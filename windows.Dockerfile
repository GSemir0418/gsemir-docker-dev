FROM alpine:latest@sha256:4ff3ca91275773af45cb4b0834e12b7eb47d1c18f770a0b151381cd227f4c253

VOLUME [ "/root/.ssh", "/root/repos","/root/.oh-my-zsh/custom/plugins"]
WORKDIR /tmp
RUN apk update &&\
    apk --no-cache --update add nodejs openssh tree npm yarn git zsh curl
# RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash 
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ENV SHELL /bin/zsh 
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
RUN git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# ADD zsh-autosuggestions ~/.oh-my-zsh/custom/plugins
# ADD zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins
ADD .zshrc /root/.zshrc
# aliyun
RUN npm i -g pnpm yarn &&\
    npm config set registry http://registry.npm.taobao.org/ &&\
    yarn config set registry http://registry.npm.taobao.org/ &&\
    pnpm config set registry http://registry.npm.taobao.org/
RUN rm -rf /etc/apk/repositories &&\
    touch /etc/apk/repositories &&\
    echo 'https://mirrors.aliyun.com/alpine/v3.16/main' >> /etc/apk/repositories &&\
    echo 'https://mirrors.aliyun.com/alpine/v3.16/community' >> /etc/apk/repositories
