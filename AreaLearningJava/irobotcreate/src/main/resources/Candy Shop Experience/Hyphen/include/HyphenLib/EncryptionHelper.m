//
//  EncryptionHelper.m
//  Hyphen
//
//  Created by Yunus Dawji on 2014-07-14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "EncryptionHelper.h"

enum {
	CSSM_ALGID_NONE =					0x00000000L,
	CSSM_ALGID_VENDOR_DEFINED =			CSSM_ALGID_NONE + 0x80000000L,
	CSSM_ALGID_AES
};



@implementation EncryptionHelper

@synthesize symmetricTag, symmetricKey;

#if DEBUG
#define LOGGING_FACILITY(X, Y)	\
NSAssert(X, Y);

#define LOGGING_FACILITY1(X, Y, Z)	\
NSAssert1(X, Y, Z);
#else
#define LOGGING_FACILITY(X, Y)	\
if (!(X)) {			\
NSLog(Y);		\
}

#define LOGGING_FACILITY1(X, Y, Z)	\
if (!(X)) {				\
NSLog(Y, Z);		\
}
#endif

static const uint8_t symmetricKeyIdentifier[]	= kSymmetricKeyTag;


-(id) init {
    self = [super init];
    
    symmetricTag = [[NSData alloc] initWithBytes:symmetricKeyIdentifier length:sizeof(symmetricKeyIdentifier)];
    
    return self;
}

- (NSData *) encryptWithRSA:(NSData *)content {
    
    size_t plainLen = [content length];
    
    if (plainLen > maxPlainLen) {
        NSLog(@"content(%ld) is too long, must < %ld", plainLen, maxPlainLen);
        return nil;
    }
    
    void *plain = malloc(plainLen);
    [content getBytes:plain length:plainLen];
    
    size_t cipherLen = 256; // currently RSA key length is set to 256 bytes
    void *cipher = malloc(cipherLen);
    
    OSStatus returnCode = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, plain,
                                        plainLen, cipher, &cipherLen);
    
    
    NSData *result = nil;
    if (returnCode != 0) {
        NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)returnCode);
    }
    else {
        result = [NSData dataWithBytes:cipher
                                length:cipherLen];
    }
    
    free(plain);
    free(cipher);
    
    return result;
}




- (NSData*) encryptWithAES:(NSData *)content key:(NSData *)key
{
    unsigned char *keyPtr = (unsigned char *)[key bytes];
    size_t numBytesEncrypted = 0;
    
    NSUInteger dataLength = [content length];
    
    size_t bufferSize = dataLength + 2*kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    const unsigned char iv[] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};;
    
    CCCryptorStatus result = CCCrypt( kCCEncrypt,
                                     kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding,
                                     keyPtr,
                                     kCCKeySizeAES256,
                                     iv,
                                     [content bytes], [content length],
                                     buffer, bufferSize,
                                     &numBytesEncrypted );
    
    if( result == kCCSuccess )
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    else {
        NSLog(@"Failed AES");
    }
    return nil;
}

- (void) generateSymmetricKeyCertificate: (NSData *) content {
    NSUInteger len = [content length];
    Byte *data = (Byte*)malloc(len);
    memcpy(data, [content bytes], len);
    
    CFDataRef temp = CFDataCreate(NULL, data, 731);
    
    
    // create a certificate from data
    SecCertificateRef tempcertficate =  SecCertificateCreateWithData (NULL ,temp);
    
    // Create SecTrust and get Public Key
    CFArrayRef certs = CFArrayCreate(kCFAllocatorDefault, (const void **) &tempcertficate, 1, NULL);
    
    policy = SecPolicyCreateBasicX509();
    
    SecTrustCreateWithCertificates(certs, policy, &trust);
    
    SecTrustResultType trustResult;
    SecTrustEvaluate(trust, &trustResult);
    
    publicKey = SecTrustCopyPublicKey(trust);
    maxPlainLen = SecKeyGetBlockSize(publicKey) - 12;
    
    
    [self generateSymmetricKey];
    
}

- (NSData *) decryptWithAES:(NSData *)content key:(NSData *)key
{
    unsigned char *keyPtr = (unsigned char *)[key bytes];
    
    size_t numBytesEncrypted = 0;
    
    NSUInteger dataLength = [content length];
    
    size_t bufferSize = dataLength + 2*kCCBlockSizeAES128;
    void *buffer_decrypt = malloc(bufferSize);
    const unsigned char iv[] ={0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};;
    
    CCCryptorStatus result = CCCrypt( kCCDecrypt , kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                     keyPtr, kCCKeySizeAES256,
                                     iv,
                                     [content bytes], [content length],
                                     buffer_decrypt, bufferSize,
                                     &numBytesEncrypted );
    
    if( result == kCCSuccess )
        return [NSData dataWithBytesNoCopy:buffer_decrypt length:numBytesEncrypted];
    
    return nil;
}

