//
//  XLJAssetHelper.m
//  Pods-XLJImagePickControllerDemo
//
//  Created by lijun_xue on 2018/9/10.
//

#import "XLJAssetHelper.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MBProgressHUD.h"

@implementation XVideoModel

@end

@interface XLJAssetHelper()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,strong) AVAudioSession *session;
@end

@implementation XLJAssetHelper
+ (XLJAssetHelper *)instance {
    static XLJAssetHelper *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[XLJAssetHelper alloc] init];
        [_instance initData];
    });
    return _instance;
}


- (void)initData {
    _selectPhotoAssets = [[NSMutableArray alloc] init];
    _selectDict = [[NSMutableDictionary alloc] init];
    _indexDic = [[NSMutableDictionary alloc] init];
}

- (void)setUpAudioSession {
    //ios12 经测试,视频播放无生意
    if (!self.session) {
        self.session = [AVAudioSession sharedInstance];
        [self.session setCategory:AVAudioSessionCategoryPlayAndRecord
                 withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                       error:nil];
    }
}

/**
 打开相册或者拍照
 
 @param pickController super Controller
 @param sourceType 类型
 @param maxCount 最大选择数量
 @param delegate 代理
 */
+ (void)xlj_imagPickController:(UIViewController *)pickController
                    sourceType:(SourceType)sourceType
                      maxCount:(NSInteger)maxCount
                      delegate:(id)delegate {
    
    AssetHelper.delegate = delegate;
    if (sourceType == SourceTypePhotoLibrary) {
        
        PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
        if (oldStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (status) {
                        case PHAuthorizationStatusNotDetermined:
                        {
                        }
                            break;
                        case PHAuthorizationStatusRestricted:
                        case PHAuthorizationStatusDenied:
                        {
                            [XNOAuthorController jumpNoAuthorController:pickController isCamera:NO];
                        }
                            break;
                        case PHAuthorizationStatusAuthorized:
                        {
                            AssetHelper.maxCount = maxCount;
                            [XLJImagePickGroupController jumpImagPickGroupController:pickController isVideo:NO];
                        }
                            break;
                        default:
                            break;
                    }
                });
            }];
        }else if (oldStatus != PHAuthorizationStatusAuthorized) {
            [XNOAuthorController jumpNoAuthorController:pickController isCamera:NO];
        }else if (oldStatus == PHAuthorizationStatusAuthorized) {
            AssetHelper.maxCount = maxCount;
            [XLJImagePickGroupController jumpImagPickGroupController:pickController isVideo:NO];
        }
        
    }else{
        
        AVAuthorizationStatus oldStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (oldStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        UIImagePickerController *pickVC = [[UIImagePickerController alloc] init];
                        pickVC.sourceType = UIImagePickerControllerSourceTypeCamera;
                        pickVC.delegate = AssetHelper;
                        [pickController presentViewController:pickVC animated:YES completion:nil];
                    }else{
                        [XNOAuthorController jumpNoAuthorController:pickController isCamera:YES];;
                    }
                });
            }];
            
        }else if (oldStatus != AVAuthorizationStatusAuthorized){
            [XNOAuthorController jumpNoAuthorController:pickController isCamera:YES];;
        }else if (oldStatus == AVAuthorizationStatusAuthorized){
            UIImagePickerController *pickVC = [[UIImagePickerController alloc] init];
            pickVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickVC.delegate = AssetHelper;
            [pickController presentViewController:pickVC animated:YES completion:nil];
        }
    }
    
}


/**
 打开相册或者拍照
 
 @param pickController super Controller
 @param sourceType 类型
 @param delegate 代理
 */
