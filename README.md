# Docker Study

## Docker란?

- 리눅스 컨테이너 기반으로하는 오픈소스 가상화 플랫폼이다.
- 각각의 컨테이너에는 OS 전체가 설치 되어있는 것이 아니라, 앱을 실행하는 데에 필요한 library와 실행파일만 설치되어있다. 그렇기 때문에 VM(가상머신)과는 구분되는 것이다.
  - 사용시 장점 ?
    - 어플리케이션 개발간 설정 작업이 굉장히 많은 시간과 비용이 소모되었는데 이것을 가상 컨테이너에 올려서 사용하게되면 쉽게 개발 설정이 가능해진다.
- Docker의 구성
  - Image로 되어있으며 Image를 통해 다수의 Container를 생성할 수 있다.
    - Image란 ?
      - 컨테이너를 실행 할 수 있는 실행 파일, 설정 값들을 가지고 있는 파일이다.
- 간단 비교 (비교대상 App Store 프로그램)

| App Store | Docker Hub |
| --------- | ---------- |
| Program   | Image      |
| Process   | Container  |

<br/>
<hr/>

## Docker 기본 명령어

- Docker Hub에서 필요한 Image Download 방법
  - 👉 명령어 : docker pull [OPTIONS] NAME[:TAG|@DIGEST]
    > docker pull httpd
- 다운 받은 Image 확인
  - 👉 명령어 : docker images
- Dokcer Image를 실행방법
  - 👉 명령어 : docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
    > // 일반 실행  
    > docker run httpd
    >
    > // 이름을 붙여서 실행  
    > docker run --name Foo httpd
- 실행중인 Container log 확인
  - 👉 명령어 : docker logs [OPTIONS] CONTAINER
    > // 일회성 로그 사라짐  
    > docker logs Foo
    >
    > // Watch Mode 사라지지 않고 계속  
    > docker logs -f Foo
- Container 삭제
  - 👉 명령어 : docker rm [OPTIONS] CONTAINER [CONTAINER...]
    - 실행중인 Container가 있을 경우 종료 후 삭제 하거나 옵션을 넣어줘야한다.
      > // 컨테이너 삭제  
      > docker rm Foo
      >
      > // 컨테이터 종료 후 삭제  
      > docker rm --force Foo
- Image 삭제
  - 👉 명령어 : docker rmi [OPTIONS] IMAGE [IMAGE...]
    > docker rmi httpd

<br/>
<hr/>

## Docker Host란?

- Host란 운영체제가 설치된 컴퓨터라 생각하면된다. 하나의 운영 체제 안에서 커널을 공유하며 개별적인 실행 환경을 제공하는 격리된 공간으로써,  
  host에서 실행되는 격리된 각각의 실행 환경이다.
  - 따라서 Dokcer Host 내부에는 여러개의 Container가 존재 할수있다.
- 독립적인 시스템을 갖고있기 때문에 포트가 나눠져있다.
  > // 포트 포워딩을 통해 연결해줘야한다.  
  > docker run -p 80:80 httpd  
  > docker run --name Foo -p 81:80 httpd  
  > docker run --name Foo2 -p 83:80 httpd

## Docker Container 접속방법

- 👉 명령어 : docker exec [OPTIONS] CONTAINER COMMAND [ARG...]
  > // 내부에서 명령어를 실행 시킴  
  > docker exec Foo ls
  > docker exec Foo pwd  
  > // 지속적으로 내부에 접근해서 실행
  > docker exec --it foo /bin/bash
- ✅ 중요한 포인트
  - 내부에서는 vi, nano가 없다
    - 경량화 하기위해 필요한 기능만 들어가있기 때문 따라서 필요시 내부에서 설치 후 사용이 필요하다.
- 👎 단 문제가 있다 위 와 같이 사용하는 것은 굉장히 위험하다
  - 컨테이너가 삭제되면 작업한것이 전부 날라가기 때문이다.

<br/>
<hr/>

## Local 파일과 Container를 동기화 하는 방법

- 호스트 내부에서 파일을 수정 할수 있기 때문에 컨터이너가 사라져도 문제가 없어짐
  > // 이미지를 사용하여 컨테이너를 생성  
  > // 포트는 8888:80  
  > // 이름은 syncTest  
  > // -v 로컬 대상 파일 위치 : 컨테이너 변경 대상위치  
  > docker run -p 8888:80 --name syncTest -v ~/Desktop/Project/dockerStudy:/usr/local/apache2/htdocs httpd

<br/>
<hr/>

## 도커 이미지 만들기 (commit)

- 필요이유

  - 현재 사용중인 Container에 새로운 무언가를 추가하고 그것을 이미지화 한다면 그 이미지를 사용하여 새로운 컨테이너를 추가할 수 있게 된다.

