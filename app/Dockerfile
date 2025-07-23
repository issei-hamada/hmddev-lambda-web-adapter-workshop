FROM public.ecr.aws/lambda/python:3.12
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter

# Pythonのバッファリングを無効化してログを即座に出力
ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=utf-8

WORKDIR /app
ADD . .
RUN pip install -r requirements.txt

ENTRYPOINT ["uvicorn"]
CMD ["main:app", "--host", "0.0.0.0", "--port", "8080"]