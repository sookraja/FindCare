import SwiftUI

struct IndoorMapView: View {
    @State private var selectedFloor = 1
    let floorImages = ["Level-1", "Level-2", "Level-3"]
    
    // Add states for the dot positions
    @State private var startPoint = CGPoint(x: 100, y: 150)
    @State private var endPoint = CGPoint(x: 300, y: 250)

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
                    ZStack {
                        // Floor map image
                        Image(floorImages[selectedFloor - 1])
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                        
                        // Path between the dots
                        Path { path in
                            path.move(to: startPoint)
                            path.addLine(to: endPoint)
                        }
                        .stroke(Color.blue, lineWidth: 3)
                        
                        // First dot
                        Circle()
                            .fill(Color.red)
                            .frame(width: 20, height: 20)
                            .position(startPoint)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        startPoint = value.location
                                    }
                            )
                        
                        // Second dot
                        Circle()
                            .fill(Color.red)
                            .frame(width: 20, height: 20)
                            .position(endPoint)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        endPoint = value.location
                                    }
                            )
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .background(Color.blue)
    }
}


