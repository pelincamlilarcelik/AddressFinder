//
//  Address.swift
//  AddressFinder
//
//  Created by Onur Celik on 5.04.2023.
//

import Foundation
import MapKit
struct Address: Codable{
    let data : [Pin]
}

struct Pin : Codable{
    
    let latitude: Double
    let longitude: Double
    let name: String?
    
}
struct Location: Identifiable{
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    
}

@MainActor class ViewModel: ObservableObject{
    private let BASE_URL = "http://api.positionstack.com/v1/forward"
    private let API_KEY = "2cf756704c6a2086ecedfe6025be067c"
    
    @Published var coordinates = []
    @Published var region : MKCoordinateRegion
    @Published var locations: [Location] = []
    init(){
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 36.884804, longitude: 30.704044), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        self.locations.insert(Location(name: "pin", coordinate: CLLocationCoordinate2D(latitude: 36.884804, longitude: 30.704044)), at: 0)
    }
    
    func getLocation(address:String,delta:Double){
        let address_string = address.replacingOccurrences(of: " ", with: "%20")
        guard let url = URL(string: "\(BASE_URL)?access_key=\(API_KEY)&query=\(address_string)") else{
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else{
                print("Failed to get data")
                print(error?.localizedDescription ?? "Error")
                return
            }
            do{
                
                let newCoordinates = try JSONDecoder().decode(Address.self, from: data)
                if newCoordinates.data.isEmpty{
                    print("Couldn't find the address")
                    return
                }
                
                DispatchQueue.main.async {
                    let details = newCoordinates.data[0]
                    let lat = details.latitude
                    let lon = details.longitude
                    let name = details.name ?? "Pin"
                    self.coordinates = [lat,lon]
                    let coordinate = Location(name: name, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                    self.locations.removeAll()
                    self.locations.insert(coordinate, at: 0)
                    self.region = MKCoordinateRegion(center: coordinate.coordinate, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
                }
                
            }catch{
                print(error)
                
            }
        }.resume()
    }
}
