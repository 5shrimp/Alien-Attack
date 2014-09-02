//
//  MainLogic.m
//  Alien Attack
//
//  Created by 5shrimp on 21.08.14.
//  Copyright (c) 2014 S&L. All rights reserved.
//

#import "MainLogic.h"
#import "Aliens.h"


@interface MainLogic ()

@end

@implementation MainLogic


/** Some things to do after your death,
 * such as hide averything before you quit the game.
 */
- (void)gameOver
{
    gameResult.hidden = NO;
    gameResult.text = [NSString stringWithFormat:@"You lose!"];
    
    frags.hidden = NO;
    frags.text = [NSString stringWithFormat:@"But you've killed %d aliens! Good job.", aliensKilled];
    
    for (Aliens *alien in allAliens) {
        alien.alienImage.hidden = YES;
        alien.alienBeamImage.hidden = YES;
    }
    
    gun.hidden = YES;
    gunBeam.hidden = YES;
    
    fire.hidden = YES;
    quit.hidden = NO;
    [movementTimer invalidate];
}

/** Here is the method, where evil aliens, those who survived the player attack,
 * get recharged and ready for strike him back with some amount of beams. Over and over again..
 */
- (void)alienAttack
{
    for (Aliens *alien in allAliens) {
        if (alien.alienIsKilled == NO) {
            [aliveAliens addObject:alien];
        }
    }
    
    int chargedAliensCount = 0;
    if ([aliveAliens count] > 0) {
    chargedAliensCount = arc4random() % ([aliveAliens count]) + 1;
    } else {
        [self alienDeath];
    }
    
    for (int charge = 0; charge < chargedAliensCount; charge ++) {
        [readyForStrikeAliens addObject:[aliveAliens objectAtIndex:arc4random() % [aliveAliens count]]];
    }

    for (Aliens *alien in readyForStrikeAliens) {
        //! make free alien supervise gunBeam + less alienfire frequency (and even less on 3.5-inch display)
        if (arc4random()%(88 + shift/10) == 1 && alien.supervisesBeam == NO) {
            
        // make readyAliens own Beams - to control Beams flow
            alien.supervisesBeam = YES;
            
        alien.alienBeamImage.center = CGPointMake(alien.alienImage.center.x, alien.alienImage.center.y + 30);
        alien.alienBeamImage.hidden = NO;
        
        ///! Simple animation of alien hands
        
        UIImage *handsNormal = alien.alienImage.image;
        UIImage *handsUp = [UIImage imageNamed: @"alphaAlienHands.png"];
        NSArray* arr = @[handsUp, handsNormal];
        UIImageView* iv = alien.alienImage;
        
        iv.animationImages = arr;
        iv.animationDuration = 0.45;
        iv.animationRepeatCount = 1;
        [iv startAnimating];
        
        /// end of animation
            
        } else {
            continue;
        }
    }
    
    //aand wash our hands..
    [readyForStrikeAliens removeAllObjects];
    [aliveAliens removeAllObjects];
}

- (void)alienMovedDown
{
    for (Aliens *alien in allAliens) {
        alien.alienImage.center = CGPointMake(alien.alienImage.center.x, alien.alienImage.center.y + 3.5 * difficulty);
    }
}

/** The several checks of objects collision, like what if alien or their beams hit the player's gun,
 * or how to animate the blinking colvunsions before the death of wounded by gunlaser-beam alien.
 */
- (void)hit
{
    for (Aliens *alien in allAliens) {
        //
        if ((CGRectIntersectsRect(alien.alienBeamImage.frame, gun.frame) && alien.alienBeamImage.hidden == NO) ||
            (CGRectIntersectsRect(alien.alienImage.frame, gun.frame) && alien.alienIsKilled == NO)) {
            [self gameOver];
        }
        
        //
        if (CGRectContainsPoint(alien.alienImage.frame, gunBeam.center) && alien.alienIsKilled == NO && gunBeam.hidden == NO) {
            //if (CGRectContainsRect(alien.alienImage.frame, gunBeam.frame) && alien.alienIsKilled == NO && gunBeam.hidden == NO) {
            alien.alienIsKilled = YES;
            
            /// ! Animation of blinking alien
            
            UIImage *green = alien.alienImage.image;
            UIImage *empty = [UIImage imageNamed: @"alphaAlienEmpty.png"];
            NSArray* arr = @[empty, green, empty, green];
            UIImageView* iv = alien.alienImage;
            
            iv.animationImages = arr;
            iv.animationDuration = 0.8;
            iv.animationRepeatCount = 1;
            [iv startAnimating];
            
            /// ! alien has to be Hidden - after animation
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, iv.animationDuration * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                alien.alienImage.hidden = YES;
            });
            
            [self alienDeath];
        }
        
        // and Do not forget about 2 beams collisions
        if (CGRectIntersectsRect(alien.alienBeamImage.frame, gunBeam.frame) && alien.alienBeamImage.hidden == NO) {
            gunBeamMovement = 0;
            gunBeam.hidden = YES;
            gunBeamsOnScreen = 0;
            
            alien.alienBeamImage.hidden = YES;
            alien.supervisesBeam = NO;
        }
    }
}

/** What's going on when alien got killed by a man? frags count increment of course!
 * Increase the difficulty (smoothly) to make the game more interesting.
 * And if everybody green got killed, make the player a winner and congratulations.
 */
