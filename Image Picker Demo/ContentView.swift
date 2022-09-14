//
//  ContentView.swift
//  Image Picker Demo
//
//  Created by kittawat phuangsombat on 2022/9/13.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct ContentView: View {
    
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    @State var retrivedImages = [UIImage]()
    
    var body: some View {
        VStack {
            
            if selectedImage != nil {
                Image(uiImage: selectedImage!)
                    .resizable()
                    .frame(width: 200, height: 200)
            }
            
            Button {
                
                //show image picket
                isPickerShowing = true
                
            } label: {
                Text("Select a Photo")
            }
            
            //Upload button
            if selectedImage != nil {
                Button {
                    // Upload the image
                    uploadPhoto()
                } label: {
                    Text("Upload photo")
                }
                
            }
            Divider()
            HStack {
                
                //Loop through the images and display them
                ForEach(retrivedImages, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 100)
                }
            }
            
        }
        .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
            // Image Picker
            ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
        }
        .onAppear {
            retrivePhotos()
        }
    }
    
    func uploadPhoto() {
        
        //make sure that the selected image property isn't nil
        guard selectedImage != nil else {
            return
        }
        
        //create storage reference
        let storageRef = Storage.storage().reference()
        
        //Turn our image into data
        let imageData = selectedImage!.jpegData(compressionQuality: 0.8)
        
        //check that we were able to convert it to data
        guard imageData != nil else {
            return
        }
        
        // Specify the file path and name
        let path = "images/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)
        
        
        //Upload that  data
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in
            
            //check for errors
            if error == nil && metadata != nil {
                
                //save a reference to the file in Firestore DB
                let db = Firestore.firestore()
                db.collection("images").document().setData(["url":path]) { error in
                    
                    //If there were no errors, display the new images
                    if error == nil {
                        
                        
                        DispatchQueue.main.async {
                            
                            // add the uploaded image to the list of images for display
                            self.retrivedImages.append(self.selectedImage!)
                        }
                    }
                    
                }
                
            }
            
        }
    }
    
    
    func retrivePhotos() {
        
        //get the data from the database
        let db = Firestore.firestore()
        
        db.collection("images").getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                var paths = [String]()
                
                //loop through all the return docs
                for doc in snapshot!.documents {
                    
                    //Extract the file path and add to array
                    paths.append(doc["url"] as! String)
                }
                
                //loop through each file path and fetch the data from storage
                for path in paths {
                    
                    //get a reference to storage
                    let storageRef = Storage.storage().reference()
                    
                    //specify the path
                    let fileRef = storageRef.child(path )
                    
                    //retrive the data for 5 megabit
                    fileRef.getData(maxSize: 5 * 1024 * 2024) { data, error in
                        
                        //check for errors
                        if error == nil && data != nil {
                            
                            //create a UIImage and put it into our array for display
                            if let image = UIImage(data: data!) {
                                
                                DispatchQueue.main.async {
                                    retrivedImages.append(image)
                                }
                                
                            }
                        }
                        
                    }
                } //end loop through pats
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
