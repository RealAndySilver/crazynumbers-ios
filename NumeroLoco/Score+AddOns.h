//
//  Score+AddOns.h
//  NumeroLoco
//
//  Created by Developer on 5/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "Score.h"

@interface Score (AddOns)
+(Score *)scoreWithIdentifier:(NSNumber *)identifier
                         type:(NSString *)type
                        value:(NSNumber *)value
       inManagedObjectContext:(NSManagedObjectContext *)context;
+(Score *)getScoreWithType:(NSString *)type identifier:(NSNumber *)identifier inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSUInteger)getTotalScoreInContext:(NSManagedObjectContext *)context;
@end
