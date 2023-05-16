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

