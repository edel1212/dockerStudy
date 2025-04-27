# Docker Study

## 1) Docker란?

- 리눅스 컨테이너 기반으로하는 오픈소스 가상화 플랫폼이다.
- 각각의 컨테이너에는 OS 전체가 설치 되어있는 것이 아니라, 앱을 실행하는 데에 필요한 library와 실행파일만 설치되어있다. 그렇기 때문에 VM(가상머신)과는 구분
- Docker의 구성
  - Image로 되어있으며 Image를 통해 다수의 Container를 생성할 수 있다.
    - Image?. 컨테이너를 실행 할 수 있는 실행 파일, 설정 값들을 가지고 있는 파일
- ✅ 중요한 포인트
  - Image들은 경량화을 위해 필요한 기능만 들어가있다.
- 간단 비교 (비교대상 App Store 프로그램)
 
| App Store | Docker Hub |
| --------- | ---------- |
| Program   | Image      |
| Process   | Container  |

## 2 ) 기본 명령어
- Image Download
  - `docker pull [OPTIONS] NAME[:TAG|@DIGEST]`
    - ex)  `docker pull httpd` ✏️ latest를 받아옴
- Image 목록
  - `docker images`
- Dokcer Image 실행
  - `docker run [OPTIONS] IMAGE [COMMAND] [args...]`
    - ex ) `docker run httpd` ✏️ 기본 실행 
    - ex ) `docker run --name Foo httpd` ✏️ 컨테이너명 추가 
    - ex ) `docker run --name Foo -p 3512:80 httpd` ✏️ 포트 포워딩 추가 
    - ex ) `docker run --network my-net nginx` ✏️ 네트워크 지정 
    - ex ) `docker run -v /my/host/dir:/usr/share/nginx/html nginx` ✏️ 볼륨 설정 
    - ex ) `docker run -d --name my-nginx -p 8080:80 nginx` ✏️ 백그라운드 실행 
- Container log 확인
  - `docker logs [OPTIONS] CONTAINER`
    - `docker logs Foo` ✏️  일회성 로그  
    - `docker logs -f Foo` ✏️  Watch Mode  
    - `docker logs --tail -f Foo` ✏️ 최근 로그부터 Watch Mode  
- Container 삭제
  - `docker rm [OPTIONS] CONTAINER [CONTAINER...]`
- Image 삭제
  - `docker rmi [OPTIONS] IMAGE [IMAGE...]`
    - ex) `docker rmi httpd`
- 네트워크 관련 명령어
  -	`docker network ls` ✏️네트워크 목록
  -	`docker network inspect [네트워크명]` ✏️ 특정 네트워크 상세 정보 보기
  - `docker network create [OPTIONS] [네트워크명]` ✏️ 네트워크 생성
    - ex) `docker network create my-net` ✏️ default driver = bridge 
    - ex) `docker network create --driver bridge [네트워크명]`

## 3) Docker Host란?

- Host란 운영체제가 설치된 컴퓨터라 생각하자 하나의 운영 체제 안에서 커널을 공유하며 개별적인 실행 환경을 제공하는 격리된 공간으로써, host에서 실행되는 격리된 각각의 실행 환경
  - Host 내부에는 여러개의 Container가 존재 한다.
  - 독립적인 시스템을 갖고있기 때문에 포트가 나눠져고 **외부에서 접근하기 위해서는 포트포워딩이 필요**
  >   docker run --name Foo -p 81:80 httpd  

## 4) Docker Container 접속
- `docker exec [OPTIONS] CONTAINER COMMAND [args...]`
```shell
# 내부에서 명령어를 실행 시킴 (실행 후 종료)
docker exec Foo ls
docker exec Foo pwd
  
#지속적으로 내부에 접근해서 실행
docker exec --it foo /bin/bash
```

## 5) Docker Volume
- 기본 설정으로 container를 생성할 경우 **컨테이너가 삭제 시 내부 데이터가 전부 사라지기에** Volume 설정이 필요하다
  - 호스트와 continer를 지정 디렉토리 끼리 mount 시키는 개념 따라서 컨터이너가 사라져도 host 내 파일을 가지고 있음
