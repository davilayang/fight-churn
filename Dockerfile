FROM python:3.8

WORKDIR /app

RUN python3 -m venv /app/venv

COPY requirements.txt requirements.txt
RUN /app/venv/bin/pip3 install -r requirements.txt

COPY fightchurn fightchurn
