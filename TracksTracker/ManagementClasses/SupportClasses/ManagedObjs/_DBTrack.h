/*
//  DBTrack.h
//  InfoReadTest
//
//  Created by jbehrbaum on 12/6/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DBTrack : NSManagedObject

@property (nonatomic, retain) NSNumber * trkID;
@property (nonatomic, retain) NSString * trkName;
@property (nonatomic, retain) NSString * artistName;
@property (nonatomic, retain) NSString * artUrl60x60;
@property (nonatomic, retain) NSString * artUrl512x512;
@property (nonatomic, retain) NSString * trkDescription;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * trkVersion;

@end
