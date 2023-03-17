FROM python:latest

WORKDIR /app

COPY requirements.txt /app

RUN pip3 install -r requirements.txt

COPY . /app

EXPOSE 5002

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0","--port=5002"]