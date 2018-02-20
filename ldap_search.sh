#!/bin/bash

DOMAIN=<.com domain>
DCOMP=<domain without .com>
OUPATH=<comma separated OU path>

RESPONSE=0
while true;
do
        echo " "
        echo "Easy LDAP Query Tool"
        echo "   1 - list all users in AD"
        echo "   2 - list all groups in AD"
        echo "   3 - list all members of a given group"
        echo "   4 - exit"
        read -p 'Enter 1-4:  ' RESPONSE
        if [ $RESPONSE -eq 4 ]; then
                exit 0
        fi
        echo " "
        echo " "
        case $RESPONSE in
                1)
                        ldapsearch -b "OU=Divisions,DC=${DCOMP},DC=com" \
                                -D "${OUPATH}" \
                                -h "${DOMAIN}" \
                                -l 120 \
                                -s sub "(&(objectCategory=user)(objectClass=user)(cn=*)(employeeID=*))" \
                                -W \
                                -x
                        ;;
                2)
                        ldapsearch -b "OU=Divisions,DC=${DCOMP},DC=com" \
                                -D "${OUPATH}" \
                                -h "${DOMAIN}" \
                                -l 120 \
                                -s sub "(&(objectCategory=group)(objectClass=group)(cn=*))" \
                                -W \
                                -x
                        ;;
                3)
                        read -p "What is the group name?  " GRPNAME
                        #first query to get the FQDN of the group
                        GRPFQDN=$(ldapsearch    -b "OU=Divisions,DC=${DCOMP},DC=com" \
                                                -D "${OUPATH}" \
                                                -h "${DOMAIN}" \
                                                -l 120 \
                                                -s sub "(&(objectCategory=group)(CN=$(echo $GRPNAME)))" \
                                                -W \
                                                -x cn | awk '/dn:/ {print $2;}')
                        #second query for the users
                        ldapsearch -b "OU=Divisions,DC=${DCOMP},DC=com" \
                                -D "${OUPATH}" \
                                -h "${DOMAIN}" \
                                -s sub "(&(objectCategory=user)(memberOf=$(echo $GRPFQDN)))" \
                                -W \
                                -x \
                                cn | awk '/cn:/ {print $2;}'
                        ;;
                4)
                        exit 0
                        ;;
                *)
                        echo "invalid entry"
                        ;;
        esac
        echo ""
        echo ""
        echo ""
done
