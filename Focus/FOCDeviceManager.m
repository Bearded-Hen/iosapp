//
//  FocusDeviceManager.m
//  Focus
//
//  Created by Jamie Lynch on 30/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCDeviceManager.h"
#import "FocusConstants.h"

@interface FOCDeviceManager ()

@property CBCentralManager* cbCentralManager;
@property CBPeripheral* focusDevice;

@end

@implementation FOCDeviceManager // TODO should connect to BLE device as in apple guide (waiting on clarifications)

-(id)init {
    if (self = [super init]) {
        
        self.cbCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        [self updateConnectionState:UNKNOWN];
    }
    return self;
}

- (void) displayUserErrMessage:(NSString *) title message:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

- (void)scanForFocusDevices
{
    CBUUID *unknownService = [CBUUID UUIDWithString:FOC_SERVICE_UNKNOWN];
    NSArray *desiredServices = [[NSArray alloc] initWithObjects:unknownService, nil];

    // FIXME should scan for TDCS service, doesn't appear to be advertised

    [self.cbCentralManager scanForPeripheralsWithServices:desiredServices options:nil];
    NSLog(@"BLE scan initiated");
}

- (void)updateConnectionState:(FocusConnectionState)state
{
    NSLog(@"Focus connection state changed to %ld", (long)state);
    self.connectionState = state;
    [self.delegate didChangeConnectionState:self.connectionState];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI
{
    NSLog(@"Discovered peripheral %@", peripheral);
    [self.cbCentralManager stopScan];
    NSLog(@"BLE scan terminated");
    
    self.focusDevice = peripheral;
    self.focusDevice.delegate = self;
    
    [self.cbCentralManager connectPeripheral:self.focusDevice options:nil];
    [self updateConnectionState:CONNECTING];
}


- (void)centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral*)peripheral
{
    NSLog(@"Connected to peripheral %@", peripheral);
    
    CBUUID *unknownService = [CBUUID UUIDWithString:FOC_SERVICE_TDCS];
    CBUUID *tdcsService = [CBUUID UUIDWithString:FOC_SERVICE_UNKNOWN];
    NSArray *desiredServices = [[NSArray alloc] initWithObjects:tdcsService, unknownService, nil];
    
    [peripheral discoverServices:desiredServices]; // FIXME look for services interested in only
    [self updateConnectionState:CONNECTED];
}
- (void)centralManagerDidUpdateState:(CBCentralManager*)central
{
    if ([central state] == CBCentralManagerStatePoweredOff) {
        [self displayUserErrMessage:@"Bluetooth disabled" message:@"Please turn on bluetooth to control your Focus device."];
        [self updateConnectionState:DISCONNECTED];
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        [self scanForFocusDevices];
        [self updateConnectionState:SCANNING];
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        [self updateConnectionState:DISCONNECTED];
        [self displayUserErrMessage:@"Bluetooth unauthorised" message:@"Please authorise bluetooth to control your Focus device."];
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        [self updateConnectionState:DISCONNECTED];
        [self displayUserErrMessage:@"Bluetooth unsupported" message:@"Your device does not currently support this Focus device."];
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
        [self updateConnectionState:UNKNOWN];
    }
    else {
        NSLog(@"Unknown bluetooth CentralManager update");
        [self updateConnectionState:UNKNOWN];
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error
{
    for (CBService *service in self.focusDevice.services) {
        NSLog(@"Discovered service with UUID %@", service.UUID.UUIDString);
        [self.focusDevice discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(NSError*)error
{
    NSLog(@"Discovered characteristics for service %@", service);
    
    for (CBCharacteristic* characteristic in service.characteristics) {
        [peripheral readValueForCharacteristic:characteristic];
        
    }
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    NSLog(@"Updated characteristic value %@", characteristic);
}


@end
