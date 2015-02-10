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



