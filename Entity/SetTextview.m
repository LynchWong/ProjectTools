//
//  SetTextview.m
//  wuneng
//
//  Created by Chuck on 2017/6/13.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "SetTextview.h"
#import "MainViewController.h"

@implementation SetTextview


- (id)initWithTitle:(NSString*)titleString{
    self = [super init];
    if (self) {
        title = titleString;
        [self initView];
    }
    return self;
}

- (id)initWithReply:(UIColor*)color{
    self = [super init];
    if (self) {
        replyType=YES;
        replyColor = color;
        [self initView];
    }
    return self;
}

- (id)initWithImg:(NSString*)titleString{
    self = [super init];
    if (self) {
        title = titleString;
        _addImages = YES;
        [self initView];
    }
    return self;
}
-(void)initView{
    
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
    [self setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    self.alpha=0;
    
    backCoverView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    [backCoverView setBackgroundColor:[UIColor blackColor]];
    backCoverView.alpha = 0;
    [backCoverView addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchDown];
    [self addSubview:backCoverView];
    
    
    
    if(replyType){//评价类型
        
        sendViewHeight = 46;
        sendView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, sendViewHeight)];
        [sendView setBackgroundColor:replyColor];
        [self addSubview:sendView];
        
        hpTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 7, SCREENWIDTH-20, sendViewHeight-6)];
        hpTextView.delegate = self;
        [sendView addSubview:hpTextView];
        
        hpTextView.minNumberOfLines = 1;
        hpTextView.maxNumberOfLines = 5;
        hpTextView.tintColor = replyColor;
        hpTextView.layer.cornerRadius = 4;
        [hpTextView.layer setMasksToBounds:YES];
        hpTextView.backgroundColor = [UIColor whiteColor];
        hpTextView.returnKeyType = UIReturnKeySend;//返回键的类型
        [hpTextView setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
        hpTextView.textColor = [UIColor blackColor];
        hpTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        hpTextView.enablesReturnKeyAutomatically = YES;
        
        
        placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(hpTextView.x+7,0, SCREENWIDTH, sendViewHeight)];
        placeHolderLabel.textAlignment = NSTextAlignmentLeft;
        placeHolderLabel.numberOfLines = 1;
        placeHolderLabel.textColor = [UIColor lightGrayColor];
        placeHolderLabel.font = [UIFont fontWithName:textDefaultFont size:14];
        [sendView addSubview:placeHolderLabel];
        
    }else{
        
        float viewHeight = 146;
        if(_addImages){
            viewHeight = 181;
        }
        
        changeView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, viewHeight)];
        [changeView setBackgroundColor:EMPTYGRAY];
        changeView.alpha = 0.9;
        [self addSubview:changeView];
        
        CGFloat tHeight = 50;
        
        hpTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(15, tHeight, SCREENWIDTH-30, 0)];
        hpTextView.delegate = self;
        
        hpTextView.layer.cornerRadius = 2;
        hpTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        hpTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(3, 0, 3, 0);
        [changeView addSubview:hpTextView];
        
        hpTextView.minNumberOfLines = 3;
        hpTextView.maxNumberOfLines = 4;
        hpTextView.tintColor = MAINCOLOR;
        [hpTextView setKeyboardType:UIKeyboardTypeDefault];
        hpTextView.returnKeyType = UIReturnKeyDone;//返回键的类型
        hpTextView.layer.borderColor = [LINECOLOR CGColor];
        hpTextView.layer.borderWidth = 0.5f;
        [hpTextView setFont:[UIFont fontWithName:textDefaultFont size:14]] ;
        hpTextView.textColor = [UIColor getColor:@"212121"];
        hpTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        hpTextView.enablesReturnKeyAutomatically = YES;
        
        
        hpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, tHeight)];
        hpLabel.textAlignment = NSTextAlignmentCenter;
        hpLabel.textColor = MAINCOLOR;
        hpLabel.text = title;
        hpLabel.font =[UIFont fontWithName:textDefaultBoldFont size:15];
        [changeView addSubview:hpLabel];
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, tHeight)];
        
        [cancelBtn setBackgroundColor:[UIColor clearColor]];
        [cancelBtn setTitle:@"清空" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont fontWithName:textDefaultBoldFont size:13];
        [cancelBtn setTitleColor:[UIColor getColor:@"cccccc"] forState:UIControlStateHighlighted];
        [cancelBtn setTitleColor:[UIColor getColor:@"cccccc"] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(clearContent) forControlEvents:UIControlEventTouchUpInside];
        
        [changeView addSubview:cancelBtn];
        
        
        
        UIButton *sBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH-60, 0, 60, tHeight)];
        
        [sBtn setBackgroundColor:[UIColor clearColor]];
        [sBtn setTitle:@"完成" forState:UIControlStateNormal];
        sBtn.titleLabel.font = [UIFont fontWithName:textDefaultBoldFont size:13];
        [sBtn setTitleColor:MAINCOLOR forState:UIControlStateHighlighted];
        [sBtn setTitleColor:MAINCOLOR forState:UIControlStateNormal];
        [sBtn addTarget:self action:@selector(saveEva) forControlEvents:UIControlEventTouchUpInside];
        
        [changeView addSubview:sBtn];
     
        [changeView addSubview:[APPUtils get_line:0 y:changeView.height-0.5 width:SCREENWIDTH]];
        
        //图片类型
        if(_addImages){
            imagesDatalist = [[NSMutableArray alloc] init];
            addBtnDic = [[NSMutableDictionary alloc] init];
            [addBtnDic setObject:@"add" forKey:@"type"];
            [imagesDatalist addObject:addBtnDic];
            [self loadImage];
        }
    }
    
    
    //修改全局光标颜色
    [[UITextField appearance] setTintColor:MAINCOLOR];
    
}


