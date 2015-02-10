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

+ (RACSignal *)rzz_mapNewArchiveForURLSignal:(RACSignal *)URLSignal {
    RACSignal *result = [URLSignal
        flattenMap:^RACSignal *(NSURL *URL) {
            return [self rzz_newArchiveAtURL:URL];
        }];
    return [result setNameWithFormat:@"[%@ +rzz_mapNewArchiveForURLSignal: %@]", self, URLSignal];
}

+ (RACSignal *)rzz_temporaryArchive {
    RACSignal *result = [self rzz_mapNewArchiveForURLSignal:[NSURL rzz_temporaryURL]];
    return [result setNameWithFormat:@"[%@ +rzz_temporaryArchive]", self];
}

+ (RACSignal *)rzz_ephemeralArchive {
    RACSignal *result = [self rzz_mapNewArchiveForURLSignal:[NSURL rzz_ephemeralURL]];
    return [result setNameWithFormat:@"[%@ +rzz_ephemeralArchive]", self];
}

+ (RACSignal *)rzz_archiveFromSignal:(RACSignal *)archiveSignal addEntriesFromSignal:(RACSignal *)entriesSignal {
    RACSignal *result = [archiveSignal
        flattenMap:^RACSignal *(ZZArchive *archive) {
            NSMutableArray *entries = [NSMutableArray array];
            RACSignal *result = [[entriesSignal
                doNext:^(ZZArchiveEntry *archiveEntry) {
                    [entries addObject:archiveEntry];
                }]
                concat:[archive rzz_updateEntries:entries]];
            return result;
        }];
    return [result setNameWithFormat:@"[%@ +rzz_archiveFromSignal: %@ addEntriesFromSignal: %@]", self, archiveSignal, entriesSignal];
}

+ (RACSignal *)rzz_temporaryArchiveWithEntriesFromSignal:(RACSignal *)signal {
    RACSignal *result = [self rzz_archiveFromSignal:[self rzz_temporaryArchive] addEntriesFromSignal:signal];
    return [result setNameWithFormat:@"[%@ +rzz_temporaryArchiveWithEntriesFromSignal: %@]", self, signal];
}

+ (RACSignal *)rzz_ephemeralArchiveWithEntriesFromSignal:(RACSignal *)signal {
    RACSignal *result = [self rzz_archiveFromSignal:[self rzz_ephemeralArchive] addEntriesFromSignal:signal];
    return [result setNameWithFormat:@"[%@ +rzz_ephemeralArchiveWithEntriesFromSignal: %@]", self, signal];
}

- (RACSignal *)rzz_updateEntries:(NSArray *)entries {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (![self updateEntries:entries.copy error:&error]) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rzz_updateEntries: %@]", self, entries];
}

@end



