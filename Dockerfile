# Multi-stage build
FROM python:3.12.3 AS builder

# Activate venv
RUN python3.12 -m venv /venv
ENV PATH="/venv/bin:$PATH"

COPY ./requirements.txt .
RUN pip3 install --no-cache-dir  -r requirements.txt


FROM python:3.12.3-slim
ENV READINESS_CHECK_PORT=7531
ENV PORT=7531
ENV PYTHONUNBUFFERED=1
# activate virtual environment
ENV VIRTUAL_ENV=/venv
ENV PATH="/venv/bin:$PATH"

# Copy dependencies
COPY --from=builder /venv /venv

#Copy aws lambda adapter
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.8.2 /lambda-adapter /opt/extensions/lambda-adapter

WORKDIR /code

COPY ./webapp .

# CMD ["python", "app.py"]
CMD ["gunicorn", "-b=:7531", "-w=1", "app:app"]