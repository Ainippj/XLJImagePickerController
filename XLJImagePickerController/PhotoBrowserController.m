//
//  PhotoBrowserController.m
//  Pods-ImagePickerDemo
//
//  Created by lijun_xue on 2018/9/13.
//

#import "PhotoBrowserController.h"
#import "XLJAssetHelper.h"
#import "BrowserCell.h"
#import "PreThumCell.h"
@interface PhotoBrowserController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,BrowserCellDelegate>
@property (nonatomic,weak) UICollectionView *collectionView;
@property (nonatomic,weak) UICollectionView *bottomCollectionView;
@property (nonatomic,weak) UIView *bottomToolBar;
@property (nonatomic,strong) NSArray *tempArray;//用于显示的数据
@property (nonatomic,strong) NSArray *data;//用于操作的数据
@property (nonatomic,strong) NSMutableDictionary *photoDict;//用于记录预览是照片对应的groupIndex_index :index
@property (nonatomic,strong) NSMutableDictionary *indexDict;//用于记录底部预览列表照片在dataArray 中的索引
@property (nonatomic,weak) UIButton *selectButton;
@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,weak) UIButton *doneButton;
@property (nonatomic,assign) CGFloat currentOffSetX;

@property (nonatomic,strong) PreThumModel *selectedModel;

@property (nonatomic,strong) NSMutableArray *preThumArray;//预览缩略图的数据
@end

@implementation PhotoBrowserController

-(PhotoBrowserController *)initWithData:(NSArray *)data preIndex:(NSInteger)preIndex isPreView:(BOOL)isPreView{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.tempArray = [data copy];
        self.data = data;
        AssetHelper.preViewIndex = preIndex;
        AssetHelper.isPreView = isPreView;
    }
    return self;
}


- (NSMutableDictionary *)photoDict {
    if (!_photoDict) {
        _photoDict = [NSMutableDictionary dictionary];
    }
    return _photoDict;
}

- (NSMutableDictionary *)indexDict {
    if (!_indexDict) {
        _indexDict = [NSMutableDictionary dictionary];
    }
    return _indexDict;
}

- (NSMutableArray *)preThumArray {
    if (!_preThumArray) {
        _preThumArray = [NSMutableArray array];
    }
    return _preThumArray;
}


- (void)initPreThumData {
    for (int i = 0; i < AssetHelper.selectPhotoAssets.count; i ++) {
        PHAsset *asset = AssetHelper.selectPhotoAssets[i];
        PreThumModel *preModel = [[PreThumModel alloc] init];
        preModel.photoAsset = asset;
        preModel.isSelected = NO;
        [self.preThumArray addObject:preModel];
    }
}


- (void)handleData {

    for (int i = 0; i < self.data.count; i ++) {
        NSString *key = [NSString stringWithFormat:@"%d",i];
        
        if (AssetHelper.isPreView) {
            PHAsset *asset = self.data[i];
            NSArray *values = [AssetHelper.selectDict allKeys];
            for (int j = 0; j < values.count; j ++) {
                if ([AssetHelper.selectDict[values[j]] isEqual:asset]) {
                    [self.photoDict setValue:values[j] forKey:key];
                }
            }
        }else{
            NSString *seletKey = [NSString stringWithFormat:@"%ld_%d",(long)AssetHelper.selectGroupIndex,i];
            [self.photoDict setValue:seletKey forKey:key];
        }
        
    }
    
    [self handleSelectedData];
}



- (void)handleSelectedData {
    self.indexDict = nil;
    for (int i = 0; i < AssetHelper.selectPhotoAssets.count; i ++) {
        NSString *key = [NSString stringWithFormat:@"%d",i];
        PHAsset *asset = AssetHelper.selectPhotoAssets[i];
        NSInteger index = [self.tempArray indexOfObject:asset];
        [self.indexDict setValue:[NSString stringWithFormat:@"%ld",index] forKey:key];
    }
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:AssetHelper.preViewIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
    self.currentIndex = AssetHelper.preViewIndex;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self handleData];
    [self initPreThumData];
    [self createCollectionView];
    [self crreateBootomCollectionView];
    [self createTopToolsBar];
    [self createBottomToolsBar];
}


-(void)dealloc {
    [self.photoDict removeAllObjects];
    self.photoDict = nil;
    self.tempArray = nil;
}

