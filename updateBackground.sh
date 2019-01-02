#!/bin/bash
# @author 周健东
# @date 2018-09-26 09:59:59
# @update 2019-01-02 10:17:51
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
        sourceFunction='bingWeb'
    ;;
    '-wr'|'--wallpaperupRandom')
        pageNumber=$(random 1 500) # 官网的页数,官网一共500页
        numberRow=$(random 1 24) # 当前页的第几个图片(一共是24个图片每页)
        sourceFunction="wallpaperupWeb ${pageNumber} ${numberRow}"
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
    echo '=================================================='
    return 0
}

sleep ${sleepSecond}

# 存放图片路径
backgroundsPath="${HOME}/.local/share/backgrounds/"
if [ ! -d ${backgroundsPath} ];then
    mkdir -p ${backgroundsPath}
fi

pushd ${backgroundsPath}


# bing壁纸,每天更换的,尺寸是1920*1080
# 下载以后返回图片名称
bingWeb(){
    imageName='bing'$(date +'%Y%m%d')'_1920_1080.jpg'
    if [ -f "${imageName}" ];then
        exit 2 # 文件已经存在
    fi
    curl 'http://api.yingjoy.cn/pic/?t=bing&w=1920' > ${imageName}
    echo ${imageName}
    return 0
}

# www.wallpaperup.com网站的2K高清壁纸,随机10页里面的随机图片
# 下载以后返回图片名称
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

    webImageName=${webImgUrl##*/}

    wget -U NoSuchBrowser/1.0 ${webImgUrl}
    if [ $? -ne 0 ];then
        echo 'wget error'
        exit 2
    fi

    echo "${webImageName}"
    return 0
}


imageName=$(${sourceFunction}) # 返回本地文件名称
if [ $? == 2 ];then
    echo '文件已经存在,不需要下载了'
    exit 9
fi
imagePath=${backgroundsPath}${imageName} # 返回本地文件全路径名称

standardLogOut

gsettingsBackground=`gsettings get org.gnome.desktop.background picture-uri`;
if [ -f "${imagePath}" ];then
    if [ "${gsettingsBackground}" == "'file:${imagePath}'" ];then
        echo 'file exists,path:'${imagePath}
        exit 6
    fi
fi

gsettings set org.gnome.desktop.background picture-uri "file:${imagePath}"
if [ $? -ne 0 ];then
    echo 'gsettings error'
    exit 4

fi

exit 0
