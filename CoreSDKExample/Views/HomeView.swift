import SwiftUI
import GameKit
import AVFAudio
import SwiftProtobuf
import MapboxNavigationCore
import FirebaseAuth
import Combine
import FirebaseFirestore

// MARK: - Step Count ViewModel





// MARK: - Header View
struct HeaderView: View {
    let title: String
    let imageName: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            Spacer()
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
        .padding(.horizontal, 16)
        .padding(.top, 40)
    }
    
    
    struct RoundedCardView: View {
        var text: String
        var color: Color
        
        var body: some View {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(color)
                .cornerRadius(8)
                .shadow(radius: 3)
                .padding(.horizontal)
        }
    }
    // MARK: - Category Tabs
    struct CategoryTabs: View {
        @Binding var selectedCategory: String
        let categories = ["Top Stories", "Local", "Campus", "Technology"]
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .onTapGesture {
                                selectedCategory = category
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Search Bar

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.orange)
            TextField("Search...", text: $text)
                .foregroundColor(.white)
                .padding(8)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal, 16)
    }
}
//
//// MARK: - News Card View
//struct NewsCardView: View {
//    let post: NewsPost
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(post.title.rendered)
//                .font(.headline)
//                .foregroundColor(.primary)
//                .lineLimit(2)
//
//            if !post.excerpt.plainText.isEmpty {
//                Text(post.excerpt.plainText)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .lineLimit(2)
//            }
//        }
//        .padding(16)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color(UIColor.systemBackground))
//                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//        )
//    }
//}

struct Location: Identifiable, Equatable {
    let id = UUID()  // Unique identifier for SwiftUI lists
    let title: String
    let lat: Double
    let lon: Double
    let altitude: Double
    let type: TestAnnotationType
    

