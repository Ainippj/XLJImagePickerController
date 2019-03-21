//
//  VideoPreCell.h
//  HQImagePickerController
//
//  Created by lijun_xue on 2018/10/30.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol VideoPreCellDelegate<NSObject>
- (void)videoPreCell:(UICollectionViewCell *)cell playActionIndex:(NSInteger)index isPlaying:(BOOL)isPlaying;
@end


@class PreBaseView;
@interface PreViewCell : UICollectionViewCell
@property (nonatomic,weak) id<VideoPreCellDelegate> delegate;
@property (nonatomic, strong) PreBaseView *preBaseView;
- (void)configCellWithPhotoAsset:(PHAsset *)photoAsset;

- (void)handleDidEndDisPlaying;

//滑动暂停播放
- (void)pasuePlay;

@end



//预览视图
@class PreViewVideo;
@interface PreBaseView : UIView

@property (nonatomic, strong) PHAsset *photoAsset;

@property (nonatomic, strong) PreViewVideo *videoView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, copy)   void (^singleTapCallBack)(BOOL isPlaying);

- (void)loadPhotoAsset:(PHAsset *)photoAsset;

- (void)loadNormalImage:(PHAsset *)photoAsset;

/**
 处理划出界面后操作
 */
- (void)cellDidEndDisplaying;


- (void)pausePlay;

- (void)pausePlayVideo;
@end



//视频预览
@interface PreViewVideo : PreBaseView
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) AVPlayerLayer *playLayer;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, copy)   void (^singleTapCallBack)(BOOL isPlaying);

- (BOOL)haveLoadVideo;


- (void)stopPlayVideo;

@end
