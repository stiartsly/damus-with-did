//
//  SetupView.swift
//  damus
//
//  Created by William Casarin on 2022-05-18.
//

import SwiftUI
import CodeScanner

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

    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            print(result.string)
            self.scanresult = result.string
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DamusGradient()
                
                ZStack() {
                    
                    VStack(alignment: .center) {
                        NavigationLink(destination: EULAView(state: state), tag: .create_account, selection: $state ) {
                            EmptyView()
                        }
                        NavigationLink(destination: EULAView(state: state), tag: .login, selection: $state ) {
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
                                
                                self.isShowingCarousel = true
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

