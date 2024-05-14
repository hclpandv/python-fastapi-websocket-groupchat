FROM alpine:3.16

WORKDIR /usr/src/app
ADD requirements.txt .

RUN apk add --no-cache python3 py3-pip \
    && pip install -r requirements.txt

CMD ["uvicorn", "main:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]