- (void)createCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(Width, Height);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 40;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    layout.minimumInteritemSpacing = 0.0f;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-20, 0, Width + 40, Height) collectionViewLayout:layout];
    self.collectionView = collectionView;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.view.layer.masksToBounds = YES;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BrowserCell" bundle:[XLJAssetHelper getXibBundle]] forCellWithReuseIdentifier:@"BrowserCell"];
   
}

- (void)crreateBootomCollectionView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(60, 60);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 0.0f;
    
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, Height -44 - BottomHeight - 80, Width, 80) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    
    UIBezierPath *linePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, Width, 0.5)];
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = linePath.CGPath;
    lineLayer.fillColor = [UIColor groupTableViewBackgroundColor].CGColor;
    [collectionView.layer addSublayer:lineLayer];
    
    self.bottomCollectionView = collectionView;
    self.bottomCollectionView.pagingEnabled = YES;
    self.bottomCollectionView.delegate = self;
    self.bottomCollectionView.dataSource = self;
    self.bottomCollectionView.showsHorizontalScrollIndicator = NO;
    self.bottomCollectionView.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
    [self.view addSubview:self.bottomCollectionView];
    [self.bottomCollectionView registerClass:[PreThumCell class] forCellWithReuseIdentifier:@"PreThumCell"];
    self.bottomCollectionView.hidden = !AssetHelper.selectPhotoAssets.count;

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
    
    if (AssetHelper.maxCount >= 1) {
        UIButton *selectBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        selectBtn.frame = CGRectMake(0, 0, 40, 40);
        [selectBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -20)];
        
        [selectBtn addTarget:self action:@selector(touchSelectItem:) forControlEvents:(UIControlEventTouchUpInside)];
        self.selectButton = selectBtn;
        [self configSelectButtonStateWithIndex:AssetHelper.preViewIndex];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:selectBtn];
    }
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
    doneBtn.frame = CGRectMake(Width - 68, 7, 60, 30);
    if (AssetHelper.selectPhotoAssets.count > 0) {
        doneBtn.enabled = YES;
        [doneBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:81/255.0 blue:84/255.0 alpha:1]];
        if (AssetHelper.maxCount <=1) {
                [doneBtn setTitle:@"确定" forState:(UIControlStateNormal)];
        }else{
            [doneBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",AssetHelper.selectPhotoAssets.count] forState:(UIControlStateNormal)];
        }
    }else{
        [doneBtn setBackgroundColor:[UIColor colorWithRed:151/255.0 green:151/255.0 blue:151/255.0 alpha:1]];
        doneBtn.enabled = NO;
        [doneBtn setTitle:@"确定" forState:(UIControlStateNormal)];
    }
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [doneBtn addTarget:self action:@selector(touchDoneItem:) forControlEvents:(UIControlEventTouchUpInside)];
    
    doneBtn.layer.cornerRadius = 3;
    doneBtn.layer.masksToBounds = YES;
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.doneButton = doneBtn;
    [self.bottomToolBar addSubview:doneBtn];
    
//    UIButton *cancelBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
//    cancelBtn.frame = CGRectMake(8, 7, 60, 30);
//    [cancelBtn setTitle:@"取消" forState:(UIControlStateNormal)];
//    [cancelBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
//    [cancelBtn addTarget:self action:@selector(touchCancelItem:) forControlEvents:(UIControlEventTouchUpInside)];
//    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//
//    [self.bottomToolBar addSubview:cancelBtn];

}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([collectionView isEqual:self.collectionView]) {
        return self.tempArray.count;
    }else {
        return self.preThumArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.collectionView]) {
        BrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BrowserCell" forIndexPath:indexPath];
        [cell configCellWithPhotoAsset:self.tempArray[indexPath.row]];
        cell.delegate = self;
        return cell;
    }else{
        
        PreThumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PreThumCell" forIndexPath:indexPath];
        PreThumModel *model = self.preThumArray[indexPath.row];
        [cell configCellWithPhotoAssetModel:model];
        
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if(collectionView == self.collectionView){
       
    }else{
        [self configPreThumSelecteCellsWithIndexPath:indexPath isSelect:YES];
        [self scrollCollectionView:self.bottomCollectionView AtIndex:indexPath.row animated:YES];
        
        NSString *key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        NSString *value = self.indexDict[key];
        [self scrollCollectionView:self.collectionView AtIndex:value.integerValue animated:NO];
        self.currentIndex = value.integerValue;
        [self configSelectButtonStateWithIndex:self.currentIndex];
    }
}

