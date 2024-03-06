1.  关于git报错
```{.cs}
    git config --global --unset http.proxy
    git config --global --unset https.proxy
```

2.  安装brew
```{.cs}
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3.  设置brew镜像安装软件
```{.cs}
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    brew update
    brew install git
```
