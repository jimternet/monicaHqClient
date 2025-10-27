import Foundation
import Security

struct APICredentials {
    let apiURL: String
    let apiToken: String
}

class KeychainManager {
    private let apiURLKey = "com.monicahq.client.apiURL"
    private let apiTokenKey = "com.monicahq.client.apiToken"
    
    func saveCredentials(apiURL: String, apiToken: String) {
        saveToKeychain(key: apiURLKey, value: apiURL)
        saveToKeychain(key: apiTokenKey, value: apiToken)
    }
    
    func getCredentials() -> APICredentials? {
        guard let apiURL = getFromKeychain(key: apiURLKey),
              let apiToken = getFromKeychain(key: apiTokenKey) else {
            return nil
        }
        
        return APICredentials(apiURL: apiURL, apiToken: apiToken)
    }
    
    func deleteCredentials() {
        deleteFromKeychain(key: apiURLKey)
        deleteFromKeychain(key: apiTokenKey)
    }
    
    private func saveToKeychain(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Failed to save to keychain: \(status)")
        }
    }
    
    private func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        return nil
    }
    
    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}