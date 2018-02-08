FROM python:2.7-alpine

ENV BOTTLE_VERSION 0.12.13

COPY ./cabify.py /
RUN pip install bottle==${BOTTLE_VERSION}

EXPOSE 8181
ENTRYPOINT ["python2", "/cabify.py"]
