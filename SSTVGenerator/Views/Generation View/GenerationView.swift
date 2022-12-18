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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    /*
                    if (self.viewModel.current_status == .fileSelected) {
                        AsyncImage(
                            url: URL(fileURLWithPath: self.viewModel.full_path),
                            content: { image in
                                image.resizable()
                                     .aspectRatio(contentMode: .fit)
                                     .frame(maxWidth: 400, maxHeight: 400)
                                     .cornerRadius(8)

                            },
                            placeholder: {
                                ProgressView()
                            }
                        )


                    } else {
                        DragDropImageView(post_action: {
                            
                        }).frame(maxWidth: 400, maxHeight: 400)

                    }*/
                    DragDropImageView( image: self.$viewModel.image,
                                       filename: self.$viewModel.filename,
                                       full_path: self.$viewModel.full_path, post_action: {
                        self.viewModel.current_status = .fileSelected

                    }).frame(maxWidth: 400, maxHeight: 400)

                    
                    VStack {
                        Button(action: self.viewModel.openPanel) {
                            Text("Select a JPEG or PNG file")
                        }
                        
                        if (self.viewModel.current_status == .selectFile) {
                            Text("Please select an image file to convert")
                        }
                        
                        if (self.viewModel.current_status == .fileSelected) {
                            
                            Picker("",  selection: self.$viewModel.sstv_type) {
                                ForEach(self.viewModel.sstv_types) { sstytype in
                                    Text( sstytype.value ).tag( sstytype.id )
                                }
                            }//.pickerStyle()
                                .labelsHidden()
                                .onChange(of: self.viewModel.sstv_type) { value in
                                    //self.viewModel.pickerLoggerTypeUpdated()
                                }

                            
                            
                            Button(action: {
                                self.viewModel.startSSTVConversion(viewContext: self.viewContext)
                            } ) {
                                Text("Generate SSTV signal")
                            }
                        }
                        

                        Spacer()
                    }

                }
                
                if (self.viewModel.hasWavAudio()) {
                    if (self.viewModel.player != nil && self.viewModel.player!.isPlaying) {
                        Button(action: {
                            
                            
                            self.viewModel.stopAudio()
                        }) {
                            Text("Stop Wav")
                        }
                    } else {
                        Button(action: {
                            
                            
                            self.viewModel.playAudio()
                        }) {
                            Text("Play Wav")
                        }

                    }

                    
                    
                }

            }.padding(.top)
        }.task {
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
