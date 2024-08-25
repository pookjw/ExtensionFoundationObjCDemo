//
//  ExtensionInterface.h
//  ExtensionFoundationObjCDemo
//
//  Created by Jinwoo Kim on 8/25/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ExtensionInterface <NSObject>
- (void)currentDateWithCompletionHandler:(void (^)(NSDate *date))completionHandler;
@end

NS_ASSUME_NONNULL_END
