#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 6+/Debian 6+/Ubuntu 14.04+
#	Description: Install the ShadowsocksR mudbjson server
#	Version: 1.0.26
#	Author: Toyo
#	Blog: https://doub.io/ss-jc60/
#=================================================


#------------------------------------------环境配置开始
sh_ver="1.0.26"
filepath=$(cd "$(dirname "$0")"; pwd)
file=$(echo -e "${filepath}"|awk -F "$0" '{print $1}')
ssr_folder="/usr/local/shadowsocksr"
config_file="${ssr_folder}/config.json"
config_user_file="${ssr_folder}/user-config.json"
config_user_api_file="${ssr_folder}/userapiconfig.py"
config_user_mudb_file="${ssr_folder}/mudb.json"
ssr_log_file="${ssr_folder}/ssserver.log"
Libsodiumr_file="/usr/local/lib/libsodium.so"
Libsodiumr_ver_backup="1.0.15"
Server_Speeder_file="/serverspeeder/bin/serverSpeeder.sh"
LotServer_file="/appex/bin/serverSpeeder.sh"
BBR_file="${file}/bbr.sh"
jq_file="${ssr_folder}/jq"
SSH_file="${file}/ssh_port.sh"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
Separator_1="——————————————————————————————"

check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前账号非ROOT(或没有ROOT权限)，无法继续操作，请使用${Green_background_prefix} sudo su ${Font_color_suffix}来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}
#------------------------------------------环境配置结束

#------------------------------------------检查选项开始
check_pid(){
	PID=`ps -ef |grep -v grep | grep server.py |awk '{print $2}'`
}
check_crontab(){
	[[ ! -e "/usr/bin/crontab" ]] && echo -e "${Error} 缺少依赖 Crontab ，请尝试手动安装 CentOS: yum install crond -y , Debian/Ubuntu: apt-get install cron -y !" && exit 1
}
SSR_installation_status(){
	[[ ! -e ${ssr_folder} ]] && echo -e "${Error} 没有发现 ShadowsocksR 文件夹，请检查 !" && exit 1
}
Server_Speeder_installation_status(){
	[[ ! -e ${Server_Speeder_file} ]] && echo -e "${Error} 没有安装 锐速(Server Speeder)，请检查 !" && exit 1
}
LotServer_installation_status(){
	[[ ! -e ${LotServer_file} ]] && echo -e "${Error} 没有安装 LotServer，请检查 !" && exit 1
}
Check_python(){
	python_ver=`python -h`
	if [[ -z ${python_ver} ]]; then
		echo -e "${Info} 没有安装Python，开始安装..."
		if [[ ${release} == "centos" ]]; then
			yum install -y python
		else
			apt-get install -y python
		fi
	fi
}
Centos_yum(){
	yum update
	cat /etc/redhat-release |grep 7\..*|grep -i centos>/dev/null
	if [[ $? = 0 ]]; then
		yum install -y vim unzip crond net-tools git
	else
		yum install -y vim unzip crond git
	fi
}
Debian_apt(){
	apt-get update
	cat /etc/issue |grep 9\..*>/dev/null
	if [[ $? = 0 ]]; then
		apt-get install -y vim unzip cron net-tools git
	else
		apt-get install -y vim unzip cron git
	fi
}
#------------------------------------------检查选项结束