- 시나리오

  - 1 . 우분투 이미지를 다운
  - 2 . 해당 우분투에 깃을 추가하여 이미자화
  - 3 . 해당 우분투는 그냥 우분투가 아닌 깃을 포함한 우분투가됨
  - 4 . 해당 이미지를 기반으로 PHP, Python, Nodejs 등 다양한 서버 환경을 구축이 가능해짐

- 시나리오 - Command
  - 👉 우분투 Download : `docker pull ubuntu`
  - 👉 우분투 컨테이너 실행 : `docker run -it --name my-ubuntu ubuntu bash`
  - 👉 컨테이너 접근 : `docker exec -it my-ubuntu /bin/bash`
  - 👉 apt Upate(깃 설치를 위함) : `apt upate`
  - 👉 git 설치 : `apt install git`
  - > 문제발생 : 현재 컨테이너만 git을 갖고있음 새로 ubuntu image를 써봤자 다시 깔아야함..
  - 👉 git이 설치된 container를 Image 만듬 : `docker commit [타겟 Container] [Image-Name:Tag-Name] `
  - 👉 commit으로 인해 image가 생성되었음 : `docker images`
  - > 위와 같은 방법으로 git이 설치된 우분투를 기점으로 다양한 서버 기반을 설치하여 container가 생성이 가능해짐
  - 👉 node version : `docker run --it --name [이름] [내가 만든 이미지] bash`

<br/>
<hr/>

## 도커 이미지 만들기 (dockerfile & build)

- dockerfile의 장점은 생성될 image의 내용을 파일을 보고 알 수 있다는것이다
- commit 과 build의 공통점
  - Image를 만든다라는 공통점이 있다.
- commit 과 build의 차이점
  - commit의 경우
    - 내가 만든 Container를 기준으로 하여 Image를 생성한다. [ 백업과 같은 느낌 ]
  - dockerfile의 경우
    - 내부에 작성된 명령어의 순서에 맞춰 Image를 생성한다. [ 내가 아예 생성하는 느낌 ]

### RUN, CMD, ENTRYPOINT 이란?

- 3가지의 공통접은 Dockerfile 작성시 사용되는 명령문 중에 실행과 관련된 명령어이다
- 차이점

  - RUN
    - 쉘에서 커맨드를 실행하는 것 처럼 이미지를 빌드 과정에 필요한 커맨드를 실행 하기 위해 사용된다.
    - 보통 이미지 안에 특정 소프트웨어를 설치하기 위해 많이 사용된다.
  - CMD
    - 해당 이미지를 컨테이터로 띄울 때 디폴트로 실행할 커맨드 또는 ENTRYPOINT 명령문으로 지정된 커맨드에 디폴트로 넘길 파라미터를 지정할때 사용 된다.
  - ENTRYPOINT
    - CMD 명령문과 비스샇지만 컨테이터는 띄울때 항상 실행 되야하는 커맨드를 지정할 수있다
    - 해당 명령으로 실행된 프로세스가 죽으면 컨테이너도 함께 종료된다.

- 시나리오
  - 1 . Dockerfile 생성 [ 확장자는 없음 ]
  - 2 . 해당 file 내부
    - 우분투 image를 기반으로 생성
    - apt, python 설치
    - 디렉토리 생성
    - 해당 디렉토리에 로컬파일을 복사하여 추가
    - container 생성 후 원하는 명령어 실행

### DockerFile

#### ✅ 예시 1 - python이 설치되어있는 ubuntu image 생성

```properties
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

<br/>

#### ✅ 예시 2 - node 기반 빌드 후 nginx로 서버 구성

```properties
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

<br/>

#### ✅ 예시 4 - springBoot 어플리케이션 가동 - DB 연결 문제를 해결하기 위해 docker network 사용 필수

