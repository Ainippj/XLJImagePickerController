//
//  PreThumCell.m
//  HQImagePickerController
//
//  Created by lijun_xue on 2018/11/6.
//

#import "PreThumCell.h"
#import "XLJAssetHelper.h"

@implementation PreThumModel

@end

@interface PreThumCell()
@property (nonatomic,weak) UIImageView *thumImageView;

@end

@implementation PreThumCell
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

- (void)initUI {
    
    UIImageView *imagView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    imagView.contentMode = UIViewContentModeScaleAspectFill;
    imagView.clipsToBounds = YES;
    self.thumImageView = imagView;
    [self.contentView addSubview:imagView];
}

- (void)configCellWithPhotoAssetModel:(PreThumModel *)model {
    __weak typeof(self) weakself = self;
    [ImageManager requestImageForAsset:model.photoAsset targetSize:CGSizeMake(100, 100) contentMode:(PHImageContentModeAspectFit) options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            weakself.thumImageView.image = result;
        }
    }];
    if (model.isSelected) {
        self.contentView.layer.borderWidth = 2.0f;
        self.contentView.layer.borderColor = [UIColor colorWithRed:258/255.0 green:81/255.0 blue:84/255.0 alpha:1.0].CGColor;
    }else{
        self.contentView.layer.borderWidth = 0.0f;
        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}
@end
