//
//  XLJImagePickController.m
//  Pods-XLJImagePickControllerDemo
//
//  Created by lijun_xue on 2018/9/10.
//

#import "XLJImagePickController.h"
#import "PhotoCell.h"
#import "XLJAssetHelper.h"
#import "PhotoBrowserController.h"
#import "MBProgressHUD.h"

@interface XLJImagePickController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) UICollectionView *photoColletionView;

@end

@implementation XLJImagePickController
+ (void)jumpImagePickController:(UIViewController *)controller animation:(BOOL)animation {
    XLJImagePickController *pickVC = [[XLJImagePickController alloc] init];
    [controller.navigationController pushViewController:pickVC animated:animation];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [AssetHelper clearSelectPhotoAssets];
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
    [cancel setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:(UIControlStateNormal)];

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
    
    CGFloat height = Height - TopHeight - BottomHeight - 44;
    if (AssetHelper.maxCount <= 1) {
        height = Height - TopHeight;
    }
    UICollectionView *photoColletionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, TopHeight, Width, height) collectionViewLayout:layout];
    photoColletionView.backgroundColor = [UIColor whiteColor];
    self.photoColletionView = photoColletionView;
    [self.view addSubview:self.photoColletionView];
    KAdjustsScrollViewInsetNever(self.photoColletionView);
    self.photoColletionView.delegate = self;
    self.photoColletionView.dataSource = self;
    [self.photoColletionView registerNib:[UINib nibWithNibName:NSStringFromClass([PhotoCell class]) bundle:[XLJAssetHelper getXibBundle]] forCellWithReuseIdentifier:NSStringFromClass([PhotoCell class])];
    
    UIView *toolsBar = [[UIView alloc] initWithFrame:CGRectMake(0, Height - BottomHeight - 44, Width, 44 + BottomHeight)];
    toolsBar.backgroundColor = [UIColor colorWithRed:248/255.0 green:250/255.0 blue:251/255.0 alpha:1.0];
    [self.view addSubview:toolsBar];
    UIBezierPath *linePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, Width, 0.5)];
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = linePath.CGPath;
    lineLayer.fillColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0].CGColor;
    [toolsBar.layer addSublayer:lineLayer];
    UIButton *preViewButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    preViewButton.frame = CGRectMake(8, 7, 60, 30);
    preViewButton.enabled = NO;
    preViewButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [preViewButton setTitle:@"预览" forState:(UIControlStateNormal)];
    [preViewButton setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:(UIControlStateDisabled)];
    [preViewButton setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:(UIControlStateNormal)];
    [preViewButton addTarget:self action:@selector(touchPreViewAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [toolsBar addSubview:preViewButton];
    
    UIButton *doneButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    doneButton.frame = CGRectMake(Width - 68, 7, 60, 30);
    doneButton.enabled = NO;
    [doneButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [doneButton setTitle:@"确定" forState:(UIControlStateNormal)];
    [doneButton setBackgroundColor:[UIColor colorWithRed:151/255.0 green:151/255.0 blue:151/255.0 alpha:1]];
    doneButton.layer.cornerRadius = 5;
    doneButton.layer.masksToBounds = YES;
    doneButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [doneButton addTarget:self action:@selector(touchDoneAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [toolsBar addSubview:doneButton];
    
    __weak typeof(self) weakself = self;
    AssetHelper.photoCountChange = ^(BOOL reloadData){
        if (AssetHelper.selectPhotoAssets.count > 0) {
            [doneButton setTitle:[NSString stringWithFormat:@"确定(%ld)",AssetHelper.selectPhotoAssets.count] forState:(UIControlStateNormal)];
            doneButton.enabled = YES;
            [doneButton setBackgroundColor:[UIColor colorWithRed:255/255.0 green:81/255.0 blue:84/255.0 alpha:1]];
            
            preViewButton.enabled = YES;

        }else{
            doneButton.enabled = NO;
            [doneButton setTitle:@"确定" forState:(UIControlStateNormal)];
            [doneButton setBackgroundColor:[UIColor colorWithRed:151/255.0 green:151/255.0 blue:151/255.0 alpha:1]];
            
            preViewButton.enabled = NO;
        }
        if (reloadData) {
            [weakself.photoColletionView reloadData];
            
        }
    };
    
}


- (void)dealloc {
    [AssetHelper clearSelectPhotoAssets];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"%s,%ld",__FUNCTION__,(long)[AssetHelper getPhotoCount]);
    return [AssetHelper getPhotoCount];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];

    [cell configCellWithIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];

    PhotoBrowserController *browserVC = [[PhotoBrowserController alloc] initWithData:AssetHelper.assetPhotos preIndex:indexPath.row isPreView:NO];
   [self.navigationController pushViewController:browserVC animated:YES];
}



- (void)touchPreViewAction:(id)sender {
    NSLog(@"%s",__FUNCTION__);
    PhotoBrowserController *browserVC = [[PhotoBrowserController alloc] initWithData:AssetHelper.selectPhotoAssets preIndex:0 isPreView:YES];

    [self.navigationController pushViewController:browserVC animated:YES];

}

- (void)touchDoneAction:(id)sender {
    NSLog(@"%s",__FUNCTION__);

    __weak typeof(self) weakself = self;

    [AssetHelper getOrignImageWithAssets:AssetHelper.selectPhotoAssets  callback:^(NSMutableArray *photos) {
        [AssetHelper hideWaitingInView:weakself.view];
        [weakself dismissViewControllerAnimated:YES completion:^{
            
            if (AssetHelper.delegate && [AssetHelper.delegate respondsToSelector:@selector(x_ImagePickerControllerSelectPhotos:)]) {
                [AssetHelper.delegate x_ImagePickerControllerSelectPhotos:photos];
            }
            [AssetHelper clearSelectPhotoAssets];
        }];
        
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        [AssetHelper creatWaitingViewInView:weakself.view title:@"正在从iCloud同步..."];
        
    }];
    
}

- (void)touchBackItem:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)cancel:(id)sender {
    [AssetHelper clearSelectPhotoAssets];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//
//
//#pragma mark - 添加手势的方法
//- (void)addScreenLeftEdgePanGestureRecognizer:(UIView *)view {
//    UIScreenEdgePanGestureRecognizer * edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgePanGesture:)]; //手势由self来管理
//    edgePan.edges = UIRectEdgeLeft;
//    [view addGestureRecognizer:edgePan];
//}
//
//#pragma mark - 手势的监听方法
//- (void)edgePanGesture:(UIScreenEdgePanGestureRecognizer *)edgePan{
//    CGFloat progress = fabs([edgePan translationInView:[UIApplication sharedApplication].keyWindow].x / [UIApplication sharedApplication].keyWindow.bounds.size.width);
//
//    if(edgePan.state == UIGestureRecognizerStateBegan){
//        self.percentDrivenTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
//        if(edgePan.edges == UIRectEdgeLeft){
//            [self dismissViewControllerAnimated:YES completion:^{
//
//            }];
//        }
//    }else if(edgePan.state == UIGestureRecognizerStateChanged){
//        [self.percentDrivenTransition updateInteractiveTransition:progress];
//    }else if(edgePan.state == UIGestureRecognizerStateCancelled || edgePan.state == UIGestureRecognizerStateEnded){
//        if(progress > 0.5){
//            [_percentDrivenTransition finishInteractiveTransition];
//        }else{
//            [_percentDrivenTransition cancelInteractiveTransition];
//        }
//        _percentDrivenTransition = nil;
//    }
//}


@end
