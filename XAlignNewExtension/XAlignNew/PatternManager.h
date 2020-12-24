//
//  patternManager.h
//  XAlignNewExtension
//
//  Created by 李晓龙 on 2020/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 位置
typedef enum XAlignPosition{
    XAlignPositionFisrt = -1,
    XAlignPositionLast,
} XAlignPosition;

/// 填充
typedef enum XAlignPaddingMode {
    XAlignPaddingModeNone = 0,
    XAlignPaddingModeMin,
    XAlignPaddingModeMax,
} XAlignPaddingMode;

typedef NSString *_Nonnull(^XAlignPatternControlBlockU)(NSUInteger padding);
typedef NSString *_Nonnull (^XAlignPatternControlBlockUS)(NSUInteger padding, NSString * match);

@interface XAlignPadding : NSObject
+ (NSString *)stringWithFormat:(NSString *)format;
@end

@interface PatternNew : NSObject
@property (nonatomic, assign) BOOL isOptional;
@property (nonatomic, retain) NSString * string;
@property (nonatomic, assign) XAlignPosition position;
@property (nonatomic, assign) XAlignPaddingMode headMode;
@property (nonatomic, assign) XAlignPaddingMode matchMode;
@property (nonatomic, assign) XAlignPaddingMode tailMode;
@property (nonatomic, copy)   XAlignPatternControlBlockUS control;
+ (NSArray *)patterns;
@end



@interface PatternManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSMutableDictionary * specifiers;

+ (void)launch;

+ (void)setupWithRawArray:(NSArray *)array;

+ (NSArray *)patternGroupMatchWithString:(NSString *)string;
+ (NSArray *)patternGroupWithDictinary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
