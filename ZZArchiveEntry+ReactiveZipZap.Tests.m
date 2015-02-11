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
    NSURL *URL = [[NSURL rzz_temporaryURLOrError:NULL] URLByAppendingPathComponent:@"test"];
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
    NSURL *URL = [[NSURL rzz_temporaryURLOrError:NULL] URLByAppendingPathComponent:@"test"];
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
    NSError *error = nil;
    NSDictionary *extendedAttributes = [myURL rzz_dictionaryWithExtendedAttributesOrError:&error];
    XCTAssertNotNil(extendedAttributes);
    NSArray *archiveEntries = [[[ZZArchiveEntry rzz_archiveEntriesOfFileAtURL:myURL includeExtendedAttributes:YES] collect] first];
    XCTAssertNotNil(archiveEntries);
    ZZArchive *archive = [[ZZArchive rzz_temporaryArchive] first];
    XCTAssertNotNil(archive);
    XCTAssertTrue([archive updateEntries:archiveEntries error:&error]);
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
    NSURL *URL = [[NSURL rzz_temporaryURLOrError:NULL] URLByAppendingPathComponent:@"test"];
    XCTAssertTrue([[fileEntry rzz_writeToURL:URL] waitUntilCompleted:&error]);
    XCTAssertTrue([[xattrEntry rzz_writeAsExtendedAttributesToURL:URL] waitUntilCompleted:&error]);
    NSData *data2 = [NSData dataWithContentsOfURL:URL];
    XCTAssertNotNil(data2);
    XCTAssertEqualObjects(data, data2);
    NSDictionary *extendedAttributes2 = [URL rzz_dictionaryWithExtendedAttributesOrError:&error];
    XCTAssertNotNil(extendedAttributes2);
    XCTAssertEqualObjects(extendedAttributes, extendedAttributes2);
}

