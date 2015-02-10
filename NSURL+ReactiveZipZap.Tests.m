//
//  NSURL+ReactiveZipZap.Tests.m
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "ReactiveZipZap.h"

@interface NSURL_ReactiveZipZapTests : XCTestCase
@property (copy, nonatomic, readwrite) NSURL *temporaryURL;
@property (copy, nonatomic, readwrite) NSURL *ephemeralURL;
@end

@implementation NSURL_ReactiveZipZapTests
@synthesize temporaryURL;
@synthesize ephemeralURL;

- (void)setUp {
	[super setUp];
    self.temporaryURL = [[NSURL rzz_temporaryURL] first];
    self.ephemeralURL = [[NSURL rzz_ephemeralURL] first];
}

- (void)tearDown {
    [[NSFileManager defaultManager] removeItemAtURL:self.temporaryURL error:NULL];
	[super tearDown];
}

- (void)testTemporaryURL {
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self.temporaryURL.path]);
}

- (void)testEphemeralURL {
    XCTAssertTrue(![[NSFileManager defaultManager] fileExistsAtPath:self.ephemeralURL.path]);
}

- (void)testNamesOfExtendedAttributesWithError {
	NSURL *URL = [NSURL fileURLWithPath:@(__FILE__)];
    XCTAssertNotNil(URL);
    NSError *error = nil;
    NSArray *names = [URL rzz_namesOfExtendedAttributesWithError:&error];
    XCTAssertNotNil(names);
}

- (void)testSetValueForExtendedAttributeWithNameError {
	NSURL *URL = [NSURL fileURLWithPath:@(__FILE__)];
    XCTAssertNotNil(URL);
    NSError *error = nil;
    NSString *testAttributeName = @"testAttributeName";
    NSString *testAttributeValue = @"testAttributeValue";
    NSArray *names = [URL rzz_namesOfExtendedAttributesWithError:&error];
    if (!names) {
        XCTAssertTrue([URL rzz_setValue:[testAttributeValue dataUsingEncoding:NSUTF8StringEncoding] forExtendedAttributeWithName:testAttributeName error:&error]);
        names = [URL rzz_namesOfExtendedAttributesWithError:&error];
    }
    XCTAssertNotNil(names);
    if ([names containsObject:testAttributeName]) {
        XCTAssertTrue([URL rzz_removeExtendedAttributeWithName:testAttributeName error:&error]);
    }
    XCTAssertTrue([URL rzz_setValue:[testAttributeValue dataUsingEncoding:NSUTF8StringEncoding] forExtendedAttributeWithName:testAttributeName error:&error]);
    XCTAssertEqualObjects([[NSString alloc] initWithData:[URL rzz_valueForExtendedAttributeWithName:testAttributeName error:&error] encoding:NSUTF8StringEncoding], testAttributeValue);
    XCTAssertTrue([URL rzz_removeExtendedAttributeWithName:testAttributeName error:&error]);
}

@end
