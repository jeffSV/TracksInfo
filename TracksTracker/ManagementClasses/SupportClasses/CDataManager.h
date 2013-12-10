/*
//  CDataManager.h
//  InfoReadTest
//
//  Created by jbehrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

#import "Defs.h"

@class NSManagedObjectModel;
@class NSManagedObjectContext;
@class NSPersistentStoreCoordinator;

@interface CDataManager : NSObject

@property(nonatomic, readonly) BOOL isDBSetup;
@property(nonatomic, readonly) NSInteger numberOfTracksInDB;

//Only use this for the construction of managed objects
@property(nonatomic, readonly) NSManagedObjectContext *theDatabase;

//The caller needs to use this call instead of "init"
//to maintain the singleton nature of this class.
+(CDataManager *)theDataManager;

-(BOOL)commitAndSaveChanges;
-(void)removeManagedObj:(NSManagedObject *)dbObj;

-(NSArray *)retreiveAllTracks;
-(NSArray *)retreiveTracksByName:(NSString *)strName sortOption:(SORT_OPTIONS)eSortOption;
-(NSManagedObject *)retreiveTrackByID:(NSNumber *)numID sortOption:(SORT_OPTIONS)eSortOption;

-(void)removeTrackByID:(NSNumber *)trkID;
-(void)removeTrackByName:(NSString *)strTrackName;

//Expecting an array of NSNumbers which represent the 
//desired ID's of the tracks to remove.
-(void)removeTracksWithIDs:(NSArray *)arrTrackIDs;

//Expecting an array of NSStrings which are the
//desired names of the tracks to remove.
-(void)removeTracksWithNames:(NSArray *)arrTrackNames;

@end