+ (void)xlj_videoPickController:(UIViewController *)pickController
                     sourceType:(SourceType)sourceType
                    qualityType:(UIImagePickerControllerQualityType)qualityType
                       delegate:(id)delegate {
    
    AssetHelper.delegate = delegate;
    AssetHelper.videoQualityType = qualityType;
    if (sourceType == SourceTypePhotoLibrary) {
        
        PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
        
        if (oldStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    switch (status) {
                        case PHAuthorizationStatusNotDetermined:
                        {
                            
                        }
                            break;
                        case PHAuthorizationStatusRestricted:
                        case PHAuthorizationStatusDenied:
                        {
                            [XNOAuthorController jumpNoAuthorController:pickController isCamera:NO];
                        }
                            break;
                        case PHAuthorizationStatusAuthorized:
                        {
                            AssetHelper.maxCount = 1;
                            [XLJImagePickGroupController jumpImagPickGroupController:pickController isVideo:YES];
                        }
                            break;
                        default:
                            break;
                    }
                });
                
            }];
            
        }else if (oldStatus != PHAuthorizationStatusAuthorized){
            
            [XNOAuthorController jumpNoAuthorController:pickController isCamera:NO];
            
        }else if (oldStatus == PHAuthorizationStatusAuthorized){
            AssetHelper.maxCount = 1;
            [XLJImagePickGroupController jumpImagPickGroupController:pickController isVideo:YES];
            
        }
        
    }else{
        
        AVAuthorizationStatus oldStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (oldStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [XLJAssetHelper presentVideoPickerController:pickController qualityType:qualityType];
                    }else{
                        [XNOAuthorController jumpNoAuthorController:pickController isCamera:YES];
                    }
                });
            }];
        }else if (oldStatus != AVAuthorizationStatusAuthorized){
            [XNOAuthorController jumpNoAuthorController:pickController isCamera:YES];;
        }else if (oldStatus == AVAuthorizationStatusAuthorized){
            [XLJAssetHelper presentVideoPickerController:pickController qualityType:qualityType];
        }
        
    }
    
}


+ (void)presentVideoPickerController:(UIViewController *)controller  qualityType:(UIImagePickerControllerQualityType)qualityType{
    UIImagePickerController *pickVC = [[UIImagePickerController alloc] init];
    pickVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickVC.mediaTypes = @[(NSString *)kUTTypeMovie];
    pickVC.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    pickVC.videoQuality = qualityType;
    pickVC.videoMaximumDuration = 120;
    pickVC.delegate = AssetHelper;
    pickVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [controller presentViewController:pickVC animated:YES completion:nil];
}



#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSString *mediaType =[info objectForKey:UIImagePickerControllerMediaType];

    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *originalImage = [AssetHelper fixOrientation:image];
        [picker dismissViewControllerAnimated:YES completion:^{
            if (AssetHelper.delegate && [AssetHelper.delegate respondsToSelector:@selector(x_ImagePickerControllerSelectPhotos:)]) {
                [AssetHelper.delegate x_ImagePickerControllerSelectPhotos:@[originalImage]];
            }
            [AssetHelper clearSelectPhotoAssets];
        }];
    } else  if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        //视频的处理
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [AssetHelper creatWaitingViewInView:picker.view title:@"正在处理..."];
        [AssetHelper handelVideoDataToMp4WithFileUrl:videoUrl callback:^(NSString *filePath) {
            [AssetHelper hideWaitingInView:picker.view];
            XVideoModel *model = [[XVideoModel alloc] init];
            model.filePath = filePath;
            model.orignImage = [AssetHelper getImageFromfileURL:videoUrl];
            model.duration = [AssetHelper getVideoDurationFromFileUrl:videoUrl];
            [AssetHelper removeItemByFilePath:videoUrl];
            [picker dismissViewControllerAnimated:YES completion:^() {
                if (AssetHelper.delegate && [AssetHelper.delegate respondsToSelector:@selector(x_ImagePickerControllerSelectVideoModle:)]) {
                    [AssetHelper.delegate x_ImagePickerControllerSelectVideoModle:model];
                }
                
            }];
        }];
        
        
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}





/**
 获取所有智能相册
 
 @param result 所有的智能相册
 */
- (void)getAllCollectionIsVideo:(BOOL)isVideo
                         result:(void(^)(NSMutableArray *collections))result {
    
    self.assetGroups = [[NSMutableArray alloc] init];
    __weak typeof(self) weakself = self;

    if (isVideo) {
        //系统相册
        PHFetchResult<PHAssetCollection *> *videos = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumVideos options:nil];
        //自定义
//        PHFetchResult<PHAssetCollection *> *custom = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumVideos options:nil];
        
        //延时摄影
        PHFetchResult<PHAssetCollection *> *timelapses = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumTimelapses options:nil];
        //慢动作
        PHFetchResult<PHAssetCollection *> *slomoVideos = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSlomoVideos options:nil];
        
        [videos enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[PHAssetCollection class]]) {
                [weakself.assetGroups addObject:obj];
            }
        }];
