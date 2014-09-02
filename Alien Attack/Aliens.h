//
//  Aliens.h
//  Alien Attack
//
//  Created by 5shrimp on 22.08.14.
//  Copyright (c) 2014 S&L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Aliens : NSObject

@property (nonatomic) UIImageView * alienImage;
@property (nonatomic) BOOL alienIsKilled;

@property (nonatomic) UIImageView * alienBeamImage;
@property (nonatomic) BOOL supervisesBeam;

@end
