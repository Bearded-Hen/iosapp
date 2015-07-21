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

@property FOCBluetoothPairManager *bluetoothPairManager;
@property FOCCharacteristicDiscoveryManager *characteristicManager;
@property FOCProgramSyncManager *syncManager;
@property FOCProgramRequestManager *requestManager;

@property BOOL isDevicePaired;

@end

static const int kPairButton = 1;
static NSString *kStoredPeripheralId = @"StoredPeripheralId";

@implementation FOCDeviceManager

-(id)init {
    if (self = [super init]) {
        self.cbCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        [self updateConnectionState:UNKNOWN];
    }
    return self;
}

#pragma mark - internal API methods

- (void)refreshDeviceState
{
    if (_focusDevice == nil || _focusDevice.state != CBPeripheralStateConnected) {
        [self handleBluetoothStateUpdate];
    }
    else if (!_isDevicePaired) {
        [self promptPairingDialog];
    }
}

- (void)closeConnection
{
    [_cbCentralManager cancelPeripheralConnection:_focusDevice];
}

- (void) displayUserErrMessage:(NSString *) title message:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

- (void)playProgram:(FOCDeviceProgramEntity *)program
{
    if (_focusDevice.delegate == _requestManager) {
        [_requestManager startProgram:program];
    }
    else {
        [self displayNotReadyAlert];
    }
}

- (void)stopProgram:(FOCDeviceProgramEntity *)program
{
    if (_focusDevice.delegate == _requestManager) {
        [_requestManager stopActiveProgram];
    }
    else {
        [self displayNotReadyAlert];
    }
}

- (void)displayNotReadyAlert
{
    [self displayUserErrMessage:@"Focus not ready" message:@"The device isn't ready for commands yet. Please check if it is connected and powered on."];
}

#pragma mark - implementation

- (void)connectFocusDevice
{
    [self updateConnectionState:SCANNING];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    id storedId = [userDefaults objectForKey:kStoredPeripheralId];
    
    if (storedId != nil) {
        NSLog(@"Attempting connection to previous peripheral %@", storedId);
        
        NSMutableArray *peripheralArray = [[NSMutableArray alloc] init];
        [peripheralArray addObject:[CBUUID UUIDWithString:storedId]];
        
        NSArray *peripherals = [_cbCentralManager retrievePeripheralsWithIdentifiers:peripheralArray];
        
        if (peripherals != nil && [peripherals count] > 0) {
            _focusDevice = peripherals[0];
            [_cbCentralManager connectPeripheral:_focusDevice options:nil];
            [self updateConnectionState:CONNECTING];
        }
        else {
            [self scanForFocusPeripherals];
        }
    }
    else {
        [self scanForFocusPeripherals];
    }
}

- (void)scanForFocusPeripherals
{
    NSLog(@"BLE peripheral scan initiated");
    
    NSMutableArray *desiredServices = [[NSMutableArray alloc] init];
    [desiredServices addObject:[CBUUID UUIDWithString:FOC_SERVICE_UNKNOWN]];
    [self.cbCentralManager scanForPeripheralsWithServices:desiredServices options:nil];
}

- (void)updateConnectionState:(FocusConnectionState)state
{
    NSString *stateName;
    
    switch (state) {
        case CONNECTED: stateName = @"Connected"; break;
        case CONNECTING: stateName = @"Connecting"; break;
        case SCANNING: stateName = @"Scanning"; break;
        case DISCONNECTED: stateName = @"Disconnected"; break;
        case DISABLED: stateName = @"Disabled"; break;
        case UNKNOWN: stateName = @"Unknown"; break;
    }
    
    NSLog(@"Focus connection state changed to '%@'", stateName);
    
    _connectionState = state;
    _connectionText = stateName;
    [_delegate didChangeConnectionState:_connectionState];
    [_delegate didChangeConnectionText:_connectionText];
}

/**
 * Disconnects from the peripheral then reconnects, which triggers a pairing request.
 */
- (void)promptPairingDialog
{
    [_bluetoothPairManager checkPairing:_characteristicManager.controlCmdRequest];
    [_cbCentralManager cancelPeripheralConnection:_focusDevice];
    _focusDevice = nil;
    [self handleBluetoothStateUpdate];
}

