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
@end

@implementation NSURL_ReactiveZipZapTests

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testTemporaryURL {
    NSURL *temporaryURL = [NSURL rzz_temporaryURLOrError:NULL];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:temporaryURL.path]);
    [[NSFileManager defaultManager] removeItemAtURL:temporaryURL error:NULL];
    XCTAssertTrue(![[NSFileManager defaultManager] fileExistsAtPath:temporaryURL.path]);
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
