#!/system/bin/sh

exec > /data/local/tmp/cert-fixer.log
exec 2>&1

set -x

MODDIR=${0%/*}

set_context() {
    [ "$(getenforce)" = "Enforcing" ] || return 0

    default_selinux_context=u:object_r:system_file:s0
    selinux_context=$(ls -Zd $1 | awk '{print $1}')

    if [ -n "$selinux_context" ] && [ "$selinux_context" != "?" ]; then
        chcon -R $selinux_context $2
    else
        chcon -R $default_selinux_context $2
    fi
}

# Read all the certificates ignoring the version.
# Later in the loop, the latest version of each certificate will be identified and copied to the system store
ls /data/misc/user/*/cacerts-added/* | grep -o -E '[0-9a-fA-F]{8}.[0-9]+$' | cut -d '.' -f1 | sort | uniq > /data/local/tmp/cert-fixer.certs-found

while read USER_CERT_HASH; do

    USER_CERT_FILE=$(ls /data/misc/user/*/cacerts-added/${USER_CERT_HASH}.* | (IFS=.; while read -r left right; do echo $right $left.$right; done) | sort -nr | (read -r left right; echo $right))

    if ! [ -e "${USER_CERT_FILE}" ]; then
        exit 0
    fi

    rm -f /data/misc/user/*/cacerts-removed/${USER_CERT_HASH}.*

    cp -f ${USER_CERT_FILE} ${MODDIR}/system/etc/security/cacerts/${USER_CERT_HASH}.0
    chown -R 0:0 ${MODDIR}/system/etc/security/cacerts
    set_context /system/etc/security/cacerts ${MODDIR}/system/etc/security/cacerts

    # Android 14 support
    # Since Magisk ignore /apex for module file injections, use non-Magisk way
    if [ -d /apex/com.android.conscrypt/cacerts ]; then
        # Clone directory into tmpfs
        rm -f /data/local/tmp/adg-ca-copy
        mkdir -p /data/local/tmp/adg-ca-copy
        mount -t tmpfs tmpfs /data/local/tmp/adg-ca-copy
        cp -f /apex/com.android.conscrypt/cacerts/* /data/local/tmp/adg-ca-copy/

        # Do the same as in Magisk module
        cp -f ${USER_CERT_FILE} /data/local/tmp/adg-ca-copy/${USER_CERT_HASH}.0
        chown -R 0:0 /data/local/tmp/adg-ca-copy
        set_context /apex/com.android.conscrypt/cacerts /data/local/tmp/adg-ca-copy

        # Mount directory inside APEX, and remove temporary one.
        mount --bind /data/local/tmp/adg-ca-copy /apex/com.android.conscrypt/cacerts
        for pid in 1 $(pgrep zygote) $(pgrep zygote64); do
            nsenter --mount=/proc/${pid}/ns/mnt -- \
                /bin/mount --bind /data/local/tmp/adg-ca-copy /apex/com.android.conscrypt/cacerts
        done

        umount /data/local/tmp/adg-ca-copy
        rmdir /data/local/tmp/adg-ca-copy
    fi

done </data/local/tmp/cert-fixer.certs-found
