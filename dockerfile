FROM alpine:3.16
ENV PYTHONUNBUFFERED 1

# Copying requirements.txt
COPY requirements.txt .

RUN apk add --no-cache python3 py3-pip \
    && pip install -r requirements.txt

# Add application code. Comment this when get solution for mount
ADD app /code

# Create a dir and make it workdir
WORKDIR /code

CMD ["uvicorn", "main:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]
