//
//  CitySelectView.m
//  zpp
//
//  Created by Chuck on 2017/4/27.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "CitySelectView.h"

@implementation CitySelectView
@synthesize relocationArea;

- (id)initCity:(BOOL)showAll{
    self = [super init];
    if (self) {
        allCitys = showAll;
        [self get_service_area];
    }
    return self;
}


//获取常用地区
-(void)get_service_area{
    
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.myncic.xsq.area",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        
        
        NSBundle *bundle = [NSBundle mainBundle];
        NSURL *plistURL = [bundle URLForResource:@"AppInfo" withExtension:@"plist"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
        NSString *cityString = [dictionary objectForKey:@"allcity"];
        NSString *hot_cityString = [dictionary objectForKey:@"hotcity"];
        dictionary= nil;
        bundle = nil;
        plistURL = nil;
        
        
        
        @try {
            
            //热门城市
            hotCityArray = [hot_cityString componentsSeparatedByString:@"、"];
            
       
            NSArray *citys = [APPUtils getArrByJson:cityString];
            
            
            
            //侧边栏拼音的collation
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            NSMutableArray *sortedSections = [[NSMutableArray alloc] initWithCapacity:[[collation sectionTitles] count]];
            
            for (NSUInteger i = 0; i < [[collation sectionTitles] count]; i++) {
                [sortedSections addObject:[NSMutableArray array]];
            }
            
            
            //将每个城市加入对应拼音组
            if(citys!=nil){
                for (NSArray *cityArr in citys) {
                    
                    @try {
                        
                        Area *area = [[Area alloc]init];
                        area.city = [cityArr objectAtIndex:0];
                        area.cityFirstWord = [cityArr objectAtIndex:1];
                        area.cityWords = [cityArr objectAtIndex:2];
                        area.cityAllWords = [cityArr objectAtIndex:3];
                        
                        NSInteger index = [collation sectionForObject:area.cityFirstWord collationStringSelector:@selector(description)];
                        
                        [[sortedSections objectAtIndex:index] addObject:area];
                        area = nil;
                    } @catch (NSException *exception) {
                        
                    }
                    
                }
            }
            
            citys = nil;
            serviceAreaArray = sortedSections;
            
            
            _cityLoadOver = YES;
            sortedSections = nil;
            collation = nil;
            cityString = nil;
            hot_cityString = nil;
            
            if(_readyOpenAreaView){
                _readyOpenAreaView = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ShowWaiting hideWaiting];
                    [self openCityView];
                });
                
            }
        
        } @catch (NSException *exception) {
        }
    });
}



