此脚本只适用于`SS-Panel V3`面板后端，全自动一键搭建。其他面板无法对接！！！
基于`https://github.com/ToyoDAdoubi`源码修改，参考了`GitHub@hybtoy`  
此版本基于doub大佬1.0.25版本修改，脚本有空才升级

面板：
 `https://github.com/NimaQu/ss-panel-v3-mod_Uim`

后端引用：
 `https://github.com/NimaQu/shadowsocks`

使用方法：
 `wget -N --no-check-certificate https://raw.githubusercontent.com/Chennhaoo/SSRR-Bash/master/Panel/SS-Panel/ssrpa.sh && chmod +x ssrpa.sh && bash ssrpa.sh`

相较于Doubi大老原始脚本增加了以下东西：
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


其他：
-----

    1、添加doub的SSH端口修改脚本
    2、添加debian/Ubuntu系统更新源和软件选项
    3、添加修改系统时间、时区