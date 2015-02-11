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
@end

@interface NSString ()
+ (NSString *)rzz_pathToTemporaryArea;
@end

@implementation NSString_ReactiveZipZapTests

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testTemporaryPath {
    NSString *temporaryPath = [NSString rzz_temporaryPathOrError:NULL];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:temporaryPath]);
    [[NSFileManager defaultManager] removeItemAtPath:temporaryPath error:NULL];
    XCTAssertTrue(![[NSFileManager defaultManager] fileExistsAtPath:temporaryPath]);
}

- (void)testCleanTemporaryAreaOrError {
    for (int i = 0; i < 50; i++) {
        [NSString rzz_temporaryPathOrError:NULL];
    }
    NSError *error = nil;
    XCTAssertTrue([NSString rzz_cleanTemporaryAreaOrError:&error]);
    XCTAssertNotNil([[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString rzz_pathToTemporaryArea] error:&error]);
    XCTAssertTrue([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString rzz_pathToTemporaryArea] error:&error] count] == 0);
}

- (void)testCleanTemporaryAreaOfItemsOlderThanDateError {
    for (int i = 0; i < 50; i++) {
        [NSString rzz_temporaryPathOrError:NULL];
    }
    NSError *error = nil;
    XCTAssertNotNil([[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString rzz_pathToTemporaryArea] error:&error]);
    XCTAssertTrue([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString rzz_pathToTemporaryArea] error:&error] count] == 50);
    XCTAssertTrue([NSString rzz_cleanTemporaryAreaOfItemsOlderThanDate:[NSDate date] error:&error]);
    XCTAssertNotNil([[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString rzz_pathToTemporaryArea] error:&error]);
    XCTAssertTrue([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString rzz_pathToTemporaryArea] error:&error] count] == 0);
}

@end