```shell
# -v  [ host 디렉토리 위치 : 컨테이너 내부 디렉토리 위치 ]  
docker run -p 8888:80 --name syncTest -v ~/Desktop/Project/dockerStudy:/usr/local/apache2/htdocs httpd
```
  

## 6) 도커 이미지 만들기 (commit)
- 현재의 Container를 새로운 무언가를 추가하고 그것을 이미지화 한다면 그 이미지를 사용하여 새로운 컨테이너 추가 가능

- 시나리오
  - 1 . 우분투 이미지를 다운
  - 2 . 해당 우분투에 깃을 추가하여 이미자화
  - 3 . 해당 우분투는 그냥 우분투가 아닌 깃을 포함한 우분투가됨
  - 4 . 해당 이미지를 기반으로 PHP, Python, Nodejs 등 다양한 서버 환경을 구축이 가능해짐

```shell
# ubuntu imager download 
docker pull ubuntu \ 
# container 싱행 
docker run -it --name my-ubuntu ubuntu bash \
# container 접근 
docker exec -it my-ubuntu /bin/bash \
# container 내 apt update 및 git 설치
$ apt upate \
$ apt install git \
$ exit \
# git 설치된 container를 Image로 생성
# - commit으로 인해 image가 생성
docker commit [타겟 Container] [Image-Name:Tag-Name] \
docker images; 
```

## 7) 도커 이미지 만들기 (dockerfile & build)

- dockerfile의 장점은 생성될 image의 내용을 파일을 보고 알 수 있다는것이다
- commit과 차이
  - commit
    - 내가 만든 Container를 기준으로 하여 Image를 생성 [ 백업과 같은 느낌 ]
  - Dockerfile
    - 내부에 작성된 명령어의 순서에 맞춰 Image를 생성 [ 내가 아예 생성하는 느낌 ]

### 7 - 1) DockerFile 명령어
#### RUN
- 이미지를 **빌드(build)** 하는 과정에서 쉘 커맨드를 실행할 때 사용합니다.
- 주로 이미지 안에 **필요한 패키지 설치**나 **환경 설정**을 위해 사용합니다.
- 빌드된 결과는 **새로운 레이어(layer)** 로 추가됩니다.
- ✅ **자주 사용 예시**
  - `RUN apt-get update && apt-get install -y nginx`
  - `RUN mkdir /app`


#### ENTRYPOINT
- 컨테이너가 **시작될 때 항상 실행**되어야 하는 커맨드를 설정합니다.
- ENTRYPOINT로 실행된 프로세스가 **종료되면 컨테이너도 함께 종료**됩니다.
- 기본적으로 **덮어쓰기(overriding)이 불가능**합니다.
  - 다만, `--entrypoint` 옵션을 사용하면 실행 시 덮어쓸 수 있습니다.
- ✅ **자주 사용 예시**
  - `ENTRYPOINT ["nginx", "-g", "daemon off;"]`
  - `ENTRYPOINT ["java", "-jar", "app.jar"]`


#### CMD
- 컨테이너를 실행할 때 **기본으로 전달할 인자(arguments)** 를 설정합니다.
- 단독 사용 시에는 실행 커맨드가 되며, **ENTRYPOINT와 함께 사용**할 경우 ENTRYPOINT의 인자 역할을 합니다.
  - 예시
    - `ENTRYPOINT ["python3", "app.py"]`
    - `CMD ["--port=8080"]`
    - ➡️ 실행 결과: `python3 app.py --port=8080`
- **CMD는 docker run 시 인자로 쉽게 덮어쓸 수 있습니다.**
- ✅ **자주 사용 예시**
  - `CMD ["nginx", "-g", "daemon off;"]`
  - `CMD ["java", "-jar", "app.jar"]`


#### 🧩  CMD , ENTRYPOINT 차이 요약

| 구분 | 실행 시점 | 역할 | 덮어쓰기 가능 여부 |
|:---|:---|:---|:---|
| ENTRYPOINT | 컨테이너 실행 시 | 반드시 실행할 커맨드 | ❌  |
| CMD | 컨테이너 실행 시 | 기본 인자 or 기본 커맨드 | ⭕ (docker run [COMMAND]로 대체 가능) |


