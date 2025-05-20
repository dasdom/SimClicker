//  Created by Dominik Hauser on 19.05.25.
//  
//


#import "NSArray+Extension.h"

@implementation NSArray (Extension)
- (NSArray *)shuffled {
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self count]];

    for (id anObject in self) {
        NSUInteger randomPos = arc4random()%([tmpArray count]+1);
        [tmpArray insertObject:anObject atIndex:randomPos];
    }

    return [tmpArray copy];
}
@end
