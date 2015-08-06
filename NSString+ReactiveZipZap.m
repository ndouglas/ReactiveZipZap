//
//  NSString+ReactiveZipZap.m
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "NSString+ReactiveZipZap.h"
#import "ReactiveZipZap.h"
#import <sys/xattr.h>
#import <unistd.h>

@implementation NSString (ReactiveZipZap)

+ (NSString *)rzz_pathToTemporaryArea {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.nathandouglas.reactivezipzap"];
}

+ (BOOL)rzz_cleanTemporaryAreaOrError:(NSError **)_error {
    NSError *error = nil;
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:[self rzz_pathToTemporaryArea] error:&error];
    result = result && [[NSFileManager defaultManager] createDirectoryAtPath:[self rzz_pathToTemporaryArea] withIntermediateDirectories:YES attributes:nil error:&error];
    if (!result && _error) {
        *_error = error;
    }
    return result;
}

+ (BOOL)rzz_cleanTemporaryAreaOfItemsOlderThanDate:(NSDate *)date error:(NSError **)_error {
    NSError *error = nil;
    NSArray *contents = nil;
    BOOL result = NO;
    @autoreleasepool {
        contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self rzz_pathToTemporaryArea] error:&error];
        result = contents != nil;
        if (result) {
            NSString *dateString = [NSString stringWithFormat:@"%.7f", date.timeIntervalSinceReferenceDate];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            for (NSString *path in contents) {
                if ([path compare:dateString] == NSOrderedAscending) {
                    if (![fileManager removeItemAtPath:[[self rzz_pathToTemporaryArea] stringByAppendingPathComponent:path] error:&error]) {
                        result = NO;
                        break;
                    }
                }
            }
        }
    }
    if (!result && _error) {
        *_error = error;
    }
    return result;
}

+ (RACSignal *)rzz_cleanTemporaryAreaOfItemsOlderThanDate:(NSDate *)date {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self rzz_pathToTemporaryArea] error:&error];
        if (contents && contents.count) {
            NSString *dateString = [NSString stringWithFormat:@"%.7f", date.timeIntervalSinceReferenceDate];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            for (NSString *path in contents) {
                @autoreleasepool {
                    if ([path compare:dateString] == NSOrderedAscending) {
                        NSError *thisError = nil;
                        if (![fileManager removeItemAtPath:[[self rzz_pathToTemporaryArea] stringByAppendingPathComponent:path] error:&thisError]) {
                            [subscriber sendError:thisError];
                        } else {
                            [subscriber sendNext:path];
                        }
                    }
                }
            }
        } else if (!contents && error) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
}

- (NSString *)rzz_extendedAttributeTargetLastPathComponent {
    return [self.lastPathComponent stringByReplacingOccurrencesOfString:RZZXattrFilenamePrefix withString:@""];
}

- (NSString *)rzz_extendedAttributeTargetPath {
    return [self.stringByDeletingLastPathComponent stringByAppendingPathComponent:self.rzz_extendedAttributeTargetLastPathComponent];
}

- (NSString *)rzz_extendedAttributeLastPathComponent {
    return [RZZXattrFilenamePrefix stringByAppendingString:self.lastPathComponent];
}

- (NSString *)rzz_extendedAttributePath {
    return [self.stringByDeletingLastPathComponent stringByAppendingPathComponent:self.rzz_extendedAttributeLastPathComponent];
}

