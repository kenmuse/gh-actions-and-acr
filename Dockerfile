FROM ubuntu:22.04

WORKDIR /src
COPY ./src /src

RUN apt-get update \
    && apt -y upgrade \
    && apt-get install -y python3-pip \
    && pip install -r requirements.txt
    
EXPOSE 80
ENTRYPOINT FLASK_APP=/src/app.py flask run --host=0.0.0.0 --port=80