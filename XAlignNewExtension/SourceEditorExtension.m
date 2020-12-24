//
//  SourceEditorExtension.m
//  XAlignNewExtension
//
//  Created by 李晓龙 on 2020/12/23.
//

#import "SourceEditorExtension.h"
#import "PatternManager.h"

@implementation SourceEditorExtension


- (void)extensionDidFinishLaunching
{
    // If your extension needs to do any work at launch, implement this optional method.
    /// 前期配置
    [PatternManager launch];
    NSLog(@"先");
}


/*
- (NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions
{
    // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
    return @[];
}
*/

@end
