FROM ubuntu:22.04

# add i386 arch for 32-bit wine runtime as needed by forscan
RUN dpkg --add-architecture i386

# install all needed OS packages
RUN apt-get update && apt-get install --no-install-recommends -y wget wine wine32 winbind

# create forscan user and clean up
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/forscan && \
    echo "forscan:x:${uid}:${gid}:forscan,,,:/home/forscan:/bin/bash" >> /etc/passwd && \
    echo "forscan:x:${uid}:" >> /etc/group && \
    gpasswd -a forscan dialout && \
    chown ${uid}:${gid} -R /home/forscan && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/* /usr/share/doc /usr/share/man

# fetch forscan installer
USER forscan
ENV HOME /home/forscan
RUN wget --no-check-certificate https://forscan.org/download/FORScanSetup2.3.58.release.exe -O /home/forscan/forscan_setup.exe

ENTRYPOINT ["/home/forscan/exec.sh"]
