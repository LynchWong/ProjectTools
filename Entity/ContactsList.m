//
//  ContactsList.m
//  zpp
//
//  Created by Chuck on 2017/8/4.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "ContactsList.h"

@implementation ContactsList


+ (ContactsList*)contacts{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contactsList = [[self alloc] initContacts];
    });
    
    return contactsList;
    
}



- (id)initContacts{
    self = [super init];
    if (self) {
        
        selectContactsArr = [[NSMutableArray alloc] init];
       
        
        [self setFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT)];
        [self setBackgroundColor:[UIColor whiteColor]];
        self.alpha=0;
        [[[UIApplication sharedApplication].delegate window] addSubview:self];
        
        cellHeight = 60;
    }
    return self;
}




//初始化ui
-(void)showList:(ContactsType)type{

    
   
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(!initok){
            
            controllerType = type;
            
            [ShowWaiting showWaiting:@"联系人加载中,请稍后"];
            
            MyBtnControl *titleView = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 20, SCREENWIDTH, TITLE_HEIGHT-20)];
            titleView.not_ShareHighlight = YES;
            titleView.no_single_click = YES;
            [titleView setBackgroundColor:[UIColor whiteColor]];
            [self addSubview:titleView];
            
            [titleView addLabel:@"选择联系人" color:TEXTGRAY font:[UIFont fontWithName:textDefaultBoldFont size:16]];
            
            MyBtnControl *close = [[MyBtnControl alloc] initWithFrame:CGRectMake(titleView.width-50, 0, 50, titleView.height)];
            [titleView addSubview:close];
            [close addLabel:@"关闭" color:[UIColor lightGrayColor] font:[UIFont fontWithName:textDefaultFont size:12] txtAlignment:NSTextAlignmentCenter x:5];
            close.clickBackBlock = ^(){
                [self closeContactView];
            };
            
            
            //搜索框
            searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, TITLE_HEIGHT, SCREENWIDTH, 41)];
            [self addSubview:searchBar];
            searchBar.tintColor = MAINCOLOR;//光标颜色
            searchBar.delegate = self;
            [searchBar setPlaceholder:@"搜索联系人"];
            [searchBar setBarTintColor:[UIColor whiteColor]];//背景颜色
            
            //去掉上下边线
            CGRect rect = searchBar.frame;
            [searchBar addSubview:[APPUtils get_line3:CGRectMake(0, rect.size.height-2,rect.size.width, 2) color:[UIColor whiteColor]]];
            [searchBar addSubview:[APPUtils get_line3:CGRectMake(0, 0,rect.size.width, 2) color:[UIColor whiteColor]]];
            [searchBar addSubview:[APPUtils get_line3:CGRectMake(0, rect.size.height-0.5,rect.size.width, 0.5) color:MAINCOLOR]];
            [searchBar addSubview:[APPUtils get_line3:CGRectMake(0, 0,rect.size.width, 0.5) color:LINECOLOR]];
            
            
            //联系人列表
            
            
            contactsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, searchBar.height+TITLE_HEIGHT, SCREENWIDTH, BODYHEIGHT-searchBar.height)];//50是底部按钮高
            contactsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //隐藏tableview多余行数的线条
            [contactsTable setBounces:YES];
            [contactsTable setBackgroundColor:[UIColor clearColor]];
            [contactsTable setSectionIndexColor:MAINCOLOR];//侧边栏字母表颜色
            contactsTable.delegate = self;//调用delegate
            contactsTable.dataSource=self;
            contactsTable.separatorStyle = UITableViewCellSeparatorStyleNone; //去掉table分割线
            contactsTable.showsVerticalScrollIndicator = YES;
            [self addSubview:contactsTable];
            
            tableHeight = contactsTable.height;
            
            
            //ios自带刷新
            refreshControl = [[UIRefreshControl alloc] init];
            [refreshControl setTintColor:MAINCOLOR];
            [refreshControl setAlpha:0.7];
            
            [refreshControl addTarget:self action:@selector(pullRefresh) forControlEvents:UIControlEventValueChanged];
            [contactsTable addSubview:refreshControl];
            
            
            tableCoverView = [[UIControl alloc] initWithFrame:CGRectMake(0, searchBar.height+TITLE_HEIGHT, SCREENWIDTH, SCREENHEIGHT)];
            [tableCoverView setBackgroundColor:[UIColor blackColor]];
            tableCoverView.alpha = 0;
            [tableCoverView addTarget:self action:@selector(clickCover) forControlEvents:UIControlEventTouchDown];
            [self addSubview:tableCoverView];
            [self bringSubviewToFront:tableCoverView];
            
            
            [self getContactsThread];
            
        }else{
            
            
            if(![AddressbookUtil getReadContactsBookPermission]){//没有权限
                [self noPermission];
                return;
            }
            
            
            if(type!=controllerType){
                controllerType = type;
             
                [ShowWaiting showWaiting:@"联系人加载中,请稍后"];
                
                NSThread *sectionThread = [[NSThread alloc] initWithTarget:self selector:@selector(setSection) object:nil];
                [sectionThread start];
                
            }
        }
        
        
        
        if(type == SELECT_CONTACTS){
            contactsTable.height = tableHeight-50;
            if(makeOkBtn==nil){
            
                makeOkBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(0,SCREENHEIGHT-50, SCREENWIDTH, 50)];
                [makeOkBtn setEnabled:NO];
                [makeOkBtn setBackgroundColor:MAINCOLOR];
                 makeOkBtn.not_highlight = YES;
                [makeOkBtn setBackgroundColor:[UIColor lightGrayColor]];
                [self addSubview:makeOkBtn];
                
                [makeOkBtn addLabel:@"确定" color:[UIColor whiteColor] font:[UIFont fontWithName:textDefaultBoldFont size:14]];
                
              
                __weak typeof(self) weakSelf = self;
                
                makeOkBtn.clickBackBlock = ^(){
                    [weakSelf callBackArr];
                };
            }
            
            totalPeople = 0;
            [self refreshSelectPeople];
            makeOkBtn.alpha=1;
        }else{
            contactsTable.height = tableHeight;
            makeOkBtn.alpha=0;
        }
        
        [[[UIApplication sharedApplication].delegate window] bringSubviewToFront:self];
        [UIView animateWithDuration:0.4 animations:^{
            self.alpha=1;
            self.y = 0;
        }];
  
    });

}




