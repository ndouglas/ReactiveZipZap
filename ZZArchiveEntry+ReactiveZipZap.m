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

+ (RACSignal *)rzz_archiveEntryWithName:(NSString *)name data:(NSData *)data {
    return [[self rzz_archiveEntryWithFileName:name compress:YES dataBlock:^NSData *(NSError *__autoreleasing *error) {
            return data;
        }]
        setNameWithFormat:@"[%@ +zz_archiveEntryWithName: %@ data: %@]", self, name, data];
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

+ (RACSignal *)rzz_archiveEntryOfExtendedAttributesAtURL:(NSURL *)URL {
    return [[self rzz_archiveEntryWithFileName:[RZZXattrFilenamePrefix stringByAppendingString:URL.lastPathComponent] compress:YES dataBlock:^NSData *(NSError *__autoreleasing *error) {
            return [NSKeyedArchiver archivedDataWithRootObject:[URL rzz_dictionaryWithExtendedAttributesOrError:error]];
        }]
        setNameWithFormat:@"[%@ +zz_archiveEntryOfFileAtURL: %@]", self, URL];
}

+ (RACSignal *)rzz_archiveEntriesOfFileAtURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes {
    return [[[self rzz_archiveEntryOfFileAtURL:URL]
        concat:includeExtendedAttributes ? [self rzz_archiveEntryOfExtendedAttributesAtURL:URL] : [RACSignal empty]]
        setNameWithFormat:@"[%@ +zz_archiveEntryOfFileAtURL: %@ includeExtendedAttributes: %@]", self, URL, @(includeExtendedAttributes)];
}

+ (RACSignal *)rzz_archiveEntriesOfDirectoryAtURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes {
    return [[[self rzz_archiveEntryOfDirectoryAtURL:URL]
        concat:includeExtendedAttributes ? [self rzz_archiveEntryOfExtendedAttributesAtURL:URL] : [RACSignal empty]]
        setNameWithFormat:@"[%@ +zz_archiveEntryOfDirectoryAtURL: %@ includeExtendedAttributes: %@]", self, URL, @(includeExtendedAttributes)];
}

+ (RACSignal *)rzz_archiveEntriesOfDirectoryContentsAtURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes {
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:URL includingPropertiesForKeys:nil options:0 error:&error];
    RACSignal *result = nil;
    if (contents) {
        result = [contents.rac_sequence.signal
            flattenMap:^RACSignal *(NSURL *contentURL) {
                return [self rzz_archiveEntriesOfItemAtURL:contentURL includeExtendedAttributes:includeExtendedAttributes];
            }];
    } else {
        result = [RACSignal error:error];
    }
    return [result setNameWithFormat:@"[%@ +zz_archiveEntriesOfDirectoryContentsAtURL: %@ includeExtendedAttributes: %@]", self, URL, @(includeExtendedAttributes)];
}

+ (RACSignal *)rzz_archiveEntriesOfItemAtURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory;
    RACSignal *result = nil;
	if ([fileManager fileExistsAtPath:URL.path isDirectory:&isDirectory]) {
		if (isDirectory) {
            result = [[self rzz_archiveEntriesOfDirectoryAtURL:URL includeExtendedAttributes:includeExtendedAttributes]
                concat:[self rzz_archiveEntriesOfDirectoryContentsAtURL:URL includeExtendedAttributes:includeExtendedAttributes]];
		} else {
            result = [self rzz_archiveEntriesOfFileAtURL:URL includeExtendedAttributes:includeExtendedAttributes];
		}
	} else {
        result = [RACSignal empty];
    }
    return [result setNameWithFormat:@"[%@ +zz_archiveEntriesOfItemAtURL: %@ includeExtendedAttributes: %@]", self, URL, @(includeExtendedAttributes)];
}

+ (RACSignal *)rzz_archiveEntriesOfItemsAtURLs:(NSArray *)URLs includeExtendedAttributes:(BOOL)includeExtendedAttributes {
	RACSignal *result = [URLs.rac_sequence.signal
        flattenMap:^RACSignal *(NSURL *URL) {
            return [self rzz_archiveEntriesOfItemAtURL:URL includeExtendedAttributes:includeExtendedAttributes];
        }];
    return [result setNameWithFormat:@"[%@ +zz_archiveEntriesOfItemsAtURLs: %@ includeExtendedAttributes: %@]", self, URLs, @(includeExtendedAttributes)];
}

- (RACSignal *)rzz_writeToURL:(NSURL *)URL {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        if (self.fileMode & S_IFDIR) {
            if (![fileManager createDirectoryAtURL:URL withIntermediateDirectories:YES attributes:nil error:&error]) {
                [subscriber sendError:error];
            }
        } else {
            NSData *data;
            if (![fileManager createDirectoryAtURL:URL.URLByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:&error] || !(data = [self newDataWithError:&error]) || ![data writeToURL:URL atomically:YES]) {
                [subscriber sendError:error];
            }
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ +zz_writeToURL: %@]", self, URL];
}

- (RACSignal *)rzz_writeAsExtendedAttributesToURL:(NSURL *)URL {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        NSData *data = [self newDataWithError:&error];
        NSURL *targetURL = URL.rzz_extendedAttributeTargetURL;
        NSDictionary *dictionary = nil;
        if (!data || !(dictionary = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data]) || [targetURL rzz_setExtendedAttributesWithDictionary:dictionary error:&error]) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ +zz_writeToURL: %@]", self, URL];
}

@end