- (NSData *)getSymmetricKeyBytes {
	OSStatus sanityCheck = noErr;
	NSData * symmetricKeyReturn = nil;
	
	if (self.symmetricKey == nil) {
		NSMutableDictionary * querySymmetricKey = [[NSMutableDictionary alloc] init];
		
		// Set the private key query dictionary.
		[querySymmetricKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
		[querySymmetricKey setObject:symmetricTag forKey:(__bridge id)kSecAttrApplicationTag];
		[querySymmetricKey setObject:[NSNumber numberWithUnsignedInt:CSSM_ALGID_AES] forKey:(__bridge id)kSecAttrKeyType];
		[querySymmetricKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
		
		CFTypeRef inTypeRef = (__bridge CFTypeRef)symmetricKeyReturn;
        
		// Get the key bits.
		sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)querySymmetricKey, &inTypeRef);
		if (sanityCheck == noErr && symmetricKeyReturn != nil) {
			self.symmetricKey = symmetricKeyReturn;
		} else {
			self.symmetricKey = nil;
		}
		
	} else {
		symmetricKeyReturn = self.symmetricKey;
	}
    
	return symmetricKeyReturn;
}

- (void)generateSymmetricKey {
	OSStatus sanityCheck = noErr;
	uint8_t * symmetricKey1 = NULL;
	
	// First delete current symmetric key.
	[self deleteSymmetricKey];
	
	// Container dictionary
	NSMutableDictionary *symmetricKeyAttr = [[NSMutableDictionary alloc] init];
	[symmetricKeyAttr setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
	[symmetricKeyAttr setObject:self.symmetricTag forKey:(__bridge id)kSecAttrApplicationTag];
	[symmetricKeyAttr setObject:[NSNumber numberWithUnsignedInt:CSSM_ALGID_AES] forKey:(__bridge id)kSecAttrKeyType];
	[symmetricKeyAttr setObject:[NSNumber numberWithUnsignedInt:(unsigned int)(kChosenCipherKeySize << 3)] forKey:(__bridge id)kSecAttrKeySizeInBits];
	[symmetricKeyAttr setObject:[NSNumber numberWithUnsignedInt:(unsigned int)(kChosenCipherKeySize << 3)]	forKey:(__bridge id)kSecAttrEffectiveKeySize];
	[symmetricKeyAttr setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecAttrCanEncrypt];
	[symmetricKeyAttr setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecAttrCanDecrypt];
	[symmetricKeyAttr setObject:(id)kCFBooleanFalse forKey:(__bridge id)kSecAttrCanDerive];
	[symmetricKeyAttr setObject:(id)kCFBooleanFalse forKey:(__bridge id)kSecAttrCanSign];
	[symmetricKeyAttr setObject:(id)kCFBooleanFalse forKey:(__bridge id)kSecAttrCanVerify];
	[symmetricKeyAttr setObject:(id)kCFBooleanFalse forKey:(__bridge id)kSecAttrCanWrap];
	[symmetricKeyAttr setObject:(id)kCFBooleanFalse forKey:(__bridge id)kSecAttrCanUnwrap];
	
	// Allocate some buffer space. I don't trust calloc.
	symmetricKey1 = malloc( kChosenCipherKeySize * sizeof(uint8_t) );
	
	LOGGING_FACILITY( symmetricKey1 != NULL, @"Problem allocating buffer space for symmetric key generation." );
	
	memset((void *)symmetricKey1, 0x0, kChosenCipherKeySize);
	
	sanityCheck = SecRandomCopyBytes(kSecRandomDefault, kChosenCipherKeySize, symmetricKey1);
	LOGGING_FACILITY1( sanityCheck == noErr, @"Problem generating the symmetric key, OSStatus == %d.", sanityCheck );
	
	self.symmetricKey = [[NSData alloc] initWithBytes:(const void *)symmetricKey1 length:kChosenCipherKeySize];
	
	// Add the wrapped key data to the container dictionary.
	[symmetricKeyAttr setObject:self.symmetricKey
                         forKey:(__bridge id)kSecValueData];
	
	// Add the symmetric key to the keychain.
	sanityCheck = SecItemAdd((__bridge CFDictionaryRef) symmetricKeyAttr, NULL);
	LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecDuplicateItem, @"Problem storing the symmetric key in the keychain, OSStatus == %d.", sanityCheck );
	
    
    NSLog(@"bytes in hex: %@", [self.symmetricKey description]);
    
	if (symmetricKey1) free(symmetricKey1);
}

- (void)deleteSymmetricKey {
	OSStatus sanityCheck = noErr;
	
	NSMutableDictionary * querySymmetricKey = [[NSMutableDictionary alloc] init];
	
	// Set the symmetric key query dictionary.
	[querySymmetricKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
	[querySymmetricKey setObject:symmetricTag forKey:(__bridge id)kSecAttrApplicationTag];
	[querySymmetricKey setObject:[NSNumber numberWithUnsignedInt:CSSM_ALGID_AES] forKey:(__bridge id)kSecAttrKeyType];
	
	// Delete the symmetric key.
	sanityCheck = SecItemDelete((__bridge CFDictionaryRef)querySymmetricKey);
	LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing symmetric key, OSStatus == %d.", sanityCheck );
	
	
	symmetricKeyRef = nil;
}




@end
