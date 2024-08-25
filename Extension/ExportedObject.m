//
//  ExportedObject.m
//  Extension
//
//  Created by Jinwoo Kim on 8/25/24.
//

#import "ExportedObject.h"

@implementation ExportedObject

- (void)currentDateWithCompletionHandler:(void (^)(NSDate * _Nonnull))completionHandler {
    completionHandler([NSDate now]);
}

@end
