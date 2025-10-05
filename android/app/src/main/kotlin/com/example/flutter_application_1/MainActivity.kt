package com.example.final_stock

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.content.pm.PackageManager
import android.os.Bundle

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.final_stock/upi"
    private lateinit var methodChannel: MethodChannel
    private var pendingPaymentData: Map<String, String>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "launchUPI" -> {
                    val uri = call.argument<String>("uri") ?: ""
                    val amount = call.argument<String>("amount") ?: ""
                    val planType = call.argument<String>("planType") ?: ""
                    val transactionId = call.argument<String>("transactionId") ?: ""
                    
                    // Store payment data for when we return from UPI app
                    pendingPaymentData = mapOf(
                        "amount" to amount,
                        "planType" to planType,
                        "transactionId" to transactionId
                    )
                    
                    launchUPIApp(uri, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun launchUPIApp(upiUri: String, result: MethodChannel.Result) {
        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(upiUri))
            
            // Try Google Pay first
            val googlePayPackage = "com.google.android.apps.nbu.paisa.user"
            if (isPackageInstalled(googlePayPackage)) {
                intent.setPackage(googlePayPackage)
                startActivity(intent)
                result.success(true)
                return
            }
            
            // Fallback to any UPI app
            val upiApps = packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
            if (upiApps.isNotEmpty()) {
                startActivity(intent)
                result.success(true)
            } else {
                result.error("NO_UPI_APP", "No UPI app found on device", null)
            }
        } catch (e: Exception) {
            result.error("UPI_ERROR", "Error launching UPI app: ${e.message}", null)
        }
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    override fun onResume() {
        super.onResume()
        
        // When app resumes after UPI payment, simulate payment success
        // In real implementation, you'd parse the UPI response
        pendingPaymentData?.let { data ->
            val response = mapOf(
                "Status" to "SUCCESS", // Simulating successful payment
                "responseCode" to "00",
                "transactionId" to data["transactionId"]!!,
                "amount" to data["amount"]!!,
                "planType" to data["planType"]!!
            )
            
            // Send response back to Flutter
            methodChannel.invokeMethod("onUPIResult", response)
            
            // Clear pending data
            pendingPaymentData = null
        }
    }
}