- (void)handleBluetoothStateUpdate
{
    if ([_cbCentralManager state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        [self connectFocusDevice];
    }
    else if ([_cbCentralManager state] == CBCentralManagerStatePoweredOff) {
        [self displayUserErrMessage:@"Bluetooth disabled" message:@"Please turn on bluetooth to control your Focus device."];
        [self updateConnectionState:DISCONNECTED];
    }
    else if ([_cbCentralManager state] == CBCentralManagerStateUnauthorized) {
        [self updateConnectionState:DISCONNECTED];
        [self displayUserErrMessage:@"Bluetooth unauthorised" message:@"Please authorise the bluetooth permission to control your Focus device."];
    }
    else if ([_cbCentralManager state] == CBCentralManagerStateUnsupported) {
        [self updateConnectionState:DISABLED];
        [self displayUserErrMessage:@"Bluetooth unsupported" message:@"Your device does not currently support this Focus device."];
    }
    else if ([_cbCentralManager state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
        [self updateConnectionState:DISABLED];
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
    [self updateConnectionState:SCANNING];
}

- (void)centralManagerDidUpdateState:(CBCentralManager*)central
{
    [self handleBluetoothStateUpdate];
}

#pragma mark - CharacteristicDiscoveryDelegate

-(void)didFinishCharacteristicDiscovery:(NSError *)error
{
    NSLog(@"Finished discovering characteristics, beginning pairing check");
    
    _bluetoothPairManager = [[FOCBluetoothPairManager alloc] initWithPeripheral:_focusDevice];
    _focusDevice.delegate = _bluetoothPairManager;

    _bluetoothPairManager.delegate = self;
    [_bluetoothPairManager checkPairing:_characteristicManager.controlCmdRequest];
}

#pragma mark - BluetoothPairingDelegate

- (void)didDiscoverBluetoothPairState:(BOOL)paired error:(NSError *)error
{
    _isDevicePaired = paired;
    
    if (paired) {
        NSLog(@"Devices are paired, initiating program sync");
        [self updateConnectionState:CONNECTED];
        
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        [userDefaults setObject:_focusDevice.identifier.UUIDString forKey:kStoredPeripheralId];
        
        _syncManager = [[FOCProgramSyncManager alloc] initWithPeripheral:_focusDevice];
        _syncManager.delegate = self;
        _focusDevice.delegate = _syncManager;
        
        FOCCharacteristicDiscoveryManager *cm = _characteristicManager;
        [_syncManager startProgramSync:cm];
        
        _connectionText = @"Syncing Device";
        [_delegate didChangeConnectionText:_connectionText];
    }
    else {
        NSLog(@"Focus device is not paired. Prompting user.");
        
        [[[UIAlertView alloc] initWithTitle:@"Pair Bluetooth" message:@"The app can't talk to your device without pairing." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Pair", nil] show];
    }
}

#pragma mark - ProgramSyncDelegate

-(void)didFinishProgramSync:(NSError *)error
{
    NSLog(@"Finished program sync, error=%@", error);
    [self updateConnectionState:CONNECTED];
    
    _requestManager = [[FOCProgramRequestManager alloc] initWithPeripheral:_focusDevice];
    _focusDevice.delegate = _requestManager;

    _requestManager.delegate = self;
    _requestManager.cm = _characteristicManager;
    [_requestManager startNotificationListeners:_focusDevice];
}

#pragma mark - ProgramRequestDelegate

- (void)didAlterProgramState:(FOCDeviceProgramEntity *)program playing:(bool)playing error:(NSError *)error
{
    if (error == nil) {
        [_delegate didAlterProgramState:program playing:playing];
    }
    else {
        NSLog(@"Program state alteration unsuccessful");
    }
}

- (void)didReceiveCurrentNotification:(int)current
{
    // TODO handle new value
}

- (void)didReceiveDurationNotification:(int)duration
{
    // TODO handle new value
}

- (void)didReceiveRemainingTimeNotification:(int)remainingTime
{
    // TODO handle new value
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == kPairButton) {
        [self promptPairingDialog];
    }
}

@end
