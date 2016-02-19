// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Emails.h instead.

#import <CoreData/CoreData.h>


extern const struct EmailsAttributes {
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *name;
} EmailsAttributes;

extern const struct EmailsRelationships {
} EmailsRelationships;

extern const struct EmailsFetchedProperties {
} EmailsFetchedProperties;





@interface EmailsID : NSManagedObjectID {}
@end

@interface _Emails : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (EmailsID*)objectID;




@property (nonatomic, strong) NSString* email;


//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;






@end

@interface _Emails (CoreDataGeneratedAccessors)

@end

@interface _Emails (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




@end
