//
//  DetectorViewController.m
//  WTMGlyphDemo
//
//  Created by Prateek Pradhan on 03/01/14.
//  Copyright (c) 2014 torin.nguyen@2359media.com. All rights reserved.
//

#import "DetectorViewController.h"
#import "OverviewViewController.h"
#define GESTURE_SCORE_THRESHOLD         1.5f

@interface DetectorViewController () <WTMGlyphDelegate>

@property (strong) OverviewViewController *overviewController;
@end

@implementation DetectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Auto Detect : OFF" style:UIBarButtonItemStyleBordered target:self action:@selector(autoDetectButtonClicked:)];
    item.tag = 1;
    self.navigationItem.leftBarButtonItem = item;
    
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export Gestures" style:UIBarButtonItemStyleBordered target:self action:@selector(exportButtonClicked:)];
    self.navigationItem.rightBarButtonItem = exportButton;
    
    self.detectorView.delegate = self;
    self.detectorView.frame = CGRectMake(0, 0, 587, 856);
    self.detectorView.disableAutoDetection = YES;
    self.detectorView.glyphDetector.timeoutSeconds = 10;
    self.detectButton.enabled = YES;
    
    self.detectorView.backgroundColor = [UIColor darkGrayColor];
    // Do any additional setup after loading the view from its nib.
//    [self.detectorView loadTemplatesWithNames:@"A",@"V",@"P",@"T",@"B", nil];
    [self.detectorView bringSubviewToFront:self.loadingIndicator];
    [self loadTemplates];
    self.outputTextField.text = @"";
    self.overviewController = [[OverviewViewController alloc] init];
    
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Overview" style:UIBarButtonItemStylePlain target:self action:@selector(showOverview:)];
//    UINavigationController *overviewNav = [[UINavigationController alloc] initWithRootViewController:self.overviewController];
//    [self.navigationController presentViewController:overviewNav animated:YES completion:nil];
    
//    [self.navigationController pushViewController:self.overviewController animated:YES];
    
}
-(void)exportButtonClicked:(id)sender{
    [self.detectorView.glyphDetector exportAllGlyphs];
}
-(void)showOverview:(id)sender{
    
    [self.navigationController pushViewController:self.overviewController animated:YES];

}
-(void)loadTemplates{
    [self.loadingIndicator startAnimating];
    self.infoLabel.text = @"Loading Templates...";
    __weak DetectorViewController *weakSelf = self;
    dispatch_queue_t backgroundQueue = dispatch_queue_create("loadDictionay", 0);
    
    dispatch_async(backgroundQueue, ^{
        [weakSelf.detectorView loadAvailableTemplates];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateInfoLabel];
            [weakSelf.loadingIndicator stopAnimating];

        });
    });
    
    

}
-(void)autoDetectButtonClicked:(UIBarButtonItem *)sender{
    if(sender.tag == 1){
        sender.title =@"Auto Detect : ON";
        sender.tag = 2;
        self.detectorView.disableAutoDetection = NO;
        self.detectorView.glyphDetector.timeoutSeconds = 1.0;
        self.detectButton.enabled = NO;
        
    }else{
        sender.title =@"Auto Detect : OFF";
         sender.tag = 1;
        self.detectorView.disableAutoDetection = YES;
        self.detectorView.glyphDetector.timeoutSeconds = 10;
        self.detectButton.enabled = YES;
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateInfoLabel];
   
}
-(void)updateInfoLabel{
    
    NSString *glyphNames = [self.detectorView getGlyphNamesString];
    
    
    if ([glyphNames length] > 0) {
        NSString *statusText = [NSString stringWithFormat:@"   Loaded with %@ templates.\n\nStart drawing. ", glyphNames];
        self.infoLabel.text = statusText;
    }
}
#pragma mark START WTMGlyphDetectorViewDelegate Methods
- (void)characterBeganToDrawn{
    self.results =nil;
    [self.leftColumnTable reloadData];
}

