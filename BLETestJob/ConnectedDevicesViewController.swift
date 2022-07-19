//
//  ConnectedDevicesViewController.swift
//  BLETestJob
//
//  Created by IPS Brar on 19/07/22.
//

import UIKit

class ConnectedDevicesViewController: UIViewController {

    @Published var name: String!
    @Published var rssi: String!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var connectedDeviceBGView: UIView!
    @IBOutlet weak var lineView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        lineView.layer.cornerRadius = 2.0
        connectedDeviceBGView.layer.cornerRadius = 8.0
        button.layer.cornerRadius = 20.0
        nameLabel.text = name
        rssiLabel.text = rssi
    }
}

