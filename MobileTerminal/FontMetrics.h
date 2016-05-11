// FontMetrics.h
// MobileTerminal
//
//

#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIFont.h>

@interface FontMetrics : NSObject {
@private
  UIFont* font;
  CTFontRef ctFont;
  CGFloat ascent;
  CGFloat descent;
  CGFloat leading;
  CGSize boundingBox;
}

- (id)initWithFont:(UIFont*)font;
- (UIFont*)font;
- (CTFontRef)ctFont;

// The dimensions of a single glyph on the screen
- (CGSize)boundingBox;
- (float)descent;

@end
