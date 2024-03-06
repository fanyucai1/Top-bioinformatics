# python3

1.  安装python3
```{.cs}
mkdir -p /usr/local/openssl/
cd /software/ && tar -zxvf openssl-1.1.1m.tar.gz
cd /software/openssl-1.1.1m/ && ./config --prefix=/usr/local/openssl
make -j20
make install
mv /usr/bin/openssl /usr/bin/openssl.old
mv /usr/lib64/openssl /usr/lib64/openssl.old
ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/openssl/include/openssl /usr/include/openssl
echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
ldconfig -v
cd /software/python3 && tar xvf Python-3.10.5.tgz && cd Python-3.10.5 && ./configure --prefix=/software/python3/Python-v3.10.5 --with-openssl=/usr/local/openssl && make -j20 && make install
```

2.  sys.path[0]为python脚本所的位置os.getcwd()为当前工作目录

3.  指定镜像快速安装python模块示例：
```{.cs}
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple numpy
```

4. [学习资料http://python3-cookbook.readthedocs.io/zh_CN/latest/index.html](http://python3-cookbook.readthedocs.io/zh_CN/latest/index.html)

5.  获得命令行输出
```{.cs}
cmd=os.popen('whoami')
user=cmd.read()
user=user.strip()
```

6.  字符匹配
```{.cs}
datepat = re.compile(r'(\d+)/(\d+)/(\d+)’)
m = datepat.match('11/27/2012’)
>>> m.group(0)
'11/27/2012'
>>> m.group(1)
'11'
>>> m.group(2)
'27'
>>> m.group(3)
‘2012'
```

7.  获得当前时间
```{.cs}
t=time.asctime()
print(t)
```

8.  随机产生字符串作为文件名
```{.cs}
unique_filename = str(uuid.uuid4())
```

9.  数组去重并排序
```{.cs}
set1=sorted(list(set(array)),reverse=True)
```
10. 判断文件大小
```{.cs}
size=os.path.getsize()
```

11. enumerate枚举
```{.cs}
 a = ['a', 'b', 'c', 'd', 'e']
>>> for index, item in enumerate(a): print index, item
```