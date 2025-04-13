FROM ubuntu

# Tránh các prompt tương tác trong quá trình cài đặt
ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt các gói cần thiết
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-21-jdk-headless \
    wget \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    bash \
    file \
    gcc \
    libgmp-dev \
    make \
    xvfb \
    lib32stdc++6 \
    libstdc++6 \
    fonts-droid-fallback \
    python3 \
    python3-pip \
    ruby \
    ruby-dev \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1001 developer \
    && useradd --uid 1001 --gid developer --shell /bin/bash --create-home developer

WORKDIR /home/developer

RUN cd /home/developer \
    && git clone https://github.com/flutter/flutter.git -b stable \
    && chown -R developer:developer flutter

ENV PATH=$PATH:/home/developer/flutter/bin

USER developer

RUN flutter precache \
    && flutter config --no-analytics \
    && flutter doctor

RUN mkdir -p /home/developer/Android/sdk/cmdline-tools \
    && cd /home/developer/Android/sdk/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
    && unzip commandlinetools-linux-9477386_latest.zip \
    && rm commandlinetools-linux-9477386_latest.zip \
    && mkdir latest \
    && mv cmdline-tools/* latest/ \
    && rmdir cmdline-tools

ENV ANDROID_HOME=/home/developer/Android/sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

RUN yes | sdkmanager --licenses \
    && sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

CMD ["bash"]