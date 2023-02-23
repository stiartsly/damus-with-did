
import SwiftUI
import ElastosDIDSDK

class modle: Identifiable {
    var name: String = ""
    var didString: String = ""
    var icon: String = ""

    init(name: String, didString: String, icon: String) {
        self.name = name
        self.didString = didString
        self.icon = icon
    }
}

struct ListDidsView: View {
    @State var modles = [modle.init(name: "123q", didString: "elastos:did:aiaakkkkkkkkaa", icon: "")]
    
    var body: some View {
        DamusGradient()
        NavigationView {
            List (modles) { item in
                NavigationLink(destination: DidsCell(name: item.name, didString: item.didString, icon: item.icon)) {
                }
            }
        }
    }
}

struct DidsCell: View {
    @State var name: String = ""
    @State var didString: String = ""
    @State var icon: String = ""

    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 12) {
                Image("undercover") // icon

                VStack{
                    Text("Name: \(self.name)")
                        .foregroundColor(.white)
                        .padding().onAppear {
                        }
                    
                    Text("DID: \(self.didString)")
                        .foregroundColor(.white)
                        .padding().onAppear {
                        }
                }

            }
        }
    }
    
    
}