#------------------------------------------Libsodium开始
Install_Libsodium(){
	if [[ -e ${Libsodiumr_file} ]]; then
		echo -e "${Error} libsodium 已安装 , 是否覆盖安装(更新)？[y/N]"
		stty erase '^H' && read -p "(默认: n):" yn
		[[ -z ${yn} ]] && yn="n"
		if [[ ${yn} == [Nn] ]]; then
			echo "已取消..." && exit 1
		fi
	else
		echo -e "${Info} libsodium 未安装，开始安装..."
	fi
	Check_Libsodium_ver
	if [[ ${release} == "centos" ]]; then
		yum update
		echo -e "${Info} 安装依赖..."
		yum -y groupinstall "Development Tools"
		echo -e "${Info} 下载..."
		wget  --no-check-certificate -N "https://github.com/jedisct1/libsodium/releases/download/${Libsodiumr_ver}/libsodium-${Libsodiumr_ver}.tar.gz"
		echo -e "${Info} 解压..."
		tar -xzf libsodium-${Libsodiumr_ver}.tar.gz && cd libsodium-${Libsodiumr_ver}
		echo -e "${Info} 编译安装..."
		./configure --disable-maintainer-mode && make -j2 && make install
		echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	else
		apt-get update
		echo -e "${Info} 安装依赖..."
		apt-get install -y build-essential
		echo -e "${Info} 下载..."
		wget  --no-check-certificate -N "https://github.com/jedisct1/libsodium/releases/download/${Libsodiumr_ver}/libsodium-${Libsodiumr_ver}.tar.gz"
		echo -e "${Info} 解压..."
		tar -xzf libsodium-${Libsodiumr_ver}.tar.gz && cd libsodium-${Libsodiumr_ver}
		echo -e "${Info} 编译安装..."
		./configure --disable-maintainer-mode && make -j2 && make install
	fi
	ldconfig
	cd .. && rm -rf libsodium-${Libsodiumr_ver}.tar.gz && rm -rf libsodium-${Libsodiumr_ver}
	[[ ! -e ${Libsodiumr_file} ]] && echo -e "${Error} libsodium 安装失败 !" && exit 1
	echo && echo -e "${Info} libsodium 安装成功 !" && echo
}
Check_Libsodium_ver(){
	echo -e "${Info} 开始获取 libsodium 最新版本..."
	Libsodiumr_ver=$(wget -qO- "https://github.com/jedisct1/libsodium/tags"|grep "/jedisct1/libsodium/releases/tag/"|head -1|sed -r 's/.*tag\/(.+)\">.*/\1/')
	[[ -z ${Libsodiumr_ver} ]] && Libsodiumr_ver=${Libsodiumr_ver_backup}
	echo -e "${Info} libsodium 最新版本为 ${Green_font_prefix}${Libsodiumr_ver}${Font_color_suffix} !"
}
#------------------------------------------Libsodium结束