- (void)testArchiveEntriesOfDirectoryAtURLIncludeExtendedAttributes {
    NSURL *myURL = [[NSURL fileURLWithPath:@(__FILE__)] URLByDeletingLastPathComponent];
    NSError *error = nil;
    XCTAssertTrue([myURL rzz_setValue:[[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding] forExtendedAttributeWithName:[[NSUUID UUID] UUIDString] error:&error]);
    XCTAssertNotNil(myURL);
    NSDictionary *extendedAttributes = [myURL rzz_dictionaryWithExtendedAttributesOrError:&error];
    XCTAssertNotNil(extendedAttributes);
    NSArray *archiveEntries = [[[ZZArchiveEntry rzz_archiveEntriesOfDirectoryAtURL:myURL includeExtendedAttributes:YES] collect] first];
    XCTAssertNotNil(archiveEntries);
    ZZArchive *archive = [[ZZArchive rzz_temporaryArchive] first];
    XCTAssertNotNil(archive);
    XCTAssertTrue([archive updateEntries:archiveEntries error:&error]);
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
    NSURL *URL = [[NSURL rzz_temporaryURLOrError:NULL] URLByAppendingPathComponent:@"test"];
    XCTAssertTrue([[fileEntry rzz_writeToURL:URL] waitUntilCompleted:&error]);
    XCTAssertTrue([[xattrEntry rzz_writeAsExtendedAttributesToURL:URL] waitUntilCompleted:&error]);
    NSDictionary *extendedAttributes2 = [URL rzz_dictionaryWithExtendedAttributesOrError:&error];
    XCTAssertNotNil(extendedAttributes2);
    XCTAssertEqualObjects(extendedAttributes, extendedAttributes2);
}

- (void)testArchiveEntriesOfDirectoryContentsAtURLIncludeExtendedAttributes {
    NSURL *myURL = [[NSURL fileURLWithPath:@(__FILE__)] URLByDeletingLastPathComponent];
    NSError *error = nil;
    XCTAssertTrue([myURL rzz_setValue:[[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding] forExtendedAttributeWithName:[[NSUUID UUID] UUIDString] error:&error]);
    XCTAssertNotNil(myURL);
    NSDictionary *extendedAttributes = [myURL rzz_dictionaryWithExtendedAttributesOrError:&error];
    XCTAssertNotNil(extendedAttributes);
    NSArray *archiveEntries = [[[ZZArchiveEntry rzz_archiveEntriesOfDirectoryContentsAtURL:myURL includeExtendedAttributes:YES] collect] first];
    XCTAssertNotNil(archiveEntries);
    ZZArchive *archive = [[ZZArchive rzz_temporaryArchive] first];
    XCTAssertNotNil(archive);
    XCTAssertTrue([archive updateEntries:archiveEntries error:&error]);
    archiveEntries = archive.entries;
    XCTAssertNotNil(archiveEntries);
}

- (void)testArchiveEntriesOfItemAtURLIncludeExtendedAttributes {
    NSURL *myURL = [NSURL fileURLWithPath:@(__FILE__)];
    XCTAssertNotNil(myURL);
    NSData *data = [NSData dataWithContentsOfURL:myURL];
    XCTAssertNotNil(data);
    NSError *error = nil;
    NSDictionary *extendedAttributes = [myURL rzz_dictionaryWithExtendedAttributesOrError:&error];
    XCTAssertNotNil(extendedAttributes);
    NSArray *archiveEntries = [[[ZZArchiveEntry rzz_archiveEntriesOfItemAtURL:myURL includeExtendedAttributes:YES] collect] first];
    XCTAssertNotNil(archiveEntries);
    ZZArchive *archive = [[ZZArchive rzz_temporaryArchive] first];
    XCTAssertNotNil(archive);
    XCTAssertTrue([archive updateEntries:archiveEntries error:&error]);
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
    NSURL *URL = [[NSURL rzz_temporaryURLOrError:NULL] URLByAppendingPathComponent:@"test"];
    XCTAssertTrue([[fileEntry rzz_writeToURL:URL] waitUntilCompleted:&error]);
    XCTAssertTrue([[xattrEntry rzz_writeAsExtendedAttributesToURL:URL] waitUntilCompleted:&error]);
    NSData *data2 = [NSData dataWithContentsOfURL:URL];
    XCTAssertNotNil(data2);
    XCTAssertEqualObjects(data, data2);
    NSDictionary *extendedAttributes2 = [URL rzz_dictionaryWithExtendedAttributesOrError:&error];
    XCTAssertNotNil(extendedAttributes2);
    XCTAssertEqualObjects(extendedAttributes, extendedAttributes2);
    
    myURL = [[NSURL fileURLWithPath:@(__FILE__)] URLByDeletingLastPathComponent];
    XCTAssertTrue([myURL rzz_setValue:[[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding] forExtendedAttributeWithName:[[NSUUID UUID] UUIDString] error:&error]);
    XCTAssertNotNil(myURL);
    extendedAttributes = [myURL rzz_dictionaryWithExtendedAttributesOrError:&error];
    XCTAssertNotNil(extendedAttributes);
    archiveEntries = [[[ZZArchiveEntry rzz_archiveEntriesOfItemAtURL:myURL includeExtendedAttributes:YES] collect] first];
    XCTAssertNotNil(archiveEntries);
    archive = [[ZZArchive rzz_temporaryArchive] first];
    XCTAssertNotNil(archive);
    XCTAssertTrue([archive updateEntries:archiveEntries error:&error]);
    archiveEntries = archive.entries;
    XCTAssertNotNil(archiveEntries);
    fileEntry = archiveEntries[0];
    XCTAssertNotNil(fileEntry);
    xattrEntry = archiveEntries[1];
    XCTAssertNotNil(xattrEntry);
    if ([xattrEntry.fileName rangeOfString:RZZXattrFilenamePrefix].location == NSNotFound) {
        fileEntry = archiveEntries[1];
        xattrEntry = archiveEntries[0];
    }
    URL = [[NSURL rzz_temporaryURLOrError:NULL] URLByAppendingPathComponent:@"test"];
    XCTAssertTrue([[fileEntry rzz_writeToURL:URL] waitUntilCompleted:&error]);
    XCTAssertTrue([[xattrEntry rzz_writeAsExtendedAttributesToURL:URL] waitUntilCompleted:&error]);
    extendedAttributes2 = [URL rzz_dictionaryWithExtendedAttributesOrError:&error];
    XCTAssertNotNil(extendedAttributes2);
    XCTAssertEqualObjects(extendedAttributes, extendedAttributes2);
}


#undef __CLASS__
@end
