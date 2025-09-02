# ======= 첫 번째 스테이지 ======= #
FROM openjdk:17-jdk-alpine as stage1

WORKDIR /app
# /app/copy파일들 생성
# 파일을 복사할 땐 COPY 파일명 파일명
# 폴더를 복사할 때 COPY 폴더명 .(현재위치) 로도 가능
COPY gradle gradle
COPY src src
COPY build.gradle .
COPY settings.gradle .
COPY gradlew .
RUN chmod +x gradlew
RUN ./gradlew bootJar



# ===== 두 번째 스테이지 ===== (FROM이 또 나오면 two stage가 나오게 됨) #
# 이미지 경량화를 위해 스테이지 분리
FROM openjdk:17-jdk-alpine
WORKDIR /app
# stage1의 파일을 stage2로 copy
# stage1에 있는 *.jar파일을 stage2에 app.jar라는 이름의 파일로 생성
# jar파일명은 settings.gradle파일의 rootProject.name + build.gradle파일의 version (또는 *.jar를 copy    )
COPY --from=stage1 /app/build/libs/*.jar app.jar
# 실행 : CMD 또는 ENTRYPOINT를 통해 컨테이너 실행
ENTRYPOINT [ "java", "-jar", "app.jar" ]

# 도커이미지 빌드
# docker build -t 이미지명:태그명(버전) -f 도커파일위치 빌드컨텍스트위치
# docker build -t ordersystem:v1.0 .

# 도커컨테이너 실행
# docker run 이미지명:버전명
# docker run --name my-ordersystem -d -p 8080:8080 ordersystem:v1.0

# docker 내부에서 localhost를 찾는 설정은 루프백 문제 발생
# 도커컨테이너 실행시점에 docker.host.internal을 환경변수로 주입 (yml 설정은 유지)
# docker run --name my-ordersystem -d -p 8080:8080 -e SPRING_REDIS_HOST=host.docker.internal -e SPRING_DATASOURCE_URL=jdbc:mariadb://host.docker.internal:3307/ordersystem ordersystem:v1.0



# dockerfile의 장점
# 1. build 자동화
# 2. 환경 통제(ex> window OS에서 linux로)