//下拉刷新
-(void)pullRefresh{
    
    if(!contactsLoadOver){
        return;
    }
    [self getContactsThread];
    
}



//获取手机联通讯录系人线程
-(void)getContactsThread{
    NSThread *gThread = [[NSThread alloc] initWithTarget:self selector:@selector(getContacts) object:nil];
    [gThread start];
    
}

//获取手机联通讯录系人
-(void)getContacts{
    
    if(_reloading){
        return;
    }
    _reloading = YES;
    
    
    dataList = [[NSMutableArray alloc] init];
    
    
    if(oneLineHeight==0){
        oneLineHeight = [APPUtils getOnelineHeight:[UIFont fontWithName:textDefaultFont size:14]];
    }
    
    
    //创建通信录对象
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    
    
    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        if(granted){//有权限
           
            // 创建获取通信录的请求对象
            // 拿到所有打算获取的属性对应的key
            NSArray *keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey,CNContactImageDataKey];
            
            //创建CNContactFetchRequest对象
            CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
            
            
            //遍历所有的联系人  默认拼音排序了
            [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull book_contact,  BOOL * _Nonnull stop) {
                
                //获取联系人的姓名
                NSString *lastname = book_contact.familyName;
                NSString *firstname = book_contact.givenName;
                
                lastname =  [lastname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
                firstname = [firstname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
                if(firstname == nil || [firstname isEqual:[NSNull null]]){
                    firstname = @"";
                }
                if(lastname == nil || [lastname isEqual:[NSNull null]]){
                    lastname = @"";
                }
                NSString *contactName =[NSString stringWithFormat:@"%@%@",lastname,firstname];
                contactName = [APPUtils clearSpecialSymbols:contactName];
                
                if(contactName!=nil&&contactName.length>0){
                    
                    
                    //联系人头像
                    UIImage *avatar;
                    if(book_contact.imageData!=nil){
                        avatar = [UIImage imageWithData:book_contact.imageData];
                        CGSize imageSize = avatar.size;
                        imageSize.width =  imageSize.width*0.4;
                        imageSize.height = imageSize.height*0.4;
                        avatar = [APPUtils scaleToSize:avatar size:imageSize];
                    }
                    NSData *avatarData = UIImageJPEGRepresentation(avatar,0.8);
                    avatar = nil;
                    
                    
                    //获取联系人的电话号码
                    NSArray *phoneNums = book_contact.phoneNumbers;
                    NSString *tempNum = @"";
                    for (CNLabeledValue *labeledValue in phoneNums) {
                        
                        @try {
                            
                            //获取电话号码
                            CNPhoneNumber *phoneNumer = labeledValue.value;
                            NSString *number = phoneNumer.stringValue;
                            if(number!=nil&&number.length>0){
                                
                                if(number==nil){
                                    continue;
                                }
                                
                                
                                if([number isEqualToString:tempNum]){//去掉连续重复的号码
                                    number = nil;
                                    continue;
                                }
                                tempNum = number;
                                
                                
                                Contact *contact = [[Contact alloc] init];
                                contact.contact_tel = [NSString stringWithString:number];
                                contact.contact_name = [NSString stringWithString:contactName];
                                
                                
                                if(avatarData!=nil){
                                    
                                    NSString* imageFilePath = [NSString stringWithFormat:@"%@/%@",[MainViewController sharedMain].avatarPaths,[NSString stringWithFormat:@"contacts_%@.png",number]];
                                    if(![APPUtils fileExist:imageFilePath]){
                                        [avatarData writeToFile: imageFilePath atomically:YES];
                                    }
                                    imageFilePath = nil;
                                }
                                avatarData = nil;
                                
                                
                                
                                contact = [self getFullContact:contact];
                                
                                
                                NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                                paragraph.alignment = NSLineBreakByWordWrapping;
                                
                                NSDictionary *attribute = @{NSFontAttributeName: [UIFont fontWithName:textDefaultFont size:14], NSParagraphStyleAttributeName: paragraph};
                                
                                CGSize nameSize = [contact.contact_name boundingRectWithSize:CGSizeMake(SCREENWIDTH-(cellHeight*0.7+30), MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
                                
                                if(nameSize.height>oneLineHeight+3){
                                    contact.is2Lines=1;
                                }
                                
                                paragraph = nil;
                                attribute = nil;
                                
                                [dataList addObject:contact];
                                
                                contact = nil;
                                number = nil;
                                
                            }
                            
                            phoneNumer = nil;
                            
                        } @catch (NSException *exception) {}
                        
                    }
                    phoneNums = nil;
                    
                    
                }
                contactName = nil;
                book_contact = nil;
                
            }];
            
            
            //装载列表
            NSThread *sectionThread = [[NSThread alloc] initWithTarget:self selector:@selector(setSection) object:nil];
            [sectionThread start];
            
        }else{
            
           [self closeContactView];
        }
    }];
}



