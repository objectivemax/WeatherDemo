//
//  ViewController.m
//  WeatherDemo
//
//  Created by Maxim Ohrimenko on 11/23/16.
//  Copyright © 2016 Maxim Ohrimenko. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;
@import GooglePlaces;
@import AFNetworking;


@interface ViewController () <UISplitViewControllerDelegate, UITextFieldDelegate , CLLocationManagerDelegate >

@property (weak, nonatomic) IBOutlet GMSMapView *GoogleMapView;
@property (weak, nonatomic) IBOutlet UITextField *cityNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *cityNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *cityTempLabel;
@property (weak, nonatomic) IBOutlet UITextView *cityWetLabel;
@property (weak, nonatomic) IBOutlet UITextView *cityWindSpeedLabel;

@property (strong, nonatomic) IBOutlet CLLocationManager *location;

@end

@implementation ViewController {
    GMSPlacesClient *placesClient;
    
    CLLocationManager *locationManager;
}


// // MARK: GOOGLE MAP/PLACE

@synthesize googleMapsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    _cityNameTextField.delegate = self;
    [_cityNameTextField setReturnKeyType:UIReturnKeyDone];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
    googleMapsController.myLocationEnabled = YES;
    placesClient = [GMSPlacesClient sharedClient];
    
    [placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *likelihoodList, NSError *error) {
        if (error != nil) {
            // NSLog(@"Current Place error %@", [error localizedDescription]);
            return;
        }
        
        for (GMSPlaceLikelihood *likelihood in likelihoodList.likelihoods) {
            GMSPlace* place = likelihood.place;
            // NSLog(@"Current Place name %@ at likelihood %g", place.name, likelihood.likelihood);
            // NSLog(@"Current Place address %@", place.formattedAddress);
            // NSLog(@"Current Place attributions %@", place.attributions);
            // NSLog(@"Current PlaceID %@", place.placeID);
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSString *text1 = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        NSString *text2 = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        // NSLog(@"%@   ____ %@" , text1 , text2);
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}


-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // NSLog(@"vtnjfldlf ______ dfkjvdfvndlfnvldf");
    // NSLog(@"%@" , locations.lastObject);
}


// MARK: SEARCH CURRENT LOCATION

- (IBAction)searchWithAdress:(id)sender {
    [locationManager startUpdatingLocation];
    NSString *theLocation = [NSString stringWithFormat:@"latitude: %f longitude: %f", self->locationManager.location.coordinate.latitude, self->locationManager.location.coordinate.longitude];
    float longitude1 = locationManager.location.coordinate.longitude;
    float latitude1 = locationManager.location.coordinate.latitude;
    
    // NSLog(@"%f", locationManager.location.coordinate.latitude);
    // NSLog(@"%f", locationManager.location.coordinate.longitude);
    // NSLog(@"%@", theLocation);
    
    NSString *stringUrl = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=7e5726a9a8b3270583785631c72be857", latitude1,longitude1];
    NSLog(@"%@", stringUrl);

    NSURL *weatherURL = [NSURL URLWithString:stringUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:weatherURL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            // NSLog(@"Error: %@", error);
        } else {
            // NSLog(@"%@ %@", response, responseObject);
            
            NSString *weather1 = [responseObject objectForKey:@"name"];                              // ГОРОД
            NSString *temperatyra = [[responseObject objectForKey:@"main"] objectForKey:@"temp"];    // ТЕМПЕРАТУРА
            double kelvin = [temperatyra doubleValue];
            NSString *humidity = [[responseObject objectForKey:@"main"] objectForKey:@"humidity"];   // ВЛАЖНОСТЬ
            NSString *speedWind = [[responseObject objectForKey:@"wind"] objectForKey:@"speed"];     // СКОРОСТЬ ВЕТРА
            NSNumber *googleLatitude = [[responseObject objectForKey:@"coord"] objectForKey:@"lat"]; // ШИРОТА
            NSNumber *googleLongitude = [[responseObject objectForKey:@"coord"] objectForKey:@"lon"];// ДОЛГОТА
            
            float glat = [googleLatitude floatValue];
            float glon = [googleLongitude floatValue];
            
            self.cityNameLabel.text = weather1;
            self.cityTempLabel.text = [NSString stringWithFormat:@"%.ld", lroundf(kelvin - 273.15), temperatyra];
            self.cityWetLabel.text = [NSString stringWithFormat:@"%@" , humidity];
            self.cityWindSpeedLabel.text = [NSString stringWithFormat:@"%@" , speedWind];
            
            GMSCameraPosition *sydney = [GMSCameraPosition cameraWithLatitude: glat
                                                                    longitude: glon
                                                                         zoom:10];
            [_GoogleMapView setCamera:sydney];
        }
    }];
    [dataTask resume];
}


// MARK: KEY BOARD

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self getDataClick];
    textField.resignFirstResponder;
    return true;
}


// MARK: WEATHER FUNС

- (void) getDataClick {
    NSString *locationCity = _cityNameTextField.text;
    NSString *stringUrl = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@&appid=7e5726a9a8b3270583785631c72be857", locationCity];
    
    NSURL *weatherURL = [NSURL URLWithString:stringUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:weatherURL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            // NSLog(@"Error: %@", error);
        } else {
            // NSLog(@"%@ %@", response, responseObject);

        NSString *weather1 = [responseObject objectForKey:@"name"];                              // ГОРОД
        NSString *temperatyra = [[responseObject objectForKey:@"main"] objectForKey:@"temp"];    // ТЕМПЕРАТУРА
            double kelvin = [temperatyra doubleValue];
        NSString *humidity = [[responseObject objectForKey:@"main"] objectForKey:@"humidity"];   // ВЛАЖНОСТЬ
        NSString *speedWind = [[responseObject objectForKey:@"wind"] objectForKey:@"speed"];     // СКОРОСТЬ ВЕТРА
        NSNumber *googleLatitude = [[responseObject objectForKey:@"coord"] objectForKey:@"lat"]; // ШИРОТА
        NSNumber *googleLongitude = [[responseObject objectForKey:@"coord"] objectForKey:@"lon"];// ДОЛГОТА
            
        float glat = [googleLatitude floatValue];
        float glon = [googleLongitude floatValue];
            
        //Проверка в консоль
        NSLog(@"%@", weather1);
        NSLog(@"Температура %.ld", lroundf(kelvin - 273.15));
        NSLog(@"Влажность %@", humidity);
        NSLog(@"Швидкість вітру складає %@ м/с", speedWind);
        NSLog(@"lon %@", googleLongitude);
        NSLog(@"lat %@", googleLatitude);
            
        self.cityNameLabel.text = weather1;
        self.cityTempLabel.text = [NSString stringWithFormat:@"%.ld", lroundf(kelvin - 273.15), temperatyra];
        self.cityWetLabel.text = [NSString stringWithFormat:@"%@" , humidity];
        self.cityWindSpeedLabel.text = [NSString stringWithFormat:@"%@" , speedWind];
            
        GMSCameraPosition *sydney = [GMSCameraPosition cameraWithLatitude: glat
                                                                longitude: glon
                                                                     zoom:11];
        [_GoogleMapView setCamera:sydney];
        }
    }];
    [dataTask resume];
}
@end
