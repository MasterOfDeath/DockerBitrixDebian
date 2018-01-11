FROM debian

LABEL name="Bitrix Image" \
    vendor="MI" \
    license="GPLv2" \
    build-date="20171128"

RUN apt-get -y update; \
    apt-get -y install apt-utils lsb-release curl git cron at unattended-upgrades lsof procps \
    initscripts libsystemd0 libudev1 systemd sysvinit-utils udev util-linux;

RUN cd /lib/systemd/system/sysinit.target.wants/ && \
	ls | grep -v systemd-tmpfiles-setup.service | xargs rm -f && \
	rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
	systemctl mask -- \
		tmp.mount \
		etc-hostname.mount \
		etc-hosts.mount \
		etc-resolv.conf.mount \
		-.mount \
		swap.target \
		getty.target \
		getty-static.service \
		dev-mqueue.mount \
		cgproxy.service \
		systemd-tmpfiles-setup-dev.service \
		systemd-remount-fs.service \
		systemd-ask-password-wall.path \
		systemd-logind.service && \
	systemctl set-default multi-user.target || true

RUN sed -ri /etc/systemd/journald.conf \
    -e 's!^#?Storage=.*!Storage=volatile!'

RUN apt-get -y install wget nano ssh apache2 zip unzip \
               php php-soap php-mysql php-mbstring php-gd php-zip php-xml; \
    apt-get clean; \
    \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config; \
    sed "s/short_open_tag = Off/short_open_tag = On/" -i /etc/php/7.0/apache2/php.ini; \
    sed "s/;date.timezone =/date.timezone = Asia\/Yekaterinburg/" -i /etc/php/7.0/apache2/php.ini; \
    sed "s/;mbstring.func_overload = 0/mbstring.func_overload = 2/" -i /etc/php/7.0/apache2/php.ini; \
    sed "s/;mbstring.internal_encoding =/mbstring.internal_encoding = utf-8/" -i /etc/php/7.0/apache2/php.ini;\
    sed "s/;opcache.revalidate_freq=2/opcache.revalidate_freq = Off/" -i /etc/php/7.0/apache2/php.ini; \
    sed "s/; max_input_vars = 1000/max_input_vars = 12000/" -i /etc/php/7.0/apache2/php.ini; \
    sed "s/upload_max_filesize = 2M/upload_max_filesize = 2000M/" -i /etc/php/7.0/apache2/php.ini; \
    sed "s/post_max_size = 8M/post_max_size = 2000M/" -i /etc/php/7.0/apache2/php.ini; \
    \
    usermod -u 1000 www-data;

RUN systemctl enable apache2;

ADD site1.conf /etc/apache2/sites-available
RUN a2dissite 000-default; a2ensite site1;

ENV ROOT_SSH_PASS="4EyahtMj"
ENV BITRIX_SSH_PASS="XW7ur3TB"


VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock", "/tmp" ]
CMD ["/lib/systemd/systemd"]
