# Cert-Fixer

Cert-Fixer is a Magisk module that copies all the user certificates to system certificate store.

Tested on `AVD Emulator Pixel 8 API 35 (Android 15)`.

# How to

1. Root your Android device using Magisk.
2. Install your CA certificate as user certificate.
3. Download `Cert-Fixer.zip` and install Cert-Fixer module in Magisk.
4. Reboot.  
   During reboot, Cert-Fixer will copy your user certificates to system store.
5. Your user certificates should be available in system store now!

## Notes
1. If there are multiple versions of the same certificate (same hash, but different extensions), only the latest certificate will be copied.


# Description and Credits

Since Android 14 (API 34), it has become too hard to add custom certificates to the system store. This is because the system certificates are now stored in APEX (Android Pony EXpress) containers which are immutable. Now, `/apex/com.android.conscrypt/cacerts` is the file location for the system CA certificates.

Tim Perry has discussed the changes and motivation behind them in his [blog post](https://httptoolkit.com/blog/android-14-install-system-ca-certificate/#how-to-install-system-ca-certificates-in-android-14). [AdguardTeam](https://github.com/AdguardTeam) has done a [nice implementation](https://github.com/AdguardTeam/adguardcert/blob/9b0fe1e0907228a2dd69e4b0fe9cac848add336a/module/post-fs-data.sh) of this in their [adguardcert](https://github.com/AdguardTeam/adguardcert) Magisk module. Adguardcert module copies their CA certificate at boot time, right after `/data` is decrypted and mounted ([Refer to Android initialization stages](https://sx.ix5.org/info/android-init-stages/)). Cert-Fixer is simply an adoption (minor modification) of the Adguardcert implementation. All credit to Tim and Adguard for finding the technique. Cert-Fixer copies all of the installed user certificates to the system store. 


