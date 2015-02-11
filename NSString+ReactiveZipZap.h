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
 A path to a temporary directory.
 
 
 @return A signal passing a path.
 */

+ (RACSignal *)rzz_temporaryPath;

/**
 A path to a temporary directory that is created and then deleted when the subscription is disposed.
 
 
 @return A signal passing a path that will be deleted when the subscription is disposed of.
 */

+ (RACSignal *)rzz_ephemeralPath;

@end
