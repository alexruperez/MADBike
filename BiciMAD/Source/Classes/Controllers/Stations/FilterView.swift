//
//  FilterView.swift
//  BiciMAD
//
//  Created by alexruperez on 21/9/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

import UIKit

@objc class FilterView: UIVisualEffectView {
    @IBOutlet weak fileprivate var greenSwitch: UISwitch!
    @IBOutlet weak fileprivate var redSwitch: UISwitch!
    @IBOutlet weak fileprivate var yellowSwitch: UISwitch!
    @IBOutlet weak fileprivate var graySwitch: UISwitch!

    @objc var stations = [BMStation]() {
        didSet {
            valueChangedAction()
        }
    }
    @objc var shouldHighlightContent = false {
        didSet {
            effect = UIBlurEffect(style: shouldHighlightContent == true ? .dark : .light)
        }
    }
    @objc var handler: ((_ stations: [BMStation], _ green: Bool, _ red: Bool, _ yellow: Bool, _ gray: Bool) -> ())?
    @objc var completion: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        greenSwitch.tintColor = UIColor.bm_green()
        redSwitch.tintColor = UIColor.bm_red()
        yellowSwitch.tintColor = UIColor.bm_yellow()
        graySwitch.tintColor = UIColor.bm_gray()
        greenSwitch.onTintColor = UIColor.bm_green()
        redSwitch.onTintColor = UIColor.bm_red()
        yellowSwitch.onTintColor = UIColor.bm_yellow()
        graySwitch.onTintColor = UIColor.bm_gray()
        greenSwitch.accessibilityLabel = NSLocalizedString("Green stations", comment: "Green stations")
        redSwitch.accessibilityLabel = NSLocalizedString("Red stations", comment: "Red stations")
        yellowSwitch.accessibilityLabel = NSLocalizedString("Yellow stations", comment: "Yellow stations")
        graySwitch.accessibilityLabel = NSLocalizedString("Gray stations", comment: "Gray stations")
    }
    
    @objc func configureFilter(green: Bool, red: Bool, yellow: Bool, gray: Bool) {
        var valueChanged = false
        if green != greenSwitch.isOn {
            greenSwitch.isOn = green
            valueChanged = true
        }
        if red != redSwitch.isOn {
            redSwitch.isOn = red
            valueChanged = true
        }
        if yellow != yellowSwitch.isOn {
            yellowSwitch.isOn = yellow
            valueChanged = true
        }
        if gray != graySwitch.isOn {
            graySwitch.isOn = gray
            valueChanged = true
        }
        if valueChanged {
            valueChangedAction()
        }
    }
    
    @objc func forceShow(_ stations: [BMStation]) {
        var valueChanged = false
        for station in stations {
            if station.light == .green && !greenSwitch.isOn {
                greenSwitch.isOn = true
                valueChanged = true
            }
            if station.light == .red && !redSwitch.isOn {
                redSwitch.isOn = true
                valueChanged = true
            }
            if station.light == .yellow && !yellowSwitch.isOn {
                yellowSwitch.isOn = true
                valueChanged = true
            }
            if station.light == .gray && !graySwitch.isOn {
                graySwitch.isOn = true
                valueChanged = true
            }
        }
        if valueChanged {
            valueChangedAction()
        }
    }

    @IBAction fileprivate func valueChangedAction() {
        guard let handler = handler else {
            return
        }
        let greenOn = greenSwitch.isOn
        let redOn = redSwitch.isOn
        let yellowOn = yellowSwitch.isOn
        let grayOn = yellowSwitch.isOn
        DispatchQueue.global(qos: .userInteractive).async {
            BMAnalyticsManager.logFilterGreen(greenOn, red: redOn, yellow: yellowOn, gray: grayOn)
            let stations = self.stations.filter { (station: BMStation) -> Bool in
                return (station.light == .green && greenOn) || (station.light == .red && redOn) || (station.light == .yellow && yellowOn) || (station.light == .gray && grayOn)
            }
            DispatchQueue.main.async {
                handler(stations, greenOn, redOn, yellowOn, grayOn)
            }
        }
    }
}
