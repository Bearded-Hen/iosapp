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

@property FOCCharacteristicDiscoveryManager *characteristicManager;
@property FOCProgramSyncManager *syncManager;
@property FOCProgramRequestManager *requestManager;

@end

@implementation FOCDeviceManager // TODO should connect to BLE device as in apple guide (waiting on clarifications)

-(id)init { // TODO should handle refresh when the app gets put in the background
    if (self = [super init]) {
        self.cbCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        [self updateConnectionState:UNKNOWN];
    }
    return self;
}

- (void)refreshStateIfNeeded
{
    if ([_cbCentralManager state] != CBCentralManagerStatePoweredOn || _connectionState != CONNECTED) {
        
        [self handleBluetoothStateUpdate];
    }
}

- (void) displayUserErrMessage:(NSString *) title message:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

- (void)scanForFocusDevices
{
    [self updateConnectionState:SCANNING];
    
    NSMutableArray *desiredServices = [[NSMutableArray alloc] init];
    [desiredServices addObject:[CBUUID UUIDWithString:FOC_SERVICE_UNKNOWN]];

    [self.cbCentralManager scanForPeripheralsWithServices:desiredServices options:nil];
//    [self.cbCentralManager retrievePeripheralsWithIdentifiers:(NSArray *)] // FIXME should retain previously connected peripheral and attempt connection to this
    NSLog(@"BLE scan initiated");
}

- (void)updateConnectionState:(FocusConnectionState)state
{
    NSString *stateName;
    
    switch (state) {
        case CONNECTED: stateName = @"Connected"; break;
        case CONNECTING: stateName = @"Connecting"; break;
        case SCANNING: stateName = @"Scanning"; break;
        case DISCONNECTED: stateName = @"Disconnected"; break;
        case UNKNOWN: stateName = @"Unknown"; break;
    }
    
    NSLog(@"Focus connection state changed to '%@'", stateName);
    self.connectionState = state;
    [self.delegate didChangeConnectionState:self.connectionState];
}

- (void)handleBluetoothNotReady
{
    if ([_cbCentralManager state] == CBCentralManagerStatePoweredOff) {
        [self displayUserErrMessage:@"Bluetooth disabled" message:@"Please turn on bluetooth to control your Focus device."];
        [self updateConnectionState:DISCONNECTED];
    }
    else if ([_cbCentralManager state] == CBCentralManagerStateUnauthorized) {
        [self updateConnectionState:DISCONNECTED];
        [self displayUserErrMessage:@"Bluetooth unauthorised" message:@"Please authorise the bluetooth permission to control your Focus device."];
    }
    else if ([_cbCentralManager state] == CBCentralManagerStateUnsupported) {
        [self updateConnectionState:DISCONNECTED];
        [self displayUserErrMessage:@"Bluetooth unsupported" message:@"Your device does not currently support this Focus device."];
    }
    else if ([_cbCentralManager state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
        [self updateConnectionState:UNKNOWN];
    }
    else {
        NSLog(@"Unknown bluetooth CentralManager update");
        [self updateConnectionState:UNKNOWN];
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI
{
    NSLog(@"Discovered '%@ - %@'", peripheral.name, peripheral.identifier.UUIDString);
    [self.cbCentralManager stopScan];
    NSLog(@"Terminating BLE Scan, initiating connection");
    
    self.focusDevice = peripheral;
    
    [self.cbCentralManager connectPeripheral:self.focusDevice options:nil];
    [self updateConnectionState:CONNECTING];
}

- (void)centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral*)peripheral
{
    NSLog(@"Connected to peripheral '%@' with UUID '%@'", peripheral.name, peripheral.identifier.UUIDString);
    
    NSMutableArray *desiredServices = [[NSMutableArray alloc] init];
    [desiredServices addObject:[CBUUID UUIDWithString:FOC_SERVICE_TDCS]];
    
    _focusDevice = peripheral;
    
    _characteristicManager = [[FOCCharacteristicDiscoveryManager alloc] initWithPeripheral:_focusDevice];
    _characteristicManager.delegate = self;
    _focusDevice.delegate = _characteristicManager;
    
    [_focusDevice discoverServices:desiredServices];
    [self updateConnectionState:CONNECTED];
}

- (void)centralManagerDidUpdateState:(CBCentralManager*)central
{
    [self handleBluetoothStateUpdate];
}

- (void)handleBluetoothStateUpdate
{
    if ([_cbCentralManager state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        [self scanForFocusDevices];
        // FIXME need to retrieve previously connected peripherals and attempt connection
        //        [self.cbCentralManager retrievePeripheralsWithIdentifiers:nil];
    }
    else {
        [self handleBluetoothNotReady];
    }
}

#pragma mark - CharacteristicDiscoveryDelegate

-(void)didFinishCharacteristicDiscovery:(NSError *)error
{
    NSLog(@"Finished discovering characteristics, beginning program sync");
    
    _syncManager = [[FOCProgramSyncManager alloc] initWithPeripheral:_focusDevice];
    _focusDevice.delegate = _syncManager;
    
    FOCCharacteristicDiscoveryManager *cm = _characteristicManager;
    
    [_syncManager startProgramSync:cm.controlCmdRequest controlCmdResponse:cm.controlCmdResponse dataBuffer:cm.dataBuffer];
}

#pragma mark - ProgramSyncDelegate

-(void)didFinishProgramSync:(NSError *)error
{
    NSLog(@"Finished program sync %@", error);
    
    _requestManager = [[FOCProgramRequestManager alloc] initWithPeripheral:_focusDevice];
    _focusDevice.delegate = _requestManager;
}

#pragma mark - ProgramRequestDelegate

- (void)didFinishProgramRequest:(NSError *)error
{
    NSLog(@"Program request finished");
    // TODO program request logic
}

@end
