//
//  swypBonjourServiceListener.m
//  swyp
//
//  Created by Alexander List on 7/27/11.
//  Copyright 2011 ExoMachina. Some rights reserved -- see included 'license' file.
//

#import "swypBonjourServiceListener.h"


@implementation swypBonjourServiceListener
@synthesize delegate = _delegate, serviceIsListening = _serviceIsListening;


#pragma mark candidates
-(NSSet*) allServerCandidates{
	if ([_serverCandidates count] == 0)
		return nil;
	
	return [NSSet setWithArray:[_serverCandidates allValues]];
}


#pragma mark NSNetServiceBrowserDelegate
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser{
	_serviceIsListening	= YES;
}
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser{
	_serviceIsListening	= NO;
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict{
	_serviceIsListening	= NO;
	[_delegate bonjourServiceListenerFailedToBeginListen:self error:[NSError errorWithDomain:[errorDict valueForKey:NSNetServicesErrorDomain] code:[[errorDict valueForKey:NSNetServicesErrorCode] intValue] userInfo:nil]];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing{
	swypServerCandidate * nextCandidate = [_serverCandidates objectForKey:[aNetService name]];
	if (nextCandidate == nil){

		if ([def_bonjourHostName isEqualToString:[aNetService name]]){
			return;
		}
		
		nextCandidate =	[[swypServerCandidate alloc] init];
		[nextCandidate	setNetService:aNetService];
		[nextCandidate	setAppearanceDate:[NSDate date]];
		
		[_serverCandidates setObject:nextCandidate forKey:[aNetService name]];
		[_delegate bonjourServiceListenerFoundServerCandidate:nextCandidate withListener:self];
	}else {
		EXOLog(@"candidate already exists in dict: %@", [[nextCandidate netService] name]);
	}

}
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing{\
	NSString * serviceName	=	[aNetService name];
	if (!StringHasText(serviceName))
		return;

	if ([_serverCandidates objectForKey:serviceName]){
		EXOLog(@"Removed service :%@",[aNetService name]);
		[_serverCandidates removeObjectForKey:serviceName];
	}
}

#pragma mark NSObject
-(id) init{
	if (self = [super init]){
		_serverBrowser		=	[[NSNetServiceBrowser alloc] init];
		[_serverBrowser			setDelegate:self];
		
		_serverCandidates	=	[[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)	dealloc{
	[self setServiceIsListening:FALSE];
	SRELS(_serverBrowser)
	SRELS(_serverCandidates);
	
	[super dealloc];
}


-(void)	setServiceIsListening:(BOOL)listening{
	if (_serviceIsListening == listening)
		return;
	
	if (listening == YES){
		[_serverBrowser searchForServicesOfType:@"_swyp._tcp." inDomain:@""];
	}else {
		[_serverBrowser	stop];
	}
}


@end