-(void)noPermission{

    //无权限
    dispatch_async(dispatch_get_main_queue(), ^{
        [ShowWaiting hideWaiting];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        infoDictionary = nil;
        
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:[NSString stringWithFormat:@"若要获取联系人，请允许<%@>读取您的通讯录，谢谢！",appCurName]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
        
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            [APPUtils intoSetting];
        }];
        
        [alertController addAction:cancel];
        [alertController addAction:confirm];
        
        
        [[MainViewController sharedMain] presentViewController:alertController animated:YES completion:nil];
        cancel = nil;
        confirm = nil;
        alertController = nil;
        
        [self closeContactView];
        
    });
    
}


//设置侧边栏数组
-(void)setSection{
    
    sectionSettingIndex++;//线程自增
    
    NSInteger nowSetting = sectionSettingIndex;
    NSMutableArray *realArray;
    
    if(searchBar.text.length > 0){
        
        filterDataList = [[NSMutableArray alloc] init];
        
        for (Contact *user in dataList) {
            
            if(nowSetting!=sectionSettingIndex){
                break;
            }
            
            NSRange range = [user.contact_name rangeOfString:searchBar.text];
            
            
            NSRange  lettersRange = [user.firstLetter rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            if(nowSetting!=sectionSettingIndex){
                break;
            }
            NSRange  wordsRange = [user.firstWord rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            if(nowSetting!=sectionSettingIndex){
                break;
            }
            NSRange  allLettersRange = [user.allLetters rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            if(nowSetting!=sectionSettingIndex){
                break;
            }
            NSRange  allWordsRange = [user.allWords rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            if(nowSetting!=sectionSettingIndex){
                break;
            }
            
            NSRange  numberRange = [user.contact_tel rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            
            if(nowSetting!=sectionSettingIndex){
                break;
            }
            
            if (range.location != NSNotFound || (lettersRange.location != NSNotFound && searchBar.text.length==1)||(wordsRange.location != NSNotFound && searchBar.text.length>1)||(allLettersRange.location != NSNotFound && searchBar.text.length>1) ||(allWordsRange.location != NSNotFound && searchBar.text.length>1) || numberRange.location != NSNotFound) {
                [filterDataList addObject:user];
            }
            
            
        }
        
        if(nowSetting!=sectionSettingIndex){
            return;
        }
        
        realArray = [[NSMutableArray alloc] initWithArray:filterDataList];
        
    }else{
        
        if(dataList!=nil){
            realArray = [[NSMutableArray alloc] initWithArray:dataList];
        }
        
        
        if(nowSetting!=sectionSettingIndex){
            return;
        }
        
        //            侧边栏拼音的collation
        UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
        NSMutableArray *sortedSections = [[NSMutableArray alloc] initWithCapacity:[[collation sectionTitles] count]];
        
        for (NSUInteger i = 0; i < [[collation sectionTitles] count]; i++) {
            [sortedSections addObject:[NSMutableArray array]];
        }
        
        //将每个用户加入对应拼音组
        if(realArray!=nil){
            for (Contact *user in realArray) {
                if(nowSetting!=sectionSettingIndex){
                    break;
                }
                
                if(cleanSelect){
                    user.selected=NO;
                }
                
                @try {
                    if(user.firstWord!=nil&&user.firstWord.length>0){
                        NSInteger index = [collation sectionForObject:user.firstWord collationStringSelector:@selector(description)];
                        [[sortedSections objectAtIndex:index] addObject:user];
                    }
                    
                } @catch (NSException *exception) {//特殊字符的
                    [[sortedSections lastObject] addObject:user];
                }
                
            }
            cleanSelect = NO;
        }
        
        if(nowSetting!=sectionSettingIndex){
            return;
        }
        
        sections = sortedSections;
        
        sortedSections = nil;
        collation = nil;
    }
    
    
    if(realArray==nil||[realArray count]==0){
        isEmpty = YES;
    }else{
        isEmpty = NO;
        
    }
    realArray = nil;
    
    if(nowSetting!=sectionSettingIndex){
        return;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [contactsTable reloadData];
        selecting=NO;
        
        initok = YES;
        contactsLoadOver = YES;
        [self refreshOver];

    });
}


-(void)refreshOver{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
        _reloading = NO;
        [ShowWaiting hideWaiting];
    });
}




//-------------------------联系人搜索
//点击搜索框后
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)search_Bar{
    
    searchBar.showsCancelButton = YES;
    
    //cancel 颜色
    for(UIView *view in  [[[searchBar subviews] objectAtIndex:0] subviews]) {
        
        if([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            UIButton * cancel =(UIButton *)view;
            [cancel setTitle:@"取消" forState:UIControlStateNormal];
            [cancel setTintColor:[UIColor whiteColor]];
        }
    }
    
    if(searchBar.text.length == 0){
        tableCoverView.alpha=0.6;
    }else{
        tableCoverView.alpha=0;
    }
    
    return YES;
}


//开始输入搜索条件
-(void)searchBar:(UISearchBar *)search_Bar textDidChange:(NSString *)searchText{
    
    if(searchBar.text.length == 0){
        tableCoverView.alpha=0.6;
    }else{
        tableCoverView.alpha=0;
    }
    
    NSThread *sectionThread = [[NSThread alloc] initWithTarget:self selector:@selector(setSection) object:nil];
    [sectionThread start];
    
}

//通过失焦searchbar隐藏输入法，但是这样cancel按钮也会失焦，所以把cancel按钮找到让它变成可用
-(void)hideInput{
    [searchBar resignFirstResponder];
    tableCoverView.alpha=0;
    for(UIView *view in  [[[searchBar subviews] objectAtIndex:0] subviews]) {
        if([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            UIButton * cancel =(UIButton *)view;
            cancel.enabled=YES;
        }
    }
}

//点击键盘的搜索按钮后
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self hideInput];
}

-(void)clickCover {
    
    [self hideInput];
    
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    
    NSThread *sectionThread = [[NSThread alloc] initWithTarget:self selector:@selector(setSection) object:nil];
    [sectionThread start];
}

//tableview开始滚动滑动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self hideInput];
    
}




