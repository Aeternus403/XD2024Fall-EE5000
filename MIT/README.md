### 一些问题记录

#### 找不到distutils

python3.10后删去了distutils，先确认正在使用的python版本：在Liteos终端输入
```bash
python --version
```
正常应该是3.7.X

**如果显示的是更高版本，则需要降至3.7**：
 -  打开设置>系统>高级系统设置>环境变量
 - 在系统变量里找到Path，双击，查看关于python的路径。确认是否添加了3.7的路径，且位于更高版本python解释器之上。如果未添加，新建并输入python37目录。以下是示例：
 ```PATH
 C:\Users\Aurora\AppData\Local\Programs\Python\Python37
 C:\Users\Aurora\AppData\Local\Programs\Python\Python37\Scripts
 ```
 - 添加后把python37路径移至其他解释器路径之上
 - 保存、返回Liteos。再次查看python版本。此时应该会看到：Python 3.7.6
 - 如果依旧显示的是高版本的python，尝试重启电脑。（一般设置完环境变量是要重启激活的，但我这边不重启也可以。没解决的可以试一下）

猜测原因是电脑以前装过高版本的python解释器，且环境变量优先级高于3.7的，在使用脚本配置环境的时候，相关的package没有装到3.7里，而是下载到了高版本中。所以当换回python37再次编译，收到多个No module named "XXX" 报错。一个个装回去就好了。以distutils为例：

**如果python版本正确，进行下一步**

**安装distutils**

打开cmd，输入
```bash
curl https://bootstrap.pypa.io/pip/3.7/get-pip.py -o get-pip.py
python get-pip.py
```
安装完成后，在python交互环境里输入
```python
import distutils
print(distutils.__file__)
```
可以看到输出distutils所在路径，类似Python37\lib\distutils\ __init__.py.再次编译，依旧找不到distutils，此处是scons的问题。

```gpt
Me:
我在liteos里确认python版本是对的，你的意思是即便如此scons也可能用不对的版本的python吗？
GPT:
是的，即使在 LiteOS 中确认了 Python 版本是正确的，`scons` 仍然可能使用不同版本的 Python。这种情况通常发生在系统中安装了多个 Python 版本时。以下是一些步骤，可以帮助你检查 `scons` 实际上使用的是哪个 Python 版本：
```
#### Scons
检查scons --version
```bash
SCons by Steven Knight et al.: SCons: v4.8.1.08661ed4c552323ef3a7f0ff1af38868cbabb05e, Tue, 03 Sep 2024 17:46:32 -0700, by bdbaddog on M1Dog2021 SCons path: ['C:\\Python312\\Lib\\site-packages\\SCons'] Copyright (c) 2001 - 2024 The SCons Foundation ohno
```
他依旧用的是python312。GPT给了几条解决方案，可以问它。但在我这里无一成功，最终删除所有其他版本的python路径（回头记得加回来）。  
再次scons --version
```bash
SCons by Steven Knight et al.:
        SCons: v4.8.1.08661ed4c552323ef3a7f0ff1af38868cbabb05e, Tue, 03 Sep 2024 17:46:32 -0700, by bdbaddog on M1Dog2021
        SCons path: ['C:\\Users\\Aurora\\AppData\\Local\\Programs\\Python\\Python37\\lib\\site-packages\\SCons']
Copyright (c) 2001 - 2024 The SCons Foundation
```
Bingo。（但非常不稳定，在之后的编译中，第一次编译依旧会报错找不到scons，但再点一次就不报错了???不确定是不是没有彻底解决此问题，配置Scons path的文件到底在哪里，找到的请告诉我thank u）  
10.19更新：重启liteos、清除编译，解决scons报错。
