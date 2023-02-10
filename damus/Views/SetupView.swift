//
//  SetupView.swift
//  damus
//
//  Created by William Casarin on 2022-05-18.
//

import SwiftUI
import CodeScanner
import ElastosDIDSDK

extension String {
    
    /*
     * example: /foo/bar/example.txt
     * dirNamePart() -> "/foo/bar/"
     */
    func dirname() -> String {
        let index = self.range(of: "/", options: .backwards)?.lowerBound
        let str = index.map(self.prefix(upTo:)) ?? ""
        return "\(str)/"
    }
    
    func toDictionary() -> [String : Any] {
        
        var result = [String : Any]()
        guard !self.isEmpty else { return result }
        
        guard let dataSelf = self.data(using: .utf8) else {
            return result
        }
        
        if let dic = try? JSONSerialization.jsonObject(with: dataSelf,
                           options: []) as? [String : Any] {
            result = dic ?? [: ]
        }
        return result
    }
}
func hex_col(r: UInt8, g: UInt8, b: UInt8) -> Color {
    return Color(.sRGB,
                 red: Double(r) / Double(0xff),
                 green: Double(g) / Double(0xff),
                 blue: Double(b) / Double(0xff),
                 opacity: 1.0)
}

let damus_grad_c1 = hex_col(r: 0x1c, g: 0x55, b: 0xff)
let damus_grad_c2 = hex_col(r: 0x7f, g: 0x35, b: 0xab)
let damus_grad_c3 = hex_col(r: 0xff, g: 0x0b, b: 0xd6)
let damus_grad = [damus_grad_c1, damus_grad_c2, damus_grad_c3]

enum SetupState {
    case home
    case create_account
    case login
}

struct DamusGradient: View {
    var body: some View {
        LinearGradient(colors: damus_grad, startPoint: .bottomLeading, endPoint: .topTrailing)
            .edgesIgnoringSafeArea([.top,.bottom])
    }
}

struct SetupView: View {
    @State var state: SetupState? = .home
    @State private var isShowingScanner = false
    @State var scanresult: String = ""
    @State private var isShowingCarousel = false
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @State private var isShowing: Bool = Bool()
    @State private var isShowingB: Bool = Bool()
    @State private var isShowingC: Bool = Bool()
    @State private var textfieldText: String = ""

    @State private var selectedIndex: Int = 0
    
    //新增
    @State private var userDIDStorePass: String = ""
    @State private var rootIdentity: RootIdentity?
    @State private var pk: String = ""
    @State private var sk: String = ""
    @State private var didString: String = ""

    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            
            self.state = .login
            
            print("result.string = \(result.string)")
            self.scanresult = result.string
            self.handleDidPkSk(mnemonic: result.string)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func handleDidPkSk(mnemonic: String) {
        do {
            let root: String = "\(NSHomeDirectory())/Library/Caches/DumausDIDStore"
            
            let didStore = try DIDStore.open(atPath: root)
            print("root = \(root)")
            
            let currentNet = "mainnet"
            if (!DIDBackend.isInitialized()) {
                try DIDBackend.initialize(DefaultDIDAdapter(currentNet))
            }
            print("DIDBackend.initialize")
            
            // Generate a random password
            self.userDIDStorePass = ""
            if try !(didStore.containsRootIdentities()) {
                self.rootIdentity = try RootIdentity.create(mnemonic, false, didStore, self.userDIDStorePass)
            }
            print("rootIdentity = \(self.rootIdentity)")
            let dids = try didStore.listDids()
            
            if dids.count > 0 {
                self.didString = dids[0].description
            }
//            let id = try didStore.loadRootIdentity()!.getId()
//
//            let root1: String = "\(NSHomeDirectory())/Library/Caches/DamusKeys"
//            let tempDir: String = "\(root1)/tempDir"
//            let exportFile = tempDir + "/idexport.json"
//            self.deleteFile(exportFile)
//            try create(exportFile, forWrite: true)
//            let fileHndle: FileHandle = FileHandle(forWritingAtPath: exportFile)!
//
//            try didStore.exportRootIdentity(id, to: fileHndle, using: "", storePassword: userDIDStorePass)
//            let readerHndle = FileHandle(forReadingAtPath: exportFile)
//            let data = try readerHndle?.readDataToEndOfFile()
//            let stringData = String(data: data!, encoding: .utf8)
//            print("stringData = \(stringData)")
            
//            let m = "jayuhyO2FLd5w8nO0Phk2OiJpQmA2y0_ZGzFvvMj2kbMth54sOR1iSBRrEac8pGf"
//            let p = "xpub6CmeARucy5ZRTYtWbQTvfbMWZNDsVQSYeyBe8d6b7vRzGZ8gPr1yPXSbwWtrDrvwx4WGNUycEBz91PXfJhYLZsZbvuFENinKcsK9yCwUJLZ"
//            let s = "75NZt_rxw19YvXR7GWACh9f_k24u3rh6gQNcQrQ_wzsP7qMcFP2GTjpHMI7LAd9FpCq3bWIAHQbqGcCqchUjSmnbUqEUSvlY4ETPDWpKugWeHIqWDG5z965j8LfhqK9x"
            
//            let dic = String(data: data!, encoding: .utf8)?.toDictionary()
//            let re = try RootIdentityExport.deserialize(dic!)
//            let p = re.publicKey
//            print("p = \(p)")
//            
//            let s = try re.getPrivateKey("", "")
//            print("s = \(s)")
            
        } catch {
            print("carsh : \(error)")
        }
    }
    
