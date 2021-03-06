#import <UIKit/UIKit.h>
#import <CaptainHook/CaptainHook.h>

__attribute__((visibility("hidden")))
@interface SkippyView : UIView
@property (nonatomic, retain) UILabel *label;
@end

@implementation SkippyView

@synthesize label;

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;
		frame.origin.x = (frame.size.width - 100) * 0.5;
		frame.origin.y = (frame.size.height - 100) * 0.5;
		frame.size.width = 100.0f;
		frame.size.height = 100.0f;
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = frame;
		effectView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		effectView.clipsToBounds = YES;
		effectView.layer.cornerRadius = 10.0;
        [self addSubview:effectView];
		frame.origin.x = 0.0f;
		frame.origin.y = 0.0f;
		self.label = [[[UILabel alloc] initWithFrame:frame] autorelease];
		self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.label.textColor = [UIColor whiteColor];
		self.label.textAlignment = NSTextAlignmentCenter;
		self.label.font = [UIFont boldSystemFontOfSize:48.0];
		[effectView addSubview:label];
        [effectView release];
	}
	return self;
}

- (void)dealloc
{
	self.label = nil;
	[super dealloc];
}

@end

static const bool kSkippyView = false;

static void CancelSkippyForIndex(UIControl *target)
{
	SkippyView *skippy = objc_getAssociatedObject(target.window, &kSkippyView);
	[UIView animateWithDuration:0.3 delay:0.25 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
		skippy.alpha = 0.0;
	} completion:^(BOOL finished) {
		if (finished) {
			skippy.hidden = YES;
		}
	}];
}

@interface UITableViewIndex : UIControl
@property (nonatomic,readonly) NSString *selectedSectionTitle;
@end

%hook UITableViewIndex

- (void)_selectSectionForTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	%orig();
	UIWindow *window = self.window;
	SkippyView *skippy = objc_getAssociatedObject(window, &kSkippyView);
	if (!skippy) {
		UIView *targetView = window.rootViewController.view ?: window.subviews[0];
		skippy = [[[SkippyView alloc] initWithFrame:targetView.bounds] autorelease];
		skippy.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		skippy.alpha = 0.0;
		[targetView addSubview:skippy];
		objc_setAssociatedObject(window, &kSkippyView, skippy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	} else {
		[skippy.superview bringSubviewToFront:skippy];
		skippy.hidden = NO;
	}
	skippy.label.text = self.selectedSectionTitle;
	[UIView animateWithDuration:0.00 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
		skippy.alpha = 1.0;
	} completion:NULL];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
	%orig();
	CancelSkippyForIndex(self);
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	BOOL result = %orig();
	if (!result) {
		CancelSkippyForIndex(self);
	}
	return result;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	%orig();
	CancelSkippyForIndex(self);
}

- (void)willMoveToWindow:(UIWindow *)window
{
	%orig();
	CancelSkippyForIndex(self);
}

%end

#pragma mark - Music App

@interface SKUIAttributedStringIndexBarEntry
@property (nonatomic,copy,readonly) NSAttributedString * attributedString; 
@end

@interface SKUIIndexBarControl : UIControl
@end

@interface MusicLibraryViewController : UIViewController
-(id)indexBarControl:(id)arg1 entryAtIndexPath:(id)arg2;
@end

%hook MusicLibraryViewController
-(void)indexBarControl:(id)arg1 didSelectEntryAtIndexPath:(id)arg2 {

	%orig();
	SKUIAttributedStringIndexBarEntry *currentIndex = [self indexBarControl:arg1 entryAtIndexPath:arg2];
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	SkippyView *skippy = objc_getAssociatedObject(window, &kSkippyView);
	if (!skippy) {
		UIView *targetView = window.rootViewController.view ?: window.subviews[0];
		skippy = [[[SkippyView alloc] initWithFrame:targetView.bounds] autorelease];
		skippy.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		skippy.alpha = 0.0;
		[targetView addSubview:skippy];
		objc_setAssociatedObject(window, &kSkippyView, skippy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	} else {
		[skippy.superview bringSubviewToFront:skippy];
		skippy.hidden = NO;
	}
	skippy.label.text = currentIndex.attributedString.string;
	[UIView animateWithDuration:0.00 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
		skippy.alpha = 1.0;
	} completion:NULL];
}
%end

%hook SKUIIndexBarControl

-(void)cancelTrackingWithEvent:(id)arg1 {
	%orig();
	CancelSkippyForIndex(self);
}
-(BOOL)continueTrackingWithTouch:(id)arg1 withEvent:(id)arg2 {
	BOOL result = %orig();
	if (!result) {
		CancelSkippyForIndex(self);
	}
	return result;
}
-(void)endTrackingWithTouch:(id)arg1 withEvent:(id)arg2 {
	%orig();
	CancelSkippyForIndex(self);
}
%end
