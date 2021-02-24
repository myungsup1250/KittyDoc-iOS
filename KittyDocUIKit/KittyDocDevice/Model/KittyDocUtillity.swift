//
//  KittyDocUtillity.swift
//  KittyDocBLEUIKit
//
//  Created by 곽명섭 on 2021/01/22.
//

//import Foundation
import CoreBluetooth
import UIKit
import UserNotifications

struct DFUResponse {
    var responseCode: UInt8
    var requestedCode: UInt8
    var responseStatus: UInt8
}

enum EnumFileExtension: String {
    case HEX = "hex"
    case BIN = "bin"
    case ZIP = "zip"
}

enum InitPacketParam: Int {
    case START_INIT_PACKET = 0x00, END_INIT_PACKET
//    case START_INIT_PACKET = 0x00
//    case END_INIT_PACKET
}

enum DfuOperations: Int {
    case START_DFU_REQUEST                      = 0x01
    case INITIALIZE_DFU_PARAMETERS_REQUEST      = 0x02
    case RECEIVE_FIRMWARE_IMAGE_REQUEST         = 0x03
    case VALIDATE_FIRMWARE_REQUEST              = 0x04
    case ACTIVATE_AND_RESET_REQUEST             = 0x05
    case RESET_SYSTEM                           = 0x06
    case PACKET_RECEIPT_NOTIFICATION_REQUEST    = 0x08
    case RESPONSE_CODE                          = 0x10
    case PACKET_RECEIPT_NOTIFICATION_RESPONSE   = 0x11
}

enum DfuOperationStatus: Int {
    case OPERATION_SUCCESSFUL_RESPONSE      = 0x01
    case OPERATION_INVALID_RESPONSE         = 0x02
    case OPERATION_NOT_SUPPORTED_RESPONSE   = 0x03
    case DATA_SIZE_EXCEEDS_LIMIT_RESPONSE   = 0x04
    case CRC_ERROR_RESPONSE                 = 0x05
    case OPERATION_FAILED_RESPONSE          = 0x06
}

enum DfuFirmwareTypes: Int {
    case SOFTDEVICE                 = 0x01
    case BOOTLOADER                 = 0x02
    case SOFTDEVICE_AND_BOOTLOADER  = 0x03
    case APPLICATION                = 0x04
}

class KittyDocUtility {
    public static let dfuServiceUUID = CBUUID.init(string: "00001530-1212-EFDE-1523-785FEABCD123")
    public static let dfuControlPointCharacteristicUUID = CBUUID.init(string: "00001531-1212-EFDE-1523-785FEABCD123")
    public static let dfuPacketCharacteristicUUID = CBUUID.init(string: "00001532-1212-EFDE-1523-785FEABCD123")
    public static let dfuVersionCharacteritsicUUID = CBUUID.init(string: "00001534-1212-EFDE-1523-785FEABCD123")

    public static let FIRMWARE_TYPE_SOFTDEVICE = String("softdevice")
    public static let FIRMWARE_TYPE_BOOTLOADER = String("bootloader")
    public static let FIRMWARE_TYPE_APPLICATION = String("application")
    public static let FIRMWARE_TYPE_BOTH_SOFTDEVICE_BOOTLOADER = String("softdevice and bootloader")
    
    var PACKETS_NOTIFICATION_INTERVAL: Int = 10 // final로 상수?
    let PACKET_SIZE: Int = 20
    
//+ (NSArray *) getFirmwareTypes;
//+ (NSString *) stringFileExtension:(enumFileExtension)fileExtension;
//+ (NSString *) getDFUHelpText;
//+ (NSString *) getEmptyUserFilesText;
//+ (NSString *) getEmptyFolderText;
//+ (NSString *) getDFUAppFileHelpText;
//+ (void) showAlert:(NSString *)message;
//+(void)showBackgroundNotification:(NSString *)message;
//+ (BOOL)isApplicationStateInactiveORBackground;


