# 考点 
0. 难度:难
1. csrf
    <img src=csrf_poc>
2. $_SERVER['SCRIPT_NAME']漏洞
3. 远程包含漏洞

# 搭建要求

0. windows环境\linux环境实验未成功(跟apache版本有关系，okami学长的dockerhub库web 可以尝试搭建)
1. php5.4.*
2. mysql
3. php.ini 修改session.cookie_httponly=1
    防止xss盗取cookie
4. allow_url_include 开启

ps: 如果要降低难度，可以把源码给他们
ps: 题目上线前，记得清楚一下特殊文件，啥.DS_STORE 一些文件泄露的东西

# by 0kami 
# 搭建、修改 by lala