//
//  PeripheralManager.swift
//  Lyrics
//
//  Created by cmStudent on 2025/04/02.
//


//
//  PeripheralManager.swift
//  MacBTScanner
//
//  Created by Hlwan Aung Phyo on 2025/03/25.
//

import CoreBluetooth

class PeripheralManager: NSObject, CBPeripheralDelegate {
    static let shared = PeripheralManager()
    
    private override init() { super.init() }
    
    var esp32: CBPeripheral?
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics([CBUUID(string: UUIDStrings.characteristicUUIDString)],
                                               for: service)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        for characteristic in service.characteristics ?? [] {
            BluetoothManager.shared.esp32Characteristic = characteristic
            if characteristic.uuid.uuidString == UUIDStrings.characteristicUUIDString {
                esp32?.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error {
            Logger.standard.error("Error writing value: \(error)")
        } else {
            Logger.standard.info(">>> Sent data")
        }
    }
}
