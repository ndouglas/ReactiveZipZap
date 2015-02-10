//
//  NSURL+ReactiveZipZap.h
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RZZDefinitions.h"

@interface NSURL (ReactiveZipZap)

/**
 A URL to a temporary directory.
 
 
 @return A signal passing a URL.
 */

+ (RACSignal *)rzz_temporaryURL;

@end
