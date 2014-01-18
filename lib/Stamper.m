#import "Stamper.h"

@interface Stamper ()
@property (nonatomic) NSImage *image;
@property (nonatomic) NSString *iconFile;
@end

@implementation Stamper

- (id)initWithFile:(NSString *)file
{
    self = [super init];
    if (self) {
        NSParameterAssert(file);
        _iconFile = file;
    }
    return self;
}

- (void)addText:(NSString *)text
{
    [self addTextUsingLayoutManager:text];
}

- (BOOL)saveTo:(NSString *)target
{
    NSData *pngData = [[self bitmapRepresentation] representationUsingType:NSPNGFileType properties:nil];
    return [pngData writeToFile:target atomically:YES];
}

#pragma mark private

- (void)addTextUsingLayoutManager:(NSString *)text
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:text attributes:self.textAttributes];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:self.iconSize];

    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];

    NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
    [self.image lockFocus];
    [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:NSMakePoint(0, self.isRetina ? -10 : -5)];
    [self.image unlockFocus];
}

- (NSFont *)font
{
    return [NSFont fontWithName:@"HelveticaNeue-Light" size:self.isRetina ? 26 : 13];
}

- (NSShadow *)textShadow
{
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = NSMakeSize(1.5, 1);
    shadow.shadowBlurRadius = 0.2;
    shadow.shadowColor = [NSColor controlDarkShadowColor];
    return shadow;
}

- (NSDictionary *)textAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSCenterTextAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;

    return @{
        NSParagraphStyleAttributeName: paragraphStyle,
        NSFontAttributeName: [self font],
        NSForegroundColorAttributeName: [NSColor whiteColor],
        NSShadowAttributeName: [self textShadow],
    };
}

- (BOOL)isRetina
{
    return self.iconSize.height > 60;
}

- (NSSize)iconSize
{
    return self.image.size;
}

- (NSImage *)image
{
    if (!_image) {
        _image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:self.iconFile]];
        NSAssert(_image, @"image could not be loaded from %@", self.iconFile);
    }
    return _image;
}

- (NSBitmapImageRep *)bitmapRepresentation
{
    CGImageRef cgRef = [self.image CGImageForProposedRect:NULL
                                                  context:nil
                                                    hints:nil];

    return [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
}

@end
