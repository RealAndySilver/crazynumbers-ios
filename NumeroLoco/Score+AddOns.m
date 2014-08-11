//
//  Score+AddOns.m
//  NumeroLoco
//
//  Created by Developer on 5/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "Score+AddOns.h"

@implementation Score (AddOns)

+(Score *)scoreWithIdentifier:(NSNumber *)identifier type:(NSString *)type value:(NSNumber *)value
       inManagedObjectContext:(NSManagedObjectContext *)context {
    
    Score *score = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Score"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@ && type = %@", identifier, type];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1) {
        NSLog(@"Error obteniendo la entidad 'Score'");
        //Error retrieving entity
        
    } else if ([matches count]) {
        NSLog(@"El Score ya existía");
        //The entity already existed
        score = [matches firstObject];
        if ([value intValue] > [score.value intValue]) {
            score.value = value;
            NSLog(@"Reemplazé el valor del puntaje porque el usuario lo superó");
        } else {
            NSLog(@"No reemplazé el valor del puntaje porque el usuario no lo superó");
        }
    } else {
        //The score did not exist on CoreData
        NSLog(@"El Score no existía");
        score = [NSEntityDescription insertNewObjectForEntityForName:@"Score" inManagedObjectContext:context];
        score.value = value;
        score.type = type;
        score.identifier = identifier;
    }
    
    return score;
}

+(Score *)getScoreWithType:(NSString *)type identifier:(NSNumber *)identifier inManagedObjectContext:(NSManagedObjectContext *)context {
    Score *score = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Score"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@ && type = %@", identifier, type];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1) {
        //Error
    } else if ([matches count]) {
        score = [matches firstObject];
    }
    
    return score;
}

+(NSUInteger)getTotalScoreInContext:(NSManagedObjectContext *)context {
    NSUInteger totalScore = 0;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Score"];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error) {
        //Error
    } else {
        for (int i = 0; i < [matches count]; i++) {
            Score *score = matches[i];
            totalScore += [score.value intValue];
        }
    }
    
    return totalScore;
}

+(NSArray *)getAllScoresWithType:(NSString *)type inManagedObjectContext:(NSManagedObjectContext *)context {
    NSSortDescriptor *sortDescritor = [[NSSortDescriptor alloc] initWithKey:@"identifier" ascending:YES];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Score"];
    request.predicate = [NSPredicate predicateWithFormat:@"type == %@", type];
    request.sortDescriptors = @[sortDescritor];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error) {
        //Error
        return nil;
    } else {
        return matches;
    }
    
    
}

@end
