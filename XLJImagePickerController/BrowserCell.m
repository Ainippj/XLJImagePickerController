//
//  BrowserCell.m
//  XImagePickerController
//
//  Created by lijun_xue on 2018/9/18.
//

#import "BrowserCell.h"
#import "XLJAssetHelper.h"
#import "MBProgressHUD.h"
@interface BrowserCell()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@end
@implementation BrowserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.contentScrollView.delegate = self;
    self.contentImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.contentImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    [self addRecognizer];
}


- (void)addRecognizer {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [tap requireGestureRecognizerToFail:doubleTap];
    [self.contentImageView addGestureRecognizer:tap];
    
}

- (void)configCellWithPhotoAsset:(PHAsset *)photoAsset{
    __weak typeof(self) weakself = self;
    
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
            weakself.contentImageView.image = result;
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
                    weakself.contentImageView.image = [UIImage imageWithData:imageData];
                }
            }];
            
        }
    }];
    
}

- (void)resetScrollZoom {
    
    if(self.contentScrollView.zoomScale != 1) {
        [self.contentScrollView setZoomScale:1 animated:NO];
    }
}


- (void)tapAction:(UIGestureRecognizer *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(browserCellTouchHideOrShowToolBars)]) {
        [self.delegate browserCellTouchHideOrShowToolBars];
    }
}
- (void)doubleTapAction:(id)sender {
    NSLog(@"%s",__FUNCTION__);
    if(self.contentScrollView.zoomScale != 1) {
        [self.contentScrollView setZoomScale:1 animated:YES];
    }
    else {
        [self.contentScrollView setZoomScale:2 animated:YES];
    }
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{//两手指触摸放大时调用，返回需要改变的view
    return self.contentImageView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{//结束放大时调用
    if (scale < 1.0) {//如果放大比例小于1.0则停止放大后返回原大小
        [scrollView setZoomScale:1.0 animated:YES];
    }
}


@end
