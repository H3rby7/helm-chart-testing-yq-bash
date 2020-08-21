FROM quay.io/helmpack/chart-testing:v3.0.0

RUN apk add jq bash && \
    wget -q -O /usr/bin/yq $(wget -q -O - https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.assets[] | select(.name == "yq_linux_amd64") | .browser_download_url') && \
    chmod +x /usr/bin/yq

ENV PATH="/usr/bin/stage-check:${PATH}"
ADD cli /usr/bin/stage-check
RUN chmod +x /usr/bin/stage-check/check-stages.sh
