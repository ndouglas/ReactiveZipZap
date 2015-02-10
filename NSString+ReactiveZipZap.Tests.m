//
//  NSString+ReactiveZipZap.Tests.m
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "ReactiveZipZap.h"

@interface NSString_ReactiveZipZapTests : XCTestCase {
}
@property (copy, nonatomic, readwrite) NSString *temporaryPath;
@property (copy, nonatomic, readwrite) NSString *ephemeralPath;
@end

@implementation NSString_ReactiveZipZapTests
@synthesize temporaryPath;
@synthesize ephemeralPath;

- (void)setUp {
	[super setUp];
    self.temporaryPath = [[NSString rzz_temporaryPath] first];
    self.ephemeralPath = [[NSString rzz_ephemeralPath] first];
}

- (void)tearDown {
    [[NSFileManager defaultManager] removeItemAtPath:self.temporaryPath error:NULL];
	[super tearDown];
}

- (void)testTemporaryPath {
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self.temporaryPath]);
}

- (void)testEphemeralPath {
    XCTAssertTrue(![[NSFileManager defaultManager] fileExistsAtPath:self.ephemeralPath]);
}

@end
