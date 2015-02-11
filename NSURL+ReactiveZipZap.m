//
//  NSURL+ReactiveZipZap.m
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "NSURL+ReactiveZipZap.h"
#import "ReactiveZipZap.h"
#import <sys/xattr.h>
#import <unistd.h>

@implementation NSURL (ReactiveZipZap)

+ (BOOL)rzz_cleanTemporaryAreaOrError:(NSError **)error {
    return [NSString rzz_cleanTemporaryAreaOrError:error];
}

+ (BOOL)rzz_cleanTemporaryAreaOfItemsOlderThanDate:(NSDate *)date error:(NSError **)error {
    return [NSString rzz_cleanTemporaryAreaOfItemsOlderThanDate:date error:error];
}

- (NSURL *)rzz_extendedAttributeTargetURL {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    return [NSURL fileURLWithPath:[self.path rzz_extendedAttributeTargetPath]];
}

- (NSString *)rzz_extendedAttributeLastPathComponent {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    return [self.path rzz_extendedAttributeLastPathComponent];
}

- (NSString *)rzz_extendedAttributePath {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    return [self.path rzz_extendedAttributePath];
}

- (NSURL *)rzz_extendedAttributeURL {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    return [NSURL fileURLWithPath:self.rzz_extendedAttributePath];
}

+ (RACSignal *)rzz_temporaryURL {
    RACSignal *result = [[NSString rzz_temporaryPath]
    map:^NSURL *(NSString *path) {
        return [NSURL fileURLWithPath:path];
    }];
    return [result setNameWithFormat:@"[%@ +rzz_temporaryURL]", self];
}

+ (RACSignal *)rzz_ephemeralURL {
    RACSignal *result = [[NSString rzz_ephemeralPath]
    map:^NSURL *(NSString *path) {
        return [NSURL fileURLWithPath:path];
    }];
    return [result setNameWithFormat:@"[%@ +rzz_ephemeralURL]", self];
}

static int RZZXattrOptions = XATTR_NOFOLLOW | XATTR_SHOWCOMPRESSION;

static inline NSError *RZZErrorForPOSIXErrorAtURL(int posixError, NSURL *URL) {
    return [NSError errorWithDomain:NSPOSIXErrorDomain code:posixError userInfo:@{
        NSLocalizedDescriptionKey : @(strerror(posixError)) ?: NSLocalizedString(@"An unknown error occurred.", nil),
        NSURLErrorKey : URL ?: [NSNull null],
    }];
}

ssize_t RZZSizeOfExtendedAttributesOfURL(NSURL *URL, NSError **error) {
    ssize_t result = listxattr(URL.path.fileSystemRepresentation, NULL, SIZE_MAX, RZZXattrOptions);
    if (result == -1 && error) {
        *error = RZZErrorForPOSIXErrorAtURL(errno, URL);
    }
    return result;
}

- (NSArray *)rzz_namesOfExtendedAttributesWithError:(NSError **)error {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    NSMutableArray *result = nil;
    ssize_t size = RZZSizeOfExtendedAttributesOfURL(self, error);
    if (size != -1) {
        if (size) {
            void *names = calloc(1, size);
            size = listxattr(self.path.fileSystemRepresentation, names, size, RZZXattrOptions);
            if (size && size != -1) {
                result = [NSMutableArray array];
                uintptr_t start = (uintptr_t)names;
                uintptr_t thisName = start;
                for (ssize_t i = 0; i < size; i++) {
                    uintptr_t current = start + i;
                    if (current && *((char *)current) == 0x0) {
                        [result addObject:@((char *)thisName)];
                        start = current + 1;
                    }
                }
            } else if (size == -1 && error) {
                *error = RZZErrorForPOSIXErrorAtURL(errno, self);
            }
            if (names) {
                free(names);
            }
        } else {
            result = [NSMutableArray array];
        }
    }
    return result;
}

- (BOOL)rzz_setValue:(NSData *)value forExtendedAttributeWithName:(NSString *)name error:(NSError **)error {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    BOOL result = YES;
    if (setxattr(self.path.fileSystemRepresentation, name.UTF8String, value.bytes, value.length, 0, RZZXattrOptions)) {
        result = NO;
        if (error) {
            *error = RZZErrorForPOSIXErrorAtURL(errno, self);
        }
    }
    return result;
}

- (NSData *)rzz_valueForExtendedAttributeWithName:(NSString *)name error:(NSError **)error {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    NSData *result = nil;
    ssize_t size = getxattr(self.path.fileSystemRepresentation, name.UTF8String, NULL, 0, 0, RZZXattrOptions);
    if (size != -1) {
        char *value = calloc(1, size);
        size = getxattr(self.path.fileSystemRepresentation, name.UTF8String, value, size, 0, RZZXattrOptions);
        if (size != -1) {
            result = [NSData dataWithBytes:value length:size];
        } else if (error) {
            *error = RZZErrorForPOSIXErrorAtURL(errno, self);
        }
        if (value) {
            free(value);
        }
    } else if (size == -1 && error) {
        *error = RZZErrorForPOSIXErrorAtURL(errno, self);
    }
    return result;
}

- (BOOL)rzz_removeExtendedAttributeWithName:(NSString *)name error:(NSError **)error {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    BOOL result = YES;
    if (removexattr(self.path.fileSystemRepresentation, name.UTF8String, RZZXattrOptions)) {
        result = NO;
        if (error) {
            *error = RZZErrorForPOSIXErrorAtURL(errno, self);
        }
    }
    return result;
}

- (NSDictionary *)rzz_dictionaryWithExtendedAttributesOrError:(NSError **)error {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
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
    NSCAssert([self isFileURL], @"self needs to be a file URL");
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
