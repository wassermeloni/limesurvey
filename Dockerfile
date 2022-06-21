
FROM mattrayner/lamp:latest-1804

RUN apt-get update -q -y && \
	apt-get upgrade -q -y && \
	apt-get install -q -y curl php-gd php-ldap php-imap sendmail php-pgsql php-curl && \
	apt-get clean && \
	phpenmod imap

RUN chown www-data:www-data /var/lib/php7

ADD apache_default /etc/apache2/sites-available/000-default.conf
ADD start.sh /
ADD run.sh /

RUN chmod +x /start.sh && \
    chmod +x /run.sh

ENV LIMESURVEY_VERSION="3.27.31+220104"

RUN apt-get update -q -y && \
	apt-get upgrade -q -y
	
RUN rm -rf /app && \
    git clone https://github.com/LimeSurvey/LimeSurvey.git && \
    cd LimeSurvey && git checkout ${LIMESURVEY_VERSION} && cd .. && \
    rm -rf /LimeSurvey/.git && \
    mv LimeSurvey app && \
    mkdir -p /app/upload/surveys && \
	mkdir -p /uploadstruct && \
	chown -R www-data:www-data /app && \
    cp -a /app/upload/* /uploadstruct

SHELL ["/bin/bash", "--login", "-c"]

RUN versions=(${LIMESURVEY_VERSION//+/ }) && \
    version=${versions[1]} && \
    sed -r -i "s/(config\['buildnumber'\] = ')(.*)('\;$)/\1${version}\3/g" /app/application/config/version.php

VOLUME /app/upload
VOLUME /app/plugins

EXPOSE 80 3306
CMD ["/start.sh"]
