//
//  MsgselfTableViewself.m
//  zpp
//
//  Created by Chuck on 2017/4/21.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "MsgCellTableViewCell.h"
#import "MainViewController.h"
@implementation MsgCellTableViewCell
@synthesize conversation;
@synthesize index;
@synthesize maxPicHeight;
@synthesize maxPicWidth;
@synthesize progressLabel;
@synthesize progressBar;


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        fromX = 62;
        fromY = 14;
        mineX = SCREENWIDTH-59;
        posWidth = SCREENWIDTH*0.65;
        posheight = posWidth*0.56;
        
        fileheight = posWidth * 0.4;
        oneLineHeight = [APPUtils getOnelineHeight:[UIFont fontWithName:textDefaultFont size:13]];
        [self.layer setMasksToBounds:YES];
    }
    return self;
}


-(void)setMsg:(OneMsgEntity *)msg{
    
    
    [APPUtils setMethod:@"MsgCellTableViewCell -> setMsg"];
    
    MyBtnControl *tableUnder = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH)];
    [self addSubview:tableUnder];
    tableUnder.clickBackBlock = ^(){
         [[NSNotificationCenter defaultCenter] postNotificationName:@"closeMsgInput" object:nil userInfo:nil];
    };
    tableUnder = nil;
    
    
    _msg = msg;
    
    if([msg.type isEqualToString:@"time"]){
        
        
        UIView *timeView ;
        if(msg.sendStatus == 90){
            timeView = [[UIView alloc]initWithFrame:CGRectMake(SCREENWIDTH/2-45, 60/2-13, 90, 26)];
        }else{
            timeView = [[UIView alloc]initWithFrame:CGRectMake(SCREENWIDTH/2-30, 60/2-13, 60, 26)];
        }
        
        [timeView setBackgroundColor:LINECOLOR2];
        timeView.layer.cornerRadius = 3;
        
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, timeView.width, timeView.height)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont fontWithName:textDefaultFont size:12];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        
        timeLabel.text = msg.content;
        
        [timeView addSubview:timeLabel];
        [self addSubview:timeView];
        
        
        
        msg = nil;
        timeView = nil;
        timeLabel = nil;
        
        self.transform = CGAffineTransformMakeScale (1,-1);//再倒转cell
        
        return;
        
    }
    
    // sendStatus
    // 0 --> 收件
    // 1 --> 发件
    // 2 --> 草稿
    // 3 --> 发送中...
    
    
    if (msg.sendStatus ==0){
        
        UIImageView *asynImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 13, 42, 42)];
      
        [asynImgView sd_setImageWithURL:[NSURL URLWithString:msg.avatar] placeholderImage:[UIImage imageNamed:@"defaultHead.png"]];
        [asynImgView.layer setCornerRadius:(asynImgView.height/2)];
        [asynImgView.layer setMasksToBounds:YES];//圆角不被盖住
        [asynImgView setContentMode:UIViewContentModeScaleAspectFill];
        [asynImgView setClipsToBounds:YES];//减掉超出部分
        asynImgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        asynImgView.layer.borderWidth = 0.2f;
        asynImgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:asynImgView];
        
 
        
        MyBtnControl*headControl = [[MyBtnControl alloc] initWithFrame:asynImgView.frame];
        [headControl setShareImage:asynImgView];
        [self addSubview:headControl];
        
        headControl.clickBackBlock = ^(){
            [self openPerson:msg.msg_uid];
        };
    
        
        if([msg.type isEqualToString:@"text"]){
    
            MyBtnControl *textControl = [self bubbleView:msg from:NO withPosition:58];
            textControl.no_single_click = YES;
            
            [textControl addLongclick];
            __weak __typeof(MyBtnControl*)weakcCntrol = textControl;
            textControl.longClickBackBlock = ^(){
                self.clickCallBackBlock(weakcCntrol,@"copy_delete");
            };
            
            
            [self addSubview:textControl];
            textControl = nil;
        
        }else if([msg.type isEqualToString:@"pic"]  ||  [msg.type isEqualToString:@"tuya"] || [msg.type isEqualToString:@"write"]){
            
            float imgWidth = maxPicHeight*_msg.imageDirection;
            if([msg.type isEqualToString:@"write"]){
                imgWidth = SCREENWIDTH*0.7;
            }else if(imgWidth>maxPicWidth){
                imgWidth = maxPicWidth;
            }
            
            UIImageView *sendImageview = [[UIImageView alloc] initWithFrame:CGRectMake(fromX, fromY, imgWidth, maxPicHeight)];
            sendImageview.tag = 233;
            if(sendImageview.height < asynImgView.height){
                sendImageview.height = asynImgView.height;
            }
         
            [sendImageview.layer setMasksToBounds:YES];//圆角不被图片盖住
            [sendImageview setBackgroundColor:[UIColor whiteColor]];
            sendImageview.layer.cornerRadius = 5;
            if([msg.type isEqualToString:@"write"]){
                [sendImageview setContentMode:UIViewContentModeLeft|UIViewContentModeTop];
            }else{
                [sendImageview setContentMode:UIViewContentModeScaleAspectFill];
            }
            [self addSubview:sendImageview];
            
            UIImage *thumb = [UIImage imageWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:_msg.thumb_url]];
            if(thumb == nil){
                thumb = [UIImage imageNamed:@"gray_square.png"];
            }
            [sendImageview setImage:thumb];
            thumb = nil;
        

            
            if(![msg.type isEqualToString:@"write"]){
                
                //尺寸
                UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(sendImageview.x, sendImageview.height+sendImageview.y, sendImageview.width, 15)];
                
                sizeLabel.textColor = [UIColor lightGrayColor];
                sizeLabel.font = [UIFont fontWithName:textDefaultFont size:10];
                sizeLabel.textAlignment = NSTextAlignmentRight;
                
                
                sizeLabel.text = [APPUtils getFilesizeUnit:msg.filesize];
                
                [self addSubview:sizeLabel];
                sizeLabel = nil;
                
                if(msg.downloading!=2){
                    
                    UIView *coverView = [[UIView alloc] initWithFrame:sendImageview.frame];
                    coverView.alpha = 0.7;
                    [coverView setBackgroundColor:[UIColor darkGrayColor]];
                    coverView.layer.cornerRadius = 5;
                    [self addSubview:coverView];
                    
                    if(msg.downloading==1){//下载中
                        
                        UIActivityIndicatorView *picActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                        picActivityIndicator.center = CGPointMake(coverView.width/2+5, coverView.height/2-7);
                        [picActivityIndicator startAnimating];
                        [coverView addSubview:picActivityIndicator];
                        picActivityIndicator = nil;
                        
                        progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, coverView.height/2+5, coverView.width, 20)];
                        progressLabel.backgroundColor = [UIColor clearColor];
                        progressLabel.font = [UIFont fontWithName:textDefaultBoldFont size:14];
                        progressLabel.text = [NSString stringWithFormat:@"%.0f%%",_msg.progress];
                        progressLabel.textColor = [UIColor whiteColor];
                        progressLabel.textAlignment = NSTextAlignmentCenter;
                        
                        
                        [coverView addSubview:progressLabel];
                        coverView = nil;
                        
                    }else{
                        //未下载
                        UIImageView *dImg = [[UIImageView alloc] initWithFrame:CGRectMake((sendImageview.width-30)/2+5, (sendImageview.height-30)/2, 30, 30)];
                        [dImg setImage:[UIImage imageNamed:@"downImg.png"]];
                        [coverView addSubview:dImg];
                        dImg = nil;
                        
                    }
                }
                
            }
            
            
            UIImage *quequeImage = [UIImage imageNamed:@"ReceiveTextEmpty.png"];
            UIImageView *quequeImageview =  [[UIImageView alloc] initWithFrame:sendImageview.frame];
            
            quequeImage = [quequeImage stretchableImageWithLeftCapWidth:(quequeImage.size.width)/2 topCapHeight:floorf(quequeImage.size.height)*0.7];
            
            [quequeImageview setImage:quequeImage];
            [self addSubview:quequeImageview];
            
            
            MyBtnControl *imageControl = [[MyBtnControl alloc] initWithFrame:sendImageview.frame];
            imageControl.shareImage = sendImageview;
            [self addSubview:imageControl];
            
            
            
            imageControl.clickBackBlock = ^(){
                [self cell_action];
            };
            
            
           [imageControl addLongclick];
            __weak __typeof(MyBtnControl*)weakcCntrol = imageControl;
            imageControl.longClickBackBlock = ^(){
                self.clickCallBackBlock(weakcCntrol,@"copy_delete");
            };
        

            imageControl = nil;
            
            quequeImage = nil;
            quequeImageview = nil;
            sendImageview = nil;
        
            
        }else if([msg.type isEqualToString:@"voice"]){
            
            CGFloat minWidth = SCREENWIDTH*0.2;
            CGFloat allWidth = SCREENWIDTH*0.65- SCREENWIDTH*0.2;//最长0.65 最短0.2
            CGFloat addone = allWidth/60;
            float recoTime = msg.voice_length;
            
            
            UIImage *bubble = [UIImage imageNamed:@"receive_txt.png"];
            UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:floorf(bubble.size.width/2) topCapHeight:floorf(bubble.size.height*0.7)]];
            bubbleImageView.frame = CGRectMake(58, 15.0f, addone*recoTime+minWidth, oneLineHeight+17);
            [self addSubview:bubbleImageView];
            
            _bolang = [[UIImageView alloc] initWithFrame:CGRectMake(bubbleImageView.x+13, bubbleImageView.y+(bubbleImageView.height-17)/2, 17, 17)];
            [_bolang setImage:[UIImage imageNamed:@"white_bolang3.png"]];
            [self addSubview:_bolang];
          
            
            
            MyBtnControl *voiceControl = [[MyBtnControl alloc] initWithFrame:bubbleImageView.frame];
            voiceControl.tag = index;
            voiceControl.shareImage = bubbleImageView;
            [self addSubview:voiceControl];
            
            
            voiceControl.clickBackBlock = ^(){
                [self cell_action];
            };
            
            [voiceControl addLongclick];
            __weak __typeof(MyBtnControl*)weakcCntrol = voiceControl;
            voiceControl.longClickBackBlock = ^(){
                self.clickCallBackBlock(weakcCntrol,@"copy_delete");
            };
            
            
            UILabel *timeLabel =  [[UILabel alloc] initWithFrame:CGRectMake(bubbleImageView.x+bubbleImageView.width+6, bubbleImageView.y, 30, voiceControl.height)];
            timeLabel.textColor = [UIColor lightGrayColor];
            timeLabel.font = [UIFont fontWithName:textDefaultBoldFont size:13];
            timeLabel.textAlignment = NSTextAlignmentLeft;
            timeLabel.text = [NSString stringWithFormat:@"%.0f%@",fabs(recoTime),@"\""];
            [self addSubview:timeLabel];
            
            
            //下载菊花
            float addX = 30;
            if(recoTime>9){
                addX = 40;
            }
       
            
            if(_msg.downloading==0){//未读红点
              
                float addX = 21;
                if(recoTime>9){
                    addX = 28;
                }
                _unreadRedView = [[UIImageView alloc] initWithFrame:CGRectMake(bubbleImageView.x+bubbleImageView.width+addX, bubbleImageView.y
                                                                                     +(bubbleImageView.height-5)/2, 5, 5)];
                [_unreadRedView setBackgroundColor:MAINRED];
                [_unreadRedView.layer setCornerRadius:(_unreadRedView.height/2)];
                
                [self addSubview:_unreadRedView];
              
                
            }
            
            
            bubble = nil;
            bubbleImageView = nil;
            timeLabel = nil;
            
        }else if([msg.type isEqualToString:@"pos"]){
            
  
            UIImageView *snapImageview = [[UIImageView alloc] initWithFrame:CGRectMake(fromX, fromY, posWidth, posheight)];
            [snapImageview.layer setMasksToBounds:YES];//圆角不被图片盖住
            snapImageview.layer.cornerRadius = 6;
            [snapImageview setContentMode:UIViewContentModeScaleAspectFill];
            [self addSubview:snapImageview];
            
            
            UIImage *sendImage = [UIImage imageWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:_msg.big_url]];
            
            if(sendImage == nil){
                sendImage = [UIImage imageNamed:@"defaultmap.png"];
            }else{
                UIImageView *annoImageview = [[UIImageView alloc]initWithFrame:CGRectMake((snapImageview.width-25)/2, (snapImageview.height-25)/2-25/2, 25, 25)];
                [annoImageview setImage:[UIImage imageNamed:@"begin_anno.png"]];
                [snapImageview addSubview:annoImageview];
                annoImageview = nil;
            }
            
            [snapImageview setImage:sendImage];
            
    
            
            UIView *addressView  = [[UIView alloc] initWithFrame:CGRectMake(0, snapImageview.height-20, snapImageview.width, 20)];
            addressView.alpha = 0.8;
            addressView.backgroundColor = [UIColor blackColor];
            
            UILabel *addressText = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, addressView.width-30, addressView.height)];
            
            addressText.font = [UIFont fontWithName:textDefaultFont size:11];
            addressText.numberOfLines = 1;
            addressText.textAlignment = NSTextAlignmentCenter;
            addressText.textColor = [UIColor whiteColor];
            addressText.text = _msg.addressString.length>0?_msg.addressString:@"未知位置";
            [addressView addSubview: addressText];
            addressText = nil;
            [snapImageview addSubview: addressView];
            addressView = nil;
            
            
            
            UIImage *quequeImage = [UIImage imageNamed:@"ReceiveTextEmpty.png"];
            UIImageView *quequeImageview =  [[UIImageView alloc] initWithFrame:snapImageview.frame];
            
            quequeImage = [quequeImage stretchableImageWithLeftCapWidth:(quequeImage.size.width)/2 topCapHeight:floorf(quequeImage.size.height)*0.7];
            
            [quequeImageview setImage:quequeImage];
            [self addSubview:quequeImageview];
            
            
            MyBtnControl *imageControl = [[MyBtnControl alloc] initWithFrame:snapImageview.frame];
            imageControl.tag = index;
            imageControl.shareImage = snapImageview;
            [self addSubview:imageControl];
            
            imageControl.clickBackBlock = ^(){
                [self cell_action];
                
            };
            
            [imageControl addLongclick];
            __weak __typeof(MyBtnControl*)weakcCntrol = imageControl;
            imageControl.longClickBackBlock = ^(){
                self.clickCallBackBlock(weakcCntrol,@"copy_delete");
            };
            
            imageControl = nil;
            
            quequeImage = nil;
            quequeImageview = nil;
            
            snapImageview = nil;
            
            
        }else if([msg.type isEqualToString:@"broadcast"]){
            
            UIView *broadCastView = [[UIView alloc] initWithFrame:CGRectMake(60, fromY, SCREENWIDTH*0.73, msg.content_height+30)];
            [broadCastView setBackgroundColor:[UIColor clearColor]];
            [self addSubview:broadCastView];
            
            UIImage *quequeImage = [UIImage imageNamed:@"receive_txt.png"];
            UIImageView *quequeImageview =  [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, broadCastView.width, broadCastView.height)];
            quequeImageview.userInteractionEnabled = YES;
            quequeImage = [quequeImage stretchableImageWithLeftCapWidth:floorf(quequeImage.size.width)/2 topCapHeight:floorf(quequeImage.size.height)*0.7];
            
            [quequeImageview setImage:quequeImage];
            [broadCastView addSubview:quequeImageview];
            quequeImage = nil;
            
            
            UIImageView *brokenLine = [[UIImageView alloc]initWithFrame:CGRectMake(broadCastView.width-42-broadCastView.height/2, broadCastView.height/2, broadCastView.height-1, 1)];
            
            UIGraphicsBeginImageContext(brokenLine.frame.size);   //开始画线
            [brokenLine.image drawInRect:CGRectMake(0, 0, brokenLine.width, brokenLine.height)];
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
            
            CGFloat lengths[] = {4,2}; //虚实线长度
            CGContextRef line = UIGraphicsGetCurrentContext();
            CGContextSetStrokeColorWithColor(line, [UIColor whiteColor].CGColor);
            
            CGContextSetLineDash(line, 0, lengths, 1);  //画虚线
            CGContextMoveToPoint(line, 0.0, 1);    //开始画线
            CGContextAddLineToPoint(line, SCREENWIDTH, 1);
            CGContextStrokePath(line);
            brokenLine.image = UIGraphicsGetImageFromCurrentImageContext();
            [broadCastView addSubview:brokenLine];
            
            
            brokenLine.transform=CGAffineTransformMakeRotation(M_PI/2);
            line = nil;
            brokenLine = nil;
            
            
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, broadCastView.width-60,  broadCastView.height-20)];
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.font = [UIFont fontWithName:textDefaultFont size:13];
            contentLabel.textColor = [UIColor whiteColor];
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentLabel.numberOfLines=0;
            contentLabel.text = msg.content;
            [broadCastView addSubview:contentLabel];
            contentLabel = nil;
            
            
            UILabel *checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(broadCastView.width-42, 0, 42, quequeImageview.height)];
            checkLabel.backgroundColor = [UIColor clearColor];
            checkLabel.font = [UIFont fontWithName:textDefaultBoldFont size:11];
            checkLabel.textColor = [UIColor whiteColor];
            checkLabel.textAlignment = NSTextAlignmentCenter;
            checkLabel.text = @"查看";
            [broadCastView addSubview:checkLabel];
            checkLabel = nil;
            
            
            MyBtnControl *broadControl = [[MyBtnControl alloc] initWithFrame:broadCastView.frame];
            broadControl.tag = index;
            broadControl.shareImage = quequeImageview;
            [self addSubview:broadControl];
            
            broadControl.clickBackBlock = ^(){
                [self cell_action];
                
            };
            
            [broadControl addLongclick];
            __weak __typeof(MyBtnControl*)weakcCntrol = broadControl;
            broadControl.longClickBackBlock = ^(){
                self.clickCallBackBlock(weakcCntrol,@"copy_delete");
            };
            broadControl = nil;
            
            
            
            broadCastView = nil;
            quequeImageview = nil;
            
        }else{//文件
            
            UIView *fileView = [[UIView alloc] initWithFrame:CGRectMake(fromX, fromY, posWidth, fileheight)];
            [fileView.layer setMasksToBounds:YES];//圆角不被图片盖住
            fileView.layer.cornerRadius = 6;
            [fileView setBackgroundColor:[UIColor whiteColor]];
            [self addSubview:fileView];
            
            
    
            UIImageView *fileImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 65, fileheight-16)];
            [fileImg.layer setMasksToBounds:YES];//圆角不被图片盖住
            fileImg.layer.cornerRadius = 6;
            [fileImg setContentMode:UIViewContentModeScaleAspectFill];
            if(msg.thumb_url!=nil && msg.thumb_url.length>0){
                [fileImg setImage:[UIImage imageWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:_msg.thumb_url]]];
            }else{
                [fileImg setImage:[APPUtils getFileIcon:_msg.fileTail]];
            }
            
            [fileView addSubview:fileImg];
            
            
            //标题
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(fileImg.x*1.5+fileImg.width, fileImg.y, posWidth-(fileImg.x*2+fileImg.width),  40)];
            nameLabel.font = [UIFont fontWithName:textDefaultFont size:13];
            nameLabel.textColor = TEXTGRAY;
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.numberOfLines=2;
            nameLabel.text = msg.fileName;
            [fileView addSubview:nameLabel];
            
            
            
            UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.x, fileheight-25, 50,  20)];
            sizeLabel.font = [UIFont fontWithName:textDefaultFont size:10];
            sizeLabel.textColor = [UIColor lightGrayColor];
            sizeLabel.textAlignment = NSTextAlignmentLeft;
            sizeLabel.text = [APPUtils getFilesizeUnit:msg.filesize];
            [fileView addSubview:sizeLabel];
            sizeLabel = nil;
            nameLabel = nil;
            fileImg = nil;
            
    
            if(msg.downloading==1){//下载中
            
                progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(fileView.x+fileView.width-30, fileView.y+fileView.height, 30, 15)];
                progressLabel.backgroundColor = [UIColor clearColor];
                progressLabel.font = [UIFont fontWithName:textDefaultBoldFont size:10];
                progressLabel.text = [NSString stringWithFormat:@"%.0f%%",_msg.progress];
                progressLabel.textColor = [UIColor lightGrayColor];
                progressLabel.textAlignment = NSTextAlignmentCenter;
                [self addSubview:progressLabel];
               
                _underbar = [[UIView alloc] initWithFrame:CGRectMake(fileView.x+9, fileView.y+fileView.height+7, fileView.width-progressLabel.width-15, 3)];
                [_underbar setBackgroundColor:LINECOLOR];
                [self addSubview:_underbar];
                
                progressBarWidth = _underbar.width;
                
                progressBar = [[UIView alloc] initWithFrame:CGRectMake(_underbar.x, _underbar.y, 0, _underbar.height)];
                [progressBar setBackgroundColor:MAINCOLOR];
                [self addSubview:progressBar];
                
           
                
            }else if(msg.downloading==0){
                //未下载
                
                UIView *downV = [[UIView alloc] initWithFrame:CGRectMake(fileView.width-25, fileView.height-25, 50, 50)];
                downV.layer.cornerRadius = downV.width/2;
                [downV setBackgroundColor:MAINCOLOR];
                [fileView addSubview:downV];
                
                UIImageView *dImg = [[UIImageView alloc] initWithFrame:CGRectMake((downV.width/2-13)/2+2, (downV.height/2-13)/2+2, 13, 13)];
                [dImg setImage:[UIImage imageNamed:@"downImg.png"]];
                [downV addSubview:dImg];
                dImg = nil;
                downV = nil;
                
            }else{
                progressLabel.alpha=0;
                progressBar.alpha=0;
                _underbar.alpha=0;
                
            }
        
            
            UIImage *quequeImage = [UIImage imageNamed:@"ReceiveTextEmpty.png"];
            UIImageView *quequeImageview =  [[UIImageView alloc] initWithFrame:fileView.frame];
            
            quequeImage = [quequeImage stretchableImageWithLeftCapWidth:(quequeImage.size.width)/2 topCapHeight:floorf(quequeImage.size.height)*0.7];
            
            [quequeImageview setImage:quequeImage];
            [self addSubview:quequeImageview];
            
            
            MyBtnControl *imageControl = [[MyBtnControl alloc] initWithFrame:fileView.frame];
            imageControl.tag = index;
            imageControl.shareView = fileView;
            [self addSubview:imageControl];
            
            imageControl.clickBackBlock = ^(){
                [self cell_action];
                
            };
            
            [imageControl addLongclick];
            __weak __typeof(MyBtnControl*)weakcCntrol = imageControl;
            imageControl.longClickBackBlock = ^(){
                self.clickCallBackBlock(weakcCntrol,@"copy_delete");
            };
            
            imageControl = nil;
            
            quequeImage = nil;
            quequeImageview = nil;
            
            fileView = nil;

            
        }
        
        asynImgView = nil;
        
    
            //下载文件监听
        __weak typeof(self) weakSelf = self;
        _msg.downloadCallback = ^(NSInteger downloading){//下载刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(downloading == 3){//刚下载的文件不打开
                     weakSelf.msg.downloading = 2;
                }else{
                     weakSelf.msg.downloading = downloading;
                }
               
                weakSelf.callBackBlock(@"update");
                
                //下载成功
                if(downloading == 2 || downloading == 3){
                    if([msg.type isEqualToString:@"pic"]  ||  [msg.type isEqualToString:@"tuya"] || [msg.type isEqualToString:@"write"]){
                    
                         weakSelf.clickCallBackBlock(nil,@"open_pic");
                        
                    }else{
                        if(downloading == 2){
                         weakSelf.clickCallBackBlock(nil,@"open_file");
                        }
                        
                    }
                }
            });
            
        };
        
        
        
        //进度
        _msg.progressResult = ^(float progress){
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.msg.progress = progress;
                 weakSelf.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",progress];//图片下载进度
                
                if(weakSelf.progressBar!=nil){
                    [UIView animateWithDuration:0.1 animations:^{
                        weakSelf.progressBar.width = progressBarWidth*(progress/100);
                    }];
                    
                }
                
            });
        };
        
    }else{
       
        
        UIActivityIndicatorView *activityIndicator;//菊花
        UIView *resendView;//重发
        
         //我的头像
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH-52, 13, 42, 42)];
        [headImageView sd_setImageWithURL:[NSURL URLWithString:_myAvatarUrl] placeholderImage:[UIImage imageNamed:@"defaultHead.png"]];
        [headImageView.layer setCornerRadius:(headImageView.height/2)];
        [headImageView.layer setMasksToBounds:YES];//圆角不被盖住
        [headImageView setContentMode:UIViewContentModeScaleAspectFill];
        [headImageView setClipsToBounds:YES];//减掉超出部分
        headImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        headImageView.layer.borderWidth = 0.2f;
        headImageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:headImageView];
        
        MyBtnControl*headControl = [[MyBtnControl alloc] initWithFrame:headImageView.frame];
        headControl.btn_num=1;
        headControl.shareImage = headImageView;
        [self addSubview:headControl];
        
        headControl.clickBackBlock = ^(){
            [self openPerson:msg.msg_uid];
        };
        
        

       
        
        
        if([msg.type isEqualToString:@"text"]){
            
            
            MyBtnControl *bubbleView = [self bubbleView:msg from:YES withPosition:63];
            bubbleView.tag = index;
            bubbleView.no_single_click = YES;
            [self addSubview:bubbleView];
            
            //长按
            [bubbleView addLongclick];
            __weak __typeof(MyBtnControl*)weakcCntrol = bubbleView;
            bubbleView.longClickBackBlock = ^(){
                self.clickCallBackBlock(weakcCntrol,@"copy_delete");
            };
           
            
            if(msg.sendStatus == 3){
                //文本发送
                activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator.center = CGPointMake(bubbleView.x-18, bubbleView.y+(bubbleView.height/2));
                
                
            }else if(msg.sendStatus == 2){
                //草稿
                resendView = [[UIView alloc] initWithFrame:CGRectMake(bubbleView.x-40, bubbleView.y, 40, bubbleView.height)];
                
            }
            
           
            bubbleView = nil;
            
        }else if([msg.type isEqualToString:@"pic"]||  [msg.type isEqualToString:@"tuya"] || [msg.type isEqualToString:@"write"]){
        
            
            float imgWidth = maxPicHeight*_msg.imageDirection;
            if([msg.type isEqualToString:@"write"]){
                imgWidth = SCREENWIDTH*0.7;
            }else if(imgWidth>maxPicWidth){
                imgWidth = maxPicWidth;
            }
            
            UIImageView *sendImageview = [[UIImageView alloc]initWithFrame:CGRectMake(mineX-imgWidth,fromY, imgWidth, maxPicHeight)];
            sendImageview.tag = 233;
            [sendImageview setBackgroundColor:[UIColor whiteColor]];
            
        
            if(sendImageview.height < headImageView.height){//控制最小高度
                if(sendImageview.height < headImageView.height){
                    sendImageview.height = headImageView.height;
                }
            }
       
            [sendImageview.layer setMasksToBounds:YES];//圆角不被图片盖住
            sendImageview.layer.cornerRadius = 5;
            if([msg.type isEqualToString:@"write"]){
                [sendImageview setContentMode:UIViewContentModeLeft|UIViewContentModeTop];
            }else{
                [sendImageview setContentMode:UIViewContentModeScaleAspectFill];
            }
            
           
            [self addSubview:sendImageview];
            
           
            //本地图片
            UIImage *sendImage = [UIImage imageWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:_msg.thumb_url]];
            
            if(sendImage == nil){
                sendImage = [UIImage imageNamed:@"gray_square.png"];
            }
            
            [sendImageview setImage:sendImage];
            sendImage = nil;
            
            if(msg.sendStatus==3){
                
                UIView *coverView = [[UIView alloc] initWithFrame:sendImageview.frame];
                coverView.alpha = 0.7;
                [coverView setBackgroundColor:[UIColor blackColor]];
                coverView.layer.cornerRadius = 5;
                [self addSubview:coverView];
                
                float juhuaY = coverView.height/2;
                if([msg.type isEqualToString:@"pic"]||[msg.type isEqualToString:@"tuya"]){
                    progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, coverView.height/2+5, coverView.width-2, 20)];
                    progressLabel.backgroundColor = [UIColor clearColor];
                    progressLabel.font = [UIFont fontWithName:textDefaultBoldFont size:14];
                    progressLabel.text = [NSString stringWithFormat:@"%.0f%%",_msg.progress];
                    progressLabel.textColor = [UIColor whiteColor];
                    progressLabel.textAlignment = NSTextAlignmentCenter;
                    
                    [coverView addSubview:progressLabel];
                    
                    juhuaY = coverView.height/2-7;
                }
                
                
                UIActivityIndicatorView *picActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                picActivityIndicator.center = CGPointMake(coverView.width/2-2, juhuaY);
                [picActivityIndicator startAnimating];
                [coverView addSubview:picActivityIndicator];
                picActivityIndicator = nil;
                
                
                
                coverView = nil;
                
                
            }else if(msg.sendStatus==2){//发送失败
                
                resendView = [[UIView alloc] initWithFrame:CGRectMake(sendImageview.x-50, sendImageview.y+(sendImageview.height-50)/2, 50, 50)];
     
            }

            
            
            UIImage *quequeImage = [UIImage imageNamed:@"SendTextEmpty.png"];
            UIImageView *quequeImageview =  [[UIImageView alloc] initWithFrame:sendImageview.frame];
            quequeImage = [quequeImage stretchableImageWithLeftCapWidth:(quequeImage.size.width)/2 topCapHeight:floorf(quequeImage.size.height)*0.7];
            [quequeImageview setImage:quequeImage];
            [self addSubview:quequeImageview];
            
            
            
            MyBtnControl *imageControl = [[MyBtnControl alloc] initWithFrame:sendImageview.frame];
            imageControl.tag = index;
            imageControl.shareImage = sendImageview;
            [self addSubview:imageControl];
            
            imageControl.clickBackBlock = ^(){
                [self cell_action];
                
            };
            
            
            [imageControl addLongclick];
            __weak __typeof(MyBtnControl*)weakcCntrol = imageControl;
            imageControl.longClickBackBlock = ^(){
                self.clickCallBackBlock(weakcCntrol,@"copy_delete");
            };
            
            imageControl = nil;
            quequeImage = nil;
            quequeImageview = nil;
            sendImageview = nil;
            
            
            
            
        }else if([msg.type isEqualToString:@"voice"]){
            
            CGFloat minWidth = SCREENWIDTH*0.2;
            CGFloat allWidth = SCREENWIDTH*0.6- SCREENWIDTH*0.2;//最长0.65 最短0.2
            CGFloat addone = allWidth/60;
            float recoTime = msg.voice_length;
            
            
            UIImage *bubble = [UIImage imageNamed:@"send_txt.png"];
            UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:floorf(bubble.size.width/2) topCapHeight:floorf(bubble.size.height*0.7)]];
            bubbleImageView.frame = CGRectMake(SCREENWIDTH-60-(addone*recoTime+minWidth), 15.0f, addone*recoTime+minWidth, oneLineHeight+17);
            [self addSubview:bubbleImageView];
            bubble = nil;
            
            _bolang = [[UIImageView alloc] initWithFrame:CGRectMake(bubbleImageView.width+bubbleImageView.x-30, bubbleImageView.y+(bubbleImageView.height-17)/2, 17, 17)];
            [_bolang setImage:[UIImage imageNamed:@"gray_bolang3.png"]];
            [self addSubview:_bolang];
         
            
            MyBtnControl *voiceControl = [[MyBtnControl alloc] initWithFrame:bubbleImageView.frame];
            voiceControl.tag = index;
            voiceControl.shareImage = bubbleImageView;
            voiceControl.shareView = _bolang;
            [self addSubview:voiceControl];
           
            
            voiceControl.clickBackBlock = ^(){
                [self cell_action];
                
            };
            
            
            [voiceControl addLongclick];
            __weak __typeof(MyBtnControl*)weakcCntrol = voiceControl;
            voiceControl.longClickBackBlock = ^(){
                self.clickCallBackBlock(weakcCntrol,@"copy_delete");
            };
            
            
            //时长
            UILabel *timeLabel =  [[UILabel alloc] initWithFrame:CGRectMake(bubbleImageView.x-34, bubbleImageView.y, 30, voiceControl.height)];
            timeLabel.textColor = [UIColor lightGrayColor];
            timeLabel.font = [UIFont fontWithName:textDefaultBoldFont size:13];
            timeLabel.textAlignment = NSTextAlignmentRight;
            timeLabel.text = [NSString stringWithFormat:@"%.0f%@",fabs(recoTime),@"\""];
            [self addSubview:timeLabel];
            
            
            
            if(msg.sendStatus==3){
                activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                int cutNumber = 30;
                if(msg.filesize>9){
                    cutNumber = 40;
                }
                activityIndicator.center = CGPointMake(bubbleImageView.x-cutNumber-6, bubbleImageView.height/2+bubbleImageView.y);
             
                
            }else if(msg.sendStatus ==2){
                
                
                resendView = [[UIView alloc] initWithFrame:CGRectMake(bubbleImageView.x-40-20, bubbleImageView.y, 40, bubbleImageView.height)];
       
            }
            
            
            bubble = nil;
            bubbleImageView = nil;
            timeLabel = nil;
            voiceControl = nil;
        }else if([msg.type isEqualToString:@"pos"]){
            
            
            UIImageView *sendImageview = [[UIImageView alloc]initWithFrame:CGRectMake(mineX-posWidth, fromY, posWidth, posheight)];
            [sendImageview.layer setMasksToBounds:YES];//圆角不被图片盖住
            sendImageview.layer.cornerRadius = 6;
            [sendImageview setContentMode:UIViewContentModeScaleAspectFill];
            [self addSubview:sendImageview];
            
            
            
            UIImage *sendImage = [UIImage imageWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:msg.big_url]];
            
            if(sendImage == nil){
                sendImage = [UIImage imageNamed:@"defaultmap.png"];
            }else{
                UIImageView *annoImageview = [[UIImageView alloc]initWithFrame:CGRectMake((sendImageview.width-25)/2, (sendImageview.height-25)/2-25/2, 25, 25)];
                [annoImageview setImage:[UIImage imageNamed:@"begin_anno.png"]];
                [sendImageview addSubview:annoImageview];
                annoImageview = nil;
            }
            
            [sendImageview setImage:sendImage];
            
            
            UIView *addressView  = [[UIView alloc] initWithFrame:CGRectMake(0, sendImageview.height-20, sendImageview.width, 20)];
            addressView.alpha = 0.8;
            addressView.backgroundColor = [UIColor blackColor];
            
            UILabel *addressText = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, addressView.width-30, addressView.height)];
            
          
            addressText.backgroundColor = [UIColor clearColor];
            addressText.font = [UIFont fontWithName:textDefaultFont size:11];
            addressText.numberOfLines = 1;
            addressText.textAlignment = NSTextAlignmentCenter;
            addressText.textColor = [UIColor whiteColor];
            addressText.text = msg.addressString.length>0?msg.addressString:@"未知位置";
            [addressView addSubview: addressText];
            addressText = nil;
            [sendImageview addSubview: addressView];
            addressView = nil;
            
            
            
            UIImage *quequeImage = [UIImage imageNamed:@"SendTextEmpty.png"];
            UIImageView *quequeImageview =  [[UIImageView alloc] initWithFrame:sendImageview.frame];
            
            quequeImage = [quequeImage stretchableImageWithLeftCapWidth:(quequeImage.size.width)/2 topCapHeight:floorf(quequeImage.size.height)*0.7];
            
            [quequeImageview setImage:quequeImage];
            [self addSubview:quequeImageview];
            
            if(msg.sendStatus==3){
                
                activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator.center = CGPointMake(sendImageview.x-21, sendImageview.height/2+8);
    
            }else if(msg.sendStatus==2){
                
                resendView = [[UIView alloc] initWithFrame:CGRectMake(sendImageview.x-50, sendImageview.y+(sendImageview.height-50)/2, 50, 50)];
     
            }
            
            
            MyBtnControl *imageControl = [[MyBtnControl alloc] initWithFrame:sendImageview.frame];
            imageControl.tag = index;
            imageControl.shareImage = sendImageview;
            [self addSubview:imageControl];
            
            imageControl.clickBackBlock = ^(){
                [self cell_action];
                
            };
            
            
            [imageControl addLongclick];
            __weak __typeof(MyBtnControl*)weakcCntrol = imageControl;
            imageControl.longClickBackBlock = ^(){
                self.clickCallBackBlock(weakcCntrol,@"copy_delete");
            };
            
            imageControl = nil;
            
            sendImage = nil;
            sendImageview = nil;
            quequeImage = nil;
            quequeImageview = nil;
            
    
            sendImage = nil;
            sendImageview = nil;
            
        
        }else{//文件
        
           
            UIView *fileView = [[UIView alloc] initWithFrame:CGRectMake(mineX-posWidth, fromY, posWidth, fileheight)];
            [fileView.layer setMasksToBounds:YES];//圆角不被图片盖住
            fileView.layer.cornerRadius = 6;
            [fileView setBackgroundColor:[UIColor whiteColor]];
            [self addSubview:fileView];
            
            
            
            UIImageView *fileImg = [[UIImageView alloc] initWithFrame:CGRectMake(posWidth-75, 8, 65, fileheight-16)];
            [fileImg.layer setMasksToBounds:YES];//圆角不被图片盖住
            fileImg.layer.cornerRadius = 6;
            [fileImg setContentMode:UIViewContentModeScaleAspectFill];
            if(msg.thumb_url!=nil && msg.thumb_url.length>0){
                [fileImg setImage:[UIImage imageWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:_msg.thumb_url]]];
            }else{
                [fileImg setImage:[APPUtils getFileIcon:_msg.fileTail]];
            }
            [fileView addSubview:fileImg];
            
            
            //标题
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, fileImg.y, posWidth-(30+fileImg.width),  40)];
            nameLabel.font = [UIFont fontWithName:textDefaultFont size:13];
            nameLabel.textColor = TEXTGRAY;
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.numberOfLines=2;
            nameLabel.text = msg.fileName;
            [fileView addSubview:nameLabel];
            
            
            
            UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.x, fileheight-25, 150, 20)];
            sizeLabel.font = [UIFont fontWithName:textDefaultFont size:10];
            sizeLabel.textColor = [UIColor lightGrayColor];
            sizeLabel.textAlignment = NSTextAlignmentLeft;
            sizeLabel.text = [NSString stringWithFormat:@"%@  %@",[APPUtils getFilesizeUnit:msg.filesize],(msg.videocompressing?@"（正在压缩）":@"")];
            [fileView addSubview:sizeLabel];
            sizeLabel = nil;
            nameLabel = nil;
            fileImg = nil;
            
            
            
            UIImage *quequeImage = [UIImage imageNamed:@"SendTextEmpty.png"];
            UIImageView *quequeImageview =  [[UIImageView alloc] initWithFrame:fileView.frame];
            
            quequeImage = [quequeImage stretchableImageWithLeftCapWidth:(quequeImage.size.width)/2 topCapHeight:floorf(quequeImage.size.height)*0.7];
            
            [quequeImageview setImage:quequeImage];
            [self addSubview:quequeImageview];
            
            if(msg.sendStatus==3){
            
                progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(fileView.x+fileView.width-32, fileView.y+fileView.height, 30, 15)];
                progressLabel.backgroundColor = [UIColor clearColor];
                progressLabel.font = [UIFont fontWithName:textDefaultBoldFont size:10];
                progressLabel.text = [NSString stringWithFormat:@"%.0f%%",_msg.progress];
                progressLabel.textColor = [UIColor lightGrayColor];
                progressLabel.textAlignment = NSTextAlignmentCenter;
                [self addSubview:progressLabel];
                
                _underbar = [[UIView alloc] initWithFrame:CGRectMake(fileView.x+5, fileView.y+fileView.height+7, fileView.width-progressLabel.width-9, 3)];
                [_underbar setBackgroundColor:LINECOLOR];
                [self addSubview:_underbar];
                
                progressBarWidth = _underbar.width;
                
                progressBar = [[UIView alloc] initWithFrame:CGRectMake(_underbar.x, _underbar.y, 0, _underbar.height)];
                [progressBar setBackgroundColor:MAINCOLOR];
                [self addSubview:progressBar];
              
                
            }else if(msg.sendStatus==2){
                
                resendView = [[UIView alloc] initWithFrame:CGRectMake(fileView.x-50, fileView.y+(fileView.height-50)/2, 50, 50)];
                
            }else{
                progressLabel.alpha=0;
                progressBar.alpha=0;
                _underbar.alpha=0;
                resendView.alpha=0;
            }
        
            
            MyBtnControl *imageControl = [[MyBtnControl alloc] initWithFrame:fileView.frame];
            imageControl.tag = index;
            imageControl.shareView = fileView;
            [self addSubview:imageControl];
            
            imageControl.clickBackBlock = ^(){
                [self cell_action];
                
            };
            
            
            [imageControl addLongclick];
            __weak __typeof(MyBtnControl*)weakcCntrol = imageControl;
            imageControl.longClickBackBlock = ^(){
                self.clickCallBackBlock(weakcCntrol,@"copy_delete");
            };
            
            imageControl = nil;
            
            quequeImage = nil;
            quequeImageview = nil;

            
            fileView = nil;
            
        }

        
        
        //重发
        if(msg.sendStatus==2){
            [self addSubview:resendView];
            UIImageView *resendImageView = [[UIImageView alloc] initWithFrame:CGRectMake(resendView.width-25-5, (resendView.height-25)/2, 25, 25)];
            [resendImageView setImage:[UIImage imageNamed:@"resend.png"]];
            [resendView addSubview:resendImageView];
            
            MyBtnControl *resendControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, resendView.width, resendView.height)];
            resendControl.tag = index;
            resendControl.shareImage =resendImageView;
            [resendView addSubview:resendControl];
            
            resendControl.clickBackBlock = ^(){
                [self resendMsg];
            };
            
            resendImageView = nil;
            resendView = nil;
            resendControl = nil;
            
            resendImageView = nil;
            resendControl = nil;
         
            
            
        }else if(_msg.sendStatus==3){//发送中
            
            if([_msg.type isEqualToString:@"text"] || [_msg.type isEqualToString:@"voice"] || [_msg.type isEqualToString:@"pos"]){//菊花显示
                [activityIndicator startAnimating];
                [self addSubview:activityIndicator];
                activityIndicator = nil;
            }
            
            __weak typeof(self)weakself = self;
            
            //更新上传进度
            _msg.progressResult = ^(float progress){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakself.msg.progress = progress;
                    
                    weakself.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",progress];
                    
                    if(weakself.progressBar!=nil){
                        [UIView animateWithDuration:0.1 animations:^{
                            weakself.progressBar.width = progressBarWidth*(progress/100);
                        }];
                    
                    }
                });
                
            };
            
            
            [_msg setSendOverBlock:^(OneMsgEntity *send_msg){
                _msg = send_msg;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_msg.sendStatus==1 || (_msg.sendStatus==0 && _msg.downloading != 1)){
                        weakself.progressLabel.alpha=0;
                        weakself.progressBar.alpha=0;
                        weakself.underbar.alpha=0;
                    }
                    
                    
                    weakself.callBackBlock(@"update");
                });
                
            }];
            
            NSDictionary *tempdic = [[APPUtils getUserDefault] objectForKey: _msg.msg_id];//检查是否开始发送
            
            @try {
                if(tempdic==nil||[tempdic isEqual:[NSNull null]]){
                    
                    [APPUtils userDefaultsSet :[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"id",nil] forKey:_msg.msg_id];
                    
                     [_msg sendMsg];
                    
                }
                
            } @catch (NSException *exception) {}
            tempdic = nil;
       
        }
        
        headImageView = nil;
        headControl = nil;
    }
    
    
    
    //语音播放监听
    if([_msg.type isEqualToString:@"voice"]){
        
        __weak typeof(self) weakSelf = self;
        _msg.playingvoiceBlock = ^(NSInteger playingIndex){//播放语音刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(playingIndex==1){
                 
                    if(_msg.sendStatus==0){
                        [weakSelf.bolang setImage:[UIImage imageNamed:@"white_bolang1.png"]];
                    }else{
                        [weakSelf.bolang setImage:[UIImage imageNamed:@"gray_bolang1.png"]];
                    }
                    
                }else if(playingIndex==2){
                   
                    if(_msg.sendStatus==0){
                        [weakSelf.bolang setImage:[UIImage imageNamed:@"white_bolang2.png"]];
                    }else{
                        [weakSelf.bolang setImage:[UIImage imageNamed:@"gray_bolang2.png"]];
                    }
                    
                }else{
                
                    if(_msg.sendStatus==0){
                        [weakSelf.bolang setImage:[UIImage imageNamed:@"white_bolang3.png"]];
                    }else{
                        [weakSelf.bolang setImage:[UIImage imageNamed:@"gray_bolang3.png"]];
                    }
                }
                
            });
        };
        
        
        //刷新后会检测播放中
        if([MainViewController sharedMain].msgUtil.voice_playing && [[MainViewController sharedMain].msgUtil.nowPlayingMsgId isEqualToString:_msg.msg_id] && !_msg.imPlaying){
             _msg.imPlaying = YES;
            _msg.playingIndex = 1;
            [_msg playingShow];
            
        }
            
        
        
    }
    
    self.transform = CGAffineTransformMakeScale (1,-1);//再倒转cell
}

