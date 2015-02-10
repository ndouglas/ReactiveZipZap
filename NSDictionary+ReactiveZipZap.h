//
//  NSDictionary+ReactiveZipZap.h
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RZZDefinitions.h"

@interface NSDictionary (ReactiveZipZap)

/**
 Retrieves the dictionary of extended attributes with names and values.
 
 @param URL The URL of the item.
 @param error An error object populated in the event of failure.
 */

+ (instancetype)rzz_dictionaryWithExtendedAttributesAtURL:(NSURL *)URL error:(NSError **)error;

@end
