//
//  Cell.m
//  DNA
//
//  Created by Tolya on 01.11.12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "Cell.h"

const NSUInteger DefaultLength = 100;
NSString * const AllowedChars[] = { @"A", @"T", @"G", @"C" };

NSString *const DNAExceptionName = @"DNAException";

@interface Cell ()

+ (BOOL)isAllowedChar:(unichar)c;

@end

@implementation Cell

+ (id)DNAWithContentOfURL:(NSURL *)url
{
    Cell *cell = [[[self class] alloc] init];
    [cell loadFromURL:url];
    
    return cell;
}

- (id)init
{
    return [self initWithLength:DefaultLength];
}

- (id)initWithLength:(NSUInteger)length
{
    if (self = [super init]) {
        DNA = nil;
        _length = length;
    }
    
    return self;
}

- (id)initWithDNA:(NSMutableArray *)dna
{
    if (self = [super init]) {
        DNA = dna;
        _length = [dna count];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Cell *copy = [[[self class] allocWithZone:zone] initWithDNA:[DNA mutableCopy]];
    
    return copy;
}

- (void)createDNA
{
    DNA = [[NSMutableArray alloc] initWithCapacity:self.length];
    
    for (NSUInteger i = 0; i < self.length; i++) {
        [DNA addObject:[[self class] randomChar]];
    }
}

- (NSString *)stringValue
{
    return [DNA componentsJoinedByString:@""];
}

+ (NSString *)randomChar
{
    const NSUInteger allowedCharsCount = sizeof(AllowedChars) / sizeof(AllowedChars[0]);
    
    return AllowedChars[rand() % allowedCharsCount];
}

- (int)hammingDistance:(Cell *)anotherCell
{
    int diffsCount = 0;
    for (NSUInteger i = 0; i < self.length; i++) {
        NSString *leftDNA = [DNA objectAtIndex:i];
        NSString *rightDNA = [anotherCell->DNA objectAtIndex:i];
        
        if ([leftDNA compare:rightDNA] != NSOrderedSame)
            diffsCount++;
    }
    
    return diffsCount;
}

- (Cell *)makeCrossingWithDNA:(Cell *)dna usingCrossKind:(int)crossKind
{
    if (self.length != dna->_length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"DNAs have different length"
                                     userInfo:nil];
    }
    
    NSMutableArray *genes = [[NSMutableArray alloc] initWithCapacity:self.length];
    NSUInteger i = 0;
    switch (crossKind) {
        case 0:
            for (i = 0; i < self.length / 2; i++) {
                [genes addObject:[DNA objectAtIndex:i]];
            }
            for (; i < self.length; i++) {
                [genes addObject:[dna->DNA objectAtIndex:i]];
            }
            break;
        case 1:
            for (NSUInteger i = 1; i < self.length; i += 2) {
                [DNA replaceObjectAtIndex:i withObject:[dna->DNA objectAtIndex:i]];
            }
            break;
        case 2:
            for (NSUInteger i = 20 * self.length / 100; i < 60 * self.length / 100; i++) {
                [DNA replaceObjectAtIndex:i withObject:[dna->DNA objectAtIndex:i]];
            }
            break;
    }
    Cell *newDna = [[Cell alloc] initWithDNA:genes];

    return newDna;
}

+ (BOOL)isAllowedChar:(unichar)c
{
    const NSUInteger allowedCharsCount = sizeof(AllowedChars) / sizeof(AllowedChars[0]);
    for (NSUInteger i = 0; i < allowedCharsCount; i++) {
        if (c == [AllowedChars[i] characterAtIndex:0])
            return YES;
    }
    
    return NO;
}

- (void)loadFromURL:(NSURL *)url
{
    NSError *error;
    NSString *content = [NSString stringWithContentsOfURL:url
                                                 encoding:NSASCIIStringEncoding
                                                    error:&error];
    if (error){
        @throw [NSException exceptionWithName:DNAExceptionName
                                       reason:error.localizedDescription
                                     userInfo:nil];
    }
    
    for (NSUInteger i = 0; i < [content length]; i++) {
        unichar c = [content characterAtIndex:i];
        if (![[self class] isAllowedChar:c]) {
            @throw [NSException exceptionWithName:DNAExceptionName
                                           reason:[NSString stringWithFormat:@"'%c' is not allowed symbol for DNA.", c]
                                         userInfo:nil];
        }
    }
    
    DNA = [[NSMutableArray alloc] initWithCapacity:[content length]];
    for (NSUInteger i = 0; i < [content length]; i++)
        [DNA addObject:[NSString stringWithFormat:@"%c", [content characterAtIndex:i]]];
    self.length = [DNA count];
}

- (NSString *)description
{
    return [self stringValue];
}

@end