//        [custom enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj isKindOfClass:[PHAssetCollection class]]) {
//                [weakself.assetGroups addObject:obj];
//            }
//        }];
        [timelapses enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[PHAssetCollection class]]) {
                [weakself.assetGroups addObject:obj];
            }
        }];
        [slomoVideos enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[PHAssetCollection class]]) {
                [weakself.assetGroups addObject:obj];
            }
        }];
        
        
    }else{
        PHFetchResult<PHAssetCollection *> *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        
        PHFetchResult<PHAssetCollection *> *createAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[PHAssetCollection class]] && obj.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumVideos) {
                [weakself.assetGroups addObject:obj];
            }
        }];
        
        if (@available(iOS 10.3, *)) {
            PHFetchResult<PHAssetCollection *> *liveAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumLivePhotos options:nil];
            
            
            [liveAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[PHAssetCollection class]] && obj.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumVideos) {
                    [weakself.assetGroups addObject:obj];
                }
            }];
        } else {
            // Fallback on earlier versions
        }
        
        [createAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[PHAssetCollection class]]) {
                [weakself.assetGroups addObject:obj];
            }
        }];
        
    }
    
    result(self.assetGroups);
    
}


/**
 获取当前相册所有照片
 @param result 所有照片
 */
- (void)getPhotosWithCollection:(PHAssetCollection *)collection
                         result:(void(^)(NSMutableArray *photos))result{
    self.assetPhotos = [NSMutableArray array];
    __weak typeof(self) weakself = self;
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsPhotos = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    [assetsPhotos enumerateObjectsUsingBlock:^(PHAsset * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAsset class]]) {
            [weakself.assetPhotos addObject:obj];
        }
    }];
    NSLog(@"assetPhotos :%@",self.assetPhotos);
}

/**
 获取当前相册所有照片
 @param result 所有照片
 */
- (void)getPhotosWithIndex:(NSInteger)index
                    result:(void(^)(NSMutableArray *photos))result {
    __weak typeof(self) weakself = self;

    [self getPhotosWithCollection:self.assetGroups[index] result:^(NSMutableArray *photos) {
        
        result(weakself.assetPhotos);
    }];
    
}

/**
 虎丘当前照片
 */
- (PHAsset *)getCurrentAssetWithIndex:(NSInteger)index {
    
    return self.assetPhotos[index];
}


/**
 获取所有视频
 
 @param result 视频
 */
- (void)getAllVideoResult:(void(^)(PHFetchResult<PHAsset *> *videos))result {
    
    self.assetVideos = [NSMutableArray array];
    
   PHFetchResult<PHAsset *> *temp = [PHAsset fetchAssetsWithMediaType:(PHAssetMediaTypeVideo) options:nil];
    
    [temp enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAsset class]] && obj.mediaType == PHAssetMediaTypeVideo) {
            [self.assetVideos addObject:obj];
        }
    }];
    
    if (result) {
        result(temp);
    }
}


/**
 获取当前播放对象
 */
- (void)getCurrentVideoItemByAsset:(PHAsset *)asset result:(void(^)(AVPlayerItem *playerItem, NSDictionary *info))result {
    
    [ImageManager requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                result(playerItem,info);
            }
        });
    }];
    
}




/**
 获取当前播放对象
 */
- (void)getCurrentVideoItemByVideoAsset:(PHAsset *)videoAsset
                               callback:(void(^)(AVURLAsset* urlAsset))callback
                        progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler{
    
    [ImageManager requestAVAssetForVideo:videoAsset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        //本地
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            
            if (downloadFinined && !isDegraded && asset && [asset isKindOfClass:[AVURLAsset class]]) {
                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                if (callback) {
                    callback(urlAsset);
                }
                
            }else{
                
                if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
                    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                    options.networkAccessAllowed = YES;
                    options.version = PHVideoRequestOptionsVersionOriginal;
                    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (progressHandler) {
                                progressHandler(progress,error,stop,info);
                            }
                        });
                    };
                    
                    [ImageManager requestAVAssetForVideo:videoAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if ([asset isKindOfClass:[AVURLAsset class]]) {
                                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                                if (callback) {
                                    callback(urlAsset);
                                }
                            }
                        });
                    }];
                }
            }
        });
    }];
    
}



/**
 获取当前播放对象
 */
- (void)getCurrentPlayItemByVideoAsset:(PHAsset *)videoAsset
                               callback:(void(^)(AVPlayerItem * _Nullable playerItem))callback
                        progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler {
    
    [AssetHelper getCurrentVideoItemByVideoAsset:videoAsset callback:^(AVURLAsset *urlAsset) {
        
        if (callback) {
            callback([AVPlayerItem playerItemWithAsset:urlAsset]);
        }
    } progressHandler:progressHandler];
    
}


/**
 获取相册数
 */
- (NSInteger)getCollectionCount {
    return self.assetGroups.count;
}
/**
 获取照片数
 */
- (NSInteger)getPhotoCount {
    return self.assetPhotos.count;
}



/**
 清除选中的照片
 */
