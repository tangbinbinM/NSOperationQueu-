//
//  ViewController.m
//  NSOperationQueu依赖监听
//
//  Created by YiGuo on 2017/10/25.
//  Copyright © 2017年 tbb. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self addDependency2];
}

-(void)addDependency2{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    __block UIImage *image1 = nil;
    NSBlockOperation *download1 = [NSBlockOperation blockOperationWithBlock:^{
        // 图片地址
        NSURL *url = [NSURL URLWithString:@"http://f.hiphotos.baidu.com/zhidao/pic/item/023b5bb5c9ea15cea34d6805b0003af33a87b21f.jpg"];
        //加载图片
        NSData *data = [NSData dataWithContentsOfURL:url];
        // 生成图片
        image1 = [UIImage imageWithData:data];
    }];
    __block UIImage *image2 = nil;
    NSBlockOperation *download2 = [NSBlockOperation blockOperationWithBlock:^{
        // 图片地址
        NSURL *url = [NSURL URLWithString:@"http://b.hiphotos.baidu.com/image/pic/item/a686c9177f3e6709f0e60b3f32c79f3df9dc550f.jpg"];
        //加载图片
        NSData *data = [NSData dataWithContentsOfURL:url];
        // 生成图片
        image2 = [UIImage imageWithData:data];
    }];
    //合成图片
    NSBlockOperation *combine = [NSBlockOperation blockOperationWithBlock:^{
        //开启图文上下文
        UIGraphicsBeginImageContext(CGSizeMake(100, 100));
        //绘制图形
        [image1 drawInRect:CGRectMake(0, 0, 50, 100)];
        image1 = nil;
        [image2 drawInRect:CGRectMake(50, 0, 50, 100)];
        image2 = nil;
        UIImage *iamge = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //回主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = iamge;
        }];
    }];
    
    [combine addDependency:download1];
    [combine addDependency:download2];
    
    [queue addOperation:download1];
    [queue addOperation:download2];
    [queue addOperation:combine];
    NSLog(@"22");
}
-(void)addDependency1{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"download1-%@", [NSThread  currentThread]);

    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"download2--%@", [NSThread  currentThread]);
    }];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"download3---%@", [NSThread  currentThread]);
    }];
    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        for (NSInteger i = 0; i<100; i++) {
            NSLog(@"download4----%@", [NSThread  currentThread]);
        }
    }];
    NSBlockOperation *op5 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"download5-----%@", [NSThread  currentThread]);
    }];
    //监听法1
//    op5.completionBlock = ^{
//        NSLog(@"op5执行download5完毕-----%@", [NSThread  currentThread]);
//    };
    //监听法2
    [op5 setCompletionBlock:^{
        NSLog(@"op5执行download5完毕-----%@", [NSThread  currentThread]);
    }];
    // 设置依赖
    [op3 addDependency:op1];
    [op3 addDependency:op2];
    
//    [op3 addDependency:op4];
    
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    [queue addOperation:op4];
    [queue addOperation:op5];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
