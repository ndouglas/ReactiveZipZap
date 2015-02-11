//
//  ZZArchiveEntry+ReactiveZipZap.h
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RZZDefinitions.h"

@interface ZZArchiveEntry (ReactiveZipZap)

/**
 An archive entry with a specified filename, compression flag, and stream block.
 
 @param fileName The name for this archive entry.
 @param compress Whether the archive entry should be compressed.
 @param streamBlock A block used to write entry data to a stream.
 @return A signal containing the archive entry, or an error if one occurred.
 */

+ (RACSignal *)rzz_archiveEntryWithFileName:(NSString *)fileName compress:(BOOL)compress streamBlock:(BOOL(^)(NSOutputStream* stream, NSError** error))streamBlock;

/**
 An archive entry with a specified filename, compression flag, and data block.
 
 @param fileName The name for this archive entry.
 @param compress Whether the archive entry should be compressed.
 @param dataBlock A block that will generate data for the archive entry.
 @return A signal containing the archive entry, or an error if one occurred.
 */

+ (RACSignal *)rzz_archiveEntryWithFileName:(NSString *)fileName compress:(BOOL)compress dataBlock:(NSData *(^)(NSError** error))dataBlock;

/**
 An archive entry with a specified filename, compression flag, and data consumer block.
 
 @param fileName The name for this archive entry.
 @param compress Whether the archive entry should be compressed.
 @param dataConsumerBlock A block that passes the entry file to the data consumer.
 @return A signal containing the archive entry, or an error if one occurred.
 */

+ (RACSignal *)rzz_archiveEntryWithFileName:(NSString *)fileName compress:(BOOL)compress dataConsumerBlock:(BOOL(^)(CGDataConsumerRef dataConsumer, NSError** error))dataConsumerBlock;

/**
 An archive entry for a directory entry.
 
 @param directoryName The name for this archive entry.
 @return A signal containing the archive entry, or an error if one occurred.
 */

+ (RACSignal *)rzz_archiveEntryWithDirectoryName:(NSString *)directoryName;

/**
 An archive entry with explicit settings.
 
 @param fileName The name for this archive entry.
 @param fileMode The UNIX file mode and file type.
 @param lastModified The last modified datetime for the entry.
 @param compressionLevel The compression level.
 @param dataBlock A block that writes entry file data.
 @param streamBlock A block that writes the entry file to the stream.
 @param dataConsumerBlock A block that passes the entry file to the data consumer.
 @return A signal containing the archive entry, or an error if one occurred.
 */

+ (RACSignal *)rzz_archiveEntryWithFileName:(NSString*)fileName fileMode:(mode_t)fileMode lastModified:(NSDate*)lastModified compressionLevel:(NSInteger)compressionLevel dataBlock:(NSData*(^)(NSError** error))dataBlock streamBlock:(BOOL(^)(NSOutputStream* stream, NSError** error))streamBlock dataConsumerBlock:(BOOL(^)(CGDataConsumerRef dataConsumer, NSError** error))dataConsumerBlock;

/**
 An archive entry for data.
 
 @param name The name of the data.
 @param data The data.
 @return A signal containing the archive entry, or an error if one occurred.
 */

+ (RACSignal *)rzz_archiveEntryWithName:(NSString *)name data:(NSData *)data;

/**
 An archive entry for a file (not directory) at a URL.
 
 @param URL The URL of the item to archive.
 @return A signal containing the archive entry, or an error if one occurred.
 @discussion No extended attributes.
 */

+ (RACSignal *)rzz_archiveEntryOfFileAtURL:(NSURL *)URL;

/**
 An archive entry for a directory at a URL.
 
 @param URL The URL of the item to archive.
 @return A signal containing the archive entry, or an error if one occurred.
 @discussion No extended attributes.
 */

+ (RACSignal *)rzz_archiveEntryOfDirectoryAtURL:(NSURL *)URL;

/**
 An archive entry for the extended attributes of the item at a URL.
 
 @param URL The URL of the item whose extended atributes should be archived.
 @return A signal containing the archive entry, or an error if one occurred.
 */

+ (RACSignal *)rzz_archiveEntryOfExtendedAttributesAtURL:(NSURL *)URL;

/**
 Archive entries for the file (not directory) at a URL and, optionally, its extended attributes.
 
 @param URL The URL of the file to archive.
 @param includeExtendedAttributes Whether the file's extended attributes should be preserved.
 @return A signal containing the archive entries, or an error if one occurred.
 */

+ (RACSignal *)rzz_archiveEntriesOfFileAtURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes;

/**
 Archive entries for the directory at a URL and, optionally, its extended attributes.
 
 @param URL The URL of the directory to archive.
 @param includeExtendedAttributes Whether the directory's extended attributes should be preserved.
 @return A signal containing the archive entries, or an error if one occurred.
 @discussion Does not include the directory contents.
 */

+ (RACSignal *)rzz_archiveEntriesOfDirectoryAtURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes;

/**
 Archive entries for the contents of the directory at a URL and, optionally, its contents' extended attributes.
 
 @param URL The URL of the directory whose contents should be archived.
 @param includeExtendedAttributes Whether the directory's contents' extended attributes should be preserved.
 @return A signal containing the archive entries, or an error if one occurred.
 @discussion Does not include the directory entry itself.
 */

+ (RACSignal *)rzz_archiveEntriesOfDirectoryContentsAtURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes;

/**
 Archive entries for the item at a URL and, optionally, its extended attributes.
 
 @param URL The URL of the item to archive.
 @param includeExtendedAttributes Whether the item's extended attributes should be preserved.
 @return A signal containing the archive entries, or an error if one occurred.
 @discussion Includes directory contents.
 */

+ (RACSignal *)rzz_archiveEntriesOfItemAtURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes;

/**
 Archive entries for the items at some URLs and, optionally, their extended attributes.
 
 @param URLs The URLs of the items to archive.
 @param includeExtendedAttributes Whether the items' extended attributes should be preserved.
 @return A signal containing the archive entries, or an error if one occurred.
 @discussion Includes directory contents.
 */

+ (RACSignal *)rzz_archiveEntriesOfItemsAtURLs:(NSArray *)URLs includeExtendedAttributes:(BOOL)includeExtendedAttributes;

/**
 Writes the entry to a data object and returns it.
 
 @return A signal that returns a data object or returns an error if one occurred.
 */

- (RACSignal *)rzz_data;

/**
 Writes the entry to the URL.
 
 @param URL The destination URL.
 @return A signal that completes or returns an error if one occurred.
 */

- (RACSignal *)rzz_writeToURL:(NSURL *)URL;

/**
 Writes the entry as extended attributes to the item at the URL.
 
 @param URL The destination URL.
 @return A signal that completes or returns an error if one occurred.
 */

- (RACSignal *)rzz_writeAsExtendedAttributesToURL:(NSURL *)URL;

@end
