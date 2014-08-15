//
//  WTMGlyphDetectorView.m
//  WTMGlyphDemo
//
//  Created by Torin Nguyen on 5/7/12.
//  Copyright (c) 2012 torin.nguyen@2359media.com. All rights reserved.
//

#import "WTMGlyphDetectorView.h"
#import "CJSONSerialization.h"
#import "CJSONDeserializer.h"

@interface WTMGlyphDetectorView() <WTMGlyphDelegate>
@property (nonatomic, strong) NSMutableArray *glyphNamesArray;
@property (nonatomic, strong) UIBezierPath *myPath;
@property (nonatomic, strong) NSMutableArray *strokes;
@property (strong) NSMutableArray *lastDrawnStorkes;
@property (nonatomic,strong) NSMutableArray *stokePoints;
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation WTMGlyphDetectorView
@synthesize delegate;
@synthesize myPath;
@synthesize enableDrawing;
@synthesize glyphDetector;
@synthesize glyphNamesArray;

-(id)init{
    self = [super init];
    if (self) {
        [self initGestureDetector];
        
        //self.backgroundColor = [UIColor clearColor];
        self.enableDrawing = YES;
        
        self.myPath = [[UIBezierPath alloc]init];
        self.myPath.lineCapStyle = kCGLineCapRound;
        self.myPath.miterLimit = 0;
        self.myPath.lineWidth = 10;
        self.strokes =[[NSMutableArray alloc] init];
        self.stokePoints =[[NSMutableArray alloc] init];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [self init];
    if(self){
        
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      [self initGestureDetector];
      
      self.backgroundColor = [UIColor clearColor];
      self.enableDrawing = YES;
      
      self.myPath = [[UIBezierPath alloc]init];
      self.myPath.lineCapStyle = kCGLineCapRound;
      self.myPath.miterLimit = 0;
      self.myPath.lineWidth = 10;
        self.strokes =[[NSMutableArray alloc] init];
        self.stokePoints =[[NSMutableArray alloc] init];
    }
    return self;
}

- (void)initGestureDetector
{
  self.glyphDetector = [WTMGlyphDetector detector];
  self.glyphDetector.delegate = self;
  self.glyphDetector.timeoutSeconds = 1;
  
  if (self.glyphNamesArray == nil)
    self.glyphNamesArray = [[NSMutableArray alloc] init];
}

-(void)setDisableAutoDetection:(BOOL)value{
    _disableAutoDetection = value;
    if(_disableAutoDetection){
        [self.timer invalidate];
        self.timer =nil;
    }else{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
    }
    
}
-(void )fireTimer:(NSTimer *)timer{
    if(!self.disableAutoDetection) {
        BOOL hasTimeOut = [self.glyphDetector hasTimedOut];
        if (hasTimeOut && !self.glyphDetector.detectionInProgress) {
            [self detectGlyph];
        }
    }
   
}
-(void)detectGlyph{
    
    [self.glyphDetector detectGlyph];

}
#pragma mark - Public interfaces

- (NSString *)getGlyphNamesString
{
  if (self.glyphNamesArray == nil || [self.glyphNamesArray count] <= 0)
    return @"";
  
    NSArray *sortedArray = [self.glyphNamesArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    ;
   
  return [sortedArray componentsJoinedByString: @", "];
}

- (void)loadTemplatesWithNames:(NSString*)firstTemplate, ... 
{
  va_list args;
  va_start(args, firstTemplate);
  for (NSString *glyphName = firstTemplate; glyphName != nil; glyphName = va_arg(args, id))
  {
    if (![glyphName isKindOfClass:[NSString class]])
      continue;
    
    [self.glyphNamesArray addObject:glyphName];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:glyphName ofType:@"json"]];
    [self.glyphDetector addGlyphFromJSON:jsonData name:glyphName];
  }
  va_end(args);
}
-(void)loadAvailableTemplates{
    
    NSError* error1 = nil;
    
    
    NSURL *documentDirPathURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                   inDomains:NSUserDomainMask] lastObject];
    NSString *documentDirPath = documentDirPathURL.path;
    NSString *filePath = [documentDirPath stringByAppendingString:@"/FontLibrary.json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Check if the database has already been created in the users filesystem
    if (![fileManager fileExistsAtPath:filePath]){
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"FontLibrary.json"];
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath
                                                toPath:filePath
                                                 error:&error1];
        
    }
    if(!error1){
        NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        
        NSError *error = nil;
        NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
        for (NSString *glyphName in dict) {
            [self.glyphNamesArray addObject:glyphName];
            NSArray *arr = [dict objectForKey:glyphName];
            if(arr){
                
                [self.glyphDetector addGlyphForDetails:arr name:glyphName];
            }
        }
    }

}




