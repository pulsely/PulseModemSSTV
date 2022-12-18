//
//  HistoryView.swift
//  SSTVGenerator
//
//  Created by Kenneth Lo on 12/17/22.
//

import SwiftUI

struct HistoryView: View {
    @State var history: SSTVGeneration
    @StateObject var viewModel:HistoryViewModel = HistoryViewModel()
    
    var body: some View {
        HStack {
            Image(nsImage: NSImage(data: history.image!)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: .zero, maxWidth: 600)

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

        }.navigationTitle( self.history.filename ?? "Untitled file")
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