-(void)openCityView{

    if(!_cityLoadOver){
         _readyOpenAreaView= YES;

        [ToastView showToast:@"城市数据加载中...."];
        
        return;
    }
    
    if(areaPickerView == nil){
        
        [self setFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT)];
        [[[UIApplication sharedApplication].delegate window] addSubview:self];
        self.alpha=0;
        
        
        areaPickerView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        [areaPickerView setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        [self addSubview:areaPickerView];
        
        
        //搜索area
        UIControl *closeAreaInputControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        [closeAreaInputControl addTarget:self action:@selector(closeAreaInput) forControlEvents:UIControlEventTouchDown];
        [areaPickerView addSubview:closeAreaInputControl];
        closeAreaInputControl = nil;
        
        
        UIImageView *searchMirror = [[UIImageView alloc] initWithFrame:CGRectMake(17, 70, 20, 20)];
        searchMirror.layer.shouldRasterize = YES;
        searchMirror.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        [searchMirror setImage:[UIImage imageNamed:@"search_area_mirror.png"]];
        [areaPickerView addSubview:searchMirror];
        
        
        searchAreaView  = [[UITextField alloc] initWithFrame:CGRectMake(17*2+searchMirror.width, searchMirror.y-10, SCREENWIDTH-(12*4+searchMirror.width), 40)];
        [searchAreaView setTextColor:TEXTGRAY];
        [searchAreaView setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
        [searchAreaView setKeyboardType:UIKeyboardTypeDefault];
        searchAreaView.placeholder = @"搜索城市名或拼音";
        searchAreaView.returnKeyType = UIReturnKeyDone;
        searchAreaView.textAlignment = NSTextAlignmentLeft;
        [searchAreaView setFont:[UIFont fontWithName:textDefaultBoldFont size:13]];
        searchAreaView.tag = 103;
        searchAreaView.delegate = self;
        [searchAreaView setBorderStyle:UITextBorderStyleNone];
        searchAreaView.returnKeyType = UIReturnKeyDone;
        [searchAreaView setClearButtonMode:UITextFieldViewModeAlways];
        searchAreaView.enablesReturnKeyAutomatically = YES;//无文字就灰色
        [areaPickerView addSubview:searchAreaView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkText) name:UITextFieldTextDidChangeNotification object:searchAreaView];
        
        UIView *searchUnderLine = [[UIView alloc] initWithFrame:CGRectMake(15, searchAreaView.y+searchAreaView.height-5, SCREENWIDTH-30, 1)];
        [searchUnderLine setBackgroundColor:MAINCOLOR];
        [areaPickerView addSubview:searchUnderLine];
        
        searchMirror = nil;
        searchUnderLine = nil;
        
        
        
        //gps定位
        UILabel *gpsAreaNotice = [[UILabel alloc] initWithFrame:CGRectMake(15, searchAreaView.y+searchAreaView.height+10, 100, 30)];
        gpsAreaNotice.textAlignment = NSTextAlignmentLeft;
        gpsAreaNotice.textColor = MAINCOLOR;
        gpsAreaNotice.text = @"定位城市";
        gpsAreaNotice.font = [UIFont fontWithName:textDefaultBoldFont size:13];
        [areaPickerView addSubview:gpsAreaNotice];
        
        CGFloat areaBtnWidth;
        if(LESSIP5){
            areaBtnWidth = 60;
        }else{
            areaBtnWidth = 70;
        }
        
        
        
        UIImageView *location_city_img = [[UIImageView alloc] initWithFrame:CGRectMake(gpsAreaNotice.x+55, gpsAreaNotice.y+(gpsAreaNotice.height-17)/2, 17, 17)];
        location_city_img.layer.shouldRasterize = YES;
        location_city_img.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        [location_city_img setImage:[UIImage imageNamed:@"location_city.png"]];
        [areaPickerView addSubview:location_city_img];
        location_city_img = nil;
        
        __weak typeof(self) weakSelf = self;
        
        
        //定位城市
        relocationArea = [[MyBtnControl alloc] initWithFrame:CGRectMake(15, gpsAreaNotice.y+gpsAreaNotice.height, areaBtnWidth, 30)];
        relocationArea.layer.cornerRadius = relocationArea.height/2;
        relocationArea.layer.shouldRasterize = YES;
        relocationArea.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        relocationArea.layer.borderColor = [MAINCOLOR CGColor];
        relocationArea.layer.borderWidth=0.7;
        [areaPickerView addSubview:relocationArea];
        relocationArea.clickBackBlock = ^(){
            [weakSelf selectGPSCity:YES];
        };
        
        [relocationArea addLabel:@"" color:MAINCOLOR font:[UIFont fontWithName:textDefaultFont size:13]];
        
    

        middleMargin = (SCREENWIDTH-relocationArea.x*3-areaBtnWidth*4)/3;//间隙
        
        if(allCitys){
            //全国
            all_area = [[MyBtnControl alloc] initWithFrame:CGRectMake(relocationArea.width+relocationArea.x+middleMargin, relocationArea.y, areaBtnWidth, relocationArea.height)];
            all_area.layer.cornerRadius = all_area.height/2;
            all_area.layer.shouldRasterize = YES;
            all_area.layer.rasterizationScale = [[UIScreen mainScreen] scale];
            all_area.layer.borderColor = [MAINCOLOR CGColor];
            all_area.layer.borderWidth=0.7;
            [areaPickerView addSubview:all_area];
            all_area.clickBackBlock = ^(){
                [weakSelf selectGPSCity:NO];
            };
            
            [all_area addLabel:@"全国" color:MAINCOLOR font:relocationArea.shareLabel.font];
        }
        
    
        gpsAreaNotice = nil;
        
        
        //城市列表
        UILabel *allAreaNotice = [[UILabel alloc] initWithFrame:CGRectMake(15, relocationArea.y+relocationArea.height+20, 100, 30)];
        allAreaNotice.textAlignment = NSTextAlignmentLeft;
        allAreaNotice.textColor = MAINCOLOR;
        allAreaNotice.text = @"城市列表";
        allAreaNotice.font = [UIFont fontWithName:textDefaultBoldFont size:13];
        [areaPickerView addSubview:allAreaNotice];
        
        //热门城市
        float hotCityArrayCount = [hotCityArray count];
        hotCityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, (ceilf(hotCityArrayCount/4))*relocationArea.height+(ceilf(hotCityArrayCount/4))*10)];
        
        
        
        //一排四个
        NSInteger xx=0;
        NSInteger yy=0;
        
        for(int i=0;i<[hotCityArray count];i++){
            if(xx>=4){
                yy++;
                xx=0;
            }
            
            MyBtnControl *hotCityBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(relocationArea.x+areaBtnWidth*xx+xx*middleMargin, yy*10+yy*relocationArea.height, areaBtnWidth, relocationArea.height)];
            hotCityBtn.layer.cornerRadius = hotCityBtn.height/2;
            hotCityBtn.layer.shouldRasterize = YES;
            hotCityBtn.layer.rasterizationScale = [[UIScreen mainScreen] scale];
            hotCityBtn.layer.borderColor = [MAINCOLOR CGColor];
            hotCityBtn.layer.borderWidth=0.7;
            hotCityBtn.tag = i;
            [hotCityView addSubview:hotCityBtn];
            hotCityBtn.clickBackBlock = ^(){
                [weakSelf selectHotCity:[hotCityArray objectAtIndex:i]];
            };
            
            [hotCityBtn addLabel:[hotCityArray objectAtIndex:i] color:MAINCOLOR font:[UIFont fontWithName:textDefaultFont size:13]];
           
            xx++;
        }
        
        areaTable = [[UITableView alloc] initWithFrame:CGRectMake(0, allAreaNotice.y+allAreaNotice.height, SCREENWIDTH, SCREENHEIGHT-allAreaNotice.height-allAreaNotice.y-60)];
        [areaPickerView addSubview:areaTable];
        areaTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //隐藏tableview多余行数的线条
        [areaTable setBounces:NO];
        [areaTable setBackgroundColor:[UIColor clearColor]];
        areaTable.tag = 102;
        areaTable.delegate = self;//调用delegate
        areaTable.dataSource=self;
        areaTable.separatorStyle = UITableViewCellSeparatorStyleNone; //去掉table分割
        areaTable.showsVerticalScrollIndicator = YES;
        areaTable.sectionIndexBackgroundColor = [UIColor clearColor];
        areaTable.sectionIndexColor = MAINCOLOR;
        
        areaTable.tableHeaderView = hotCityView;
        
        //关闭area
        UIImageView *closeImg = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-20)/2, SCREENHEIGHT-40, 20, 20)];
        [closeImg setImage:[UIImage imageNamed:@"close_view.png"]];
        [areaPickerView addSubview:closeImg];
        
        
        UIControl *closeAreaControl = [[UIControl alloc] initWithFrame:CGRectMake((SCREENWIDTH-80)/2, SCREENHEIGHT-50, 80, 50)];
        [closeAreaControl addTarget:self action:@selector(closePickerView) forControlEvents:UIControlEventTouchDown];
        [areaPickerView addSubview:closeAreaControl];
        closeImg = nil;
        
    }
    
    
    [self refresh_location_city];
    
    if(serviceAreaFliterArray!=nil){
        [serviceAreaFliterArray removeAllObjects];
    }
    searchAreaView.text = @"";
    [areaTable reloadData];
    
    
    [[[UIApplication sharedApplication].delegate window] bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
         self.alpha=1;
    }];
    

    
}


