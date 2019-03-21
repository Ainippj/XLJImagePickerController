//
//  PhotoCell.h
//  Pods
//
//  Created by lijun_xue on 2018/9/13.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PhotoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

- (void)configCellWithIndexPath:(NSIndexPath *)indexPath;

@end
