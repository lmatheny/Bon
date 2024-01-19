//
//  CreatorSettingsView.swift
//  tim
//
//  Created by Luke Matheny on 1/16/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ImageLoader2: ObservableObject {
    @Published var image: Image?
    @Published var result: String?

    
    func downloadImage(storagePath: String) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: storagePath)

        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                self.image = Image("defBanner")
                self.result = "none"
            } else if let data = data, let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
        }
    }
}




struct CreatorSettingsView: View {
    let unique: String
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false
    @StateObject private var imageLoader = ImageLoader2()
    //@State private var bannerStoragePath = "lucaPlan1"
    @State private var foundBanner = false
    
    var body: some View {
        VStack {
            Text("Comumunity Settings")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .bold()
            
            
           // Text(unique)
            
            
            // Add plan thumbnail pic
            Button(action: {
               
                isImagePickerPresented.toggle()
              
            }) {
                ZStack {
                    
                    if(imageLoader.result == "none") {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill() // Use scaledToFill to maintain aspect ratio and fill the frame
                                .frame(height: 75) // Adjust the size as needed
                                .clipped() // Ensure the image doesn't exceed the frame boundaries
                            
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 75) // Adjust the size as needed
                                .overlay(
                                    Image(systemName: "plus")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                )
                        }
                    } else {
                        imageLoader.image?
                            .resizable()
                            .frame(height: 75).onAppear {
                                // Initial image download
                                imageLoader.downloadImage(storagePath: "gs://tfinal-a07fc.appspot.com/banners/\(unique).jpg")
                            } // Adjust the size as needed
                    }
                    
                }
                
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePickerView(selectedImage: $selectedImage, isImagePickerPresented: $isImagePickerPresented)
        
            }
          
            Text(selectedImage == nil ? "Add a Plan Banner" : "Change Banner").foregroundColor(.gray)
            Spacer()
            
        }.onAppear {
            // Initial image download
            imageLoader.downloadImage(storagePath: "gs://tfinal-a07fc.appspot.com/banners/\(unique).jpg")
        }
    }
}

struct CreatorSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CreatorSettingsView(unique: "test")
    }
}
