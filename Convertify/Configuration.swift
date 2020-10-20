import Foundation
import UIKit

class Configuration{
    
    public static let HOST = "material-server.de" // if url has "www" then add host like "www.domain.com" else would be white screen
    
// MARK: - URL or To load local website write path name like "Website/index.html" here Website is the folder of local website
// No need to change host for local website
    public static let URL = "https://material-server.de/schueler.php?device=iosapp"
    
    public static let USER_AGENT:String = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Mobile/15E148 Safari/604.1 Convertify"
    
    public static let ALLOW_BACKWARD_FORWARD_GESTURE = true
    
    public static let EXTERNAL_LINKS_IN_BROWSER = true

    public static let ORIENTATION = 2 // 0 for portrait, 1 for landscape, 2 for both
    
    public static let LOADING_SIGN = true
    
    public static let LOADING_SIGN_COLOR = HexColor.hexValue(hex: "#233714")
    
    public static let PULL_TO_REFRESH = true
    
    public static let STATUS_BAR_COLOR = HexColor.hexValue(hex: "#ffffff")

    public static let STATUS_BAR_TEXT_COLOR = 1 // 0 for white, 1 for black
    
    public static let RATE_DIALOG = false
    
    public static let RATE_DIALOG_AFTER_APP_LAUNCHES = 3 // dialog appears at 4th launch
    
    public static let PUSH_ENABLED = true
    
}
