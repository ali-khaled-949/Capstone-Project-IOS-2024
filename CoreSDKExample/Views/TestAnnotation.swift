//
//  TestAnnotation.swift
//  HDAugmentedRealityDemo
//
//  Created by Danijel Huis on 11/12/2019.
//  © 2019 Danijel Huis. All rights reserved.
//

import UIKit
import CoreLocation
import HDAugmentedReality

/// Custom annotation class for augmented reality, subclassed to include additional properties.
class TestAnnotation: ARAnnotation, RadarAnnotation {
    var type: TestAnnotationType
    
    init?(identifier: String?, title: String?, location: CLLocation, type: TestAnnotationType) {
        self.type = type
        super.init(identifier: identifier, title: title, location: location)
    }
    
    var radarAnnotationTintColor: UIColor? {
        return type.tintColor
    }
}
enum TestAnnotationType: CaseIterable {
    case postOffice, library, supermarket, hifi, paintShop, pharmacy, repairShop, home, mechanic, gameRoom
    case giftShop, performingArts, computerScience, engineering, universityHall, park, education, humanities, kinesiology
    case langsdorfHall, mccarthyHall, danBlackHall, rubyCenter, mihayloHall, visualArts, studentUnion, parkingLot
    case scienceCenter, healthCenter, businessSchool, lawSchool, dormitory, cafeteria, gymnasium, admissionsOffice, financialAidOffice
    
    /// Icon for each annotation type, using SF Symbols where available.
    var icon: UIImage? {
        let imageName: String
        switch self {
        case .postOffice: imageName = "paperplane.fill"
        case .library: imageName = "book.fill"
        case .supermarket: imageName = "cart.fill"
        case .hifi: imageName = "hifispeaker.fill"
        case .paintShop: imageName = "paintbrush.fill"
        case .pharmacy: imageName = "bandage.fill"
        case .repairShop: imageName = "hammer.fill"
        case .home: imageName = "house.fill"
        case .mechanic: imageName = "car.fill"
        case .gameRoom: imageName = "gamecontroller.fill"
        case .giftShop: imageName = "gift.fill"
        case .performingArts: imageName = "music.note.house.fill"
        case .computerScience: imageName = "desktopcomputer"
        case .engineering: imageName = "gearshape.2.fill"
        case .universityHall: imageName = "building.2.fill"
        case .park: imageName = "leaf.fill"
        case .education: imageName = "graduationcap.fill"
        case .humanities: imageName = "person.fill"
        case .kinesiology: imageName = "figure.walk"
        case .langsdorfHall: imageName = "building.columns.fill"
        case .mccarthyHall: imageName = "house"
        case .danBlackHall: imageName = "flame.fill"
        case .rubyCenter: imageName = "person.3.fill"
        case .mihayloHall: imageName = "briefcase.fill"
        case .visualArts: imageName = "paintpalette.fill"
        case .studentUnion: imageName = "person.2.circle.fill"
        case .parkingLot: imageName = "car.fill"
        case .scienceCenter: imageName = "atom"
        case .healthCenter: imageName = "cross.case.fill"
        case .businessSchool: imageName = "chart.bar.fill"
        case .lawSchool: imageName = "scales"
        case .dormitory: imageName = "bed.double.fill"
        case .cafeteria: imageName = "fork.knife"
        case .gymnasium: imageName = "figure.run"
        case .admissionsOffice: imageName = "person.badge.plus"
        case .financialAidOffice: imageName = "dollarsign.circle.fill"
        }
        
        return UIImage(systemName: imageName) ?? UIImage(named: "default_icon")?.withRenderingMode(.alwaysTemplate)
    }
    
    /// Title for each annotation type.
    var title: String {
        switch self {
        case .postOffice: return "Post Office"
        case .library: return "Library"
        case .supermarket: return "Supermarket"
        case .hifi: return "HiFi Shop"
        case .paintShop: return "Paint Shop"
        case .pharmacy: return "Pharmacy"
        case .repairShop: return "Repair Shop"
        case .home: return "Home"
        case .mechanic: return "Mechanic"
        case .gameRoom: return "Game Room"
        case .giftShop: return "Gift Shop"
        case .performingArts: return "Performing Arts Center"
        case .computerScience: return "Computer Science Building"
        case .engineering: return "Engineering Building"
        case .universityHall: return "University Hall"
        case .park: return "College Park"
        case .education: return "Education Classroom"
        case .humanities: return "Humanities"
        case .kinesiology: return "Kinesiology and Health Science"
        case .langsdorfHall: return "Langsdorf Hall"
        case .mccarthyHall: return "McCarthy Hall"
        case .danBlackHall: return "Dan Black Hall"
        case .rubyCenter: return "Ruby Gerontology Center"
        case .mihayloHall: return "Steven G. Mihaylo Hall"
        case .visualArts: return "Visual Arts"
        case .studentUnion: return "Student Union"
        case .parkingLot: return "Parking Lot"
        case .scienceCenter: return "Science Center"
        case .healthCenter: return "Health Center"
        case .businessSchool: return "Business School"
        case .lawSchool: return "Law School"
        case .dormitory: return "Dormitory"
        case .cafeteria: return "Cafeteria"
        case .gymnasium: return "Gymnasium"
        case .admissionsOffice: return "Admissions Office"
        case .financialAidOffice: return "Financial Aid Office"
        }
    }
    
    /// Tint color associated with each annotation type, using a professional color palette for differentiation.
    var tintColor: UIColor {
        switch self {
        case .postOffice, .library, .education, .pharmacy, .scienceCenter, .businessSchool, .lawSchool:
            return UIColor.systemBlue // Represents educational and service centers
            
        case .gameRoom, .home, .kinesiology, .gymnasium:
            return UIColor.systemGreen // Represents recreational and fitness-related facilities
            
        case .paintShop, .giftShop, .visualArts:
            return UIColor.systemPurple // Represents creative and artistic centers
            
        case .supermarket, .repairShop, .mechanic, .parkingLot:
            return UIColor.systemGray // Represents utility and practical services
            
        case .performingArts, .studentUnion, .humanities:
            return UIColor.systemYellow // Represents social and cultural facilities
            
        case .computerScience, .engineering, .universityHall, .admissionsOffice:
            return UIColor.systemTeal // Represents academic and administrative buildings
            
        case .park, .rubyCenter, .mccarthyHall, .danBlackHall, .cafeteria:
            return UIColor.systemOrange // Represents community areas and specialized centers
            
        case .mihayloHall, .langsdorfHall, .financialAidOffice:
            return UIColor.systemIndigo // Represents administrative and high-profile facilities
            
        case .hifi, .healthCenter:
            return UIColor.systemRed // Represents health and wellness facilities
            
        default:
            return UIColor.systemGray // Fallback color for any unhandled cases
        }
    }
}
