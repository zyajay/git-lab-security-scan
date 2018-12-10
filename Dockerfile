FROM scratch
ADD dependency-scanning /

ENTRYPOINT ["/dependency-scanning"]
CMD []
