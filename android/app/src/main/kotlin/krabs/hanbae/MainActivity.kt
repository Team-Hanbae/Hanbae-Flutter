package krabs.hanbae

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.SoundPool
import android.media.AudioAttributes
import android.content.res.Resources
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "krabs.hanbae/sound"
    private lateinit var soundPool: SoundPool
    private val soundMap = HashMap<String, Int>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_MEDIA)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .build()

        soundPool = SoundPool.Builder()
            .setAudioAttributes(audioAttributes)
            .setMaxStreams(10)
            .build()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    val name = call.argument<String>("name")
                    if (name != null) {
                        val soundId = soundMap[name] ?: loadSound(name)
                        if (soundId != null) {
                            soundPool.play(soundId, 1f, 1f, 1, 0, 1f)
                            result.success(null)
                        } else {
                            result.error("SOUND_NOT_FOUND", "Sound file not found for name: $name", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Missing sound name", null)
                    }
                }
                "preload" -> {
                    val name = call.argument<String>("name")
                    if (name != null) {
                        loadSound(name)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Missing sound name", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun loadSound(name: String): Int? {
        val resId = resources.getIdentifier(name.lowercase(), "raw", packageName)
        return if (resId != 0) {
            val soundId = soundPool.load(this, resId, 1)
            soundMap[name] = soundId
            soundId
        } else {
            Log.e("SoundManager", "Resource not found: $name")
            null
        }
    }
}