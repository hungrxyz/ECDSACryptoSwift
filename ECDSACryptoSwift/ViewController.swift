//
//  ViewController.swift
//  ECDSACryptoSwift
//
//  Created by Zel Marko on 11/20/16.
//  Copyright © 2016 Zel Marko. All rights reserved.
//

import UIKit
import GMCrypto

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
//		// The first 24 bytes of the SHA-256 hash for "Hack the Planet!"
//		char bytes[] = { 56, 164, 34, 250, 121, 21, 2, 18, 65, 4, 161, 90, 126, 145, 111, 204,
//			151, 65, 181, 4, 231, 177, 117, 154 };
//		NSData *messageHash = [NSData dataWithBytes:bytes length:24];
//		
//		GMEllipticCurveCrypto *crypto = [GMEllipticCurveCrypto cryptoForCurve:
//			GMEllipticCurveSecp192r1];
//		crypto.privateKeyBase64 = @"ENxb+5pCLAGT88vGmE6XLQRH1e8i/0rz";
//		NSData *signature = [crypto signatureForHash:messageHash];
//		NSLog(@"Signature: %@", signature);
		
		self.letsgo()
	}
	
	@IBAction func letsgoTapped() { self.letsgo() }

	func letsgo() {
		let privateIdString = "568f96df895f25b0506ddaa5f123ea6a53c92ffae8f193b34d0aca016b663002"
		let payload = "{\"users\":[{\"emailAddress\":\"marko@zzzel.xyz\"}]}"
		
		guard let crypto = GMEllipticCurveCrypto(curve: GMEllipticCurveSecp256r1) else {
			print("No Crypto")
			return
		}
		guard let base64DataId = Data(base64Encoded: privateIdString, options: Data.Base64DecodingOptions(rawValue: 0)) else {
			print("No Base64 id")
			return
		}
		crypto.privateKeyBase64 = base64DataId.base64EncodedString()
		guard let signiture = crypto.signature(forHash: payload.data(using: .utf8)!.sha256) else {
			print("No Signiture")
			return
		}
		guard let base64Signiture = Data(base64Encoded: signiture, options: Data.Base64DecodingOptions(rawValue: 0))?.base64EncodedString() else {
			print("No base64 signiture")
			return
		}
		
		let headers = [
			"Content-Type": "text/plain",
			"X-Apple-CloudKit-Request-KeyID": privateIdString,
			"X-Apple-CloudKit-Request-ISO8601Date": Date().iso8601,
			"X-Apple-CloudKit-Request-SignatureV1": base64Signiture
		]
		
		let request = NSMutableURLRequest(url: URL(string: "https://api.apple-cloudkit.com/database/1/iCloud.com.n26.kicker/development/public/users/lookup/email")!,
		                                  cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = headers
		request.httpBody = payload.data(using: .utf8)
		
		let session = URLSession.shared
		let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
			if (error != nil) {
				print(error)
			} else {
				let httpResponse = response as? HTTPURLResponse
				print(httpResponse)
			}
		})
		
		dataTask.resume()
	}
	
}

extension Int {
	var hexString: String {
		return String(self, radix: 16)
	}
}

extension Data {
	var hexString: String {
		let string = self.map{Int($0).hexString}.joined()
		return string
	}
	
	var MD5: Data {
		var result = Data(count: Int(CC_MD5_DIGEST_LENGTH))
		_ = result.withUnsafeMutableBytes {resultPtr in
			self.withUnsafeBytes {(bytes: UnsafePointer<UInt8>) in
				CC_MD5(bytes, CC_LONG(count), resultPtr)
			}
		}
		return result
	}
	
	var sha256: Data {
		var result = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
		_ = result.withUnsafeMutableBytes { resultPtr in
			self.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
				CC_SHA256(bytes, CC_LONG(count), resultPtr)
			}
		}
		return result
	}
	
	/*
	... nearly the same for `SHA1` and `SHA256`.
	*/
}

extension String {
	var hexString: String {
		return self.data(using: .utf8)!.hexString
	}
	
	var MD5: String {
		return self.data(using: .utf8)!.MD5.hexString
	}
	
	var sha256: String {
		return self.data(using: .utf8)!.sha256.hexString
	}
	
	/*
	... nearly the same for `SHA1` and `SHA256`.
	*/
}

extension Date {
	struct Formatter {
		static let iso8601: DateFormatter = {
			let formatter = DateFormatter()
			formatter.calendar = Calendar(identifier: .iso8601)
			formatter.locale = Locale(identifier: "en_US_POSIX")
			formatter.timeZone = TimeZone(secondsFromGMT: 0)
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
			return formatter
		}()
	}
	var iso8601: String {
		return Formatter.iso8601.string(from: self)
	}
}


extension String {
	var dateFromISO8601: Date? {
		return Date.Formatter.iso8601.date(from: self)
	}
}

