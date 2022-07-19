//
//  BLEConnector.swift
//  BLETestJob
//
//  Created by IPS Brar on 19/07/22.
//

import CoreBluetooth
import Foundation

protocol BLEConnectorDelegate {
    func peripheralDidUpdateValueFor(_ bytesArray:[UInt8])
    func deviceFound()
    func deviceConnected(peripheral:CBPeripheral)
}

struct BLEPeripheralDevice {
    var name: String?
    var device: CBPeripheral?
}

class BLEConnector: NSObject {
    
    // Properties
    var centralManager: CBCentralManager!
    
    var peripheral: BLEPeripheralDevice!{
        didSet{
            peripheral.device?.delegate = self
        }
    }
    var devices: [BLEPeripheralDevice] = []
    var delegate: BLEConnectorDelegate?
    var activeCharacteristic: CBCharacteristic?
    var nameCharacteristic: CBCharacteristic?
    
    override init() { }
    
    func initalizeBLE(){
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BLEConnector: CBPeripheralDelegate, CBCentralManagerDelegate {
    // If we're powered on, start scanning
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            centralManager.scanForPeripherals(withServices: nil,
                                              options: nil)
        }
    }
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let device = BLEPeripheralDevice(name: peripheral.name, device: peripheral)
        if peripheral.name != nil && peripheral.name != "" {
            
            if !ifArrayContainsThisDeviceAlready(peripheral: peripheral) {
                self.devices.append(device)
            }
        }
        delegate?.deviceFound()
    }
    
    func ifArrayContainsThisDeviceAlready(peripheral: CBPeripheral) -> Bool {
        for device in self.devices {
            if device.device?.identifier == peripheral.identifier {
                return true
            }
        }
        return false
    }
    
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral.device {
            //   HelpingVC.shared.deviceConnectivityStatus = true
            print("Connected to your Particle Board \(peripheral.name ?? "")")
            peripheral.discoverServices(nil)
            delegate?.deviceConnected(peripheral:peripheral)
        }
    }
    
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices")
        if let services = peripheral.services {
            for service in services {
                print(service)
                print(service.characteristics ?? [])
                
                //Now kick off discovery of characteristics
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(error?.localizedDescription)
        guard let characteristicData = characteristic.value else { return }
    }
    
    
    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor \(service)")
        
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print(characteristic)
            
            //            if characteristic.uuid == ParticlePeripheral.deviceNameCharacteristicUUID {
            if characteristic.properties.contains(.write) {
                print(peripheral.name)
                nameCharacteristic = characteristic
                
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotificationStateFor")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: %s", error.localizedDescription)
            return
        }
        guard let characteristicData = characteristic.value else { return }
        var bytesArray:[UInt8] = []
        for byte in characteristicData{
            bytesArray.append(byte)
        }
        delegate?.peripheralDidUpdateValueFor(bytesArray)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.peripheral.device {
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("didModifyServices")
    }
}
