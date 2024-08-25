//
//  Extension.m
//  Extension
//
//  Created by Jinwoo Kim on 8/25/24.
//

#import "Extension.h"
#import "ExportedObject.h"
#import <objc/runtime.h>

/*
 Swift의 경우
 extension main에서
 -[_EXRunningUIExtension setSceneFactory:]를 호출
 
 protocol : _EXExtensionSceneFactory
 -makeSceneWithConfiguration:
 
 returns: id<_TtP12ExtensionKit13SceneProtocol_>
 - (id) view; (0x1fb516980)
 - (void) setView:(id)arg1; (0x1fb516990)
 - (_Bool) shouldAcceptConnection:(id)arg1;
 
 Objective-C의 경우 Info.plist에 정의만 하면 되며
 
 이러한 언어에 따른 분기는 -[_EXUISceneSession makeSceneWithError:]에서 hasSwiftEntryPoint로 이뤄진다.
 
 또한 Storyboard 없이 하려면 -[_EXViewControllerSceneConfiguration setViewControllerClass:]로 할 수 있는데,
 -[_EXExtensionIdentity(SceneProviding) configurationWithParameters:]을 보면 Storyboard여야 _EXViewControllerSceneConfiguration 생성을 해주기 때문에, -setViewControllerClass:를 정상적인 방법으로 호출할 수 없다.
 */

@implementation Extension

+ (void)load {
    assert(class_addProtocol(self, NSProtocolFromString(@"_EXConnectionHandler")));
}

- (BOOL)shouldAcceptXPCConnection:(NSXPCConnection *)connection {
    connection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ExtensionInterface)];
    
    ExportedObject *exportedObject = [ExportedObject new];
    connection.exportedObject = exportedObject;
    [exportedObject release];
    
    [connection resume];
    
    return YES;
}

@end