#### WORKDIR
- 작업 디렉터리를 설정합니다. (`cd`처럼 동작)
- 예시
  - `WORKDIR /app`

#### COPY
- 호스트 파일을 이미지로 복사
- 예시
  - `COPY . /app`

#### ADD
- `COPY`처럼 파일 복사 기능 + **압축파일 자동 해제** 기능까지 지원 함
  - ✅ 되도록이면 `COPY`를 사용하자

#### ENV
- 컨테이너 안에서 사용할 **환경 변수**를 설정
- 예시
  - `ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk`

#### EXPOSE
- 컨테이너가 사용하는 **포트를 문서화** 함 여기서 포인트는 문서화이기에 **실제 포트적용이 아님**
  - **주의**: 실제 포트 포워딩은 `docker run -p` 옵션으로 별도 지정 필요
- 예시
  - `EXPOSE 8080`

- 시나리오
  - 1 . Dockerfile 생성 [ 확장자는 없음 ]
  - 2 . 해당 file 내부
    - 우분투 image를 기반으로 생성
    - apt, python 설치
    - 디렉토리 생성
    - 해당 디렉토리에 로컬파일을 복사하여 추가
    - container 생성 후 원하는 명령어 실행

### 7 - 2 ) DockerFile 사용 방법
- 좋은 습관 
  - 하나의 명령어를 `\`로 나눠서 가독성을 놓여 주자
    ```shell
    ...
    RUN apt-get install paackage-1 \
    paackage-2 \
    paackage-3
    ``` 
  - `.dockerignore`파일을 작성해 불필요한 빌드 파일은 제외 시키자
  - 명령어가 이어질 경우 `&&`를 사용하여 이어서 사용하자 그럻지 않을 경우 불필요한 용량이 커지는 문제가 생길 수 있음
    ```shell
    # 👎 잘못된 방식의 DockerFile 생성 (용량이 엄청 큼 -rm 과정까지 image 생성 )
    FROM ubuntu
    RUN mkdir /test \
    RUN  fallocate -l 100m /test/dummy \
    RUN rm /test/dummy \
    
    # 👍 올바른 사용 (커맨드가 하나로 진행되어 rm 명령이 의도된 방법으로 실행)
    FROM ubuntu
    RUN mkdir /test && \
    RUN  fallocate -l 100m /test/dummy && \
    RUN rm /test/dummy
    ```

#### 7 - 2 - A ) 예시 1 - python 설치 되어 있는 ubuntu image
```yaml
# - 사용될 Image 대상
# FROM [베이스 이미지]
FROM ubuntu

# - Container가 생성되고 실행 될 명령어
#   RUN을 여러개로 나누어서 작성해도 실행에는 문제가 없으나
#   RUN 명령어 하나당 레이어가 하나씩 추가되기에 비효율적이다
#   따라서 && 사용하여 명령어를 연결해주자!
#   앞에 명령어가 성공하면 뒤에 명령어를 실행함
# RUN [명령어]
RUN apt update && apt install -y python3

# 디렉토리가 없다면 생성해줌
# midir -p /var/www/html 와 같은 의미 [-p 옵션 없으면 부모가 없다면 dir을 생성하지 않음 ]
# WORKDIR에서는 불필요한 옵션임
WORKDIR /var/www/html

# container가 실행될 때 실행될 command
# 형식 CMD["<커맨드>", "<파라미터1>", "<파라미터2>", ...]
# docker run ubuntu ls  << 와 같음
CMD ["python3". "-u", "-m" , "http.server"]
```
#### 7 - 2 - A ) 예시 2 - node 기반 빌드 후 nginx로 서버 구성

```yaml
# base image - 기반이 될 node 이미지 다운 ㅁ
## 여기서 AS는 dockerfile에서 사용될 별칭
FROM node:lts-alpine AS build-stage

# set working directory - 해당 컨테이너 작업 Dir
WORKDIR ./

# copy package.json and package-lock.json
## copy 명령어를 통해 [현재 호스트파일 위치] 이동시킬 위치를 지정
COPY package*.json ./

# install dependencies
## npm을 install "--production"를  통해 배포에 필요 파일만 설치함
RUN npm install --production

# copy project files and folders to the working directory
## front의 프로젝트 전체를 Copy
COPY . .

