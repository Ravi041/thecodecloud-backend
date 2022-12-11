FROM tomcat:8
MAINTAINER odiadevops@gmail.com
#Take the war file and copy to webapps of tomcat
COPY target/*.war /usr/local/tomcat/webapps/devopsodia.war
CMD ["catalina.sh", "run"]
EXPOSE 8080