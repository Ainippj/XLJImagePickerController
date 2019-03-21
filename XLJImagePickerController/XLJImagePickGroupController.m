//
//  XLJImagePickGroupController.m
//  Pods-XLJImagePickControllerDemo
//
//  Created by lijun_xue on 2018/9/10.
//

#import "XLJImagePickGroupController.h"
#import "XLJImagePickController.h"
#import "XLJVideoPickerController.h"
#import "XLJAssetHelper.h"
#import "CollectionCell.h"
@interface XLJImagePickGroupController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic,assign) BOOL isVideo;
@end

@implementation XLJImagePickGroupController

+ (void)jumpImagPickGroupController:(UIViewController *)controller  isVideo:(BOOL)isVideo {
    XLJImagePickGroupController *groupVC = [[XLJImagePickGroupController alloc] init];
    groupVC.isVideo = isVideo;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:groupVC];
    [controller presentViewController:nav animated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

    [self configNavgationBar];
    [self createTableView];
    [self loadCollections];
}

- (void)loadCollections {
    
    __weak typeof(self) weakself = self;
    [AssetHelper getAllCollectionIsVideo:self.isVideo result:^(NSMutableArray *collections) {
        [weakself.tableView reloadData];
        [weakself jumpImagePickController:weakself];
    }];
}


- (void)configNavgationBar {
    self.navigationItem.title = @"相册";
    UIButton *cancel = [UIButton buttonWithType:(UIButtonTypeCustom)];
    cancel.frame = CGRectMake(0, 0, 40, 40);
    [cancel setTitle:@"取消" forState:(UIControlStateNormal)];
    [cancel setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:(UIControlStateNormal)];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:(UIControlEventTouchUpInside)];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    self.navigationItem.rightBarButtonItem = cancelItem;
    
}

- (void)createTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TopHeight, Width, Height - TopHeight) style:(UITableViewStylePlain)];
    self.tableView = tableView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CollectionCell class]) bundle:[XLJAssetHelper getXibBundle]] forCellReuseIdentifier:NSStringFromClass([CollectionCell class])];
    
}

- (void)jumpImagePickController:(UIViewController *)controller {
    [XLJAssetHelper instance].selectGroupIndex = 0;
    if (self.isVideo) {
        [XLJVideoPickerController jumpViedioPickController:controller animation:NO];
    }else{
        [XLJImagePickController jumpImagePickController:controller animation:NO];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%s,%ld",__FUNCTION__,[AssetHelper getCollectionCount]);
    return [AssetHelper getCollectionCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CollectionCell class]) forIndexPath:indexPath];

    [cell configCellWithIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return groupCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%s,%ld",__FUNCTION__,indexPath.row);

    AssetHelper.selectGroupIndex = indexPath.row;
    if (self.isVideo) {
        [XLJVideoPickerController jumpViedioPickController:self animation:YES];
    }else{
        [XLJImagePickController jumpImagePickController:self animation:YES];
    }

}


- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