#------------------------------------------ShadowsocksR开始
Install_SSR(){
	check_root
	[[ -e ${ssr_folder} ]] && echo -e "${Error} ShadowsocksR 文件夹已存在，请检查( 如安装失败或者存在旧版本，请先卸载 ) !" && exit 1
	echo -e "${Info} 开始安装/配置 ShadowsocksR依赖..."
	Installation_dependency
	echo -e "${Info} 开始下载/安装 ShadowsocksR文件..."
	Download_SSR
	echo -e "${Info} 开始下载/安装 ShadowsocksR服务脚本(init)..."
	Service_SSR
	echo -e "${Info} 安装JQ解析器"
	JQ_install
	echo -e "${Info} 安装Cymysql"
	Cymysql_install
	menu_status
}
# 安装 依赖
Installation_dependency(){
	if [[ ${release} == "centos" ]]; then
		Centos_yum
	else
		Debian_apt
	fi
	[[ ! -e "/usr/bin/unzip" ]] && echo -e "${Error} 依赖 unzip(解压压缩包) 安装失败，多半是软件包源的问题，请检查 !" && exit 1
	Check_python
	#echo "nameserver 8.8.8.8" > /etc/resolv.conf
	#echo "nameserver 1.1.1.1" >> /etc/resolv.conf
	\cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	if [[ ${release} == "centos" ]]; then
		/etc/init.d/crond restart
	else
		/etc/init.d/cron restart
	fi
}
# 下载 ShadowsocksR
Download_SSR(){
	cd "/usr/local"
	git clone https://github.com/ssrpanel/shadowsocksr.git
	[[ ! -e ${ssr_folder} ]] && echo -e "${Error} ShadowsocksR服务端 下载失败 !" && exit 1
	cd "shadowsocksr"
    sed -i 's/ \/\/ only works under multi-user mode//g' "${config_user_file}"
	echo -e "${Info} ShadowsocksR服务端 下载完成 !"
}
#SSR服务
Service_SSR(){
	if [[ ${release} = "centos" ]]; then
		if ! wget --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/other/ssrmu_centos -O /etc/init.d/ssrmu; then
			echo -e "${Error} ShadowsocksR服务 管理脚本下载失败 !" && exit 1
		fi
		chmod +x /etc/init.d/ssrmu
		chkconfig --add ssrmu
		chkconfig ssrmu on
	else
		if ! wget --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/other/ssrmu_debian -O /etc/init.d/ssrmu; then
			echo -e "${Error} ShadowsocksR服务 管理脚本下载失败 !" && exit 1
		fi
		chmod +x /etc/init.d/ssrmu
		update-rc.d -f ssrmu defaults
	fi
	echo -e "${Info} ShadowsocksR服务 管理脚本下载完成 !"
}
# 安装 JQ解析器
JQ_install(){
	if [[ ! -e ${jq_file} ]]; then
		cd "${ssr_folder}"
		if [[ ${bit} = "x86_64" ]]; then
			wget --no-check-certificate "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" -O ${jq_file}
		else
			wget --no-check-certificate "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux32" -O ${jq_file}
		fi
		[[ ! -e ${jq_file} ]] && echo -e "${Error} JQ解析器 重命名失败，请检查 !" && exit 1
		chmod +x ${jq_file}
		echo -e "${Info} JQ解析器 安装完成，继续..." 
	else
		echo -e "${Info} JQ解析器 已安装，继续..."
	fi
}
#安装Cymysql
Cymysql_install(){
	echo && echo -e "  请根据MYSQL版本安装Cymysql
	
 	${Green_font_prefix}1.${Font_color_suffix} 5.5及以下
 	${Green_font_prefix}2.${Font_color_suffix} 5.6及以上" && echo
	stty erase '^H' && read -p "(默认: 取消):" num
	[[ -z "${num}" ]] && echo "已取消..." && exit 1
	if [[ ${num} == "1" ]]; then
		cd "${ssr_folder}"
		rm -rf CyMySQL
		rm -rf cymysql
		wget https://github.com/nakagami/CyMySQL/archive/REL_0_9_4.tar.gz
		tar zxvf REL_0_9_4.tar.gz
		mv CyMySQL-REL_0_9_4/cymysql/ ./
		rm REL_0_9_4.tar.gz
		rm -rf CyMySQL-REL_0_9_4/
	elif [[ ${num} == "2" ]]; then
		cd "${ssr_folder}"
		rm -rf CyMySQL
		rm -rf cymysql
		git clone https://github.com/nakagami/CyMySQL.git
		mv CyMySQL/cymysql ./
		rm -rf CyMySQL
	else
		echo -e "${Error} 请输入正确的数字(1-2)" && exit 1
	fi
}
#启动SSR
Start_SSR(){
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} ShadowsocksR 正在运行 !" && exit 1
	/etc/init.d/ssrmu start
}
#停止SSR
Stop_SSR(){
	SSR_installation_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} ShadowsocksR 未运行 !" && exit 1
	/etc/init.d/ssrmu stop
}
#重启SSR
Restart_SSR(){
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && /etc/init.d/ssrmu stop
	/etc/init.d/ssrmu start
}
#查看SSR日志
View_Log(){
	SSR_installation_status
	[[ ! -e ${ssr_log_file} ]] && echo -e "${Error} ShadowsocksR日志文件不存在 !" && exit 1
	echo && echo -e "${Tip} 按 ${Red_font_prefix}Ctrl+C${Font_color_suffix} 终止查看日志" && echo
	tail -f ${ssr_log_file}
}
#检查SSR更新
Update_SSR(){ 
	[[ ! -e ${ssr_folder} ]] && echo -e "${Error} 没有安装 ShadowsocksR，请检查 !" && exit 1
	echo "
	更新前请备份好配置文件
	确定要 更新ShadowsocksR？[y/N]
	" && echo
	stty erase '^H' && read -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		SSR_installation_status
		echo -e "准备更新"
		cd ${ssr_folder}
		git pull
		Restart_SSR
		echo -e "更新完毕"
	else
		echo && echo " 已取消..." && echo
	fi
}
#卸载SSR
Uninstall_SSR(){
	[[ ! -e ${ssr_folder} ]] && echo -e "${Error} 没有安装 ShadowsocksR，请检查 !" && exit 1
	echo "确定要 卸载ShadowsocksR？[y/N]" && echo
	stty erase '^H' && read -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		check_pid
		[[ ! -z "${PID}" ]] && kill -9 ${PID}
		if [[ ! -z $(crontab -l | grep "ssrpa.sh") ]]; then
			crontab_monitor_ssr_cron_stop
			Clear_transfer_all_cron_stop
		fi
		if [[ ${release} = "centos" ]]; then
			chkconfig --del ssrmu
		else
			update-rc.d -f ssrmu remove
		fi
		rm -rf ${ssr_folder} && rm -rf /etc/init.d/ssrmu
		echo && echo " ShadowsocksR 卸载完成 !" && echo
	else
		echo && echo " 卸载已取消..." && echo
	fi
}
#------------------------------------------ShadowsocksR结束

#------------------------------------------SSH开始
#修改SSH端口
Install_SSHPOR(){
	[[ ${release} = "centos" ]] && echo -e "${Error} 本脚本不支持 CentOS系统 !" && exit 1
	echo -e "————————
如果采用 ${Green_font_prefix} [保守修改]${Font_color_suffix} 选项，在修改完后新SSH链接正常 请链接后再次执行命令 ${Green_font_prefix} [bash /root/ssh_port.sh end]${Font_color_suffix} 以删除旧端口配置！
当服务器存在外部防火墙时（如 阿里云、腾讯云、微软云、谷歌云、亚马逊云等），需要外部防火墙开放 新SSH端口TCP协议方可连接！
————————" && echo
	echo "确定更改SSH端口吗 ？[y/N]" && echo
	stty erase '^H' && read -p "(默认: Y):" unyn 
	if [[ ${unyn} == [Nn] ]]; then
		echo && echo -e "${Info} 已取消..." && exit 1
		else
		if [[ ! -e ${SSH_file} ]]; then
			echo -e "${Error} 没有发现 SSH修改端口脚本，开始下载..."
			cd "${file}"
			if ! wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssh_port.sh; then
				echo -e "${Error} SSH 修改端口脚本下载失败 !" && exit 1
			else
				echo -e "${Info} SSH 修改端口脚本下载完成 !"
				chmod +x ssh_port.sh
			fi
		fi
	fi
	echo -e "${Info} 开始修改..."
	bash "${SSH_file}"
}
#------------------------------------------SSH结束

