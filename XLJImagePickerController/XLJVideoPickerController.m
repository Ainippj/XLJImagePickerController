//
//  XLJVideoPickerController.m
//  HQImagePickerController
//
//  Created by lijun_xue on 2018/10/26.
//

#import "XLJVideoPickerController.h"
#import "VIdeoCell.h"
#import "XLJAssetHelper.h"
#import "MBProgressHUD.h"
#import "XLJVideoPreViewController.h"

@interface XLJVideoPickerController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) UICollectionView *photoColletionView;

@end

@implementation XLJVideoPickerController
+ (void)jumpViedioPickController:(UIViewController *)controller animation:(BOOL)animation {
    XLJVideoPickerController *videoVC = [[XLJVideoPickerController alloc] init];
    [controller.navigationController pushViewController:videoVC animated:animation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self configNavgationBar];
    [self createColletionView];
    __weak typeof(self) weakself = self;
    
    [AssetHelper getPhotosWithIndex:AssetHelper.selectGroupIndex result:^(NSMutableArray *photos) {
        [weakself.photoColletionView reloadData];
    }];
}

- (void)configNavgationBar {
    PHAssetCollection *collection = AssetHelper.assetGroups[AssetHelper.selectGroupIndex];
    NSString *navTitle = collection.localizedTitle;
    self.navigationItem.title = navTitle;
    UIButton *cancel = [UIButton buttonWithType:(UIButtonTypeCustom)];
    cancel.frame = CGRectMake(0, 0, 40, 40);
    [cancel setTitle:@"取消" forState:(UIControlStateNormal)];
    [cancel setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:(UIControlStateNormal)];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:(UIControlEventTouchUpInside)];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    self.navigationItem.rightBarButtonItem = cancelItem;
    
    
    NSBundle *resourceBundle = [XLJAssetHelper getResourceBundle];
    
    UIImage *backImage = [UIImage imageNamed:@"back_b" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    
    UIButton *backBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    backBtn.frame = CGRectMake(0, 0, 40, 40);
    [backBtn setImage:backImage forState:(UIControlStateNormal)];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
    [backBtn addTarget:self action:@selector(touchBackItem:) forControlEvents:(UIControlEventTouchUpInside)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
   
}



- (void)createColletionView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(photoCellWidth, photoCellWidth);
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 0;
    UICollectionView *photoColletionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, TopHeight, Width, Height - TopHeight) collectionViewLayout:layout];
    photoColletionView.backgroundColor = [UIColor whiteColor];
    self.photoColletionView = photoColletionView;
    [self.view addSubview:self.photoColletionView];
    KAdjustsScrollViewInsetNever(self.photoColletionView);
    self.photoColletionView.delegate = self;
    self.photoColletionView.dataSource = self;
    [self.photoColletionView registerNib:[UINib nibWithNibName:NSStringFromClass([VIdeoCell class]) bundle:[XLJAssetHelper getXibBundle]] forCellWithReuseIdentifier:NSStringFromClass([VIdeoCell class])];
    
//    UIView *toolsBar = [[UIView alloc] initWithFrame:CGRectMake(0, Height - BottomHeight - 44, Width, 44 + BottomHeight)];
//    toolsBar.backgroundColor = [UIColor darkGrayColor];
//    [self.view addSubview:toolsBar];
//
//    UIButton *doneButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
//    doneButton.frame = CGRectMake(Width - 68, 4, 60, 30);
//    [doneButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
//    [doneButton setTitleColor:[UIColor lightTextColor] forState:(UIControlStateDisabled)];
//    [doneButton setTitle:@"完成" forState:(UIControlStateNormal)];
//    [doneButton setBackgroundColor:[UIColor colorWithRed:20/255.0 green:100/255.0 blue:17/255.0 alpha:1]];
//    doneButton.layer.cornerRadius = 3;
//    doneButton.layer.masksToBounds = YES;
//    doneButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    [doneButton addTarget:self action:@selector(touchDoneAction:) forControlEvents:(UIControlEventTouchUpInside)];
//    [toolsBar addSubview:doneButton];
    
//    __weak typeof(self) weakself = self;
//    AssetHelper.photoCountChange = ^(BOOL reloadData){
//        if (AssetHelper.selectPhotoAssets.count > 0) {
//            doneButton.enabled = YES;
//            doneButton.backgroundColor = [UIColor colorWithRed:50/255.0 green:150/255.0 blue:17/255.0 alpha:1];
//        }else{
//            doneButton.enabled = NO;
//            [doneButton setBackgroundColor:[UIColor colorWithRed:20/255.0 green:100/255.0 blue:17/255.0 alpha:1]];
//        }
//        if (reloadData) {
//            [weakself.photoColletionView reloadData];
//
//        }
//    };
}




-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"%s,%ld",__FUNCTION__,(long)[AssetHelper getVideosCount]);
    return [AssetHelper getVideosCount];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VIdeoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VIdeoCell" forIndexPath:indexPath];
    [cell configCellWithIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];

    XLJVideoPreViewController *videoPreVC = [[XLJVideoPreViewController alloc] initWithData:AssetHelper.assetPhotos preIndex:indexPath.row];
    [self.navigationController pushViewController:videoPreVC animated:YES];

}


//
//- (void)touchDoneAction:(id)sender {
//
//    __weak typeof(self) weakself = self;
//    [AssetHelper getCurrentVideoItemByVideoAsset:AssetHelper.selectPhotoAssets.firstObject callback:^(XVideoModel *videoModel) {
//        [AssetHelper hideWaitingInView:weakself.view];
//        [weakself dismissViewControllerAnimated:YES completion:^{
//            if (AssetHelper.delegate && [AssetHelper.delegate respondsToSelector:@selector(x_ImagePickerControllerSelectVideoModle:)]) {
//                [AssetHelper.delegate x_ImagePickerControllerSelectVideoModle:videoModel];
//            }
//        }];
//    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//        [AssetHelper creatWaitingViewInView:weakself.view];
//    }];
//
//
//}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)touchBackItem:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
