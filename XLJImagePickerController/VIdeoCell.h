//
//  VIdeoCell.h
//  HQImagePickerController
//
//  Created by lijun_xue on 2018/10/26.
//

#import <UIKit/UIKit.h>

@interface VIdeoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *slectButton;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumImageView;


- (void)configCellWithIndexPath:(NSIndexPath *)indexPath;
@end
