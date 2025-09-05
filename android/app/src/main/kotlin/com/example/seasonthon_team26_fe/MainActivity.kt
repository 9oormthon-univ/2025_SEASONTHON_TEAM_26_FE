package com.example.seasonthon_team26_fe

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 키 해시 생성 및 로그 출력
        try {
            val info = packageManager.getPackageInfo(packageName, android.content.pm.PackageManager.GET_SIGNATURES)
            info.signatures?.let { signatures ->
                for (signature in signatures) {
                    val md = MessageDigest.getInstance("SHA")
                    md.update(signature.toByteArray())
                    val keyHash = android.util.Base64.encodeToString(md.digest(), android.util.Base64.DEFAULT)
                    Log.d("KeyHash", "Key Hash: $keyHash")
                    Log.i("KeyHash", "Key Hash: $keyHash")
                    Log.w("KeyHash", "Key Hash: $keyHash")
                    Log.e("KeyHash", "Key Hash: $keyHash")
                    println("Key Hash: $keyHash")
                }
            }
        } catch (e: android.content.pm.PackageManager.NameNotFoundException) {
            Log.e("KeyHash", "Package name not found", e)
        } catch (e: NoSuchAlgorithmException) {
            Log.e("KeyHash", "SHA algorithm not found", e)
        }
    }
}
