//
//  EncryptionHelper.h
//  Hyphen
//
//  Created by Yunus Dawji on 2014-07-14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>

#define kChosenCipherBlockSize	kCCBlockSizeAES256
#define kChosenCipherKeySize	kCCKeySizeAES256
#define kChosenDigestLength		CC_SHA1_DIGEST_LENGTH

// constants used to find public, private, and symmetric keys.
#define kSymmetricKeyTag		"com.hyphen.symmetrickey"

@interface EncryptionHelper : NSObject{
    SecKeyRef publicKey;
    SecCertificateRef certificate;
    SecPolicyRef policy;
    SecTrustRef trust;
    size_t maxPlainLen;
    NSData* symmetricKeyRef;
}

@property (strong,nonatomic) NSData *symmetricKey;
@property (nonatomic, retain) NSData * symmetricTag;



- (NSData *) encryptWithRSA:(NSData *)content;
- (NSData*) encryptWithAES:(NSData *)content key:(NSData *)key;
- (NSData *) decryptWithAES:(NSData *)content key:(NSData *)key;
- (void) generateSymmetricKeyCertificate: (NSData *) content;
- (void)deleteSymmetricKey;
- (void)generateSymmetricKey;
- (NSData *)getSymmetricKeyBytes;
- (void)generateSymmetricKeyCertificate;

@end