#------------------------------------------其他功能开始
# 其他功能
# 其他功能
Other_functions(){
	echo && echo -e "  你要做什么？
	
  ${Green_font_prefix}1.${Font_color_suffix} 配置 BBR
  ${Green_font_prefix}2.${Font_color_suffix} 配置 锐速(ServerSpeeder)
  ${Green_font_prefix}3.${Font_color_suffix} 配置 LotServer(锐速母公司)
  ${Tip} 锐速/LotServer/BBR 不支持 OpenVZ！
  ${Tip} 锐速和LotServer不能共存！
————————————
  ${Green_font_prefix}4.${Font_color_suffix} 一键封禁 BT/PT/SPAM (iptables)
  ${Green_font_prefix}5.${Font_color_suffix} 一键解封 BT/PT/SPAM (iptables)
————————————
  ${Green_font_prefix}6.${Font_color_suffix} 切换 ShadowsocksR日志输出模式
  —— 说明：SSR默认只输出错误日志，此项可切换为输出详细的访问日志。
  ${Green_font_prefix}7.${Font_color_suffix} 监控 ShadowsocksR服务端运行状态
  —— 说明：该功能适合于SSR服务端经常进程结束，启动该功能后会每分钟检测一次，当进程不存在则自动启动SSR服务端。
————————————
  ${Green_font_prefix}8.${Font_color_suffix} 更新软件源 
  ${Tip} 仅支持Debian/Ubuntu系统 
———————————— 
  ${Green_font_prefix}9.${Font_color_suffix} 更新系统时间 
  ${Green_font_prefix}10.${Font_color_suffix} 更新软件 （谨慎操作）
  " && echo
	stty erase '^H' && read -p "(默认: 取消):" other_num
	[[ -z "${other_num}" ]] && echo "已取消..." && exit 1
	if [[ ${other_num} == "1" ]]; then
		Configure_BBR
	elif [[ ${other_num} == "2" ]]; then
		Configure_Server_Speeder
	elif [[ ${other_num} == "3" ]]; then
		Configure_LotServer
	elif [[ ${other_num} == "4" ]]; then
		BanBTPTSPAM
	elif [[ ${other_num} == "5" ]]; then
		UnBanBTPTSPAM
	elif [[ ${other_num} == "6" ]]; then
		Set_config_connect_verbose_info
	elif [[ ${other_num} == "7" ]]; then
		Set_crontab_monitor_ssr
	elif [[ ${other_num} == "8" ]]; then
		Update_YUAN	
	elif [[ ${other_num} == "9" ]]; then
		Sys_time
	elif [[ ${other_num} == "10" ]]; then
		Update_SYS	
	else
		echo -e "${Error} 请输入正确的数字 [1-10]" && exit 1
	fi
}
# BBR
Configure_BBR(){
	echo && echo -e "  你要做什么？
	
 ${Green_font_prefix}1.${Font_color_suffix} 安装 BBR
————————
 ${Green_font_prefix}2.${Font_color_suffix} 启动 BBR
 ${Green_font_prefix}3.${Font_color_suffix} 停止 BBR
 ${Green_font_prefix}4.${Font_color_suffix} 查看 BBR 状态" && echo
echo -e "${Green_font_prefix} [安装前 请注意] ${Font_color_suffix}
1. 安装开启BBR，需要更换内核，存在更换失败等风险(重启后无法开机)
2. 本脚本仅支持 Debian / Ubuntu 系统更换内核，OpenVZ和Docker 不支持更换内核
3. Debian 更换内核过程中会提示 [ 是否终止卸载内核 ] ，请选择 ${Green_font_prefix} NO ${Font_color_suffix}" && echo
	stty erase '^H' && read -p "(默认: 取消):" bbr_num
	[[ -z "${bbr_num}" ]] && echo "已取消..." && exit 1
	if [[ ${bbr_num} == "1" ]]; then
		Install_BBR
	elif [[ ${bbr_num} == "2" ]]; then
		Start_BBR
	elif [[ ${bbr_num} == "3" ]]; then
		Stop_BBR
	elif [[ ${bbr_num} == "4" ]]; then
		Status_BBR
	else
		echo -e "${Error} 请输入正确的数字(1-4)" && exit 1
	fi
}
Install_BBR(){
	[[ ${release} = "centos" ]] && echo -e "${Error} 本脚本不支持 CentOS系统安装 BBR !" && exit 1
	BBR_installation_status
	bash "${BBR_file}"
}
Start_BBR(){
	BBR_installation_status
	bash "${BBR_file}" start
}
Stop_BBR(){
	BBR_installation_status
	bash "${BBR_file}" stop
}
Status_BBR(){
	BBR_installation_status
	bash "${BBR_file}" status
}
BBR_installation_status(){
	if [[ ! -e ${BBR_file} ]]; then
		echo -e "${Error} 没有发现 BBR脚本，开始下载..."
		cd "${file}"
		if ! wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/bbr.sh; then
			echo -e "${Error} BBR 脚本下载失败 !" && exit 1
		else
			echo -e "${Info} BBR 脚本下载完成 !"
			chmod +x bbr.sh
		fi
	fi
}

