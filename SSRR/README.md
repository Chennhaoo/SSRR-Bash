此脚本只适用于`ShadowsocksR mudbjson server`多端口多用户，无法与面板对接！！！
基于`https://github.com/ToyoDAdoubi`源码修改，参考了`GitHub@hybtoy`    
SSRR服务端基于`https://github.com/shadowsocksrr/shadowsocksr`     akkariiin/dev 分支<br>
脚本详细用法参见`https://doub.io/ss-jc60/`<br>
此版本基于doub大佬1.0.25版本修改，脚本有空才升级

增加加密：
-----

    xsalsa20
    xchacha20


增加协议：
-----

    auth_chain_c
    auth_chain_d
    auth_chain_e
    auth_chain_f


使用方法
----

`wget -N --no-check-certificate https://raw.githubusercontent.com/Chennhaoo/SSRR-Bash/master/SSRR/ssrmu.sh && chmod +x ssrmu.sh && bash ssrmu.sh`
    

其他：
-----

    1、添加doub的SSH端口修改脚本
    2、添加debian/Ubuntu系统更新源和软件选项
    3、添加修改系统时间、时区
    4、可通过脚本升级后端，升级后需要重新配置

