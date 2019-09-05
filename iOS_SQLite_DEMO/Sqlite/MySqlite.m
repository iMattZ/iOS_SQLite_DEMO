//
//  MySqlite.m
//  iOS_SQLite_DEMO
//
//  Created by 张博文 on 2019/9/4.
//  Copyright © 2019 com.hime. All rights reserved.
//

#import "MySqlite.h"
#import "Student.h"

@implementation MySqlite

+(instancetype)shareMySqlite{
    static MySqlite *mySqlite;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySqlite = [[MySqlite alloc] init];
    });
    return mySqlite;
}

- (void)openSqlite{
    
    //1.打开数据库(如果指定的数据库文件存在就直接打开，不存在就创建一个新的数据文件)
    //参数1:需要打开的数据库文件路径(iOS中一般将数据库文件放到沙盒目录下的Documents下)
    NSString *nsPath = [NSString stringWithFormat:@"%@/Documents/Person.db", NSHomeDirectory()];
    const char *path = [nsPath UTF8String];
    NSLog(@"sqlite path == %@",nsPath);
    //参数2:指向数据库变量的指针的地址
    //返回值:数据库操作结果
    int ret = sqlite3_open(path, &db);
    
    //判断执行结果
    if (ret == SQLITE_OK) {
        NSLog(@"打开数据库成功");
        if (![self isExistTable:@"student"]) {
            [self creatTable];
        }
    }else{
        NSLog(@"打开数据库失败");
    }
}

/**
 判断一张表是否已经存在
 @param tablename 表名
 */
- (BOOL)isExistTable:(NSString *)tablename{
    char *err;
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM sqlite_master where type= 'table' and name= '%@';",tablename];
    const char *sql_stmt = [sql UTF8String];
    if(sqlite3_exec(db, sql_stmt, NULL, NULL, &err) == 1){
        return YES;
    }else{
        return NO;
    }
    return NO;
}

- (void)creatTable{
    //1.设计创建表的sql语句
    const char * sql = "CREATE TABLE IF NOT EXISTS student(ID INTEGER PRIMARY KEY AUTOINCREMENT, num integer,name 'text', 'sex' 'text','age' integer);";
    
    //2.执行sql语句
    //通过sqlite3_exec方法可以执行创建表、数据的插入、数据的删除以及数据的更新操作；但是数据查询的sql语句不能使用这个方法来执行
    //参数1:数据库指针(需要操作的数据库)
    //参数2:需要执行的sql语句
    //返回值:执行结果
    int ret = sqlite3_exec(db, sql, NULL, NULL, NULL);
    
    //3.判断执行结果
    if (ret == SQLITE_OK) {
        NSLog(@"创建表成功");
    }else{
        NSLog(@"创建表失败");
    }
}

//添加数据
- (void)addStudent:(Student *)stu {
    
    //操作之前先打开数据库
    [self openSqlite];
    
    //1.准备sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"insert into student(num,name,age,sex) values (%@,'%@','%@','%@')",@(stu.num),stu.name,@(stu.age),stu.sex];
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result = sqlite3_exec(db, [sqlite UTF8String], nil, nil, &error);
    if (result == SQLITE_OK) {
        NSLog(@"添加数据成功");
    } else {
        NSLog(@"添加数据失败 %s",error);
    }
    
    //    结束之后要记得关闭: 这一点很重要
    [self closeSqlite];
}

//删除数据
- (void)delete:(Student*)stu {
    
    //操作之前先打开数据库
    [self openSqlite];
    
    //1.准备sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"delete from student where num = '%ld'",stu.num];
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result = sqlite3_exec(db, [sqlite UTF8String], nil, nil, &error);
    if (result == SQLITE_OK) {
        NSLog(@"删除数据成功");
    } else {
        NSLog(@"删除数据失败%s",error);
    }
    
    //    结束之后要记得关闭: 这一点很重要
    [self closeSqlite];
}

//修改数据
- (void)updataWithStu:(Student *)stu {
    
    //操作之前先打开数据库
    [self openSqlite];
    
    //1.sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"update student set name = '%@',sex = '%@',age = '%ld' where num = '%ld'",stu.name,stu.sex,stu.age,stu.num];
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result = sqlite3_exec(db, [sqlite UTF8String], nil, nil, &error);
    if (result == SQLITE_OK) {
        NSLog(@"修改数据成功");
    } else {
        NSLog(@"修改数据失败");
    }
    
    //    结束之后要记得关闭: 这一点很重要
    [self closeSqlite];
}

//查询所有数据
- (NSMutableArray*)selecAllStudent {
    
    [self openSqlite];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //1.准备sqlite语句
    //    NSString *sqlite = [NSString stringWithFormat:@"select * from student"];
    char *sql = "select * from student";
    //2.伴随指针
    sqlite3_stmt *stmt = NULL;
    //3.预执行sqlite语句
    //    int result = sqlite3_prepare_v2(db, sqlite.UTF8String, -1, &stmt, NULL);//第4个参数是一次性返回所有的参数,就用-1
    int result = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"查询成功");
        //4.执行n次
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            Student *stu = [[Student alloc] init];
            //从伴随指针获取数据,第1列
            int num = sqlite3_column_int(stmt, 1);
            stu.num = num;
            //从伴随指针获取数据,第2列
            stu.name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)] ;
            //从伴随指针获取数据,第3列
            stu.sex = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)] ;
            //从伴随指针获取数据,第4列
            stu.age = sqlite3_column_int(stmt, 4);
            
            [array addObject:stu];
        }
    } else {
        NSLog(@"查询失败");
    }
    //5.关闭伴随指针
    sqlite3_finalize(stmt);
    //    结束之后要记得关闭: 这一点很重要
    [self closeSqlite];
    return array;
}

#pragma mark - 4.关闭数据库
- (void)closeSqlite {
    
    int result = sqlite3_close(db);
    if (result == SQLITE_OK) {
        NSLog(@"数据库关闭成功");
    } else {
        NSLog(@"数据库关闭失败");
    }
}


@end
