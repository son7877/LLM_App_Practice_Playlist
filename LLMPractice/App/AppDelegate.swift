import UIKit
import MusicKit
import UserNotifications
#if canImport(KakaoSDKAuth)
import KakaoSDKAuth
#endif

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication, 
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { // 앱이 실행되었을 때 호출되는 메서드
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        #if canImport(KakaoSDKAuth)
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        #endif
        return false
    }
}



