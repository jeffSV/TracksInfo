/*
//  CFetchedResultsBaseControllerViewController.h
//  TracksTracker
//
//  Created by Jeff Behrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@protocol fetchResultControllerChildTable <NSObject>
@required
-(void)fetchControllerChangedContent;//ie:Something changed in the fetched results

@end


@interface CFetchedResultsBaseController : UITableViewController<NSFetchedResultsControllerDelegate>

// Set to YES to get some debugging output in the console.
@property BOOL debug;

@property(strong, atomic) id<fetchResultControllerChildTable> childResultControllerDelegate;

@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

-(void)performFetch;

@end
