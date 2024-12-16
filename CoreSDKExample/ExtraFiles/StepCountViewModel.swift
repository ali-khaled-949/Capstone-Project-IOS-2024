//import Foundation
//import SwiftUI
//import HealthKit
//import Combine
//
//
//class StepCountViewModel: ObservableObject {
//    @Published var stepsToday: Int = 0
//    private let healthStore = HKHealthStore() // Define healthStore at the class level
//
//    init() {
//        requestAuthorization()
//    }
//
//    private func requestAuthorization() {
//        guard HKHealthStore.isHealthDataAvailable() else { return }
//        
//        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
//        healthStore.requestAuthorization(toShare: [], read: [stepType]) { [weak self] success, error in
//            DispatchQueue.main.async {
//                if success {
//                    self?.fetchTodayStepCount() // Initial fetch
//                    self?.startStepCountObserver() // Start observing changes
//                } else {
//                    print("Authorization failed: \(String(describing: error))")
//                }
//            }
//        }
//    }
//    
//
//    private func fetchTodayStepCount() {
//        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
//        let now = Date()
//        let startOfDay = Calendar.current.startOfDay(for: now)
//        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
//
//        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
//            guard let result = result, let sum = result.sumQuantity() else { return }
//            DispatchQueue.main.async {
//                self.stepsToday = Int(sum.doubleValue(for: HKUnit.count()))
//            }
//        }
//        healthStore.execute(query)
//    }
//
//   
//    private func startStepCountObserver() {
//        // Ensure HealthKit is available and step count type is valid
//        guard HKHealthStore.isHealthDataAvailable(),
//              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
//            print("Health data is not available or step count type is invalid.")
//            return
//        }
//
//        // Observer query to monitor step count updates
//        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, error in
//            if let error = error {
//                print("Observer query failed: \(error.localizedDescription)")
//                return
//            }
//            // Fetch updated step count whenever there’s new data
//            self?.fetchTodayStepCount()
//        }
//
//        // Execute the query
//        healthStore.execute(query)
//
//        // Enable background delivery to get step count updates even when the app is in the background
//        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
//            if let error = error {
//                print("Failed to enable background delivery: \(error.localizedDescription)")
//            } else if success {
//                print("Background delivery enabled for step count.")
//            }
//        }
//    }
//
//}
//
//
//
//
//
//struct SectionHeader: View {
//    let title: String
//
//    var body: some View {
//        HStack {
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.white)
//            Spacer()
//        }
//        .padding(.horizontal)
//    }
//}
//
//struct CardView: View {
//    let content: String
//
//    var body: some View {
//        Text(content)
//            .font(.headline)
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.white.opacity(0.1))
//            .cornerRadius(10)
//            .padding(.horizontal)
//    }
//}
//
//struct CameraFeedView: View {
//    var body: some View {
//        HStack {
//            ForEach(0..<2) { _ in
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color.gray.opacity(0.5))
//                    .frame(width: 150, height: 100)
//                    .overlay(
//                        Image(systemName: "video.fill")
//                            .foregroundColor(.white)
//                            .font(.system(size: 40))
//                    )
//            }
//        }
//        .padding(.horizontal)
//    }
//}
//
//
//
//
//// MARK: - Category Tabs
//struct CategoryTabsView: View {
//    @Binding var selectedCategory: String
//
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 15) {
//                ForEach(["All", "Music", "Nature", "Tech"], id: \.self) { category in
//                    Text(category)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 8)
//                        .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
//                        .foregroundColor(selectedCategory == category ? .white : .gray)
//                        .cornerRadius(20)
//                        .onTapGesture {
//                            selectedCategory = category
//                        }
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//}
//
//
//
//// MARK: - Content Section
//struct ContentSectionView: View {
//    let title: String
//    let content: String
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.white)
//                .padding(.horizontal)
//
//            Text(content)
//                .font(.headline)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color.white.opacity(0.1))
//                .cornerRadius(10)
//                .padding(.horizontal)
//        }
//    }
//}
