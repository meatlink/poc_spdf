FROM ubuntu:22.04
RUN apt update && apt install -y git pkg-config

RUN \
  git clone https://github.com/spdk/spdk --recursive \
  && \
  cd spdk && git checkout 84532e3d225b0a28d6c897192c9e0f963e0a97a6
WORKDIR spdk

RUN scripts/pkgdep.sh
RUN ./configure && make

ENTRYPOINT []
CMD [ \
  "sh", \
  "-c", \
  " \
    ( \
      sleep 3 ; \
      /spdk/scripts/rpc.py \
        nvmf_create_transport \
        -t TCP \
        -u 16384 \
        -m 8 \
        -c 8192 \
    ) \
    & \
    exec /spdk/build/bin/nvmf_tgt -s \"${SPDK_HUGEPAGES_MB}M\" \
  " \
]
