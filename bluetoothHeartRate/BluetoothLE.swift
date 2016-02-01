//
//  BluetoothLE.swift
//  bluetoothHeartRate
//
//  Created by Curtis Bacon on 05/12/2015.
//  Copyright © 2015 Curtis Bacon. All rights reserved.
//

import Foundation
import CoreBluetooth

class BTLE: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var central = CBCentralManager()
    var discoveredPeripheral:CBPeripheral?
    
    let hrmServiceUUID = CBUUID.init( string:"180D" )
    //let scratchCharUUID = CBUUID.init( string:"A495FF21-C5B1-4B44-B512-1370F02D74DE" )
    
    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    // called when a peripheral is discovered
    func centralManager(central: CBCentralManager,
        didDiscoverPeripheral peripheral: CBPeripheral,
        advertisementData: [String : AnyObject],
        RSSI: NSNumber) {
            
            if true
            {
                central.connectPeripheral(peripheral, options: nil)
                
                self.discoveredPeripheral = peripheral
                
                // Hardware beacon
                print("PERIPHERAL NAME: \(peripheral.name)\n AdvertisementData: \(advertisementData)\n RSSI: \(RSSI)\n")
                
                print("UUID DESCRIPTION: \(peripheral.identifier.UUIDString)\n")
                
                print("IDENTIFIER: \(peripheral.identifier)\n")
                
                print( "FOUND PERIPHERALS: \(peripheral) AdvertisementData: \(advertisementData) RSSI: \(RSSI)\n" )
                
                // stop scanning, saves the battery
                central.stopScan()
            }
            
    }
    
    // called when a peripheral connects
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        peripheral.delegate = self
        peripheral.discoverServices(nil )
        
        print("Connected to peripheral")
        var outputStr : String
        outputStr = "Name: " + peripheral.name!
        outputStr = "\(outputStr)\nID: "
        outputStr = outputStr + peripheral.identifier.UUIDString
        print( outputStr )
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print( "FAILED TO CONNECT \(error)" )
    }
    
    // called with BT LE state changes
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        switch central.state {
            
        case .PoweredOff:
            print("CoreBluetooth BLE hardware is powered off")
            break
        case .PoweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready")
            let hrmUUID = CBUUID.init( string:"180D" )
            central.scanForPeripheralsWithServices([hrmUUID] , options: nil)
            break
        case .Resetting:
            print("CoreBluetooth BLE hardware is resetting")
            break
        case .Unauthorized:
            print("CoreBluetooth BLE state is unauthorized")
            break
        case .Unknown:
            print("CoreBluetooth BLE state is unknown")
            break
        case .Unsupported:
            print("CoreBluetooth BLE hardware is unsupported on this platform")
            break
        default:
            break
        }
    }
    
    // callback: called when services are discovered on a peripheral
    
    func peripheral(peripheral: CBPeripheral,
        didDiscoverServices error: NSError?) {
            
            if( error == nil)
            {
                for serv in peripheral.services!
                {
                    //println(serv)
                    peripheral.discoverCharacteristics(nil, forService: serv as CBService)
                }
            }
    }

    // called when characterisics for a service are discovered

    func peripheral(peripheral: CBPeripheral,
        didDiscoverCharacteristicsForService service: CBService,
        error: NSError?)
    {
        if( error == nil )
        {
            for characteristic in service.characteristics!
            {
                print("********FOUND CHARACTERISTIC:")
                print( characteristic )
                if( service.UUID == CBUUID.init( string:"A495FF20-C5B1-4B44-B512-1370F02D74DE"))
                {
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic)
                    peripheral.readValueForCharacteristic(characteristic as CBCharacteristic)
                }
                print(characteristic.UUID)
                if( characteristic.UUID == CBUUID.init( string:"2A37"))
                {
                    print("##Enabling read for 2A37")
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic)
                    peripheral.readValueForCharacteristic(characteristic as CBCharacteristic)
                }
                
            }
        }
    }
    
    // called when notifiactation state is changed from yes to no or vice versa
    
    func peripheral(peripheral: CBPeripheral,
        didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic,
        error: NSError?){
            if( error == nil )
            {
                print( characteristic.value )
            }
    }
    
    // called when a notification is received from the peripheral
    // found notification center code here:
    
    func peripheral(peripheral: CBPeripheral,
        didUpdateValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?)
    {
        // Get the Heart Rate Monitor BPM
        let data = characteristic.value
        let reportData = UnsafePointer<UInt8>(data!.bytes)
        var bpm : UInt16
        var rawByte : UInt8
        var outputString = ""
        rawByte = UInt8(reportData[0])
        bpm = 0
        
        if ((rawByte & 0x01) == 0) {          // 2
            // Retrieve the BPM value for the Heart Rate Monitor
            bpm = UInt16( reportData[1] )
        }
        else {
            bpm = CFSwapInt16LittleToHost(UInt16(reportData[1]))
        }
        
        outputString = String(bpm)
        //println(outputString)
        
        var dataDict = Dictionary<String, Int>()
        dataDict["HeartRate"] = Int(bpm)
            
        NSNotificationCenter.defaultCenter().postNotificationName(heartBeatKey, object:nil, userInfo:["heartRate" : String(bpm)] )
    }
}

