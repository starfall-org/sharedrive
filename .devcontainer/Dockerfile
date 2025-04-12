FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive

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
    && rm -rf /var/lib/apt/lists/*

ENV ANDROID_SDK_ROOT=/usr/lib/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

WORKDIR /root

RUN cd /root \
    && git clone https://github.com/flutter/flutter.git -b stable \
    && chown -R developer:developer flutter

ENV PATH=$PATH:/root/flutter/bin

RUN flutter precache \
    && flutter config --no-analytics \
    && flutter doctor

RUN mkdir -p /root/Android/sdk/cmdline-tools \
    && cd /root/Android/sdk/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
    && unzip commandlinetools-linux-9477386_latest.zip \
    && rm commandlinetools-linux-9477386_latest.zip \
    && mkdir latest \
    && mv cmdline-tools/* latest/ \
    && rmdir cmdline-tools

ENV ANDROID_HOME=/root/Android/sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

RUN yes | sdkmanager --licenses \
    && sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"