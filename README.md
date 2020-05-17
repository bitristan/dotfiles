# dotfiles
My personal dotfiles

## Intellij系列编辑器使用IdeaVim
Vim文本编辑是最高效的文本编辑操作方式，结合JetBrains公司的[IdeaVim](https://github.com/JetBrains/ideavim)插件，我们可以实现非常高效的文本编辑以及编辑器相关的各种常用操作，掌握以下几个要点，可以让你的编程有飞一般的感觉

### Vim文本编辑
这个不必详细说了，网上很多关于vim编辑器的资料都可以详细了解，必须掌握vim文件编辑的各种基本操作

### 通过命令模式与编辑器交互
在IdeaVim中，进入命令模式，输入`:action COMMAND`可以执行IntelliJ编辑器的一些内置命令。

在绝大部分编辑器中，操作菜单其实都是操作编辑器的内置命令，例如点击`File->New->New Project`其实就是执行了一条`NewProject`的命令。我们在命令模式下执行`:action NewProject`，其实就是完成了跟`File->New->New Project`菜单一样的工作。Vim/Emacs编辑器之所以强大就是可以通过命令完成基本所有的事情，也就为脱离鼠标操作提供了基础。

回到IntelliJ，如何查看编辑器支持的内置命令呢，其实IdeaVim的github官方文档已经比较详细了
1. 命令模式执行`:actionlist`即可列出所有命令
2. 支持模糊查询，例如`:actionlist goto`可以列出所有包含goto的指令，不区分大小写
3. 支持根据按键查询，例如从编辑器的菜单上可以看到`Navigate->Back`的快捷是`Ctrl-Alt-left`，那么输入`:actionlist <A-C-left>`即可看到这个按键触发的命令为`Back`

### 核武器：结合Vim的Leader Key定制快捷键
Vim Leader Key相关的知识请自行google搜索。例如我加入了以下三行配置，分别是进入我觉得比较有用的几个模式，但是如果点菜单实在是太麻烦了，设置之后在命令模式直接连续按一下`,tf`三个键，就会进入全屏，跟点击了菜单`View->Appearance->Enter Full Screen`的效果是一样的。举一反三，基本上所有的操作都可以自定义自己喜欢的快捷键，当然我们一般只需要设置一些平常最常用的就行了，设置太多没必要也记不住。
```
" 执行菜单 View->Appearance->Enter Full Screen
noremap ,tf :action ToggleFullScreen<CR>
" 执行菜单 View->Appearance->Enter Distraction Mode
noremap ,td :action ToggleDistractionFreeMode<CR>
" 执行菜单 View->Appearance->Enter Presentation Mode
noremap ,tp :action TogglePresentationMode<CR>
```

