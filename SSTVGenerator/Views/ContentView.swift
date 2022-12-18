//
//  ContentView.swift
//  SSTVGenerator
//
//  Created by Kenneth Lo on 12/14/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    
    
    
    var body: some View {
        NavigationView {
            
            SideBarView()
            GenerationView()
        }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
