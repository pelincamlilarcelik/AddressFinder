//
//  ContentView.swift
//  AddressFinder
//
//  Created by Onur Celik on 5.04.2023.
//

import SwiftUI
import MapKit
struct ContentView: View {
    @StateObject var vm = ViewModel()
    @State private var text = ""
    var body: some View {
        VStack {
            TextField("Enter Address...", text: $text)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            Button("Search") {
                vm.getLocation(address:text, delta:1)
            }
            Map(coordinateRegion: $vm.region, annotationItems: vm.locations) { pin in
                MapMarker(coordinate: pin.coordinate)
                    
            }
            .ignoresSafeArea()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