- (void)clearSelectPhotoAssets {
    [_selectPhotoAssets removeAllObjects];
    [_selectDict removeAllObjects];
}




/**
 获取视频个数
 */
- (NSInteger)getVideosCount {
    return self.assetPhotos.count;
}

//获取照片
- (void)getOrignImageWithAssets:(NSArray<PHAsset *>*)assets callback:(void(^)(NSMutableArray *photos))callback progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler {
    
    __weak typeof(self) weakself = self;

    __block  NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakself getOrignImageWithAsset:obj callback:^(UIImage *photo) {
            UIImage *originalImage = [AssetHelper fixOrientation:photo];
            [imageArray addObject:originalImage];
            if (imageArray.count == assets.count) {
                 callback(imageArray);
            }
        } progressHandler:progressHandler];
    }];
}

- (void)getOrignImageWithAsset:(PHAsset *)asset callback:(void(^)(UIImage *photo))callback progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler {
    
    [ImageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        //本地
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        
        if (downloadFinined && imageData && !isDegraded) {
            callback([UIImage imageWithData:imageData]);
        }else{
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressHandler) {
                            progressHandler(progress,error,stop,info);
                        }
                    });
                };
                [ImageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                    BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                    if (downloadFinined && imageData && !isDegraded) {
                        callback([UIImage imageWithData:imageData]);
                    }
                    
                }];
            }else{
                
                CGFloat scale = [UIScreen mainScreen].scale;
                
                CGSize size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
                
                CGFloat scale_width = Width*scale;
                
                CGFloat scale_height = Height*scale;
                
                if (asset.pixelWidth > scale_width && asset.pixelHeight > scale_height) {
                    
                    if (asset.pixelWidth >= asset.pixelHeight) {
                        
                        size = CGSizeMake(scale_height, (NSInteger)(scale_height/asset.pixelWidth*asset.pixelHeight));
                        
                    } else {
                        
                        size = CGSizeMake((NSInteger)(scale_height/asset.pixelHeight*asset.pixelWidth), scale_height);
                        
                    }
                }
                
                [ImageManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                    if (downloadFinined && result) {
                        callback(result);
                    }
                }];
            }
        }
    }];
    
}



/**
 生成缩略图
 
 */
+ (UIImage *)thumImageWithOrignImage:(UIImage *)orignImage targetSize:(CGSize)targetSize {
    UIImage * resultImage = orignImage;
    UIGraphicsBeginImageContext(targetSize);
    [resultImage drawInRect:CGRectMake(00, 0, targetSize.width, targetSize.height)];
    UIGraphicsEndImageContext();
    return orignImage;
}

//获取资源包
+ (NSBundle *)getResourceBundle {
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleURL = [bundle URLForResource:@"Resource" withExtension:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithURL: bundleURL];
    return resourceBundle;
}

    //获取资源包
+ (NSBundle *)getXibBundle {
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleURL = [bundle URLForResource:@"XibReSource" withExtension:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithURL: bundleURL];
    return resourceBundle;
}


+ (BOOL )checkPhotoAlbumAuthorization
{
    
    BOOL result = YES;
    
    switch (PHPhotoLibrary.authorizationStatus ){
            
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied: {
            
            result = NO;
            
            break;
        }
        case PHAuthorizationStatusAuthorized:
        case PHAuthorizationStatusNotDetermined: {
            
            break;
        }
    }
    
    return result;
    
}




/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


- (void)creatWaitingViewInView:(UIView *)view title:(NSString *)title;{
    if (!view) {
        return;
    }
    MBProgressHUD *hub = [MBProgressHUD HUDForView:view];
    if (hub == nil) {
        hub = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    hub.label.text = title;
}


- (void)hideWaitingInView:(UIView *)view {
    [MBProgressHUD hideHUDForView:view animated:YES];
}



- (NSString *)formatTimeDuration:(NSTimeInterval)duration {
    NSInteger hour = duration/360;
    NSInteger min = (duration - hour * 360)/60;
    NSInteger sec = duration - hour *360 - min * 60;
    
    NSString *time = nil;
    if (hour > 0) {
        time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,min,sec];
    }else{
        time = [NSString stringWithFormat:@"%02ld:%02ld",min,sec];
        
    }
    return time;
    
}


- (UIImage *)getImageFromfileURL:(NSURL *)fileURL {
    UIImage *shotImage;
    //视频路径URL
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    shotImage = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return shotImage;
}


- (CGFloat)getVideoDurationFromFileUrl:(NSURL*)fileUrl
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:fileUrl options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

