FROM alpine:3.11

RUN apk --update add openjdk8-jre

RUN apk add --no-cache gnupg
RUN apk add --no-cache curl

RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.10.5.1-1_amd64.apk
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.10.1.1-1_amd64.apk

RUN apk add --allow-untrusted msodbcsql17_17.10.5.1-1_amd64.apk
RUN apk add --allow-untrusted mssql-tools_17.10.1.1-1_amd64.apk

RUN ln -s /opt/microsoft/msodbcsql17/lib64/libmsodbcsql-17.10.so.5.1 /lib/libmsodbcsql.so

RUN wget -q https://github.com/embulk/embulk/releases/download/v0.9.25/embulk-0.9.25.jar -O /bin/embulk \
  && chmod +x /bin/embulk

WORKDIR /work

RUN apk add --no-cache libc6-compat \
  && embulk gem install embulk-output-s3_parquet embulk-input-sqlserver embulk-output-multi embulk-output-s3 embulk-output-parquet embulk-input-postgresql embulk-output-clickhouse embulk-input-sqlserver embulk-output-sqlserver
RUN ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2

RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/microsoft/msodbcsql18/lib64:/lib64


ENTRYPOINT ["java", "-jar", "/bin/embulk"]