# build the project
## npm run build 명령어를 이용하여 vue프로젝트를 build함
RUN npm run build

# production stage
## nginx  설치 및 별칭 설정
FROM nginx:stable-alpine AS production-stage

# 베포파일 이동
## 상단에서 사용 한 별칭을 통해 container내부 파일을 복사함
COPY --from=build-stage ./dist /usr/share/nginx/html

# Copy Nginx configuration
## vue-router 사용으로 인해 nginx 설정 파일 수정 하여 copy
COPY nginx.conf /etc/nginx/nginx.conf

# expose port 80
EXPOSE 80

# start the application
## 서버 기동 명령어 사용
### "daemon off;" 의미는 백그라운드 실행
CMD [ "nginx", "-g", "daemon off;" ]
```

#### 7 - 2 - A ) 예시 4 - springBoot 어플리케이션 가동  
- DB 연결 문제를 해결하기 위해 docker network 사용 필수
```yaml
# Base 이미지로 OpenJDK를 사용합니다.
FROM openjdk:11-jdk

# 작업 디렉토리를 생성하고, Spring Boot JAR 파일을 복사합니다.
#WORKDIR /Users/yoo/Desktop/project/springBootStudy/loginServer/build/libs
## 위의 경로가 파일이 있어도 제대로 인식을 못하는 문제가 있어 파일 이동 후 경로 수정
WORKDIR ./
COPY loginServer.jar .

# 컨테이너 실행 시 실행될 명령을 지정합니다.
CMD ["java", "-jar", "loginServer.jar"]
```

### 7 - 3 ) DockerFile build
```shell
# Dockerfile 실행
# [현재 디렉토리 DockerFile 기반] docker build -t [이미지명:버전] [사용될 Dockerfile 경로]  
docker build -t front:1.0 .    
# [지정 DockerFile 기반] docker build -t [이미지명:버전] [사용될 Dockerfile 경로]
docker build -t [이미지이름 지정:버전지정] [사용될 Dockerfile 경로] -f 파일경로/파일명 .  
```

## 8 ) Docker Image Export, Import
- Docker Image export : `docker save` 
  - `$ docker save -o <만들파일명.tar> <대상이미지:버전>`
    - `.tar` 확장자로 export 된다.
- Docker Image import : `docker load`
  - `$ docker load -i <받아온파일명.tar>`

## 9 )  Docker Image Push
- `docker push [이미지명]:[태그]`명령어를 통해 Registry(docker hub)에 올릴 수 있다.

- 시나리오 - Command
```shell
# 우분투 컨테이너 실행
docker run -it --name python-ubuntu ubuntu bash
# 컨테이너 접근
docker exec -it my-ubuntu /bin/bash
# python3 설치
$ apt update && apt install -y python3
exit
# image 생성 - docker commit pyton-ubunt [docker hub 이름]/[image 이름]:[version]
docker commit ptyon-ubuntu edel1212/python:1.0
# docker pull
docker pull edel1212/python3:1.0
```


## 10 ) Docker Network
- Docker 컨테이너는 각각 격리된 환경에서 돌아가기 떄문에 **기본적으로 다른 컨테이너와의 통신이 불가능** 하다.
- Docker Network를 생성하여 연결하고 싶은 컨테이너를 연결해주면 각각 독립되어 있던 컨테이너가 **같은 네트워크 상에 있게 되므로 서로간의 연결이 가능**해진다.

### 10 - 1 ) 네트워크의 종류

- Docker Network 종류 : `bridge`,`host`,`none`,`container`,`overlay`
  - `bridge`란?
    - **_하나의 호소트_** 컴퓨터 내에세 여러 컨테이너들이 서로 소통할 수 있도록 해준다. 👉 브릿지(다리) 설정이 필요하다. _연결 해준다라는 개념_
    - 브릿지 설정이 되어있지 않은 컨테이너와는 통신이 불가능함
    - 네트워크를 생성하면 디폴트로 `bridge`로 설정되어 생성된다.
  - `host`란?
    - 컨테이너를 호스트 컴퓨터와 동일한 네트워크에서 컨테이너를 돌리기 위해 사용
    - 주로 컨테이너가 하나일때 사용된다.
    - 호스트의 네트워크를 그대로 사용하기에 **포트포워딩 작업을 해줄 필요하가 없다.**
    - ✅ **_하나만 존재할 수 있음!!_**
  - `none`란?
    - 네트워크를 사용하지 않는 설정
    - `--attachable` 설정을 통해 설정 가능
  - `container`란?
    - 다른 컨테이너의 네트워크 환경을 공유한다.
  - `overlay`란?
    - 분산된 네트워크( 호스트가 여러대 )에서 Docker를 사용할 때 사용 - 서버가 어려대로 생각하면 된다.
    - 각각의 호스트 (서버)에서 swarm mode가 활성화 되어 있어야한다.
      - 설정이 되어있지 않다면 컴테이너 생성이 불가능함

### 10 - 2 ) network-alias
```yaml
# ✅ network를 alias로 지정 할 경우 같은 docker network를 공유한다면 해당 alias로 ping을 주고받을 수 있다. (라운드 로빈 방식)
```
- `docker network create --driver bridge mybridge` # docker network 생성
- `docker run -itd -name container1 --net mybridge --net-alias ping-test ubuntu:14.04` # 테스트용 continer 생성
- `docker run -itd -name container2 --net mybridge --net-alias ping-test ubuntu:14.04` # 테스트용 continer2 생성
- `docker run -itd -name ping --net mybridge --net-alias ping-test ubuntu:14.04` # 테스트용 continer2 생성
  - 해당 continer에 접속 후 `ping ping-test` 시 각각 돌아가며 ping이 날라가는 것 확인 가능

- 자세한 명령어는 https://docs.docker.com/engine/reference/commandline/network_create/ 확인


## 11 ) Docker Compose

- 도커 컨테이너를 실핼할 때마다 연관 관계가 있는 컨테이너들을 하나하나 입력하고 기억하기가 쉽지 않을 것이다.
- 예시와 같이 긴 명령어를 yml 파일 하나로 정리하여 사용하면 `docker-compose up -d` 명령어 한번으로 실행이 가능해 진다.


### 11 - 1 ) 일반 CLI 명렁어 설치 및 실행

```shell
$ docker run -p 3306:3306                     ## 포트 번호 지정
  --network dt-network                        ## network 지정
  -e MYSQL_ROOT_PASSWORD=123                  ## root pw 지정
  --name mariadb                              ## container 이름 지정
  -v /usr/mariadb-vol:/var/lib/mysql mariadb  ## volume 지정
