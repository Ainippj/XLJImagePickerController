//
//  XLJVideoPreViewController.m
//  HQImagePickerController
//
//  Created by lijun_xue on 2018/10/26.
//

#import "XLJVideoPreViewController.h"
#import "PreViewCell.h"
@interface XLJVideoPreViewController ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
UIScrollViewDelegate,
VideoPreCellDelegate>
@property (nonatomic,weak) UIView *bottomToolBar;
@property (nonatomic,weak) UIButton *doneButton;


@property (nonatomic,weak) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *dataArray;//用于操作的数据
@property (nonatomic,assign) NSInteger currentIndex;

@end

@implementation XLJVideoPreViewController
-(XLJVideoPreViewController *)initWithData:(NSArray *)data preIndex:(NSInteger)preIndex {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.dataArray = data;
        AssetHelper.preViewIndex = preIndex;
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:AssetHelper.preViewIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
    self.currentIndex = AssetHelper.preViewIndex;
    
}




- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [AssetHelper setUpAudioSession];
    [self createCollectionView];
    [self createBottomToolsBar];
    [self createTopToolsBar];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)createCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(Width, Height);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 40.0;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    layout.minimumInteritemSpacing = 0.0f;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-20, 0, Width + 40, Height) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView = collectionView;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[PreViewCell class] forCellWithReuseIdentifier:@"VideoPreCell"];
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PreViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoPreCell" forIndexPath:indexPath];
    [cell configCellWithPhotoAsset:self.dataArray[indexPath.row]];
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) {
    
}
//

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    PreViewCell *videoCell = (PreViewCell *)cell;
    [videoCell handleDidEndDisPlaying];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat index = offsetX/(Width + 40);
    NSInteger currentIndex = offsetX/(Width + 40);
    CGFloat dif = index - currentIndex;
    
    if (dif > 0.9) {
        currentIndex = currentIndex + 1;
    }
    
    PreViewCell *cell = (PreViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]];
    [cell pasuePlay];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger currentIndex = offsetX/(Width + 40);
    self.currentIndex = currentIndex;
}






- (void)createTopToolsBar {
    
    NSBundle *resourceBundle = [XLJAssetHelper getResourceBundle];
    
    UIImage *backImage = [UIImage imageNamed:@"back_b" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    
    UIButton *backBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    backBtn.frame = CGRectMake(0, 0, 40, 40);
    [backBtn setImage:backImage forState:(UIControlStateNormal)];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
    [backBtn addTarget:self action:@selector(touchBackItem:) forControlEvents:(UIControlEventTouchUpInside)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}


- (void)createBottomToolsBar {
    
    UIView *bottomToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, Height - BottomHeight - 44, Width, 44 + BottomHeight)];
    bottomToolBar.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    self.bottomToolBar = bottomToolBar;
    [self.view addSubview:bottomToolBar];
    UIBezierPath *linePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, Width, 0.5)];
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = linePath.CGPath;
    lineLayer.fillColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0].CGColor;
    [bottomToolBar.layer addSublayer:lineLayer];
    
    UIButton *doneBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    doneBtn.frame = CGRectMake(Width - 68, 4, 60, 30);
    [doneBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:81/255.0 blue:84/255.0 alpha:1]];
    [doneBtn setTitle:@"确定" forState:(UIControlStateNormal)];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [doneBtn addTarget:self action:@selector(touchDoneItem:) forControlEvents:(UIControlEventTouchUpInside)];
    
    doneBtn.layer.cornerRadius = 3;
    doneBtn.layer.masksToBounds = YES;
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.doneButton = doneBtn;
    [self.bottomToolBar addSubview:doneBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    cancelBtn.frame = CGRectMake(8, 7, 60, 30);
    [cancelBtn setTitle:@"取消" forState:(UIControlStateNormal)];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [cancelBtn addTarget:self action:@selector(touchCancelItem:) forControlEvents:(UIControlEventTouchUpInside)];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [self.bottomToolBar addSubview:cancelBtn];
    
}


- (void)touchDoneItem:(id)sender {
    NSLog(@"%s",__FUNCTION__);
    __weak typeof(self) weakself = self;
    PHAsset *photo = [AssetHelper getCurrentAssetWithIndex:self.currentIndex];
    
    [AssetHelper getCurrentVideoItemByVideoAsset:photo callback:^(AVURLAsset* urlAsset) {
        [AssetHelper hideWaitingInView:weakself.view];
        [AssetHelper creatWaitingViewInView:weakself.view title:@"正在处理..."];
        [AssetHelper handelVideoDataToMp4WithFileUrl:urlAsset.URL callback:^(NSString *filePath) {
            [AssetHelper hideWaitingInView:weakself.view];
          
            XVideoModel *videoModel = [[XVideoModel alloc] init];
            videoModel.duration = photo.duration;
            videoModel.orignImage = [AssetHelper getImageFromfileURL:urlAsset.URL];
            videoModel.filePath = filePath;
            [AssetHelper removeItemByFilePath:urlAsset.URL];
            [weakself dismissViewControllerAnimated:YES completion:^{
                if (AssetHelper.delegate && [AssetHelper.delegate respondsToSelector:@selector(x_ImagePickerControllerSelectVideoModle:)]) {
                    [AssetHelper.delegate x_ImagePickerControllerSelectVideoModle:videoModel];
                }
            }];
        }];
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        [AssetHelper creatWaitingViewInView:weakself.view title:@"正在从iCloud同步..."];
    }];
    
}

- (void)touchBackItem:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchCancelItem:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (void)videoPreCell:(UICollectionViewCell *)cell playActionIndex:(NSInteger)index isPlaying:(BOOL)isPlaying {
    
    if (isPlaying) {
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomToolBar.frame = CGRectMake(0, Height, Width, 44 + BottomHeight);
        } completion:^(BOOL finished) {
            self.bottomToolBar.hidden = YES;
        }];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        self.collectionView.backgroundColor = [UIColor blackColor];
        
    }else{
        
        self.bottomToolBar.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomToolBar.frame = CGRectMake(0, Height - BottomHeight - 44, Width, 44 + BottomHeight);
        } completion:^(BOOL finished) {
         
        }];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        self.collectionView.backgroundColor = [UIColor whiteColor];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
