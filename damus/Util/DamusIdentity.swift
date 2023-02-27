
import Foundation
import ElastosDIDSDK

struct defaultsKeys {
    static let currentUserDid = "CURRENT_USER_DID"
    static let currentUserPath = "CURRENT_USER_PATH"

}
let notApproveNetWork = "目前不允许数据连接。"
let notNetWorkError = "无法连接网络：请点击登录重试"
private var did: String = ""

public class DamusIdentity {
    
    public var mnemonic: String = ""
    public var publicKey: String = ""
    public var rootIdentity: RootIdentity?
    public var didStore: DIDStore?
    public var document: DIDDocument?

    public var didString: String = ""
    private var dirPath: String = NSHomeDirectory()
    public var rootPath: String = ""
    private var path: String = ""

    public var defaultStorePass: String = "DUMASDIDPASSWORD"
    private static var instance: DamusIdentity?
    private var adapter: DaumsIDChainAdapter?

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
                    try DIDBackend.initialize(DaumsIDChainAdapter("https://api.elastos.io/eid"))
                } catch {
                    print("error =\(error)")
                }
            }
            print("DIDBackend.initialize")
        }
        
        return instance!
    }
    
    func exportMnemonic() -> String {
        do {
            let e = try rootIdentity!.exportMnemonic(defaultStorePass)
            print("exportMnemonic = \(e)")
            return e
        }
        catch {
            return ""
        }
    }
    
    func loadDIDDocumentFromDP(did: String, path: String) throws -> DIDDocument? {
        didStore = try DIDStore.open(atPath: path)
        document = try didStore?.loadDid(did)
        if document == nil {
            document = try DID(didString).resolve()
        }
        
        if rootIdentity == nil {
            self.rootIdentity = try didStore!.loadRootIdentity()
        }
        return document
    }

    func createDidStore() throws {
        let currentPath = Int.random(in: 0...1000)
        path = "/Library/Caches/DumausDIDStore" + "\(currentPath)"
        rootPath = dirPath + path

//        rootPath = "\(NSHomeDirectory()/Library/Caches/DumausDIDStore" + "\(currentPath)"
        didStore = try DIDStore.open(atPath: rootPath)
        print("rootPath = \(rootPath)")
    }
    
    func createNewMnemonic() throws {
        mnemonic = try Mnemonic.generate(Mnemonic.DID_ENGLISH)
        rootIdentity = try RootIdentity.create(mnemonic, true, didStore!, defaultStorePass)
    }
    
    public func createNewDid(name: String) throws {
        print("createNewDid 开始 name = \(name)")
        try createDidStore()
        print("createNewDid 创建 DidStore成功: \(name)")
        try createNewMnemonic()
        print("createNewDid Mnemonic 成功: \(mnemonic)")
        var doc = try rootIdentity!.newDid(defaultStorePass)
        did = doc.subject.description
        
        print("createNewDid newDid 成功: \(doc)")
        print("createNewDid rootPath = \(rootPath)")

        if !name.isEmpty {
            print("createNewDid name = \(name)")
            doc = try createNameCredential(doc, name: name)
            print("createNewDid 添加NameCredential 成功: \(name)")
        }
        try didStore!.storeDid(using: doc)
        try doc.publish(using: defaultStorePass)

        print("createNewDid publish doc 成功. ")
        didString = doc.subject.description
        print("createNewDid didString === \(didString)")
        document = doc
    }
    
    func createNameCredential(_ didDocument: DIDDocument, name: String) throws -> DIDDocument {
        var doc = didDocument
        let db = try doc.editing()
        let js = ["name": name]
        let json = js.toJsonString() != nil ? js.toJsonString()! : ""
        print("createNewDid json === \(json)")
//        var json = "{\"name\":\"Foo Bar\"}"
        _ = try db.appendCredential(with: "#name", json: json, using: defaultStorePass)
        doc = try db.seal(using: defaultStorePass)
        
        return doc
    }
    
    func createIdentity(mnemonic: String) throws {
        // Generate a random password
        if try !(didStore!.containsRootIdentities()) {
            self.rootIdentity = try RootIdentity.create(mnemonic, false, didStore!, defaultStorePass)
        }
        self.rootIdentity = try didStore!.loadRootIdentity()
        print("rootIdentity = \(self.rootIdentity)")
    }
    
    public func handleMnemonic(mnemonic: String) -> String {
        do {
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
    
    func didDocument()throws {
        if document == nil {
            document = try didStore?.loadDid(didString)
        }
    }
    
    func loadCurrentDid() -> String {
        let defaults = UserDefaults.standard
        if didString != "" {
            return didString
        }
        
        didString = defaults.value(forKey: defaultsKeys.currentUserDid) != nil ? defaults.value(forKey: defaultsKeys.currentUserDid) as! String : ""
        
        return didString
    }
    
    func loadCurrentDidPath() -> String {
        let defaults = UserDefaults.standard
        path = defaults.value(forKey: defaultsKeys.currentUserPath) != nil ? defaults.value(forKey: defaultsKeys.currentUserPath) as! String : ""
            
        return dirPath + path
    }
    
    func save_did() -> Bool {
        let defaults = UserDefaults.standard
        print("loginView did = \(didString)")
        if didString == "" {
            return false
        }
        defaults.setValue(didString, forKey: defaultsKeys.currentUserDid)
        defaults.setValue(path, forKey: defaultsKeys.currentUserPath)
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

class DaumsIDChainAdapter: DefaultDIDAdapter {
    private var idtxEndpoint: String = ""

    override init(_ endpoint: String) {
        super.init(endpoint)
        idtxEndpoint = endpoint
    }
    
    override func createIdTransaction(_ payload: String, _ memo: String?) throws {
        let data = try assistPerformRequest("https://assist.trinity-tech.io/v2/didtx/create", payload)
        print("createIdTransaction: \(data)")
    }
    
    func assistPerformRequest(_ urlString: String, _ body: String) throws -> Data? {
        let url = URL(string: urlString)!
        
        let requestBody = [
            "did": did,
            "memo": "",
            "requestFrom": "Essentials",
            "didRequest": body.toDictionary()
        ] as [String : Any]
        print("requestBody = ", requestBody)
        
        var request = URLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("IdSFtQosmCwCB9NOLltkZrFy5VqtQn8QbxBKQoHPw7zp3w0hDOyOYjgL53DO3MDH", forHTTPHeaderField: "Authorization")
        
        let parameters = requestBody
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let semaphore = DispatchSemaphore(value: 0)
        var errDes: String?
        var result: Data?
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse,
                error == nil else { // check for fundamental networking error
                
                errDes = error?.localizedDescription
                let httpResponse = response as? HTTPURLResponse
                if (httpResponse?.statusCode == 303) {
                    errDes = "Request rejected by the server"
                }
                semaphore.signal()
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else { // check for http errors
                errDes = "Server eror (status code: \(response.statusCode)"
                print(errDes)
                print(String(data: data!, encoding: .utf8))
                semaphore.signal()
                return
            }
            
            result = data
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        guard let _ = result else {
            throw DIDError.CheckedError.DIDBackendError.DIDResolveError(errDes ?? "Unknown error")
        }
        
        return result
    }
    
}