-(void)closeAreaInput{
    [searchAreaView resignFirstResponder];
}


//刷新定位城市
-(void)refresh_location_city{
    
   
    location_city = [[APPUtils getUserDefaults] stringForKey:@"location_city"];
    

    if(location_city!=nil&&location_city.length>0){
        relocationArea.shareLabel.text = location_city;
    }else{
        relocationArea.shareLabel.text = @"重新定位";
    }
    
    CGFloat areaBtnWidth;
    if(LESSIP5){
        areaBtnWidth = 60;
    }else{
        areaBtnWidth = 70;
    }
    
    //定位城市按钮框
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSLineBreakByWordWrapping;
    
    NSDictionary *attribute = @{NSFontAttributeName: relocationArea.shareLabel.font, NSParagraphStyleAttributeName: paragraph};
    
    CGSize areaSize = [relocationArea.shareLabel.text boundingRectWithSize:CGSizeMake(SCREENWIDTH, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    attribute = nil;
    paragraph = nil;
    if(areaSize.width>=areaBtnWidth){
        areaSize.width = areaSize.width+20;
    }else{
        areaSize.width = areaBtnWidth;
    }
    
    [relocationArea setFrame:CGRectMake(relocationArea.x, relocationArea.y, areaSize.width, relocationArea.height)];
    [relocationArea.shareLabel setFrame:CGRectMake(0, 0, relocationArea.width, relocationArea.height)];
    
    if(allCitys){
        [all_area setFrame:CGRectMake(relocationArea.width+relocationArea.x+middleMargin, relocationArea.y, areaBtnWidth, relocationArea.height)];
    }
    
    
    
}

//tableview开始滚动滑动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(searchAreaView!=nil){
        [self closeAreaInput];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([string isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        
        [textField resignFirstResponder];
        
        return NO;
    }
    
    return YES;
    
}


-(void)checkText{
    
    if(searchAreaView.text.length>0){
        
        if(searchAreaView.text.length>20){
            searchAreaView.text = [searchAreaView.text substringWithRange:NSMakeRange(0,20)];
        }else{
            serviceAreaFliterArray = [[NSMutableArray alloc] init];
            for(int i=0;i<[serviceAreaArray count];i++){
                NSMutableArray *tempArray = [serviceAreaArray objectAtIndex:i];
                if(tempArray == nil || [tempArray count] == 0){
                    tempArray = nil;
                    continue;
                }
                
                for(int j=0;j<[tempArray count];j++){
                    
                    Area *area = [tempArray objectAtIndex:j];
                    
                    if([area.city hasPrefix:searchAreaView.text]){
                        [serviceAreaFliterArray addObject:area];
                        continue;
                    }
                    
                    
                    if([area.cityWords hasPrefix:[searchAreaView.text uppercaseString]]){
                        [serviceAreaFliterArray addObject:area];
                        continue;
                    }
                    
                    
                    if([area.cityAllWords hasPrefix:[searchAreaView.text uppercaseString]]){
                        [serviceAreaFliterArray addObject:area];
                        continue;
                    }
                    
                    if([area.cityFirstWord hasPrefix:[searchAreaView.text uppercaseString]]){
                        [serviceAreaFliterArray addObject:area];
                        continue;
                    }
                    
                    
                    area = nil;
                    
                }
                
                
                tempArray = nil;
            }
        }
        
        if(areaTable.tableHeaderView!=nil){
            areaTable.tableHeaderView = nil;
        }
    }else{
        if(areaTable.tableHeaderView==nil){
            areaTable.tableHeaderView = hotCityView;
        }
    }
    
    
    [areaTable reloadData];
    
    
}




//显示tableview 的章节数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(searchAreaView.text.length>0){
        return 1;
    }else{
        return serviceAreaArray.count;
    }
    
}

