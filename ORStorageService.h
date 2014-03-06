//
//  ORStorageService.h
//  Temporary CoreData
//
//  Basado en http://locassa.com/temporary-storage-in-apples-coredata/
//  y adaptado por Orlando Alemán Ortiz, 2012
//

#import "ORDomainObject.h"


#pragma mark - Constant Definitions


/*!
 @brief 
    Permite trabajar con objetos CoreData temporales de manera más flexible. Es una clase Singleton

 @example
     ORStorageService *storage = [ORStorageService sharedInstance];
     NSManagedObjectContext *context = [storage contextForIdentifier:@"CoreData"];
     ￼*object = NEW_ENTITY(￼LODomainObjectSubclass, context);
     [context save:NULL];
     
 */

@interface ORStorageService : NSObject

#pragma mark - Singleton

/// Da acceso al objeto LOStorage único
+ (ORStorageService *)sharedInstance;


#pragma mark - General methods

- (NSManagedObjectContext *)contextForIdentifier:(NSString *)identifier;
- (NSManagedObjectContext *)contextForIdentifier:(NSString *)identifier copyFromAppBundle:(BOOL)copyFromAppBundle;
- (NSManagedObjectContext *)contextForIdentifier:(NSString *)identifier copyFromAppBundle:(BOOL)copyFromAppBundle storeType:(NSString *)storeType;


#pragma mark - keyed Subscript

- (NSManagedObjectContext *)objectForKeyedSubscript:(NSString *)identifier;

@end
