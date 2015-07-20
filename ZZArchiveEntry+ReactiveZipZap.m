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
        setNameWithFormat:@"[%@ rzz_archiveEntryWithFileName: %@ compress: %@ streamBlock: %@]", self, fileName, @(compress), streamBlock];
}

+ (RACSignal *)rzz_archiveEntryWithFileName:(NSString *)fileName compress:(BOOL)compress dataBlock:(NSData *(^)(NSError** error))dataBlock {
    return [[RACSignal return:[self archiveEntryWithFileName:fileName compress:compress dataBlock:dataBlock]]
        setNameWithFormat:@"[%@ rzz_archiveEntryWithFileName: %@ compress: %@ dataBlock: %@]", self, fileName, @(compress), dataBlock];
}

+ (RACSignal *)rzz_archiveEntryWithFileName:(NSString *)fileName compress:(BOOL)compress dataConsumerBlock:(BOOL(^)(CGDataConsumerRef dataConsumer, NSError** error))dataConsumerBlock {
    return [[RACSignal return:[self archiveEntryWithFileName:fileName compress:compress dataConsumerBlock:dataConsumerBlock]]
        setNameWithFormat:@"[%@ rzz_archiveEntryWithFileName: %@ compress: %@ dataConsumerBlock: %@]", self, fileName, @(compress), dataConsumerBlock];
}

+ (RACSignal *)rzz_archiveEntryWithDirectoryName:(NSString *)directoryName {
    return [[RACSignal return:[self archiveEntryWithDirectoryName:directoryName]]
        setNameWithFormat:@"[%@ rzz_archiveEntryWithDirectoryName: %@]", self, directoryName];
}

+ (RACSignal *)rzz_archiveEntryWithFileName:(NSString*)fileName fileMode:(mode_t)fileMode lastModified:(NSDate*)lastModified compressionLevel:(NSInteger)compressionLevel dataBlock:(NSData*(^)(NSError** error))dataBlock streamBlock:(BOOL(^)(NSOutputStream* stream, NSError** error))streamBlock dataConsumerBlock:(BOOL(^)(CGDataConsumerRef dataConsumer, NSError** error))dataConsumerBlock {
    return [[RACSignal return:[self archiveEntryWithFileName:fileName fileMode:fileMode lastModified:lastModified compressionLevel:compressionLevel dataBlock:dataBlock streamBlock:streamBlock dataConsumerBlock:dataConsumerBlock]]
        setNameWithFormat:@"[%@ rzz_archiveEntryWithFileName: %@ fileMode: %@ lastModified: %@ compressionLevel: %@ dataBlock: %@ streamBlock: %@ dataConsumerBlock %@]", self, fileName, @(fileMode), lastModified, @(compressionLevel), dataBlock, streamBlock, dataConsumerBlock];
    
}

NSString *RZZRelativePathFromBaseURLToURL(NSURL *baseURL, NSURL *URL) {
    return [URL.path stringByReplacingOccurrencesOfString:baseURL.path withString:@""];
}

+ (RACSignal *)rzz_archiveEntryWithName:(NSString *)name data:(NSData *)data {
    return [[self rzz_archiveEntryWithFileName:name compress:YES dataBlock:^NSData *(NSError *__autoreleasing *error) {
            return data;
        }]
        setNameWithFormat:@"[%@ +rzz_archiveEntryWithName: %@ data: %@]", self, name, data];
}

+ (RACSignal *)rzz_archiveEntryOfFileAtURL:(NSURL *)URL relativeToURL:(NSURL *)baseURL {
    return [[self rzz_archiveEntryWithFileName:RZZRelativePathFromBaseURLToURL(baseURL, URL) compress:YES dataBlock:^NSData *(NSError *__autoreleasing *error) {
            return [NSData dataWithContentsOfFile:URL.path options:NSDataReadingMappedIfSafe error:error];
        }]
        setNameWithFormat:@"[%@ +rzz_archiveEntryOfFileAtURL: %@]", self, URL];
}

+ (RACSignal *)rzz_archiveEntryOfDirectoryAtURL:(NSURL *)URL relativeToURL:(NSURL *)baseURL {
    return [[self rzz_archiveEntryWithDirectoryName:[RZZRelativePathFromBaseURLToURL(baseURL, URL) stringByAppendingString:@"/"]]
        setNameWithFormat:@"[%@ +rzz_archiveEntryOfDirectoryAtURL: %@]", self, URL];
}

+ (RACSignal *)rzz_archiveEntryOfExtendedAttributesAtURL:(NSURL *)URL relativeToURL:(NSURL *)baseURL {
    return [[self rzz_archiveEntryWithFileName:RZZRelativePathFromBaseURLToURL(baseURL, URL).rzz_extendedAttributePath compress:YES dataBlock:^NSData *(NSError *__autoreleasing *error) {
            return [NSKeyedArchiver archivedDataWithRootObject:[URL rzz_dictionaryWithExtendedAttributesOrError:error]];
        }]
        setNameWithFormat:@"[%@ +rzz_archiveEntryOfFileAtURL: %@]", self, URL];
}

+ (RACSignal *)rzz_archiveEntriesOfFileAtURL:(NSURL *)URL relativeToURL:(NSURL *)baseURL includeExtendedAttributes:(BOOL)includeExtendedAttributes {
    return [[[self rzz_archiveEntryOfFileAtURL:URL relativeToURL:baseURL]
        concat:includeExtendedAttributes ? [self rzz_archiveEntryOfExtendedAttributesAtURL:URL relativeToURL:baseURL] : [RACSignal empty]]
        setNameWithFormat:@"[%@ +rzz_archiveEntryOfFileAtURL: %@ includeExtendedAttributes: %@]", self, URL, @(includeExtendedAttributes)];
}