```

### 11 - 2 ) Dokcer compose  사용 시

- docker-compose.yml 파일 - `파일 이름을 변경하면 -t 명령어로 대상을 지정해줘야하는 번거로움 있음`

```yaml
services:
  db:
    ## 사용할 이미지 지정
    image: mariadb
    ## 생성될 컨테이너명
    container_name: mariadb
    ## 포트번호 지정
    ports:
      - 3306:3306
    ## 볼륨 지정
    volumes:
      - ./db/conf.d:/etc/mysql/conf.d
      - ./db/data:/var/lib/mysql
      - ./db/initdb.d:/docker-entrypoint-initdb.d
    ## 읽을 설정 파일 지정
    env_file: .env
    ## 타임 라인 지정
    environment:
      TZ: Asia/Seoul
    ## network 지정
    networks:
      - backend
    ## 재시작 옵션 적용
    restart: always

networks:
  backend:
    ## network 사용 이름 지정 - 버전에 따라 사요할 수 없을 떄가 있음
    name: dt-network
```

- 주의 사항
  - network 사용 시 `networks-> 지정이름 -> name : ??`와 같이 지정을 해주지 않으면 `해당 yml파일이 있는 디렉토리명_네트워크명`으로 자동 적용 되므로 꼭 확인하자
- 커맨드에서 사용한 것보다 옵션을 조금 더 많이 사용하였지만 보이는 것과 같이
  `docker-compse`를 사용하면 긴 명령어로 사용해야하는 옵션들을 한번에 실행 할 수 있는 파일로 생성이 가능 하다.
- 사용 명령여
  - 해당 파일 디렉토리로 이동 후`docker-compose up -d` -d는 백그라운드 실행 의미 이다.