- (NSInteger)getVideoSizeFromFileUrl:(NSURL*)fileUrl
{
    
    NSData *data = [NSData dataWithContentsOfURL:fileUrl];

    return data.length;
}

/*
 AVAssetExportPreset640x480
 AVAssetExportPreset960x540
 AVAssetExportPreset1280x720
 AVAssetExportPreset1920x1080
AVAssetExportPreset3840x2160
 */
- (void)handelVideoDataToMp4WithFileUrl:(NSURL *)fileUrl callback:(void(^)(NSString *filePath))callback {
    
    NSInteger size1 = [AssetHelper getVideoSizeFromFileUrl:fileUrl];
    NSLog(@"beforVideoSize: %.2fMB",size1/1024.00/1024.00);
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSString * resultPath = [NSTemporaryDirectory() stringByAppendingFormat:@"video-output-%@.mp4", [formater stringFromDate:[NSDate date]]];
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:fileUrl options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    NSLog(@"%@",compatiblePresets);
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:[XLJAssetHelper getVideoOutPutPresetName]];
        NSLog(@"resultPath = %@",resultPath);
        
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 switch (exportSession.status) {
                         
                     case AVAssetExportSessionStatusCompleted: {
                         NSInteger size = [AssetHelper getVideoSizeFromFileUrl:[NSURL fileURLWithPath:resultPath]];
                         NSLog(@"afterVideoSize: %.2fMB",size/1024.00/1024.00);
                         NSLog(@"AVAssetExportSessionStatusCompleted");
                         if (callback) {
                             callback(resultPath);
                         }
                     }
                         break;
                     case AVAssetExportSessionStatusUnknown:
                         
                         NSLog(@"AVAssetExportSessionStatusUnknown");
                         break;
                     case AVAssetExportSessionStatusWaiting:
                         
                         NSLog(@"AVAssetExportSessionStatusWaiting");
                         break;
                     case AVAssetExportSessionStatusExporting:
                         NSLog(@"AVAssetExportSessionStatusExporting");
                         break;
                     case AVAssetExportSessionStatusFailed:
                         NSLog(@"AVAssetExportSessionStatusFailed");
                         break;
                     case AVAssetExportSessionStatusCancelled:
                         NSLog(@"AVAssetExportSessionStatusCancelled");
                         break;
                 }
             });
        }];
    }
}
- (void)removeItemByFilePath:(NSURL *)filePath {
    
    [[NSFileManager defaultManager] removeItemAtPath:filePath.path error:nil];
    
}


+ (NSString *)getAppName {
    NSDictionary *info = [NSBundle mainBundle].localizedInfoDictionary ?: [NSBundle mainBundle].infoDictionary;
    NSString *appName = [info valueForKey:@"CFBundleDisplayName"] ?: [info valueForKey:@"CFBundleName"];
    return appName;
}


+ (NSString *)getVideoOutPutPresetName {
    /* UIImagePickerControllerQualityTypeHigh = 0,       // highest quality
     UIImagePickerControllerQualityTypeMedium = 1,     // medium quality, suitable for transmission via Wi-Fi
     UIImagePickerControllerQualityTypeLow = 2,         // lowest quality, suitable for tranmission via cellular network
     UIImagePickerControllerQualityType640x480 NS_ENUM_AVAILABLE_IOS(4_0) = 3,    // VGA quality
     UIImagePickerControllerQualityTypeIFrame1280x720 NS_ENUM_AVAILABLE_IOS(5_0) = 4,
     UIImagePickerControllerQualityTypeIFrame960x540 NS_ENUM_AVAILABLE_IOS(5_0) = 5,
     */
    
    NSString *presetName = nil;
    
    switch (AssetHelper.videoQualityType) {
        case UIImagePickerControllerQualityTypeHigh:
            {
                presetName = AVAssetExportPresetHighestQuality;
            }
            break;
        case UIImagePickerControllerQualityTypeMedium:
        {
            presetName = AVAssetExportPresetMediumQuality;
        }
            break;
        case UIImagePickerControllerQualityTypeLow:
        {
           presetName = AVAssetExportPresetLowQuality;
        }
            break;
        case UIImagePickerControllerQualityType640x480:
        {
            presetName = AVAssetExportPreset640x480;
        }
            break;
        case UIImagePickerControllerQualityTypeIFrame1280x720:
        {
            presetName = AVAssetExportPreset1280x720;
        }
            break;
        case UIImagePickerControllerQualityTypeIFrame960x540:
        {
            presetName = AVAssetExportPreset960x540;
        }
            break;
            
        default:
            break;
    }
    
    return presetName;
    
}

@end
