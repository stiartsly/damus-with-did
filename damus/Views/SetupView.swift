//
//  SetupView.swift
//  damus
//
//  Created by William Casarin on 2022-05-18.
//

import SwiftUI
import CodeScanner
import Kingfisher

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
    let damusIdentity = DamusIdentity.shared()
    @State private var isAnimating: Bool = true

    //新增
    @State private var pk: String = ""
    @State private var sk: String = ""
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            
            self.state = .login
            
            print("result.string = \(result.string)")
            self.scanresult = result.string
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                DamusGradient()
                
                POPRootView(isShowingPOPA: isShowing, isShowingPOPB: isShowingB, isShowingPOPC: isShowingC) {
                    
                    ZStack() {
                        
                        VStack(alignment: .center) {
//                            NavigationLink(destination: EULAView(state: state), tag: .create_account, selection: $state ) {
//                                EmptyView()
//                            }
                            
                            NavigationLink(destination: LoginView(mnemonic: scanresult), tag: .login, selection: $state ) {
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
                                self.selectedIndex = 0
                            }.frame(width: 44, height: 44).padding(12)
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
                    
                    VStack(spacing: 30) {
                        Spacer()

                        HStack {
                            Spacer()
                            Button("关闭") {
                                self.isShowing = false
                            }.frame(width: 44, height: 44).padding(12)
                                .cornerRadius(22)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 22).stroke(.clear, lineWidth: 1)
                                }
                        }.frame(height: 44)
                        
                        HStack {
                            TextField("输入名称", text: $textfieldText).frame(height: 50).background(.white).cornerRadius(8)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8).stroke(.white, lineWidth: 1)
                                }
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
                        Spacer().frame(height: 44)

                    }.frame(width: 350, height: 280)
                        .background(Color(hex: "161C24"))// 161C24  background(.white)
                        .cornerRadius(20)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20).stroke(.blue, lineWidth: 1)
                        }
                                        
                } POPCContent: {
                    
                    VStack (alignment: .center) {
                        HStack {
                            Spacer()
                            Button("关闭") {
                                self.isShowingC = false
                            }.frame(width: 44, height: 30).padding(12)
                                .cornerRadius(20)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20).stroke(.clear, lineWidth: 1)
                                }
                        }.frame(height: 30)
                        Spacer().frame(height: 5)
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("创建身份").font(.system(size: 18)).padding(.leading,12)
                                Text("向您的设备添加新身份").font(.system(size: 15)).padding(.leading,12)
                            }
                            Spacer()

                            Image("ic-tick")
                                .resizable()
                                .frame(width: 20, height: 20, alignment: .trailing)
                                .padding(30)
                        }.frame(width:300, height: 80)
                            .background(.white)
                            .cornerRadius(20)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 1).shadow(radius: 0.25).opacity(0.5)
                            }
                        
                        Spacer().frame(height:10)
                        Image(systemName: "arrow.down")
                        Spacer().frame(height:10)
                        HStack  {
                            VStack (alignment: .leading, spacing: 5){
                                Text("发布身份").font(.system(size: 18)).padding(.leading,12)
                                Text("将身份记录到公开仓库上，此步骤大约15秒").font(.system(size: 15)).padding(.leading,12)
                            }
                            Spacer()
//                            Image(systemName: "circle").padding(12)
                            ActivityIndicator(isAnimating: $isAnimating, style: .medium).padding(30)
                            if isAnimating == false {
                                Image("ic-tick")
                                    .resizable()
                                    .frame(width: 20, height: 20, alignment: .trailing)
                                    .padding(30)
//                                notify(.login, ())

//                                let path = Bundle.main.url(forResource: "sucess", withExtension: "gif")!
//                                KFAnimatedImage(source:
//                                        .provider(LocalFileImageDataProvider(fileURL: path))
//                                ).frame(width: 20, height: 20, alignment: .trailing).background(.red).padding(30)
                            }
                            
                        }.frame(width:300, height: 100).cornerRadius(20)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 1).shadow(radius: 0.25).opacity(0.5)
                            }.background(.white)
                        Spacer().frame(height:44)

                    }.frame(width: 350, height: 320).background(.white).cornerRadius(20)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 1)
                    }
                    .onAppear {
                        isAnimating = true
                        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1), execute: {
                            do {
//                                try damusIdentity.createNewDid(name: textfieldText)
                                isAnimating = false
                            }
                            catch {
                                isAnimating = false
                                print("createNewDid error: \(error)")
                            }
                        })

                       }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: Context) -> UIActivityIndicatorView  {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.color = .purple
        return indicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
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

func DamusWhiteButton(_ title: String, _ bdisabled: Bool = false, action: @escaping () -> ()) -> some View {
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
    }.disabled(bdisabled)
    
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
