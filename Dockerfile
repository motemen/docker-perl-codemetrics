FROM perl:5

ADD cpanfile cpanfile.snapshot ./
RUN cpanm --notest --installdeps .
ADD metrics.pl .

WORKDIR /src

ENTRYPOINT ["perl", "/root/metrics.pl"]
