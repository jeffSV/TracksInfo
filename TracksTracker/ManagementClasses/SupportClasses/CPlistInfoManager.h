/*
//  CPlistInfoManager.h
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

#import <Foundation/Foundation.h>

@interface CPlistInfoManager : NSObject

@property(nonatomic, strong) NSString *strInfoFileName;

@end