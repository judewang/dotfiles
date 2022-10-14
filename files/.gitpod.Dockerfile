FROM gitpod/workspace-full:latest

USER root

RUN curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
  && install-packages xvfb x11vnc openjfx libopenjfx-java \
                    xfce4 apt-transport-https google-chrome-stable dbus dbus-x11 gnome-keyring tmux

# Install novnc
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc \
    && git clone --depth 1 https://github.com/novnc/websockify /opt/novnc/utils/websockify
COPY novnc-index.html /opt/novnc/index.html

# Add VNC startup script
COPY start-vnc-session.sh /usr/bin/
RUN chmod +x /usr/bin/start-vnc-session.sh

# This is a bit of a hack. At the moment we have no means of starting background
# tasks from a Dockerfile. This workaround checks, on each bashrc eval, if the X
# server is running on screen 0, and if not starts Xvfb, x11vnc and novnc.
RUN printf '%s\n' 'export DISPLAY=:0' \
    "test ! -e /tmp/.X0-lock && tmux new-session -d -s runlogs '/usr/bin/start-vnc-session.sh'" >> ~/.bashrc

USER gitpod

RUN printf '%s\n' '#!/bin/sh' \
                    'exec dbus-launch --exit-with-session xfce4-session' > "$HOME/.xdesktop.xfce"

COPY --chown=gitpod:gitpod .Xresources $HOME/
COPY --chown=gitpod:gitpod .xinitrc $HOME/

RUN curl -L -O https://github.com/google/fonts/raw/main/ofl/notosanstc/NotoSansTC-Black.otf
RUN curl -L -O https://github.com/google/fonts/raw/main/ofl/notosanstc/NotoSansTC-Bold.otf
RUN curl -L -O https://github.com/google/fonts/raw/main/ofl/notosanstc/NotoSansTC-Light.otf
RUN curl -L -O https://github.com/google/fonts/raw/main/ofl/notosanstc/NotoSansTC-Medium.otf
RUN curl -L -O https://github.com/google/fonts/raw/main/ofl/notosanstc/NotoSansTC-Regular.otf
RUN curl -L -O https://github.com/google/fonts/raw/main/ofl/notosanstc/NotoSansTC-Thin.otf
RUN sudo mv NotoSansTC-Black.otf /usr/share/fonts/
RUN sudo mv NotoSansTC-Bold.otf /usr/share/fonts/
RUN sudo mv NotoSansTC-Light.otf /usr/share/fonts/
RUN sudo mv NotoSansTC-Medium.otf /usr/share/fonts/
RUN sudo mv NotoSansTC-Regular.otf /usr/share/fonts/
RUN sudo mv NotoSansTC-Thin.otf /usr/share/fonts/
RUN rm -rf *.otf
RUN fc-cache -f -v
