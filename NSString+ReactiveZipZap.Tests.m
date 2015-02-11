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

@interface NSString ()
+ (NSString *)rzz_pathToTemporaryArea;
@end

@implementation NSString_ReactiveZipZapTests
@synthesize temporaryPath;
@synthesize ephemeralPath;

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testTemporaryPath {
    self.temporaryPath = [[NSString rzz_temporaryPath] first];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self.temporaryPath]);
    [[NSFileManager defaultManager] removeItemAtPath:self.temporaryPath error:NULL];
    XCTAssertTrue(![[NSFileManager defaultManager] fileExistsAtPath:self.temporaryPath]);
}

- (void)testEphemeralPath {
    self.ephemeralPath = [[NSString rzz_ephemeralPath] first];
    XCTAssertTrue(![[NSFileManager defaultManager] fileExistsAtPath:self.ephemeralPath]);
}

- (void)testCleanTemporaryAreaOrError {
    for (int i = 0; i < 50; i++) {
        [[NSString rzz_temporaryPath] first];
    }
    NSError *error = nil;
    XCTAssertTrue([NSString rzz_cleanTemporaryAreaOrError:&error]);
    XCTAssertNotNil([[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString rzz_pathToTemporaryArea] error:&error]);
    XCTAssertTrue([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString rzz_pathToTemporaryArea] error:&error] count] == 0);
}

- (void)testCleanTemporaryAreaOfItemsOlderThanDateError {
    for (int i = 0; i < 50; i++) {
        [[NSString rzz_temporaryPath] first];
    }
    NSError *error = nil;
    XCTAssertNotNil([[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString rzz_pathToTemporaryArea] error:&error]);
    XCTAssertTrue([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString rzz_pathToTemporaryArea] error:&error] count] == 50);
    XCTAssertTrue([NSString rzz_cleanTemporaryAreaOfItemsOlderThanDate:[NSDate date] error:&error]);
    XCTAssertNotNil([[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString rzz_pathToTemporaryArea] error:&error]);
    XCTAssertTrue([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString rzz_pathToTemporaryArea] error:&error] count] == 0);
}

@end
