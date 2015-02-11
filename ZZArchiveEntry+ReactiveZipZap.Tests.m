//
//  ZZArchiveEntry+ReactiveZipZap.Tests.m
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "ReactiveZipZap.h"

@interface ZZArchiveEntry_ReactiveZipZapTests : XCTestCase {
}
@property (copy, nonatomic, readwrite) NSString *UUID;
@end

@implementation ZZArchiveEntry_ReactiveZipZapTests
@synthesize UUID;

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}

- (ZZArchiveEntry *)oldArchiveEntryForNewArchiveEntry:(ZZArchiveEntry *)archiveEntry {
    NSError *error = nil;
    NSURL *URL = [[[NSURL rzz_temporaryURL] first] URLByAppendingPathComponent:@"test"];
    ZZArchive *archive = [[ZZArchive rzz_newArchiveAtURL:URL] first];
    XCTAssertTrue([archive updateEntries:@[archiveEntry] error:&error]);
    ZZArchiveEntry *result = [[archive entries] firstObject];
    return result;
}

- (void)testArchiveEntryWithNameData {
    NSData *data = [NSData dataWithContentsOfFile:@(__FILE__)];
    ZZArchiveEntry *storedArchiveEntry = [self oldArchiveEntryForNewArchiveEntry:[[ZZArchiveEntry rzz_archiveEntryWithName:@"Test" data:data] first]];
    NSData *data2 = [[storedArchiveEntry rzz_data] first];
    XCTAssertEqualObjects(data, data2);
}

- (void)testArchiveEntryOfFileAtURL {
    NSURL *URL = [[[NSURL rzz_temporaryURL] first] URLByAppendingPathComponent:@"test"];
    NSError *error = nil;
    ZZArchiveEntry *archiveEntry = [[ZZArchiveEntry rzz_archiveEntryOfFileAtURL:[NSURL fileURLWithPath:@(__FILE__)]] first];
    XCTAssertTrue([[[self oldArchiveEntryForNewArchiveEntry:archiveEntry] rzz_writeToURL:URL] waitUntilCompleted:&error]);
    NSData *data1 = [NSData dataWithContentsOfURL:URL];
    NSData *data2 = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:@(__FILE__)]];
    XCTAssertTrue([data1 isEqual:data2]);
}

- (void)testArchiveEntryOfExtendedAttributesAtURL {
    NSError *error = nil;
    NSDictionary *extendedAttributes = [[NSURL fileURLWithPath:@(__FILE__)] rzz_dictionaryWithExtendedAttributesOrError:&error];
    XCTAssertNotNil(extendedAttributes);
    NSData *extendedAttributeData = [NSKeyedArchiver archivedDataWithRootObject:extendedAttributes];
    ZZArchiveEntry *archiveEntry = [self oldArchiveEntryForNewArchiveEntry:[[ZZArchiveEntry rzz_archiveEntryWithName:@"Test" data:extendedAttributeData] first]];
    NSData *data2 = [[archiveEntry rzz_data] first];
    NSDictionary *extendedAttributes2 = [NSKeyedUnarchiver unarchiveObjectWithData:data2];
    XCTAssertEqualObjects(extendedAttributes, extendedAttributes2);
}

- (void)testArchiveEntriesOfFileAtURLIncludeExtendedAttributes {
    NSURL *myURL = [NSURL fileURLWithPath:@(__FILE__)];
    XCTAssertNotNil(myURL);
    NSData *data = [NSData dataWithContentsOfURL:myURL];
    XCTAssertNotNil(data);
    NSDictionary *extendedAttributes = [myURL rzz_dictionaryWithExtendedAttributesOrError:NULL];
    XCTAssertNotNil(extendedAttributes);
    NSArray *archiveEntries = [[[ZZArchiveEntry rzz_archiveEntriesOfFileAtURL:myURL includeExtendedAttributes:YES] collect] first];
    XCTAssertNotNil(archiveEntries);
    ZZArchive *archive = [[ZZArchive rzz_temporaryArchive] first];
    XCTAssertNotNil(archive);
    XCTAssertTrue([archive updateEntries:archiveEntries error:NULL]);
    archiveEntries = archive.entries;
    XCTAssertNotNil(archiveEntries);
    ZZArchiveEntry *fileEntry = archiveEntries[0];
    XCTAssertNotNil(fileEntry);
    ZZArchiveEntry *xattrEntry = archiveEntries[1];
    XCTAssertNotNil(xattrEntry);
    if ([xattrEntry.fileName rangeOfString:RZZXattrFilenamePrefix].location == NSNotFound) {
        fileEntry = archiveEntries[1];
        xattrEntry = archiveEntries[0];
    }
    NSURL *URL = [[[NSURL rzz_temporaryURL] first] URLByAppendingPathComponent:@"test"];
    NSError *error = nil;
    XCTAssertTrue([[fileEntry rzz_writeToURL:URL] waitUntilCompleted:&error]);
    XCTAssertTrue([[xattrEntry rzz_writeAsExtendedAttributesToURL:URL] waitUntilCompleted:&error]);
    NSData *data2 = [NSData dataWithContentsOfURL:URL];
    XCTAssertNotNil(data2);
    XCTAssertEqualObjects(data, data2);
    NSDictionary *extendedAttributes2 = [URL rzz_dictionaryWithExtendedAttributesOrError:NULL];
    XCTAssertNotNil(extendedAttributes2);
    XCTAssertEqualObjects(extendedAttributes, extendedAttributes2);
}

#undef __CLASS__
@end

/**
+ (RACSignal *)rzz_archiveEntriesOfFileAtURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes;
+ (RACSignal *)rzz_archiveEntriesOfDirectoryAtURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes;
+ (RACSignal *)rzz_archiveEntriesOfDirectoryContentsAtURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes;
+ (RACSignal *)rzz_archiveEntriesOfItemAtURL:(NSURL *)URL includeExtendedAttributes:(BOOL)includeExtendedAttributes;
+ (RACSignal *)rzz_archiveEntriesOfItemsAtURLs:(NSArray *)URLs includeExtendedAttributes:(BOOL)includeExtendedAttributes;
- (RACSignal *)rzz_writeToURL:(NSURL *)URL;
- (RACSignal *)rzz_writeAsExtendedAttributesToURL:(NSURL *)URL;
*/
