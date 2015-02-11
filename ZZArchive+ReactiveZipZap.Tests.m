//
//  ZZArchive+ReactiveZipZap.Tests.m
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "ReactiveZipZap.h"

@interface ZZArchive_ReactiveZipZapTests : XCTestCase
@end

@implementation ZZArchive_ReactiveZipZapTests

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testTemporaryArchive {
	ZZArchive *temporaryArchive = [[ZZArchive rzz_temporaryArchive] first];
    XCTAssertNotNil(temporaryArchive);
    NSString *path = temporaryArchive.URL.path;
    NSString *filePath = @(__FILE__);
    ZZArchiveEntry *entry = [[ZZArchiveEntry rzz_archiveEntryOfFileAtURL:[NSURL fileURLWithPath:filePath]] first];
    NSError *error = nil;
    XCTAssertTrue([temporaryArchive updateEntries:@[entry] error:&error]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path]);
    temporaryArchive = nil;
    XCTAssertTrue(([[NSFileManager defaultManager] removeItemAtPath:path error:&error]));
}

- (void)testEphemeralArchive {
    __block NSString *path = nil;
    __block NSURL *URL = nil;
    [[[[[[ZZArchive rzz_ephemeralArchive]
        map:^ZZArchive *(ZZArchive *archive) {
            XCTAssertNotNil(archive);
            path = archive.URL.path;
            return archive;
        }]
        doNext:^(ZZArchive *archive) {
            NSString *filePath = @(__FILE__);
            ZZArchiveEntry *entry = [[ZZArchiveEntry rzz_archiveEntryOfFileAtURL:[NSURL fileURLWithPath:filePath]] first];
            NSError *error = nil;
            XCTAssertTrue([archive updateEntries:@[entry] error:&error]);
            XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path]);
        }]
        map:^ZZArchiveEntry *(ZZArchive *archive) {
            return archive.entries[0];
        }]
        flattenMap:^RACSignal *(ZZArchiveEntry *archiveEntry) {
            return [[[[NSURL rzz_ephemeralURL]
                doNext:^(NSURL *ephemeralURL) {
                    URL = ephemeralURL;
                    NSError *error;
                    XCTAssertTrue([[archiveEntry rzz_writeToURL:[ephemeralURL URLByAppendingPathComponent:@"test"]] waitUntilCompleted:&error], @"%@", error);
                }]
                doCompleted:^{
                    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
                }]
                then:^RACSignal *{
                    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
                    return [RACSignal return:archiveEntry];
                }];
        }]
        subscribeError:^(NSError *error) {
            XCTFail(@"%@", error);
        } completed:^{
            XCTAssertNotNil(path);
            XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path]);
            XCTAssertTrue(![[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
        }];
}

