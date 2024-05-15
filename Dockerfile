FROM            ruby:3.2.2-slim

ENV             ANDROID_COMMAND_LINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip"
ENV             ANDROID_HOME="/opt/android/sdk"
ENV             ANDROID_ACCEPT_LICENSE="yes"
ENV             ANDROID_PLATFORM_VERSION="31"
ENV             DEBIAN_FRONTEND="noninteractive"
ENV             LANG="en_US.UTF-8"
ENV             LANGUAGE="en_US.UTF-8"
ENV             PATH=$PATH:/home/builder/.local/share/gem/ruby/3.2.0/bin:/opt/android/sdk/platform-tools:/opt/android/tools/bin

RUN             mkdir -p "/usr/share/man/man1" && \
                apt-get update --fix-missing && \
                apt-get -y upgrade && \
                apt-get install -y \
                apt-transport-https \
                build-essential \
                default-jdk-headless \
                curl \
                git \
                python3 \
                unzip \
                usbutils \
                vim

RUN 			curl -fsSLO https://nodejs.org/dist/v18.10.0/node-v18.10.0-linux-x64.tar.xz && \
				tar -xJf node-v18.10.0-linux-x64.tar.xz -C /usr/local --strip-components=1 && \
				rm node-v18.10.0-linux-x64.tar.xz && \
				npm install -g npm@9.0.0

RUN             npm -g install react-native-cli

RUN             useradd -m builder && \
                mkdir -p "/opt/android" && \
                chown builder "/opt/android" && \
                mkdir -p "/conf" "/data" && chmod 777 "/conf" "/data"

USER            builder

RUN             curl "$ANDROID_COMMAND_LINE_TOOLS_URL" -o "/tmp/android-tools.zip"  && \
                unzip -d "/opt/android" "/tmp/android-tools.zip"; rm -f "/tmp/android-tools.zip" && \
                $ANDROID_ACCEPT_LICENSE | sdkmanager  --sdk_root="/opt/android/sdk" "platform-tools" "platforms;android-${ANDROID_PLATFORM_VERSION}"

RUN             gem install --user-install fastlane

COPY            "build-sample.conf" "/home/builder/build-sample.conf"

COPY            "entrypoint.sh" "/entrypoint.sh"

ENTRYPOINT      ["/entrypoint.sh"]

CMD             ["help"]
