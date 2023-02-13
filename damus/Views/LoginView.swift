//
//  LoginView.swift
//  damus
//
//  Created by William Casarin on 2022-05-22.
//

import SwiftUI
import ElastosDIDSDK

enum ParsedKey {
    case pub(String)
    case priv(String)
    case hex(String)
    case nip05(String)

    var is_pub: Bool {
        if case .pub = self {
            return true
        }

        if case .nip05 = self {
            return true
        }
        return false
    }

    var is_hex: Bool {
        if case .hex = self {
            return true
        }
        return false
    }
}

enum LogInStatus {
    case unKnow
    case notNetWork
    case retry
    case login
    
    var title: String {
        switch self {
        case .unKnow:
            return NSLocalizedString("正在解析助记词", comment: "")
        case .notNetWork:
            return NSLocalizedString("Login", comment: "Button to log into account.")
        case .retry:
            return NSLocalizedString("登录中，请稍后", comment: "正在解析助记词")
        case .login:
            return NSLocalizedString("开始使用", comment: "进入首页")
        }
    }
    
    var disabled: Bool {
        switch self {
        case .unKnow:
            return true
        case .notNetWork:
            return false
        case .retry:
            return true
        case .login:
            return false
        }
    }
}

struct LoginView: View {
    @State var key: String = ""
    @State var is_pubkey: Bool = false
    @State var error: String? = nil
    @State var mnemonic: String = ""
    @State var publicKey: String = ""
    @State var privateKey: String = ""
    @State public var didString: String = ""
    @State private var logInStatus: LogInStatus = .login
    @State var buttonTitle: String = ""

    func get_error(parsed_key: ParsedKey?) -> String? {
        if self.error != nil {
            return self.error
        }

        if !key.isEmpty && parsed_key == nil {
            return "Invalid key"
        }

        return nil
    }

    func process_login(_ key: ParsedKey, is_pubkey: Bool) -> Bool {
        switch key {
        case .priv(let priv):
            do {
                try save_privkey(privkey: priv)
            } catch {
                return false
            }
            
            guard let pk = privkey_to_pubkey(privkey: priv) else {
                return false
            }
            save_pubkey(pubkey: pk)

        case .pub(let pub):
            do {
                try clear_saved_privkey()
            } catch {
                return false
            }
            
            save_pubkey(pubkey: pub)

        case .nip05(let id):
            Task.init {
                guard let nip05 = await get_nip05_pubkey(id: id) else {
                    self.error = "Could not fetch pubkey"
                    return
                }

                for relay in nip05.relays {
                    if !(BOOTSTRAP_RELAYS.contains { $0 == relay }) {
                        BOOTSTRAP_RELAYS.append(relay)
                    }
                }
                save_pubkey(pubkey: nip05.pubkey)

                notify(.login, ())
            }


        case .hex(let hexstr):
            if is_pubkey {
                do {
                    try clear_saved_privkey()
                } catch {
                    return false
                }
                
                save_pubkey(pubkey: hexstr)
            } else {
                do {
                    try save_privkey(privkey: hexstr)
                } catch {
                    return false
                }
                
                guard let pk = privkey_to_pubkey(privkey: hexstr) else {
                    return false
                }
                save_pubkey(pubkey: pk)
            }
        }
        
        notify(.login, ())
        return true
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            DamusGradient()
            VStack(alignment: .leading) {
                Text("Login", comment: "Title of view to log into an account.")
                    .foregroundColor(.white)
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity,alignment: .center)
                
                //                Text("Enter your account key to login:", comment: "Prompt for user to enter an account key to login.")
                //                    .foregroundColor(.white)
                //                    .padding()
                
                
                //                Text("\(self.scanResult)")
                //                    .foregroundColor(.white)
                //                    .padding()
                
                //                Text("Public Key: \(self.publicKey)")
                //                    .foregroundColor(.white)
                //                    .padding()
                //
                //                Text("Private Key: \(self.privateKey)")
                //                    .foregroundColor(.white)
                //                    .padding()
                //
                Text("DID: \(self.didString)")
                    .foregroundColor(.white)
                    .padding().onAppear {
                        parsedDID()
                    }
                
                DamusWhiteButton(self.buttonTitle, self.logInStatus.disabled, action: {
                    print("DODO1 登录 mnemonic = \(mnemonic)")
                    checkLogin()
                }).frame(maxWidth: .infinity,alignment: .center).buttonStyle(.plain)
                
                //                KeyInput(NSLocalizedString("nsec1...", comment: "Prompt for user to enter in an account key to login. This text shows the characters the key could start with if it was a private key."), key: $scanResult)
                
                //                let parsed = parse_key(key)
                //
                //                if parsed?.is_hex ?? false {
                //                    Text("This is an old-style nostr key. We're not sure if it's a pubkey or private key. Please toggle the button below if this a public key.", comment: "Warning that the inputted account key for login is an old-style and asking user to verify if it is a public key.")
                //                        .font(.subheadline.bold())
                //                        .foregroundColor(.white)
                //                    PubkeySwitch(isOn: $is_pubkey)
                //                        .padding()
                //                }
                //
                //                if let error = get_error(parsed_key: parsed) {
                //                    Text(error)
                //                        .foregroundColor(.red)
                //                        .padding()
                //                }
                //
                //                if parsed?.is_pub ?? false {
                //                    Text("This is a public key, you will not be able to make posts or interact in any way. This is used for viewing accounts from their perspective.", comment: "Warning that the inputted account key is a public key and the result of what happens because of it.")
                //                        .foregroundColor(.white)
                //                        .padding()
                //                }
                //
                //                if let p = parsed {
                //                    DamusWhiteButton(NSLocalizedString("Login", comment: "Button to log into account.")) {
                //                        if !process_login(p, is_pubkey: self.is_pubkey) {
                //                            self.error = NSLocalizedString("Invalid key", comment: "Error message indicating that an invalid account key was entered for login.")
                //                        }
                //                    }
                //                }
                
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackNav())
    }
    
    func parsedDID() {
        _ = checkLoginStatus()
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1), execute: {
            print("Thread = ", Thread.current)
            self.logInStatus = .retry
            self.buttonTitle = logInStatus.title
            let di = DamusIdentity.shared()
            didString = di.handleDidPkSk(mnemonic: mnemonic)
            _ = checkLoginStatus()
        })
    }
    
    func checkLoginStatus() -> LogInStatus {
        let contains = "did:elastos:"
        if self.didString == "" {
            self.logInStatus = .unKnow
            self.buttonTitle = self.logInStatus.title
        }
       else if self.didString.contains(notNetWorkError) {
            self.logInStatus = .notNetWork
            self.buttonTitle = self.logInStatus.title
        }
        else if self.didString.contains(contains) {
            self.logInStatus = .login
            self.buttonTitle = self.logInStatus.title
        }
        
        return logInStatus
    }
    
    func checkLogin() {
        if (checkLoginStatus() == .login) {
            login()
            return
        }

        parsedDID()
        self.logInStatus = .retry
        self.buttonTitle = logInStatus.title
        self.didString = "正在解析中"
        print("DODO2 登录 mnemonic = \(mnemonic)")
    }
    
    func login() {
        let di = DamusIdentity.shared()
        _ = di.save_did()
        notify(.login, ())
    }
}


