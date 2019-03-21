//
//  PhotoCell.m
//  Pods
//
//  Created by lijun_xue on 2018/9/13.
//

#import "PhotoCell.h"
#import "XLJAssetHelper.h"
@interface PhotoCell()
@property (weak, nonatomic) IBOutlet UIImageView *thumImageView;
@property (nonatomic,strong) PHAsset *assetPhoto;
@property (nonatomic,copy) NSString  *index;

@end
@implementation PhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSBundle *resourceBundle = [XLJAssetHelper getResourceBundle];
    UIImage *image = [UIImage imageNamed:@"select" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    self.thumImageView.contentMode = UIViewContentModeScaleAspectFill;
//    self.selectButton.hidden = AssetHelper.maxCount == 1;
    [self.selectButton setImage:image forState:(UIControlStateNormal)];
    
    // Initialization code
}

- (void)configCellWithIndexPath:(NSIndexPath *)indexPath {
    
    
    PHAsset *photo = AssetHelper.assetPhotos[indexPath.row];
    
    self.assetPhoto = photo;
    self.index = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    NSString *seletKey = [NSString stringWithFormat:@"%ld_%@",(long)AssetHelper.selectGroupIndex,self.index];
    
    PHAsset *selectPhoto = [AssetHelper.selectDict valueForKey:seletKey];
    NSBundle *resourceBundle = [XLJAssetHelper getResourceBundle];

    if (selectPhoto) {//如果有,已经选择了,处于选中状态
        UIImage *image = [UIImage imageNamed:@"selected" inBundle:resourceBundle compatibleWithTraitCollection:nil];
        [self.selectButton setImage:image forState:UIControlStateNormal];
        self.selectButton.selected = YES;

    }else{
        UIImage *image = [UIImage imageNamed:@"select" inBundle:resourceBundle compatibleWithTraitCollection:nil];
        [self.selectButton setImage:image forState:UIControlStateNormal];
        self.selectButton.selected = NO;
    }
    __weak typeof(self) weakself = self;

    [ImageManager requestImageForAsset:photo targetSize:CGSizeMake(200, 200) contentMode:(PHImageContentModeAspectFit) options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            weakself.thumImageView.image = result;
        }
    }];
}
- (IBAction)touchSelect:(id)sender {
    
    NSBundle *resourceBundle = [XLJAssetHelper getResourceBundle];
    NSString *seletKey = [NSString stringWithFormat:@"%ld_%@",(long)AssetHelper.selectGroupIndex,self.index];

    if (self.selectButton.selected == NO) {
        
        if (AssetHelper.selectPhotoAssets.count == AssetHelper.maxCount) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"您最多只能选择%ld张照片",(long)AssetHelper.maxCount] delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil,nil];
            [alert show];
            return;
        }
        UIImage *image = [UIImage imageNamed:@"selected" inBundle:resourceBundle compatibleWithTraitCollection:nil];
        
        [self.selectButton setImage:image forState:UIControlStateNormal];
        
        [AssetHelper.selectPhotoAssets addObject:self.assetPhoto];
    
        [AssetHelper.selectDict setValue:self.assetPhoto forKey:seletKey];
        
        self.selectButton.selected = YES;
        
    }else{
        UIImage *image = [UIImage imageNamed:@"select" inBundle:resourceBundle compatibleWithTraitCollection:nil];

        [self.selectButton setImage:image forState:UIControlStateNormal];
        
        [AssetHelper.selectPhotoAssets removeObject:self.assetPhoto];

        [AssetHelper.selectDict removeObjectForKey:seletKey];
        self.selectButton.selected = NO;
    }
    
    NSLog(@"SelectItem dic: %@,key :%@ selectPhotoAssets:%@",AssetHelper.selectDict,seletKey,AssetHelper.selectPhotoAssets);

    
    AssetHelper.photoCountChange(NO);
}
@end
