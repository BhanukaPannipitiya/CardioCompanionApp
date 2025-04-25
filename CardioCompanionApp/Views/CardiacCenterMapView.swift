import SwiftUI
import MapKit

class CardiacCenterViewModel: ObservableObject {
    @Published var cardiacCenters: [CardiacCenter] = []
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    init() {
        loadCardiacCenters()
    }
    
    func loadCardiacCenters() {
        cardiacCenters = [
            CardiacCenter(name: "National Hospital of Sri Lanka",
                         coordinate: CLLocationCoordinate2D(latitude: 6.9167, longitude: 79.8667),
                         address: "Regent Street, Colombo",
                         phoneNumber: "011-2691111",
                         rating: 4.8,
                         waitTime: "15 min"),
            CardiacCenter(name: "Lanka Hospitals",
                         coordinate: CLLocationCoordinate2D(latitude: 6.9144, longitude: 79.8669),
                         address: "578 Elvitigala Mawatha, Colombo",
                         phoneNumber: "011-5430000",
                         rating: 4.5,
                         waitTime: "20 min"),
            CardiacCenter(name: "Nawaloka Hospital",
                         coordinate: CLLocationCoordinate2D(latitude: 6.9178, longitude: 79.8528),
                         address: "23 Deshamanya H.K. Dharmadasa Mw, Colombo",
                         phoneNumber: "011-2544444",
                         rating: 4.7,
                         waitTime: "10 min")
        ]
    }
    
    func updateRegion(with location: CLLocation) {
        DispatchQueue.main.async {
            self.region.center = location.coordinate
        }
    }
    
    func updateCardiacCentersDistance(from location: CLLocation) {
        DispatchQueue.main.async {
            self.cardiacCenters = self.cardiacCenters.map { center in
                var updatedCenter = center
                let centerLocation = CLLocation(latitude: center.coordinate.latitude,
                                              longitude: center.coordinate.longitude)
                updatedCenter.distance = location.distance(from: centerLocation)
                return updatedCenter
            }.sorted { $0.distance ?? 0 < $1.distance ?? 0 }
        }
    }
}

struct CardiacCenterMapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = CardiacCenterViewModel()
    @State private var selectedCenter: CardiacCenter?
    @State private var showingDetail = false
    @State private var showingLocationError = false
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: viewModel.cardiacCenters) { center in
                MapAnnotation(coordinate: center.coordinate) {
                    Button(action: {
                        selectedCenter = center
                        showingDetail = true
                    }) {
                        VStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                            
                            Text(center.name)
                                .font(.caption)
                                .foregroundColor(.black)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            if showingDetail, let center = selectedCenter {
                VStack {
                    Spacer()
                    CardiacCenterDetailView(center: center)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .navigationTitle("Nearby Cardiac Centers")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation {
                viewModel.updateRegion(with: location)
                viewModel.updateCardiacCentersDistance(from: location)
            }
        }
        .onChange(of: locationManager.lastError) { error in
            if error != nil {
                showingLocationError = true
            }
        }
        .alert("Location Error", isPresented: $showingLocationError) {
            Button("OK", role: .cancel) { }
            if let _ = locationManager.lastError {
                Button("Open Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            }
        } message: {
            Text(locationManager.lastError ?? "Unable to access location")
        }
    }
} 