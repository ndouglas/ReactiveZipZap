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

+ (RACSignal *)rzz_temporaryArchive {
    NSError *error = nil;
    NSURL *URL = [NSURL rzz_temporaryURLOrError:&error];
    RACSignal *result = URL ? [self rzz_newArchiveAtURL:[URL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]]] : [RACSignal error:error];
    return [result setNameWithFormat:@"[%@ +rzz_temporaryArchive]", self];
}

+ (RACSignal *)rzz_archiveFromSignal:(RACSignal *)archiveSignal addEntriesFromSignal:(RACSignal *)entriesSignal {
    RACSignal *result = [archiveSignal
        flattenMap:^RACSignal *(ZZArchive *archive) {
            NSMutableArray *entries = [NSMutableArray array];
            RACSignal *result = [[[[entriesSignal
                doNext:^(ZZArchiveEntry *archiveEntry) {
                    [entries addObject:archiveEntry];
                }]
                ignoreValues]
                concat:[archive rzz_updateEntries:entries]]
                concat:[RACSignal return:archive]];
            return result;
        }];
    return [result setNameWithFormat:@"[%@ +rzz_archiveFromSignal: %@ addEntriesFromSignal: %@]", self, archiveSignal, entriesSignal];
}

+ (RACSignal *)rzz_temporaryArchiveWithEntriesFromSignal:(RACSignal *)signal {
    RACSignal *result = [self rzz_archiveFromSignal:[self rzz_temporaryArchive] addEntriesFromSignal:signal];
    return [result setNameWithFormat:@"[%@ +rzz_temporaryArchiveWithEntriesFromSignal: %@]", self, signal];
}

+ (RACSignal *)rzz_temporaryArchiveWithContentsOfURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes {
    RACSignal *result = [self rzz_temporaryArchiveWithEntriesFromSignal:[ZZArchiveEntry rzz_archiveEntriesOfItemAtURL:URL relativeToURL:URL.URLByDeletingLastPathComponent includeExtendedAttributes:includeExtendedAttributes]];
    return [result setNameWithFormat:@"[%@ +rzz_temporaryArchiveWithContentsOfURL: %@ includeExtendedAttributes: %@]", self, URL, @(includeExtendedAttributes)];
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

- (RACSignal *)rzz_unarchiveToURL:(NSURL *)URL {
    RACSignal *result = [[self rzz_writeItemEntriesToURL:URL]
        then:^RACSignal *{
            return [self rzz_writeExtendedAttributeEntriesToURL:URL];
        }];
    return [result setNameWithFormat:@"[%@ -rzz_unarchiveToURL: %@]", self, URL];
}

- (RACSignal *)rzz_unarchiveToTemporaryURL {
    NSError *error = nil;
    NSURL *URL = [NSURL rzz_temporaryURLOrError:&error];
    RACSignal *result = nil;
    if (URL) {
        result = [[self rzz_unarchiveToURL:URL]
            concat:[RACSignal return:URL]];
    } else {
        result = [RACSignal error:error];
    }
    return [result setNameWithFormat:@"[%@ -rzz_unarchiveToTemporaryURL]", self];
}

- (RACSignal *)rzz_writeItemEntriesToURL:(NSURL *)URL {
    RACSignal *result = [[self.entries.rac_sequence.signal
        filter:^BOOL(ZZArchiveEntry *entry) {
            return ![entry.fileName containsString:RZZXattrFilenamePrefix];
        }]
        flattenMap:^RACSignal *(ZZArchiveEntry *entry) {
            return [entry rzz_writeToURL:[URL URLByAppendingPathComponent:entry.fileName]];
        }];
    return [result setNameWithFormat:@"[%@ -rzz_writeItemEntriesToURL: %@]", self, URL];
}

- (RACSignal *)rzz_writeExtendedAttributeEntriesToURL:(NSURL *)URL {
    RACSignal *result = [[self.entries.rac_sequence.signal
        filter:^BOOL(ZZArchiveEntry *entry) {
            return [entry.fileName containsString:RZZXattrFilenamePrefix];
        }]
        flattenMap:^RACSignal *(ZZArchiveEntry *entry) {
            return [entry rzz_writeAsExtendedAttributesToURL:[URL URLByAppendingPathComponent:entry.fileName]];
        }];
    return [result setNameWithFormat:@"[%@ -rzz_writeItemEntriesToURL: %@]", self, URL];
}

@end
