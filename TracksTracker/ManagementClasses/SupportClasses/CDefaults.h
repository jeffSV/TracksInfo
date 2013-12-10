/*
//  CDefaults.h
//  InfoReadTest
//
//  Created by jbehrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import <Foundation/Foundation.h>

#import "Defs.h"

@interface CDefaults : NSObject

+(NSArray *)alphabetArray;
+(NSString *)appsPlistKeyName;
+(NSString *)defaultPlistFileName;
+(NSString *)trackPropertyName:(TRACK_PROPERTIES)eTrackProperty;


@end
