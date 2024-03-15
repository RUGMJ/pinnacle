#import <AltList/LSApplicationProxy+AltList.h>
#import <Foundation/NSValue.h>
#import <MobileCoreServices/LSApplicationProxy.h>
#import <MobileCoreServices/LSApplicationWorkspace.h>
#import <RemoteLog.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBIconContentView.h>
#import <SpringBoard/SBIconController.h>
#import <SpringBoard/SBIconListView.h>
#import <SpringBoard/SBIconModel.h>
#import <SpringBoard/SBIconView.h>
#import <SpringBoard/SBIconViewMap.h>
#import <SpringBoard/SBRootFolderView.h>
#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIKit.h>
#import <objc/NSObjCRuntime.h>

NSString *plusCirclePath();

@interface SBIconScrollView : UIScrollView
@end

@interface SBRootFolderView ()
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
@end

@interface SBIcon : NSObject
@property NSString *displayName;
@end

@interface SBFTouchPassThroughView : UIView
@end

@interface SBWidgetIcon : SBIcon
@end

@interface SBApplicationIcon : SBIcon
- (instancetype)initWithApplication:(SBApplication *)application;
- (NSString *)applicationBundleID;
@end

@interface SBIconView ()
- (BOOL)isFolderIcon;
- (NSUInteger)_pinnacleGetRow;
- (NSUInteger)_pinnacleGetColumn;

- (void)_pinnacleMoveAway:(NSUInteger)row
                   column:(NSUInteger)column
               directions:(NSArray<NSNumber *> *)directions;

- (void)_pinnacleMoveWithX:(NSInteger)x y:(NSInteger)y;
- (void)_pinnacleReset;
- (void)_pinnacleCalculateRowAndColumn;
- (CGSize)_pinnacleGetEffectiveIconSpacing;
- (SBIconListView *)_pinnacleGetIconList;
@property CGRect iconImageFrame;
- (NSString *)applicationBundleIdentifierForShortcuts;
- (NSArray<NSNumber *> *)_pinnacleCalcAvailableDirections;
- (void)_removeJitter;
- (void)setEditing:(BOOL)arg;
- (void)setAllowsLabelArea:(BOOL)allows;
@end

@interface SBIconListView ()
@property NSUInteger iconRowsForCurrentOrientation;
@property NSUInteger iconColumnsForCurrentOrientation;
@property CGSize effectiveIconSpacing;
- (void)_addIconViewsForIcons:(id)arg1;
- (SBIconView *)iconViewForIcon:(SBIcon *)icon;
- (SBIconView *)_pinnacleCreateIconViewForDisplayIdentifier:
    (NSString *)displayIdentifier;

- (void)_pinnacleForIconViews:(void (^)(SBIconView *))action;
- (NSUInteger)rowAtPoint:(CGPoint)point;
- (NSUInteger)columnAtPoint:(CGPoint)point;
- (BOOL)_pinnacleIsEditing;
- (void)_pinnacleResetAllIconViews;
@end

@interface SBHLibraryCategoryPodIconView : SBIconView
@end

@interface SBDockIconListView : SBIconListView
@end
