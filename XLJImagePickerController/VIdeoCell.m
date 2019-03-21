//
//  VIdeoCell.m
//  HQImagePickerController
//
//  Created by lijun_xue on 2018/10/26.
//

#import "VIdeoCell.h"
#import "XLJAssetHelper.h"

@interface VIdeoCell()
@property (nonatomic,strong) PHAsset *assetPhoto;
@property (nonatomic,copy) NSString  *index;
@end

@implementation VIdeoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSBundle *resourceBundle = [XLJAssetHelper getResourceBundle];
    UIImage *image = [UIImage imageNamed:@"select" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    [self.slectButton setImage:image forState:(UIControlStateNormal)];
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
        [self.slectButton setImage:image forState:UIControlStateNormal];
        self.slectButton.selected = YES;
        
    }else{
        UIImage *image = [UIImage imageNamed:@"select" inBundle:resourceBundle compatibleWithTraitCollection:nil];
        [self.slectButton setImage:image forState:UIControlStateNormal];
        self.slectButton.selected = NO;
    }
    self.durationLabel.text = [AssetHelper formatTimeDuration:photo.duration];
    
    [ImageManager requestImageForAsset:photo targetSize:CGSizeMake(200, 200) contentMode:(PHImageContentModeAspectFit) options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            self.thumImageView.image = result;
        }
    }];
    
}
- (IBAction)touchSelectButton:(id)sender {
    NSBundle *resourceBundle = [XLJAssetHelper getResourceBundle];
    NSString *seletKey = [NSString stringWithFormat:@"%ld_%@",(long)AssetHelper.selectGroupIndex,self.index];
    
    if (self.slectButton.selected == NO) {
        
        if (AssetHelper.selectPhotoAssets.count == AssetHelper.maxCount) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"您最多只能选择%ld个视频",(long)AssetHelper.maxCount] delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil,nil];
            [alert show];
            return;
        }
        UIImage *image = [UIImage imageNamed:@"selected" inBundle:resourceBundle compatibleWithTraitCollection:nil];
        
        [self.slectButton setImage:image forState:UIControlStateNormal];
        
        [AssetHelper.selectPhotoAssets addObject:self.assetPhoto];
        
        [AssetHelper.selectDict setValue:self.assetPhoto forKey:seletKey];
        
        self.slectButton.selected = YES;
        
    }else{
        UIImage *image = [UIImage imageNamed:@"select" inBundle:resourceBundle compatibleWithTraitCollection:nil];
        
        [self.slectButton setImage:image forState:UIControlStateNormal];
        
        [AssetHelper.selectPhotoAssets removeObject:self.assetPhoto];
        
        [AssetHelper.selectDict removeObjectForKey:seletKey];
        self.slectButton.selected = NO;
    }
    NSLog(@"SelectItem dic: %@,key :%@ selectPhotoAssets:%@",AssetHelper.selectDict,seletKey,AssetHelper.selectPhotoAssets);
    if (AssetHelper.photoCountChange) {
        AssetHelper.photoCountChange(NO);
    }
}



@end
