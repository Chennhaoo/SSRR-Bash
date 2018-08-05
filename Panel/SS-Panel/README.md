此脚本只适用于`SS-Panel V3`面板后端，全自动一键搭建。其他面板无法对接！！！<br>
基于`https://github.com/ToyoDAdoubi`源码修改，参考了`GitHub@hybtoy` <br> 
此版本基于doub大佬1.0.26版本修改，脚本有空才升级<br>

面板：<br>
 `https://github.com/NimaQu/ss-panel-v3-mod_Uim`

后端引用：<br>
 `https://github.com/NimaQu/shadowsocks`

本项目压缩包版本：2018-8-5<br>

使用方法：<br>
`wget -N --no-check-certificate https://raw.githubusercontent.com/Chennhaoo/SSRR-Bash/master/Panel/SS-Panel/ssrpa.sh && chmod +x ssrpa.sh && bash ssrpa.sh`

<br>
<br>
<br>
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