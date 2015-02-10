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
