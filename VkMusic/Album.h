//
//  Album.h
//  VkMusic
//
//  Created by keepcoder on 11.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Album : NSManagedObject

@property (nonatomic, retain) NSNumber * owner_id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * album_id;

@end
