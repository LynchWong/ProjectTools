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


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        posWidth = SCREENWIDTH*0.65;
        posheight = posWidth*0.56;
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
        
        if(conversation.auth_type==1){
            UIImageView *auth = [[UIImageView alloc] initWithFrame:CGRectMake(asynImgView.width+asynImgView.x-13, asynImgView.y+asynImgView.height-14, 18, 18)];
            [auth setImage:[UIImage imageNamed:@"auth_paopao.png"]];
            [self addSubview:auth];
            auth = nil;
        }
        
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
        
        }else if([msg.type isEqualToString:@"pic"]){
            
            
            UIImageView *sendImageview = [[UIImageView alloc] initWithFrame:CGRectMake(62, 14, maxPicHeight*_msg.imageDirection, maxPicHeight)];
          
            if(sendImageview.height < 42){
                sendImageview.height = 42;
            }
            sendImageview.tag = 233;
            [sendImageview.layer setMasksToBounds:YES];//圆角不被图片盖住
            [sendImageview setBackgroundColor:[UIColor whiteColor]];
            sendImageview.layer.cornerRadius = 5;
            [sendImageview setContentMode:UIViewContentModeScaleAspectFill];
            [sendImageview sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@",[AFN_util getIpadd],_msg.thumb_url]] placeholderImage:[UIImage imageNamed:@"gray_square.png"]];
            
            [self addSubview:sendImageview];
        

            //尺寸
            UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(sendImageview.x, sendImageview.height+sendImageview.y, sendImageview.width, 15)];
            
            sizeLabel.textColor = [UIColor lightGrayColor];
            sizeLabel.font = [UIFont fontWithName:textDefaultFont size:10];
            sizeLabel.textAlignment = NSTextAlignmentRight;
            
     
            sizeLabel.text = [APPUtils getFilesizeUnit:msg.filesize];
            
            [self addSubview:sizeLabel];
            sizeLabel = nil;
            
            
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
            float recoTime = msg.voice_length/1000;
            
            
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
            _voiceActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _voiceActivityIndicator.center = CGPointMake(bubbleImageView.x+bubbleImageView.width+addX, bubbleImageView.y+(bubbleImageView.height/2));
            [_voiceActivityIndicator startAnimating];
            _voiceActivityIndicator.alpha=0;
             [self addSubview:_voiceActivityIndicator];
            
            if(_msg.downloading==1){
                _voiceActivityIndicator.alpha=1;
            }else{
                _voiceActivityIndicator.alpha=0;
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
            
  
            UIImageView *snapImageview = [[UIImageView alloc] initWithFrame:CGRectMake(62, 14, posWidth, posheight)];
            [snapImageview.layer setMasksToBounds:YES];//圆角不被图片盖住
            snapImageview.layer.cornerRadius = 6;
            [snapImageview setContentMode:UIViewContentModeScaleAspectFill];
            [self addSubview:snapImageview];
            
    
            [snapImageview sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@",[AFN_util getIpadd],msg.thumb_url]] placeholderImage:[UIImage imageNamed:@"defaultmap.png"]];
            
            
            
            UIImageView *annoImageview = [[UIImageView alloc]initWithFrame:CGRectMake((snapImageview.width-25)/2, (snapImageview.height-25)/2-25/2, 25, 25)];
            [annoImageview setImage:[UIImage imageNamed:@"begin_anno.png"]];
            [snapImageview addSubview:annoImageview];
            annoImageview = nil;
            
            
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
            
            UIView *broadCastView = [[UIView alloc] initWithFrame:CGRectMake(60, 14, SCREENWIDTH*0.73, msg.content_height+30)];
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
        }
        
        asynImgView = nil;
        
        
        
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
        
        

        headImageView = nil;
        headControl = nil;
        
        
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
            
        }else if([msg.type isEqualToString:@"pic"]){
        
            
            UIImageView *sendImageview = [[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH-59-maxPicHeight*msg.imageDirection,14, maxPicHeight*msg.imageDirection, maxPicHeight)];
            [sendImageview setBackgroundColor:[UIColor whiteColor]];
            
        
            if(sendImageview.height < 42){
                CGRect containerFrame = sendImageview.frame;
                sendImageview.height = 42;
            }
            sendImageview.tag = 233;
            [sendImageview.layer setMasksToBounds:YES];//圆角不被图片盖住
            sendImageview.layer.cornerRadius = 5;
            [sendImageview setContentMode:UIViewContentModeScaleAspectFill];
           
            [self addSubview:sendImageview];
            
           
            //本地图片
            UIImage *sendImage = [UIImage imageWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",msg.fileName]]];
            
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
                
                UIActivityIndicatorView *picActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                picActivityIndicator.center = CGPointMake(coverView.width/2-2, coverView.height/2-7);
                [picActivityIndicator startAnimating];
                [coverView addSubview:picActivityIndicator];
                picActivityIndicator = nil;
                
                progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, coverView.height/2+5, coverView.width-2, 20)];
                progressLabel.backgroundColor = [UIColor clearColor];
                progressLabel.font = [UIFont fontWithName:textDefaultFont size:14];
                progressLabel.numberOfLines = 0;
                progressLabel.textColor = [UIColor whiteColor];
                progressLabel.textAlignment = NSTextAlignmentCenter;
                
                
                [coverView addSubview:progressLabel];
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
            float recoTime = msg.voice_length/1000;
            
            
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
                activityIndicator.center = CGPointMake(bubbleImageView.x-cutNumber, bubbleImageView.height/2+bubbleImageView.y);
             
                
            }else if(msg.sendStatus ==2){
                
                
                resendView = [[UIView alloc] initWithFrame:CGRectMake(bubbleImageView.x-40-20, bubbleImageView.y, 40, bubbleImageView.height)];
       
            }
            
            
            bubble = nil;
            bubbleImageView = nil;
            timeLabel = nil;
            voiceControl = nil;
        }else if([msg.type isEqualToString:@"pos"]){
            
            
            UIImageView *sendImageview = [[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH-59-posWidth, 14, posWidth, posheight)];
            [sendImageview.layer setMasksToBounds:YES];//圆角不被图片盖住
            sendImageview.layer.cornerRadius = 6;
            [sendImageview setContentMode:UIViewContentModeScaleAspectFill];
            [self addSubview:sendImageview];
            
            
            
            UIImage *sendImage = [UIImage imageWithContentsOfFile:[[[MainViewController sharedMain] conversationPaths] stringByAppendingPathComponent:msg.fileName]];
            
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
         
            
            
        }else if(_msg.sendStatus==3){//发送回调
            
            if(![_msg.type isEqualToString:@"pic"]){//菊花显示
                [activityIndicator startAnimating];
                [self addSubview:activityIndicator];
                activityIndicator = nil;
            }
            
            
            
           
            NSDictionary *tempdic = [[APPUtils getUserDefault] objectForKey: _msg.msg_id];
            
            @try {
                if(tempdic==nil||[tempdic isEqual:[NSNull null]]){//检测没发送就开始发送
                    
                    [APPUtils userDefaultsSet :[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"id",nil] forKey:_msg.msg_id];
                    
                
                    __weak typeof(self)weakself = self;
                    
                    if(progressLabel!=nil&&[_msg.type isEqualToString:@"pic"]){//更新上传进度
                        
                        _msg.progressResult = ^(NSString *progress){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                 weakself.progressLabel.text = progress;
                            });
                           
                        };
                        
                    }
                    
                    
                    [_msg setSendOverBlock:^(OneMsgEntity *send_msg){
                        _msg = send_msg;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                             weakself.callBackBlock(@"update");
                        });
                     
                    }];
                    
                     [_msg sendMsg];
                    
                }
            } @catch (NSException *exception) {}
            tempdic = nil;
        
        }

        
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
    PersonPageViewController *pView = [[PersonPageViewController alloc]initWithUid:[NSString stringWithFormat:@"%d",(int)uid]];
    [[MainViewController sharedMain].navigationController pushViewController:pView animated:YES];
    pView = nil;
}



//cell点击事件
- (void)cell_action{
    
    [APPUtils setMethod:@"MsgCellTableViewCell -> cell_action"];
    
    @try {
        
        if([_msg.type isEqualToString:@"pic"]){//打开图片
            
            self.clickCallBackBlock(nil,@"open_pic");
            
        }else if([_msg.type isEqualToString:@"voice"]){//播放语音
            
            [self checkVoice];
            
        }else if([_msg.type isEqualToString:@"pos"]){//查看位置
            
            self.clickCallBackBlock(nil,@"open_position");
            
        }else if([_msg.type isEqualToString:@"broadcast"]){//广播
            
            if(_msg.orderId>0){
                self.clickCallBackBlock(nil,@"open_broadcast");
            }
        }
        
    } @catch (NSException *exception) {
        
    }

}

//检查语音
-(void)checkVoice{
    _unreadRedView.alpha=0;
    

    __weak typeof(self) weakSelf = self;
    _msg.downloadCallback = ^(NSInteger downloading){//下载刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            if(downloading==1){
                weakSelf.voiceActivityIndicator.alpha=1;
            }else{
                weakSelf.voiceActivityIndicator.alpha=0;
            }
        });

    };
    
    [_msg checkVoice];
   
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
