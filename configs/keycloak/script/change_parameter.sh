#!/bin/sh

sed -i 's|Private_IP|${private_ip}|g' /tmp/keycloak/standalone.xml
sed -i 's|DB_Name|${db_name}|g' /tmp/keycloak/standalone.xml
sed -i 's|DB_Username|${db_username}|g' /tmp/keycloak/standalone.xml
sed -i 's|DB_Password|${db_password}|g' /tmp/keycloak/standalone.xml
sed -i 's|Https_URL|${keycloak_url}|g' /tmp/keycloak/standalone.xml
sed -i 's|DB_String|${db_endpoint}|g' /tmp/keycloak/standalone.xml