+ (NSString *)rzz_temporaryPathOrError:(NSError **)_error {
    NSString *result = nil;
    NSError *error = nil;
    @autoreleasepool {
        NSString *nonce = [NSString stringWithFormat:@"%.7f_%@", [[NSDate date] timeIntervalSinceReferenceDate], [[NSUUID UUID] UUIDString]];
        NSString *path = [[self rzz_pathToTemporaryArea] stringByAppendingPathComponent:nonce];
        if ([[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            result = path;
        };
    }
    if (!result && _error) {
        *_error = error;
    }
    return result;
}

static int RZZXattrOptions = XATTR_NOFOLLOW | XATTR_SHOWCOMPRESSION;

static inline NSError *RZZErrorForPOSIXErrorAtPath(int posixError, NSString *path) {
    return [NSError errorWithDomain:NSPOSIXErrorDomain code:posixError userInfo:@{
        NSLocalizedDescriptionKey : @(strerror(posixError)) ?: NSLocalizedString(@"An unknown error occurred.", nil),
        NSURLErrorKey : [NSURL fileURLWithPath:path] ?: [NSNull null],
    }];
}

- (NSArray *)rzz_namesOfExtendedAttributesWithError:(NSError **)_error {
	NSMutableArray *result = [NSMutableArray array];
    @autoreleasepool {
        char *keys = 0;
        size_t size = listxattr(self.fileSystemRepresentation, NULL, 0, RZZXattrOptions);
        keys = calloc(size, sizeof(*keys));
        size = listxattr(self.fileSystemRepresentation, keys, size, RZZXattrOptions);
        char *key = 0;
        int sLen = 0;
        for(key = keys; key < keys + size; key += 1 + sLen) {
            sLen = (int)strlen(key);
            [result addObject:[NSString stringWithUTF8String:key]];
        }
        free(keys);
    }
	return result;
}

- (BOOL)rzz_setValue:(NSData *)value forExtendedAttributeWithName:(NSString *)name error:(NSError **)_error {
    BOOL result = YES;
    if (setxattr(self.fileSystemRepresentation, name.UTF8String, value.bytes, value.length, 0, RZZXattrOptions)) {
        result = NO;
    }
    if (!result && _error) {
        *_error = RZZErrorForPOSIXErrorAtPath(errno, self);
    }
    return result;
}

- (NSData *)rzz_valueForExtendedAttributeWithName:(NSString *)name error:(NSError **)_error {
    NSData *result = nil;
    NSError *error = nil;
    @autoreleasepool {
        ssize_t size = getxattr(self.fileSystemRepresentation, name.UTF8String, NULL, 0, 0, RZZXattrOptions);
        if (size != -1) {
            char *value = calloc(1, size);
            size = getxattr(self.fileSystemRepresentation, name.UTF8String, value, size, 0, RZZXattrOptions);
            if (size != -1) {
                result = [NSData dataWithBytes:value length:size];
            } else {
                error = RZZErrorForPOSIXErrorAtPath(errno, self);
            }
            if (value) {
                free(value);
            }
        }
    }
    if (!result && _error) {
        *_error = error;
    }
    return result;
}

- (BOOL)rzz_removeExtendedAttributeWithName:(NSString *)name error:(NSError **)_error {
    BOOL result = YES;
    if (removexattr(self.fileSystemRepresentation, name.UTF8String, RZZXattrOptions)) {
        result = NO;
    }
    if (!result && _error) {
        *_error = RZZErrorForPOSIXErrorAtPath(errno, self);
    }
    return result;
}

- (NSDictionary *)rzz_dictionaryWithExtendedAttributesOrError:(NSError **)_error {
    NSMutableDictionary *result = nil;
    NSError *error = nil;
    NSArray *attributeNames = [self rzz_namesOfExtendedAttributesWithError:&error];
    @autoreleasepool {
        if (attributeNames) {
            result = [NSMutableDictionary dictionaryWithCapacity:attributeNames.count];
            for (NSString *attributeName in attributeNames) {
                NSData *value = [self rzz_valueForExtendedAttributeWithName:attributeName error:&error];
                if (!value) {
                    result = nil;
                    break;
                }
                result[attributeName] = value;
            }
        }
    }
    if (!result && _error) {
        *_error = error;
    }
    return result;
}

- (BOOL)rzz_setExtendedAttributesWithDictionary:(NSDictionary *)dictionary error:(NSError **)_error {
    BOOL result = YES;
    NSError *error = nil;
    @autoreleasepool {
        for (NSString *attributeName in dictionary) {
            if (![self rzz_setValue:dictionary[attributeName] forExtendedAttributeWithName:attributeName error:&error]) {
                result = NO;
                break;
            }
        }
    }
    if (!result && _error) {
        *_error = error;
    }
    return result;
}

@end
