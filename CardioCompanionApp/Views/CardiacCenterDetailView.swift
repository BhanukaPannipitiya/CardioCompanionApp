import SwiftUI
import MapKit

struct CardiacCenterDetailView: View {
    let center: CardiacCenter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(center.name)
                    .font(.headline)
                Spacer()
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(center.formattedRating)
                        .font(.subheadline)
                }
            }
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.gray)
                Text(center.address)
                    .font(.subheadline)
            }
            
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.gray)
                Text("Wait time: \(center.waitTime)")
                    .font(.subheadline)
            }
            
            if let distance = center.distance {
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.gray)
                    Text(String(format: "%.1f km away", distance / 1000))
                        .font(.subheadline)
                }
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    guard let url = URL(string: "tel://\(center.phoneNumber)") else { return }
                    UIApplication.shared.open(url)
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button(action: {
                    let destination = MKMapItem(placemark: MKPlacemark(coordinate: center.coordinate))
                    destination.name = center.name
                    destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                }) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Directions")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
} 