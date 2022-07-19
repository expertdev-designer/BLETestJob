//
//  ViewController.swift
//  BLETestJob
//
//  Created by IPS Brar on 19/07/22.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var bleTableView: UITableView!
    @IBOutlet var tableHeightConstraint : NSLayoutConstraint!

    var connector:BLEConnector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connector = BLEConnector()
        connector?.delegate = self
        connector?.initalizeBLE()
    }
}

extension ViewController: BLEConnectorDelegate {
    
    func peripheralDidUpdateValueFor(_ bytesArray: [UInt8]) {
       
    }
    
    func deviceFound() {
        bleTableView.reloadData()
    }
    
    func deviceConnected(peripheral: CBPeripheral) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ConnectedDevicesViewController") as! ConnectedDevicesViewController
        
        vc.name = peripheral.name ?? "No name available"
        
        let rssiNumber = peripheral.rssi ?? 0
        if rssiNumber != nil && rssiNumber != 0 {
            vc.rssi = "RSSI:- \(rssiNumber)"
        } else {
            vc.rssi = "RSSI:- Not Available"
        }

        self.present(vc, animated: true) {}

        
        print("deviceConnected")
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        tableHeightConstraint.constant =  (100.0 * CGFloat(connector?.devices.count ?? 0)) >= 300.0 ? 300.0 : (100.0 * CGFloat(connector?.devices.count ?? 0))
        tableView.setNeedsLayout()
        self.view.setNeedsLayout()
        return self.connector?.devices.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.layer.cornerRadius = 10.0
        cell.clipsToBounds = true
        let device : BLEPeripheralDevice?
        device = self.connector?.devices[indexPath.row]
        cell.textLabel?.text = device?.name ?? "No name available"
        let rssiNumber = device?.device?.rssi
        if rssiNumber != nil {
            cell.detailTextLabel?.text = "RSSI:- \(rssiNumber)"
        } else {
            cell.detailTextLabel?.text = "RSSI:- Not Available"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.connector?.centralManager.stopScan()
        self.connector?.peripheral = self.connector?.devices[indexPath.row]
        self.connector?.centralManager.connect((self.connector?.peripheral.device)!, options: nil)
    }
}
