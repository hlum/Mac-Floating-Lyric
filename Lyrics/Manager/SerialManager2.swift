//
//  SerialManager2.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/25.
//


//
//  SerialManager2.swift
//  Controller
//
//  Created by Hlwan Aung Phyo on 2025/02/20.
//

import Foundation
import OSLog
import ORSSerial

final class SerialManager2: NSObject, ORSSerialPortDelegate{
    var serialPort: ORSSerialPort?
    
    static let shared = SerialManager2()
    
    override init() {
        super.init()
        setupSerialPort()
    }

    var receivedMessage: ((String) -> Void)?

    private var portPath: String? {
        return findArduinoPort()
    }

    
    private func findArduinoPort() -> String? {
        let fileManager = FileManager.default
        let devPath = "/dev/"
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: devPath)
            let arduinoPorts = contents.filter { $0.contains("cu.usbmodem") }
            
            if let port = arduinoPorts.first {
                return "/dev/\(port)"
            }
        } catch {
            Logger.standard.error("❌ Failed to list /dev directory: \(error)")
        }
        
        return nil
    }
    
    private func setupSerialPort() {
        guard let portPath else {
            Logger.standard.error("❌ Arduino port not found.")
            return
        }
        
        serialPort = ORSSerialPort(path: portPath)
        Logger.standard.info("path: \(portPath)")
        guard let serialPort else {
            Logger.standard.error("❌ Failed to create ORSSerialPort.")
            return
        }
        serialPort.delegate = self
        serialPort.baudRate = 9600
        serialPort.numberOfDataBits = 8
        serialPort.parity = .none
        serialPort.numberOfStopBits = 1

        serialPort.open()
        
        if serialPort.isOpen {
            serialPort.rts = false
            serialPort.dtr = true
        }
        
        
        // Add this to setupSerialPort() after opening the port
        Logger.standard.info("Port settings - Baud: \(serialPort.baudRate), Parity: \(serialPort.parity.rawValue), Stop bits: \(serialPort.numberOfStopBits)")
        
        print("✅ Serial port opened and RTS/DTR set.")

    }
    
    func sendMessage(message: String) {
        
        let messageToSend = "\(message)\n"
        if let data = messageToSend.data(using: .ascii) {
            guard let serialPort else {
                Logger.standard.error("No serial port to send data to!")
                return
            }
            
            Logger.standard.info("result: \(serialPort.send(data))")

        }
    }
    
    
    
//    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
//        print("🔍 Raw Data Received:", data as NSData)  // Debug raw bytes
//
//        guard let message = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
//              !message.isEmpty else { return }
//        
//        logger.info("\(message)")
//        DispatchQueue.global().async {
//            self.receivedMessage?(message)
//        }
//    }
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        Logger.standard.error("Port was removed from system!")
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        Logger.standard.error("Serial port error: \(error)")
    }

    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        Logger.standard.info("Serial port was opened successfully")
    }

    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        Logger.standard.error("Serial port was closed")
    }
}
