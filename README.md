# Handoff BLE-Viewer 

This project is part of my Master Thesis @ SEEMOO (TU Darmstadt). 
With iOS 8 Apple has released a feature called *Handoff*. It allows a user to start an activity on one device and continue on another device. For example you could start writing an email on your iPhone and continue the writing at the same spot with the same content on your Mac. All you need to do is to press one little button. 
Researching how this feature is implemented by Apple is my main goal of my Thesis. 

One big part *Handoff* is Bluetooth Low Energy. With every *Handoff* activity  (`NSUserActivity` for devs) the OS will automatically send out a BLE advertising packet. The BLE communication has been researched by Martin et. al. [1] in *Handoff All Your Privacy: A Review of Apple's Bluetooth Low Energy Continuity Protocol*. The paper does only cover the encrypted parts of the messages and does not actually decrypt any packets. 
Luckily most *Handoff* messages are encrypted, but this tool enables you to view the content of a *Handoff* BLE advertising packet. 

I may insert parts of my Thesis here later for further explanations. 

## Installation 

* Use Xcode 11+
* Make sure to use the CryptoSwift Swift Package 
* Run 

## Privacy 

The App will request certain keys from your Keychain. This is necessary to decrypt BLE advertising packets. None of the keys will be uploaded somewhere. They will also not be saved outside of your keychain. They will stay in memory as long as the app is running. 
Checkout the code if you don't belive me. 




[1]: https://arxiv.org/abs/1904.10600 
