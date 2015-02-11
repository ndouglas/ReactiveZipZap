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

+ (RACSignal *)rzz_archiveEntryWithFileName:(NSString *)fileName compress:(BOOL)compress dataConsumerBlock:(BOOL(^)(CGDataConsumerRef dataConsumer, NSError** error))dataConsumerBlock {
    return [[RACSignal return:[self archiveEntryWithFileName:fileName compress:compress dataConsumerBlock:dataConsumerBlock]]
        setNameWithFormat:@"[%@ zz_archiveEntryWithFileName: %@ compress: %@ dataConsumerBlock: %@]", self, fileName, @(compress), dataConsumerBlock];
}

+ (RACSignal *)rzz_archiveEntryWithDirectoryName:(NSString *)directoryName {
    return [[RACSignal return:[self archiveEntryWithDirectoryName:directoryName]]
        setNameWithFormat:@"[%@ zz_archiveEntryWithDirectoryName: %@]", self, directoryName];
}

+ (RACSignal *)rzz_archiveEntryWithFileName:(NSString*)fileName fileMode:(mode_t)fileMode lastModified:(NSDate*)lastModified compressionLevel:(NSInteger)compressionLevel dataBlock:(NSData*(^)(NSError** error))dataBlock streamBlock:(BOOL(^)(NSOutputStream* stream, NSError** error))streamBlock dataConsumerBlock:(BOOL(^)(CGDataConsumerRef dataConsumer, NSError** error))dataConsumerBlock {
    return [[RACSignal return:[self archiveEntryWithFileName:fileName fileMode:fileMode lastModified:lastModified compressionLevel:compressionLevel dataBlock:dataBlock streamBlock:streamBlock dataConsumerBlock:dataConsumerBlock]]
        setNameWithFormat:@"[%@ zz_archiveEntryWithFileName: %@ fileMode: %@ lastModified: %@ compressionLevel: %@ dataBlock: %@ streamBlock: %@ dataConsumerBlock %@]", self, fileName, @(fileMode), lastModified, @(compressionLevel), dataBlock, streamBlock, dataConsumerBlock];
    
}

+ (RACSignal *)rzz_archiveEntryOfFileAtURL:(NSURL *)URL {
    return [[self rzz_archiveEntryWithFileName:URL.lastPathComponent compress:YES dataBlock:^NSData *(NSError *__autoreleasing *error) {
            return [NSData dataWithContentsOfFile:URL.path options:NSDataReadingMappedIfSafe error:error];
        }]
        setNameWithFormat:@"[%@ +zz_archiveEntryOfFileAtURL: %@]", self, URL];
}

+ (RACSignal *)rzz_archiveEntryOfDirectoryAtURL:(NSURL *)URL {
    return [[self rzz_archiveEntryWithDirectoryName:URL.lastPathComponent]
        setNameWithFormat:@"[%@ +zz_archiveEntryOfDirectoryAtURL: %@]", self, URL];
}


@end
