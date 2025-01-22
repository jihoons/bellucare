package co.weseeks.bellucare

import android.Manifest
import android.os.Build
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "co.weseeks.bellucare.android.channel")
        channel.setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "getPhoneNumber") {
                result.success(getPhoneNumber())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getPhoneNumber(): List<String> {
        val phoneNumbers = mutableListOf<String>()
        try {
            Log.i("telephone", "SDK version ${android.os.Build.VERSION.SDK_INT}")
            val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
            val phoneCount = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R ) {
                telephonyManager.activeModemCount
            } else {
                telephonyManager.phoneCount
            }
            Log.i("telephone", "phoneCount: $phoneCount")
            val subscriptionService =  getSystemService(TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                Log.i("telephone", "get phoneNumber over TIRAMISU")
                for (i in 0 until phoneCount) {
                    val phoneNumber = subscriptionService.getPhoneNumber(i)
                    Log.i("telephone", "phone number of $i is [$phoneNumber]")
                    phoneNumbers.add(phoneNumber)
                }
            } else {
                Log.i("telephone", "get phoneNumber under TIRAMISU")
                val list = subscriptionService.activeSubscriptionInfoList
                list?.filter { it != null && it.number != null }?.forEach {
                    val phoneNumber = it.number
                    if (phoneNumber != null && phoneNumber.isNotBlank()) {
                        phoneNumbers.add(phoneNumber)
                    }
                }
            }
            return phoneNumbers.filter { it != null && it.isNotEmpty() }.toList()
        } catch (e: Exception) {
            Log.e("telephone", "Exception: $e")
            return phoneNumbers
        }
    }
}
