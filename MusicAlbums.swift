
/**
 * Could you please have a look at this file? Bob Scatterbrain pushed it to
master yesterday. I think we should talk to
 * him about it, but I would like to have a second opinion.
 */

import SwiftUI
import Combine
// TODO: - remove unused import
import UIKit

/* TODO: - Add conformance to Equitable protocol to MusicAlbum. It required when you wont to use this model in ForEach. Also, it would better to add inner `struct` for `id` for stronger typing
 `
 struct Id: Hashable, Equatable {
    var value: Int
 }
 
 var id: Id
 `
 And consider moving this struct to separate folder, for example `Models/` for better code structuring
*/
struct MusicAlbum: Identifiable {
    var title: String
    var artist: String
    var id = UUID()
}

// TODO: - Consider choosing more precise name for `ViewModel` if it's not the only one in your project, for expample `MusicAlbumsViewModel`. And I prefer creating separate file for `ViewModel` inside the module folder, for exaple `MusicAlbum/MusicAlbumsViewModel.swift`
class ViewModel: ObservableObject
{
    @Published var albums: [MusicAlbum]
    
    var cancellables = Set<AnyCancellable>()
    
    init(albums: [MusicAlbum]) {
        self.albums = albums
    }

    func fetch_albums() {
// TODO: - Consider moving networking logic to separate class, for example `class NetworkingManager` implements `protocol Networking` with required method `func fetchAlbums() -> [MusicAlbum]`. We will need `protocol` for ability top set `MockNetworkingManager` for testing. Then set `Networking` as a dependency to the ViewModel. Also, provided url seems to be invalid.
        URLSession.shared.dataTaskPublisher(for: URL(string: "1979673067.rsc.cdn77.org/music-albums.json")!)
            .map { $0.data }
            .decode(type: [MusicAlbum].self, decoder: JSONDecoder())
            .sink { completion in
                print(completion)
            } receiveValue: { albums in
                self.albums = albums
            }
    }
}

// TODO: - Consider moving this struct to separate file and choose more precise name, for example `AlbumsView`. Becouse now it looks like a Model.
struct Albums: View
{
// TODO: - You shouldn't use semicolon in this line
    @ObservedObject var viewModel = ViewModel();
    @State var isLoading: Bool = false
    var showDetailView: Bool = false
    var title: String?
    
    var body: some View {
        GeometryReader { proxy in
// TODO: - You would better rewrite this line to `if isLoading {`
            if !false == isLoading {
                ProgressView()
// TODO: - You can avoid using `GeometryReader` here to center the `ProgressView()`. Consider using `ZStack` or .overlay() instead.
                    .offset(x: proxy.size.width / 2,
                            y: proxy.size.height / 2)
            } else {
                NavigationView {
                    LazyVStack {
// TODO: - Extra `ForEach`. Consider to remove it.
                        ForEach(viewModel.albums) { album in
                            ForEach(viewModel.albums) { album in
                                NavigationLink(
                                    isActive: Binding(get: { showDetailView },
                                                      set: { _ in })) {
                                    DetailView()
                                  } label: {
                                      VStack {
// TODO: - Consider using `Text("Artist: \(album.artist)")` syntax instead of following HStack block
                                          HStack {
                                              Text("Artist: ")
                                              Text(album.artist)
                                          }
                                          .font(.headline)
// TODO: - See previous suggestion
                                          HStack {
                                              Text("Album: ")
                                              Text(album.title)
                                                  .font(.subheadline)
                                          } } } } }
// TODO: - Consider using trailing closure syntax - `.toolbar {`
                        .toolbar(content: {
                            ToolbarItem(placement: .navigationBarTrailing) {
// TODO: - Looks like missed action for the Button. Provide one or if this code is just a template, provide some TODO: - comment to not forget to add some `action` in the future.
                                Button {
                                } label: {
                                    Image(systemName: "plus")
                                }
                            }
                        })
                        .navigationTitle("My albums!")
                    }
                }
            }
            .onAppear {
                isLoading.toggle()
// TODO: - Please, use camelCase for methods naming in Swift. (There are some exeptions for naming Tests)
                viewModel.fetch_albums()
            }
        }
    }
// TODO: - Consider moving this struct to separate file
    struct DetailView: View
    {
// TODO: - Consider using camelCase for variable naming as well.
        var coverarturl: URL?
        @State var coverArtData: Data?
        @State var cancellables = Set<AnyCancellable>()
        
        var body: some View {
// TODO: - Unnecessary use of `VStack`
            VStack {
                coverImage()
            }
            .onAppear {
                DispatchQueue.main.async {
// TODO: - Consider moving Image loading logic to separate Service and handle asynchronous work, caching, etc.
                    coverarturl.map {
                        URLSession.shared.dataTaskPublisher(for: $0)
                            .sink { _ in
                            } receiveValue: { (data: Data,
                                               response: URLResponse) in
                                self.coverArtData = data
                            }
                            .store(in: &cancellables)
                    }
                }
            }
        }
    }
// TODO: - Consider moving these king of methods or computed properties in `extension DetailView {` and provide `MARK: - description` above for better navigation using minimap
    @ViewBuilder
    func coverImage() -> some View {
        if coverArtData != nil {
// TODO: - Unnecessary use of `VStack`
            VStack {
// TODO: - Avoid using force casting
                Image(uiImage: UIImage(data: coverArtData!)!)
            }
        } else {
            EmptyView()
        }
    }
}

struct ContentView_Previews {
    static var previews: some View {
        Albums(viewModel: ViewModel(albums: mockAlbums), isLoading: true)
    }
}

// TODO: - Consider adding `mockAlbums` using `extension` to `MusicAlbum` model
let mockAlbums: [MusicAlbum] = [MusicAlbum(title: "Foo", artist: "Bar")]