```properties
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

- 시나리오 - Command
  - 👉 Dockerfile 실행 : `docker build -t [이미지이름 지정:버전지정] [사용될 Dockerfile 경로]`
    - `docker build -t front:1.0 .` 👉 **'.'** 사용 시 현재 dir의 dockerfile을 읽음
  - 👉 Dockerfile 실행 - 파일지정 : `docker build -t [이미지이름 지정:버전지정] [사용될 Dockerfile 경로] -f 파일경로/파일명 .` ✅ 뒤에 **"."** 중요

<br/>
<hr/>

## 도커 이미지 공유하기 (push)

- Docker에서는 이미지를 만드는 방법이 2가지가 있다
  - 1 . commit을 통해 내가 수정한 컨테이터를 image화 함
  - 2 . build를 통해 Dockerfile을 생성함
- 그렇다면 이것을 공유하여 사람들과 같이 쓰고싶을때는?

  - `push`명령어를 통해 Registry(docker hub)에 올릴 수 있다. **(git과 매우 유사)**

- 시나리오

  - 1 . 우분투로 컨테이너 생성
  - 2 . 해당 컨테이너에 파이썬을 설치
  - 3 . 이미지 생성
  - 4 . Docker hub에 등록

- 시나리오 - Command
  - 👉 우분투 컨테이너 실행 : `docker run -it --name python-ubuntu ubuntu bash`
  - 👉 컨테이너 접근 : `docker exec -it my-ubuntu /bin/bash`
  - 👉 python3 설치 : `apt update && apt install -y python3`
  - 👉 image 생성 : `docker commit pyton-ubunt [docker hub 이름]/[image 이름]:[version]` //✅ 테그 기준으로 올라가기 떄문에 맞춰줘야함!! - ⭐️ 예시 코드 : `docker commit ptyon-ubuntu edel1212/python:1.0` - ⭐️ 예시 코드(테그별로 추가 가능) : `docker commit python-ubuntu-upgrade edel1212/python:2.0`
    > 현재 테스트 기준으로 dockerhub 레파지토리 명 : edel1212 / python3 이다. 위의 예시 코드를 사용하면 Tag 버전이 1.0으로 올라간 것을 확인 할 수 있으며
    >
    > docker pull edel1212/python3:1.0 으로 내려받을 수 있다.

<br/>
<hr/>

## Docker Network

### 도커 네트워크란?

- Docker 컨테이너는 각각 격리된 환경에서 돌아가기 떄문에 **기본적으로 다른 컨테이너와의 통신이 불가능** 하다.
- Docker Network를 생성하여 연결하고 싶은 컨테이너를 연결해주면 각각 독립되어 있던 컨테이너가 **같은 네트워크 상에 있게 되므로 서로간의 연결이 가능**해진다.

### 네트워크의 종류

- Docker Network의 종류로는 `bridge`,`host`,`none`,`container`,`overlay`가 있다.
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

### 명령어

- Docker Network 조회
  - `docker network ls`
- Docker Network 생성
  - `docker network create 이름지정`
- Docker Network 삭제

  - `docker network rm 이름지정`

- 자세한 명령어는 https://docs.docker.com/engine/reference/commandline/network_create/ 확인

<br/>
<hr/>

## Docker Volume

### Volume (-v)란?

- Docker의 특성상 Container이기 때문에 해당 **컨테이터를 삭제**하는 순간 **안에 있던 모든 데이터가 사라진다.**
- 그에 내가 사용하는 Host(머신)에 해당 파일의 중요 데이터의 경로의 데이터와 Host의 경로를 지정하여 동기화를 해주는것.
- Volume 종류
  - 👉 Volume을 직접 생성
    - ex) `docker create volume 볼륨명지정`
      - 해당 방법의 단점은 `Mountpoint`가 임의로 지정이 된다는 것이다. **운영체제별로 다름**
        - 그렇다면 ?
          - `--opt` 옵션을 사용하여 볼륨의 옵션을 수정해 줄 수 있다.
            - ex) `docker create volume --opt device=/Users/yoo/Desktop/DockerVolume 볼륨명지정`

<br/>
<hr/>

## 도커 Compose

### 사용 이유?

- 도커 컨테이너를 실핼할 때마다 연관 관계가 있는 컨테이너들을 하나하나 입력하고 기억하기가 쉽지 않을 것이다.
- 예시와 같이 긴 명령어를 yml 파일 하나로 정리하여 사용하면 `docker-compose up -d` 명령어 한번으로 실행이 가능해 진다.
  - ex) Docker 명령어와 Compose의 사용 비교

### 시나리오 내용

- Mariadb를 사용하는 상황
- 다른 컨테이너 와 연결을 위해 `docker network`또한 필요한 상황
- 기본적으로 mariadbd의 이미지가 존재한다는 가정하에 시작한다.

#### 일반 CLI 명렁어 설치 및 실행

```shell
$ docker run -p 3306:3306                     ## 포트 번호 지정
  --network dt-network                        ## network 지정
  -e MYSQL_ROOT_PASSWORD=123                  ## root pw 지정
  --name mariadb                              ## container 이름 지정
  -v /usr/mariadb-vol:/var/lib/mysql mariadb  ## volume 지정
```

#### Compose를 통한 실행

- docker-compose.yml 파일 - `파일 이름을 변경하면 -t 명령어로 대상을 지정해줘야하는 번거로움 있음`

```properties
## 버전 지정 - 큰 의미는 없음
version: "3"

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
  - network 사용 시 `networks-> 지정이름 -> name : ??`와 같이 지정을 해주지 않으면 `컨테이너명_네트워크명`으로 자동 적용 되므로 꼭 확인하자
- 커맨드에서 사용한 것보다 옵션을 조금 더 많이 사용하였지만 보이는 것과 같이
  `docker-compse`를 사용하면 긴 명령어로 사용해야하는 옵션들을 한번에 실행 할 수 있는 파일로 생성이 가능 하다.
- 사용 명령여
  - 해당 파일 디렉토리로 이동 후`docker-compose up -d` -d는 백그라운드 실행 의미 이다.
