//
//  ZZArchive+ReactiveZipZap.h
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RZZDefinitions.h"

@interface ZZArchive (ReactiveZipZap)

/**
 The archive at the specified URL, if it exists.
 
 @param URL The URL at which the archive should be found.
 @return A signal passing an initialized instance of the class.
 */

+ (RACSignal *)rzz_archiveAtURL:(NSURL *)URL;

/**
 The archive at the specified URL, creating it if it does not already exist.
 
 @param URL The URL at which the archive should be found.
 @return A signal passing an initialized instance of the class.
 */

+ (RACSignal *)rzz_newArchiveAtURL:(NSURL *)URL;

/**
 A new archive at a temporary location.
 
 @return A signal passing an initialized instance of the class.
 */

+ (RACSignal *)rzz_temporaryArchive;

/**
 A new archive at a temporary location.
 
 @return A signal passing an initialized instance of the class.
 @discussion The archive and its containing location will be deleted when the subscription is disposed.
 */

+ (RACSignal *)rzz_ephemeralArchive;

@end