- (void)configPreThumSelecteCellsWithIndexPath:(NSIndexPath *)indexPath isSelect:(BOOL)isSelect{
    self.selectedModel.isSelected = NO;
    if (isSelect) {
        PreThumModel *model = self.preThumArray[indexPath.row];
        model.isSelected = isSelect;
        self.selectedModel = model;
    }
    [self.bottomCollectionView reloadData];
}


- (void)scrollCollectionView:(UICollectionView *)collectionView AtIndex:(NSInteger )index animated:(BOOL)animated {
    [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) {

    if([collectionView isEqual:self.collectionView]){
        BrowserCell *browserCell = (BrowserCell *)cell;
        [browserCell resetScrollZoom];
    }else{
        
      
        
        
    }
    
}


- (void)configSelectButtonStateWithIndex:(NSInteger)index {
    
    NSString *key = [NSString stringWithFormat:@"%ld",(long)index];
    NSString *keyValue = self.photoDict[key];
    PHAsset *selectPhoto = [AssetHelper.selectDict valueForKey:keyValue];
    NSLog(@"dic: %@,key :%@",AssetHelper.selectDict,keyValue);
    NSBundle *resourceBundle = [XLJAssetHelper getResourceBundle];
    UIImage *selectImage = nil;

    if (selectPhoto) {
        selectImage = [UIImage imageNamed:@"pre_selected" inBundle:resourceBundle compatibleWithTraitCollection:nil];
        self.selectButton.selected = YES;
        NSInteger index = [AssetHelper.selectPhotoAssets indexOfObject:selectPhoto];
        [self configPreThumSelecteCellsWithIndexPath:[NSIndexPath indexPathForRow:index inSection:0] isSelect:YES];
        [self scrollCollectionView:self.bottomCollectionView AtIndex:index animated:YES];

    }else{
        [self configPreThumSelecteCellsWithIndexPath:nil isSelect:NO];
        selectImage = [UIImage imageNamed:@"pre_select" inBundle:resourceBundle compatibleWithTraitCollection:nil];
        self.selectButton.selected = NO;
    }
    [self.selectButton setImage:selectImage forState:(UIControlStateNormal)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollview {

    if ([scrollview isEqual:self.bottomCollectionView]) {
        NSLog(@"%s",__FUNCTION__);
    }
    
    if([scrollview isEqual:self.collectionView]){
        
        CGFloat offsetX = scrollview.contentOffset.x;
        NSInteger index = self.currentIndex;
        
        CGFloat temp = fabs(self.currentOffSetX - offsetX);
        if (temp > Width/2 + 20) {
            if (self.currentOffSetX >= offsetX) {
               index --;
            }else {
                index ++;
            }
        }
        [self configSelectButtonStateWithIndex:index];
    }else{
        
        
    }
    
}
 // called when scroll view grinds to a halt
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if([scrollView isEqual:self.collectionView]){
        CGFloat offsetX = scrollView.contentOffset.x;
        NSInteger index = offsetX/(Width + 40);
        self.currentIndex = index;
        NSLog(@"%s,Page :%zd",__FUNCTION__,index);
        self.currentOffSetX = offsetX;
        [self configSelectButtonStateWithIndex:index];

    }else{


    }
    
}

- (void)browserCellTouchHideOrShowToolBars {
    
    if (self.bottomToolBar.hidden == NO) {
        self.bottomCollectionView.hidden = YES;
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
            if (AssetHelper.selectPhotoAssets.count) {
                self.bottomCollectionView.hidden = NO;
            }
        }];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        self.collectionView.backgroundColor = [UIColor whiteColor];

    }

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchBackItem:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchSelectItem:(id)sender {
    NSLog(@"%s",__FUNCTION__);
    NSBundle *resourceBundle = [XLJAssetHelper getResourceBundle];
    
    NSInteger realIndex = self.currentIndex;//如果是查看,当前索引即为在改相册中的索引
    
    NSString *key = [NSString stringWithFormat:@"%ld",(long)realIndex];
    NSString *keyValue = self.photoDict[key];
    
    NSMutableDictionary *selectDict = AssetHelper.selectDict;
    NSMutableArray *selectPhotoAssets = AssetHelper.selectPhotoAssets;
    
    if (self.selectButton.selected) {
        UIImage *image = [UIImage imageNamed:@"pre_select" inBundle:resourceBundle compatibleWithTraitCollection:nil];
        
        [self.selectButton setImage:image forState:UIControlStateNormal];
        
        PHAsset *photoAsset = [AssetHelper.selectDict valueForKey:keyValue];
        //在选中的索引
        NSInteger index = [AssetHelper.selectPhotoAssets indexOfObject:photoAsset];
        if (photoAsset) {
            [selectPhotoAssets removeObject:photoAsset];
            [self.preThumArray removeObjectAtIndex:index];
        }
        [selectDict removeObjectForKey:keyValue];
        self.selectButton.selected = NO;
        [self.bottomCollectionView reloadData];

    }else{
        if (AssetHelper.selectPhotoAssets.count == AssetHelper.maxCount) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"您最多只能选择%ld张照片",(long)AssetHelper.maxCount] delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil,nil];
            [alert show];
            return;
        }
        UIImage *image = [UIImage imageNamed:@"pre_selected" inBundle:resourceBundle compatibleWithTraitCollection:nil];
        
        [self.selectButton setImage:image forState:UIControlStateNormal];
      
        NSArray *keyArray = [keyValue componentsSeparatedByString:@"_"];
        NSInteger index = [keyArray.lastObject integerValue];
        PHAsset *asset = [AssetHelper getCurrentAssetWithIndex:index];
        [selectPhotoAssets addObject:asset];
        [selectDict setValue:asset forKey:keyValue];
        self.selectedModel.isSelected = NO;
        PreThumModel *photoModel = [[PreThumModel alloc] init];
        photoModel.photoAsset = asset;
        photoModel.isSelected = YES;
        self.selectedModel = photoModel;
        [self.preThumArray addObject:photoModel];
        [self.bottomCollectionView reloadData];
        NSInteger assetIndex = [AssetHelper.selectPhotoAssets indexOfObject:asset];
        [self.bottomCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:assetIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:YES];
        self.selectButton.selected = YES;
    }
    
    if (AssetHelper.selectPhotoAssets.count > 0) {
        self.doneButton.enabled = YES;
        [self.doneButton setBackgroundColor:[UIColor colorWithRed:255/255.0 green:81/255.0 blue:84/255.0 alpha:1]];
           [self.doneButton setTitle:[NSString stringWithFormat:@"确定(%ld)",AssetHelper.selectPhotoAssets.count] forState:(UIControlStateNormal)];
    }else{
        self.doneButton.enabled = NO;
        [self.doneButton setBackgroundColor:[UIColor colorWithRed:151/255.0 green:151/255.0 blue:151/255.0 alpha:1]];
        [self.doneButton setTitle:@"确定" forState:(UIControlStateNormal)];

    }
    NSLog(@"SelectItem dic: %@,key :%@",AssetHelper.selectDict,keyValue);

    AssetHelper.photoCountChange(YES);
    __weak typeof(self) weakself = self;

    if (AssetHelper.selectPhotoAssets.count > 0) {
        weakself.bottomCollectionView.hidden = NO;
    }else{
        weakself.bottomCollectionView.hidden = YES;
    }
    [self handleSelectedData];

}

- (void)touchDoneItem:(id)sender {
    NSLog(@"%s",__FUNCTION__);
    __weak typeof(self) weakself = self;
    NSMutableArray *selectAsset = AssetHelper.selectPhotoAssets;
    if (AssetHelper.maxCount <=1) {
        selectAsset = [@[self.tempArray[self.currentIndex]] mutableCopy];
    }
    [AssetHelper getOrignImageWithAssets:selectAsset callback:^(NSMutableArray *photos) {
        [AssetHelper hideWaitingInView:weakself.collectionView];
        [weakself dismissViewControllerAnimated:YES completion:^{
            if (AssetHelper.delegate && [AssetHelper.delegate respondsToSelector:@selector(x_ImagePickerControllerSelectPhotos:)]) {
                [AssetHelper.delegate x_ImagePickerControllerSelectPhotos:photos];
            }
            [AssetHelper clearSelectPhotoAssets];
        }];
        
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        [AssetHelper creatWaitingViewInView:weakself.collectionView title:@"正在从iCloud同步..."];
        
    }];
    
}


- (void)touchCancelItem:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
