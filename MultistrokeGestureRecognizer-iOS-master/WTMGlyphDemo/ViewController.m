//
//  ViewController.m
//  WTMGlyphDemo
//
//  Created by Torin Nguyen on 5/7/12.
//  Copyright (c) 2012 torin.nguyen@2359media.com. All rights reserved.
//

#define GESTURE_SCORE_THRESHOLD         0.7f

#import "ViewController.h"
#import "WTMGlyphDetectorView.h"

@interface ViewController ()
@property (nonatomic, strong) WTMGlyphDetectorView *gestureDetectorView;
@property (nonatomic, strong) IBOutlet UILabel *lblStatus;
@end

@implementation ViewController
@synthesize gestureDetectorView;
@synthesize lblStatus;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.gestureDetectorView = [[WTMGlyphDetectorView alloc] initWithFrame:self.view.bounds];
    self.gestureDetectorView.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-100);
    self.gestureDetectorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.gestureDetectorView.delegate = self;
  [self.gestureDetectorView loadTemplatesWithNames:@"R",@"B",@"N", @"T", @"W", @"V", @"circle", @"square", @"triangle",@"D",@"P",@"A",@"HindKA",@"pa", nil];
  [self.view addSubview:self.gestureDetectorView];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  NSString *glyphNames = [self.gestureDetectorView getGlyphNamesString];
  if ([glyphNames length] > 0) {
    NSString *statusText = [NSString stringWithFormat:@"Loaded with %@ templates.\n\nStart drawing. ", [self.gestureDetectorView getGlyphNamesString]];
    self.lblStatus.text = [NSString stringWithFormat:@"String with  हिन्दी unicode %C%C", (unichar)0x092A,(unichar)0x093E];//statusText;
      
    
  }
}

- (void)viewDidUnload
{
  [self.gestureDetectorView removeFromSuperview];
  self.gestureDetectorView.delegate = nil;
  self.gestureDetectorView = nil;
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

-(IBAction)showStrokes:(id)sender{
    [self.gestureDetectorView logStrokes];
    
}
#pragma mark - Delegate

- (void)wtmGlyphDetectorView:(WTMGlyphDetectorView*)theView glyphDetected:(WTMGlyph *)glyph withScore:(float)score
{
  //Reject detection when quality too low
  //More info: http://britg.com/2011/07/17/complex-gesture-recognition-understanding-the-score/
  if (score < GESTURE_SCORE_THRESHOLD)
    return;
  
  NSString *statusString = @"";
  
  NSString *glyphNames = [self.gestureDetectorView getGlyphNamesString];
  if ([glyphNames length] > 0)
    statusString = [statusString stringByAppendingFormat:@"Loaded with %@ templates.\n\n", glyphNames];
  
    NSString *name = glyph.name;
    if([name isEqualToString:@"HindKA"]){
        name = [NSString stringWithFormat:@"%C", (unichar)0x0915];
    }else if ([name isEqualToString:@"pa"]){
        name = [NSString stringWithFormat:@"%C", (unichar)0x092A];
    }
  statusString = [statusString stringByAppendingFormat:@"Last gesture detected: %@\nScore: %.3f", name, score];
  
  self.lblStatus.text = statusString;
}


@end
