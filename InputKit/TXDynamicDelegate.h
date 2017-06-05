//
//  TXDynamicDelegate.h
//  InputKit
//
//  Created by tingxins on 31/05/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    SEL setter;
    SEL tx_setter;
    SEL getter;
} TXDynamicDelegateInfos;

@interface TXDynamicDelegate : NSProxy {
    const char *_key;
}


/**
 注意：如果 realDelegate 是被代理本身，例如：realDelegate 是 TXLimitedTextField，则有可能出现消息无限转发问题，应当尽量避免使用self.delegate = self;
 */
@property (weak, nonatomic) id realDelegate;

- (instancetype)initWithKey:(const char *)key;

/**
 给 realDelegate 发送消息

 @param component 事件产生组件
 @param selector 方法名
 */
- (void)sendMsgToObject:(id)obj with:(id)component SEL:(SEL)selector;

@end


@interface NSObject (TXOperationDelegate)

+ (void)tx_registerDynamicDelegate;

@end
