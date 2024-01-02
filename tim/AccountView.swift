import SwiftUI

struct AccountView: View {
    var body: some View {
        VStack {
            NavigationView {
                List {
                    NavigationLink(destination: YourAccountView()) {
                        Label("Your Account", systemImage: "gear")
                    }
                    NavigationLink(destination: MyPlansView()) {
                        Label("Manage Plans", systemImage: "person.fill")
                    }
                    NavigationLink(destination: VerView()) {
                        Label("Request Plan Verification", systemImage: "heart.circle.fill")
                    }
                 
                   
                }
                .navigationBarTitle("Account Settings")
            }
            Spacer()
        }
    }
}

struct YourAccountView: View {
    var body: some View {
        Text("Your Account Details")
            .navigationBarTitle("Your Account")
    }
}

struct MyPlansView: View {
    var body: some View {
        Text("Manage Plans")
            .navigationBarTitle("Manage Plans")
    }
}

struct VerView: View {
    var body: some View {
        Text("Request Plan Verification")
            .navigationBarTitle("Request Plan Verification")
    }
}




struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}


