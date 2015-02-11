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

+ (RACSignal *)rzz_temporaryPath {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *nonce = [NSString stringWithFormat:@"%.7f_%@", [[NSDate date] timeIntervalSinceReferenceDate], [[NSUUID UUID] UUIDString]];
        NSString *path = [[self rzz_pathToTemporaryArea] stringByAppendingPathComponent:nonce];
        NSError *error = nil;
        if ([[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            [subscriber sendNext:path];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[ %@ +rzz_temporaryPath]", self];
}

+ (RACSignal *)rzz_ephemeralPath {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *nonce = [NSString stringWithFormat:@"%.7f_%@", [[NSDate date] timeIntervalSinceReferenceDate], [[NSUUID UUID] UUIDString]];
        NSString *path = [[self rzz_pathToTemporaryArea] stringByAppendingPathComponent:nonce];
        NSError *error = nil;
        if ([[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            [subscriber sendNext:path];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSError *error = nil;
            if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
                NSLog(@"Failed to remove item at path '%@': %@", path, error);
            }
        }];
    }];
    return [result setNameWithFormat:@"[ %@ +rzz_ephemeralPath]", self];
}

@end
