FROM openjdk:8u312-jdk

RUN  apt-get update
RUN apt install -y wget
RUN apt-get install -y unzip
RUN apt-get install -y xvfb
RUN apt-get install -y libxtst6
RUN apt-get install -y libxrender1 
RUN apt-get install -y libxi6 
RUN apt-get install -y x11vnc 
RUN apt-get install -y socat 
RUN apt-get install -y software-properties-common 
RUN apt-get install -y dos2unix 
RUN apt install openjdk-8-jdk -y 
RUN apt install bbe -y 

# Setup IB TWS
RUN mkdir -p /opt/TWS
WORKDIR /opt/TWS
# RUN wget -q http://cdn.quantconnect.com/interactive/ibgateway-latest-standalone-linux-x64-v974.4g.sh
RUN wget -q https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh
RUN mv tws-latest-standalone-linux-x64.sh infile
RUN bbe -e 's,# INSTALL4J_JAVA_HOME_OVERRIDE=,INSTALL4J_JAVA_HOME_OVERRIDE=/usr/lib/jvm/java-1.8.0-openjdk-arm64,' infile > outfile
RUN bbe -e 's,"152","312",' outfile > tws-latest-standalone-linux-x64.sh
RUN chmod a+x tws-latest-standalone-linux-x64.sh
# INSTALL4J_JAVA_HOME_OVERRIDE=/usr/lib/jvm/java-1.8.0-openjdk-arm64

# Setup  IBController
RUN mkdir -p /opt/IBController/ && mkdir -p /opt/IBController/Logs
WORKDIR /opt/IBController/
RUN wget -q http://cdn.quantconnect.com/interactive/IBController-QuantConnect-3.2.0.5.zip
RUN unzip ./IBController-QuantConnect-3.2.0.5.zip
RUN chmod -R u+x *.sh && chmod -R u+x Scripts/*.sh

WORKDIR /

# Install TWS
RUN echo -e "\nn"  | /opt/TWS/tws-latest-standalone-linux-x64.sh

ENV DISPLAY :0

ADD runscript.sh runscript.sh
ADD ./vnc/xvfb_init /etc/init.d/xvfb
ADD ./vnc/vnc_init /etc/init.d/vnc
ADD ./vnc/xvfb-daemon-run /usr/bin/xvfb-daemon-run

RUN chmod -R u+x runscript.sh \
  && chmod -R 777 /usr/bin/xvfb-daemon-run \
  && chmod 777 /etc/init.d/xvfb \
  && chmod 777 /etc/init.d/vnc

RUN dos2unix /usr/bin/xvfb-daemon-run \
  && dos2unix /etc/init.d/xvfb \
  && dos2unix /etc/init.d/vnc \
  && dos2unix runscript.sh

# Below files copied during build to enable operation without volume mount
COPY ./ib/IBController.ini /root/IBController/IBController.ini
COPY ./ib/jts.ini /root/Jts/jts.ini

CMD bash runscript.sh
