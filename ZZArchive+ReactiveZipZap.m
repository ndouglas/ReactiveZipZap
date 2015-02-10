//
//  ZZArchive+ReactiveZipZap.m
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "ZZArchive+ReactiveZipZap.h"
#import "ReactiveZipZap.h"

@implementation ZZArchive (ReactiveZipZap)

+ (RACSignal *)rzz_archiveAtURL:(NSURL *)URL {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        ZZArchive *archive = [ZZArchive archiveWithURL:URL error:&error];
        if (archive) {
            [subscriber sendNext:archive];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ +rzz_newArchiveAtURL: %@]", self, URL];
}

+ (RACSignal *)rzz_newArchiveAtURL:(NSURL *)URL {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSDictionary *options = @{
            ZZOpenOptionsCreateIfMissingKey : @YES,
        };
        NSError *error = nil;
        ZZArchive *archive = [[ZZArchive alloc] initWithURL:URL options:options error:&error];
        if (archive) {
            [subscriber sendNext:archive];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ +rzz_newArchiveAtURL: %@]", self, URL];
}



