//
//  PreThumCell.h
//  HQImagePickerController
//
//  Created by lijun_xue on 2018/11/6.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


@interface PreThumModel : NSObject
@property (nonatomic,strong) PHAsset *photoAsset;
@property (nonatomic,assign) BOOL isSelected;//是佛被选中
@end


@interface PreThumCell : UICollectionViewCell

- (void)configCellWithPhotoAssetModel:(PreThumModel *)model;
@end
