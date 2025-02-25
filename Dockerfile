FROM docker.io/node:14 as builder
RUN npm install @angular/cli@10.1.2 -g
WORKDIR /usr/src/app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

FROM docker.io/node:14

ENV OPENSSL_CONF=/dev/null
RUN apt-get update && apt-get install build-essential chrpath libssl-dev libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev -y 
# RUN echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p

# RUN wget https://stgwusvcapp01.blob.core.windows.net/image/library/phantomjs-2.1.1-linux-x86_64.tar.bz2 -P /tmp/
COPY phantomjs-2.1.1-linux-x86_64.tar.bz2 /tmp/
RUN tar xvjf /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share/
RUN ln -sf /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin

RUN npm install node-gyp -g
RUN npm install babel-cli babel-preset-es2015 -g

WORKDIR /usr/src/app
COPY --from=builder /usr/src/app/server/package.json .
RUN npm install
COPY --from=builder /usr/src/app/server .
CMD [ "babel-node", "--presets", "es2015", "./src/index.js"]