- (void)alienDeath
{
    aliensKilled = aliensKilled + 1;
    
    difficulty = difficulty + 0.15;
    
    gunBeamsOnScreen = 0;
    gunBeam.hidden = YES;
    gunBeamMovement = 0;
    gunBeam.center = CGPointMake(200, 545 - shift);
    
    if (aliensKilled == 8) {
        gameResult.hidden = NO;
        gameResult.text = [NSString stringWithFormat:@"You win!"];
        //
        frags.hidden = NO;
        frags.text = [NSString stringWithFormat:@"Your skills are impressive."];
        
        gun.hidden = YES;
        fire.hidden = YES;
        quit.hidden = NO;
        
        for (Aliens *alien in allAliens) {
            alien.alienBeamImage.hidden = YES;
        }
        [movementTimer invalidate];
    }
}

/** If you pressed the fire button,
 * and a laser beam went off the screen, another one got triggered.
 */
- (IBAction)fire:(id)sender
{
    if (gunBeamsOnScreen == 0) {
        gunBeam.hidden = NO;
        gunBeam.center = CGPointMake(gun.center.x, gun.center.y - 30 - shift);
        gunBeamsOnScreen = gunBeamsOnScreen + 1;
        gunBeamMovement = 4.2;
    }
}

/** You can move the gun left or right
 * by touching the left or right half of screen respectively.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    if (point.x < 160 && gun.center.x > 45) {
        gunMovement = -7;
    } else if (gun.center.x < 275) {
        gunMovement = 7;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    gunMovement = 0;
}

/** Every time the Timer we've started works - the gun and its beam, aliens and their beams
 * have to be checked for being alive and moved correctly. And do not forget to attack.
 */
- (void) movement
{
    [self hit];
    
    gun.center = CGPointMake(gun.center.x + gunMovement, gun.center.y);
    gunBeam.center = CGPointMake(gunBeam.center.x, gunBeam.center.y - gunBeamMovement);
    
    if (gun.center.x > 275 || gun.center.x < 45) {
        gunMovement = 0;
    }
    
    for (Aliens *alien in allAliens) {
        
        // aliens themselves
        if (alien.alienImage.center.x < 20 && alien.alienIsKilled == NO) {
            alienMovement = 1.5;
            [self alienMovedDown];
        }
        else if (alien.alienImage.center.x > 300 && alien.alienIsKilled == NO) {
            alienMovement = -1.5;
            [self alienMovedDown];
        }
        
        alien.alienImage.center = CGPointMake(alien.alienImage.center.x + alienMovement * difficulty, alien.alienImage.center.y);
        
        // alien Beams
        if (alien.alienBeamImage.center.y > 575 - shift) {
            alien.alienBeamImage.hidden = YES;
            
            // we must give some rest for Alien - superviser of Alien gunBeam
            alien.supervisesBeam = NO;
        }
        
        // to hide the start Alien Beams
        if ( alien.alienBeamImage.center.y < 25) {
            alien.alienBeamImage.hidden = YES;
        }

        if (alien.supervisesBeam == YES)
        //at first alienBeamIamge velocity was 4.9, but everybody told me it was too difficult to play..
        alien.alienBeamImage.center = CGPointMake(alien.alienBeamImage.center.x, alien.alienBeamImage.center.y + 2.39);
    }
 
    // alien atack loop
    
    [self alienAttack];
    
    // off-screen gunBeam hide
    
    if (gunBeam.center.y < 10) {
        gunBeam.hidden = YES;
        gunBeamsOnScreen = 0;
        gunBeamMovement = 0;
    }
}

/** When the player hits start, every button (except fire) have to be hidden, alien swarm arrives.
 * And timer gets started, too.
 */
- (IBAction)start:(id)sender
{
    fire.center = CGPointMake(fire.center.x, fire.center.y - shift);
    
    start.hidden = YES;
    quit.hidden = YES;
    tip1.hidden = YES;
    tip2.hidden = YES;
    fire.hidden = NO;
    
    gunBeamsOnScreen = 0;
    
    gun.center = CGPointMake(gun.center.x, gun.center.y - shift);
    
    for (Aliens *alien in allAliens) {
        alien.alienImage.hidden = NO;
    }
    
    movementTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(movement) userInfo:nil repeats:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/** When the player hits the Play button, everything must be prepared for the game:
 * congratulation final labels, fire button, gun and alien Images - be hidden, alien swarm array - be created.
 */
- (void)viewDidLoad
{
    // this is awful, but works, lol
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        shift = 0;
    } else {
        // code for 3.5-inch screen. to lift up the gun and stuff
        shift = 71;
    }
    
    gunBeam.hidden = YES;
    fire.hidden = YES;
    
    allAliens = [NSMutableArray new];
    aliveAliens = [NSMutableArray new];
    readyForStrikeAliens = [NSMutableArray new];
    
    for (UIImageView *alienImage in alienImages) {
        Aliens *alien = [Aliens new];
        alien.alienImage = alienImage;
        alien.alienImage.hidden = YES;
        alien.alienIsKilled = NO;
        
        /// every alien potentially has his own energy beam
        alien.alienBeamImage = [alienBeamImages objectAtIndex:[alienImages indexOfObject:alienImage]];
        alien.alienBeamImage.hidden = YES;
        
        //! - this leaves aliens without their beams as yet
        alien.supervisesBeam = NO;
        
        [allAliens addObject:alien];
    }
    
    alienMovement = 5;
    aliensKilled = 0;

    difficulty = 1;
    
    gameResult.hidden = YES;
    frags.hidden = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
