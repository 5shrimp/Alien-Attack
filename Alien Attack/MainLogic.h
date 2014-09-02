//
//  MainLogic.h
//  Alien Attack
//
//  Created by 5shrimp on 21.08.14.
//  Copyright (c) 2014 S&L. All rights reserved.
//

#import <UIKit/UIKit.h>

int gunMovement;

float gunBeamMovement;
int gunBeamsOnScreen;

int aliensKilled;
int alienMovement;

//sort of constraint for gun. awfull
int shift;

float difficulty;

NSMutableArray *allAliens;
NSMutableArray *aliveAliens;
NSMutableArray *readyForStrikeAliens;


@interface MainLogic : UIViewController

{
    
    IBOutlet UIButton *start;
    IBOutlet UIButton *quit;
    IBOutlet UIButton *fire;
    
    IBOutlet UIImageView *gun;
    IBOutlet UIImageView *gunBeam;

    IBOutletCollection(UIImageView) NSArray *alienImages;
    IBOutletCollection(UIImageView) NSArray *alienBeamImages;
    
    IBOutlet UILabel *gameResult;
    IBOutlet UILabel *frags;
    
    IBOutlet UILabel *tip1;
    IBOutlet UILabel *tip2;
    
    NSTimer *movementTimer;
    
}


- (IBAction)start:(id)sender;
- (IBAction)fire:(id)sender;

- (void)movement;
- (void)hit;
- (void)gameOver;

- (void)alienDeath;
- (void)alienMovedDown;
- (void)alienAttack;

@end
