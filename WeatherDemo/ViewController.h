//
//  ViewController.h
//  WeatherDemo
//
//  Created by Maxim Ohrimenko on 11/23/16.
//  Copyright © 2016 Maxim Ohrimenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>



@interface ViewController : UIViewController;

@property (weak, nonatomic) IBOutlet GMSMapView *googleMapsController;
@property (strong, nonatomic) NSArray *data;
@property (nonatomic,retain) CLLocationManager *locationManager;


- (IBAction)searchWithAdress:(id)sender;

@end

