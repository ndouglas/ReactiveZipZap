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

@end
