////
////  FeatureCollection.swift
////  Titan Routes
////
////  Created by Ali Main on 10/1/24.
////
//
//import Foundation
//import Foundation
//import CoreLocation
//
//struct FeatureCollection: Codable {
//    let features: [Feature]
//}
//
//
//
//
//
//
//
//class JSONManager {
//    static func loadFeatures(from file: String) -> [CustomFeature]? {
//        guard let path = Bundle.main.path(forResource: file, ofType: "json") else {
//            print("JSON file not found.")
//            return nil
//        }
//
//        do {
//            let data = try Data(contentsOf: URL(fileURLWithPath: path))
//            let decoder = JSONDecoder()
//            let featureCollection = try decoder.decode(CustomFeatureCollection.self, from: data)
//            return featureCollection.features
//        } catch {
//            print("Error decoding JSON: \(error)")
//            return nil
//        }
//    }
//}
//
//
//
//
//
//
//struct CustomFeatureCollection: Codable {
//    let features: [CustomFeature]
//}
//
//struct CustomFeature: Codable {
//    let type: String
//    let properties: CustomProperties
//    let geometry: CustomGeometry
//}
//
//struct CustomProperties: Codable {
//    let id: Int
//    let name: String
//    let floor: Int
//    let classRoom: String
//}
//
//struct CustomGeometry: Codable {
//    let coordinates: [[[Double]]]
//    let type: String
//}
//
