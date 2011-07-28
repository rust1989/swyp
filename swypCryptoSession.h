//
//  swypCryptoSession.h
//  swyp
//
//  Created by Alexander List on 7/27/11.
//  Copyright 2011 ExoMachina. Some rights reserved -- check online.
//

#import <Foundation/Foundation.h>
#import "swypEncryptingTransform.h"
#import "swypUnencryptingTransform.h"

typedef enum {
			/* nothing has occured yet, no crypto happening */
	swypCryptoSessionStagePreKeyShare = 0,
			/*1) client has sent a public key */
	swypCryptoSessionStageSharedPublicKey,
			/*2) server has sent a public key + symetric encrypted with client's public key with symmetric in json
				•last partially unencrypted message */
	swypCryptoSessionStageSharedSymetricKey,
			/*3)client has confirmed same device id, encrypted and sent this confirmation packet*/
	swypCryptoSessionStageConfirmedSymetricKey,
			/*4) server has replied to "clientKeyNeogtiationConclusion" message, and is ready to work big-time! */
	swypCryptoSessionStageReady
}swypCryptoSessionStage;

@interface swypCryptoSession : NSObject {
	
}
@property (nonatomic, assign)	swypCryptoSessionStage	cryptoStage;
@property (nonatomic, readonly)	BOOL					encryptedCommunicationRequired;
@property (nonatomic, retain)	NSData*					candidatePublicKey;
@property (nonatomic, retain)	NSData*					sharedSessionKey;

@property (nonatomic, retain)	swypEncryptingTransform*	encryptingTransform;
@property (nonatomic, retain)	swypUnencryptingTransform*	unencryptingTransform;

@end
