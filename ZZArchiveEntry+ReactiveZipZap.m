//
//  ZZArchiveEntry+ReactiveZipZap.m
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "ZZArchiveEntry+ReactiveZipZap.h"
#import "ReactiveZipZap.h"

@implementation ZZArchiveEntry (ReactiveZipZap)

+ (RACSignal *)rzz_archiveEntryWithFileName:(NSString *)fileName compress:(BOOL)compress streamBlock:(BOOL(^)(NSOutputStream* stream, NSError** error))streamBlock {
    return [[RACSignal return:[self archiveEntryWithFileName:fileName compress:compress streamBlock:streamBlock]]
        setNameWithFormat:@"[%@ zz_archiveEntryWithFileName: %@ compress: %@ streamBlock: %@]", self, fileName, @(compress), streamBlock];
}

+ (RACSignal *)rzz_archiveEntryWithFileName:(NSString *)fileName compress:(BOOL)compress dataBlock:(NSData *(^)(NSError** error))dataBlock {
    return [[RACSignal return:[self archiveEntryWithFileName:fileName compress:compress dataBlock:dataBlock]]
        setNameWithFormat:@"[%@ zz_archiveEntryWithFileName: %@ compress: %@ dataBlock: %@]", self, fileName, @(compress), dataBlock];
}


@end
