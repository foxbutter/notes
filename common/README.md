
# 常用内容

## 常用配置
- [Git 多租户/用户名 按目录配置](gitconfig.md)

## 常用脚本

### Python

1. [pip 设置镜像源](https://mirrors.tuna.tsinghua.edu.cn/help/pypi/)
```sh
# 临时使用
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple some-package

# 设为默认
python -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

```

2. 