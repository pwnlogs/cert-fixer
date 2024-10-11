# Cert-Fixer

Cert-Fixer is a Magisk module that installs custom CA certificates to Android's system certificate store.
This module is tested/known to work on Android 13, 14, and 15 (API 33, 34, and 35). 

[A step-by-step guide for installing custom CA certificates on the system store of Android 15 (API 35)](https://blog.pwnlogs.dev/articles/cert-fixer/index.html).

Tested on AVD Emulators `Pixel 8 API 35 (Android 15)` and `Pixel 8 API 34 (Android 14)`.  
Users have reported as working on `Redme API 33 (Android 13)`.

# How to

1. Root your Android device using [rootAVD](https://gitlab.com/newbit/rootAVD) (rootAVD uses [Magisk](https://github.com/topjohnwu/Magisk)).
2. Complete any pending updates for Magisk, and make sure you have the latest Magisk version.
3. Install your custom CA certificate under user certificate store.
4. Download `Cert-Fixer.zip` and install Cert-Fixer module in Magisk.
5. Reboot.  
   Cert-Fixer will copy all your user certificates to system store at boot up.
6. Your user certificates should now be available in the system store!

## Notes
1. Cert-Fixer copies all the CA certificates from the user store to the system store. Make sure you do not have any untrusted certificates in the user store before reboot.
2. If there are multiple versions of the same certificate (same hash, but different extensions), only the latest certificate will be copied.


# Description and Credits

Since Android 14 (API 34), it has become too hard to add custom certificates to the system store. This is because the system certificates are now stored in APEX (Android Pony EXpress) containers which are immutable. Now, `/apex/com.android.conscrypt/cacerts` is the file location for the system CA certificates.

Tim Perry has discussed the changes and motivation behind them in his [blog post](https://httptoolkit.com/blog/android-14-install-system-ca-certificate/#how-to-install-system-ca-certificates-in-android-14). [AdguardTeam](https://github.com/AdguardTeam) has done a [nice implementation](https://github.com/AdguardTeam/adguardcert/blob/9b0fe1e0907228a2dd69e4b0fe9cac848add336a/module/post-fs-data.sh) of this in their [adguardcert](https://github.com/AdguardTeam/adguardcert) Magisk module. Adguardcert module copies their CA certificate at boot time, right after `/data` is decrypted and mounted ([Refer to Android initialization stages](https://sx.ix5.org/info/android-init-stages/)). Cert-Fixer is simply an adoption (minor modification) of the Adguardcert implementation. All credit to Tim and Adguard for finding the technique. Cert-Fixer copies all of the installed user certificates to the system store. 


