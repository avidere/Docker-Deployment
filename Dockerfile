FROM tomcat:latest
RUN mv /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps/
ARG host_name
ARG artifact_id
ARG version
ARG build_no
RUN wget http://$host_name/repository/tomcat-Release/example/demo/$artifact_id/$version-$build_no/$artifact_id-$version-$build_no.war
RUN mv $artifact_id-$version-$build_no.war /usr/local/tomcat/webapps/
