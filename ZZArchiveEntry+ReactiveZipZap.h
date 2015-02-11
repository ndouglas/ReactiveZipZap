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


@end
