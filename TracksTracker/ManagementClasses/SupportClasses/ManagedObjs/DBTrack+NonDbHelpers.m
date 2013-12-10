/*
//  DBTrack+NonDbHelpers.m
//  TracksTracker
//
//  Created by Jeff Behrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import "DBTrack+NonDbHelpers.h"

@implementation DBTrack (NonDbHelpers)

-(NSString *)alphaOrderingLetter
{
	if( (self.trkName == nil) || (self.trkName.length < 1) )
		return @"A";
	
	return [self.trkName substringToIndex:1];
}


@end
