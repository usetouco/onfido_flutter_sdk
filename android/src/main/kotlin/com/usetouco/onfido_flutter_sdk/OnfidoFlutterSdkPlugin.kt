package com.usetouco.onfido_flutter_sdk

import android.content.Intent
import androidx.annotation.NonNull
import com.onfido.android.sdk.capture.ExitCode
import com.onfido.android.sdk.capture.Onfido
import com.onfido.android.sdk.capture.Onfido.OnfidoResultListener
import com.onfido.android.sdk.capture.OnfidoConfig
import com.onfido.android.sdk.capture.OnfidoFactory
import com.onfido.android.sdk.capture.errors.OnfidoException
import com.onfido.android.sdk.capture.ui.options.FlowStep
import com.onfido.android.sdk.capture.upload.Captures
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar

class OnfidoFlutterSdkPlugin() : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var methodChannel: MethodChannel

    private var onfidoSdk: Onfido? = null

    private var activityBinding: ActivityPluginBinding? = null

    private var startFlowResult: Result? = null

    private fun onActivityBinding(binding: ActivityPluginBinding) {
        onfidoSdk = OnfidoFactory.create(binding.activity.applicationContext).client
        this.activityBinding = binding
        binding.addActivityResultListener(this)
    }

    private fun onActivityUnbinding() {
        activityBinding?.removeActivityResultListener(this)
        this.activityBinding = null

        onfidoSdk = null
    }

    private fun onAttachedToEngine(messenger: BinaryMessenger) {
        methodChannel = MethodChannel(messenger, channelName)
        methodChannel.setMethodCallHandler(this)
    }

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        onAttachedToEngine(binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    companion object {
        private const val onfidoRequestCode = 49564

        private const val channelName = "onfido_flutter_sdk"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = OnfidoFlutterSdkPlugin()
            plugin.onAttachedToEngine(registrar.messenger())

            registrar.addActivityResultListener(plugin)
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        onActivityBinding(binding)
    }

    override fun onDetachedFromActivity() {
        onActivityUnbinding()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onActivityBinding(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onActivityUnbinding()
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "startFlow" -> {
                if (onfidoSdk != null && activityBinding != null) {
                    startFlowResult = result

                    val sdkToken = call.argument<String>("sdkToken")!!
                    val stepsArg = call.argument<List<String>>("flowSteps")!!
                    val steps = toFlowSteps(stepsArg)

                    startFlow(sdkToken, steps)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun toFlowSteps(flowSteps: List<String>): Array<FlowStep> {
        val stringToStep: (String) -> FlowStep = {
            when (it) {
                "welcome" -> FlowStep.WELCOME
                "captureDocument" -> FlowStep.CAPTURE_DOCUMENT
                "captureFace" -> FlowStep.CAPTURE_FACE
                "finalScreen" -> FlowStep.FINAL
                else -> FlowStep.FINAL
            }
        }

        return flowSteps.map(stringToStep).toTypedArray()
    }

    private fun startFlow(sdkToken: String, flowSteps: Array<FlowStep>) {
        val onfidoConfig = OnfidoConfig.builder(activityBinding!!.activity.applicationContext)
                .withSDKToken(sdkToken)
                .withCustomFlow(flowSteps)
                .build()

        onfidoSdk!!.startActivityForResult(
                activityBinding!!.activity,
                onfidoRequestCode,
                onfidoConfig
        )
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == onfidoRequestCode) {
            onfidoSdk!!.handleActivityResult(resultCode, data, object : OnfidoResultListener {
                override fun userExited(exitCode: ExitCode) {
                    startFlowResult?.success(hashMapOf(
                            "method" to "onUserExited"
                    ))
                }

                override fun userCompleted(captures: Captures) {
                    startFlowResult?.success(hashMapOf(
                            "method" to "onUserCompleted"
                    ))
                }

                override fun onError(exception: OnfidoException) {
                    startFlowResult?.success(hashMapOf(
                            "method" to "onError",
                            "message" to exception.message
                    ))
                }
            })

            startFlowResult = null
            return true
        }

        return false
    }

}
