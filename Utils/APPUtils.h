
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>
#import <CommonCrypto/CommonDigest.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "sys/utsname.h"
#import "MainViewController.h"

#define FileHashDefaultChunkSizeForReadingData 1024*8 // 8K

static NSUserDefaults *user_Defaults;

@interface APPUtils :NSObject

//iphone 型号
+ (NSString *)getCurrentDeviceModel;

//获取iphone 屏幕版本
+(NSString *)getIphoneVersion;

//获取启动页尺寸
+(NSString*)getLoadingImageName:(NSInteger)num;


//计算NSData 的MD5值
+(NSString*)getMD5WithData:(NSData*)data;

//计算字符串的MD5值，
+(NSString*)getmd5WithString:(NSString*)string;

//计算大文件的MD5值
+(NSString*)fileMD5:(NSString*)path;

//uiimage ->base64
+ (BOOL) imageHasAlpha: (UIImage *) image;
+ (NSString *) image2DataURL: (UIImage *) image;

//base64 -> uiimage
+ (UIImage *) dataURL2Image: (NSString *) imgSrc;


//文本数据格式字符串转换为base64
+ (NSString *)stringToBase64:(NSString *)string;

//base64格式字符串转换为文本数据
+ (NSData *)base64ToString:(NSString *)base64String;


//urlEncoding 编码
+(NSString *)urlEncode:(NSString*)string;

//NSdic -> jsonstring
+(NSString*)data2jsonString:(id)object;

//图片缩放
+(UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

//截取图片
+(UIImage *)getPartOfImage:(UIImage *)img rect:(CGRect)partRect;

//剪裁正方形
+(UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize;

//图片加水印
+(UIImage *)watermarkImage:(UIImage *)img withName:(NSString *)name;

//纠正图片方向
+(UIImage *)fixOrientation:(UIImage *)srcImg;

//压缩图片
+(NSData*)getZipImage:(UIImage*)editedImage;

//验证数字
+ (BOOL)isNumber:(NSString *)string;

//验证手机号
+(BOOL) validateMobile:(NSString *)mobile;

//验证邮箱
+(BOOL)isValidateEmail:(NSString *)emails;

//验证身份证号
+(BOOL) validateIdentityCard: (NSString *)identityCard;

//y验证是否中文
+(BOOL)IsChinese:(NSString *)str;

//是否是银行卡
+(BOOL)IsBankCard:(NSString*)cardNumber;

//判断奇数偶数
+(NSInteger)parity:(NSInteger)num;

//数字数组排序
+(NSArray*)sortArray:(NSMutableArray*)array;

//数组转字符串
+(NSString*)array2String:(NSMutableArray *)array;

//修复单引号
+(NSString*)fixString:(NSString*)str;

//遍历文件夹获得文件夹大小，返回多少M
+ (float ) folderSizeAtPath:(NSString*) folderPath;

//单个文件的大小
+ (long long) fileSizeAtPath:(NSString*) filePath;

//文件是否存在沙盒
+(BOOL)fileExist:(NSString*)path;

//文件大小显示 传入kb
+ (NSString*) fileSizeConver:(float) fileSize;

//获取文件大小单位 (byte)
+(NSString*)getFilesizeUnit:(float)size;

//NSFileManager 时间排序
+(NSArray *)filesByModDate: (NSString *)fullPath;



//获取唯一字符串
+(NSString*)getUniquenessString;

//去掉特殊符号
+(NSString*)clearSpecialSymbols:(NSString*)string;

//字母顺序
+(NSInteger)getWordSort:(NSString*)word;


//获取forward
+(UIImageView*)get_forward:(float)fatherheight x:(float)x;

//获取线条
+(UIView*)get_line:(float)x y:(float)y width:(float)width;
+(UIView*)get_line2:(CGRect)frame;

//alert

+(void)alertShow:(NSString*)string;
+(void)alertShow:(NSString*)title string:(NSString*)string;

+(void)alertShow:(NSString*)string controller:(UIViewController*)controller;
+(void)alertShow:(NSString*)title string:(NSString*)string controller:(UIViewController*)controller;


//支持web浏览的文件
+(BOOL)support_file_check_online:(NSString*)fileType;

/*得到文件类型
 pic:图片类
 video:视频类
 office:文档类
 zip:压缩文件类
 other : 其他
 */
+(NSString*)get_file_type:(NSString*)fileType;


//json解析array
+(NSMutableArray*)getArrByJson:(NSString*)string;

//json解析jsondic
+(NSDictionary*)getDicByJson:(NSString*)string;

//nsdata->nsstring
+(NSString*)data2String:(NSData*)data;

//nsstring->nsdata
+(NSData*)string2Data:(NSString*)string;

//当前时间
+ (NSString*)GetCurrentTimeString;

//秒数转分时显示
+(NSString*)unixSecond2Time:(NSInteger)unixTime;
+(NSString*)unixSecond2Time2:(NSInteger)unixTime;

//秒数转分钟小时
+(NSString*)seconds2Time:(float)second;
+(NSString*)seconds2Time2:(float)second;
+(NSInteger)time2Second:(NSString*)time;

//获取文件图标
+(UIImage *)getFileIcon:(NSString*)tail;

//比较两个数大小
+(CGFloat) compareFloat:(double)a b:(double)b;

//解密
+(NSString*)unCrypt:(NSString*)baseString;

//解码
+(NSString *)URLDecodedString:(NSString *)str;

//验证纯数字
+(BOOL)isPureNumandCharacters:(NSString *)string;

//是否有号码
+(BOOL)phoneInString:(NSString *)string;

//获取一行高
+(CGFloat)getOnelineHeight:(UIFont*)font;

//根据键盘号码获取字母
+(NSArray*)getLetterByNum:(NSInteger)num;

//存入本地联系人
+(void)saveUser2PhoneBook:(NSString*)saveName saveTel:(NSString*)saveTel saveIcon:(BOOL)saveIcon;

//检索联系人
+(BOOL)checkContactExist:(NSString*)name;

//获取通讯录读取权限
+(BOOL)getReadContactsBookPermission;

//钱的单位
+(NSString*)getMoneyUnit:(NSInteger)num unit:(NSString*)unit;

//钱单位
+(NSString*)getMoneyUnit_onlyYuan:(NSInteger)num;

//检查推送
+(BOOL)checkPushMission;

//判断星期几
+(NSString*)weekdayStringFromDate:(NSDate*)inputDate;

//获得NSUserDefaults
+(NSUserDefaults*)getUserDefaults;

//设置NSUserDefaults
+(void)userDefaultsSet:(NSObject*)value forKey:(NSString*)key;

//清理NSUserDefaults
+(void)userDefaultsDelete:(NSString*)key;


//判断两个颜色是否相等
+ (BOOL) isTheSameColor2:(UIColor*)color1 anotherColor:(UIColor*)color2;

//添加阴影
+(void)addShadow:(UIView*)view;

//获取定位按钮
+(UIView*)getLocationBtn:(UIImage*)img x:(float)x y:(float)y width:(float)width;

/*将高德地图zoom调整到显示全部anno的值
 add值越大 zoomlevel就越小
 */
+(void)zoomToMapPoints:(MAMapView*)mapView annotations:(NSArray*)annotations add:(float)add;

//转圈
+(void)takeAround:(NSInteger)count duration:(float)duration view:(UIView*)view;
@end
