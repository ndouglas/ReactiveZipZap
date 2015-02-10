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

+ (RACSignal *)rzz_temporaryURL {
    RACSignal *result = [[NSString rzz_temporaryPath]
    map:^NSURL *(NSString *path) {
        return [NSURL fileURLWithPath:path];
    }];
    return [result setNameWithFormat:@"[%@ +rzz_temporaryURL]", self];
}

@end
