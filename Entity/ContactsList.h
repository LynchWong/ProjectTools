//
//  ContactsList.h
//  zpp
//
//  Created by Chuck on 2017/8/4.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import <Contacts/Contacts.h>
#import "AddressbookUtil.h"
@class Contact;
@class ContactsList;

static ContactsList *contactsList;

#define  nameFont [UIFont fontWithName:@"HelveticaNeue" size:14]//table Name的字体 判断行数

@interface ContactsList : UIView<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate>{
    
    BOOL initok;
    
    UIRefreshControl *refreshControl;
    UISearchBar *searchBar;
    UIControl *tableCoverView;
    NSMutableArray *filterDataList;//搜索
    NSMutableArray *dataList;
    NSMutableArray *sections;
    UITableView *contactsTable;
    
    BOOL isEmpty;
    BOOL _reloading;
    CGFloat cellHeight;
    CGFloat tableHeight;
    CGFloat oneLineHeight;
    NSInteger controllerType;//类型 1联系人页面  2选择群成员
    BOOL selecting;//选择中
    NSInteger sectionSettingIndex;//联系人设置中
    
    BOOL contactsLoadOver;//联系人加载完成
    
    
    NSMutableArray *selectContactsArr;//多选
    NSInteger totalPeople;//总人数
    MyBtnControl *makeOkBtn;
    BOOL cleanSelect;//清理选择

    BOOL selectOk;
}

typedef enum : NSInteger {
    CONTACTS_PAGE  = 1,
    SELECT_CONTACTS,
} ContactsType;//类型 1联系人页面  2选择群成员


+ (ContactsList*)contacts;

-(id)initContacts;

//显示
-(void)showList:(ContactsType)type;



typedef void (^ContactsBlock)(Contact* contact,NSMutableArray*selectArr);
@property (nonatomic,strong)ContactsBlock callBackBlock;


@end


@interface Contact : NSObject
@property (strong, nonatomic) NSString* contact_name;
@property (strong, nonatomic) NSString* contact_tel;
@property (strong, nonatomic) NSString* firstWord;//第一个拼音
@property (strong, nonatomic) NSString* firstLetter;//第一个字母
@property (strong, nonatomic) NSString* allLetters;//首字母拼音
@property (strong, nonatomic) NSString* allWords;//全拼
@property (strong, nonatomic) NSString* allWordsArrayString;//全拼数组string
@property (strong, nonatomic) NSArray* allWordsArray;//全拼数组
@property (strong, nonatomic) NSString* lettersNumber;//首字母对应的数字键盘


@property (assign, nonatomic) NSInteger is2Lines;//是否是两行


@property (assign, nonatomic) NSInteger rangeType;//匹配类型   1以号码开头类型 2首字母匹配类型 3电话包含类型 4全拼匹配类型
@property (assign, nonatomic) NSInteger rangeBegin;//匹配的字符串开头位置
@property (assign, nonatomic) NSInteger rangeEnd;//匹配的字符串结束位置
@property (assign, nonatomic) BOOL selected;//是否被选中


@property (strong, nonatomic) NSString* contact_note;//描述
@property (assign, nonatomic) NSInteger contact_group_id;//哪个组
@property (assign, nonatomic) NSInteger contact_uid;//联系人id
@property (strong, nonatomic) NSString* phonehome;//归属地
@property (strong, nonatomic) NSString* operatorName;//运营商名字
@end

