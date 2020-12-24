//
//  NSString+XAlign2.m
//  main
//
//  Created by QFish on 11/18/13.
//  Copyright (c) 2013 net.qfish. All rights reserved.
//

#import "NSString+XAlign.h"

#undef	____STEP_IIN
#define ____STEP_IIN(s)
#undef  ____STEP_OUT
#define ____STEP_OUT(s)

@interface XAlignLine : NSObject
@property (nonatomic, retain) NSMutableArray * partials;
+ (id)line;
- (NSString *)stringWithPaddings:(NSArray *)paddings patterns:(NSArray *)patterns;
@end

@implementation XAlignLine

+ (id)line
{
	return [[self alloc] init];
}

- (id)init
{
	self = [super init];
	
	if ( self )
	{
		self.partials = [NSMutableArray array];
	}
	
	return self;
}

- (int)sumOfPaddings:(NSArray *)paddings atRange:(NSRange)range
{
	int sum = 0;
	
	if ( NSMaxRange(range) > paddings.count )
		return 0;
	
	for ( NSUInteger i=range.location, j=1; j<=range.length; j++, i++)
	{
		sum += [paddings[i] intValue];
	}
	
	return sum;
}


/// 最终效果，再把arr里面的内容拼接成字符串返回
/// @param paddings <#paddings description#>
/// @param patterns <#patterns description#>
- (NSString *)stringWithPaddings:(NSArray *)paddings patterns:(NSArray *)patterns
{
	NSMutableString * string = [NSMutableString string];
	
	for ( int i=0; i < self.partials.count; i++ )
	{
		NSString * partial = self.partials[i];
		NSUInteger padding = [paddings[i] integerValue];
		NSString * tempString = nil;
		
		if ( partial.length )
		{
			/*
			 i: 0 1 2 3 4 5 6 7 8 9 10
                ----- --- --- --- ----
			 p:   0    1   2   3   4
			 */
			
			NSUInteger pIndex = i == 0 ? 0 : ( ( i + 1 ) / 2 - 1 );
			
            PatternNew * pattern = patterns[pIndex];
			
			// build string
			
			if ( 0 == i )
			{
				if ( XAlignPaddingModeNone == pattern.headMode )
					tempString = partial;
				else
					tempString = [partial stringByPaddingToLength:padding withString:@" " startingAtIndex:0];
			}
			else
			{
				switch ( i % 2 )
				{
					case 0: // tail
						if ( XAlignPaddingModeNone == pattern.tailMode )
							tempString = partial;
						else
                            /// 给头部后面加了一个空格
							tempString = [partial stringByPaddingToLength:padding withString:@" " startingAtIndex:0];
						break;
					case 1: // match
						tempString = pattern.control(padding, partial);
						break;
				}
			}
		}
		else
		{
			tempString = @"";
		}
		
		[string appendString:tempString];
	}
	
	return string.xtrimTail;
}

- (NSString *)description
{
	return [self.partials description];
}
@end

#pragma mark -

@implementation NSString (XAlign)


/// 去掉两端空格
- (NSString *)xtrim{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)xtrimTail
{
	NSError * error = nil;
    /// 正则表达式  https://github.com/pro648/tips/wiki/iOS%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F%E8%AF%AD%E6%B3%95%E5%85%A8%E9%9B%86
    /// \下一个字符标记为一个特殊字符、或一个原义字符、或一个向后引用    \s  空格   + 多个匹配   $ 结束位置
    /// 查看结果感觉是  把一个字符串首尾的空白符换为空  匹配字符以大小写分割？
    /// \\s+可以替换掉关键字之间的所有空白字符 --java   https://blog.csdn.net/xuxu120/article/details/72627508
	NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+$" options:NSRegularExpressionCaseInsensitive error:&error];
	
	if ( error )
		return self;
	
    /// 仍然是一个正则操作
    NSArray * matches = [regex matchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)];
	
	if ( 0 == matches.count )
		return self;
	
	return [self substringWithRange:NSMakeRange(0, [matches[0] range].location)];
}

- (NSUInteger)xlength
{
	return [self lengthWithTabWidth:kTabSize];
}