+ (RACSignal *)rzz_archiveEntriesOfDirectoryAtURL:(NSURL *)URL relativeToURL:(NSURL *)baseURL includeExtendedAttributes:(BOOL)includeExtendedAttributes {
    return [[[self rzz_archiveEntryOfDirectoryAtURL:URL relativeToURL:baseURL]
        concat:includeExtendedAttributes ? [self rzz_archiveEntryOfExtendedAttributesAtURL:URL relativeToURL:baseURL] : [RACSignal empty]]
        setNameWithFormat:@"[%@ +rzz_archiveEntryOfDirectoryAtURL: %@ includeExtendedAttributes: %@]", self, URL, @(includeExtendedAttributes)];
}

+ (RACSignal *)rzz_archiveEntriesOfDirectoryContentsAtURL:(NSURL *)URL relativeToURL:(NSURL *)baseURL includeExtendedAttributes:(BOOL)includeExtendedAttributes {
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:URL includingPropertiesForKeys:nil options:0 error:&error];
    RACSignal *result = nil;
    if (contents) {
        result = [contents.rac_sequence.signal
            flattenMap:^RACSignal *(NSURL *contentURL) {
                return [self rzz_archiveEntriesOfItemAtURL:contentURL relativeToURL:baseURL includeExtendedAttributes:includeExtendedAttributes];
            }];
    } else {
        result = [RACSignal error:error];
    }
    return [result setNameWithFormat:@"[%@ +rzz_archiveEntriesOfDirectoryContentsAtURL: %@ includeExtendedAttributes: %@]", self, URL, @(includeExtendedAttributes)];
}

+ (RACSignal *)rzz_archiveEntriesOfItemAtURL:(NSURL *)URL relativeToURL:(NSURL *)baseURL includeExtendedAttributes:(BOOL)includeExtendedAttributes {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory;
    RACSignal *result = nil;
	if ([fileManager fileExistsAtPath:URL.path isDirectory:&isDirectory]) {
		if (isDirectory) {
            result = [[self rzz_archiveEntriesOfDirectoryAtURL:URL relativeToURL:baseURL includeExtendedAttributes:includeExtendedAttributes]
                concat:[self rzz_archiveEntriesOfDirectoryContentsAtURL:URL relativeToURL:baseURL includeExtendedAttributes:includeExtendedAttributes]];
		} else {
            result = [self rzz_archiveEntriesOfFileAtURL:URL relativeToURL:baseURL includeExtendedAttributes:includeExtendedAttributes];
		}
	} else {
        result = [RACSignal empty];
    }
    return [result setNameWithFormat:@"[%@ +rzz_archiveEntriesOfItemAtURL: %@ includeExtendedAttributes: %@]", self, URL, @(includeExtendedAttributes)];
}

+ (RACSignal *)rzz_archiveEntriesOfItemsAtURLs:(NSArray *)URLs relativeToURL:(NSURL *)baseURL includeExtendedAttributes:(BOOL)includeExtendedAttributes {
	RACSignal *result = [URLs.rac_sequence.signal
        flattenMap:^RACSignal *(NSURL *URL) {
            return [self rzz_archiveEntriesOfItemAtURL:URL relativeToURL:baseURL includeExtendedAttributes:includeExtendedAttributes];
        }];
    return [result setNameWithFormat:@"[%@ +rzz_archiveEntriesOfItemsAtURLs: %@ includeExtendedAttributes: %@]", self, URLs, @(includeExtendedAttributes)];
}

- (RACSignal *)rzz_data {
    NSError *error = nil;
    NSData *data = [self newDataWithError:&error];
    RACSignal *result = data ? [RACSignal return:data] : [RACSignal error:error];
    return [result setNameWithFormat:@"[%@ +rzz_data]", self];
}

- (BOOL)rzz_ifNecessaryCreateDirectoryAtPath:(NSString *)path error:(NSError **)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    BOOL result = [fileManager fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory;
    if (!result) {
        result = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
    }
    return result;
}

- (RACSignal *)rzz_writeToURL:(NSURL *)URL {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (self.fileMode & S_IFDIR) {
            if (![self rzz_ifNecessaryCreateDirectoryAtPath:URL.path error:&error]) {
                [subscriber sendError:error];
            }
        } else {
            NSData *data;
            if (![self rzz_ifNecessaryCreateDirectoryAtPath:URL.URLByDeletingLastPathComponent.path error:&error] || !(data = [self newDataWithError:&error]) || ![data writeToURL:URL atomically:YES]) {
                [subscriber sendError:error];
            }
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ +rzz_writeToURL: %@]", self, URL];
}

- (RACSignal *)rzz_writeAsExtendedAttributesToURL:(NSURL *)URL {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        NSData *data = [self newDataWithError:&error];
        if (!data) {
            [subscriber sendError:error];
        } else {
            NSURL *targetURL = URL.rzz_extendedAttributeTargetURL;
            @try {
                NSDictionary *dictionary = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
                if (![targetURL rzz_setExtendedAttributesWithDictionary:dictionary error:&error]) {
                    [subscriber sendError:error];
                }
            }
            @catch (NSException *exception) {
                [subscriber sendError:[NSError errorWithDomain:NSStringFromClass([NSException class]) code:0 userInfo:@{
                    NSLocalizedDescriptionKey : exception.description,
                }]];
            }
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ +rzz_writeToURL: %@]", self, URL];
}

@end
