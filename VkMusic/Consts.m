//
//  Consts.m
//  VkMusic
//
//  Created by keepcoder on 31.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "Consts.h"

@implementation Consts
NSInteger const DEFAULT_CELL_SIZE = 60;
NSString * const FONT_BOLD = @"Helvetica-Bold";
NSString * const FONT_REGULAR = @"Helvetica-Regular";

+(BOOL)access {
    NSArray *access = @[@"RU",@"FI",@"UA",@"AZ",@"AM",@"BY",@"BE",@"KZ",@"UK"];
    return [access indexOfObject:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]] != NSNotFound;

   // return  [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"RU"] == YES || [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"UA"] == YES || [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"FI"] == YES;
}
@end