//泡泡文本
- (MyBtnControl *)bubbleView:(OneMsgEntity *)msg from:(BOOL)fromSelf withPosition:(int)position{
    

    //添加文本信息
    if(msg.content == nil || msg.content.length == 0){
        msg.content = @" ";
    }
    
    
    CGFloat realWidth = msg.textsize.width;
    CGFloat addY = 0;
    if(msg.textsize.height<=oneLineHeight){
        realWidth = msg.textsize.width+5;
        addY = 1;
    }else if(realWidth < 28){
        realWidth = 28;
    }
    
    
    UILabel *bubbleText;
    CGFloat addWidth = 0;
    if(msg.content.length == 1){
        addWidth = 5;
        bubbleText = [[UILabel alloc]initWithFrame:CGRectMake(fromSelf?15.0f:21.0f, 10.0f+addY, realWidth, msg.textsize.height)];
    }else{
        bubbleText = [[UILabel alloc]initWithFrame:CGRectMake(fromSelf?9.0f:16.0f, 10.0f+addY, realWidth, msg.textsize.height)];
    }
    
    bubbleText.textAlignment = NSTextAlignmentLeft;
    bubbleText.font = [UIFont fontWithName:textDefaultFont size:13];
    bubbleText.numberOfLines = 0;
    [bubbleText setTextColor:(fromSelf?TEXTGRAY:[UIColor whiteColor])];
    bubbleText.text = msg.content;
    bubbleText.lineBreakMode = NSLineBreakByWordWrapping;
    
    
    
    //背影图片
    UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"send_txt":@"receive_txt" ofType:@"png"]];
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, realWidth+25+addWidth, msg.textsize.height+20)];
    [bubbleImageView setImage:[bubble stretchableImageWithLeftCapWidth:floorf(bubble.size.width/2) topCapHeight:floorf(bubble.size.height*0.7)]];
    bubble = nil;

    
    
    
    MyBtnControl *returnView;
    if(fromSelf){
        returnView = [[MyBtnControl alloc] initWithFrame:CGRectMake(SCREENWIDTH-(realWidth+83+addWidth),15.0f, realWidth+25+addWidth, msg.textsize.height+20)];
    }else{
        returnView = [[MyBtnControl alloc] initWithFrame:CGRectMake(60, 15.0f, realWidth+25+addWidth, msg.textsize.height+20)];
    }
    
    returnView.backgroundColor = [UIColor clearColor];
    returnView.shareLabel = bubbleText;
    returnView.shareImage = bubbleImageView;
    

    
    [returnView addSubview:bubbleImageView];
    [returnView addSubview:bubbleText];
    
    bubbleText = nil;
    bubbleImageView = nil;
    
    return returnView;
}








