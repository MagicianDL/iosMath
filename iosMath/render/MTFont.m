//
//  MTFont.m
//  iosMath
//
//  Created by Kostub Deshmukh on 5/18/16.
//
//

#import "MTFont.h"

@interface MTFont ()

@property (nonatomic) CGFontRef defaultCGFont;
@property (nonatomic) CTFontRef font;
@property (nonatomic) NSDictionary* mathTable;

@end

const int kDefaultFontSize = 30;

@implementation MTFont

- (instancetype) initFontWithName:(NSString*) name
{
    self = [super init];
    if (self ) {
        // CTFontCreateWithName does not load the complete math font, it only has about half the glyphs of the full math font.
        // In particular it does not have the math italic characters which breaks our variable rendering.
        // So we first load a CGFont from the file and then convert it to a CTFont.

        NSLog(@"Loading font %@", name);
        // Uses bundle for class so that this can be access by the unit tests.
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString* fontPath = [bundle pathForResource:name ofType:@"otf"];
        CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename([fontPath UTF8String]);
        self.defaultCGFont = CGFontCreateWithDataProvider(fontDataProvider);
        CFRelease(fontDataProvider);
        NSLog(@"Num glyphs: %zd", CGFontGetNumberOfGlyphs(self.defaultCGFont));

        self.font = CTFontCreateWithGraphicsFont(self.defaultCGFont, kDefaultFontSize, nil, nil);

        NSString* mathTablePlist = [bundle pathForResource:name ofType:@"plist"];
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:mathTablePlist];
        self.mathTable = dict;
    }
    return self;
}

- (MTFont *)copyFontWithSize:(CGFloat)size
{
    MTFont* copyFont = [[[self class] alloc] init];
    copyFont.defaultCGFont = self.defaultCGFont;
    // Retain the font as we are adding another reference to it.
    CGFontRetain(copyFont.defaultCGFont);
    copyFont.mathTable = self.mathTable;
    copyFont.font = CTFontCreateWithGraphicsFont(self.defaultCGFont, size, nil, nil);
    return copyFont;
}

-(NSString*) getGlyphName:(CGGlyph) glyph
{
    NSString* name = CFBridgingRelease(CGFontCopyGlyphNameForGlyph(self.defaultCGFont, glyph));
    return name;
}

- (void)dealloc
{
    CGFontRelease(self.defaultCGFont);
    CFRelease(self.font);
}

@end
