//
//  WTMGlyphStroke.m
//  WTMGlyph
//
//  Created by Brit Gardner on 5/14/11.
//  Copyright 2011 Warrior Thief Mage Studios. All rights reserved.
//

#import "WTMGlyphStroke.h"


@implementation WTMGlyphStroke
@synthesize points;



- (id)initWithPoints:(NSArray *)_points {
    if ((self = [super init])) {
        self.points = [NSMutableArray arrayWithArray:_points];
    }
    return self;
}

- (void)addPoint:(CGPoint)point {
    if (!self.points)
        self.points = [NSMutableArray array];
    
    [self.points addObject:[NSValue valueWithCGPoint:point]];
}

-(NSMutableArray *)getArraryRepresentation{
    NSMutableArray *strokePoints = [[NSMutableArray alloc] init];
    for (NSValue *pointObject in self.points) {
        CGPoint point = [pointObject CGPointValue];
        NSArray *tempArr = [NSArray arrayWithObjects:[NSNumber numberWithInt:point.x],[NSNumber numberWithInt:point.y ], nil];
        [strokePoints addObject:tempArr];
    }
    return strokePoints;
}

@end
