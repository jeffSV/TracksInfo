/*
//  CDataManager.m
//  InfoReadTest
//
//  Created by jbehrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import "CDataManager.h"
#import "DBTrack.h"

@interface CDataManager()

@property (atomic) BOOL bProperlyInitialized;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(NSURL *)applicationDocumentsDirectory;
-(void)addSortDescriptorToRequest:(NSFetchRequest *)request sortOption:(SORT_OPTIONS)eSortOption;

@end

@implementation CDataManager

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize bProperlyInitialized = _bProperlyInitialized;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

-(id)init
{
	self = [super init];
	
	if(self)
		self.bProperlyInitialized = FALSE;

	return self;
}

//Used for the singleton
+(CDataManager *)theDataManager
{
	static CDataManager *sharedInstance = nil;
	
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedInstance = [[CDataManager alloc] init];
		sharedInstance.bProperlyInitialized = TRUE;//Be sure this is called only after init
	});

	return sharedInstance;
}

-(BOOL)isDBSetup
{
	return self.bProperlyInitialized & (self.theDatabase != nil);
}

-(NSInteger) numberOfTracksInDB
{
	NSInteger entityCount = 0;
	NSError *error = nil;

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBTrack" inManagedObjectContext:self.theDatabase];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	[fetchRequest setEntity:entity];
	[fetchRequest setIncludesPropertyValues:NO];
	[fetchRequest setIncludesSubentities:NO];

	NSUInteger count = [self.theDatabase countForFetchRequest: fetchRequest error: &error];

	if(error == nil)
		entityCount = count;

	return entityCount;
}

-(NSManagedObjectContext *)theDatabase
{
	return self.managedObjectContext;
}

-(BOOL)commitAndSaveChanges
{
	if (![[self managedObjectContext] hasChanges]) 
		return TRUE;

	BOOL bRetStat = TRUE;
	NSError *error = nil;
	
	if (![[self managedObjectContext] save:&error])
	{
		bRetStat = FALSE;
		NSLog(@"Failed to save the changes to the DB");
	}//End          
	
	return bRetStat;
}

-(NSArray *)retreiveAllTracks
{
	NSEntityDescription *entityDescription = [NSEntityDescription
															entityForName:@"DBTrack" inManagedObjectContext:self.theDatabase];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	[request setEntity:entityDescription];

	NSError *error;
	NSArray *arrayTracks = [self.theDatabase executeFetchRequest:request error:&error];
	
	return arrayTracks;//Can be greater than 1 - Names don't have to be unique
}

-(NSArray *)retreiveTracksByName:(NSString *)strName sortOption:(SORT_OPTIONS)eSortOption
{
	NSEntityDescription *entityDescription = [NSEntityDescription
															entityForName:@"DBTrack" inManagedObjectContext:self.theDatabase];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	[request setEntity:entityDescription];
	
	// Set predicate and sort orderings...
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
									  @"(trkName LIKE[c] %@)", strName];
	
	[request setPredicate:predicate];
	
	[self addSortDescriptorToRequest:request sortOption:eSortOption];
	
	NSError *error;
	NSArray *arrayTracks = [self.theDatabase executeFetchRequest:request error:&error];
	
	return arrayTracks;//Can be greater than 1 - Names don't have to be unique
}

-(NSManagedObject *)retreiveTrackByID:(NSNumber *)numID sortOption:(SORT_OPTIONS)eSortOption
{
	NSEntityDescription *entityDescription = [NSEntityDescription
															entityForName:@"DBTrack" inManagedObjectContext:self.theDatabase];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	[request setEntity:entityDescription];
	
	// Set predicate and sort orderings...
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
									  @"(trkID == %d)", [numID intValue] ];
	
	[request setPredicate:predicate];
	
	[self addSortDescriptorToRequest:request sortOption:eSortOption];

	NSError *error;
	NSArray *arrayTracks = [self.theDatabase executeFetchRequest:request error:&error];
	
	DBTrack *theTrack = nil;
	if( (arrayTracks != nil) && (arrayTracks.count >= 1) )//Weird if it's greater than 1
	{
		theTrack = [arrayTracks objectAtIndex:0];
		
		//Test is you need to remove duplicates. ID Must be unique
		if(arrayTracks.count > 1)
		{
			NSInteger iArrCount = arrayTracks.count;

			for(int i = 1; i < iArrCount; i++)
				[self removeManagedObj:[arrayTracks objectAtIndex:i]];
		}
	}
	
	return theTrack;
}

-(void)addSortDescriptorToRequest:(NSFetchRequest *)request sortOption:(SORT_OPTIONS)eSortOption
{
	if( (request == nil) || (eSortOption == BY_DEFAULT) )
		return;//Get sorted data however coredata choses.
	
	NSSortDescriptor *sortDescriptor;
	
	switch (eSortOption)
	{
		case BY_ID_ASCENDING:
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"trkID" ascending:YES];
			break;
		case BY_ID_DESCENDING:
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"trkID" ascending:NO];
			break;
		case BY_PRICE_ASCENDING:
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
			break;
		case BY_PRICE_DESCENDING:
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:NO];
			break;
		case BY_TRKNAME_ASCENDING:
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"trkName" ascending:YES];
			break;
		case BY_TRKNAME_DESCENDING:
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"trkName" ascending:NO];
			break;
		case BY_ARTISTNAME_ASCENDING:
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"artistName" ascending:YES];
			break;
		case BY_ARTISTNAME_DESCENDING:
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"artistName" ascending:NO];
			break;
		default:
			sortDescriptor = nil;
			break;
	}

	if(sortDescriptor != nil)
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

#pragma mark - Removal methods

-(void)removeManagedObj:(NSManagedObject *)dbObj
{
	if(dbObj == nil)
		return;
	
	@try
	{
		[self.managedObjectContext deleteObject:dbObj];
	}
	@catch (NSException *exception) 
	{
		NSLog(@"Failed to remove the ManagedObject from the DB");
	}
	@finally 
	{
		dbObj = nil;
	}
}

-(void)removeTrackByID:(NSNumber *)trkID
{
	if(trkID == nil)
		return;
	
	NSManagedObject *trk = nil;
	
	@try
	{
		trk = [self retreiveTrackByID:trkID sortOption:BY_DEFAULT];
	}
	@catch (NSException *exception)
	{
	}
	@finally 
	{
		[self removeManagedObj:trk];
	}
}

-(void)removeTrackByName:(NSString *)strTrackName
{
	if( (strTrackName == nil) || (strTrackName.length <= 0) )
		return;

	@try 
	{
		NSArray *arrTracks = [self retreiveTracksByName:strTrackName sortOption:BY_DEFAULT];
		
		for(NSObject *obj in arrTracks)
		{
			if([obj isKindOfClass:[NSManagedObject class]] == TRUE)
				[self removeManagedObj:(NSManagedObject *)obj];
		}
	}
	@catch (NSException *exception)
	{}
	@finally
	{}
}

-(void)removeTracksWithIDs:(NSArray *)arrTrackIDs
{
	for(NSObject *obj in arrTrackIDs)
	{
		if( (obj == [NSNull null]) || ([obj isKindOfClass:[NSNumber class]] == FALSE) )
			continue;

		[self removeTrackByID:(NSNumber *)obj];
	}
}

-(void)removeTracksWithNames:(NSArray *)arrTrackNames
{
	for(NSObject *obj in arrTrackNames)
	{
		if( (obj == [NSNull null]) || ([obj isKindOfClass:[NSString class]] == FALSE) )
			continue;
		
		[self removeTrackByName:(NSString *)obj];
	}
}

#pragma mark - setup and intialziation of the coredata module

// Creates if necessary and returns the managed object model for the application.
-(NSManagedObjectModel *)managedObjectModel
{
	if (_managedObjectModel)
		return _managedObjectModel;
	
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TrackInfoDataModel" withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return _managedObjectModel;
}

/*
 | Returns the persistent store coordinator for the application.
 | If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator != nil)
		return _persistentStoreCoordinator;

	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TracksInfoDB.sqlite"];

	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}//End
	
	return _persistentStoreCoordinator;
}//End

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
-(NSManagedObjectContext *)managedObjectContext
{
	if (_managedObjectContext)
		return _managedObjectContext;
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	
	if (!coordinator)
	{
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
		[dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];

		return nil;
	}
	
	_managedObjectContext = [[NSManagedObjectContext alloc] init];
   
	[_managedObjectContext setPersistentStoreCoordinator:coordinator];
	
	return _managedObjectContext;
}

-(NSURL *)applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}//End

@end