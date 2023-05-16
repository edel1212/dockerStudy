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
|-----------|------------|
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
> docker run -p 8888:80 --name syncTest -v ~/Desktop/Project/dockerStudy:/usr/local/apache2/htdocs  httpd

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

- 시나리오 - Command
  - 👉 Dockerfile 실행 : `docker build -t [이미지이름 지정:버전지정] [사용될 Dockerfile 경로]` 

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
  - 👉 image 생성  : `docker commit pyton-ubunt [docker hub 이름]/[image 이름]:[version]` //✅ 테그 기준으로 올라가기 떄문에 맞춰줘야함!!
    - ⭐️ 예시 코드 : `docker commit ptyon-ubuntu edel1212/python:1.0`
    - ⭐️ 예시 코드(테그별로 추가 가능) : `docker commit python-ubuntu-upgrade edel1212/python:2.0`
> 현재 테스트 기준으로 dockerhub 레파지토리 명 : edel1212 / python3 이다.  위의 예시 코드를 사용하면 Tag 버전이 1.0으로 올라간 것을 확인 할 수 있으며
>
> docker pull edel1212/python3:1.0 으로 내려받을 수 있다.


<br/>
<hr/>


- https://seomal.com/map/1/129