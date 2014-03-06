//
//  LODomainObject.m
//  Temporary CoreData
//

#import "ORDomainObject.h"
#import "ORStorageService.h"


@implementation ORDomainObject


+ (NSString *)entityName
{
    return CLASS_STRING(self);
}


+ (id)tempEntityForContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    return [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil];
}


- (void)addToContext:(NSManagedObjectContext *)context
{
    [context insertObject:self];
}


+ (NSArray *)allObjectsOfType:(Class)class inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(class)
                                              inManagedObjectContext:context];

    [request setEntity:entity];

    NSError *error = nil;
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];

    if (error != nil) {
        NSLog(@"There was an error retrieving all objects of type: %@, %@", NSStringFromClass(class), [error localizedDescription]);
        [ORDomainObject logNSError:error];
        return nil;
    }

    return fetchResults;
}


+ (void)logNSError:(NSError *)error
{
    NSLog(@"%@", [error userInfo]);
    
    if ([error userInfo][@"NSDetailedErrors"]) {
        for (NSError *errorItem in [error userInfo][@"NSDetailedErrors"]) {
            for (NSString *key in [errorItem userInfo]) {
                NSLog(@"%@ - %@", key, [errorItem userInfo][key]);
            }
        }
    }
}


@end
