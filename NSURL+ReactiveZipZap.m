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

+ (RACSignal *)rzz_cleanTemporaryAreaOfItemsOlderThanDate:(NSDate *)date {
    return [NSString rzz_cleanTemporaryAreaOfItemsOlderThanDate:date];
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

+ (NSURL *)rzz_temporaryURLOrError:(NSError **)error {
    return [NSURL fileURLWithPath:[NSString rzz_temporaryPathOrError:error]];
}

static int RZZXattrOptions = XATTR_NOFOLLOW | XATTR_SHOWCOMPRESSION;

- (NSArray *)rzz_namesOfExtendedAttributesWithError:(NSError **)error {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    return [self.path rzz_namesOfExtendedAttributesWithError:error];
}

- (BOOL)rzz_setValue:(NSData *)value forExtendedAttributeWithName:(NSString *)name error:(NSError **)error {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    return [self.path rzz_setValue:value forExtendedAttributeWithName:name error:error];
}

- (NSData *)rzz_valueForExtendedAttributeWithName:(NSString *)name error:(NSError **)error {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    return [self.path rzz_valueForExtendedAttributeWithName:name error:error];
}

- (BOOL)rzz_removeExtendedAttributeWithName:(NSString *)name error:(NSError **)error {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    return [self.path rzz_removeExtendedAttributeWithName:name error:error];
}

- (NSDictionary *)rzz_dictionaryWithExtendedAttributesOrError:(NSError **)error {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    return [self.path rzz_dictionaryWithExtendedAttributesOrError:error];
}

- (BOOL)rzz_setExtendedAttributesWithDictionary:(NSDictionary *)dictionary error:(NSError **)error {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    return [self.path rzz_setExtendedAttributesWithDictionary:dictionary error:error];
}

@end
