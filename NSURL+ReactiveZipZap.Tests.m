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

@end
