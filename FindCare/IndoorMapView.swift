import SwiftUI

struct IndoorMapView: View {
    @State private var selectedFloor = 1
    let floorImages = ["Level-1", "Level-2", "Level-3"]

    var body: some View {
        VStack {
            // Picker to select the floor
            Picker("Select Floor", selection: $selectedFloor) {
                ForEach(1..<floorImages.count + 1, id: \.self) { floor in
                    Text("Floor \(floor)").tag(floor)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // ScrollView to display the selected floor map image
            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical]) {
                    Image(floorImages[selectedFloor - 1])
                        .resizable()
                        .scaledToFill() // Ensures the image fills the screen, may crop the image
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped() // Clips any part of the image that goes beyond bounds
                }
            }
            .edgesIgnoringSafeArea(.all) // Makes sure the map goes all the way to the edges of the screen
        }
        .background(Color.blue) // Optional: Set background color to black or any color of your choice
    }
}