//打开个人页
-(void)openPerson:(NSInteger)uid{
    
//    ContactDetailViewController *secondView = [[ContactDetailViewController alloc] initWithUser:user];
//    secondView.showBtn = NO;
//    [[MainViewController sharedMain].navigationController pushViewController:secondView animated:YES];
//    secondView = nil;
//    user = nil;

}



//cell点击事件
- (void)cell_action{
    
    [APPUtils setMethod:@"MsgCellTableViewCell -> cell_action"];
    
    @try {
        
        if([_msg.type isEqualToString:@"pic"]||[_msg.type isEqualToString:@"tuya"]||[_msg.type isEqualToString:@"write"]){//打开图片
            
            [self check_img];
           
            
        }else if([_msg.type isEqualToString:@"voice"]){//播放语音
            
            [self checkVoice];
            
        }else if([_msg.type isEqualToString:@"pos"]){//查看位置
            
            self.clickCallBackBlock(nil,@"open_position");
            
        }else if([_msg.type isEqualToString:@"broadcast"]){//广播
            
        }else{//文件
            
            [self check_file];
            
        }
        
    } @catch (NSException *exception) {
        
    }

}

//检查语音
-(void)checkVoice{
    _unreadRedView.alpha=0;
    [_msg playVoice];
}

//检查图片
-(void)check_img{
   
    if(_msg.sendStatus==0){//对方的
         [_msg check_file];
    }else{
      self.clickCallBackBlock(nil,@"open_pic");
    }
}


//检查文件
-(void)check_file{
    
    if(_msg.sendStatus==0){//对方的
        [_msg check_file];
    }else{
        self.clickCallBackBlock(nil,@"open_file");
    }
}


//重发
-(void)resendMsg{

    if(_msg.sendStatus == 2){
        _msg.sendStatus = 3;
        
        [APPUtils userDefaultsDelete:_msg.msg_id];
        self.callBackBlock(@"update");
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