struct PubkeySwitch: View {
    @Binding var isOn: Bool
    var body: some View {
        HStack {
            Toggle(isOn: $isOn) {
                Text("Public Key?", comment: "Prompt to ask user if the key they entered is a public key.")
                    .foregroundColor(.white)
            }
        }
    }
}

func parse_key(_ thekey: String) -> ParsedKey? {
    var key = thekey
    if key.count > 0 && key.first! == "@" {
        key = String(key.dropFirst())
    }

    if hex_decode(key) != nil {
        return .hex(key)
    }

    if (key.contains { $0 == "@" }) {
        return .nip05(key)
    }

    if let bech_key = decode_bech32_key(key) {
        switch bech_key {
        case .pub(let pk):
            return .pub(pk)
        case .sec(let sec):
            return .priv(sec)
        }
    }

    return nil
}

struct NIP05Result: Decodable {
    let names: Dictionary<String, String>
    let relays: Dictionary<String, [String]>?
}

struct NIP05User {
    let pubkey: String
    let relays: [String]
}

func get_nip05_pubkey(id: String) async -> NIP05User? {
    let parts = id.components(separatedBy: "@")

    guard parts.count == 2 else {
        return nil
    }

    let user = parts[0]
    let host = parts[1]

    guard let url = URL(string: "https://\(host)/.well-known/nostr.json?name=\(user)") else {
        return nil
    }

    guard let (data, _) = try? await URLSession.shared.data(for: URLRequest(url: url)) else {
        return nil
    }

    guard let json: NIP05Result = decode_data(data) else {
        return nil
    }

    guard let pubkey = json.names[user] else {
        return nil
    }

    var relays: [String] = []
    if let rs = json.relays {
        if let rs = rs[pubkey] {
            relays = rs
        }
    }

    return NIP05User(pubkey: pubkey, relays: relays)
}

struct KeyInput: View {
    let title: String
    let key: Binding<String>

    init(_ title: String, key: Binding<String>) {
        self.title = title
        self.key = key
    }

    var body: some View {
        TextField("", text: key)
            .placeholder(when: key.wrappedValue.isEmpty) {
                Text(title).foregroundColor(.white.opacity(0.6))
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 4.0).opacity(0.2)
            }
            .autocapitalization(.none)
            .foregroundColor(.white)
            .font(.body.monospaced())
            .textContentType(.password)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let pubkey = "3efdaebb1d8923ebd99c9e7ace3b4194ab45512e2be79c1b7d68d9243e0d2681"
        let bech32_pubkey = "KeyInput"
        Group {
            LoginView(key: pubkey)
            LoginView(key: bech32_pubkey)
        }
    }
}
