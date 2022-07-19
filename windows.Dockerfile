FROM alpine:latest@sha256:4ff3ca91275773af45cb4b0834e12b7eb47d1c18f770a0b151381cd227f4c253

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