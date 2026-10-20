FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    container=docker

# Empty Linux host: SSH and tools only. You install k3s after you log in (vm5–vm7).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      dbus \
      git \
      gnupg \
      iproute2 \
      iputils-ping \
      nano \
      openssh-server \
      sudo \
      systemd \
      systemd-sysv \
      vim-tiny \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Trim noisy systemd units that do not belong in a container
RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
 && rm -f /etc/systemd/system/*.wants/* \
 && rm -f /lib/systemd/system/local-fs.target.wants/* \
 && rm -f /lib/systemd/system/sockets.target.wants/*udev* \
 && rm -f /lib/systemd/system/sockets.target.wants/*initctl* \
 && rm -f /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
 && rm -f /lib/systemd/system/systemd-update-utmp* \
 && systemctl mask \
      console-getty.service \
      getty@tty1.service \
      systemd-logind.service \
      systemd-resolved.service \
      systemd-networkd.service \
      systemd-udevd.service \
      systemd-udevd-kernel.socket \
      systemd-udevd-control.socket \
 && systemctl enable ssh.service

# Local lab login only: user lab / password lab
RUN useradd -m -s /bin/bash -G sudo lab \
 && echo 'lab:lab' | chpasswd \
 && echo 'lab ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/lab \
 && chmod 440 /etc/sudoers.d/lab \
 && mkdir -p /home/lab/.ssh \
 && chmod 700 /home/lab/.ssh \
 && chown -R lab:lab /home/lab/.ssh

COPY keys/lab_ed25519.pub /home/lab/.ssh/authorized_keys

RUN chown lab:lab /home/lab/.ssh/authorized_keys \
 && chmod 600 /home/lab/.ssh/authorized_keys \
 && mkdir -p /var/run/sshd \
 && sed -i 's/#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
 && sed -i 's/#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
 && sed -i 's/#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config \
 && sed -i 's/#\?UsePAM .*/UsePAM yes/' /etc/ssh/sshd_config

COPY motd /etc/motd
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
 && printf '\ncat /etc/motd\n' >> /home/lab/.bashrc

STOPSIGNAL SIGRTMIN+3
EXPOSE 22
CMD ["/usr/local/bin/entrypoint.sh"]
