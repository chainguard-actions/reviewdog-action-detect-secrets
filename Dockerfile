FROM python:3.14.7-alpine

ENV REVIEWDOG_VERSION=v0.21.0

RUN apk --no-cache add bash git gcc musl-dev \
  && wget -q -O /tmp/install-reviewdog.sh https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh \
  && sh /tmp/install-reviewdog.sh -b /usr/local/bin/ ${REVIEWDOG_VERSION} \
  && rm /tmp/install-reviewdog.sh \
  && pip install detect-secrets[word_list]

COPY baseline2rdf.py /usr/local/bin/baseline2rdf
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
