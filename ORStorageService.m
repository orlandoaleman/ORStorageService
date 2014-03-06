//
//  OrStorageService.m
//  Temporary CoreData
//

#import "ORStorageService.h"


#pragma mark - Interfaces

@interface ORStorageService () {}

@property (nonatomic) NSMutableDictionary *contexts;
@end



@implementation ORStorageService


#pragma mark - Singleton

static ORStorageService *_sharedInstance = nil;


+ (void)initialize
{
    /*
       PATRÓN SINGLETON:
       http://stackoverflow.com/questions/145154/what-does-your-objective-c-singleton-look-like
     */

    static BOOL initialized = NO;

    if (!initialized) {
        initialized = YES;
        _sharedInstance = [[ORStorageService alloc] init];
    }
}


+ (ORStorageService *)sharedInstance
{
    return _sharedInstance;
}


- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    _contexts = [NSMutableDictionary dictionary];
    
    return self;
}


#pragma mark - General methods


- (NSManagedObjectContext *)contextForIdentifier:(NSString *)identifier
{
    return [self contextForIdentifier:identifier copyFromAppBundle:YES];
}


- (NSManagedObjectContext *)contextForIdentifier:(NSString *)identifier copyFromAppBundle:(BOOL)copyFromAppBundle
{
    return [self contextForIdentifier:identifier copyFromAppBundle:YES storeType:NSSQLiteStoreType];
}


- (NSManagedObjectContext *)contextForIdentifier:(NSString *)identifier copyFromAppBundle:(BOOL)copyFromAppBundle storeType:(NSString *)storeType
{
    NSManagedObjectContext *context = self.contexts[identifier];
    if (context) return context;
    
    context = [self createContextForIdentifier:identifier copyFromAppBundle:copyFromAppBundle storeType:storeType];
    if (context) self.contexts[identifier] = context;
    
    return context;
}


- (NSManagedObjectContext *)createContextForIdentifier:(NSString *)identifier copyFromAppBundle:(BOOL)copyFromAppBundle storeType:(NSString *)storeType
{
    NSPersistentStoreCoordinator *coodinator = [self createCoodinatorForIdentifier:identifier copyFromAppBundle:copyFromAppBundle storeType:storeType];
    if (coodinator) {
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:coodinator];
        return context;
    }
    return nil;
}


- (NSManagedObjectModel *)modelForIdentifier:(NSString *)identifier
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:identifier withExtension:@"momd"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}


- (NSPersistentStoreCoordinator *)createCoodinatorForIdentifier:(NSString *)identifier copyFromAppBundle:(BOOL)copyFromAppBundle storeType:(NSString *)storeType
{
    NSError *error = nil;
    NSURL *storeURL = nil;
    NSDictionary *options = nil;
    
    if (copyFromAppBundle) {
        storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[identifier stringByAppendingPathExtension:@"sqlite"]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:[storeURL path]]) {
            NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource:identifier withExtension:@"sqlite"];
            [fileManager copyItemAtURL:defaultStoreURL toURL:storeURL error:&error];
            if (error) {
                NSLog(@"Error: %@", error.description);
                return nil;
            }
        }
        options = @{ NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES };
        
    }
    else {
        storeURL = [[NSBundle mainBundle] URLForResource:identifier withExtension:@"sqlite"];
        options = @{ NSReadOnlyPersistentStoreOption: @YES};
    }
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self modelForIdentifier:identifier]];
    
    if (![coordinator addPersistentStoreWithType:storeType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return coordinator;
}


#pragma mark - keyed Subscript

- (NSManagedObjectContext *)objectForKeyedSubscript:(NSString *)identifier
{
    return [self contextForIdentifier:identifier];
}


#pragma mark - CoreData stack

- (void)saveAll
{
    NSError *error = nil;
    for (NSManagedObjectContext *context in self.contexts) {
        if (![context save:&error]) {
            [self logNSError:error];
        }
    }
}


#pragma mark - Other Helper Methods

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)logNSError:(NSError *)error
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
