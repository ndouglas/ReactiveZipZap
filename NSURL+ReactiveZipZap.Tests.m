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

- (BOOL)singularlyReadExtendedAttributesForItemAtURL:(NSURL *)URL {
    NSError *error = nil;
    static NSUInteger counter = 0;
    counter++;
    NSLog(@"Counter: %@", @(counter));
    NSLog(@"Reading extended attributes of item at URL: %@", URL);
    NSDictionary *dictionary = [URL rzz_dictionaryWithExtendedAttributesOrError:&error];
    BOOL result = dictionary != nil;
    XCTAssertTrue(result, @"Fetching extended attributes of URL: %@ failed with error: %@", URL, error);
    if (result) {
        NSLog(@"Read extended attributes of item at URL: %@ %@", URL, dictionary);
    }
    return result;
}

- (BOOL)recursivelyReadExtendedAttributesForItemAtURL:(NSURL *)URL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL result = NO;
    if ([fileManager fileExistsAtPath:URL.path isDirectory:&isDirectory]) {
        result = [self singularlyReadExtendedAttributesForItemAtURL:URL];
        if (result) {
            if (isDirectory) {
                NSError *error = nil;
                NSArray *contents = [fileManager contentsOfDirectoryAtURL:URL includingPropertiesForKeys:nil options:0 error:&error];
                XCTAssertTrue(contents != nil, @"Fetching contents of directory at URL: %@ failed with error: %@", URL, error);
                if (contents) {
                    for (NSURL *thisContentURL in contents) {
                        result = [self recursivelyReadExtendedAttributesForItemAtURL:thisContentURL];
                        if (!result) {
                            break;
                        }
                    }
                }
            }
        }
    } else {
        XCTFail(@"No item at URL: %@", URL);
    }
    return result;
}

- (void)testReadExtendedAttributesForALotOfFiles {
    [self recursivelyReadExtendedAttributesForItemAtURL:[NSURL fileURLWithPath:@"/Users/nathan/Documents/RSS.dtBase2"]];
}

@end