    func create(_ path: String, forWrite: Bool) throws {
        if !FileManager.default.fileExists(atPath: path) && forWrite {
            let dirPath: String = path.dirname()
            let fileM = FileManager.default
            let re = fileM.fileExists(atPath: dirPath)
            print("dirPath = \(dirPath)")
            print("path = \(path)")

            if !re {
                try fileM.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            }
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
    }
    
    func deleteFile(_ path: String) {
         do {
             let filemanager: FileManager = FileManager.default
             var isdir = ObjCBool.init(false)
             let fileExists = filemanager.fileExists(atPath: path, isDirectory: &isdir)
             if fileExists && isdir.boolValue {
                 if let dircontents = filemanager.enumerator(atPath: path) {
                     for case let url as URL in dircontents {
                         deleteFile(url.absoluteString)
                     }
                 }
             }
             guard fileExists else {
                 return
             }
             try filemanager.removeItem(atPath: path)
         } catch {
             print("deleteFile error: \(error)")
         }
     }
    
    var body: some View {
        NavigationView {
            ZStack {
                DamusGradient()
                
                POPRootView(isShowingPOPA: isShowing, isShowingPOPB: isShowingB, isShowingPOPC: isShowingC) {
                    
                    ZStack() {
                        
                        VStack(alignment: .center) {
                            NavigationLink(destination: EULAView(state: state), tag: .create_account, selection: $state ) {
                                EmptyView()
                            }
                            
                            NavigationLink(destination: LoginView(scanResult: scanresult, publicKey: pk, privateKey: sk, did: didString), tag: .login, selection: $state ) {
                                EmptyView()
                            }
                            
                            Image("Feeds-logo-signin")
                                .resizable()
                                .frame(width: 200, height: 133.3, alignment: .center)
                                .padding([.top], 80.0)
                            
                            Text("Web3 社交网络").foregroundColor(.white).bold().font(.system(size: 25)).padding(EdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0))
                            
                            
                            
                            
                            Spacer()
                            
                            VStack(spacing: 1) {
                                Text("登录").foregroundColor(.white).bold().font(.system(size: 25)).padding(EdgeInsets(top: 17, leading: 0, bottom: 0, trailing: 0))
                                Text("请选择应用登录方式").foregroundColor(.white).bold().font(.system(size: 15)).padding(EdgeInsets(top: 17, leading: 0, bottom: 0, trailing: 0))
                                Button("导入Elastos DID") {
                                    
                                    self.isShowingScanner = true
                                }.frame(width: 300, height: 44)
                                    .cornerRadius(22)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 22).stroke(.clear, lineWidth: 1)
                                    }.background(
                                        LinearGradient(gradient: Gradient(colors: [Color(hex:"7624FE"), Color(hex:"368BFF")]), startPoint: .leading, endPoint: .trailing).cornerRadius(22)
                                    ).foregroundColor(.white).padding(EdgeInsets(top: 17, leading: 0, bottom: 0, trailing: 0))
                                
                                Button("新人登录") {
                                    self.isShowing = true
                                }.frame(width: 300, height: 44)
                                    .cornerRadius(22)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 22).stroke(.clear, lineWidth: 1)
                                    }.background(
                                        LinearGradient(gradient: Gradient(colors: [Color(hex:"7624FE"), Color(hex:"368BFF")]), startPoint: .leading, endPoint: .trailing).cornerRadius(22)
                                    ).foregroundColor(.white).padding(EdgeInsets(top: 17, leading: 0, bottom: 0, trailing: 0))
                                
                                Button("了解更多") {
                                    self.isShowingCarousel = true
                                    
                                }.frame(width: 300, height: 44)
                                    .cornerRadius(22)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 22).stroke(.clear, lineWidth: 1)
                                    }.background(
                                        LinearGradient(gradient: Gradient(colors: [Color(hex:"7624FE"), Color(hex:"368BFF")]), startPoint: .leading, endPoint: .trailing).cornerRadius(22)
                                    ).foregroundColor(.white).padding(EdgeInsets(top: 17, leading: 0, bottom: 0, trailing: 0))
                                
                                
                                HStack(spacing: 0) {
                                    Text("登录表明你同意我们的").font(.system(size: 10)).foregroundColor(.white)
                                    Button("条款") {
                                        
                                    }.font(.system(size: 10)).foregroundColor(.blue)
                                    Text("、").font(.system(size: 10)).foregroundColor(.white)
                                    Button("隐私政策") {
                                        
                                    }.font(.system(size: 10)).foregroundColor(.blue)
                                }.padding(EdgeInsets(top: 17, leading: 0, bottom: 0, trailing: 0))
                                
                                Spacer()
                                
                            }.frame(width: UIScreen.main.bounds.size.width, height: 400)
                                .background(Color(hex: "161C24"))
                                .cornerRadius(20)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20).stroke(.blue, lineWidth: 1)
                                }
                            
                        }
                        
                        VStack {
                            Spacer()
                            ZStack {
                                CarouselView().frame(height: 450).background(Color(hex: "161C24")).padding(EdgeInsets(top: 0, leading: 0, bottom: safeAreaInsets.bottom + 50, trailing: 0))
                                
                                VStack {
                                    Spacer()
                                    Button("隐私政策") {
                                        self.isShowingCarousel = false
                                    }.font(.system(size: 20)).foregroundColor(.white).frame(height: 50)
                                }.padding(EdgeInsets(top: 0, leading: 0, bottom: safeAreaInsets.bottom, trailing: 0))
                                
                            }.frame(height: 500)
                        }.opacity(self.isShowingCarousel ? 1 : 0)
                        
                        
                        
                    }.sheet(isPresented: $isShowingScanner) {
                        CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
                    }.edgesIgnoringSafeArea(.bottom)
                    
                } POPAContent: {
                    
                    VStack {

                        HStack {
                            Spacer()
                            Button("关闭") {
                                self.isShowing = false
                            }.frame(width: 44, height: 44)
                                .cornerRadius(22)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 22).stroke(.clear, lineWidth: 1)
                                }
                        }.frame(height: 44)

                        CarouselNewView(selectedIndex: $selectedIndex)
                            .frame(width: 350, height: 450).allowsHitTesting(false)
                        Button("下一个") {
                            if (self.selectedIndex == 2) {
                                self.selectedIndex = 0
                                self.isShowing = false
                                self.isShowingB = true
                            } else {
                                self.selectedIndex = self.selectedIndex + 1

                            }
                            print("\(self.selectedIndex)")
                        }.frame(width: 300, height: 44)
                            .cornerRadius(22)
                            .overlay {
                                RoundedRectangle(cornerRadius: 22).stroke(.clear, lineWidth: 1)
                            }.background(
                                LinearGradient(gradient: Gradient(colors: [Color(hex:"7624FE"), Color(hex:"368BFF")]), startPoint: .leading, endPoint: .trailing).cornerRadius(22)
                            ).foregroundColor(.white)
                        
                    }.frame(width: 350, height: 550 + 44)
                        .background(Color(hex: "161C24"))// 161C24  background(.white)
                        .cornerRadius(20)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20).stroke(.blue, lineWidth: 1)
                        }
                    
                } POPBContent: {
                    
                    VStack {

                        HStack {
                            Spacer()
                            Button("关闭") {
                                self.isShowing = false
                            }.frame(width: 44, height: 44)
                                .cornerRadius(22)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 22).stroke(.clear, lineWidth: 1)
                                }
                        }.frame(height: 44)
                        
                        HStack {
                            TextField("输入名称", text: $textfieldText).frame(height: 50).background(.white)
                        }.padding(20)
                        Button("下一个") {
                            self.isShowingB = false
                            self.isShowingC = true
                        }.frame(width: 300, height: 44)
                            .cornerRadius(22)
                            .overlay {
                                RoundedRectangle(cornerRadius: 22).stroke(.clear, lineWidth: 1)
                            }.background(
                                LinearGradient(gradient: Gradient(colors: [Color(hex:"7624FE"), Color(hex:"368BFF")]), startPoint: .leading, endPoint: .trailing).cornerRadius(22)
                            ).foregroundColor(.white)
                        
                    }.frame(width: 350, height: 300)
                        .background(Color(hex: "161C24"))// 161C24  background(.white)
                        .cornerRadius(20)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20).stroke(.blue, lineWidth: 1)
                        }
                    
                    
                    
                } POPCContent: {
                    

                    
                    VStack {
                        HStack {
                            Spacer()
                            Button("关闭") {
                                self.isShowingC = false
                            }.frame(width: 44, height: 44)
                                .cornerRadius(22)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 22).stroke(.clear, lineWidth: 1)
                                }
                        }.frame(height: 44)
                        HStack {
                            VStack {
                                Text("22222").font(.system(size: 25))
                                Text("33333").font(.system(size: 15))
                            }.frame(width: 150)
                            Image(systemName: "touchid")
                        }.padding(10).cornerRadius(22)
                            .overlay {
                                RoundedRectangle(cornerRadius: 22).stroke(.clear, lineWidth: 1)
                            }.background(.red)
                        Image(systemName: "touchid").padding(10)
                        HStack {
                            VStack {
                                Text("22222").font(.system(size: 25))
                                Text("33333").font(.system(size: 15))
                            }.frame(width: 400)
                            Image(systemName: "touchid")
                        }.padding(10).cornerRadius(22)
                            .overlay {
                                RoundedRectangle(cornerRadius: 22).stroke(.clear, lineWidth: 1)
                            }.background(.red)
                        Image(systemName: "touchid").padding(10)
                        HStack {
                            VStack {
                                Text("22222").font(.system(size: 25))
                                Text("33333").font(.system(size: 15))
                            }.frame(width: 150)
                            Image(systemName: "touchid")
                        }.padding(10).cornerRadius(22)
                            .overlay {
                                RoundedRectangle(cornerRadius: 22).stroke(.clear, lineWidth: 1)
                            }.background(.red)

                    }.frame(width: 400, height: 500).background(.white)
                }

            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}



