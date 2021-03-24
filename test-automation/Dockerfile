FROM node:12

RUN npm install -g newman
RUN npm install -g newman-reporter-testrail

# install jq to parse json within bash scripts
RUN curl -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && \
  chmod +x /usr/local/bin/jq

COPY * /
RUN chmod +x /run_newman.sh

ENV COLLECTION_NAME="My Collection Name"

ENTRYPOINT ["/run_newman.sh"]

