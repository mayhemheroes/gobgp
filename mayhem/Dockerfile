FROM gcr.io/oss-fuzz-base/base-builder-go as builder

COPY . /gobgp

WORKDIR /gobgp

RUN go get github.com/AdamKorcz/go-118-fuzz-build/testing

COPY mayhem/build.sh build.sh

RUN chmod +x build.sh

ENV FUZZING_LANGUAGE=go
ENV SANITIZER=address
ENV FUZZING_ENGINE=libfuzzer
ENV ARCHITECTURE=x86_64
ENV PROJECT_NAME=gobgp

RUN compile_libfuzzer

RUN ./build.sh

FROM ubuntu:20.04 as target

COPY --from=builder /out /out

CMD ["/out/fuzz_parse_bgp_message"]