- (void)wtmGlyphDetectorView:(WTMGlyphDetectorView*)theView glyphDetected:(WTMGlyph *)glyph withScore:(float)score
{
    //Reject detection when quality too low
    if (score < GESTURE_SCORE_THRESHOLD){
        self.resultLabel.text = @"   No Match Found";
        return;
    }
    self.resultLabel.text  = [NSString stringWithFormat:@"   Gesture Detected:%@ score %.3f",glyph.name,score];
    self.outputTextField.text = [NSString stringWithFormat:@"%@%@",self.outputTextField.text,glyph.name];
   
}
- (void)glyphResults:(NSArray *)results{
    
    NSMutableArray *newArray =[[NSMutableArray alloc] init];
    NSMutableDictionary *keys = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dict in results) {
        NSString *name = [dict objectForKey:@"name"];
        if([keys objectForKey:name]){
            continue;
        }
        [newArray addObject:dict];
        [keys setObject:dict forKey:name];
    }
    
    NSArray *newArr = newArray.count > 5?[newArray subarrayWithRange:NSMakeRange(0, 5)]:newArray;
    
    self.results = newArr;
    [self.leftColumnTable reloadData];
}
#pragma mark EDN WTMGlyphDetectorViewDelegate Methods

-(IBAction)detectButtonPressed:(id)sender{
    self.resultLabel.text =@"Detecting...";
    [self.detectorView logStrokes];
    [self.detectorView detectGlyph];
    
}
-(IBAction)clearButtonPressed:(id)sender{
    self.outputTextField.text = @"";
    [self.detectorView clearDrawingIfTimeout];
    self.results =nil;
    [self.leftColumnTable reloadData];
}
#pragma mark START tableViewDelegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.results.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row < self.results.count ){
        NSDictionary *result =[self.results objectAtIndex:indexPath.row];
        UITableViewCell *cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSNumber *score = [result objectForKey:@"score"];
        cell.textLabel.text = [NSString stringWithFormat:@"Name:%@ Score:%.3f ",[result objectForKey:@"name"],[score floatValue]];
        return cell;
    }else{
        UITableViewCell *cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *cellString = @"Start Drawing on Canvas";
        if(self.results.count){
                cellString = @"Any Other";
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@",cellString];
        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row < self.results.count ){
       
        NSDictionary *result =[self.results objectAtIndex:indexPath.row];
        NSString *name = [result objectForKey:@"name"];
        if(name && ![name isEqualToString:@""]){
            self.resultLabel.text = [NSString stringWithFormat: @"Updating template for %@",name];
            [self.detectorView updateCurrentContextGlyphWithName:name];
            self.results =nil;
            [self.leftColumnTable reloadData];
            self.resultLabel.text = [NSString stringWithFormat: @"Updated template for %@",name];
            if(self.outputTextField.text.length){
                
               self.outputTextField.text =  [self.outputTextField.text stringByReplacingCharactersInRange:NSMakeRange(self.outputTextField.text.length-1, 1) withString:name];
            }else{
                self.outputTextField.text = name;
            }
           
            
        }
    
    }else{
        if(self.results.count){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Enter Character Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done",nil];
            alert.alertViewStyle =  UIAlertViewStylePlainTextInput;
            [alert show];
        }
        
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Results";
}
#pragma mark END tableViewDelegate Methods

-(BOOL)shouldAutorotate{
    return NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return NO;
}

#pragma mark START alertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex != 0){
        UITextField *textField =  [alertView textFieldAtIndex:0];
        NSString *name = textField.text;
        if(name && ![name isEqualToString:@""]){
            self.resultLabel.text = [NSString stringWithFormat: @"Updating template for %@",name];
            [self.detectorView updateCurrentContextGlyphWithName:name];
            self.results =nil;
            [self.leftColumnTable reloadData];
            self.resultLabel.text = [NSString stringWithFormat: @"Updated template for %@",name];
            if(self.outputTextField.text.length){
               
                self.outputTextField.text = [self.outputTextField.text stringByReplacingCharactersInRange:NSMakeRange(self.outputTextField.text.length-1, 1) withString:name];
            }else{
                self.outputTextField.text = name;
            }
        }

    }
    
}
#pragma mark END alertViewDelegate Methods


@end