    func getDFUHelpText() -> String {
        return String("-The Device Firmware Update (DFU) app that is compatible with Nordic Semiconductor nRF51822 devices that have the S110 SoftDevice and bootloader enabled.\n\n-It allows to upload new application onto the device over-the-air (OTA).\n\n-The DFU discovers supported DFU devices, connects to them, and uploads user selected firmware applications to the device.\n\n-Default number of Packet Receipt Notification is 10 but you can set up other number in the iPhone Settings.\n\n-(New) Bin format is also supported in this version.\n\n-(New) This version supports Nordic Semiconductor softdevice 7.1 and SDK 7.1 and it is backword compatible. \n\n-(New) In SDK 7.0 and above initPacket is sent in a file (.dat) in addition to firmware file.\n\n-(New) For Application update application.hex or application.bin and application.dat is required inside a zip file.\n\n-(New) For Bootloader update bootloader.hex or bootloader.bin and bootloader.dat is required inside a zip file.\n\n-(New) For Softdevice update softdevice.hex or softdevice.bin and softdevice.dat is required.\n\n-(New) For updating both softdevice and bootloader system.dat is required in addition.")
    }
    
    func getEmptyUserFilesText() -> String {
        return String("-User can add Folders and Files with Hex, Bin and Zip extensions from Emails and iTunes.\n\n-User added files will be appeared here.\n\n- In order to add files from iTunes:\n   1. Open iTunes on your PC and connect iPhone to it.\n   2.On the left, under Devices select your iPhone.\n   3.on the top, select tab Apps.\n   4. on the bottom, under File Sharing select app nRF Toolbox and then add files.")
    }

    func getDFUAppFileHelpText() -> String {
        return String("-User can add Folders and Files with Hex, Bin and Zip extensions from Emails and iTunes.\n\n-User added files will be appeared on tab User Files.\n\n- In order to add files from iTunes:\n   1. Open iTunes on your PC and connect iPhone to it.\n   2.On the left, under Devices select your iPhone.\n   3.on the top, select tab Apps.\n   4. on the bottom, under File Sharing select app nRF Toolbox and then add files.\n\n- In order to add files from Emails:\n   1. Attach file to your email.\n   2.Open your email on your iPhone.\n   3.Long click on attached file and then select Open in nRF Toolbox.")
    }
    
    func getEmptyFolderText() -> String {
        return String("There are no Hex, Bin or Zip files found inside selected folder.")
    }

    func getFirmwareTypes() -> [String] {
        return [KittyDocUtility.FIRMWARE_TYPE_SOFTDEVICE, KittyDocUtility.FIRMWARE_TYPE_BOOTLOADER, KittyDocUtility.FIRMWARE_TYPE_APPLICATION, KittyDocUtility.FIRMWARE_TYPE_BOTH_SOFTDEVICE_BOOTLOADER]
    }
    
    func stringFileExtension(fileExtension: EnumFileExtension) -> String {
        //enum EnumFileExtension: String 정의로 해결
        print("fileExtension.rawValue : \(fileExtension.rawValue)")
        return fileExtension.rawValue
    } // 추후 삭제 : Swift 에는 String Enum 지원된다.
    
    func showAlert(message: String) {
        let alert: UIAlertController = UIAlertController(title: "DFU", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.show(alert, sender: nil)
    }

    func showBackgroundNotification(message: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted: Bool, error: Error?) in
            if !granted || error != nil {
                print("Not granted or There is an Error(\(String(describing: error))")
            } else {
                print("UNUserNotificationCenter.requestAuthorization Done")
            }
        }

//        let fileURL: URL = ... //  your media item file url
//
//        let customContent = UNMutableNotificationContent()
//
//        let attachment = UNNotificationAttachment(identifier: "attachment", url: fileURL, options: nil)
//        customContent.attachments = [attachment!]
        let content = UNMutableNotificationContent()
        content.title = "Show"
        content.body = message
        content.sound = .default//UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(1), repeats: false)
        
        let request = UNNotificationRequest(identifier: "Show", content: content, trigger: trigger)
        center.add(request) { (error: Error?) in
            if error != nil {
                print("error : \(String(describing: error))")
            } else {
                print("UNUserNotificationCenter Request Done!")
            }
        }
        
//        UILocalNotification *notification = [[UILocalNotification alloc]init];
//        notification.alertAction = @"Show";
//        notification.alertBody = message;
//        notification.hasAction = NO;
//        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
//        notification.timeZone = [NSTimeZone  defaultTimeZone];
//        [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    }
    
    func isApplicationStateInactiveORBackground() -> Bool {
        let applicationState: UIApplication.State = UIApplication.shared.applicationState
        if (applicationState == UIApplication.State.inactive || applicationState == UIApplication.State.background) {
            return true
        } else {
            return false
        }
//        return applicationState == UIApplication.State.inactive || applicationState == UIApplication.State.background // 로 교체???
    }
}
