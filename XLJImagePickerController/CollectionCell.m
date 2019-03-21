//
//  CollectionCell.m
//  XLJImagePickController
//
//  Created by lijun_xue on 2018/9/12.
//

#import "CollectionCell.h"

#import "XLJAssetHelper.h"
@interface CollectionCell()
@property (weak, nonatomic) IBOutlet UIImageView *thumImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation CollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.thumImageView.contentMode = UIViewContentModeScaleAspectFill;

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCellWithIndexPath:(NSIndexPath *)indexPath {
    
    PHAssetCollection *collection = AssetHelper.assetGroups[indexPath.row];
    PHFetchResult * fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    NSString *albumName = collection.localizedTitle;
    self.nameLabel.text = [NSString stringWithFormat:@"%@(%ld)",albumName,fetchResult.count];
    //获取相册集合中的每个相册的第一个资源，形成缩略图    
    if (fetchResult.count != 0) {
        PHAsset *asset = fetchResult[0];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        
        __weak typeof(self) weakself = self;
        [ImageManager requestImageForAsset:asset targetSize:CGSizeMake(groupCellWidth, groupCellWidth) contentMode:(PHImageContentModeAspectFit) options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            weakself.thumImageView.image = result;
        }];
    }else{
        NSBundle *resourceBundle = [XLJAssetHelper getResourceBundle];
        UIImage *deafualt = [UIImage imageNamed:@"notPhoto" inBundle:resourceBundle compatibleWithTraitCollection:nil];
        self.thumImageView.image = deafualt;
    }

}

@end
