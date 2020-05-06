ARG SSH_HOST_KEYS_HASH=sha256:9a6630c2fbed11a3f806c5a5c1fe1550b628311d8701680fd740cae94b377e6c

# SSH host keys
FROM qmxme/openssh@$SSH_HOST_KEYS_HASH as ssh_host_keys

# base distro
FROM debian:sid

# setup env
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

# default package set
RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y \
	apache2-utils \
	apt-transport-https \
	awscli \
	bat \
	build-essential \
	ca-certificates \
	clang \
	cmake \
	curl \
	debcargo \
	default-libmysqlclient-dev \
	default-mysql-client \
	direnv \
	dnsutils \
	docker-compose \
	docker.io \
	entr \
	exuberant-ctags \
	fd-find \
	flake8 \
	fzf \
	gdb \
	git \
	git-crypt \
	gnupg \
	golang-1.14 \
	htop \
	hub \
	hugo \
	ipcalc \
	jq \
	kafkacat \
	less \
	libclang-dev \
	liblzma-dev \
	libpq-dev \
	libprotoc-dev \
	librdkafka-dev \
	libsqlite3-dev \
	libssl-dev \
	lldb \
	locales \
	man \
	mosh \
	mtr-tiny \
	musl-tools \
	ncdu \
	neovim \
	netcat-openbsd \
	openjdk-11-jdk-headless \
	openssh-server \
	pcscd \
	pkg-config \
	protobuf-compiler \
	pwgen \
	python \
	python3 \
	python3-flake8 \
	python3-neovim \
	python3-pip \
	python3-setuptools \
	python3-venv \
	python3-wheel \
	qrencode \
	quilt \
	redis-server \
	restic \
	ripgrep \
	rsync \
	shellcheck \
	socat \
	sqlite3 \
	stow \
	strace \
	sudo \
	tmate \
	tmux \
	unzip \
	vim-nox \
	wabt \
	wget \
	wireguard-tools \
	zgen \
	zip \
	zlib1g-dev \
	zsh \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
	locale-gen --purge $LANG && \
	dpkg-reconfigure --frontend=noninteractive locales && \
	update-locale LANG=$LANG LC_ALL=$LC_ALL LANGUAGE=$LANGUAGE
RUN update-ca-certificates -f

# enable nodesource repo
RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
RUN echo "deb https://deb.nodesource.com/node_12.x sid main" | sudo tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update -qq && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

# enable yarn repo
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -qq -y \
	yarn \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

# sshd setup
RUN mkdir /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed 's/#Port 22/Port 3222/' -i /etc/ssh/sshd_config
RUN echo 'StreamLocalBindUnlink yes' >> /etc/ssh/sshd_config
COPY --from=ssh_host_keys /etc/ssh/ssh_host* /etc/ssh/
