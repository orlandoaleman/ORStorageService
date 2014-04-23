//
//  ORDomainObject
//  Temporary CoreData
//

#ifndef ORDOMAINOBJECT_UTILS
#define ORDOMAINOBJECT_UTILS

#define CLASS_STRING(x) NSStringFromClass ([x class])

#define NEW_ENTITY(CLASS, CONTEXT) [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CLASS class]) inManagedObjectContext:CONTEXT]

#endif


#import <CoreData/CoreData.h>

@interface ORDomainObject : NSManagedObject { }

/// Retorna el nombre del objeto
+ (NSString *)entityName;

/// Devuelve una instancia de la entidad sin un contexto asignado
+ (id)tempEntityForContext:(NSManagedObjectContext *)context;

/// Retorna todos los objectos de la clase en el contexto
+ (NSArray *)allObjectsOfType:(Class)class inManagedObjectContext:(NSManagedObjectContext *)context;

/// Añade la instancia de entidad al contexto indicado
- (void)addToContext:(NSManagedObjectContext *)context;

@end

