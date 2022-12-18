//
//  HistoryView.swift
//  SSTVGenerator
//
//  Created by Kenneth Lo on 12/17/22.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var history: SSTVGeneration
    @StateObject var viewModel:HistoryViewModel = HistoryViewModel()
    
    var body: some View {
        VStack {

            
            HStack {
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
                Spacer()
                Button(action: {
                    self.viewModel.deleteHistory(viewContext: self.viewContext, history: self.history)
                }) {
                    Label("Delete", systemImage: "trash.fill")

                    
                }
            }
            Image(nsImage: NSImage(data: history.image!)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)

            

        }.padding()
        .navigationTitle( self.history.filename ?? "Untitled file")
            .task {
                self.viewModel.data = self.history.wav
            }
    }
}

//struct HistoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        HistoryView()
//    }
//}