- (void)testTemporaryArchiveWithContentsOfURLIncludeExtendedAttributes {
    __block NSString *path = nil;
    __block NSURL *URL = nil;
    [[[[[ZZArchive rzz_temporaryArchiveWithContentsOfURL:[NSURL fileURLWithPath:@(__FILE__)] includeExtendedAttributes:YES]
        doNext:^(ZZArchive *archive) {
            path = archive.URL.path;
        }]
        map:^ZZArchiveEntry *(ZZArchive *archive) {
            return archive.entries[0];
        }]
        flattenMap:^RACSignal *(ZZArchiveEntry *archiveEntry) {
            return [[[[NSURL rzz_ephemeralURL]
                doNext:^(NSURL *ephemeralURL) {
                    URL = ephemeralURL;
                    NSError *error;
                    XCTAssertTrue([[archiveEntry rzz_writeToURL:[ephemeralURL URLByAppendingPathComponent:@"test"]] waitUntilCompleted:&error], @"%@", error);
                }]
                doCompleted:^{
                    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
                }]
                then:^RACSignal *{
                    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
                    return [RACSignal return:archiveEntry];
                }];
        }]
        subscribeError:^(NSError *error) {
            XCTFail(@"%@", error);
        } completed:^{
            XCTAssertNotNil(path);
            XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path]);
            XCTAssertTrue(![[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
        }];
}

- (void)testEphemeralArchiveWithContentsOfURLIncludeExtendedAttributes {
    __block NSString *path = nil;
    __block NSURL *URL = nil;
    [[[[[ZZArchive rzz_ephemeralArchiveWithContentsOfURL:[NSURL fileURLWithPath:@(__FILE__)] includeExtendedAttributes:YES]
        doNext:^(ZZArchive *archive) {
            path = archive.URL.path;
        }]
        map:^ZZArchiveEntry *(ZZArchive *archive) {
            return archive.entries[0];
        }]
        flattenMap:^RACSignal *(ZZArchiveEntry *archiveEntry) {
            return [[[[NSURL rzz_ephemeralURL]
                doNext:^(NSURL *ephemeralURL) {
                    URL = ephemeralURL;
                    NSError *error;
                    XCTAssertTrue([[archiveEntry rzz_writeToURL:[ephemeralURL URLByAppendingPathComponent:@"test"]] waitUntilCompleted:&error], @"%@", error);
                }]
                doCompleted:^{
                    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
                }]
                then:^RACSignal *{
                    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
                    return [RACSignal return:archiveEntry];
                }];
        }]
        subscribeError:^(NSError *error) {
            XCTFail(@"%@", error);
        } completed:^{
            XCTAssertNotNil(path);
            XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path]);
            XCTAssertTrue(![[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
        }];
}

- (void)testUnarchiveToURL {
    NSError *error = nil;
    NSURL *URL = [[NSURL rzz_temporaryURL] first];
    XCTAssertTrue([[[ZZArchive rzz_ephemeralArchiveWithContentsOfURL:[NSURL fileURLWithPath:@(__FILE__)] includeExtendedAttributes:YES]
        flattenMap:^RACSignal *(ZZArchive *archive) {
            return [archive rzz_unarchiveToURL:URL];
        }]
        waitUntilCompleted:&error]);
    NSString *newPath = [URL.path stringByAppendingPathComponent:[@(__FILE__) lastPathComponent]];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:newPath]);
}

- (void)testUnarchiveToTemporaryURL {
    NSError *error = nil;
    __block NSURL *URL = nil;
    XCTAssertTrue([[[[ZZArchive rzz_ephemeralArchiveWithContentsOfURL:[NSURL fileURLWithPath:@(__FILE__)] includeExtendedAttributes:YES]
        flattenMap:^RACSignal *(ZZArchive *archive) {
            return [archive rzz_unarchiveToTemporaryURL];
        }]
        doNext:^(NSURL *temporaryURL) {
            URL = temporaryURL;
        }]
        waitUntilCompleted:&error]);
    NSString *newPath = [URL.path stringByAppendingPathComponent:[@(__FILE__) lastPathComponent]];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:newPath]);
}

- (void)testUnarchiveToEphemeralURL {
    NSError *error = nil;
    __block NSURL *URL = nil;
    BOOL success = [[[[ZZArchive rzz_ephemeralArchiveWithContentsOfURL:[NSURL fileURLWithPath:@(__FILE__)] includeExtendedAttributes:YES]
        flattenMap:^RACSignal *(ZZArchive *archive) {
            URL = archive.URL;
            XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
            return [archive rzz_unarchiveToEphemeralURL];
        }]
        doNext:^(NSURL *ephemeralURL) {
            URL = ephemeralURL;
        }]
        waitUntilCompleted:&error];
    XCTAssertTrue(success);
    NSString *newPath = [URL.path stringByAppendingPathComponent:[@(__FILE__) lastPathComponent]];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:newPath]);
}

@end

/**
- (RACSignal *)rzz_unarchiveToEphemeralURL;
*/
