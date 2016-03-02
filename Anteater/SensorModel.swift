//
//  BLEMananger.m
//  Anteater
//
//  Created by Sam Madden on 1/13/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc protocol SensorModelDelegate: CBCentralManagerDelegate {
    func bleDidConnect()
    func bleDidDisconnect()
    func bleGotSensorReading(reading: BLESensorReading)
}


@objc class SensorModel : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    static let kRblServiceUUID = "713D0000-503E-4C75-BA94-3148F18D941E"
    static let kRblCharTxUUID = "713D0002-503E-4C75-BA94-3148F18D941E"
    static let kRblCharRxUUID = "713D0003-503E-4C75-BA94-3148F18D941E"
    static let kReadingTypePatterns = [kHumidityReading.rawValue : "H\\d*\\.\\d*D", kTemperatureReading.rawValue: "T\\d*\\.\\d*D"]
    static let kErrorRegex = "E."
    
    static let instance = SensorModel()
    var delegate : SensorModelDelegate?
    var sensorReadings : [BLESensorReading] = []
    
    var shouldScan = false
    var isConnected = false
    
    var connectedPeripheral : CBPeripheral?
    var centralManager : CBCentralManager?
    var data : String = ""
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        shouldScan = true
        
        if let central = centralManager {
            self.centralManagerDidUpdateState(central)
        }
    }
    
    func stopScanning() {
        shouldScan = false
        centralManager?.stopScan()
    }
    
    func currentSensorId() -> String? {
        return connectedPeripheral?.name
    }
    
    // MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if (central.state == CBCentralManagerState.PoweredOn && shouldScan) {
            print("Scanning for peripherals...")
            central.scanForPeripheralsWithServices([CBUUID(string: SensorModel.kRblServiceUUID)], options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        print("Discovered peripheral \(peripheral.name)")
        central.connectPeripheral(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true])
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected to peripheral \(peripheral.name)")
        isConnected = true
        delegate?.bleDidConnect()
        peripheral.discoverServices([CBUUID(string: SensorModel.kRblServiceUUID)])
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Disconnected from peripheral \(peripheral.name)")
        isConnected = false
        delegate?.bleDidDisconnect()
        connectedPeripheral = nil
    }
    
    // MARK: CBPeripheralDelegate
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let services = peripheral.services {
            for service in services {
                print("Discovered service on peripheral \(peripheral.name)")
                peripheral.discoverCharacteristics([CBUUID(string: SensorModel.kRblCharTxUUID)], forService: service)
            }
        }

    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let characteristics = service.characteristics {
            for c : CBCharacteristic in characteristics {
                print("Notifying for characteristic on peripheral \(peripheral.name)")
                peripheral.setNotifyValue(true, forCharacteristic: c)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let value = characteristic.value {
            if let output = String(data: value, encoding: NSUTF8StringEncoding) {
                if output.hasPrefix("H") {
                    data = output
                } else {
                    data += output
                }
                processData()
            }
        }
    }
    
    func processData() {
        for error in RegexHelper.listMatches(SensorModel.kErrorRegex, inString: data) {
            print("Encountered error: \(error)")
        }
        
        var readings = [BLESensorReading]()
        
        if let deviceId = connectedPeripheral?.name {
            for (type, pattern) in SensorModel.kReadingTypePatterns {
                for match in RegexHelper.listMatches(pattern, inString: data) {
                    
                    if let value = Float(String(match.characters.dropFirst().dropLast())) {
                        readings.append(BLESensorReading(readingValue: value, andType: SensorReadingType(rawValue: type), atTime: NSDate(), andSensorId: deviceId))
                    }
                    
                    if let newData = RegexHelper.replaceMatches(pattern, inString: data, withString: "") {
                        data = newData
                    }
                }
                
            }
        }
        
        for reading in readings {
            self.sensorReadings.append(reading)
            delegate?.bleGotSensorReading(reading)
            AnteaterREST.postListOfSensorReadings([reading], andCallCallback: nil)
        }
    }
}

