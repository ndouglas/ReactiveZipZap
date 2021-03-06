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
    NSURL *myURL = [NSURL fileURLWithPath:filePath];
    ZZArchiveEntry *entry = [[ZZArchiveEntry rzz_archiveEntryOfFileAtURL:myURL relativeToURL:myURL] first];
    NSError *error = nil;
    XCTAssertTrue([temporaryArchive updateEntries:@[entry] error:&error]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path]);
    temporaryArchive = nil;
    XCTAssertTrue(([[NSFileManager defaultManager] removeItemAtPath:path error:&error]));
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
        doNext:^(ZZArchiveEntry *archiveEntry) {
            NSError *error = nil;
            NSURL *URL = [NSURL rzz_temporaryURLOrError:&error];
            XCTAssertNotNil(URL, @"%@", error);
            XCTAssertTrue([[archiveEntry rzz_writeToURL:[URL URLByAppendingPathComponent:@"test"]] waitUntilCompleted:&error], @"%@", error);
            XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
            XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
        }]
        subscribeError:^(NSError *error) {
            XCTFail(@"%@", error);
        } completed:^{
            XCTAssertNotNil(path);
            XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path]);
            XCTAssertTrue(![[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
        }];
}

- (void)testTemporaryArchiveWithContentsOfURLIncludeExtendedAttributes2 {
    NSString *sourcePath = @"/Users/nathan/testBundle";
    NSURL *sourceURL = [NSURL fileURLWithPath:sourcePath];
    XCTestExpectation *expectation = [self expectationWithDescription:@"archive unarchived"];
    [[[ZZArchive rzz_temporaryArchiveWithContentsOfURL:sourceURL includeExtendedAttributes:YES]
        flattenMap:^RACSignal *(ZZArchive *_archive_) {
            NSLog(@"Archived to URL: %@", _archive_.URL);
            return [_archive_ rzz_unarchiveToTemporaryURL];
        }]
        subscribeNext:^(NSURL *_URL_) {
            NSLog(@"Unarchived to URL: %@", _URL_);
            [expectation fulfill];
        } error:^(NSError *error) {
            XCTFail(@"Error: %@", error);
        }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testTemporaryArchiveWithContentsOfURLIncludeExtendedAttributes3 {
    NSString *sourcePath = @"/Users/nathan/Desktop/RTFD Test.rtfd";
    NSURL *sourceURL = [NSURL fileURLWithPath:sourcePath];
    XCTestExpectation *expectation = [self expectationWithDescription:@"archive unarchived"];
    [[[ZZArchive rzz_temporaryArchiveWithContentsOfURL:sourceURL includeExtendedAttributes:YES]
        flattenMap:^RACSignal *(ZZArchive *_archive_) {
            NSLog(@"Archived to URL: %@", _archive_.URL);
            return [_archive_ rzz_unarchiveToTemporaryURL];
        }]
        subscribeNext:^(NSURL *_URL_) {
            NSLog(@"Unarchived to URL: %@", _URL_);
            [expectation fulfill];
        } error:^(NSError *error) {
            XCTFail(@"Error: %@", error);
        }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testUnarchiveToURL {
    NSError *error = nil;
    NSURL *URL = [NSURL rzz_temporaryURLOrError:&error];
    XCTAssertTrue([[[ZZArchive rzz_temporaryArchiveWithContentsOfURL:[NSURL fileURLWithPath:@(__FILE__)].URLByDeletingLastPathComponent includeExtendedAttributes:YES]
        flattenMap:^RACSignal *(ZZArchive *archive) {
            return [archive rzz_unarchiveToURL:URL];
        }]
        waitUntilCompleted:&error]);
    NSString *newPath = [URL.path stringByAppendingPathComponent:@(__FILE__).lastPathComponent];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:newPath]);
}

- (void)testUnarchiveToTemporaryURL {
    NSError *error = nil;
    __block NSURL *URL = nil;
    XCTAssertTrue([[[[ZZArchive rzz_temporaryArchiveWithContentsOfURL:[NSURL fileURLWithPath:@(__FILE__)] includeExtendedAttributes:YES]
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

@end
