此脚本只适用于`SSR-Panel`面板后端，全自动一键搭建。其他面板无法对接！！！<br>
基于`https://github.com/ToyoDAdoubi`源码修改，参考了`GitHub@hybtoy`  <br>
此版本基于doub大佬1.0.25版本修改，脚本有空才升级<br>

面板：<br>
 `https://github.com/ssrpanel/ssrpanel`

后端引用：<br>
 `https://github.com/ssrpanel/shadowsocksr`

使用方法：<br>
`wget -N --no-check-certificate https://raw.githubusercontent.com/Chennhaoo/SSRR-Bash/master/Panel/SSR-Panel/ssrpa.sh && chmod +x ssrpa.sh && bash ssrpa.sh`

相较于Doubi大老原始脚本增加了以下东西：<br>
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


