#import "BeaconBroadcast.h"
#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>

@interface BeaconBroadcast : RCTEventEmitter <RCTBridgeModule, CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

@end

@implementation BeaconBroadcast

RCT_EXPORT_MODULE()

// MARK: - React Native Bridge Methods

RCT_EXPORT_METHOD(startSharedAdvertisingBeaconWithString:(NSString *)uuid major:(int)major minor:(int)minor identifier:(NSString *)identifier)
{
  [[BeaconBroadcast sharedInstance] startAdvertisingBeaconWithString: uuid major: major minor: minor identifier: identifier];
}

RCT_EXPORT_METHOD(stopSharedAdvertisingBeacon)
{
  [[BeaconBroadcast sharedInstance] stopAdvertisingBeacon];
}

// MARK: - Shared Instance

+ (id)sharedInstance
{
  static dispatch_once_t p = 0;
  __strong static id _sharedObject = nil;
  dispatch_once(&p, ^{
    _sharedObject = [[self alloc] init];
  });
  return _sharedObject;
}

// MARK: - Beacon Advertising Control

- (void)startAdvertisingBeaconWithString:(NSString *)uuid major:(int)major minor:(int)minor identifier:(NSString *)identifier
{
  NSLog(@"Turning on advertising...");

  [self createBeaconRegionWithString:uuid major:major minor:minor identifier:identifier];

  if (!self.peripheralManager) {
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
  }

  [self turnOnAdvertising];
}

- (void)stopAdvertisingBeacon
{
  if ([self.peripheralManager isAdvertising]) {
    [self.peripheralManager stopAdvertising];
  }

  NSLog(@"Turned off advertising.");
}

// MARK: - Beacon Setup

- (void)createBeaconRegionWithString:(NSString *)uuid major:(int)major minor:(int)minor identifier:(NSString *)identifier
{
  NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:uuid];
  self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:major minor:minor identifier:identifier];
  self.beaconRegion.notifyEntryStateOnDisplay = YES;
}

- (void)createLocationManager
{
  if (!self.locationManager) {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
  }
}

// MARK: - Advertising Logic

- (void)turnOnAdvertising
{
  if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
    NSLog(@"Peripheral manager is off.");
    return;
  }

  UInt16 major = [self.beaconRegion.major unsignedShortValue];
  UInt16 minor = [self.beaconRegion.minor unsignedShortValue];

  CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:self.beaconRegion.proximityUUID
                                                                    major:major
                                                                    minor:minor
                                                               identifier:self.beaconRegion.identifier];

  NSDictionary *beaconPeripheralData = [region peripheralDataWithMeasuredPower:nil];
  [self.peripheralManager startAdvertising:beaconPeripheralData];

  NSLog(@"Turning on advertising for region: %@.", region);
}

// MARK: - CBPeripheralManagerDelegate

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheralManager error:(NSError *)error
{
  if (error) {
    NSLog(@"Couldn't turn on advertising: %@", error);
    return;
  }

  if (peripheralManager.isAdvertising) {
    NSLog(@"Turned on advertising.");
    [self sendEventWithName:@"onBeaconStateChanged" body:@{ @"status": @"started" }];
  }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
  if (peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
    NSLog(@"Peripheral manager is off.");
    return;
  }

  NSLog(@"Peripheral manager is on.");
  [self turnOnAdvertising];
}

// MARK: - RCTEventEmitter

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"onBeaconStateChanged"];
}

@end

