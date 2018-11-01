# updateBackground
## @author 周健东
## @date 2018-09-26 09:59:59
## 使用场景
+ Ubuntu和其他Linux系统更换壁纸脚本,
+ gnome和unity桌面系统测试过
+ 目前支持bing.com和wallpaperup.com两个网站的资源
+ 使用到的非系统自带脚本命令有 curl 
+ debian和Ubuntu系列可以用 sudo apt install curl 或 sudo apt-get install curl 命令安装
+ redhat系列可以用 sudo yum install curl安装
+ 个别出现错误解决方法
+ wgb@wgb:~$ sudo gedit ~/.bashrc
+ 然后把粘贴在最后一行export GIO_EXTRA_MODULES=/usr/lib/x86_64-linux-gnu/gio/modules/
+ 随机背景接口:http://api.yingjoy.cn/pic/?t=random&w=1920
+ bing背景接口:http://api.yingjoy.cn/pic/?t=bing&w=1920
## 使用方法

        Usage: updateBackground.sh [string options] [int sleepSecond]
        options:
            -h, --help          help
            -b, --bing          source : bing.com
                            每日最新壁纸,尺寸是1920*1080
            -wr, --wallpaperupRandom    source : wallpaperup.com
                            random
                            随机更换壁纸,尺寸是2048*1080
        sleepSecond:(default 60)        sleep time
        Example:
            updateBackground.sh -wr 0
            updateBackground.sh -b 0
        image save path:
            /home/fire/.local/share/backgrounds
