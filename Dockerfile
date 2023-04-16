# Alpine Linux 3.13에서 Python 3.9 이미지를 기반으로합니다.
FROM python:3.9-alpine3.13

# 이미지를 생성한 사람의 정보를 포함하는 레이블을 추가합니다.
LABEL maintainer="seokcoding.com"

# Python 출력 버퍼링을 비활성화합니다.
ENV PYTHONUNBUFFERED 1

# 로컬 파일 시스템에서 requirements.txt 파일을 /tmp 디렉토리로 복사합니다.
COPY ./requirements.txt /tmp/requirements.txt
# 로컬 파일 시스템에서 requirements.dev.txt 파일을 /tmp 디렉토리로 복사합니다.
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# 로컬 파일 시스템에서 애플리케이션 코드를 /app 디렉토리로 복사합니다.
COPY ./app /app

# 이미지 내부의 작업 디렉토리를 /app으로 설정합니다.
WORKDIR /app

# 8000번 포트를 노출합니다.
EXPOSE 8000
# 이미지를 빌드 할 때 'DEV' 인자가 전달되지 않으면, 기본적으로 false로 설정
ARG DEV=false
# 가상 환경을 만들고, pip를 업그레이드하고, 필요한 패키지를 설치하며, 임시 디렉토리를 삭제하고, django-user라는 사용자를 추가합니다.
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    # Dockerfile에서 사용되는 쉘 스크립트 \
    # 이렇게 하면 개발 환경과 프로덕션 환경을 구분하여 패키지를 관리 할 수 있다.
    if [ $DEV = "true" ]; \
      # 개발용 패키지 설치 명령문
      then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    # if문 종료 후 다른 명령어와 연결
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# PATH 환경 변수를 설정하여 가상 환경에 설치된 pip를 사용할 수 있도록 합니다.
ENV PATH="/py/bin:$PATH"

# django-user 사용자로 전환합니다.
USER django-user
