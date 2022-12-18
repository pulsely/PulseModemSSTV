//
//  SideBarView.swift
//  SSTVGenerator
//
//  Created by Kenneth Lo on 12/17/22.
//

import SwiftUI
import CoreData

struct SideBarView: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SSTVGeneration.timestamp, ascending: false)],
        animation: .default) var histories: FetchedResults<SSTVGeneration>
    let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var body: some View {
        List {
            Section(header: Text("Functions")) {
                
                NavigationLink(destination: GenerationView()) {
                    Label("New SSTV Image", systemImage: "plus")
                }
                
            }
            
            Section(header: Text("History")) {
                ForEach (histories) { history in
                    NavigationLink( destination: HistoryView(history: history)) {
                        HStack {
                            if (history.thumbnail != nil) {
                                Image(nsImage: NSImage(data: history.thumbnail!)!)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(5.0)
                            } else {
                                Rectangle().fill( Color("lightgray")).frame(width: 40, height: 40)
                                    .cornerRadius(5.0)
                            }
                            VStack(alignment: .leading) {
                                Text( history.filename ?? "" ).foregroundColor(.accentColor)
                                Text( "\(history.timestamp!, formatter: itemFormatter)")
                                    .font(.footnote)
                                
                                
                                
                            }
                        }
                    }
                }
                
            }
        }.listStyle( SidebarListStyle() )
            .frame(minWidth: 300)
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView()
    }
}
