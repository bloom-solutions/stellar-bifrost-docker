FROM ubuntu:16.04
MAINTAINER Ramon Tayag <ramon.tayag@gmail.com>

RUN apt-get update -qq && apt-get upgrade -y && \
  apt-get install wget golang-go git postgresql-client -y

ENV BIFROST_VERSION=v0.0.1
ENV BIFROST_URL=https://github.com/stellar/go/releases/download/bifrost-$BIFROST_VERSION/bifrost-linux-amd64

RUN wget $BIFROST_URL
RUN chmod +x bifrost-linux-amd64 && mv bifrost-linux-amd64 /usr/local/bin/bifrost
RUN mkdir /go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$PATH

# Download the Stellar's go repo that has the bifrost migration file
RUN mkdir -p /go/src/github.com/stellar/ && \
  git clone --depth 1 --branch master https://github.com/stellar/go.git /go/src/github.com/stellar/go

# Add library that will migrate the db
RUN go get github.com/lib/pq
RUN ls $GOPATH/src/github.com/lib/pq
ADD initbifrost $GOPATH/src/github.com/stellar/initbifrost
RUN go install github.com/stellar/initbifrost

ADD templater.sh /usr/local/bin/templater
RUN chmod +x /usr/local/bin/templater
ADD entry.sh /entry.sh
RUN chmod +x /entry.sh
ADD templates /opt/templates

ENTRYPOINT ["/entry.sh"]
