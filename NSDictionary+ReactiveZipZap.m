//
//  NSDictionary+ReactiveZipZap.m
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "NSDictionary+ReactiveZipZap.h"
#import "ReactiveZipZap.h"

@implementation NSDictionary (ReactiveZipZap)

+ (instancetype)rzz_dictionaryWithExtendedAttributesAtURL:(NSURL *)URL error:(NSError **)error {
    return [URL rzz_dictionaryWithExtendedAttributesOrError:error];
}

@end
