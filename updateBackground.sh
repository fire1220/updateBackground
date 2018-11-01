#!/bin/bash
# @author 周健东
# @date 2018-09-26 09:59:59
# Ubuntu和其他Linux系统更换壁纸脚本,
# gnome和unity桌面系统测试过
# 目前支持bing.com和wallpaperup.com两个网站的资源
# 使用到的非系统自带脚本命令有 curl 
# debian和Ubuntu系列可以用 sudo apt install curl 或 sudo apt-get install curl 命令安装
# redhat系列可以用 sudo yum install curl安装
# 错误解决方法
# GLib-GIO-Message: Using the 'memory' GSettings backend.  Your settings will not be saved or shared with other applications.
# wgb@wgb:~$ 
# 上面的解决办法，只是暂时的，长期的解决办法为：
#  wgb@wgb:~$ sudo gedit ~/.bashrc
# 然后把粘贴在最后一行export GIO_EXTRA_MODULES=/usr/lib/x86_64-linux-gnu/gio/modules/
# 随机背景接口:http://api.yingjoy.cn/pic/?t=random&w=1920
# bing背景接口:http://api.yingjoy.cn/pic/?t=bing&w=1920
arguments=$1 # 参数表示选择的来源
# 休眠时间(秒)
sleepSecond=60
if [ -n "$2" ];then
    sleepSecond=$(echo $2|awk -v sleepSecond=${sleepSecond} '{print $0~/^[0-9]*$/?$0:sleepSecond}')
fi
helpDoc(){
    echo -e "Usage: ${0##*/} [\033[33mstring\033[0m options] [\033[33mint\033[0m sleepSecond]"
    echo -e "options:"
    echo -e "\t-h, --help\t\t\thelp"
    echo -e "\t-b, --bing\t\t\tsource : bing.com"
    echo -e "\t\t\t\t\t每日最新壁纸,尺寸是1920*1080"
    echo -e "\t-wr, --wallpaperupRandom\tsource : wallpaperup.com"
    echo -e "\t\t\t\t\trandom"
    echo -e "\t\t\t\t\t随机更换壁纸,尺寸是2048*1080"
    echo -e "sleepSecond:(default 60)\t\tsleep time"
    echo 'Example:'
    echo -e "\t${0##*/} -wr 0"
    echo -e "\t${0##*/} -b 0"
    echo 'image save path:'
    echo -e "\t$HOME/.local/share/backgrounds"
    exit 0
}
# 随机函数
random(){
    local min=$1
    local max=$2
    local range=$max-$min
    echo $(($(date +'%s%N') % ${range} + ${min}))
    return 0
}
case $arguments in
    '-h'|'--help')
        helpDoc
    ;;
    '-b'|'--bing')
        isUpdateName=1
        sourceName='bing'
        sourceFunction='bingWeb'
        imageName=${sourceName}$(date +'%Y%m%d')'_1920_1080.jpg'
    ;;
    '-wr'|'--wallpaperupRandom')
        isUpdateName=0
        sourceName='wallpaperupRandom'
        pageNumber=$(random 1 500) # 官网的页数,官网一共500页
        numberRow=$(random 1 24) # 当前页的第几个图片(一共是24个图片每页)
        sourceFunction="wallpaperupWeb ${pageNumber} ${numberRow}"
        # imageName=${sourceName}$(date +'%Y%m%d%H%M%S')'_2048_1080.jpg'
        imageName='';
    ;;
    *)
        helpDoc
    ;;
esac
# 输出日志信息
standardLogOut(){
    echo $(date)
    echo "pageNumber : " $pageNumber
    echo "numberRow : " $numberRow
    echo "webImageUrl : " $webImageUrl
    echo 'webImageName : '${webImageName} 
    echo 'backgroundsPath : '${backgroundsPath}
    echo 'isUpdateName : '${isUpdateName}
    echo 'imageName : '${imageName}
    echo '=================================================='
    return 0
}
# 存放图片路径
backgroundsPath="${HOME}/.local/share/backgrounds/"
imagePath=${backgroundsPath}${imageName}
if [ ! -d ${backgroundsPath} ];then
    mkdir -p ${backgroundsPath}
fi
if [ -f "${imagePath}" ];then
    echo 'file is exists'
    standardLogOut
    exit 5
fi
sleep ${sleepSecond}
# bing壁纸,每天更换的,尺寸是1920*1080
bingWeb(){
    # bing官方地址
    webUrl='https://www4.bing.com'
    # bing图片地址路径
    webImgUrl=$(echo ${webUrl}|xargs curl |grep '</html>'|awk -F'["]' -v webUrl=${webUrl} '{print webUrl$2}')
    echo ${webImgUrl}
    return 0
}
# www.wallpaperup.com网站的2K高清壁纸,随机10页里面的随机图片
wallpaperupWeb(){
    # wallpaperup官方地址
    pageNumber=$1 # 官网的页数,官网一共500页
    numberRow=$2 # 当前页的第几个图片(一共是24个图片每页)
    # pageNumber=$(random 1 500) # 官网的页数,官网一共500页
    # numberRow=$(random 1 24) # 当前页的第几个图片(一共是24个图片每页)
    webUrl='https://www.wallpaperup.com/resolution/2k/'$pageNumber
    # wallpaperup图片地址路径
    # webImgUrl=$(echo ${webUrl}|xargs curl|grep -oe '<img[^>]*>'|awk -v numberRow=${numberRow} '{if(NR==numberRow){print $0}}'|grep -o -e 'https://www\.wallpaperup\.com[^\.]*\.jpg'|head -n1|sed 's/-187/-1400/')
    webImgUrl=$(echo ${webUrl}|xargs curl|grep -oe '<img[^>]*>'|awk -v numberRow=${numberRow} '{if(NR==numberRow){print $0}}'|grep -o -e 'https://www\.wallpaperup\.com[^\.]*\.jpg'|head -n1|sed 's/-187//')
    echo "${webImgUrl}"
    return 0
}
webImageUrl=$(${sourceFunction}) # web图片地址路径
webImageName=${webImageUrl##*/}
pushd ${backgroundsPath}
standardLogOut
if [ $isUpdateName -eq 0 ];then
    imagePath=${imagePath}$webImageName
    if [ -f $imagePath ];then
        gsettings set org.gnome.desktop.background picture-uri "file:${imagePath}"
        if [ $? -ne 0 ];then
            echo 'gsettings error'
            exit 4
        fi
        exit 0
    fi
fi
wget -U NoSuchBrowser/1.0 ${webImageUrl}
if [ $? -ne 0 ];then
    echo 'wget error'
    exit 2
fi
if [ $isUpdateName -eq 1 ];then
    mv ${webImageName} ${imageName}
    if [ $? -ne 0 ];then
        echo 'mv error'
        exit 3
    fi
fi
if [ ! -f "${imagePath}" ];then
    echo 'rename error'
    exit 6
fi
gsettings set org.gnome.desktop.background picture-uri "file:${imagePath}"
if [ $? -ne 0 ];then
    echo 'gsettings error'
    exit 4
fi
exit 0


