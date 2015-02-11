//
//  NSURL+ReactiveZipZap.h
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RZZDefinitions.h"

@interface NSURL (ReactiveZipZap)

/**
 The URL for the target of this extended attribute file URL.
 */

@property (copy, nonatomic, readonly) NSURL *rzz_extendedAttributeTargetURL;

/**
 The last path component for an extended attributes file.
 */

@property (copy, nonatomic, readonly) NSString *rzz_extendedAttributeLastPathComponent;

/**
 The path for an extended attributes file.
 */

@property (copy, nonatomic, readonly) NSString *rzz_extendedAttributePath;

/**
 The URL for an extended attributes file.
 */

@property (copy, nonatomic, readonly) NSURL *rzz_extendedAttributeURL;

/**
 Cleans the directory where temporary URLs are generated.
 
 @param error An error object populated in the event of failure.
 @return YES if the operation succeeded, otherwise NO.
 @discussion Obviously, this removes every item currently at that location.
 */

+ (BOOL)rzz_cleanTemporaryAreaOrError:(NSError **)error;

/**
 Cleans the directory where temporary URLs are generated.
 
 @param date A date indicating how old the temporary items are that should be kept.
 @param error An error object populated in the event of failure.
 @return YES if the operation succeeded, otherwise NO.
 @discussion Obviously, this removes every item currently at that location.
 */

+ (BOOL)rzz_cleanTemporaryAreaOfItemsOlderThanDate:(NSDate *)date error:(NSError **)error;

/**
 A URL to a temporary directory.
 
 
 @return A signal passing a URL.
 */

+ (RACSignal *)rzz_temporaryURL;

/**
 A URL to a temporary directory that is created and then deleted when the subscription is disposed.
 
 
 @return A signal passing a URL that will be deleted when the subscription is disposed of.
 */

+ (RACSignal *)rzz_ephemeralURL;

/**
 Fetches the names of the extended attributes.
 
 @param error An error object populated in the event of failure.
 */

- (NSArray *)rzz_namesOfExtendedAttributesWithError:(NSError **)error;

/**
 Sets the extended attribute with the specified name to the specified value.
 
 @param value The value to set for the extended attribute.
 @param name The name of the extended attribute.
 @param error An error object populated in the event of failure.
*/

- (BOOL)rzz_setValue:(NSData *)_value forExtendedAttributeWithName:(NSString *)name error:(NSError **)error;

/**
 Fetches the value for the extended attribute with the specified name.
 
 @param name The name of the extended attribute.
 @param error An error object populated in the event of failure.
 @return A data value.
 */

- (NSData *)rzz_valueForExtendedAttributeWithName:(NSString *)name error:(NSError **)error;

/**
 Removes the extended attribute with the specified name.
 
 @param name The name of the extended attribute.
 @param error An error object populated in the event of failure.
 */

- (BOOL)rzz_removeExtendedAttributeWithName:(NSString *)name error:(NSError **)error;

/**
 Retrieves the dictionary of extended attributes with names and values.
 
 @param error An error object populated in the event of failure.
 */

- (NSDictionary *)rzz_dictionaryWithExtendedAttributesOrError:(NSError **)error;

/**
 Retrieves the dictionary of extended attributes with names and values.
 
 @param dictionary A dictionary of extended attribute names and values.
 @param error An error object populated in the event of failure.
 */

- (BOOL)rzz_setExtendedAttributesWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;

@end

