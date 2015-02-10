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

@implementation NSURL (ReactiveZipZap)

- (NSURL *)rzz_extendedAttributeTargetURL {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    return [NSURL fileURLWithPath:[self.path rzz_extendedAttributeTargetPath]];
}

- (NSString *)rzz_extendedAttributeLastPathComponent {
    NSCAssert([self isFileURL], @"self needs to be a file URL");
    return [self.path rzz_extendedAttributeLastPathComponent];
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

@end
