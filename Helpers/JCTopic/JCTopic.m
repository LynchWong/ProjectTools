//
//  JCTopic.m
//  PSCollectionViewDemo
//
//  Created by jc on 14-1-7.
//
//

#import "JCTopic.h"
#import "MainViewController.h"
@implementation JCTopic
@synthesize JCdelegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        [self setSelf];
    }
    return self;
}
-(void)setSelf{
    self.pagingEnabled = YES;
    self.scrollEnabled = YES;
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.backgroundColor = [UIColor whiteColor];

}


-(void)upDate{
    
    @try {
        
        int i = 0;
        for (id obj in self.pics) {
            pic= Nil;
            pic = [UIButton buttonWithType:UIButtonTypeCustom];
            pic.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [pic setFrame:CGRectMake(i*self.width,0, self.width, self.height)];
            UIImageView * tempImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, pic.width, pic.height)];
            tempImage.contentMode = UIViewContentModeScaleAspectFill;
            [tempImage setClipsToBounds:YES];
            [pic addSubview:tempImage];
            if ([[obj objectForKey:@"isLoc"]boolValue]) {
                [tempImage setImage:[obj objectForKey:@"pic"]];
            }else{
                
                [tempImage sd_setImageWithURL:[NSURL URLWithString:[obj objectForKey:@"pic"]] placeholderImage:(UIImage*)[obj objectForKey:@"placeholderImage"]];
                
            }
            
            [pic setBackgroundColor:[UIColor whiteColor]];
            pic.tag = i;
            [pic addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:pic];
            
            
            NSString*tString =[obj objectForKey:@"title"];
            if(tString!=nil && tString.length>0){
                
                UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(i*self.width, self.height-25, self.width, 25)];
                [self addSubview:titleView];
                
                UIView *under = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, titleView.width, titleView.height)];
                [under setBackgroundColor:[UIColor blackColor]];
                under.alpha = 0.7;
                [titleView addSubview:under];
                under = nil;
                
                NSString *isVideo = [obj objectForKey:@"isVideo"];
                
                UILabel * titleLabel = [[UILabel alloc]init];
                if(isVideo!=nil && isVideo.length>0){
                    [titleLabel setFrame:CGRectMake(22, 0, titleView.width-70,titleView.height)];
                }else{
                    [titleLabel setFrame:CGRectMake(5, 0, titleView.width-55,titleView.height)];
                }
                [titleLabel setText:tString];
                [titleLabel setTextColor:[UIColor whiteColor]];
                [titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:11]];
                [titleView addSubview:titleLabel];
                
                
                if(isVideo!=nil && isVideo.length>0){
                    UIImageView *videoImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, (titleView.height-13)/2, 13, 13)];
                    videoImage.layer.cornerRadius = videoImage.height/2;
                    videoImage.layer.borderColor = [[UIColor whiteColor]CGColor];
                    videoImage.layer.borderWidth = 1.0;
                    videoImage.contentMode = UIViewContentModeScaleAspectFit;
                    [videoImage setImage:[UIImage imageNamed:@"video_little.png"]];
                    [titleView addSubview:videoImage];
                }
            }
            
    
            i ++;
        }
        
      
        
        [self setContentSize:CGSizeMake(self.width*[self.pics count], self.height)];
        [self setContentOffset:CGPointMake(0, 0) animated:NO];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!scrollTimer && [self.pics count]>1){
                [JCdelegate currentPage:0 total:[self.pics count]-2];
                scrollTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(scrollTopic) userInfo:nil repeats:YES];
            }
        });
        
    }
    @catch (NSException *exception) {
        
    }
    
    
    
    
}
-(void)click:(UIButton*)sender{
    [JCdelegate didClick:[NSString stringWithFormat:@"%d",(int)[sender tag]]];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    currentPage = scrollView.contentOffset.x/self.width;
    [JCdelegate currentPage:currentPage total:[self.pics count]];
    scrollTopicFlag = currentPage;
}
-(void)scrollTopic{
    
    if (scrollTopicFlag >= [self.pics count]-1) {
        scrollTopicFlag = 0;
    }else {
        scrollTopicFlag++;
    }
    
    [self setContentOffset:CGPointMake(self.width*scrollTopicFlag, 0) animated:YES];
    
    
}


-(void)releaseTimer{
    
    @try {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (scrollTimer) {
                [scrollTimer invalidate];
                scrollTimer = nil;
                
            }
        });
        
        
    }
    @catch (NSException *exception) {
        
    }
    
    
}

@end
