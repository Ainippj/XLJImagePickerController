//
//  XLJAssetHelper.h
//  Pods-XLJImagePickControllerDemo
//
//  Created by lijun_xue on 2018/9/10.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "XLJImagePickGroupController.h"
#import "XLJVideoPickerController.h"
#import "XNOAuthorController.h"
typedef enum : NSUInteger {
    SourceTypePhotoLibrary,
    SourceTypeCamera,
} SourceType;

#define AssetHelper [XLJAssetHelper instance]
#define ImageManager [PHImageManager defaultManager]

#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height

#define groupCellHeight 80
#define groupCellWidth 70
#define photoCellWidth (Width - 25)/4

// 判断是否是iPhone X iPhoneX
 #define XLJiPhoneAreaSafe   (@available(iOS 11.0,*) ?  [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom: NO)

#define KAdjustsScrollViewInsetNever(view) if(@available(iOS 11.0, *)) {view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;}

#define StatusBarHeight (XLJiPhoneAreaSafe ? 44.0 : 20.0)

#define BottomHeight (XLJiPhoneAreaSafe ? 34.0 : 0.0)

#define TopHeight  (XLJiPhoneAreaSafe ? 88 : 64)

#define StatusBarHeight (XLJiPhoneAreaSafe ? 44.0 : 20.0)


@interface XVideoModel :NSObject
@property (nonatomic,copy) NSString *filePath;//文件地址  (文件使用后,请将原文件删除,以免占用更多空间)
@property (nonatomic,assign) NSTimeInterval duration;//视频时长 单位 秒
@property (nonatomic,strong) UIImage *orignImage;//原图

@end

@protocol ImagePikerDelegate <NSObject>
- (void)x_ImagePickerControllerSelectPhotos:(NSArray *)photos;
- (void)x_ImagePickerControllerSelectVideoModle:(XVideoModel *)videoModle;

@end


@interface XLJAssetHelper : NSObject
@property (nonatomic, strong) NSMutableArray<PHAssetCollection *> *assetGroups;//分组个数
@property (nonatomic ,strong) NSMutableArray<PHAsset *> *assetPhotos;//当前组的照片;
@property (nonatomic, strong)  NSMutableArray<PHAsset *> *assetVideos;//视频集合;
@property (nonatomic ,assign) NSInteger selectGroupIndex;//当前相册的索引
@property (nonatomic ,assign) NSInteger preViewIndex;//当前选择的索引
@property (nonatomic ,strong) NSMutableArray *selectPhotoAssets;//当前选中的照片;
@property (nonatomic ,strong) NSMutableDictionary *selectDict;//当前选中的集合 key:groupIndex_photoIndex value:PHAsset
@property (nonatomic ,strong) NSMutableDictionary *indexDic;//选中的集合  key:PHAsset value :groupIndex_photoIndex;

@property (nonatomic ,assign) NSInteger maxCount;//可以选择最多的照片数;
@property (nonatomic ,assign) BOOL isPreView;//查看/预览
@property (nonatomic ,copy)  void(^photoCountChange)(BOOL reloadData);//选择的数目变化
@property (nonatomic ,weak) id<ImagePikerDelegate> delegate;
@property (nonatomic,assign) UIImagePickerControllerQualityType videoQualityType;

+ (XLJAssetHelper *)instance;


//ios12播放无声音,需要设置session模式
- (void)setUpAudioSession;

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
                      delegate:(id)delegate;

/**
 打开相册或者拍照
 
 @param pickController super Controller
 @param sourceType 类型
 @param delegate 代理
 */
+ (void)xlj_videoPickController:(UIViewController *)pickController
                    sourceType:(SourceType)sourceType
                    qualityType:(UIImagePickerControllerQualityType)qualityType
                      delegate:(id)delegate;





/**
 获取所有智能相册

 @param result 所有的智能相册
 */
- (void)getAllCollectionIsVideo:(BOOL)isVideo
                         result:(void(^)(NSMutableArray *collections))result;

/**
 获取当前相册所有照片
 @param result 所有照片
 */
- (void)getPhotosWithCollection:(PHAssetCollection *)collection
                         result:(void(^)(NSMutableArray *photos))result;

/**
 获取当前相册所有照片
 @param result 所有照片
 */
- (void)getPhotosWithIndex:(NSInteger)index
                    result:(void(^)(NSMutableArray *photos))result;



/**
 获取所有视频

 @param result 视频
 */
- (void)getAllVideoResult:(void(^)(PHFetchResult<PHAsset *> *videos))result;


/**
 获取当前播放对象
 */
- (void)getCurrentVideoItemByAsset:(PHAsset *)asset result:(void(^)(AVPlayerItem *playerItem, NSDictionary *info))result;




/**
 获取当前播放对象
 */
- (void)getCurrentVideoItemByVideoAsset:(PHAsset *)videoAsset
                               callback:(void(^)(AVURLAsset* urlAsset))callback
                        progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;



/**
 获取当前播放对象
 */
- (void)getCurrentPlayItemByVideoAsset:(PHAsset *)videoAsset
                              callback:(void(^)(AVPlayerItem * _Nullable playerItem))callback
                       progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;


/**
 虎丘当前照片
 */
- (PHAsset *)getCurrentAssetWithIndex:(NSInteger)index;

/**
 获取相册数
 */
- (NSInteger)getCollectionCount;
/**
 获取照片数
 */
- (NSInteger)getPhotoCount;

/**
 清除选中的照片
 */
- (void)clearSelectPhotoAssets;


/**
 获取视频个数
 */
- (NSInteger)getVideosCount;


//获取照片
- (void)getOrignImageWithAssets:(NSArray<PHAsset *>*)assets callback:(void(^)(NSMutableArray *photos))callback progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;


- (void)getOrignImageWithAsset:(PHAsset *)asset callback:(void(^)(UIImage *photo))callback progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

/**
 生成缩略图

 */
+ (UIImage *)thumImageWithOrignImage:(UIImage *)orignImage targetSize:(CGSize)targetSize;

//获取资源包
+ (NSBundle *)getResourceBundle;

    //获取资源包
+ (NSBundle *)getXibBundle;

/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage;

- (void)creatWaitingViewInView:(UIView *)view title:(NSString *)title;

- (void)hideWaitingInView:(UIView *)view;


- (NSString *)formatTimeDuration:(NSTimeInterval)duration;

- (UIImage *)getImageFromfileURL:(NSURL *)fileURL;

- (CGFloat)getVideoDurationFromFileUrl:(NSURL*)fileUrl;

- (NSInteger)getVideoSizeFromFileUrl:(NSURL*)fileUrl;

- (void)handelVideoDataToMp4WithFileUrl:(NSURL *)fileUrl callback:(void(^)(NSString *filePath))callback;

- (void)removeItemByFilePath:(NSURL *)filePath;
+ (NSString *)getAppName;
+ (NSString *)getVideoOutPutPresetName;
@end
