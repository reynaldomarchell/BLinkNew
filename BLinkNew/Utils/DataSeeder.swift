//
//  DataSeeder.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import Foundation
import SwiftData

class DataSeeder {
   static func seedInitialData(modelContext: ModelContext) {
    print("Starting data seeding...")
    
    // Seed bus routes
    let busRoutes = [
        BusRoute(
            routeName: "The Breeze - AEON - ICE - The Breeze Loop Line",
            startPoint: "The Breeze",
            endPoint: "The Breeze",
            stations: [
                Station(name: "The Breeze", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Timur 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Selatan", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "AEON Mall 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "AEON Mall 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CDB Utara 3", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE Business Park", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 6", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 5", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Barat 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Barat 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Lobby AEON Mall", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Timur 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Navapark 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Green cove", isCurrentStation: false, isPreviousStation: false, isNextStation: false)
            ],
            routeCode: "BC",
            color: "purple",
            estimatedTime: 65,
            distance: 6.9,
            routeDescription: "The Breeze → AEON → ICE → The Breeze Loop Line"
        ),
        BusRoute(
            routeName: "Greenwich - Sektor 1.3 Loop Line",
            startPoint: "Greenwich Park",
            endPoint: "Halte Sektor 1.3",
            stations: [
                Station(name: "Greenwich Park", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Timur 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Selatan", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "AEON Mall 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "AEON Mall 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CDB Utara 3", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE Business Park", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 6", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 5", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Barat 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Barat 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Lobby AEON Mall", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Timur 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Navapark 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Green cove", isCurrentStation: false, isPreviousStation: false, isNextStation: false)
            ],
            routeCode: "GS",
            color: "green",
            estimatedTime: 65,
            distance: 6.9,
            routeDescription: "Greenwich - Sektor 1.3 Loop Line"
        ),
        BusRoute(
            routeName: "Intermoda - Halte Sektor 1.3",
            startPoint: "Intermoda",
            endPoint: "Halte Sektor 1.3",
            stations: [
                Station(name: "Intermoda", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Cosmo", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Verdan View", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Eternity", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Simplicity 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Edutown 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Edutown 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 6", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 5", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "GOP 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "SML Plaza", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "The Breeze", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Timur 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Timur 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Navapark 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "SWA 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Giant", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Eka Hostpital 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Puspita Loka", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Polsek Serpong", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Pasmod Timur", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Griyaloka 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Halte Sektor 1.3", isCurrentStation: false, isPreviousStation: false, isNextStation: false)
            ],
            routeCode: "IS",
            color: "teal", // Changed from "black" to "teal" for better visibility in dark mode
            estimatedTime: 69,
            distance: 6.9,
            routeDescription: "Intermoda - Sektor 1.3 Loop Line"
        ),
        BusRoute(
            routeName: "Intermoda - De Park 1",
            startPoint: "Intermoda",
            endPoint: "Intermoda",
            stations: [
                Station(name: "Intermoda", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Edutown 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Edutown 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 6", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 5", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Froggy", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Gramedia", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Astra", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Court Mega Store", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "QBIG 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Lulu", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Greenwich Park 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Greenwich Park Office", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Jadeite", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "De Maja", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "De Heliconia 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "De Nara", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Navapark 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "GOP 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "SML Plaza", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "The Breeze", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Casa De Parco 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Lobby House of Tiktokers", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Digital Hub 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Digital Hub 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Verdant View", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Eternity", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Intermoda", isCurrentStation: false, isPreviousStation: false, isNextStation: false)
            ],
            routeCode: "ID1",
            color: "lightBlue",
            estimatedTime: 47,
            distance: 6.9,
            routeDescription: "Intermoda - De Park 1 Loop Line"
        ),
        BusRoute(
            routeName: "Intermoda - De Park 2",
            startPoint: "Intermoda",
            endPoint: "Intermoda",
            stations: [
                Station(name: "Intermoda", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Icon Ncentro", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Horizon Broadway", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Extreme Park", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Saveria", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Casa De Parco 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "SML Plaza", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "The Breeze", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Timur 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "AEON Mall 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "AEON Mall 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Timur 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Simpang Foresta", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Allenvare", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Fiore", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Studento 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Naturale", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Fresco", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Primavera", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Foresta 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "De Park 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "De Frangipani", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "De Heliconia 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "De Brassia", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Jadeite", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Greenwich Park 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "QBIG 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "QBIG 3", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "BCA", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "FBL 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "FBL 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 6", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 5", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Barat 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Barat 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Simplicity 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Intermoda", isCurrentStation: false, isPreviousStation: false, isNextStation: false)
            ],
            routeCode: "ID2",
            color: "pink",
            estimatedTime: 50,
            distance: 6.9,
            routeDescription: "Intermoda - De Park 2 Loop Line"
        ),
        BusRoute(
            routeName: "Intermoda - Vanya",
            startPoint: "Intermoda",
            endPoint: "Intermoda",
            stations: [
                Station(name: "Intermoda", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Simplicity 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Edutown 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Edutown 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 6", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Prestigia", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "The Mozia 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Piazza Mozia", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Tabebuya", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Vanya Park", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "The Mozia 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Illustria", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 6", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 5", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Barat 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Barat 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Simplicity 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Intermoda", isCurrentStation: false, isPreviousStation: false, isNextStation: false)
            ],
            routeCode: "IV",
            color: "darkgreen",
            estimatedTime: 35,
            distance: 6.9,
            routeDescription: "Intermoda - Vanya Park Loop Line"
        ),
        BusRoute(
            routeName: "Electric Line",
            startPoint: "Intermoda",
            endPoint: "Intermoda",
            stations: [
                Station(name: "Intermoda", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Simplicity 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Edutown 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Edutown 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 6", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 5", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Froggy", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Gramedia", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Astra", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Court Mega Store", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "QBIG 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Lulu", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "QBIG 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "QBIG 3", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "BCA", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "FBL 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "FBL 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "GOP 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "SML Plaza", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "The Breeze", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Casa De Parco 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Lobby House of Tiktokers", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Digital Hub 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Saveria", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Casa De Parco 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Timur 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Lobby AEON Mall", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Barat 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Simplicity 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Intermoda", isCurrentStation: false, isPreviousStation: false, isNextStation: false)
            ],
            routeCode: "EC",
            color: "navy",
            estimatedTime: 53,
            distance: 6.9,
            routeDescription: "Electric Line | Intermoda - ICE - QBIG - Ara Rasa - The Breeze - Digital Hub - AEON Mall Loop Line"
        ),
        BusRoute(
            routeName: "Big Bus Line",
            startPoint: "Intermoda",
            endPoint: "Intermoda",
            stations: [
                Station(name: "Intermoda", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Simplicity 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Edutown 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Edutown 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 6", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "ICE 5", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Froggy", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Gramedia", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Astra", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Court Mega Store", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "QBIG 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Lulu", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "QBIG 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "QBIG 3", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "BCA", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "FBL 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "FBL 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "GOP 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "SML Plaza", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "The Breeze", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Timur 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "AEON Mall / Sky House", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "CBD Barat 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Simplicity 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                Station(name: "Intermoda", isCurrentStation: false, isPreviousStation: false, isNextStation: false)
            ],
            routeCode: "BB",
            color: "red",
            estimatedTime: 53,
            distance: 6.9,
            routeDescription: "The Big Bus Electric | INTERMODA - I C E - QBIG - ARA RASA -THE BREEZE - SKY HOUSE / AEON MALL - INTERMODA"
        ),
    ]
    

    let busInfos = [
        BusInfo(plateNumber: "B7566PAA", routeCode: "GS", routeName: "Greenwich - Sektor 1.3 Loop Line"),
        BusInfo(plateNumber: "B7266JF", routeCode: "GS", routeName: "Greenwich - Sektor 1.3 Loop Line"),
        BusInfo(plateNumber: "B7466PAA", routeCode: "GS", routeName: "Greenwich - Sektor 1.3 Loop Line"),
        BusInfo(plateNumber: "B7366JE", routeCode: "ID1", routeName: "Intermoda - De Park 1"),
        BusInfo(plateNumber: "B7366PAA", routeCode: "ID2", routeName: "Intermoda - De Park 2"),
        BusInfo(plateNumber: "B7866PAA", routeCode: "ID2", routeName: "Intermoda - De Park 2"),
        BusInfo(plateNumber: "B7666PAA", routeCode: "IS", routeName: "Intermoda - Halte Sektor 1.3"),
        BusInfo(plateNumber: "B7966PAA", routeCode: "IS", routeName: "Intermoda - Halte Sektor 1.3"),
        BusInfo(plateNumber: "B7002PGX", routeCode: "EC", routeName: "Electric Line | Intermoda - ICE - QBIG - Ara Rasa - The Breeze - Digital Hub - AEON Mall Loop Line"),
        BusInfo(plateNumber: "B7166PAA", routeCode: "BC", routeName: "The Breeze - AEON - ICE - The Breeze Loop Line"),
        BusInfo(plateNumber: "B7866PAA", routeCode: "BC", routeName: "The Breeze - AEON - ICE - The Breeze Loop Line"),
        BusInfo(plateNumber: "B7766PAA", routeCode: "IV", routeName: "Intermoda - Vanya"),
        
    ]
    
    // Insert data into the model context
    for route in busRoutes {
        modelContext.insert(route)
        print("Inserted route: \(route.routeCode)")
    }
    
    for busInfo in busInfos {
        modelContext.insert(busInfo)
    }
    
    // Try to save changes immediately
    do {
        try modelContext.save()
        print("Successfully saved model context after seeding")
    } catch {
        print("Error saving model context: \(error)")
    }
    
    // Print debug info
    print("Data seeding completed successfully")
    print("Seeded bus infos: \(busInfos.map { $0.plateNumber })")
    print("Seeded routes: \(busRoutes.map { $0.routeCode })")
    
    // Verify routes were added
    do {
        let descriptor = FetchDescriptor<BusRoute>()
        let count = try modelContext.fetchCount(descriptor)
        print("After seeding, database has \(count) routes")
    } catch {
        print("Error verifying route count: \(error)")
    }
}

   // Function to clear all existing data
   static func clearAllData(modelContext: ModelContext) {
       do {
           // Clear BusInfo
           let busInfoDescriptor = FetchDescriptor<BusInfo>()
           let busInfos = try modelContext.fetch(busInfoDescriptor)
           for busInfo in busInfos {
               modelContext.delete(busInfo)
           }
           
           // Clear BusRoute
           let routeDescriptor = FetchDescriptor<BusRoute>()
           let routes = try modelContext.fetch(routeDescriptor)
           for route in routes {
               modelContext.delete(route)
           }
           
           // Try to save changes immediately
           try modelContext.save()
           print("All existing data cleared successfully")
       } catch {
           print("Error clearing data: \(error)")
       }
   }
    
    // Add a function to update station status based on current time
    static func updateStationStatus(route: BusRoute) {
        // Get the current time
        let currentTime = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentTime)
        let currentMinute = calendar.component(.minute, from: currentTime)
        
        // Calculate the total minutes since midnight
        let currentTotalMinutes = currentHour * 60 + currentMinute
        
        // Determine which station is current based on time
        // This is a simplified algorithm - in a real app, you'd use actual bus schedules
        let totalStations = route.stations.count
        let cycleTime = route.estimatedTime // minutes for a full cycle
        
        // Calculate which station in the cycle we're at
        let minutesIntoDay = currentTotalMinutes % cycleTime
        let stationIndex = Int(Double(minutesIntoDay) / Double(cycleTime) * Double(totalStations)) % totalStations
        
        // Update station statuses
        for i in 0..<route.stations.count {
            route.stations[i].isCurrentStation = (i == stationIndex)
            route.stations[i].isPreviousStation = (i == (stationIndex - 1 + totalStations) % totalStations)
            route.stations[i].isNextStation = (i == (stationIndex + 1) % totalStations)
            
            // Set arrival times
            let minutesFromNow = ((i - stationIndex + totalStations) % totalStations) * (cycleTime / totalStations)
            route.stations[i].arrivalTime = calendar.date(byAdding: .minute, value: minutesFromNow, to: currentTime)
        }
    }

    // Add a function to get the nearest bus stop
    static func getNearestBusStop(latitude: Double, longitude: Double) -> Station? {
        // This would normally use actual geolocation data
        // For this demo, we'll just return a fixed station
        return Station(
            name: "The Breeze",
            arrivalTime: Date(),
            isCurrentStation: true,
            isPreviousStation: false,
            isNextStation: false
        )
    }
}
