import Foundation
import SocketIO
import SwiftyJSON

class SocketIOManager: NSObject {
    private var manager : SocketManager
    var socket : SocketIOClient
    static let shared = SocketIOManager()
    
    override init(){
        manager = SocketManager(socketURL: URL(string: API.baseURL)!, config: [.log(true), .compress])
        socket = manager.defaultSocket
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func sendRequest(key : String , parameter: [String : Any]) {
        if self.socket.status == .connected {
            SocketIOManager.shared.socket.emit(key, parameter)
        }else{
            self.establishConnection()
        }
    }
    
    func joinChatRoom(){
        if GConstant.UserData != nil {
            SocketIOManager.shared.socket.emit("join", ["user_id": GConstant.UserData.id])
        }
    }
    
    func isConnectionValid() -> Bool {
        if self.socket.status == .connected {
            return true
        }else{
            self.establishConnection()
        }
        return false
    }
    
    //MARK:- Swipe LEFT, RIGHT, TOP, BOTTOM Listners
    func swipeUp(completion: @escaping () -> Void) {
        socket.on(SocketEvents.swipeUp) { (responseArray, socketAck) -> Void in
            if responseArray.count > 0 {
                completion()
            }
        }
    }
    
    func swipeDown(completion: @escaping () -> Void) {
        socket.on(SocketEvents.swipeDown) { (responseArray, socketAck) -> Void in
            if responseArray.count > 0 {
                completion()
            }
        }
    }
    
    func swipeLeft(completion: @escaping () -> Void) {
        socket.on(SocketEvents.swipeLeft) { (responseArray, socketAck) -> Void in
            if responseArray.count > 0 {
                completion()
            }
        }
    }
    
    func swipeRight(completion: @escaping () -> Void) {
        socket.on(SocketEvents.swipeRight) { (responseArray, socketAck) -> Void in
            if responseArray.count > 0 {
                completion()
            }
        }
    }
    
    //MARK:- Freeze Listner
    func streamingPause(completion: @escaping () -> Void) {
        socket.on(SocketEvents.pause) { (responseArray, socketAck) -> Void in
            if responseArray.count > 0 {
                completion()
            }
        }
    }
    
    func streamingPlay(completion: @escaping () -> Void) {
        socket.on(SocketEvents.play) { (responseArray, socketAck) -> Void in
            if responseArray.count > 0 {
                completion()
            }
        }
    }
    
    //MARK:- Dot Listener
    func focusPoint(completion: @escaping (FocusPointManager) -> Void) {
        socket.on(SocketEvents.dotPosition) { (responseArray, socketAck) -> Void in
            if responseArray.count > 0 {
                if let json = responseArray[0] as? [String:Any] {
                    let manager = FocusPointManager()
                    manager.handleData(json)
                    completion(manager)
                }
            }
        }
    }
    
    func drawPoint(completion: @escaping (DrawPointManager) -> Void) {
        socket.on(SocketEvents.drawPosition) { (responseArray, socketAck) -> Void in
            if responseArray.count > 0 {
                if let json = responseArray[0] as? [String:Any] {
                    let manager = DrawPointManager()
                    manager.handleData(json)
                    completion(manager)
                }
            }
        }
    }
    
    func callInit(completion: @escaping () -> Void) {
        socket.on(SocketEvents.initCall) { (responseArray, socketAck) -> Void in
            if responseArray.count > 0 {
                completion()
            }
        }
    }
    
    func shareLocation(completion: @escaping (ShareLocationManager) -> Void) {
        socket.on(SocketEvents.shareLocation) { (responseArray, socketAck) -> Void in
            if responseArray.count > 0 {
                if let json = responseArray[0] as? [String:Any] {
                    let manager = ShareLocationManager()
                    manager.handleData(json)
                    completion(manager)
                }
            }
        }
    }
    
    func receiveMessage(completion: @escaping (MessageManager) -> Void) {
        socket.on(SocketEvents.receiveMessage) { (responseArray, socketAck) -> Void in
            if responseArray.count > 0 {
                if let json = responseArray[0] as? [String:Any] {
                    let manager = MessageManager()
                    manager.handleData(json)
                    completion(manager)
                }
            }
        }
    }
    
    func callDeclined(completion: @escaping () -> Void) {
        socket.on(SocketEvents.callDeclined) { (responseArray, socketAck) -> Void in
            if responseArray.count > 0 {
                completion()
            }
        }
    }
    
    func noShow(completion: @escaping () -> Void) {
        socket.on(SocketEvents.noShow) { (responseArray, socketAck) -> Void in
            if responseArray.count > 0 {
                completion()
            }
        }
    }
    

}

// MARK:- Share Location Model

class ShareLocationManager {
    var latitude, longitude, timestamp, message: String!
    
    func handleData(_ dict: Dictionary<String, Any>) {
        let data = dict["data"] as! NSDictionary
        
        if let lat = data["streamer_lat"] as? String {
            self.latitude = lat
        }else{
            self.latitude = ""
        }
        
        if let lng = data["streamer_long"] as? String {
            self.longitude = lng
        }else{
            self.longitude = ""
        }
        
        self.timestamp = data["timestamp"] as? String
        self.message = data["message"] as? String
    }
}

// MARK:- Message Model

class MessageManager {
    var message, name, image, timestamp, receiverID: String!
    
    func handleData(_ dict: Dictionary<String, Any>) {
        let data = dict["data"] as! NSDictionary
        
        self.message = data["message"] as? String
        self.receiverID = data["receiver_id"] as? String
        self.name = data["sender_name"] as? String
        self.image = data["sender_image"] as? String
        self.timestamp = data["timestamp"] as? String
    }
}

// MARK:- Focus Point Model

class FocusPointManager {
    var cgPoint: CGPoint!
    var frameSize: CGSize!
    var deviceType: String!
    
    func handleData(_ dict: Dictionary<String, Any>) {
        let data = dict["data"] as! NSDictionary
        var cx, cy, dWidth, dHeight: Double!
        if let x = data["coordinateX"] as? String {
            cx = Double(x)!
        }
        
        if let y = data["coordinateY"] as? String {
            cy = Double(y)!
        }
        
        if let width = data["deviceWidth"] as? String {
            dWidth = Double(width)!
        }
        
        if let height = data["deviceHeight"] as? String {
            dHeight = Double(height)!
        }
        
        cgPoint = CGPoint(x: cx, y: cy)
        frameSize = CGSize(width: dWidth, height: dHeight)
        deviceType = data["device_type"] as? String
    }
    
}

// MARK:- Draw Point Model

class DrawPointManager {
    var arrCGPoints: [CGPoint] = []
    var deviceType: String!
    var frameSize: CGSize!
    
    func handleData(_ dict: Dictionary<String, Any>) {
        let data = dict["data"] as! NSDictionary
        var cx, cy, dWidth, dHeight: Double!
        
        let arrData = data["coordinates"] as! NSArray
        for i in 0 ..< arrData.count {
            let coordDic = arrData[i] as! NSDictionary
            
            if let x = coordDic["x"] as? String {
                cx = Double(x)!
            }
            
            if let y = coordDic["y"] as? String {
                cy = Double(y)!
            }
            
            arrCGPoints.append(CGPoint(x: cx, y: cy))
        }
        
        if let width = data["device_width"] as? String {
            dWidth = Double(width)!
        }
        
        if let height = data["device_height"] as? String {
            dHeight = Double(height)!
        }
        
        frameSize = CGSize(width: dWidth, height: dHeight)
        deviceType = data["device_type"] as? String
    }
    
}

