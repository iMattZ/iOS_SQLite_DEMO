//
//  MySqlite.h
//  iOS_SQLite_DEMO
//
//  Created by 张博文 on 2019/9/4.
//  Copyright © 2019 com.hime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@class Student;

static sqlite3 *db;//是指向数据库的指针,我们其他操作都是用这个指针来完成

@interface MySqlite : NSObject

+(instancetype)shareMySqlite;

//添加数据
- (void)addStudent:(Student *)stu;

//删除数据
- (void)delete:(Student*)stu;

//修改数据
- (void)updataWithStu:(Student *)stu;

//查询所有数据
- (NSMutableArray*)selecAllStudent;

@end


