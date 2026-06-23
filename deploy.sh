export JAVA_HOME="/c/Program Files/Eclipse Adoptium/jdk-17.0.19.10-hotspot"
export PATH="$JAVA_HOME/bin:$PATH"
ADB="/c/Users/wardi/AppData/Local/Android/Sdk/platform-tools/adb.exe"

echo "🔨 Building APK..."
flutter build apk --release

echo "📱 Connecting to tablet..."
$ADB connect 192.168.1.5:5555

echo "📦 Installing..."
$ADB install -r build/app/outputs/flutter-apk/app-release.apk

echo "✅ Done!"