//控制侧边栏的显示和隐藏
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    if (searchAreaView.text.length == 0) {
        //只显示有名字的拼音
        NSMutableArray *wordArray = [[NSMutableArray alloc]init];
        for(int i=0;i<[serviceAreaArray count];i++){
            @try {
                if([[serviceAreaArray objectAtIndex:i]count]>0){
                    [wordArray addObject:[[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles] objectAtIndex:i]];
                }
            } @catch (NSException *exception) {
                
            }
            
        }
        [wordArray addObject:[[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles] lastObject]];//#
        
        return [wordArray copy];
        //        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];显示全部字母
    } else {
        return nil;
    }
    
}

//点击右侧索引表的时候会相应跳转
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return [APPUtils getWordSort:title];
    
}

//控制每个章节顶部头显示 如 A B C
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (searchAreaView.text.length == 0) {
        @try {
            if ([[serviceAreaArray objectAtIndex:section] count] > 0) {
                return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
            } else {
                return nil;
            }
        } @catch (NSException *exception) {
            return nil;
        }
        
    } else {
        return nil;
    }
    
}

//Section高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return 0;
    }else{
        return 22;
    }
}

//改变章节头的颜色高度等
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel * label = [[UILabel alloc] init] ;
    label.frame = CGRectMake(17, 0, SCREENWIDTH, 22);
    label.font=[UIFont fontWithName:textDefaultBoldFont size:13];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = sectionTitle;
    label.textColor = MAINCOLOR;
    UIView * sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 22)] ;
    [sectionView setBackgroundColor:[UIColor clearColor]];
    [sectionView addSubview:label];
    return sectionView;
    
}

