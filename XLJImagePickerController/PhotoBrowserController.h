//
//  PhotoBrowserController.h
//  Pods-ImagePickerDemo
//
//  Created by lijun_xue on 2018/9/13.
//

#import <UIKit/UIKit.h>

@interface PhotoBrowserController : UIViewController
-(PhotoBrowserController *)initWithData:(NSArray *)data preIndex:(NSInteger)preIndex isPreView:(BOOL)isPreView;
@end
