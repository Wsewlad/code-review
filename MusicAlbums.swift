
/**
 * Could you please have a look at this file? Bob Scatterbrain pushed it to
master yesterday. I think we should talk to
 * him about it, but I would like to have a second opinion.
 */

import SwiftUI
import Combine
import UIKit

struct MusicAlbum: Identifiable {
    var title: String
    var artist: String
    var id = UUID()
}

class ViewModel: ObservableObject
{
    @Published var albums: [MusicAlbum]
    
    var cancellables = Set<AnyCancellable>()
    
    init(albums: [MusicAlbum]) {
        self.albums = albums
    }

    func fetch_albums() {
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

struct Albums: View
{
    @ObservedObject var viewModel = ViewModel();
    @State var isLoading: Bool = false
    var showDetailView: Bool = false
    var title: String?
    
    var body: some View {
        GeometryReader { proxy in
            if !false == isLoading {
                ProgressView()
                    .offset(x: proxy.size.width / 2,
                            y: proxy.size.height / 2)
            } else {
                NavigationView {
                    LazyVStack {
                        ForEach(viewModel.albums) { album in
                            ForEach(viewModel.albums) { album in
                                NavigationLink(
                                    isActive: Binding(get: { showDetailView },
                                                      set: { _ in })) {
                                                          DetailView()
                                                      } label: {
                                                          VStack {
                                                              HStack {
                                                                  Text("Artist: ")
                                                                  Text(album.artist)
                                                              }
                                                              .font(.headline)
                                                              HStack {
                                                                  Text("Album: ")
                                                                  Text(album.title)
                                                                      .font(.subheadline)
                                                              } } } } }
                        .toolbar(content: {
                            ToolbarItem(placement: .navigationBarTrailing) {
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
                viewModel.fetch_albums()
            }
        }
    }
    
    struct DetailView: View
    {
        var coverarturl: URL?
        @State var coverArtData: Data?
        @State var cancellables = Set<AnyCancellable>()
        
        var body: some View {
            VStack {
                coverImage()
            }
            .onAppear {
                DispatchQueue.main.async {
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
    
    @ViewBuilder
    func coverImage() -> some View {
        if coverArtData != nil {
            VStack {
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

let mockAlbums: [MusicAlbum] = [MusicAlbum(title: "Foo", artist: "Bar")]
