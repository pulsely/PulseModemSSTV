//
//  GenerationView.swift
//  SSTVGenerator
//
//  Created by Kenneth Lo on 12/16/22.
//

import SwiftUI
import AVFoundation

struct GenerationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var viewModel: GenerationViewModel = GenerationViewModel()
    
    @State private var current_status:CurrentStatus = .selectFile
    
    var generation_view : some View {
        Group {
            HStack {
                Button(action: self.viewModel.openPanel) {
                    Text("Select a JPEG or PNG file")
                }
                
                //                    if (self.viewModel.current_status == .selectFile) {
                Text("Please select an image file to convert")
                //                    }
                
                Spacer()
            }
            
            HStack {
                Picker("",  selection: self.$viewModel.sstv_type) {
                    ForEach(self.viewModel.sstv_types) { sstytype in
                        Text( sstytype.value ).tag( sstytype.id )
                    }
                }//.pickerStyle()
                .labelsHidden()
                .onChange(of: self.viewModel.sstv_type) { value in
                    //self.viewModel.pickerLoggerTypeUpdated()
                }
                .disabled(self.viewModel.current_status != .fileSelected)
                
                
                
                Button(action: {
                    self.viewModel.startSSTVConversion(viewContext: self.viewContext)
                } ) {
                    Label("Generate SSTV signal", systemImage: "waveform")
                }                        .disabled(self.viewModel.current_status != .fileSelected)
                
                if (self.viewModel.player != nil && self.viewModel.player!.isPlaying) {
                    Button(action: {
                        
                        
                        self.viewModel.stopAudio()
                    }) {
                        Label("Stop Wav", systemImage: "stop.fill")
                        
                    }.disabled(!self.viewModel.hasWavAudio())
                } else {
                    Button(action: {
                        
                        
                        self.viewModel.playAudio()
                    }) {
                        Label("Play Wave", systemImage: "play.fill")
                    }.disabled(!self.viewModel.hasWavAudio())
                    
                }
                
            }
            
            
            
            
            DragDropImageView( image: self.$viewModel.image,
                               filename: self.$viewModel.filename,
                               full_path: self.$viewModel.full_path, post_action: {
                self.viewModel.current_status = .fileSelected
                
            }).padding(.top, 5)

        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if (utsname.isAppleSilicon) {
                generation_view
            } else {
                Text("Sorry, PulseModem SSTV cannot run on Intel platform")
                    .font(.title2)
                    .padding(.bottom)
                
                Text("Please run PulseModem SSTV on an Apple Silicon computer")
                    .foregroundColor(.gray)
            }

        }.padding()
            .task {
                self.viewModel.initializePython()
            }
            .frame(minWidth: 600)
            .navigationTitle("PulseModem SSTV Generator")
    }
}

struct GenerationView_Previews: PreviewProvider {
    static var previews: some View {
        GenerationView()
    }
}
