/*
//  CTracksIntroTblVC.m
//  TracksTracker
//
//  Created by Jeff Behrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import "CTracksIntroTblVC.h"

#import "CDataManager.h"
#import "CDefaults.h"
#import "CExtraDataDisplayVC.h"
#import "CHelperMethods.h"
#import "CTrackInitialTableViewCell.h"
#import "CUpdateSyncInfo.h"
#import "DBTrack.h"

@interface CTracksIntroTblVC ()
	enum{CELL_HEIGHT=90};//Measured in points

	@property(atomic, strong) NSMutableArray *arrUpdateInfo;//Used in multiple threads
	@property (nonatomic, strong) NSIndexPath *deleteTrackAtIndexPath;

	-(void)updateCell:(CUpdateSyncInfo *)syncInfo;
	-(UIImage *)findImage:(NSIndexPath *)indxPath;
	-(void)retreiveImage:(NSIndexPath *)indxPath imgUrl:(NSString *)strUrl;
@end

@implementation CTracksIntroTblVC

@synthesize arrUpdateInfo = _arrUpdateInfo;
@synthesize deleteTrackAtIndexPath = _deleteTrackAtIndexPath;

-(void)viewDidLoad
{
	[super viewDidLoad];

	self.clearsSelectionOnViewWillAppear = TRUE;
	super.childResultControllerDelegate = self;

	[self.refreshControl endRefreshing];

	self.arrUpdateInfo = [[NSMutableArray alloc]init];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self setUpFetchedResultController];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

#pragma mark - Data changed protocol methods
-(void)fetchControllerChangedContent//ie:Something changed in the fetched results
{
	
}

-(void)setUpFetchedResultController
{
	CDataManager *dataMgr = [CDataManager theDataManager];

	if( (dataMgr.isDBSetup == FALSE) || (self.fetchedResultsController != nil) )
		return;

	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBTrack"];

	NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"trkName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];

	request.sortDescriptors	= [NSArray arrayWithObject:nameSort];

	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
																							  managedObjectContext:  dataMgr.theDatabase
																								 sectionNameKeyPath:@"alphaOrderingLetter"
																											 cacheName:nil];
}

#pragma mark - Table view data source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	const float IMG_MAX_SQ = 35.0f;

	static NSString *CellIdentifier = @"myReuseID";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	CTrackInitialTableViewCell* tblCell;
	if (!cell)
	{
		tblCell = (CTrackInitialTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"trackInitialCell" owner:self options:nil] objectAtIndex:0];
	}
	else
	{
		if([cell isKindOfClass:[CTrackInitialTableViewCell class]] == FALSE)
			return cell;
		
		tblCell = (CTrackInitialTableViewCell *)cell;
	}

	// ask NSFetchedResultsController for the NSManagedObject at the row in question
	DBTrack *trk = [self.fetchedResultsController objectAtIndexPath:indexPath];

	if(trk == nil)
	{
		tblCell.imageView.image = [UIImage imageNamed:@"NoAvailableImage40x40.png"];
		tblCell.lblTrackName.text = @"No Available Name";
		return tblCell;
	}

	if( (trk.artUrl60x60 == nil) || (trk.artUrl60x60.length <= 0) )
	{
		tblCell.imageView.image = [UIImage imageNamed:@"NoAvailableImage40x40.png"];
	}
	else
	{
		UIImage *imgFromAsyncUrlReq = [self findImage:indexPath];
		if(imgFromAsyncUrlReq != nil)//Since this gets called for update after async request - if you have the image don't fire off another request.
			tblCell.imageView.image = imgFromAsyncUrlReq;
		else
			[self retreiveImage:indexPath imgUrl:trk.artUrl60x60];
	}

	if( (tblCell.imageView.image.size.height > IMG_MAX_SQ) || (cell.imageView.image.size.width > IMG_MAX_SQ) )
	{
		UIGraphicsBeginImageContext(CGSizeMake(IMG_MAX_SQ ,IMG_MAX_SQ));
		[tblCell.imageView.image drawInRect:CGRectMake(0, 0, IMG_MAX_SQ, IMG_MAX_SQ)];
		tblCell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	
	tblCell.lblTrackName.text = trk.trkName;
	tblCell.lblArtistName.text = trk.artistName;

	return tblCell;
}

//Provides the [A - Z] listing along the right side
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return [CDefaults alphabetArray];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		if (editingStyle == UITableViewCellEditingStyleDelete)
		{
			 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete Track?"
																			message:@"This will delete the track record. Are you sure you want to delete the selected Track? "
																		  delegate:self
															  cancelButtonTitle:@"Yes"
															  otherButtonTitles:@"No", nil];
			[alert show];

			self.deleteTrackAtIndexPath = indexPath;
		}//End if
	}//End if
}//End commitEdit

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return CELL_HEIGHT;
}//End
 
#pragma mark - Navigation

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(alertView.numberOfButtons == 1)
		return;//Means it's just the info view with only an OK button
	
	if( (buttonIndex == 1) || (self.deleteTrackAtIndexPath == nil) )
	{
		[self.tableView setEditing:FALSE animated:FALSE];
		return;//Don't do anything if the user hit the no button
	}
	
	@try
	{
		NSObject *objTrk = [self.fetchedResultsController objectAtIndexPath:self.deleteTrackAtIndexPath];
		
		if( (objTrk != [NSNull null]) && ([objTrk isKindOfClass:[NSManagedObject class]] == TRUE))
			[[CDataManager theDataManager] removeManagedObj:(NSManagedObject *)objTrk];
		else
			NSLog(@"Unable to validate the track for removal");
	}
	@catch (NSException *exception)
	{
		NSLog(@"Failed to remove the track from the DB");
	}
	@finally
	{
		self.deleteTrackAtIndexPath = nil;
		[self.tableView setEditing:FALSE animated:FALSE];
	}
}//End

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	DBTrack *trk = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	if(trk == nil)
	{
		NSLog(@"The row at index %ld of section %ld was selected and invalid", indexPath.row, (long)indexPath.section);
		return;
	}
	
	NSString *strTitle = trk.trkName;
	NSString *strMsg = [NSString stringWithFormat:@"Artist: %@\nPrice: $%0.2f", trk.artistName, [trk.price floatValue]];
	
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alert show];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
		return;//The iPhone will segue

	UIViewController *detailedVC = [CHelperMethods retreiveSplitViewDispalayController:self.splitViewController];

	if( (detailedVC == nil) || ([detailedVC isKindOfClass:[CExtraDataDisplayVC class]] == FALSE) )
		return;

	CExtraDataDisplayVC *extrDataVC = (CExtraDataDisplayVC *)detailedVC;
	
	if([extrDataVC configureHtmlFromTrack:[self.fetchedResultsController objectAtIndexPath:indexPath]] == FALSE)
	{
		NSLog(@"Failed to properly construct the track's HTML from the track at index: %ld Row - %ld Section", indexPath.row, indexPath.section);
		return;
	}
}

// In a story board-based application, you will often want to do a little preparation before navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if([sender isKindOfClass:[UITableViewCell class]] == FALSE)
	{
		NSLog(@"Unknow sender from tableview segue. Sender type: %@", [sender class]);
		return;
	}

	if([segue.destinationViewController isKindOfClass:[CExtraDataDisplayVC class]] == FALSE)
	{
		NSLog(@"Unknow segue destination controller of type: %@", [segue.destinationViewController class]);
		return;//Not 100% sure where we're going but there's nothing we can do about it now.
	}

	UITableViewCell *cell = (UITableViewCell *)sender;
	
	NSIndexPath *indxPth = [self.tableView indexPathForCell:cell];

	CExtraDataDisplayVC *destVC = (CExtraDataDisplayVC *)segue.destinationViewController;

	if([destVC configureHtmlFromTrack:[self.fetchedResultsController objectAtIndexPath:indxPth]] == FALSE)
	{
		NSLog(@"Failed to properly construct the track's HTML from the track at index: %ld Row - %ld Section", indxPth.row, indxPth.section);
		return;
	}
}

-(void)retreiveImage:(NSIndexPath *)indxPath imgUrl:(NSString *)strUrl
{
	if( (indxPath == nil) || (strUrl == nil) || (strUrl.length <= 0) )
		return;
	
	NSURL *urlImg = [NSURL URLWithString:strUrl];
	
	NSURLRequest *urlReq = [NSURLRequest requestWithURL:urlImg cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20.0];
	
	NSOperationQueue *opQue = [[NSOperationQueue alloc]init];
	
	[NSURLConnection sendAsynchronousRequest:urlReq queue:opQue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
	 {
		 if(error != nil)
			 NSLog(@"Error on asyn receive: %@", [error localizedDescription]);
		 
		 if([response isKindOfClass:[NSHTTPURLResponse class]] == TRUE)
		 {
			 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
			 
			 if(httpResponse.statusCode != 200)
				 return;
			
			 UIImage *image=[UIImage imageWithData:data];
			 
			 if(image == nil)
				 return;

			 CUpdateSyncInfo *syncInfo = [[CUpdateSyncInfo alloc]init];
			 syncInfo.img = image;
			 syncInfo.indxPth = indxPath;
			 
			 if(image != nil)
				 [self performSelectorOnMainThread:@selector(updateCell:) withObject:syncInfo waitUntilDone:NO];
		 }
	 }];
}

-(void)updateCell:(CUpdateSyncInfo *)syncInfo
{
	if( (syncInfo == nil) || (syncInfo.indxPth == nil) || (syncInfo.img == nil) )
		return;
	
	[self.arrUpdateInfo addObject:syncInfo];
	
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:syncInfo.indxPth] withRowAnimation:FALSE];
}

-(UIImage *)findImage:(NSIndexPath *)indxPath
{
	__block NSInteger iFoundIndex = -1;
	
	[self.arrUpdateInfo enumerateObjectsUsingBlock:^(id updateSyncInfo, NSUInteger idx,BOOL *stop)
	 {
		 if([updateSyncInfo isKindOfClass:[CUpdateSyncInfo class]] == FALSE)
			 return;
		 
		 CUpdateSyncInfo *syncInfo = (CUpdateSyncInfo *)updateSyncInfo;


		 if(syncInfo.indxPth != nil)
		 {
			if( (syncInfo.indxPth.row == indxPath.row) && (syncInfo.indxPth.section == indxPath.section) )
			{
				iFoundIndex = idx;
				*stop = TRUE;
			}
		 }
	 }];
			
	if(iFoundIndex < 0)
		return nil;

	CUpdateSyncInfo *syncInfoValid = [self.arrUpdateInfo objectAtIndex:iFoundIndex];
	[self.arrUpdateInfo removeObjectAtIndex:iFoundIndex];

	return syncInfoValid.img;
}//End

@end