-(void)setTitle:(NSString*)string{
    hpLabel.text = string;
}

-(void)setKeyType:(NSInteger)type{
    [hpTextView setKeyboardType:type];
}

-(void)setMaxLength:(NSInteger)max{
    maxLength = max;
}

-(void)registerKeyboard{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

//显示自己
-(void)showMyself{
    self.alpha=1;
    [self becomeFirstResponder];
    [self registerKeyboard];
    [hpTextView becomeFirstResponder];
    
    [[[UIApplication sharedApplication].delegate window] bringSubviewToFront:self];
}

//普通显示
-(void)show:(NSString*)defaultString{

    if(defaultString!=nil && defaultString.length>0){
        hpTextView.text = defaultString;
    }

    [self showMyself];
}



//回复类型显示
-(void)showWithPlace:(NSString*)placeString{
    
    placeHolderLabel.text = placeString;
    
    [self showMyself];
    
}
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];


    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame;
    if(replyType){
        containerFrame = sendView.frame;
    }else{
        containerFrame = changeView.frame;
    }
    containerFrame.origin.y = SCREENHEIGHT - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    
    CGRect containerMenuFrame = changeView.frame;
    containerMenuFrame.origin.y = SCREENHEIGHT;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        if(replyType){
            sendView.frame = containerFrame;
        }else{
            changeView.frame = containerFrame;
        }
       
        backCoverView.alpha=0.6;
        
    }];
   
    menuState = NO;
    
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    if(!menuState){
        
        // get a rect for the textView frame
        CGRect containerFrame;
        if(replyType){
            containerFrame = sendView.frame;
        }else{
            containerFrame = changeView.frame;
        }
        
        containerFrame.origin.y = SCREENHEIGHT;
        
        [UIView animateWithDuration:0.3 delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                backCoverView.alpha=0;
                                if(replyType){
                                    sendView.frame = containerFrame;
                                }else{
                                    changeView.frame = containerFrame;
                                }
                                
                            }
                         completion:^(BOOL finished){
                             self.alpha=0;
                             maxLength = 0;
                             
                             [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
                             [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
                         }];
    }
    
}


//textview变高后  sendview跟着变
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    
    if(replyType){
        diff = (growingTextView.height - height);
        CGRect r = sendView.frame;
        r.size.height -= diff;
        r.origin.y += diff;
        sendView.frame = r;
    }
}

-(BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView{
    
    [self cut];
    
    return YES;
}

-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{

    if(growingTextView.text.length>0){
        
        if(replyType){
            placeHolderLabel.alpha=0;
        }
  
    }else{
        if(replyType){
            placeHolderLabel.alpha=1;
        }
        
    }
}



-(void)cut{
    if(maxLength>0 && hpTextView.text.length>maxLength){
        
        NSString *readword = hpTextView.text;
        readword = [readword substringWithRange:NSMakeRange(0,maxLength)];
        hpTextView.text = readword;
        readword = nil;
    }
}

-(void)clearContent{
    hpTextView.text = @"";
    
    if(replyType){
        placeHolderLabel.alpha=1;
    }
    
    if(_addImages){
        if(imagesList!=nil&&[imagesList count]>0){
            for(int i=0;i<[imagesList count];i++){
                UIView *tempView = [imagesList objectAtIndex:i];
                [tempView removeFromSuperview];
                tempView = nil;
            }
        }
        
        for(NSMutableDictionary *imgDic in imagesDatalist){
            @try {
                if(![[imgDic objectForKey:@"type"]isEqualToString:@"add"]){
                    //删除文件
                    NSFileManager* fileManager=[NSFileManager defaultManager];
                    NSString *deletePath = [[MainViewController sharedMain].avatarPaths stringByAppendingPathComponent:[imgDic objectForKey:@"fileName"]];
                    BOOL blHave=[fileManager fileExistsAtPath:deletePath];
                    if (blHave) {
                        [fileManager removeItemAtPath:deletePath error:nil];
                    }
                    deletePath = nil;
                    fileManager = nil;
                }
                
            } @catch (NSException *exception) {}
        }
        
        [imagesDatalist removeAllObjects];
        imagesList = [[NSMutableArray alloc] init];
        imgFull = NO;
        [imagesDatalist addObject:addBtnDic];
        [self loadImage];
    }
}



//判断输入的字是否是回车，即按下return
-(BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        
        [self saveEva];
        
        return NO;
    }
    
    [self cut];
    
    
    return YES;
}

