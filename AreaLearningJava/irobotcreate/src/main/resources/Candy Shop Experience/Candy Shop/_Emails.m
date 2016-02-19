// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Emails.m instead.

#import "_Emails.h"

const struct EmailsAttributes EmailsAttributes = {
	.email = @"email",
	.name = @"name",
};

const struct EmailsRelationships EmailsRelationships = {
};

const struct EmailsFetchedProperties EmailsFetchedProperties = {
};

@implementation EmailsID
@end

@implementation _Emails

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Emails" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Emails";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Emails" inManagedObjectContext:moc_];
}

- (EmailsID*)objectID {
	return (EmailsID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic email;






@dynamic name;











@end
