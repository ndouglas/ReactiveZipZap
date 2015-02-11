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
 An archive entry for a file (not directory) at a URL.
 
 @param URL The URL of the item to archive.
 @return A signal containing the archive entry, or an error if one occurred.
 @discussion No extended attributes.
 */

+ (RACSignal *)rzz_archiveEntryOfFileAtURL:(NSURL *)URL;


@end
