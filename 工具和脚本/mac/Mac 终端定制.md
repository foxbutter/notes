
## 1. 安装 Iterm2

```sh
brew cask install iterm2
```

## 2. 安装 oh-my-zsh

```sh
# install
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# uninstall
uninstall_oh_my_zsh
```

## 3. 配置 iTerm2

### 1. 字体

使用下面的主题，需要 Meslo 字体支持，要不然会出现乱码的情况

\>Preferences>Profiles>Text>Font

选择 Meslo LG M for Powerline 字体

![图示](https://raw.githubusercontent.com/foxbutter/my-pics/main/cut/iterm2_font_setting.png?token=AGD554MWNPB6WYIG36HI5BTDEP26O)


### 2. 配色方案

Iterm2 已经内置 [Solarized主题](http://ethanschoonover.com/solarized)，直接设置：

![图示](https://raw.githubusercontent.com/foxbutter/my-pics/main/cut/iterm2_color_setting.png?token=AGD554JXTL7IQM7L7DKZKSLDEPZ3Y)

### 3. 主题

```sh
vim ~/.zshrc
# 将 ZSH_THEME 后面字段改为 agnoster
```

### 4. 插件

- Git

  - 命令内容可以参考`cat ~/.oh-my-zsh/plugins/git/git.plugin.zsh`

    ```sh
    gapa    git add --patch
    gc!    git commit -v --amend
    gcl    git clone --recursive
    gclean    git reset --hard && git clean -dfx
    gcm    git checkout master
    gcmsg    git commit -m
    gco    git checkout
    gd    git diff
    gdca    git diff --cached
    gp    git push
    grbc    git rebase --continue
    gst    git status
    gup    git pull --rebase
    ```

- 语法高亮

  - 方式一：

    ```sh
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    ```
  - 方式二：
    ```sh
    brew install zsh-syntax-highlighting
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    ```
  
- 自动补全

	- 方式一：
	
	  ```sh
	  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	  ```

修改配置文件：.zshrc

```sh
vim .zshrc
###
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)
###
source ~/.zshrc
```

### 5. 用户主机名前缀

```sh
vim ~/.oh-my-zsh/themes/agnoster.zsh-theme

# Context: user@hostname (who am I and where am I)
```

## Dock 栏属性设置

Mac 中为了获得更大的可视空间，在不使用 Dock 时我们可以隐藏它。若要查看隐藏的 Dock，可以将指针移到 Dock 所在屏幕的边缘。但是这个显示速度存在了一定的延迟，为了加速这个过程，我们可以使用一段命令行，让你的隐藏 Dock 弹出的时候更加的顺滑流畅：

使用后的效果，可以说是非常明显了，再也不会有在「挤牙膏」的感觉。

![动图](https://picx.zhimg.com/50/v2-e3b1e39a207cf2bbfc071893b496e60c_720w.webp?source=1940ef5c)

如果在你的使用下，Dock 栏上摆满了各类 App，却发现这不是自己想要的结果。你可以通过终端来重置你的 Dock 栏，让它回到最开始的状态：

```sh
# 设置
defaults write com.apple.Dock autohide-delay -float 0 && killall Dock

# 恢复设置
defaults delete com.apple.dock; killall Dock
```

## 让屏幕亮的更久

Mac 在运行一段时间后，会自动进入睡眠。如果大家不想 Mac 那么快的进入书面，可以采用一些第三方软件来达到此目的。其实与其下载一个软件占用 Mac 上精贵的储存，不如使用一段命令行就可以解决这些问题了。下方命令行中的 3600 单位是秒，即你希望多长时间内你的 Mac 不会进入睡眠：

```sh
caffeinate -t 3600
```