FROM python:3.9

WORKDIR /app/backend

COPY requirements.txt /app/backend
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y gcc default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*


# Install app dependencies
RUN pip install mysqlclient \
    && pip install --no-cache-dir -r requirements.txt

# Prevent Python from writing .pyc files and enable unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY . /app/backend

EXPOSE 8000
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["gunicorn", "notesapp.wsgi:application", "--bind", "0.0.0.0:8000"]

