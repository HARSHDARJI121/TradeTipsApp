import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.final_stock/upi"
    private val UPI_REQUEST_CODE = 100

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "launchUPI") {
                    val uri = call.argument<String>("uri")
                    val intent = Intent(Intent.ACTION_VIEW, android.net.Uri.parse(uri))
                    startActivityForResult(intent, UPI_REQUEST_CODE)
                    result.success(true)
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == UPI_REQUEST_CODE) {
            val response = data?.extras?.let {
                mapOf(
                    "Status" to it.getString("Status"),
                    "responseCode" to it.getString("responseCode"),
                    "amount" to it.getString("amount"),
                    "planType" to it.getString("planType"),
                    "transactionId" to it.getString("transactionId")
                )
            } ?: mapOf()
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("onUPIResult", response)
        }
    }
}