//
//  GenerationViewModel.swift
//  SSTVGenerator
//
//  Created by Kenneth Lo on 12/16/22.
//

import Foundation
import SwiftUI
import Python
import PythonKit
import AVKit


enum CurrentStatus {
    case selectFile
    case fileSelected
    case converting
    case completed
    case failure
}

class GenerationViewModel: ObservableObject {
    @Published var current_status:CurrentStatus = .selectFile
    
    @Published var image: NSImage?

    @Published var filename = ""

    @Published var full_path = ""
    @Published var sstv:PythonObject?
    @Published var wav_path:URL?
    
    @Published var player: AVAudioPlayer?

    func openPanel() {
        let panel = NSOpenPanel()
        
        panel.title = "Choose an image | Our Code World";
        panel.allowedContentTypes = [ .jpeg, .png];
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK {
            self.filename = panel.url?.lastPathComponent ?? "<none>"

            self.full_path = panel.url!.path
            self.current_status = .fileSelected
        }
    }
    
    func startSSTVConversion(viewContext: NSManagedObjectContext) {
        self.sstv = Python.import("sstv")
        
        let temporary_folder:String = FileManager.default.temporaryDirectory.absoluteString

        let wav_path_string = self.sstv?.convert_image( temporary_folder, "Robot36", self.full_path ) ?? ""
        
        if wav_path_string.count > 0 {
            self.wav_path = URL(fileURLWithPath: "\(wav_path_string ?? "")")
                
            debugPrint(  "Wave coversion made to: \(self.wav_path)" )


            let generation = SSTVGeneration(context: viewContext)
            generation.filename = self.filename
            generation.image = try? Data(contentsOf: URL(fileURLWithPath: self.full_path))
            generation.thumbnail = self.image?.resize(withSize: NSSize(width: 100, height: 100))?.PNGRepresentation
            generation.wav = try? Data(contentsOf: self.wav_path!)
            generation.timestamp = Date()
            try? viewContext.save()

        } else {
            debugPrint(">> Invalid image")
        }
        

    }

    func initializePython() {
        // we now have a Python interpreter ready to be used
        guard let stdLibPath = Bundle.main.path(forResource: "python-stdlib", ofType: nil) else { return }
        guard let libDynloadPath = Bundle.main.path(forResource: "python-stdlib/lib-dynload", ofType: nil) else { return }
        
        guard let sitepackages = Bundle.main.path(forResource: "venv/lib/python3.10/site-packages", ofType: nil) else { return }

        guard let src = Bundle.main.path(forResource: "src", ofType: nil) else { return }
        setenv("PYTHONHOME", stdLibPath, 1)
        setenv("PYTHONPATH", "\(stdLibPath):\(libDynloadPath)", 1)
        Py_Initialize()
        
        let sys = Python.import("sys")
        sys.path.append(sitepackages)
        sys.path.append(src)
//
//        print("Python Version: \(sys.version_info.major).\(sys.version_info.minor)")
//        print("Python Encoding: \(sys.getdefaultencoding().upper())")
//        print("Python Path: \(sys.path)")
        
    }
    
    func hasWavAudio() -> Bool {
        let url = "\(self.wav_path?.absoluteString ?? "")"
        if self.wav_path != nil && url.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func playAudio() {
        if self.wav_path == nil {
            return
        }
        do {
            self.player = try AVAudioPlayer(contentsOf: self.wav_path!) /// make the audio player
            self.player?.currentTime = 0
            self.player?.prepareToPlay()
            self.player?.play()


        } catch {
            print("Couldn't play audio. Error: \(error)")
        }

    }
    
    func stopAudio() {
        if self.player != nil {
            self.player?.stop()
            self.player?.currentTime = 0
            
            self.player = nil
        }
    }

}