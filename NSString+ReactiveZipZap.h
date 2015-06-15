//
//  NSString+ReactiveZipZap.h
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RZZDefinitions.h"

@interface NSString (ReactiveZipZap)

/**
 The last path component for an extended attributes target.
 */

@property (copy, nonatomic, readonly) NSString *rzz_extendedAttributeTargetLastPathComponent;

/**
 The path for an extended attributes target.
 */

@property (copy, nonatomic, readonly) NSString *rzz_extendedAttributeTargetPath;

/**
 The last path component for an extended attributes file.
 */

@property (copy, nonatomic, readonly) NSString *rzz_extendedAttributeLastPathComponent;

/**
 The path for an extended attributes file.
 */

@property (copy, nonatomic, readonly) NSString *rzz_extendedAttributePath;

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
 Cleans the directory where temporary URLs are generated.
 
 @param date A date indicating how old the temporary items are that should be kept.
 @return A signal listing deleted items or errors if any occurred.
 @discussion Obviously, this removes every item currently at that location.
 */

+ (RACSignal *)rzz_cleanTemporaryAreaOfItemsOlderThanDate:(NSDate *)date;

/**
 A path to a temporary directory.
 
 @param error An error object populated in the event of failure.
 @return A path to a temporary directory.
 @discussion It is the caller's responsibility to remove the directory.
 */

+ (NSString *)rzz_temporaryPathOrError:(NSError **)error;

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
