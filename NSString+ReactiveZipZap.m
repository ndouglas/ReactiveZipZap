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

+ (BOOL)rzz_cleanTemporaryAreaOrError:(NSError **)error {
    return [[NSFileManager defaultManager] removeItemAtPath:[self rzz_pathToTemporaryArea] error:error] && [[NSFileManager defaultManager] createDirectoryAtPath:[self rzz_pathToTemporaryArea] withIntermediateDirectories:YES attributes:nil error:error];
}

+ (BOOL)rzz_cleanTemporaryAreaOfItemsOlderThanDate:(NSDate *)date error:(NSError **)error {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self rzz_pathToTemporaryArea] error:error];
    BOOL result = contents != nil;
    if (contents) {
        NSString *dateString = [NSString stringWithFormat:@"%.7f", date.timeIntervalSinceReferenceDate];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (NSString *path in contents) {
            if ([path compare:dateString] == NSOrderedAscending) {
                if (![fileManager removeItemAtPath:[[self rzz_pathToTemporaryArea] stringByAppendingPathComponent:path] error:error]) {
                    result = NO;
                    break;
                }
            }
        }
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
                if ([path compare:dateString] == NSOrderedAscending) {
                    if (![fileManager removeItemAtPath:[[self rzz_pathToTemporaryArea] stringByAppendingPathComponent:path] error:&error]) {
                        [subscriber sendError:error];
                    } else {
                        [subscriber sendNext:path];
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

+ (NSString *)rzz_temporaryPathOrError:(NSError **)error {
    NSString *nonce = [NSString stringWithFormat:@"%.7f_%@", [[NSDate date] timeIntervalSinceReferenceDate], [[NSUUID UUID] UUIDString]];
    NSString *path = [[self rzz_pathToTemporaryArea] stringByAppendingPathComponent:nonce];
    NSString *result = nil;
    if ([[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error]) {
        result = path;
    };
    return result;
}

static int RZZXattrOptions = XATTR_NOFOLLOW | XATTR_SHOWCOMPRESSION;

static inline NSError *RZZErrorForPOSIXErrorAtPath(int posixError, NSString *path) {
    return [NSError errorWithDomain:NSPOSIXErrorDomain code:posixError userInfo:@{
        NSLocalizedDescriptionKey : @(strerror(posixError)) ?: NSLocalizedString(@"An unknown error occurred.", nil),
        NSURLErrorKey : [NSURL fileURLWithPath:path] ?: [NSNull null],
    }];
}

ssize_t RZZSizeOfExtendedAttributesOfPath(NSString *path, NSError **error) {
    ssize_t result = listxattr(path.fileSystemRepresentation, NULL, SIZE_MAX, RZZXattrOptions);
    if (result == -1 && error) {
        *error = RZZErrorForPOSIXErrorAtPath(errno, path);
    }
    return result;
}

- (NSArray *)rzz_namesOfExtendedAttributesWithError:(NSError **)error {
    NSMutableArray *result = nil;
    ssize_t size = RZZSizeOfExtendedAttributesOfPath(self, error);
    if (size != -1) {
        if (size) {
            void *names = calloc(1, size);
            if (names) {
                size = listxattr(self.fileSystemRepresentation, names, size, RZZXattrOptions);
                if (size && size != -1) {
                    result = [NSMutableArray array];
                    uintptr_t start = (uintptr_t)names;
                    uintptr_t thisName = start;
                    for (ssize_t i = 0; i < size; i++) {
                        uintptr_t current = start + i;
                        if (current && *((char *)current) == 0x0) {
                            NSString *name = [NSString stringWithUTF8String:(char *)thisName];
                            if (name) {
                                [result addObject:name];
                                start = current + 1;
                            }
                        }
                    }
                } else if (size == -1 && error) {
                    *error = RZZErrorForPOSIXErrorAtPath(errno, self);
                }
                free(names);
            } else if (error) {
                *error = RZZErrorForPOSIXErrorAtPath(errno, self);
            }
        } else {
            result = [NSMutableArray array];
        }
    }
    return result;
}

- (BOOL)rzz_setValue:(NSData *)value forExtendedAttributeWithName:(NSString *)name error:(NSError **)error {
    BOOL result = YES;
    if (setxattr(self.fileSystemRepresentation, name.UTF8String, value.bytes, value.length, 0, RZZXattrOptions)) {
        result = NO;
        if (error) {
            *error = RZZErrorForPOSIXErrorAtPath(errno, self);
        }
    }
    return result;
}

- (NSData *)rzz_valueForExtendedAttributeWithName:(NSString *)name error:(NSError **)error {
    NSData *result = nil;
    ssize_t size = getxattr(self.fileSystemRepresentation, name.UTF8String, NULL, 0, 0, RZZXattrOptions);
    if (size != -1) {
        char *value = calloc(1, size);
        size = getxattr(self.fileSystemRepresentation, name.UTF8String, value, size, 0, RZZXattrOptions);
        if (size != -1) {
            result = [NSData dataWithBytes:value length:size];
        } else if (error) {
            *error = RZZErrorForPOSIXErrorAtPath(errno, self);
        }
        if (value) {
            free(value);
        }
    } else if (size == -1 && error) {
        *error = RZZErrorForPOSIXErrorAtPath(errno, self);
    }
    return result;
}

- (BOOL)rzz_removeExtendedAttributeWithName:(NSString *)name error:(NSError **)error {
    BOOL result = YES;
    if (removexattr(self.fileSystemRepresentation, name.UTF8String, RZZXattrOptions)) {
        result = NO;
        if (error) {
            *error = RZZErrorForPOSIXErrorAtPath(errno, self);
        }
    }
    return result;
}

- (NSDictionary *)rzz_dictionaryWithExtendedAttributesOrError:(NSError **)error {
    NSArray *attributeNames = [self rzz_namesOfExtendedAttributesWithError:error];
    NSMutableDictionary *result = nil;
    if (attributeNames) {
        result = [NSMutableDictionary dictionaryWithCapacity:attributeNames.count];
        for (NSString *attributeName in attributeNames) {
            NSData *value = [self rzz_valueForExtendedAttributeWithName:attributeName error:error];
            if (!value) {
                result = nil;
                break;
            }
            result[attributeName] = value;
        }
    }
    return result;
}

- (BOOL)rzz_setExtendedAttributesWithDictionary:(NSDictionary *)dictionary error:(NSError **)error {
    BOOL result = YES;
    for (NSString *attributeName in dictionary) {
        if (![self rzz_setValue:dictionary[attributeName] forExtendedAttributeWithName:attributeName error:error]) {
            result = NO;
            break;
        }
    }
    return result;
}

@end
