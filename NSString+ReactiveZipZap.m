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
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self rzz_pathToTemporaryArea] error:error];
        if (contents && contents.count) {
            NSString *dateString = [NSString stringWithFormat:@"%.7f", date.timeIntervalSinceReferenceDate];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            for (NSString *path in contents) {
                if ([path compare:dateString] == NSOrderedAscending) {
                    if (![fileManager removeItemAtPath:[[self rzz_pathToTemporaryArea] stringByAppendingPathComponent:path] error:error]) {
                        [subscriber sendError:error];
                    } else {
                        [subscriber sendNext:path];
                    }
                }
            }
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return result;
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

@end
