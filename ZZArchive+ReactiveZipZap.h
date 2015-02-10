//
//  ZZArchive+ReactiveZipZap.h
//  ReactiveZipZap
//
//  Created by Nathan Douglas on 2/10/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RZZDefinitions.h"

@interface ZZArchive (ReactiveZipZap)

/**
 The archive at the specified URL, if it exists.
 
 @param URL The URL at which the archive should be found.
 @return An initialized instance of the class.
 */

+ (RACSignal *)rzz_archiveAtURL:(NSURL *)URL;

@end
