
import Alamofire
import Foundation
class FileDownload {
    
    public static var fileURL:URL?
    public static var isComplete = false
    public static func download(url: URL, completion: @escaping (URL) -> Void){
        
        let fileExtension = url.pathExtension
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("file.\(fileExtension)")
            return (documentsURL, [.removePreviousFile])
        }
        Alamofire.download(url, to: destination).responseData { response in
            if let destinationUrl = response.destinationURL {
                
                fileURL = destinationUrl.absoluteURL
                print("destinationUrl \(destinationUrl.absoluteURL)")
                completion(fileURL!)
            }
        }
        
    }
}
