#!/bin/bash
echo "==================================================================================="
echo "==== Kerberos Client =============================================================="
echo "==================================================================================="
KADMIN_PRINCIPAL_FULL=$KADMIN_PRINCIPAL@$REALM

echo "REALM: $REALM"
echo "KADMIN_PRINCIPAL_FULL: $KADMIN_PRINCIPAL_FULL"
echo ""

function kadminCommand {
    kadmin -p $KADMIN_PRINCIPAL_FULL -w $KADMIN_PASSWORD -q "$1"
}

echo "==================================================================================="
echo "==== /etc/krb5.conf ==============================================================="
echo "==================================================================================="
#tee /etc/krb5.conf <<EOF
#[libdefaults]
#	default_realm = $REALM
#
#[realms]
#	$REALM = {
#		kdc = kdc-kadmin
#		admin_server = kdc-kadmin
#	}
#EOF
echo ""

echo "==================================================================================="
echo "==== Testing ======================================================================"
echo "==================================================================================="
until echo $KADMIN_PASSWORD | kinit $KADMIN_PRINCIPAL_FULL; do
  >&2 echo "KDC unavailable - sleeping 1 sec"
  sleep 1
done

#until kadminCommand "list_principals $KADMIN_PRINCIPAL_FULL"; do
#  >&2 echo "KDC is unavailable - sleeping 1 sec"
#  sleep 1
#echo "KDC and Kadmin are operational"
echo "Got KDC TGT"