- (NSUInteger)lengthWithTabWidth:(NSUInteger)tabWidth
{
	const char * c = self.UTF8String;
    
    int count = 0;
    
    while ( *c )
	{
		if ( *c == '\t' )
			count += tabWidth;
		else
			count++;
        c++;
    }
    
    return count;
}

- (NSString *)stringByAligningWithPatterns:(NSArray *)patterns{
    /// 哦~~~~self 对应 selectedString。。。。
	return [self stringByAligningWithPatterns:patterns partialCount:(patterns.count * 2 + 1)];
}

- (NSString *)stringByAligningWithPatterns:(NSArray *)patterns partialCount:(NSUInteger)partialCount{
    /// 把self 按照\n 分割成数组
	NSArray * lines = [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    if ( lines.count <= 1 )
        return self;
	
	NSMutableArray * paddings     = [NSMutableArray array];
    NSMutableArray * processLines = [NSMutableArray array];
	
	for ( int j=0; j < partialCount; j++ )
	{
		[paddings addObject:@(-1)];
	}
	
	for ( NSString * line in lines )
    {
        // 通过类别返回一个字符串
		NSString * trimLine = line.xtrimTail;
		
		XAlignLine * xline = nil;
        /// 看的头疼，内部是个递归。。。就是把一条字符串，分割成数组，放到xline 指向的里面。。。
		[trimLine processLine:&xline level:(int)(patterns.count - 1) patterns:patterns paddings:paddings];
		
        /// 判断是加一个字符串对象 还是加一个数组对象
		if ( !xline )
		{
			[processLines addObject:trimLine];
		}
		else
		{
			[processLines addObject:xline];
		}
	}
	
	NSMutableString * newLines = [NSMutableString string];
	
	for ( int i=0; i < processLines.count; i++ )
	{
		id line = processLines[i];
		
		if ( [line isKindOfClass:[NSString class]] )
		{
			[newLines appendString:line];
		}
		else if ( [line isKindOfClass:[XAlignLine class]] )
		{
		 	[newLines appendString:[line stringWithPaddings:paddings patterns:patterns]];
		}
		
		if ( i != processLines.count - 1 )
		{
			[newLines appendString:@"\n"];
		}
	}
	
	return newLines;
}

/// 内部是递归，按照一定规则分割字符串，最终把数据作为数组放入line
- (void)processLine:(XAlignLine **)line level:(int)level patterns:(NSArray *)patterns paddings:(NSMutableArray *)paddings
{
	if ( level < 0 )
		return;
	/// 这里直接是赋值到pattern的string里了
    PatternNew * pattern = patterns[level];
	
	NSString * match = nil;
    /// 以=为中心，找到了前半段、后半段，变为两个字符串返回到这个数组。注意，这里是下面方法递归 得到的。
	NSArray * components = [self componentsSeparatedByRegexPattern:pattern.string position:pattern.position match:&match];

	if ( !match )
	{
		if ( !pattern.isOptional )
		{
			*line = nil;
			return;
		}
		else
		{
			components = @[ self, @"" ];
			match = @"";
		}
	}
	
	if ( nil == *line )
		*line = [XAlignLine line];
	
	XAlignLine * xline = *line;
	
	NSString * head = [components firstObject];
	NSString * tail = [components  lastObject];
	/// 递归遍历
	[head processLine:line level:(level-1) patterns:patterns paddings:paddings];
	
____STEP_IIN( head )
    // 头部
	if ( 0 == level && head )
	{
		// add head partial
		[xline.partials addObject:head];
		// get index for match padding
		NSInteger headIndex      = level;
		NSInteger headPadding    = [paddings[headIndex] integerValue];
		NSInteger newMatchPadding = head.xlength;
		switch ( pattern.headMode )
		{
			case XAlignPaddingModeMin:
			{
				headPadding = headPadding == -1 ? NSNotFound : headPadding;
				paddings[headIndex] = @( MIN( headPadding , newMatchPadding ) );
			}
				break;
			case XAlignPaddingModeMax:
			{
				headPadding = headPadding == -1 ? -1 : headPadding;
				paddings[headIndex] = @( MAX( headPadding , newMatchPadding ) );
			}
				break;
			default:
				paddings[headIndex] = @( newMatchPadding );
				break;
		}
	}
____STEP_OUT( head )
	
____STEP_IIN( match )
    // 中间匹配
	// add match partial
	[xline.partials addObject:match];
	// get index for match padding
    NSInteger matchIndex      = level * 2 + 1;
    NSInteger matchPadding    = [paddings[matchIndex] integerValue];
    NSInteger newMatchPadding = match.xlength;
	switch ( pattern.matchMode )
	{
		case XAlignPaddingModeMin:
		{
			matchPadding = matchPadding == -1 ? NSNotFound : matchPadding;
			paddings[matchIndex] = @( MIN( matchPadding , newMatchPadding ) );
		}
			break;
		case XAlignPaddingModeMax:
		{
			matchPadding = matchPadding == -1 ? -1 : matchPadding;
			paddings[matchIndex] = @( MAX( matchPadding , newMatchPadding ) );
		}
			break;
		default:
			paddings[matchIndex] = @( newMatchPadding );
			break;
	}
____STEP_OUT( match )
	
____STEP_IIN( tail )
	// add tail partial
	[xline.partials addObject:tail];
	// get index for match padding
	NSInteger tailIndex = level * 2 + 2;
	NSInteger tailPadding = [paddings[tailIndex] integerValue];
	NSInteger newTailPadding = tail.xlength;
	switch ( pattern.tailMode )
	{
		case XAlignPaddingModeMin:
		{
			tailPadding = tailPadding == -1 ? NSNotFound : tailPadding;
			paddings[tailIndex] = @( MIN( tailPadding , newTailPadding ) );
		}
			break;
		case XAlignPaddingModeMax:
		{
			tailPadding = tailPadding == -1 ? -1 : tailPadding;
			paddings[tailIndex] = @( MAX( tailPadding , newTailPadding ) );
		}
			break;
		default:
			paddings[tailIndex] = @( newTailPadding );
			break;
	}
	
____STEP_OUT( tail )
	
	//	NSLog( @"%d| head:%d| match:%d| tail:%d", level, level+1, level+2, level+3 );
	//	NSLog( @"\n  level:%d %@\n   head:%@\n   tail:%@\nmatch:%@", level, pattern, head, tail, match );
}

- (NSArray *)componentsSeparatedByRegexPattern:(NSString *)pattern position:(XAlignPosition)position match:(NSString **)match
{
	NSError * error = nil;
    /// 根据正则表达式匹配  其实就是取出 匹配的字符串
	NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
	
	if ( error )
	{
        /// 打印错误当前方法
		NSLog( @"[NSString+XAlign](%s): pattern is illegal. error: %@", __PRETTY_FUNCTION__, error );
		return nil;
	}
    
    /// https://blog.csdn.net/reylen/article/details/50723122
    /// 这个方法会返回一个结果数组，将所有匹配的结果返回
	NSArray * matches = [regex matchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)];
	
	if ( 0 == matches.count )
		return nil;
	
	NSTextCheckingResult * matchResult = nil;
	
//	for ( matchResult in matches )
//	{
//		NSLog( @"|||%@|||", [self substringWithRange:NSMakeRange(0, NSMaxRange([matchResult range]))]);
//	}
		
	switch ( position )
	{
		case XAlignPositionFisrt:
			matchResult = [matches firstObject];
			break;
		case XAlignPositionLast:
			matchResult = [matches lastObject];
			break;
			
		default:
			if ( position >= matches.count )
				matchResult = nil;
			else
				matchResult = matches[position-1];
			break;
	}
	
	if ( nil == match )
		return nil;

	*match = [self substringWithRange:[matchResult range]];
	
	NSRange headRange = NSMakeRange( 0, [matchResult range].location );
	NSRange tailRange = NSMakeRange( NSMaxRange([matchResult range]), self.length - NSMaxRange([matchResult range]) );// 这个是从= 后面空格后的字符串开始

	NSString * head = [self substringWithRange:headRange] ?: @"";// = 前半段
	NSString * tail = [self substringWithRange:tailRange] ?: @"";// = 后半段
	
	return @[ head, tail ];
}

@end
