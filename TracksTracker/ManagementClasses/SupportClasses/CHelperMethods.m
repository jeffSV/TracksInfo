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

+(UIViewController *)retreiveSplitViewDispalayController:(UISplitViewController *)svc
{
	if( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) || (svc == nil) )
		return nil;//The iPhone will not implement a split view controller
	
	UIViewController *vc;

	for(NSObject *obj in svc.viewControllers)
	{
		//Based on Apple's documentation regarding a UISplitViewController's viewcontrollers array:
		//"The array in this property must contain exactly two view controllers."
		//ie: One is a table view controller and the other is a display viewcontroller.
		if ( (obj != [NSNull null]) && ([obj isKindOfClass:[UINavigationController class]] == FALSE) )
		{
			NSLog(@"%@", [obj class]);
			vc = (UIViewController *)obj;
			break;
		}
	}//End

	return vc;
}//End


@end