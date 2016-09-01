# VKDevTooL

[App内调试工具 VKDevTool](https://github.com/Awhisper/VKDevTool)

允许在

- 在脱离Xcode Debug的情况下
- 黑盒真机情况下

进行App的调试工作，包括：

- 调试内存对象
- 打印内存数据
- 修改UI
- 查看NSLog
- 查看所有网络请求记录
- 查看App界面层级

方便在黑盒测试+内部体验的环境下，发现Bug后，直接在Bug现场调试内存，分析问题


>这个工具在早期的VKDebugConsole的基础上完全推翻重做了，核心思路都不变，只是重新整理了工具的使用方式，工具的界面呈现，工具的模块划分，模块化可扩展支持
>
>[旧文档链接 -- VKDebugConsole App黑盒控制台](http://awhisper.github.io/2016/05/22/VKDebugConsole-App%E9%BB%91%E7%9B%92%E6%8E%A7%E5%88%B6%E5%8F%B0/)

# 使用介绍
<!--more-->

## 工程配置

- 将`VKDevTool`文件夹拖入工程文件
- 将`VKDevToolLogHeader.h`写入pch，以便开启NSLog的动态拦截记录，不导入ConsoleLog模块无法捕获NSLog
- 可以修改`VKDevToolDefine.h`中的`#ifdef DEBUG`来进行自定义的编译控制，如果不修改，默认Debug模式下VKDevTool工具才有效

## 编写代码

```objectivec
[VKDevTool enableDebugMode];
```

一行代码即可开启DevTool的功能，该功能内部有编译控制，Release版本会自动失效，无需使用者在这行代码外围在套一层`#ifdef DEBUG`


## 如何使用

进行完工程配置与写入代码之后可以通过如下方式，在App内打开工程模式菜单

- 模拟器下，使用键盘command+x快捷键唤起菜单
- 真机运行下，使用摇一摇唤起菜单


![main](http://o7bhtwerg.bkt.clouddn.com/devtoolmain.jpeg)


主菜单模块包含4个模块
- DebugScript
- ConsoleLog
- NetworkLog
- ViewHierarchy3D

>VKDevTool采取模块化设计，每个模块Module都可以独立分拆分离，同时支持用户定义扩展自己的模块，图中的额外2个模块为自定义模块


## 黑盒调试功能DebugScript

- 在主菜单中选择`DebugScript`
- 按提示点选任意一个界面元素
- 进入代码控制台
- 上面是代码输入框
- 下面是输出框

![main](http://o7bhtwerg.bkt.clouddn.com/devscript1.jpeg)


以上是一个预览界面，上方输入的代码都是基于JSPatch的，所有JSPatch的语法规则这里都一模一样可以使用，戳这里看JSPatch如何使用 [JSPatch语法](https://github.com/bang590/JSPatch/wiki)

- 真机摇一摇 or 模拟器Command+X 可以唤起DebugScript模块子菜单
- 模拟器下如果输入过代码Command+X可能不好使，通过模拟器菜单`Shake Gesture`功能模拟摇一摇，依旧可以唤起

子菜单包含以下几个功能

- `GetTarget`:自动往输入框中输入getTarget的脚本代码，执行以后print Target信息，便于后续直接调试target的任意内存数据和执行方法
- `Get TargetVC`:自动往输入框中输入getTargetVC的脚本代码，执行以后print Target所在的当前vc的信息，便于后续直接调试targetVC的任意内存数据和执行方法
- `ChangeTarget`:自动往输入框中输入切换所选target的代码，执行后，重新返回选择target界面
- `clearInput`

- `getParentVC(v)`输入一个View，获取所在的VC
- `print(item)`输出一个对象到控制台，单独处理了Label和View的描述信息，更加方便直观（可以扩展更多单独处理的对象类型）
- `changeSelect()`重新手选获取新target
- `exit()`退出控制台
- `clearOutput()`清空控制台输出区
- `clearInput()`清空控制台输入区

先大体看一下GIF动画如何使用，此处的Gif是旧的Gif，新版本的颜色样式都已经调整，但是用法完全不变

![git](http://ww2.sinaimg.cn/mw690/678c3e91jw1f4cejgkcipg20900gfasa.gif)



TODO LIST:
consolelog 加入搜索功能（搜索+高亮看起来是个大坑T_T）

摇一摇太麻烦了，准备加入音量键捕捉

## 扩展接口

```objectivec
[VKDevTool changeNetworktModuleFilter:@“xxxxx”];
```
这个接口控制网络请求HookLog的过滤器，只拦截含有xxxx字符串的http网络请求，同时在DevTool内还可以通过菜单，修改网络拦截过滤器

如果全都拦截，可以省略


```objectivec
[VKDevTool registKeyName:@"custom module name" withExtensionFunction:^{
    //todo your code
}];
```
VKDevTool采取模块化设计，每个模块Module都可以独立分拆分离，同时支持用户定义扩展自己的模块

主菜单模块包含4个模块

- DebugScript
- ConsoleLog
- NetworkLog
- ViewHierarchy3D

这个接口用于给VKDevTool扩展主菜单模块，可以省略不写，只使用自带的4个模块。
