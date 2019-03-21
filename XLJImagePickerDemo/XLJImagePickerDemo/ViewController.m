//
//  ViewController.m
//  XLJImagePickerDemo
//
//  Created by lijun_xue on 2019/3/21.
//  Copyright © 2019 lijun_xue. All rights reserved.
//

#import "ViewController.h"
#import "XLJImagePickHeader.h"
#import "ImageCell.h"
@interface ViewController ()<ImagePikerDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong,nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.dataSource  = self;
    self.collectionView.delegate = self;
    //    [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"ImageCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCell"];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)plus:(id)sender {
    NSInteger num = self.numLabel.text.integerValue;
    if (num < 9) {
        num ++;
        self.numLabel.text = [NSString stringWithFormat:@"%ld",num];
    }
}
- (IBAction)minus:(id)sender {
    
    NSInteger num = self.numLabel.text.integerValue;
    
    if (num > 1) {
        num --;
        self.numLabel.text = [NSString stringWithFormat:@"%ld",num];
    }
    
}
- (IBAction)selectImage:(id)sender {
    self.dataArray = nil;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择照片" message:@"" preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"相册" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self selectPhotoFromLibiray];
        
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"相机" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self selectPhotoFromCamera];
    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)selectVideo:(id)sender {
        self.dataArray = nil;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择视频资源" message:@"" preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"相册" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self selectVideFromLibiray];
        
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"相机" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self selectVideoFromCamera];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)selectPhotoFromCamera {
    NSLog(@"%s",__FUNCTION__);
    [XLJAssetHelper xlj_imagPickController:self sourceType:(SourceTypeCamera) maxCount:0 delegate:self ];
}

- (void)selectPhotoFromLibiray {
    NSLog(@"%s",__FUNCTION__);
    NSInteger num = self.numLabel.text.integerValue;
    [XLJAssetHelper xlj_imagPickController:self sourceType:(SourceTypePhotoLibrary) maxCount:num delegate:self];
}


- (void)selectVideFromLibiray {
    [XLJAssetHelper xlj_videoPickController:self sourceType:(SourceTypePhotoLibrary) qualityType:(UIImagePickerControllerQualityTypeMedium) delegate:self ];
}

-(void)selectVideoFromCamera {
    [XLJAssetHelper xlj_videoPickController:self sourceType:(SourceTypeCamera) qualityType:(UIImagePickerControllerQualityTypeMedium) delegate:self ];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:( NSIndexPath *)indexPath {
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.contentImage.image = self.dataArray[indexPath.row];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    

}


- (void)x_ImagePickerControllerSelectPhotos:(NSArray *)photos {
    NSLog(@"%s,%@",__FUNCTION__,photos);
    self.dataArray = photos;
    [self.collectionView reloadData];
}


- (void)x_ImagePickerControllerSelectVideoModle:(XVideoModel *)videoModle {
    
    self.dataArray = @[videoModle.orignImage];
    [self.collectionView reloadData];
    //    [[NSFileManager defaultManager] removeItemAtPath:videoModle.filePath error:nil];
    
}


@end