//保存修改
-(void)saveEva{
    NSString *tString = @"";
    if(hpLabel!=nil){
        tString = hpLabel.text;
    }
    if(_addImages){
         self.setImgback([imagesDatalist mutableCopy], hpTextView.text);
    }else{
        self.setback(tString, hpTextView.text);
    }
   
    [self hide];
    [self clearContent];
    tString = nil;
}


-(void)hide{
 
    [hpTextView resignFirstResponder];
    
}

//摧毁
-(void)destroy{
    [self removeFromSuperview];
}


//----------图片类型

//加载图片
-(void)loadImage{
    
    if(imagesList!=nil&&[imagesList count]>0){
        for(int i=0;i<[imagesList count];i++){
            UIView *tempView = [imagesList objectAtIndex:i];
            [tempView removeFromSuperview];
            tempView = nil;
        }
    }
    
    imagesList = [[NSMutableArray alloc] init];
    
    
    NSInteger xx=0;
    
    CGFloat picViewWidth = 65;//最多三张
    CGFloat imageWidth=picViewWidth*0.85;
    
    for(int i=0;i<[imagesDatalist count];i++){
        
        NSMutableDictionary *imgDic = [imagesDatalist objectAtIndex:i];
        
        UIView *imgView = [[UIView alloc] initWithFrame:CGRectMake(10+xx*picViewWidth, changeView.height-picViewWidth, picViewWidth, picViewWidth)];
        [changeView addSubview:imgView];
        
        //显示图片
        UIImageView *showImg = [[UIImageView alloc] initWithFrame:CGRectMake((picViewWidth-imageWidth)/2, (picViewWidth-imageWidth)/2, imageWidth, imageWidth)];
        [showImg.layer setMasksToBounds:YES];
        [showImg setContentMode:UIViewContentModeScaleAspectFill];
        [imgView addSubview:showImg];
        
        
        
        
        NSString*imgType = [imgDic objectForKey:@"type"];
        if([imgType isEqualToString:@"add"]){
            //点击事件
            MyBtnControl *clickControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, picViewWidth, picViewWidth)];
            
            clickControl.back_highlight = YES;
            clickControl.clickBackBlock = ^(){
                [hpTextView resignFirstResponder];
                [self selectPics];
            };
            showImg.layer.borderWidth=0.5;
            showImg.layer.borderColor=[LINECOLOR2 CGColor];
            
            [clickControl addImage:[UIImage imageNamed:@"add_image.png"] frame:CGRectMake((picViewWidth-imageWidth*0.5)/2, (picViewWidth-imageWidth*0.5)/2, imageWidth*0.5, imageWidth*0.5)];
            

            [imgView addSubview:clickControl];
            clickControl = nil;
        }else{
            
            [showImg setImage:[UIImage imageWithContentsOfFile:[[MainViewController sharedMain].avatarPaths stringByAppendingPathComponent:[imgDic objectForKey:@"fileName"]]]];
            
            
            
            //删除
          
            MyBtnControl *dControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(picViewWidth-35, 0, 35, 35)];
            [imgView addSubview:dControl];
            dControl.clickBackBlock = ^(){
                
                @try {
                    
                    [imagesDatalist removeObjectAtIndex:i];
                    
                    //删除文件
                    NSFileManager* fileManager=[NSFileManager defaultManager];
                    NSString *deletePath = [[MainViewController sharedMain].avatarPaths stringByAppendingPathComponent:[imgDic objectForKey:@"fileName"]];
                    BOOL blHave=[fileManager fileExistsAtPath:deletePath];
                    if (blHave) {
                        [fileManager removeItemAtPath:deletePath error:nil];
                    }
                    deletePath = nil;
                    fileManager = nil;
                    
                    
                    if(imgFull){
                        imgFull = NO;
                        [imagesDatalist addObject:addBtnDic];
                    }
                    [self loadImage];
                    
                } @catch (NSException *exception) {}
            };
            
            [dControl addImage:[UIImage imageNamed:@"delete_user_red.png"] frame:CGRectMake(dControl.width-17, 0, 17, 17)];
        
            dControl = nil;
        }
        
        
        
        [imagesList addObject:imgView];
        
        imgView = nil;
        showImg = nil;
        imgType = nil;
        imgDic = nil;
        
        xx++;
        
    }
}

