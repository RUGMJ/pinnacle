#import <AltList/LSApplicationProxy+AltList.h>
#import <Foundation/Foundation.h>
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
NSString *grabberPath();

@interface SBSearchScrollView : UIScrollView
@end

@interface SBHIconLibraryTableViewController : UITableView
@end

@interface SBIconScrollView : UIScrollView
@end

@interface SBFloatingDockController : UIViewController
- (void)_presentFloatingDockIfDismissedAnimated:(BOOL)present
                              completionHandler:(id)completionHandler;
- (void)_dismissFloatingDockIfPresentedAnimated:(BOOL)dismiss
                              completionHandler:(id)completionHandler;
@end

@interface SBFloatingDockBehaviorAssertion : NSObject
@property SBFloatingDockController *floatingDockController;
@end

@interface SBHomeScreenViewController : UIViewController
@property(nonatomic, strong, readwrite)
    SBFloatingDockBehaviorAssertion *homeScreenFloatingDockAssertion;
@end

@interface SBIconController ()
@property(nonatomic, weak, readwrite)
    SBHomeScreenViewController *parentViewController;
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
- (CGRect)_pinnacleGetImageSize;
- (SBIconListView *)_pinnacleGetIconList;
- (CGRect)iconImageFrame;
- (NSArray<NSNumber *> *)_pinnacleCalcAvailableDirections;
- (void)_removeJitter;
- (void)setEditing:(BOOL)arg;
- (void)setAllowsLabelArea:(BOOL)allows;
- (UIView *)viewController;
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
- (void)_pinnacleEnsureTapToEndIsRegistered;
@end

@interface SBHLibraryCategoryPodIconView : SBIconView
@end

@interface SBDockIconListView : SBIconListView
@end
