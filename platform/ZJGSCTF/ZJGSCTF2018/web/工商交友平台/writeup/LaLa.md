## 工商交友平台writeup
开始`index.php`页面，有登录(?func=login)和注册(?func=register)两个功能
<div align=center>
![111.png](http://ww4.sinaimg.cn/large/006iKNp3gy1fpq97quaj4j30ez0ckaa7.jpg)
</div>

<div align=center>
![222.png](http://ww4.sinaimg.cn/large/006iKNp3gy1fpq97uxoc7j30d30gfaa4.jpg)
</div>

输入有过滤
+ 账号需要是 0-9a-zA-Z
+ 年龄需要是数字
+ 密码没有过滤

注册后登录，进入 `profile.php`

<div align=center>
![333.png](http://ww4.sinaimg.cn/large/006iKNp3gy1fpq97zr4w8j30k3085whd.jpg)
</div>

跑目录，找到一个**config.php**，但没有内容
抓包查看，其中login页面有回显，估计是数据库查询内容回显，其他页面正常
![444.png](http://ww4.sinaimg.cn/large/006iKNp3gy1fpq983ffhtj30b508eweo.jpg)
思索.....

+ php中判断是数字可能用到`is_numeric()`，is_numeric判断数字不严格，可以是16进制。
+ 猜测后端数据库语句是
  `insert into lesson1(name,age,password) values(name,age,password)`
  在insert语句中，16进制插入会解析成字符，存入数据库中

以上两点结合在一起
可以通过age输入payload转成16进制，通过insert注入数据库中，再通过login的回显判断是否成功
再通过页面逻辑，判断`profile.php`中的数据库语句是
`select * from 表 where age = (我们的age) `

构造payload测试(因为回显判断4列)
```
age=1 and 0 union select 1,2,3,4 #
age=0x3120616e64203020756e696f6e2073656c65637420312c322c332c342023
```
<div align=center>
![555.png](http://ww2.sinaimg.cn/large/006iKNp3gy1fpq987soqwj30bg08e3yr.jpg)
</div>

<div align=center>
![666.png](http://ww1.sinaimg.cn/large/006iKNp3gy1fpq98az6sij30l50b8q7t.jpg)
</div>

成功
之后省略注入过程
得到**user()**,**database()**,尝试**information_schema**可行，得到表结构

库 | 表 | 列
:--: | :--: | :--:
qwb | users | id username age password
qwb | flag | flag

读取flag