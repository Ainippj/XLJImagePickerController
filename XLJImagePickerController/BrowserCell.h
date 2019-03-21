//
//  BrowserCell.h
//  XImagePickerController
//
//  Created by lijun_xue on 2018/9/18.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


@protocol BrowserCellDelegate<NSObject>
- (void)browserCellTouchHideOrShowToolBars;
@end

@interface BrowserCell : UICollectionViewCell

@property (nonatomic,weak) id<BrowserCellDelegate> delegate;
//@property (nonatomic,copy) void(^tapBlock)(void);

- (void)configCellWithPhotoAsset:(PHAsset *)photoAsset;

- (void)resetScrollZoom;
@end