# 锐速
Configure_Server_Speeder(){
	echo && echo -e "你要做什么？
 ${Green_font_prefix}1.${Font_color_suffix} 安装 锐速
 ${Green_font_prefix}2.${Font_color_suffix} 卸载 锐速
————————
 ${Green_font_prefix}3.${Font_color_suffix} 启动 锐速
 ${Green_font_prefix}4.${Font_color_suffix} 停止 锐速
 ${Green_font_prefix}5.${Font_color_suffix} 重启 锐速
 ${Green_font_prefix}6.${Font_color_suffix} 查看 锐速 状态
 
 注意： 锐速和LotServer不能同时安装/启动！" && echo
	stty erase '^H' && read -p "(默认: 取消):" server_speeder_num
	[[ -z "${server_speeder_num}" ]] && echo "已取消..." && exit 1
	if [[ ${server_speeder_num} == "1" ]]; then
		Install_ServerSpeeder
	elif [[ ${server_speeder_num} == "2" ]]; then
		Server_Speeder_installation_status
		Uninstall_ServerSpeeder
	elif [[ ${server_speeder_num} == "3" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} start
		${Server_Speeder_file} status
	elif [[ ${server_speeder_num} == "4" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} stop
	elif [[ ${server_speeder_num} == "5" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} restart
		${Server_Speeder_file} status
	elif [[ ${server_speeder_num} == "6" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} status
	else
		echo -e "${Error} 请输入正确的数字(1-6)" && exit 1
	fi
}
Install_ServerSpeeder(){
	[[ -e ${Server_Speeder_file} ]] && echo -e "${Error} 锐速(Server Speeder) 已安装 !" && exit 1
	#借用91yun.rog的开心版锐速
	wget --no-check-certificate -qO /tmp/serverspeeder.sh https://raw.githubusercontent.com/91yun/serverspeeder/master/serverspeeder.sh
	[[ ! -e "/tmp/serverspeeder.sh" ]] && echo -e "${Error} 锐速安装脚本下载失败 !" && exit 1
	bash /tmp/serverspeeder.sh
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "serverspeeder" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		rm -rf /tmp/serverspeeder.sh
		rm -rf /tmp/91yunserverspeeder
		rm -rf /tmp/91yunserverspeeder.tar.gz
		echo -e "${Info} 锐速(Server Speeder) 安装完成 !" && exit 1
	else
		echo -e "${Error} 锐速(Server Speeder) 安装失败 !" && exit 1
	fi
}
Uninstall_ServerSpeeder(){
	echo "确定要卸载 锐速(Server Speeder)？[y/N]" && echo
	stty erase '^H' && read -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "已取消..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then
		chattr -i /serverspeeder/etc/apx*
		/serverspeeder/bin/serverSpeeder.sh uninstall -f
		echo && echo "锐速(Server Speeder) 卸载完成 !" && echo
	fi
}

# LotServer
Configure_LotServer(){
	echo && echo -e "你要做什么？
 ${Green_font_prefix}1.${Font_color_suffix} 安装 LotServer
 ${Green_font_prefix}2.${Font_color_suffix} 卸载 LotServer
————————
 ${Green_font_prefix}3.${Font_color_suffix} 启动 LotServer
 ${Green_font_prefix}4.${Font_color_suffix} 停止 LotServer
 ${Green_font_prefix}5.${Font_color_suffix} 重启 LotServer
 ${Green_font_prefix}6.${Font_color_suffix} 查看 LotServer 状态
 
 注意： 锐速和LotServer不能同时安装/启动！" && echo
	stty erase '^H' && read -p "(默认: 取消):" lotserver_num
	[[ -z "${lotserver_num}" ]] && echo "已取消..." && exit 1
	if [[ ${lotserver_num} == "1" ]]; then
		Install_LotServer
	elif [[ ${lotserver_num} == "2" ]]; then
		LotServer_installation_status
		Uninstall_LotServer
	elif [[ ${lotserver_num} == "3" ]]; then
		LotServer_installation_status
		${LotServer_file} start
		${LotServer_file} status
	elif [[ ${lotserver_num} == "4" ]]; then
		LotServer_installation_status
		${LotServer_file} stop
	elif [[ ${lotserver_num} == "5" ]]; then
		LotServer_installation_status
		${LotServer_file} restart
		${LotServer_file} status
	elif [[ ${lotserver_num} == "6" ]]; then
		LotServer_installation_status
		${LotServer_file} status
	else
		echo -e "${Error} 请输入正确的数字(1-6)" && exit 1
	fi
}
Install_LotServer(){
	[[ -e ${LotServer_file} ]] && echo -e "${Error} LotServer 已安装 !" && exit 1
	#Github: https://github.com/0oVicero0/serverSpeeder_Install
	wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh"
	[[ ! -e "/tmp/appex.sh" ]] && echo -e "${Error} LotServer 安装脚本下载失败 !" && exit 1
	bash /tmp/appex.sh 'install'
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "appex" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		echo -e "${Info} LotServer 安装完成 !" && exit 1
	else
		echo -e "${Error} LotServer 安装失败 !" && exit 1
	fi
}
Uninstall_LotServer(){
	echo "确定要卸载 LotServer？[y/N]" && echo
	stty erase '^H' && read -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "已取消..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then
		wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh" && bash /tmp/appex.sh 'uninstall'
		echo && echo "LotServer 卸载完成 !" && echo
	fi
}

#修改日志
Set_config_connect_verbose_info(){
	SSR_installation_status
	[[ ! -e ${jq_file} ]] && echo -e "${Error} JQ解析器 不存在，请检查 !" && exit 1
	connect_verbose_info=`${jq_file} '.connect_verbose_info' ${config_user_file}`
	if [[ ${connect_verbose_info} = "0" ]]; then
		echo && echo -e "当前日志模式: ${Green_font_prefix}简单模式（只输出错误日志）${Font_color_suffix}" && echo
		echo -e "确定要切换为 ${Green_font_prefix}详细模式（输出详细连接日志+错误日志）${Font_color_suffix}？[y/N]"
		stty erase '^H' && read -p "(默认: n):" connect_verbose_info_ny
		[[ -z "${connect_verbose_info_ny}" ]] && connect_verbose_info_ny="n"
		if [[ ${connect_verbose_info_ny} == [Yy] ]]; then
			ssr_connect_verbose_info="1"
			Modify_config_connect_verbose_info
			Restart_SSR
		else
			echo && echo "	已取消..." && echo
		fi
	else
		echo && echo -e "当前日志模式: ${Green_font_prefix}详细模式（输出详细连接日志+错误日志）${Font_color_suffix}" && echo
		echo -e "确定要切换为 ${Green_font_prefix}简单模式（只输出错误日志）${Font_color_suffix}？[y/N]"
		stty erase '^H' && read -p "(默认: n):" connect_verbose_info_ny
		[[ -z "${connect_verbose_info_ny}" ]] && connect_verbose_info_ny="n"
		if [[ ${connect_verbose_info_ny} == [Yy] ]]; then
			ssr_connect_verbose_info="0"
			Modify_config_connect_verbose_info
			Restart_SSR
		else
			echo && echo "	已取消..." && echo
		fi
	fi
}
Modify_config_connect_verbose_info(){
	sed -i 's/"connect_verbose_info": '"$(echo ${connect_verbose_info})"',/"connect_verbose_info": '"$(echo ${ssr_connect_verbose_info})"',/g' ${config_user_file}
}

# 封禁 BT PT SPAM
BanBTPTSPAM(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ban_iptables.sh && chmod +x ban_iptables.sh && bash ban_iptables.sh banall
	rm -rf ban_iptables.sh
}
# 解封 BT PT SPAM
UnBanBTPTSPAM(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ban_iptables.sh && chmod +x ban_iptables.sh && bash ban_iptables.sh unbanall
	rm -rf ban_iptables.sh
}

#-----SSR监控 有文件路径，注意修改
Set_crontab_monitor_ssr(){
	SSR_installation_status
	crontab_monitor_ssr_status=$(crontab -l|grep "ssrpa.sh monitor")
	if [[ -z "${crontab_monitor_ssr_status}" ]]; then
		echo && echo -e "当前监控模式: ${Green_font_prefix}未开启${Font_color_suffix}" && echo
		echo -e "确定要开启为 ${Green_font_prefix}ShadowsocksR服务端运行状态监控${Font_color_suffix} 功能吗？(当进程关闭则自动启动SSR服务端)[Y/n]"
		stty erase '^H' && read -p "(默认: y):" crontab_monitor_ssr_status_ny
		[[ -z "${crontab_monitor_ssr_status_ny}" ]] && crontab_monitor_ssr_status_ny="y"
		if [[ ${crontab_monitor_ssr_status_ny} == [Yy] ]]; then
			crontab_monitor_ssr_cron_start
		else
			echo && echo "	已取消..." && echo
		fi
	else
		echo && echo -e "当前监控模式: ${Green_font_prefix}已开启${Font_color_suffix}" && echo
		echo -e "确定要关闭为 ${Green_font_prefix}ShadowsocksR服务端运行状态监控${Font_color_suffix} 功能吗？(当进程关闭则自动启动SSR服务端)[y/N]"
		stty erase '^H' && read -p "(默认: n):" crontab_monitor_ssr_status_ny
		[[ -z "${crontab_monitor_ssr_status_ny}" ]] && crontab_monitor_ssr_status_ny="n"
		if [[ ${crontab_monitor_ssr_status_ny} == [Yy] ]]; then
			crontab_monitor_ssr_cron_stop
		else
			echo && echo "	已取消..." && echo
		fi
	fi
}
crontab_monitor_ssr(){
	SSR_installation_status
	check_pid
	if [[ -z ${PID} ]]; then
		echo -e "${Error} [$(date "+%Y-%m-%d %H:%M:%S %u %Z")] 检测到 ShadowsocksR服务端 未运行 , 开始启动..." | tee -a ${ssr_log_file}
		/etc/init.d/ssrmu start
		sleep 1s
		check_pid
		if [[ -z ${PID} ]]; then
			echo -e "${Error} [$(date "+%Y-%m-%d %H:%M:%S %u %Z")] ShadowsocksR服务端 启动失败..." | tee -a ${ssr_log_file} && exit 1
		else
			echo -e "${Info} [$(date "+%Y-%m-%d %H:%M:%S %u %Z")] ShadowsocksR服务端 启动成功..." | tee -a ${ssr_log_file} && exit 1
		fi
	else
		echo -e "${Info} [$(date "+%Y-%m-%d %H:%M:%S %u %Z")] ShadowsocksR服务端 进程运行正常..." exit 0
	fi
}
#开始SSR监控
crontab_monitor_ssr_cron_start(){
	crontab -l > "$file/crontab.bak"
	sed -i "/ssrpa.sh monitor/d" "$file/crontab.bak"
	echo -e "\n* * * * * /bin/bash $file/ssrpa.sh monitor" >> "$file/crontab.bak"
	crontab "$file/crontab.bak"
	rm -r "$file/crontab.bak"
	cron_config=$(crontab -l | grep "ssrpa.sh monitor")
	if [[ -z ${cron_config} ]]; then
		echo -e "${Error} ShadowsocksR服务端运行状态监控功能 启动失败 !" && exit 1
	else
		echo -e "${Info} ShadowsocksR服务端运行状态监控功能 启动成功 !"
	fi
}
#停止SSR监控
crontab_monitor_ssr_cron_stop(){
	crontab -l > "$file/crontab.bak"
	sed -i "/ssrpa.sh monitor/d" "$file/crontab.bak"
	crontab "$file/crontab.bak"
	rm -r "$file/crontab.bak"
	cron_config=$(crontab -l | grep "ssrpa.sh monitor")
	if [[ ! -z ${cron_config} ]]; then
		echo -e "${Error} ShadowsocksR服务端运行状态监控功能 停止失败 !" && exit 1
	else
		echo -e "${Info} ShadowsocksR服务端运行状态监控功能 停止成功 !"
	fi
}
#-----SSR监控

#更新软件源
Update_YUAN(){
    [[ ${release} = "centos" ]] && echo -e "${Error} 此命令只支持Debian/Ubuntu !" && exit 1
	echo -e "${Info} 开始更新软件源...."
	apt-get update
	echo -e "${Info} 软件源更新完毕！"	
}
#修改系统时间
Sys_time(){
	echo -e "${Info} 开始同步系统时间...."
	if [[ ${release} == "centos" ]]; then
		yum -y install ntp ntpdate
		tzselect
		ntpdate cn.pool.ntp.org
	else
		dpkg-reconfigure tzdata
		apt-get install ntpdate -y
		ntpdate cn.pool.ntp.org
	fi
	echo -e "${Info} 系统时间修改完毕，请使用 date 命令查看！"
}
#更新系统及软件
Update_SYS(){
	echo -e "${Info} 升级前请做好备份，如有内核升级请慎重考虑 ！"
	echo "确定要升级系统软件吗 ？[y/N]" && echo
	stty erase '^H' && read -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "已取消..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then		
		if [[ ${release} == "centos" ]]; then
			echo -e "${Info} 开始更新软件，请手动确认是否升级 ！"
			yum update
		else
			echo -e "${Info} 开始更新软件源...."
			apt-get update
			echo -e "${Info} 软件源更新完毕！"
			echo -e "${Info} 开始更新软件，请手动确认是否升级 ！"
			apt-get upgrade
		fi		
		echo -e "${Info} 更新软件及系统完毕，请稍后自行重启 ！"
	fi
}
#------------------------------------------其他功能结束

#------------------------------------------一键环境部署开始
One_key(){
	echo -e "
	1.更新系统
	2.更新时间
	3.安装libsodium
	4.一键封禁BT
	5.BBR（OpenVZ不可用）
	${Info} 每一项可单独自行安装
	"
	echo "确定要开始吗 ？[y/N]" && echo
	stty erase '^H' && read -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "已取消..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then		
		echo -e "${Info} 开始更新系统"
		Update_SYS
		echo -e "${Info} 开始更新时间"
		Sys_time
		echo -e "${Info} 安装libsodium"
		Install_Lib
		echo -e "${Info} 一键封禁BT"
		BanBTPT
		echo -e "${Info} BBR"
		Configure_BBR
		echo -e "${Info} 环境部署完毕，请重启VPS"
	fi
}
#libsodium安装判断
Install_Lib(){
	echo "确定要开始吗 ？[y/N]" && echo
	stty erase '^H' && read -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "已取消..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then
		Install_Libsodium
	fi	
}
#BT封禁判断
BanBTPT(){
	echo "确定要开始吗 ？[y/N]" && echo
	stty erase '^H' && read -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "已取消..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then
		BanBTPTSPAM
	fi	
}
#------------------------------------------一键环境部署结束

# 显示 菜单状态
menu_status(){
	if [[ -e ${ssr_folder} ]]; then
		check_pid
		if [[ ! -z "${PID}" ]]; then
			echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix}"
		else
			echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
		fi
		cd "${ssr_folder}"
	else
		echo -e " 当前状态: ${Red_font_prefix}未安装${Font_color_suffix}"
	fi
}
check_sys
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
action=$1
if [[ "${action}" == "clearall" ]]; then
	Clear_transfer_all
elif [[ "${action}" == "monitor" ]]; then
	crontab_monitor_ssr
else
	echo -e "
          SSR-Panel后端管理脚本${Green_font_prefix}[MOD_${sh_ver} 180808]${Font_color_suffix}
  ---- GitHub@ChennHaoo @hybtoy @ToyoDAdoubi @YihanH ----
 ${Tip} 本脚本为SSR-Panel后端一键搭建脚本，不适用于MuJSON多用户后端!!!!
 ${Tip} 安装位置：/usr/local/shadowsocksr

  ${Green_font_prefix}1.${Font_color_suffix} 安装 libsodium(chacha20 xchacha20)
  ${Green_font_prefix}2.${Font_color_suffix} 安装 ShadowsocksR
  ${Green_font_prefix}3.${Font_color_suffix} 更新 ShadowsocksR
  ${Green_font_prefix}4.${Font_color_suffix} 卸载 ShadowsocksR
————————————
  ${Green_font_prefix}5.${Font_color_suffix} 启动 ShadowsocksR
  ${Green_font_prefix}6.${Font_color_suffix} 停止 ShadowsocksR
  ${Green_font_prefix}7.${Font_color_suffix} 重启 ShadowsocksR
  ${Green_font_prefix}8.${Font_color_suffix} 查看 ShadowsocksR 日志
————————————
  ${Green_font_prefix}9.${Font_color_suffix} 修改SSH端口 （如有宝塔面板，不建议在此修改）
  ${Green_font_prefix}10.${Font_color_suffix} 一键环境部署
  ${Green_font_prefix}11.${Font_color_suffix} 其他功能
 "
	menu_status
	echo && stty erase '^H' && read -p "请输入数字 [1-11]：" num
case "$num" in
	1)
	Install_Libsodium
	;;
	2)
	Install_SSR
	;;
	3)
	Update_SSR
	;;
	4)
	Uninstall_SSR
	;;
	5)
	Start_SSR
	;;
	6)
	Stop_SSR
	;;
	7)
	Restart_SSR
	;;
	8)
	View_Log
	;;
	9)
	Install_SSHPOR
	;;
	10)
	One_key
	;;
	11)
	Other_functions
	;;		
	*)
	echo -e "${Error} 请输入正确的数字 [1-11]"
	;;
esac
fi