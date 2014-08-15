//
//  DetectorViewController.h
//  WTMGlyphDemo
//
//  Created by Prateek Pradhan on 03/01/14.
//  Copyright (c) 2014 torin.nguyen@2359media.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTMGlyphDetectorView.h"

@interface DetectorViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet WTMGlyphDetectorView *detectorView;
@property (strong, nonatomic) IBOutlet UILabel *resultLabel;
@property (strong, nonatomic) IBOutlet UITableView *leftColumnTable;
@property (strong, nonatomic) IBOutlet UITextField *outputTextField;
@property (strong, nonatomic) IBOutlet UIButton *detectButton;
@property (strong, nonatomic) IBOutlet UITextField *clearButton;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong) IBOutlet UIActivityIndicatorView *loadingIndicator;
-(IBAction)detectButtonPressed:(id)sender;
-(IBAction)clearButtonPressed:(id)sender;
@property NSArray *results;

@end