private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }
}

extension EnvironmentValues {
    
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

func DamusWhiteButton(_ title: String, action: @escaping () -> ()) -> some View {
    return Button(action: action) {
        Text(title)
            .frame(width: 300, height: 50)
            .font(.body.bold())
            .contentShape(Rectangle())
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 4.0)
                    .stroke(Color.white, lineWidth: 2.0)
                    .background(Color.white.opacity(0.15))
            )
    }
    
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SetupView()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
            SetupView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
        }
    }
}

struct POPRootView<Content: View, contentA: View, contentB: View, contentC: View>: View {
    
    let isShowingPOPA: Bool
    let isShowingPOPB: Bool
    let isShowingPOPC: Bool

    @ViewBuilder let content: () -> Content
    @ViewBuilder let POPAContent: () -> contentA
    @ViewBuilder let POPBContent: () -> contentB
    @ViewBuilder let POPCContent: () -> contentC

    var body: some View {
        
        Group {
            
            if isShowingPOPA {
                ZStack { content().blur(radius: isShowingPOPA ? 5.0 : 0.0); POPAContent() }
            }
            else if isShowingPOPB {
                ZStack { content().blur(radius: isShowingPOPB ? 5.0 : 0.0); POPBContent() }
            }
            else if isShowingPOPC {
                ZStack { content().blur(radius: isShowingPOPC ? 5.0 : 0.0); POPCContent() }
            }
            else { content() }
            
        }
        .animation(.default, value: isShowingPOPA)
        
    }
}
