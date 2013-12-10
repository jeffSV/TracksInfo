/*
//  CFetchedResultsBaseControllerViewController.m
//  TracksTracker
//
//  Created by Jeff Behrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import "CFetchedResultsBaseControllerViewController.h"

@interface CFetchedResultsBaseController()
@property (nonatomic) BOOL beganUpdates;

@end

@implementation CFetchedResultsBaseController

#pragma mark - Properties
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize suspendAutomaticTrackingOfChangesInManagedObjectContext = _suspendAutomaticTrackingOfChangesInManagedObjectContext;
@synthesize debug = _debug;
@synthesize beganUpdates = _beganUpdates;

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Fetching

- (void)performFetch
{
	if (self.fetchedResultsController)
	{
		if (self.fetchedResultsController.fetchRequest.predicate)
		{
			if (self.debug)
			{
				NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd),
						self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
			}
		}
		else
		{
			if (self.debug)
			{
				NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd),
						self.fetchedResultsController.fetchRequest.entityName);
			}
		}
		
		NSError *error;
		[self.fetchedResultsController performFetch:&error];
		if (error)
			NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
	}
	else
	{
		if (self.debug)
			NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	}
	
	[self.tableView reloadData];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
	NSFetchedResultsController *oldfrc = _fetchedResultsController;
	if (newfrc != oldfrc)
	{
		_fetchedResultsController = newfrc;
		newfrc.delegate = self;
		
		if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name]) && (!self.navigationController || !self.navigationItem.title))
		{
			self.title = newfrc.fetchRequest.entity.name;
		}
		
		if (newfrc)
		{
			if (self.debug)
				NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
			
			[self performFetch];
		}
		else
		{
			if (self.debug)
				NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
			
			[self.tableView reloadData];
		}//End else
	}//End if
}//End

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if(self.debug == TRUE)
		NSLog(@"Num sections: %lu", (unsigned long)[[self.fetchedResultsController sections] count]);

	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSUInteger iNumRowsInSection = 0;
	if(self.debug == TRUE)
		iNumRowsInSection = [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];

	return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(self.debug == TRUE)
	{
		NSString *strVal = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
		NSLog(@"Section title: %@", strVal);
	}
	
	return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

//This provides the first letter of the track's name for the header of each section
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	__block NSInteger iFoundIndex = -1;

	[[self.fetchedResultsController sections] enumerateObjectsUsingBlock:^(id tblSection, NSUInteger idx,BOOL *stop)
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = tblSection;
		
		if([sectionInfo.name compare:title] == NSOrderedSame)
		{
			iFoundIndex = idx;
			*stop = TRUE;
		}
	}];

	if(iFoundIndex < 0)
		return index;

	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:iFoundIndex];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
	{
		if(self.childResultControllerDelegate != nil)
			[self.childResultControllerDelegate fetchControllerChangedContent];
		
		[self.tableView beginUpdates];
		self.beganUpdates = YES;
	}
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
			  atIndex:(NSUInteger)sectionIndex
	  forChangeType:(NSFetchedResultsChangeType)type
{
	if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
	{
		switch(type)
		{
			case NSFetchedResultsChangeInsert:
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
				break;
		}//End switch
	}//End if
}//End

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
		 atIndexPath:(NSIndexPath *)indexPath
	  forChangeType:(NSFetchedResultsChangeType)type
		newIndexPath:(NSIndexPath *)newIndexPath
{
	if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
	{
		switch(type)
		{
			case NSFetchedResultsChangeInsert:
				[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeUpdate:
				[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeMove:
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
		}//End switch
	}//End if
}//End

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	if (self.beganUpdates)
		[self.tableView endUpdates];
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
	_suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
	if (suspend)
		_suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
	else
		[self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
}

@end

