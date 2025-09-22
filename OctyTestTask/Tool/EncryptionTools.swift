import Foundation
import SwiftyJSON
import CryptoSwift

class EncryptionTools {
    
    private static var _3868372818: MJEncryptString = MJEncryptString(
        factor: -42,
        value: [-104, -84, -119, -84, -93, -30, -4, -82, -126, -18, -5, -18, -116, -30, -96, -77],
        length: 16,
        decoded: false
    )

    private static var _571380506: MJEncryptString = MJEncryptString(
        factor: 13,
        value: [117, 90, 35, 120, 110, 53, 65, 88, 100, 35, 117, 58, 77, 102, 44, 125],
        length: 16,
        decoded: false
    )
    
    class func tiger2_aesDecrypt(_ rawData: Data) -> Data? {
        let tiger2_iv = _3868372818.mj_CString()
        let tiger2_key = _571380506.mj_CString()

        return aesDecryptString(input: rawData, key: tiger2_key, iv: tiger2_iv)
    }
    
    class func tiger2_aesEncrypt(_ rawData: String) -> Data? {
        let tiger2_iv = _3868372818.mj_CString()
        let tiger2_key = _571380506.mj_CString()

        return aesEncryptString(input: rawData, key: tiger2_key, iv: tiger2_iv)
    }
    
    class func aesEncryptString(input: String?, key: [UInt8], iv: [UInt8]) -> Data? {

        guard let input = input else { return nil }

        do {
            let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
            let aes_result = try aes.encrypt(input.bytes)
            return Data(aes_result)
        } catch let error {
            debugPrint(error)
        }
        return nil
    }

    class func aesDecryptString(input: Data?, key: [UInt8], iv: [UInt8]) -> Data? {

        guard let input = input else { return nil }

        do {
            let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
            let aes_result = try aes.decrypt(input.bytes)
            return Data(aes_result)
        } catch let error {
            debugPrint(error)
        }
        return nil
    }
}

struct MJEncryptString {
    var factor: Int8
    var value: [Int8]
    var length: Int
    var decoded: Bool
    var decrypted: [UInt8] = [UInt8]()

    mutating func mj_CString() -> [UInt8] {

        guard decoded == false else { return decrypted }

        let serialQueue = DispatchQueue(label: "com.encrypt.mj")
        serialQueue.sync {
            for t in self.value.enumerated() {
                decrypted.append(UInt8(t.element ^ self.factor))
            }
            self.decoded = true
        }

        return decrypted
    }

}
