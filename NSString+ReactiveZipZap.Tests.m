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

- (BOOL)singularlyReadExtendedAttributesForItemAtPath:(NSString *)path {
    NSError *error = nil;
    static NSUInteger counter = 0;
    counter++;
    NSLog(@"Counter: %@", @(counter));
    NSLog(@"Reading extended attributes of item at path: %@", path);
    NSDictionary *dictionary = [path rzz_dictionaryWithExtendedAttributesOrError:&error];
    BOOL result = dictionary != nil;
    XCTAssertTrue(result, @"Fetching extended attributes of path: %@ failed with error: %@", path, error);
    if (result) {
        NSLog(@"Read extended attributes of item at path: %@ %@", path, dictionary);
    }
    return result;
}

- (BOOL)recursivelyReadExtendedAttributesForItemAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL result = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        result = [self singularlyReadExtendedAttributesForItemAtPath:path];
        if (result) {
            if (isDirectory) {
                NSError *error = nil;
                NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:&error];
                XCTAssertTrue(contents != nil, @"Fetching contents of directory at path: %@ failed with error: %@", path, error);
                if (contents) {
                    for (NSString *thisContent in contents) {
                        NSString *newPath = [path stringByAppendingPathComponent:thisContent];
                        result = [self recursivelyReadExtendedAttributesForItemAtPath:newPath];
                        if (!result) {
                            break;
                        }
                    }
                }
            }
        }
    } else {
        XCTFail(@"No item at path: %@", path);
    }
    return result;
}

- (void)testReadExtendedAttributesForALotOfFiles {
    [self recursivelyReadExtendedAttributesForItemAtPath:@"/Users/nathan/Documents/Goats.txt"];
}

@end
