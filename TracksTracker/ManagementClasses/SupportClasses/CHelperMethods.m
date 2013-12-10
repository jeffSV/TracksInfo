/*
//  CHelperMethods.m
//  InfoReadTest
//
//  Created by jbehrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import "CHelperMethods.h"

@implementation CHelperMethods

+(NSNumber *)numberFromString:(NSString *)strNumber
{
	NSNumberFormatter * fmtr4Num = [[NSNumberFormatter alloc] init];

	fmtr4Num.generatesDecimalNumbers = TRUE;//Use decimal points

	[fmtr4Num setNumberStyle:NSNumberFormatterDecimalStyle];//What type is received

	NSNumber *fTheNumber = [fmtr4Num numberFromString:strNumber];
	
	if(fTheNumber == nil)//If the string wasn't a proper numeric string
		fTheNumber = [NSNumber numberWithFloat:0.0];

	return fTheNumber;
}//End

@end