//添加评论照片
-(void)selectPics{
    CCActionSheet *actionSheet = [[CCActionSheet alloc] initWithTitle:@"添加图片" clickedAtIndex:^(NSInteger index) {
        
        if(index == 0){
            [self openCamera];
        }else if(index == 1){
            [self openPictures];
        }else if(index == 2){
            [self showMyself];
        }
        
    } cancelButtonTitle:@"取消" otherButtonTitles:@"拍照", @"从相册中选取",nil];
    
    [actionSheet show];
    actionSheet = nil;
}

//打开照相机

-(void)openCamera{
    
    if(makeAvatar == nil){
        makeAvatar = [[MakeAvatarTool alloc]init];
        makeAvatar.not_avatar = YES;
        __weak typeof(self) weakSelf = self;
        makeAvatar.callBackBlock = ^(UIImage *avatar_img){
            [weakSelf saveImg:avatar_img];
        };
    }
    
    [makeAvatar takePhoto];
}

//保存拍照图片
-(void)saveImg:(UIImage*)portraitImg{
    

    //处理图片
    NSData*savedata = [APPUtils getZipImage:portraitImg];
    
    NSString *fileName = [NSString stringWithFormat:@"%@%@%@",@"quan_",[APPUtils getUniquenessString],@".jpg"];
    NSString *savePath = [[MainViewController sharedMain].avatarPaths stringByAppendingPathComponent:fileName];
    [savedata writeToFile: savePath atomically:YES];
    
    portraitImg = nil;
    
    NSMutableDictionary *imgDic = [[NSMutableDictionary alloc] init];
    [imgDic setObject:@"img" forKey:@"type"];
    [imgDic setObject:fileName forKey:@"fileName"];
    
    [imagesDatalist removeLastObject];
    [imagesDatalist addObject:imgDic];
    
    fileName = nil;
    savedata = nil;
    savePath = nil;
    
    if([imagesDatalist count]<_maxImgs){
        [imagesDatalist addObject:addBtnDic];
    }else{
        imgFull=YES;
    }
    [self loadImage];
   [self showMyself];
    
}


//打开相册
-(void)openPictures{
    
    LocalPhotoViewController *pick=[[LocalPhotoViewController alloc] init];
    pick.selectPhotoDelegate=self;
    pick.isQuan = YES;
    pick.mostCount = 4-[imagesDatalist count];
    [[MainViewController sharedMain].navigationController pushViewController:pick animated:YES];
    pick = nil;
}


-(void)getSelectedPhoto:(NSMutableArray *)photos{
    
    
    NSLog(@"共选择%lu张照片,%@",(unsigned long)[photos count],photos);
    
    [imagesDatalist removeLastObject];
    
    if([photos count]>0){
        NSMutableArray *sendArray = [[NSMutableArray alloc] init];
        
        for(int i=0;i<[photos count];i++){
            
            ALAsset *asset= [photos objectAtIndex:i];
            ALAssetRepresentation* representation = [asset defaultRepresentation];
            
            UIImage *tempImg = [UIImage imageWithCGImage:representation.fullScreenImage];//全屏图 推荐使用
            
            
            NSString*tail=asset.defaultRepresentation.url.absoluteString;//获取文件后缀
            tail = [tail substringWithRange:NSMakeRange(tail.length-3,3)];
            tail = [tail lowercaseString];
            
            NSString *fileName = [NSString stringWithFormat:@"quan_%@.%@",[APPUtils getUniquenessString],tail];
            
            NSData*savedata = UIImageJPEGRepresentation(tempImg,0.7);
            NSString *savePath = [[MainViewController sharedMain].avatarPaths stringByAppendingPathComponent:fileName];
            [savedata writeToFile: savePath atomically:YES];
            
            NSMutableDictionary *imgDic = [[NSMutableDictionary alloc] init];
            [imgDic setObject:@"img" forKey:@"type"];
            [imgDic setObject:fileName forKey:@"fileName"];
            
            
            [imagesDatalist addObject:imgDic];
            
            savedata = nil;
            tempImg = nil;
            fileName = nil;
            savePath = nil;
            representation = nil;
            asset = nil;
        }
        
        if([imagesDatalist count]<_maxImgs){
            [imagesDatalist addObject:addBtnDic];
        }else{
            imgFull=YES;
        }
        [self loadImage];
        
        [ShowWaiting hideWaiting];
        
        sendArray = nil;
       [self showMyself];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
