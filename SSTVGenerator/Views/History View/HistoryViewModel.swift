//
//  HistoryViewModel.swift
//  SSTVGenerator
//
//  Created by Kenneth Lo on 12/18/22.
//

import Foundation
import AVKit

class HistoryViewModel: ObservableObject {
    @Published var data:Data?
    @Published var player: AVAudioPlayer?
    
    func deleteHistory(viewContext: NSManagedObjectContext, history:SSTVGeneration) {
        viewContext.delete( history)
        try? viewContext.save()

    }
    
    func playAudio() {
        if self.data == nil {
            return
        }
        do {
            self.player = try AVAudioPlayer(data: self.data!) /// make the audio player
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
    
    func hasWavAudio() -> Bool {
        if self.data != nil {
            return true
        } else {
            return false
        }
    }
}