//---------table

//控制侧边栏的显示和隐藏
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    if (searchBar.text.length == 0) {
        //只显示有名字的拼音
        NSMutableArray *wordArray = [[NSMutableArray alloc]init];
        for(int i=0;i<[sections count];i++){
            @try {
                if([[sections objectAtIndex:i]count]>0){
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
    if (searchBar.text.length == 0) {
        @try {
            if ([[sections objectAtIndex:section] count] > 0) {
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
    label.frame = CGRectMake(10, 0, SCREENWIDTH, 22);
    label.font=[UIFont fontWithName:textDefaultBoldFont size:13];
    label.text = sectionTitle;
    label.textColor = TEXTGRAY;
    UIView * sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 22)] ;
    [sectionView setBackgroundColor:[UIColor whiteColor]];
    [sectionView addSubview:label];
    return sectionView;
    
}



//显示tableview 的章节数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(isEmpty){
        return 1;
    }else{
        if (searchBar.text.length == 0) {
            return sections.count;  //根据字母划分章节
            
        } else {
            return 1;
        }
    }
}

//显示多少cells
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(isEmpty){
        return 1;
    }else{
        if(searchBar.text.length == 0) {
            @try {
                return [[sections objectAtIndex:section] count];
            } @catch (NSException *exception) {
                isEmpty = YES;
                return 1;
            }
            
        }else {
            return [filterDataList count];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *CellIdentifie;
    
    if(controllerType==CONTACTS_PAGE){
        CellIdentifie = @"contact_cell";
    }else if(controllerType==SELECT_CONTACTS){
        CellIdentifie = @"check_group_cell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifie];
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifie];
    }else{
        
        for (UIView *cellView in cell.subviews){
            [cellView removeFromSuperview];
        }
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(isEmpty){
        
        
        UIImageView *noChatView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-ERROR_STATE_BACKGROUND_WIDTH)/2, (tableView.height-ERROR_STATE_BACKGROUND_WIDTH)/2, ERROR_STATE_BACKGROUND_WIDTH, ERROR_STATE_BACKGROUND_WIDTH)];
        
       
        [noChatView setImage:[UIImage imageNamed:@"empty_contacts.png"]];
        
        
        [cell addSubview: noChatView];
        
       
        
        MyBtnControl *cellBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, noChatView.height)];
        cellBtn.not_ShareHighlight = YES;
        cellBtn.clickBackBlock = ^(){
            [self hideInput];
        };
        [cell addSubview:cellBtn];
        cellBtn = nil;
        noChatView = nil;
    
    }else{
        
        @try {
            
            Contact *user;
            
            UIView *sepline;
            BOOL isLast=NO;
            if(searchBar.text.length == 0){
                NSMutableArray *tempArray = [sections objectAtIndex:[indexPath section]];
                if(tempArray == nil || [tempArray count] == 0){
                    tempArray = nil;
                    return cell;
                }
                user = [tempArray objectAtIndex:[indexPath row]];
                
                sepline = [APPUtils get_line:10 y:0 width:SCREENWIDTH];
                
                if(indexPath.row == [tempArray count]-1){
                    isLast = YES;
                }
                
                tempArray = nil;
                
            }else{
                user = [filterDataList objectAtIndex:[indexPath row]];
                sepline = [APPUtils get_line:10 y:cellHeight-0.5 width:SCREENWIDTH];
            }
            
            [cell addSubview:sepline];
            
            if(user == nil){
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return  cell;
            }
            
            
            UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (cellHeight-cellHeight*0.7)/2, cellHeight*0.7,cellHeight*0.7)];
            
            UIImage *avata;
            
            @try {
                NSString* imageFilePath = [NSString stringWithFormat:@"%@/%@",[MainViewController sharedMain].avatarPaths,[NSString stringWithFormat:@"contacts_%@.png",user.contact_tel]];
                avata  = [UIImage imageWithContentsOfFile:imageFilePath];
                imageFilePath = nil;
            } @catch (NSException *exception) {}
           
            
            MyBtnControl *viewHeadControl;
            if(avata == nil){
                avata = [UIImage imageNamed:@"default_contacts.png"];
            }else{
                avatarImageView.layer.borderColor = [MAINCOLOR2 CGColor];
                avatarImageView.layer.borderWidth = 0.2f;
                
                viewHeadControl = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, avatarImageView.width+avatarImageView.x*2, cellHeight)];
                viewHeadControl.shareImage = avatarImageView;
                [cell addSubview:viewHeadControl];
                viewHeadControl.clickBackBlock = ^(){
                    CLPhotoBrowser *imageBrower = [[CLPhotoBrowser alloc] init];
                    imageBrower.photos = [NSMutableArray array];
                    
                    CLPhoto *photo = [[CLPhoto alloc] init];
                    photo.thumbUrl = @"";
                    photo.local_img = avata;
                    photo.scrRect = [avatarImageView convertRect:avatarImageView.bounds toView:nil];
                    [imageBrower.photos addObject:photo];
                    photo = nil;
                    
                    [imageBrower show];
                    imageBrower = nil;
                };
                
            }
            
            
            [avatarImageView.layer setCornerRadius:(avatarImageView.height/2)];
            [avatarImageView.layer setMasksToBounds:YES];//圆角不被盖住
            [avatarImageView setContentMode:UIViewContentModeScaleAspectFill];
            [avatarImageView setClipsToBounds:YES];//减掉超出部分
            [avatarImageView setImage:avata];
            [cell addSubview:avatarImageView];
            
            
            
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(avatarImageView.width+avatarImageView.x*2, 0, SCREENWIDTH-(avatarImageView.width+avatarImageView.x*3)-(controllerType>CONTACTS_PAGE?30:0), cellHeight*0.7)];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            nameLabel.textColor = [UIColor darkGrayColor];
            nameLabel.font = nameFont;
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.numberOfLines = 2;
            nameLabel.text = user.contact_name;
            [cell addSubview:nameLabel];
            
            
            UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.x, cellHeight*0.45+(user.is2Lines?6:0), nameLabel.width, cellHeight*0.5)];
            [phoneLabel setBackgroundColor:[UIColor clearColor]];
            phoneLabel.textColor = [UIColor lightGrayColor];
            phoneLabel.font = [UIFont fontWithName:textDefaultFont size:12];
            phoneLabel.textAlignment = NSTextAlignmentLeft;
            phoneLabel.numberOfLines = 1;
            phoneLabel.text = user.contact_tel;
            [cell addSubview:phoneLabel];
            
            
            if(controllerType==SELECT_CONTACTS){//选择联系人
                UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH-40, (cellHeight-18)/2, 18, 18)];
                selectView.layer.cornerRadius = 4;
                [selectView.layer setMasksToBounds:YES];
                selectView.layer.borderWidth=1.0;
                [cell addSubview:selectView];
                
                if(user.selected){
                    selectView.layer.borderColor = [MAINCOLOR CGColor];
                    UIImageView *selectImg = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 12, 12)];
                    [selectImg setImage:[UIImage imageNamed:@"gougou_blue.png"]];
                    [selectView addSubview:selectImg];
                    selectImg = nil;
                }else{
                    selectView.layer.borderColor = [LINECOLOR CGColor];
                }
            }else{
                [cell addSubview:[APPUtils get_forward:cellHeight x:SCREENWIDTH-30]];
            }
            
          
            
            MyBtnControl *cellBtn = [[MyBtnControl alloc] initWithFrame:CGRectMake(0, 0, SCREENHEIGHT, cellHeight)];
            [cell addSubview:cellBtn];
            cellBtn.shareView = cell;
            cellBtn.clickBackBlock = ^(){
                
                if(controllerType==CONTACTS_PAGE){
                    
                    self.callBackBlock(user, nil);
                    [self closeContactView];
                    
                }else if(controllerType==SELECT_CONTACTS){
                    
                    if(selecting){
                        return;
                    }
                    selecting = YES;
        
                    if(user.selected){
                        user.selected=NO;
                        @try {
                            //删除缓存已选择的
                            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:selectContactsArr];
                            NSInteger i=0;
                            for(Contact *tempUser in tempArray){
                                if([tempUser.contact_tel isEqualToString:user.contact_tel]){
                                    [selectContactsArr removeObjectAtIndex:i];
                                    break;
                                }
                                i++;
                            }
                            tempArray = nil;
                        } @catch (NSException *exception) {}
                        
                    }else{
                        
                        user.selected=YES;
                        //缓存已选择的
                        [selectContactsArr addObject:user];
                    }
                    
                    
                    //刷新选择人数
                    totalPeople = [selectContactsArr count];;
                    [self refreshSelectPeople];
                    
                    NSThread *sectionThread = [[NSThread alloc] initWithTarget:self selector:@selector(setSection) object:nil];
                    [sectionThread start];
                   
                    
                    
                }
            };
            
            
    
            if(viewHeadControl!=nil){
                [cell bringSubviewToFront:viewHeadControl];
            }
            
            viewHeadControl = nil;
            cellBtn = nil;
            avatarImageView = nil;
            avata = nil;
            nameLabel = nil;
            user = nil;
            sepline = nil;
            
        } @catch (NSException *exception) {}
    }
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(isEmpty){
        return tableView.height;
    }else{
        return cellHeight;
    }
}



