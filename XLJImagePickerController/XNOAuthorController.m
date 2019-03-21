//
//  XNOAuthorController.m
//  HQImagePickerController
//
//  Created by lijun_xue on 2018/11/19.
//

#import "XNOAuthorController.h"
#import "XLJAssetHelper.h"
@interface XNOAuthorController ()
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (nonatomic,assign) BOOL isCamera;
@end

@implementation XNOAuthorController


+ (void)jumpNoAuthorController:(UIViewController *)controller isCamera:(BOOL)isCamera {
    
    XNOAuthorController *noAuthorVC = [[XNOAuthorController alloc] initWithNibName:@"XNOAuthorController" bundle:[XLJAssetHelper getXibBundle]];
    noAuthorVC.isCamera = isCamera;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:noAuthorVC];
    [controller presentViewController:nav animated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNavgationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configNavgationBar {
    
    NSString *title = self.isCamera? @"相机" : @"照片";
    
    self.navigationItem.title = title;
    
    NSString *tipString = [NSString stringWithFormat:@"请在iPhone的 ""设置-隐私-%@"" 选项中，选择允许 %@ 的访问",title,[XLJAssetHelper getAppName]];
    
    self.tipLabel.text = tipString;
    UIButton *cancel = [UIButton buttonWithType:(UIButtonTypeCustom)];
    cancel.frame = CGRectMake(0, 0, 40, 40);
    [cancel setTitle:@"取消" forState:(UIControlStateNormal)];
    [cancel setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:(UIControlStateNormal)];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:(UIControlEventTouchUpInside)];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    self.navigationItem.rightBarButtonItem = cancelItem;
    
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
