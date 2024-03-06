
# 使用说明

1.**pandoc软件安装**

[pandoc:https://pandoc.org/installing.html](https://pandoc.org/installing.html)

2.**latex软件安装**

[LaTeX:https://www.latex-project.org/get/](https://www.latex-project.org/get/)

3.**[markdown语法学习:https://dillinger.io/](https://dillinger.io/)**

4.**[pandoc的markdown语法:https://www.cnblogs.com/baiyangcao/p/pandoc_markdown.html](https://www.cnblogs.com/baiyangcao/p/pandoc_markdown.html)**

5.**markdown convert pdf**

```{.cs}
pandoc README.md --pdf-engine=xelatex -o README.pdf --metadata-file metadata.yaml --highlight-style tango
```

6.**转换过程中解决中文支持可参考：**

<https://blog.csdn.net/weixin_44908818/article/details/108659018>
