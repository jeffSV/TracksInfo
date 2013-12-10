/*
//  CDefaults.m
//  InfoReadTest
//
//  Created by jbehrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import "CDefaults.h"

@implementation CDefaults

+(NSArray *)alphabetArray
{
	return [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
}

+(NSString *)appsPlistKeyName
{
	return @"apps";
}

+(NSString *)defaultPlistFileName
{
	return @"SampleData";
}

+(NSString *)trackPropertyName:(TRACK_PROPERTIES)eTrackProperty
{
	NSString *strPropName = @"Invalid";

	switch (eTrackProperty) {
		case TRACK_ID:
			strPropName = @"trackId";
			break;
		case ARTWRK_URL_60:
			strPropName = @"artworkUrl60";
			break;
		case ARTWRK_URL_512:
			strPropName = @"artworkUrl512";
			break;
		case PRICE:
			strPropName = @"price";
			break;
		case ARTIST_NAME:
			strPropName = @"artistName";
			break;
		case TRACK_NAME:
			strPropName = @"trackName";
			break;
		case TRACK_VERSION:
			strPropName = @"version";
			break;
		case TRACK_DESC:
			strPropName = @"description";
			break;
		default:
			break;
	}

	return strPropName;
}//End

@end
