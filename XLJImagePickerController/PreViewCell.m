//
//  VideoPreCell.m
//  HQImagePickerController
//
//  Created by lijun_xue on 2018/10/30.
//

#import "PreViewCell.h"
#import "XLJAssetHelper.h"
@class PreViewVideo;
@interface PreViewCell()

@end

@implementation PreViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (PreBaseView *)preBaseView
{
    if (!_preBaseView) {
        _preBaseView = [[PreBaseView alloc] initWithFrame:self.bounds];
        _preBaseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _preBaseView;
}

- (void)initUI
{
    [self addSubview:self.preBaseView];
    __weak typeof(self) weakself = self;

    self.preBaseView.singleTapCallBack = ^(BOOL isPlaying){
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoPreCell:playActionIndex:isPlaying:)]) {
            [weakself.delegate videoPreCell:weakself playActionIndex:0 isPlaying:isPlaying];
        }
    };
}






- (void)configCellWithPhotoAsset:(PHAsset *)photoAsset{
    
    [self.preBaseView loadPhotoAsset:photoAsset];
}


//滑动暂停播放
- (void)pasuePlay {
    [self.preBaseView pausePlay];
    
}


- (void)handleDidEndDisPlaying {
    
    [self.preBaseView cellDidEndDisplaying];
}


@end



//基本视图
@implementation PreBaseView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        [self addGestureRecognizer:self.singleTap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (PreViewVideo *)videoView
{
    if (!_videoView) {
        _videoView = [[PreViewVideo alloc] initWithFrame:self.bounds];
        _videoView.singleTapCallBack = self.singleTapCallBack;
    }
    return _videoView;
}
- (void)loadPhotoAsset:(PHAsset *)photoAsset {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addSubview:self.videoView];
    [self.videoView loadNormalImage:photoAsset];
}



- (void)loadNormalImage:(PHAsset *)photoAsset
{
    //子类重写
}


/**
 处理划出界面后操作
 */
- (void)cellDidEndDisplaying {

}

- (void)singleTapAction {
 
}

- (void)pausePlay {
    
    [self.videoView pausePlayVideo];
}

- (void)pausePlayVideo {
    //子类重写
}
@end


@implementation PreViewVideo


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.imageView];
    [self addSubview:self.playButton];
    [self addSubview:self.indicator];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    _playLayer.frame = self.bounds;
    self.playButton.center = self.center;
}

- (UIActivityIndicatorView *)indicator
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.hidesWhenStopped = YES;
        _indicator.center = self.center;
    }
    return _indicator;
}


- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        //        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _imageView;
}



//视频播放层
- (AVPlayerLayer *)playLayer
{
    if (!_playLayer) {
        _playLayer = [[AVPlayerLayer alloc] init];
        _playLayer.frame = self.bounds;
    }
    return _playLayer;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSBundle *resourceBundle = [XLJAssetHelper getResourceBundle];
        UIImage *image = [UIImage imageNamed:@"play" inBundle:resourceBundle compatibleWithTraitCollection:nil];
        [_playButton setBackgroundImage:image forState:UIControlStateNormal];
        _playButton.frame = CGRectMake(0, 0, 72, 72);
        _playButton.center = self.center;
        [_playButton addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    [self bringSubviewToFront:_playButton];
    return _playButton;
}




- (void)loadNormalImage:(PHAsset *)photoAsset
{
    __weak typeof(self) weakself = self;
    self.photoAsset = photoAsset;
    self.imageView.image = nil;
    if (_playLayer) {
        [_playLayer removeFromSuperlayer];
        _playLayer = nil;
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGSize size = CGSizeMake(photoAsset.pixelWidth, photoAsset.pixelHeight);
    
    CGFloat scale_width = Width*scale;
    
    CGFloat scale_height = Height*scale;
    
    if (photoAsset.pixelWidth > scale_width && photoAsset.pixelHeight > scale_height) {
        
        if (photoAsset.pixelWidth >= photoAsset.pixelHeight) {
            
            size = CGSizeMake(scale_height, (NSInteger)(scale_height/photoAsset.pixelWidth*photoAsset.pixelHeight));
            
        } else {
            
            size = CGSizeMake((NSInteger)(scale_height/photoAsset.pixelHeight*photoAsset.pixelWidth), scale_height);
            
        }
    }
    [ImageManager requestImageForAsset:photoAsset targetSize:size contentMode:(PHImageContentModeAspectFit) options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (result && downloadFinined) {
            weakself.imageView.image = result;
        }
        
        if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !result) {
            [weakself.indicator startAnimating];
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progress >= 1.0) {
                        [weakself.indicator stopAnimating];
                    }
                });
            };
            [ImageManager requestImageDataForAsset:photoAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                [weakself.indicator stopAnimating];
                BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                if (downloadFinined && !isDegraded && imageData) {
                    weakself.imageView.image = [UIImage imageWithData:imageData];
                }
            }];
        }
    }];
}


- (void)singleTapAction
{
    [self playBtnClick];
    
}

- (void)playBtnClick {
    
    if (!_playLayer) {
        __weak typeof(self) weakSelf = self;
        [AssetHelper getCurrentPlayItemByVideoAsset:self.photoAsset callback:^(AVPlayerItem * _Nullable playerItem) {
            [AssetHelper hideWaitingInView:weakSelf];
            __strong typeof(weakSelf) strongSelf = weakSelf;
            AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
            [strongSelf.layer addSublayer:strongSelf.playLayer];
            strongSelf.playLayer.player = player;
            [strongSelf switchVideoStatus];
            [[NSNotificationCenter defaultCenter] addObserver:strongSelf selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
            
        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            [AssetHelper creatWaitingViewInView:weakSelf title:@"正在从iCloud同步..."];
        }];
    } else {
        
        [self switchVideoStatus];
    }
}


- (void)switchVideoStatus
{
    AVPlayer *player = self.playLayer.player;
    CMTime stop = player.currentItem.currentTime;
    CMTime duration = player.currentItem.duration;
    if (player.rate == .0) {
        self.playButton.hidden = YES;
        if (stop.value == duration.value) {
            [player.currentItem seekToTime:CMTimeMake(0, 1)];
        }
        [player play];
        self.singleTapCallBack(YES);
    } else {
        self.playButton.hidden = NO;
        [player pause];
        self.singleTapCallBack(NO);

    }
    

}

- (void)playFinished:(id)sender {
    self.playButton.hidden = NO;
    self.imageView.hidden = NO;
    [self.playLayer.player seekToTime:kCMTimeZero];
    self.singleTapCallBack(NO);

}

- (void)pausePlayVideo {
    
    if (!_playLayer) {
        return;
    }
    AVPlayer *player = self.playLayer.player;
    if (player.rate != .0) {
        [player pause];
        self.playButton.hidden = NO;
    }
}

- (void)stopPlayVideo {
 
    
}


/**
 处理划出界面后操作
 */
- (void)cellDidEndDisplaying {
    
    if ([self haveLoadVideo]) {
        [self loadNormalImage:self.photoAsset];
    }
}


- (BOOL)haveLoadVideo
{
    return _playLayer ? YES : NO;
}


@end




