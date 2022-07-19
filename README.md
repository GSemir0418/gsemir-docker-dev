> 目标：使用 docker 搭建自用开发环境

# 1 docker 核心概念：

- 核心概念主要包括`dockerfile`、`container`、`image`、`volume`

- `dockerfile`

  - docker 构建 image 的**说明书**

  ```dockerfile
  FROM 指定镜像tag
  RUN 运行命令
  ADD 复制宿主机文件
  ENV 添加环境变量
  WORKDIR 访问容器时的初始目录
  ```

- `image`(镜像)
  - 相当于一张**系统盘**
- `container`(容器)
  - 相当于一台**虚拟机**
- `volume`(数据卷)
  - 相当于虚拟机的硬盘，可以用来**持久化**容器内数据
  - 因为每次 rebuild 都相当于重装系统，其内部数据会被清空
  - `docker volume create [name]`创建数据卷

# 2 docker 常用命令

- `build`

  - 基于`dockerfile`构建 image

  ```sh
  $ # docker build [dockerfile目录] -t [标签名]
  $ docker build . -t xxx/yyy:0.1
  ```

  - 查看与删除 image

  ```sh
  $ docker image ls
  $ docker image rm [tag]
  ```

- `run`

  - 运行 image 启动 container

  ```sh
  $ docker run -dit [image_tag] --name [container_name] -p [容器端口:宿主机端口] -e [环境变量=值] --network=net1
  $ docker run -v volume_name:/容器内需持久化的路径
  ```

  - -d 表示 deamon，即启动后不需自动关闭
  - 以 mysql 容器为例

  ```sh
  $ docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.7.38
  ```

- `exec`

  - 访问 container

  ```sh
  $ docker exec -it [container_id] bash/zsh
  ```

  - 退出 container

  ```sh
  $ exec / ctrl + D
  ```

- `pull`

  - 拉取镜像

  ```sh
  $ docker pull alpine:latest
  ```

- `start`

  - `docker ps -a`查看全部容器

  - `docker start [container_id]`启动容器

- `stop`

  - 同 start

- `logs`
  - `docker logs container_id`查看容器日志

# 3 docker 连接数据库

- 创建局域网

```sh
$ docker network create net1
```

- 创建数据库容器，指定局域网

```sh
$ docker run -d \
		容器名称
    --name db-for-test \
    环境变量
    -e POSTGRES_USER=gsemir \
    -e POSTGRES_PASSWORD=123456 \
    -e POSTGRES_DB=test_dev \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
   	关联数据卷
    -v mangosteen-data:/var/lib/postgresql/data \
    指定网络 与服务端容器在同一网络下 此时容器的名称就可以作为ip地址供服务端访问
    --network=net1 \
    镜像tag
    postgres:14
```

- 服务端安装相关库，并连接到局域网

```sh
$ apk --no-cache add postgresql-libs
```

- 开启数据库容器，完成数据库连接

# 4 搭建个人开发环境

- 镜像目录

```sh
.
├── .devcontainer
│		└── devcontainer.json		# 配置容器运行启动时的参数
├── tmp											# 宿主与容器共享目录
├── .Dockerfile							# mac/linux版本的dockerfile
├── windows.Dockerfile			#	windows版本的dockerfile
├── .zshrc									#	容器zsh配置
├── zsh-autosuggestions			#	zsh插件
└── zsh-syntax-highlighting	# zsh插件
```

- devcontainer.json
  - `devcontainer.json`中的配置项，实际上相当于运行`docker run`命令的配置项

```json
{
  "name": "GSemirDev",
  "dockerFile": "../.Dockerfile",
  "extensions": ["dbaeumer.vscode-eslint", "esbenp.prettier-vscode"],
  "runArgs": [
    "--network=network1", // 方便连接数据库
    "--dns=114.114.114.114",
    "--privileged" // docker in docker时会用到
  ],
  "containerEnv": {
    "DISPLAY": "host.docker.internal:0.0"
  },
  "mounts": [
    "source=g-repos,target=/root/repos,type=volume",
    "source=g-zsh-plugin,target=/root/.oh-my-zsh/custom/plugins,type=volume"
  ],
  "remoteUser": "root"
}
```

- dockerfile

```dockerfile
FROM alpine:latest@sha256:c3c58223e2af75154c4a7852d6924b4cc51a00c821553bbd9b3319481131b2e0
WORKDIR /tmp
RUN rm -rf /etc/apk/repositories &&\
    touch /etc/apk/repositories &&\
    echo 'https://mirrors.aliyun.com/alpine/v3.16/main' >> /etc/apk/repositories &&\
    echo 'https://mirrors.aliyun.com/alpine/v3.16/community' >> /etc/apk/repositories &&\
    apk update &&\
    apk --no-cache --update add nodejs git zsh curl yarn npm tree
# zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ENV SHELL /bin/zsh
ADD zsh-autosuggestions ~/.oh-my-zsh/custom/plugins
ADD zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins
ADD .zshrc /root/.zshrc
# js dev
RUN npm config set registry http://registry.npm.taobao.org/ &&\
    yarn config set registry http://registry.npm.taobao.org/
RUN npm i -g pnpm &&\
    pnpm config set registry http://registry.npm.taobao.org/
```

- 上传自己的`image`到`docker hub`

  1. 构建 image，指定 tag 名称

  ```sh
  $ docker build . -t gsemir/dev-env:0.1
  ```

  2. 登录 docker

  ```sh
  $ docker login
  ```

  3. push

  ```sh
  $ docker push gsemir/dev-env:0.1
  ```

  4. 修改 tag 版本为 latest

  ```sh
  $ docker tag gsemir/dev-env:0.1 gsemir/dev-env:latest
  ```

  5. 再次 push

  ```sh
  $ docker push gsemir/dev-env:latest
  ```