//显示多少cells
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(searchAreaView.text.length>0){
        return [serviceAreaFliterArray count];
    }else{
        return [[serviceAreaArray objectAtIndex:section] count];
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //定义个静态字符串为了防止与其他类的tableivew重复
    static NSString *CellIdentifier= @"areaSelect";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
    }else{
        
        if([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0){
            for (UIView *cellView in cell.subviews){
                [cellView removeFromSuperview];
            }
        }else{
            for (UIView *cellView in cell.subviews){ //ios7上cell第一层还有个scrollView
                for (UIView *cellView1 in cellView.subviews){
                    [cellView1 removeFromSuperview];
                }
            }
        }
        
        
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    
    @try {
        Area *area;
        if(searchAreaView.text.length>0){
            area = [serviceAreaFliterArray objectAtIndex:indexPath.row];
        }else{
            NSMutableArray *tempArray = [serviceAreaArray objectAtIndex:[indexPath section]];
            if(tempArray == nil || [tempArray count] == 0){
                tempArray = nil;
                return cell;
            }
            area = [tempArray objectAtIndex:indexPath.row];
            tempArray = nil;
        }
        
        
        UILabel *otherAreaLabel = [[UILabel alloc] initWithFrame:CGRectMake(33,0,SCREENWIDTH-35,45)];
        otherAreaLabel.text = area.city;
        otherAreaLabel.textColor = TEXTGRAY;
        otherAreaLabel.font = [UIFont fontWithName:textDefaultFont size:14];
        otherAreaLabel.textAlignment = NSTextAlignmentLeft;
        [cell addSubview:otherAreaLabel];
        otherAreaLabel = nil;
        
    
        [cell addSubview:[APPUtils get_line:33 y:44.5 width:SCREENWIDTH-52]];
    
        area = nil;
    } @catch (NSException *exception) {
        
    }
    
    
    
    return  cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 45;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Area *area;
    if(searchAreaView.text.length>0){
        area = [serviceAreaFliterArray objectAtIndex:indexPath.row];
    }else{
        
        NSMutableArray *tempArray = [serviceAreaArray objectAtIndex:[indexPath section]];
        area = [tempArray objectAtIndex:indexPath.row];
        tempArray = nil;
        
    }
    
    
    
    
    check_city = area.city;
     area = nil;
    
    [self checkCitySelectOk];


}




//确认城市
-(void)checkCitySelectOk{


    [APPUtils userDefaultsSet:check_city forKey:@"check_city"];
    
    self.callBackBlock(check_city);
    
    [self closePickerView];
}



//选择定位城市
-(void)selectGPSCity:(BOOL)locationCity{
    
    if(![relocationArea.shareLabel.text isEqualToString:@"重新定位"]){
        if(locationCity){
            check_city = location_city;
        }else{
            check_city = @"";
        }
        
        [self checkCitySelectOk];
    
    }else{
        [ShowWaiting showWaiting:@"定位中,请稍后"];
        [MainViewController sharedMain].locationUtil.handleLocationCity = YES;
        [[MainViewController sharedMain].locationUtil startLocation];
    }
}



//选择热门城市
-(void)selectHotCity:(NSString*)cityName{
    
    check_city = cityName;
    [self checkCitySelectOk];
   
    
}



//关闭全部选择框
-(void)closePickerView{
      [self closeAreaInput];
    
    [UIView animateWithDuration:0.2 animations:^{
        
        [self setFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT)];
        self.alpha=0;
    }];
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


@implementation Area
@end