//刷新确定按钮里选择的人数
-(void)refreshSelectPeople{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(makeOkBtn!=nil){
            if(totalPeople==0){
                makeOkBtn.shareLabel.text = @"确定";
                [makeOkBtn setEnabled:NO];
                [makeOkBtn setBackgroundColor:[UIColor lightGrayColor]];
            }else{
                makeOkBtn.shareLabel.text = [NSString stringWithFormat:@"确定(%d人)",(int)totalPeople];
                [makeOkBtn setEnabled:YES];
                [makeOkBtn setBackgroundColor:MAINCOLOR];
            }
        }

    });
}


//返回组数据
-(void)callBackArr{
    self.callBackBlock(nil, [selectContactsArr mutableCopy]);
     [self closeContactView];
}


//关闭全部选择框
-(void)closeContactView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^(void) {
                                
                                self.alpha=0;
                                self.y = SCREENHEIGHT;
                            }
                         completion:^(BOOL finished){
                             cleanSelect = YES;
                             [self clickCover];
                             _reloading = NO;
                             [selectContactsArr removeAllObjects];
                         }];
    });
    
}



//获取联系人的拼音
-(Contact*)getFullContact:(Contact*)contact{
    
    @try {
        
        @try {
            contact.contact_tel = [contact.contact_tel stringByReplacingOccurrencesOfString:@"-" withString:@""];
        } @catch (NSException *exception) {}
        
        NSString *firstWord;//第一个字的完整拼音
        
        NSMutableString *lettersString = [[NSMutableString alloc] init]; //每个字首字母的拼音组合
        NSMutableString *wordsString = [[NSMutableString alloc] init]; //每个字的拼音组合
        NSMutableString *wordsArrayString = [[NSMutableString alloc] init];
        
        
        for(int i=0;i<contact.contact_name.length;i++){
            NSString *word = [contact.contact_name substringWithRange:NSMakeRange(i,1)];
            word = [APPUtils  nameConvert: word];
            if(i==0){
                firstWord = word;
            }
            
            
            NSMutableString *letterNumString = [[NSMutableString alloc] init];
            
            
            for(int j=0;j<word.length;j++){
                @try {
                    [letterNumString appendString:[APPUtils getNumByLetter:[word substringWithRange:NSMakeRange(j,1)]]];
                } @catch (NSException *exception) {
                }
            }
            @try {
                [wordsArrayString appendString:[NSString stringWithFormat:@"%@,",[NSString stringWithFormat:@"%@",letterNumString]]];
            } @catch (NSException *exception) {
                
            }
            
            letterNumString = nil;
            
            @try {
                [wordsString appendString:word];
                word = [word substringWithRange:NSMakeRange(0,1)];
                [lettersString appendString:word];
            } @catch (NSException *exception) {}
            
            
            word = nil;
        }
        
        if(firstWord==nil){
            firstWord = @"";
        }
        contact.firstWord = [NSString stringWithString:firstWord];//chang
        @try {
            contact.firstLetter = [firstWord substringWithRange:NSMakeRange(0,1)];//c
        } @catch (NSException *exception) {
            contact.firstLetter = @"";
        }
        
        contact.allLetters = [NSString stringWithFormat:@"%@",lettersString];//cyq
        contact.allWords = [NSString stringWithFormat:@"%@",wordsString];//changyouquan
        
        NSString *arrString = [NSString stringWithFormat:@"%@",wordsArrayString];
        if([arrString hasSuffix:@","]){
            arrString = [arrString substringWithRange:NSMakeRange(0,arrString.length-1)];
        }
        contact.allWordsArrayString = arrString;
        arrString = nil;
        @try {
            contact.allWordsArray =  [contact.allWordsArrayString componentsSeparatedByString:@","];
        } @catch (NSException *exception) {
            contact.allWordsArray = [[NSArray alloc] init];
        }
        
        
        NSMutableString *letterMS = [[NSMutableString alloc] init];
        for(int i=0;i<contact.allLetters.length;i++){
            @try {
                [letterMS appendString:[APPUtils getNumByLetter:[contact.allLetters substringWithRange:NSMakeRange(i,1)]]];
            } @catch (NSException *exception) {
                
            }
            
        }
        contact.lettersNumber = [NSString stringWithFormat:@"%@",letterMS];
        letterMS = nil;
        
        
        firstWord = nil;
        lettersString = nil;
        wordsArrayString = nil;
        wordsString = nil;
    } @catch (NSException *exception) {
        
    }
    
    return contact;
    
}




@end

@implementation Contact

@end
