FROM scratch
ADD dependency-scanning /

ARG DS_ANALYZER_IMAGE_TAG
ENV DS_ANALYZER_IMAGE_TAG ${DS_ANALYZER_IMAGE_TAG:-latest}

ENTRYPOINT ["/dependency-scanning"]
CMD []
