//
//  SourceEditorCommand.m
//  XAlignNewExtension
//
//  Created by 李晓龙 on 2020/12/23.
//

#import "SourceEditorCommand.h"
//#import "XAlignNewPattern.h"
//#import "XAlignNewPattern.h"
#import "NSString+XAlign.h"
#import "PatternManager.h"


@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    NSLog(@"后");
    if ([invocation.commandIdentifier hasSuffix:@"SourceEditorCommand"])
    {
        [[self class] autoAlign:invocation];
    }
    
    completionHandler(nil);
}

+ (void)autoAlign:(XCSourceEditorCommandInvocation *)invocation
{
    NSLog(@"hello world");
    NSMutableArray * selections = [NSMutableArray array];
    
    // 遍历了选中的行，然后存入数组selection
    for ( XCSourceTextRange *range in invocation.buffer.selections ){
        for ( NSInteger i = range.start.line; i < range.end.line ; i++){
            [selections addObject:invocation.buffer.lines[i]];
        }
    }
    

    NSString * selectedString = [selections componentsJoinedByString:@""];
    NSArray * patternGroup = [PatternManager patternGroupMatchWithString:selectedString];
    
    
    NSLog(@"hello world1");
    if ( !patternGroup )
        return;
    
    // 这里去调回调 拼接 成带\n的一个完整字符串，内部进行了空格数量计算
    NSString * alignedString = [selectedString stringByAligningWithPatterns:patternGroup];
    // 以换行符分割成数组
    NSArray * result = [alignedString componentsSeparatedByString:@"\n"];

    for ( XCSourceTextRange *range in invocation.buffer.selections )
    {
        for ( NSInteger i = range.start.line, j=0; i < range.end.line ; i++, j++ )
        {
            invocation.buffer.lines[i] = result[j];
        }
    }
}


@end
