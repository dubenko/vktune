//
//  URLParser.h
//  VkMusic
//
//  Created by keepcoder on 19.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLParser : NSObject


@property (nonatomic,strong) NSMutableDictionary *variables;
- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForVariable:(NSString *)varName;
@end
