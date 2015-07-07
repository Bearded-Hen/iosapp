//
//  FocusDeviceManager.m
//  Focus
//
//  Created by Jamie Lynch on 30/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCDeviceManager.h"

#define TDCS_SERVICE = @"0000AAB0­F845­40FA­995D­658A43FEEA4C" //FIXME
#define CONTROL_COMMAND = @"0000AAB1­F845­40FA­995D­658A43FEEA4C" //FIXME

@interface FOCDeviceManager ()

@property CBCentralManager* cbCentralManager;
@property CBPeripheral* cbPeripheral;

@end

@implementation FOCDeviceManager

-(id)init {
    if (self = [super init]) {
        self.cbCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
    return self;
}

- (void)requestUpdate
{
    NSLog(@"Root View Controller requested update");
}

- (void)scanForFocusDevices
{
    CBUUID *tdcsService = [CBUUID UUIDWithString:@"EA935A36-D185-730B-00C5-2522A48FE677"];
    NSArray *desiredServices = [[NSArray alloc] initWithObjects:tdcsService, nil];
    
    [self.cbCentralManager scanForPeripheralsWithServices:nil options:nil]; // FIXME should scan for SPECIFIC services
    NSLog(@"BLE scan initiated");
}

#pragma mark - CBCentralManagerDelegate

// method called whenever you have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral*)peripheral
{
    NSLog(@"Connected to peripheral %@", peripheral);
    [peripheral discoverServices:nil];
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI
{
    NSLog(@"Discovered peripheral %@", peripheral); // FIXME check if interested in this peripheral
    
    //    [self.cbCentralManager stopScan];
    //    NSLog(@"BLE scan terminated");
    
    self.cbPeripheral = peripheral;
    self.cbPeripheral.delegate = self;
    
    [self.cbCentralManager connectPeripheral:self.cbPeripheral options:nil];
}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager*)central
{
    NSLog(@"Central manager device state updated");
    
    // Determine the state of the peripheral
    if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
        
        [self displayUserErrMessage:@"Bluetooth disabled" message:@"Please turn on bluetooth to control your Focus device."];
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        [self scanForFocusDevices];
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
        
        [self displayUserErrMessage:@"Bluetooth unauthorised" message:@"Please authorise bluetooth to control your Focus device."];
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
        
        [self displayUserErrMessage:@"Bluetooth unsupported" message:@"Your device does not currently support this Focus device."];
    }
    else {
        NSLog(@"Unknown bluetooth CentralManager update");
    }
}

- (void) displayUserErrMessage:(NSString *) title message:(NSString *)message {
     [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

#pragma mark - CBPeripheralDelegate

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error
{
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service, attempting to discover characteristics %@", service);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(NSError*)error
{
    NSLog(@"Discovered characteristics for service %@", service);
    
    for (CBCharacteristic* characteristic in service.characteristics) {
        [peripheral readValueForCharacteristic:characteristic];
        
    }
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    NSLog(@"Updated characteristic value %@", characteristic);
}


@end
