/*
//  CPlistInfoManager.m
//  InfoReadTest
//
//  Reads the plist for the info and converts the plist info into
//  managed objects and calls the CDataManager to place the newly
//  read in track info into the persistance/DB store. This class
//  is then complete. The user uses other object types to retreive
//  view/update/delete the tracks from the DB.
//
//  Created by jbehrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import "CPlistInfoManager.h"
#import "CDataManager.h"
#import "DBTrack.h"
#import "CDefaults.h"
#import "CHelperMethods.h"

@interface CPlistInfoManager()
{
	BOOL bDataAvailable;
}

@property(nonatomic, strong) NSDictionary *dicPlistInfo;

-(BOOL)readInfoFile;
-(void)configureColor:(DBTrack *)trk;
-(BOOL)convertDictionaryEntriesToDBObjects;

@end

@implementation CPlistInfoManager

@synthesize dicPlistInfo = _dicPlistInfo;
@synthesize strInfoFileName = _strInfoFileName;

-(void)setStrInfoFileName:(NSString *)strInfoFileName
{
	if( (strInfoFileName != nil) && (strInfoFileName.length > 0) )
	{
		_strInfoFileName = strInfoFileName;
		bDataAvailable = ([self readInfoFile] == TRUE) && ([self convertDictionaryEntriesToDBObjects] == TRUE);
	}
}

-(id)init
{
	self = [super init];

	bDataAvailable = FALSE;
	
	return self;
}

-(BOOL)readInfoFile
{
	//First thing you must do is locate the PList you intend to read from. This may or maynot be the default name;
	NSURL *plistURL = [[NSBundle mainBundle] URLForResource:self.strInfoFileName withExtension:@"plist"];
	
	if(plistURL != nil)
		self.dicPlistInfo = [[NSDictionary alloc] initWithContentsOfURL:plistURL];
	
	if( (self.dicPlistInfo == nil) && (plistURL != nil) )
	{
		NSString *strPath = [[NSBundle mainBundle] pathForResource:[CDefaults defaultPlistFileName] ofType:@"plist"];
		self.dicPlistInfo = [NSURL URLWithString:strPath];
	}

	return !(self.dicPlistInfo == nil);
}

-(BOOL)convertDictionaryEntriesToDBObjects
{
	BOOL bRetStat = TRUE;

	CDataManager *dataMgr = [CDataManager theDataManager];
	
	NSObject *objAppsVals = [self.dicPlistInfo objectForKey:[CDefaults appsPlistKeyName]];

	if([objAppsVals isKindOfClass:[NSArray class]] == FALSE)
		return FALSE;
	
	NSArray *arrTrackDictionaries = (NSArray *)objAppsVals;

	for(NSObject *trackInfoObj in arrTrackDictionaries)
	{
		if( (trackInfoObj == [NSNull null]) || ([trackInfoObj isKindOfClass:[NSDictionary class]] == FALSE) )
			continue;
		
		NSDictionary *trackInfoDictionary = (NSDictionary *)trackInfoObj;
		
		NSObject *objTrkID = [trackInfoDictionary objectForKey:[CDefaults trackPropertyName:TRACK_ID]];
		NSObject *objTrkVer = [trackInfoDictionary objectForKey:[CDefaults trackPropertyName:TRACK_VERSION]];
		NSObject *objTrkPrice = [trackInfoDictionary objectForKey:[CDefaults trackPropertyName:PRICE]];
		
		//Validate the mandatory properties are present.
		if( (objTrkID == [NSNull null]) || (objTrkVer == [NSNull null]) || (objTrkPrice == [NSNull null]) )
			continue;//You don't have a valid track object
		
		NSObject *objTrkName = [trackInfoDictionary objectForKey:[CDefaults trackPropertyName:TRACK_NAME]];
		NSObject *objTrkDesc = [trackInfoDictionary objectForKey:[CDefaults trackPropertyName:TRACK_DESC]];
		NSObject *objArt60Px = [trackInfoDictionary objectForKey:[CDefaults trackPropertyName:ARTWRK_URL_60]];
		NSObject *objArt512Px = [trackInfoDictionary objectForKey:[CDefaults trackPropertyName:ARTWRK_URL_512]];
		NSObject *objArtistName = [trackInfoDictionary objectForKey:[CDefaults trackPropertyName:ARTIST_NAME]];
		
		if(objTrkID != nil)
		{
			if([dataMgr retreiveTrackByID:(NSNumber *)objTrkID sortOption:BY_DEFAULT] != nil)
				continue;//Means the track is already in the DB
		}//End

		if(objTrkName != nil)
		{
			NSArray *arrNamedTracks = [dataMgr retreiveTracksByName:(NSString *)objTrkName sortOption:BY_DEFAULT];
			if( (arrNamedTracks != nil) && (arrNamedTracks.count > 0) )
				continue;//Means the track(s) are already in the DB
		}//End

		DBTrack *newTrack = nil;
		
		@try
		{
			newTrack = [NSEntityDescription
							insertNewObjectForEntityForName:@"DBTrack"
							inManagedObjectContext:dataMgr.theDatabase];
			
			newTrack.trkVersion = (NSString *)objTrkVer;
			newTrack.trkID =   [CHelperMethods numberFromString:(NSString *)objTrkID];
			newTrack.price = [CHelperMethods numberFromString:(NSString *)objTrkPrice];

			newTrack.trkName = (NSString *)objTrkName;
			newTrack.artistName = (NSString *)objArtistName;
			newTrack.artUrl60x60 = (NSString *)objArt60Px;
			newTrack.artUrl512x512 = (NSString *)objArt512Px;
			newTrack.trkDescription = (NSString *)objTrkDesc;
			
			[self configureColor:newTrack];
			NSLog(@"%@", newTrack.displayColor);
			
			
			if([dataMgr commitAndSaveChanges] == FALSE)
				[dataMgr removeManagedObj:newTrack];
		}
		@catch (NSException *exception)
		{
			if(newTrack != nil)
				[dataMgr removeManagedObj:newTrack];
		}
		@finally
		{
			newTrack = nil;
		}
	}

	return bRetStat;
}

-(void)configureColor:(DBTrack *)trk
{
	if(trk == nil)
		return;

	if( ([[trk.trkName lowercaseString] rangeOfString:@"flixster"].location != NSNotFound) ||
		 ([[trk.trkName lowercaseString] rangeOfString:@"fantasy"].location != NSNotFound) )
	{
		trk.displayColor = @"f90628";
	}
	else
	{
		trk.displayColor = @"000000";
	}
}//End

@end