    // Implement Equatable
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}
//
//struct NewsTabView: View {
//    @StateObject var viewModel = NewsViewModel()
//    @ObservedObject var favoritesViewModel: FavoritesViewModel // Passed from ContentView
//    let locationDictionary: [String: Location] // Passed from ContentView
//    @State private var selectedCategory = "Top Stories"
//    @State private var searchText = ""
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 20) {
//                    HeaderView(title: "Home", imageName: "YourLogoImageName")
//
//                    // Favorites Section
//                    Section(header: Text("Lastest News").font(.headline)) {
////                        if favoritesViewModel.favoriteLocations.isEmpty {
////                            Text("No favorite locations saved yet.")
////                                .foregroundColor(.gray)
////                        } else {
////                            LazyVStack(spacing: 10) { // Use LazyVStack for better performance
////                                ForEach(favoritesViewModel.favoriteLocations.keys.compactMap { locationName in
////                                    locationDictionary[locationName] // Convert favorite location names to Location objects
////                                }, id: \.id) { location in
////                                    if favoritesViewModel.favoriteLocations[location.title] == true {
////                                        LocationCardView(location: location, favoritesViewModel: favoritesViewModel)
////                                    }
////                                }
////                            }
////                        }
//                    }
//                    .padding()
//
//                    // News list
//                    NewsList(viewModel: viewModel, searchText: $searchText)
//                }
//            }
//            .background(LinearGradient(gradient: Gradient(colors: [Color(.systemBlue), Color(.systemIndigo)]),
//                                       startPoint: .top, endPoint: .bottom)
//                            .edgesIgnoringSafeArea(.all))
//            .navigationBarHidden(true)
//            .onAppear {
//                favoritesViewModel.loadFavorites() // Load favorites when the view appears
//            }
//            .refreshable {
//                viewModel.resetNews()
//                favoritesViewModel.loadFavorites() // Refresh the favorites as well
//            }
//        }
//    }
//}

// Custom LocationCardView to redesign how locations are displayed
struct LocationCardView: View {
    let location: Location
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(location.title) // Title is used from the location object
                    .font(.headline)
                Spacer()
                Button(action: {
                    favoritesViewModel.toggleFavorite(locationTitle: location.title)
                }) {
                    Image(systemName: favoritesViewModel.favoriteLocations[location.title] == true ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
                .buttonStyle(PlainButtonStyle())
            }
            // Add any additional design elements here, no assumptions on the structure
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
struct LocationCardViewTwo: View {
    let location: Location
    let onNavigate: (Location) -> Void // Closure to handle navigation

    var body: some View {
        VStack(alignment: .leading) {
            Text(location.title)
                .font(.headline)
            Button(action: {
                onNavigate(location) // Call the onNavigate closure when the button is tapped
            }) {
                Text("Navigate")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .shadow(radius: 5)
    }
}



//
//// MARK: - NewsList
//struct NewsList: View {
//    @ObservedObject var viewModel: NewsViewModel
//    @Binding var searchText: String
//
//    var body: some View {
//        LazyVStack(spacing: 16) {
//            ForEach(viewModel.newsPosts.filter { post in
//                searchText.isEmpty || post.title.rendered.localizedCaseInsensitiveContains(searchText)
//            }) { post in
//                NavigationLink(destination: NewsDetailView(post: post)) {
//                    NewsCardView(post: post)
//                        .padding(.horizontal, 16)
//                        .background(Color.white)
//                        .cornerRadius(8)
//                        .shadow(radius: 3)
//                }
//                .onAppear {
//                    if post == viewModel.newsPosts.last {
//                        viewModel.fetchNews()
//                    }
//                }
//            }
//            if viewModel.isLoading {
//                ProgressView("Loading...").padding()
//            }
//        }
//    }
//}
//
//// MARK: - NewsViewModel
//class NewsViewModel: ObservableObject {
//    @Published var newsPosts: [NewsPost] = []
//    @Published var page = 1
//    @Published var isLoading = false
//    @Published var showErrorAlert = false
//    @Published var errorMessage = ""
//
//    private let urlBase = "https://titannavigators.com/wp/wp-json/wp/v2/posts?_embed"
//    private var cancellables = Set<AnyCancellable>()
//
//    init() {
//        fetchNews()
//    }
//
//    func fetchNews() {
//        guard !isLoading else { return }
//        isLoading = true
//
//        let url = URL(string: "\(urlBase)&page=\(page)")!
//
//        URLSession.shared.dataTaskPublisher(for: url)
//            .map(\.data)
//            .decode(type: [NewsPost].self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                DispatchQueue.main.async {
//                    self?.isLoading = false
//                    if case .failure(let error) = completion {
//                        self?.errorMessage = "Error fetching news: \(error.localizedDescription)"
//                        self?.showErrorAlert = true
//                    }
//                }
//            }, receiveValue: { [weak self] newPosts in
//                DispatchQueue.main.async {
//                    self?.newsPosts.append(contentsOf: newPosts)
//                    self?.page += 1
//                }
//            })
//            .store(in: &cancellables)
//    }
//
//    func resetNews() {
//        page = 1
//        newsPosts.removeAll()
//        fetchNews()
//    }
//}
//
//// MARK: - NewsPost and RenderedText Model
//struct NewsPost: Identifiable, Decodable, Equatable {
//    let id: Int
//    let title: RenderedText
//    let excerpt: RenderedText
//    let link: String
//    let _embedded: Embedded?
//
//    var featuredImageURL: String? {
//        _embedded?.wpFeaturedMedia?.first?.source_url
//    }
//
//    struct Embedded: Decodable, Equatable {
//        let wpFeaturedMedia: [FeaturedMedia]?
//        
//        struct FeaturedMedia: Decodable, Equatable {
//            let source_url: String
//        }
//    }
////}
//
//struct RenderedText: Decodable, Equatable {
//    let rendered: String
//    
//    var plainText: String {
//        let data = Data(rendered.utf8)
//        if let attributedString = try? NSAttributedString(
//            data: data,
//            options: [.documentType: NSAttributedString.DocumentType.html,
//                      .characterEncoding: String.Encoding.utf8.rawValue],
//            documentAttributes: nil
//        ) {
//            return attributedString.string
//        }
//        return rendered
//    }
//}
//
//// MARK: - NewsDetailView
//struct NewsDetailView: View {
//    let post: NewsPost
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                if let imageUrl = post.featuredImageURL, let url = URL(string: imageUrl) {
//                    AsyncImage(url: url) { image in
//                        image
//                            .resizable()
//                            .scaledToFill()
//                            .frame(height: 200)
//                            .clipped()
//                    } placeholder: {
//                        Color.gray.frame(height: 200)
//                    }
//                }
//                
//                Text(post.title.rendered)
//                    .font(.largeTitle.bold())
//                    .foregroundColor(.primary)
//                    .padding(.horizontal, 16)
//
//                Text(post.excerpt.plainText)
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .padding(.horizontal, 16)
//                    .padding(.bottom, 20)
//            }
//            .padding(.top, 10)
//        }
//        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
//        .navigationTitle("News Detail")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: openInBrowser) {
//                    VStack {
//                        Image(systemName: "globe")
//                            .font(.system(size: 22, weight: .bold))
//                            .foregroundColor(.blue)
//                        Text("Open Link")
//                            .font(.caption)
//                            .foregroundColor(.blue)
//                    }
//                    .padding(8)
//                    .background(Color.blue.opacity(0.1))
//                    .cornerRadius(8)
//                }
//            }
//        }
//    }
//    
//    private func openInBrowser() {
//        if let url = URL(string: post.link) {
//            UIApplication.shared.open(url)
//        }
//    }
//}
