//
//  AboutUsViewController.m
//  zpp
//
//  Created by Chuck on 16/7/14.
//  Copyright © 2016年 myncic.com. All rights reserved.
//

#import "AboutUsViewController.h"
#import "MainViewController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (id)initWithIcon:(UIImage*)img year:(NSString*)year{
    self = [super init];
    if (self) {
        icon = img;
        showYear = year;
        if(showYear == nil){
            showYear = @"2017";
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     [self initViews];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    if([APPUtils isTheSameColor2:TITLE_WORD_COLOR anotherColor:[UIColor whiteColor]]){//标题是白色
        return UIStatusBarStyleLightContent;
    }else{
        return UIStatusBarStyleDefault;
    }
    
}

-(void)initViews{
    
    

    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    ZppTitleView *titletView = [[ZppTitleView alloc] initWithTitle:@"关于我们"];
    [self.view addSubview:titletView];
    titletView.goback = ^(){
        [self beBack];
    };
    
    
    bodyView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, BODYHEIGHT)];
    bodyView.showsVerticalScrollIndicator = NO;
 
    
    
    [bodyView setBackgroundColor:MAINGRAY];
    
    [self.view addSubview:bodyView];
    
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-80)/2, SCREENHEIGHT<=480?15:50, 80, 80)];
    logoImageView.layer.cornerRadius = logoImageView.height/2;
    [logoImageView.layer setMasksToBounds:YES];
    [logoImageView setImage:icon];
    [bodyView addSubview:logoImageView];
    
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    infoDictionary = nil;
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, logoImageView.height+logoImageView.y+10, SCREENWIDTH, 20)];
    versionLabel.text = [NSString stringWithFormat:@"%@ v%@",appCurName,version];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.textColor = TEXTGRAY;
    versionLabel.font = [UIFont fontWithName:textDefaultFont size:13];
    [bodyView addSubview:versionLabel];

   

    
    //打电话
    MyBtnControl *teleControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, versionLabel.y+(SCREENHEIGHT<=480?30:70), SCREENWIDTH, 50)];
    [teleControl setBackgroundColor:[UIColor whiteColor]];
    teleControl.clickBackBlock = ^(){
        CCActionSheet *actionSheet = [[CCActionSheet alloc] initWithTitle:@"呼叫 博文软件开发有限公司客服?" clickedAtIndex:^(NSInteger index) {
            
            if(index == 0){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",@"4000852400"]]];
            }
            
        } cancelButtonTitle:@"取消" otherButtonTitles:@"400-0852-400",nil];
        
        [actionSheet show];
        actionSheet = nil;
    };
    [bodyView addSubview:teleControl];
    
    ;
    
 
    [teleControl addSubview:[APPUtils get_line:0 y:0 width:SCREENWIDTH]];
    
    [teleControl addLabel:@"拨打客服电话" color:TEXTGRAY font:[UIFont fontWithName:textDefaultFont size:14] txtAlignment:NSTextAlignmentLeft x:15];
    
 
    [teleControl addSubview:[APPUtils get_forward:teleControl.height x:SCREENWIDTH-30]];
 
    
    //进网站
    MyBtnControl *webControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, teleControl.y+50, SCREENWIDTH, 50)];
    [webControl setBackgroundColor:[UIColor whiteColor]];
    webControl.clickBackBlock = ^(){
        WebViewController *webview = [[WebViewController alloc] initWithtitle:@"博文软件官方网站" url:@"http://www.myncic.com"];
        [self.navigationController pushViewController:webview animated:YES];
        webview = nil;
    };

    [bodyView addSubview:webControl];
    

    [webControl addSubview:[APPUtils get_line:15 y:0 width:SCREENWIDTH-30]];

    
    
    [webControl addLabel:@"访问官网" color:TEXTGRAY font:[UIFont fontWithName:textDefaultFont size:14] txtAlignment:NSTextAlignmentLeft x:15];
   
    

    [webControl addSubview:[APPUtils get_forward:webControl.height x:SCREENWIDTH-30]];
 

  
    [webControl addSubview:[APPUtils get_line:0 y:49.5 width:SCREENWIDTH]];
 
    
    
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSLineBreakByWordWrapping;
    [paragraph setLineSpacing:3];
    
    NSString *showString = [NSString stringWithFormat:@"博文软件开发有限公司 荣誉出品\n%@ MYNCIC GROUP © All Rights Reserved",showYear];
    
    NSMutableAttributedString *attributedString =  [[NSMutableAttributedString alloc] initWithString:showString attributes:@{NSKernAttributeName : @(0.1f)}];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, showString.length)];
    
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bodyView.height-50, SCREENWIDTH, 50)];
    nameLabel.attributedText = attributedString;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor lightGrayColor];
    nameLabel.numberOfLines=0;
    nameLabel.font = [UIFont fontWithName:textDefaultFont size:12];
    [bodyView addSubview:nameLabel];
    
    attributedString = nil;
    paragraph = nil;
    nameLabel = nil;
 
    webControl = nil;
    teleControl = nil;
    logoImageView = nil;
    versionLabel = nil;
}






- (void)beBack{
    
    //退回到第一个窗口
    [self.navigationController popViewControllerAnimated:YES];
 
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {


}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
