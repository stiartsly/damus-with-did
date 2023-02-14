
import Foundation
import ElastosDIDSDK

struct defaultsKeys {
    static let currentUserDid = "CURRENT_USER_DID"
    static let currentUserPath = "CURRENT_USER_PATH"

}
let notApproveNetWork = "目前不允许数据连接。"
let notNetWorkError = "无法连接网络：请点击登录重试"

public class DamusIdentity {
    
    public var mnemonic: String = ""
    public var publicKey: String = ""
    public var rootIdentity: RootIdentity?
    public var didStore: DIDStore?

    public var didString: String = ""
    public var rootPath: String = ""
    private var defaultStorePass: String = "DUMASDIDPASSWORD"
    private static var instance: DamusIdentity?

    deinit {
        rootIdentity = nil
        didStore = nil
        DamusIdentity.instance = nil
    }
    
    public class func shared() -> DamusIdentity {
        if (instance == nil) {
            instance = DamusIdentity()
            let currentNet = "mainnet"
            if (!DIDBackend.isInitialized()) {
                do {
                    try DIDBackend.initialize(DefaultDIDAdapter("https://api.elastos.io/eid"))
                } catch {
                    print("error =\(error)")
                }
            }
            print("DIDBackend.initialize")
        }
        
        return instance!
    }
    
    func createDidStore() throws {
        let currentPath = Int.random(in: 0...1000)
        rootPath = "\(NSHomeDirectory())/Library/Caches/DumausDIDStore" + "\(currentPath)"
        didStore = try DIDStore.open(atPath: rootPath)
        print("rootPath = \(rootPath)")
    }
    
    public func createNewMnemonic(name: String) throws {
        mnemonic = try Mnemonic.generate(Mnemonic.DID_ENGLISH)
        rootIdentity = try RootIdentity.create(mnemonic, true, didStore!, defaultStorePass)
    }
    
    public func createNewDid(name: String) throws {
        try createNewMnemonic(name: name)
        var doc = try rootIdentity!.newDid(defaultStorePass)
        let db = try doc.editing()
        let js = ["name": name]
        let json = js.toJsonString() != nil ? js.toJsonString()! : ""
        print("createNewDid json === \(json)")
//        var json = "{\"name\":\"Foo Bar\"}"
        _ = try db.appendCredential(with: "#name", json: json, using: defaultStorePass)
        doc = try db.seal(using: defaultStorePass)
        try doc.publish(using: defaultStorePass)
        didString = doc.subject.description
        print("createNewDid didString === \(didString)")
    }
    
    public func createIdentity(mnemonic: String) throws {
        // Generate a random password
        if try !(didStore!.containsRootIdentities()) {
            self.rootIdentity = try RootIdentity.create(mnemonic, false, didStore!, defaultStorePass)
        }
        self.rootIdentity = try didStore!.loadRootIdentity()
        print("rootIdentity = \(self.rootIdentity)")
    }
    
    public func handleMnemonic(mnemonic: String) -> String {
        do {
//            let currentPath = Int.random(in: 0...1000)
//            rootPath = "\(NSHomeDirectory())/Library/Caches/DumausDIDStore" + "\(currentPath)"
//            let didStore = try DIDStore.open(atPath: rootPath)
//            print("rootPath = \(rootPath)")
//
//            // Generate a random password
//            if try !(didStore.containsRootIdentities()) {
//                self.rootIdentity = try RootIdentity.create(mnemonic, false, didStore, self.defaultStorePass)
//            }
//            self.rootIdentity = try didStore.loadRootIdentity()
//            print("rootIdentity = \(self.rootIdentity)")
//
            try createDidStore()
            try createIdentity(mnemonic: mnemonic)
            try didStore!.synchronize()
            let dids = try didStore!.listDids()
            print("dids = ", dids)
            
            //TODO: 默认只取第一个did // 其他的did暂时不支持
            if dids.count > 0 {
                self.didString = dids[0].description
            }
            return self.didString
            // TODO: 判断本地是否有此did存储
        } catch {
            print("carsh : \(error.localizedDescription)")
            if error.localizedDescription == notApproveNetWork {
                return notNetWorkError
            }
            return error.localizedDescription
        }
    }
    
    func save_did() -> Bool {
        let defaults = UserDefaults.standard
        print("loginView did = \(didString)")
        if didString == "" {
            return false
        }
        defaults.setValue(didString, forKey: defaultsKeys.currentUserDid)
        defaults.setValue(rootPath, forKey: defaultsKeys.currentUserPath)
        return true
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
}
