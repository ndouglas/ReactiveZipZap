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

/**
 Creates a temporary archive with the contents of the URL.
 
 @param URL The URL of the item that should be archived.
 @param includeExtendedAttributes Whether or not extended attributes should be retrieved and packaged along with the original file.
 @return A signal with a value pointing to an archive.
 */

+ (RACSignal *)rzz_temporaryArchiveWithContentsOfURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes;

/**
 Creates an ephemeral archive with the contents of the URL.
 
 @param URL The URL of the item that should be archived.
 @param includeExtendedAttributes Whether or not extended attributes should be retrieved and packaged along with the original file.
 @return A signal with a value pointing to an archive.
 @discussion The archive will automatically be deleted when the subscription is disposed.
 */

+ (RACSignal *)rzz_ephemeralArchiveWithContentsOfURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes;

/**
 Writes out the archive's entries to the specified URL.
 
 @param URL The URL that will contain the written file(s).  Must be a directory.
 @return A signal that completes when the entries are written, or returns an error if one occurred.
 */

- (RACSignal *)rzz_unarchiveToURL:(NSURL *)URL;

/**
 Writes out the archive's entries to a temporary URL.
 
 @return A signal that completes when the entries are written, or returns an error if one occurred.
 */

- (RACSignal *)rzz_unarchiveToTemporaryURL;

@end
