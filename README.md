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

## 도커 이미지 만들기

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

- https://seomal.com/map/1/129
- https://www.youtube.com/watch?v=RMNOQXs-f68