import SwiftUI
import FirebaseStorage



struct planBanner: View {
    @State private var image: Image?
    
    let storagePath: String
   
    
    //search
    @State private var searchText = ""
    @State private var searchResults: [String] = []
    let yourArray = [String]()
    @State private var showCancelButton = false
    
    
    
    
    init(_ storagePath: String) {
        self.storagePath = storagePath
    }
    
    var body: some View {
        VStack {
            if let image = image {
                image
                    .resizable()
                    .frame(height: 72.5) // Adjust the size as needed
                   
                   
             
            } else {
            
             ProgressView() .frame(height: 72.5) // Adjust the size as needed
                    .onAppear {
                        downloadImage()
                    }
            }
        }
        
    }
    
    private func downloadImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: storagePath)
        
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
            } else if let data = data, let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
        }
    }
}




struct CommunityView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            
        
                planBanner("gs://tfinal-a07fc.appspot.com/planPic.png")
               
            
            VStack {
                
                Divider() // Add a separator at the top
                
                HStack() {
                    
                    
                    Text("Creator")
                        .font(selectedTab == 0 ? .title3.bold() : .subheadline)
                        .foregroundColor(selectedTab == 0 ? CustomColor.limeColor : .black)
                        .onTapGesture {
                            withAnimation {
                                selectedTab = 0
                            }
                        }
                        .padding(.leading)
                    
                    Spacer()
                    
                    Text("Community")
                        .font(selectedTab == 1 ? .title3.bold() : .subheadline)
                        .foregroundColor(selectedTab == 1 ? CustomColor.limeColor : .black)
                        .onTapGesture {
                            withAnimation {
                                selectedTab = 1
                            }
                        }
                        .padding(.trailing)
                    
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity) // Center the HStack horizontally
                
                Divider() // Add a separator at the bottom
                
                VStack {
                    
                    if selectedTab == 0 {
                        Text("Content for Creator")
                    } else {
                        Text("Content for Community")
                    }
                }.padding()
                
                Spacer() // Push the tabs to the top
            }
           
        }
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}


struct SpinnerView: View {
  var body: some View {
    ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: CustomColor.limeColor))
      .scaleEffect(3.0, anchor: .center) // Makes the spinner larger
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          // Simulates a delay in content loading
          // Perform transition to the next view here
        }
      }
  }
}