#pragma mark - WTMGlyphDelegate

- (void)glyphDetected:(WTMGlyph *)glyph withScore:(float)score
{
   // [self performSelector:@selector(clearDrawingIfTimeout) withObject:nil afterDelay:1.0f];
    [self clearDrawingIfTimeout];
  //Simply forward it to my parent
  if ([self.delegate respondsToSelector:@selector(wtmGlyphDetectorView:glyphDetected:withScore:)])
    [self.delegate wtmGlyphDetectorView:self glyphDetected:glyph withScore:score];
  
}

- (void)glyphResults:(NSArray *)results{
  //Raw results from the library?
  //Not sure what this delegate function is for, undocumented
    if([self.delegate respondsToSelector:@selector(glyphResults:)]){
        [self.delegate glyphResults:results];
    }
}



#pragma mark - Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!self.strokes.count){
        //Make last drawn nil since a new character is started for drawing.
        self.lastDrawnStorkes = nil;
        if([self.delegate respondsToSelector:@selector(characterBeganToDrawn)]){
            [self.delegate characterBeganToDrawn];
        }

    }
  //This is basically the content of resetIfTimeout
  BOOL hasTimeOut = [self.glyphDetector hasTimedOut];
  if (hasTimeOut) {
    NSLog(@"Gesture detector reset");
    [self.glyphDetector reset];
    
    if (self.enableDrawing) {
      [self.myPath removeAllPoints];
      //This is not recommended for production, but it's ok here since we don't have a lot to draw
      [self setNeedsDisplay];
    }
  }
  
  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];
  [self.glyphDetector addPoint:point];
   //Stroke Points
   self.stokePoints =[[NSMutableArray alloc] init];
   NSArray *pointArr = [NSArray arrayWithObjects:[NSNumber numberWithFloat:floorf(point.x) ],[NSNumber numberWithFloat:floorf(point.y)], nil];
    [self.stokePoints addObject:pointArr];
  
    [super touchesBegan:touches withEvent:event];
  
  if (!self.enableDrawing)
    return;
  
  [self.myPath moveToPoint:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];
  [self.glyphDetector addPoint:point];
  
  [super touchesMoved:touches withEvent:event];
  
  if (!self.enableDrawing)
    return;
  
  [self.myPath addLineToPoint:point];
    NSArray *pointArr = [NSArray arrayWithObjects:[NSNumber numberWithFloat:floorf(point.x) ],[NSNumber numberWithFloat:floorf(point.y)], nil];
    [self.stokePoints addObject:pointArr];
  
  //This is not recommended for production, but it's ok here since we don't have a lot to draw
  [self setNeedsDisplay];
}
- (NSString *)JSONRepresentation :(NSArray *)array{
    NSError *error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:&error];
    if (!error) {
        NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return result;
    }
    return nil;
}
-(void)logStrokes{
    
    NSLog(@"Stroke Array%@---->",[self JSONRepresentation:self.strokes]);
    
  
    
    //[self.strokes removeAllObjects];
    [self.myPath removeAllPoints];
    //This is not recommended for production, but it's ok here since we don't have a lot to draw
    [self setNeedsDisplay];
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];
  [self.glyphDetector addPoint:point];
    
  
    
    NSArray *pointArr = [NSArray arrayWithObjects:[NSNumber numberWithFloat:floorf(point.x) ],[NSNumber numberWithFloat:floorf(point.y)], nil];
    [self.stokePoints addObject:pointArr];
    [self.strokes addObject:self.stokePoints];
    self.stokePoints = nil;
  [super touchesEnded:touches withEvent:event]; 
}


- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  
  if (!self.enableDrawing)
    return;
  
  [[UIColor whiteColor] setStroke];
  [self.myPath strokeWithBlendMode:kCGBlendModeNormal alpha:0.5];
}

- (void)clearDrawingIfTimeout
{
   // return;
  if (!self.enableDrawing)
    return;

//    if (!self.disableAutoDetection) {
//        BOOL hasTimeOut = [self.glyphDetector hasTimedOut];
//        if (!hasTimeOut)
//            return;
//    }
 
  
  [self.myPath removeAllPoints];
  [self.glyphDetector removeAllPoints];
  self.lastDrawnStorkes = [NSMutableArray arrayWithArray:self.strokes];
  [self.strokes removeAllObjects];
    
  
  //This is not recommended for production, but it's ok here since we don't have a lot to draw
  [self setNeedsDisplay];
}
-(void)updateCurrentContextGlyphWithName:(NSString *)name{
    [self.glyphDetector addGlyphForInfo:self.lastDrawnStorkes name:name];
    
}



@end
