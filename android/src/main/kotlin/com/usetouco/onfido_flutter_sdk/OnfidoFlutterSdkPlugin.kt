package com.usetouco.onfido_flutter_sdk

import androidx.annotation.NonNull
import com.onfido.android.sdk.capture.Onfido
import com.onfido.android.sdk.capture.OnfidoConfig
import com.onfido.android.sdk.capture.OnfidoFactory
import com.onfido.android.sdk.capture.ui.options.FlowStep
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class OnfidoFlutterSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private var client: Onfido? = null
  private var activityBinding: ActivityPluginBinding? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(
            flutterPluginBinding.getFlutterEngine().getDartExecutor(),
            "onfido_flutter_sdk"
    )
    channel.setMethodCallHandler(this)
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "onfido_flutter_sdk")
      channel.setMethodCallHandler(OnfidoFlutterSdkPlugin())
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {
    activityBinding = null
    client = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activityBinding = binding
    client = OnfidoFactory.create(binding.activity.applicationContext).client
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityBinding = binding
    client = OnfidoFactory.create(binding.activity.applicationContext).client
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activityBinding = null
    client = null
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "startFlow" -> {
        if (client != null && activityBinding != null) {
          val sdkToken = call.argument<String>("sdkToken")

          if (sdkToken != null) {
            startFlow(sdkToken)
            result.success("Test success")
          } else {
            result.error(
                    "MISSING_ARGUMENT",
                    "You need pass a valid SDK token",
                    null
            )
          }
        }
      }
      else -> result.notImplemented()
    }
  }

  private fun startFlow(sdkToken: String) {
    val flowSteps = arrayOf(
            FlowStep.WELCOME,
            FlowStep.CAPTURE_DOCUMENT,
            FlowStep.CAPTURE_FACE,
            FlowStep.FINAL
    )

    val onfidoConfig = OnfidoConfig.builder(activityBinding!!.activity.applicationContext)
            .withSDKToken(sdkToken)
            .withCustomFlow(flowSteps)
            .build()

    client!!.startActivityForResult(
            activityBinding!!.activity,
            1,
            onfidoConfig
    )
  }
}
