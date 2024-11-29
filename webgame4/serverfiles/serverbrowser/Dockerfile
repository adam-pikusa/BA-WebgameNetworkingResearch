FROM python:3.13-slim

WORKDIR /app

COPY . /app

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

EXPOSE 7890

CMD gunicorn -w 3 --bind=0.0.0.0:7890 app:app