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

@end
