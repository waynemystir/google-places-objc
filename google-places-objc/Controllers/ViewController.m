//
//  ViewController.m
//  google-places-objc
//
//  Created by WAYNE SMALL on 11/6/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import "ViewController.h"
#import "LoadGoogleData.h"
#import "GoogleAutocompletePlace.h"
#import "Places.h"
#import "GooglePlace.h"
#import "PlacesTableViewCell.h"
#import <MapKit/MapKit.h>
#import "AppEnvironment.h"

static NSString * const cellReuserIdentifier = @"cellIdentifier";
static int const kAutoCompleteMinimumNumberOfCharacters = 4;

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, LoadGoogleDataDelegate, UITableViewDataSource, UITableViewDelegate>

#pragma mark View Outlets

@property (weak, nonatomic) IBOutlet UITextField *whereToTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *autoCompleteSpinner;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *placesTableView;

#pragma mark Constraint Outlets

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *placesTvBottomConstr;

#pragma mark Properties

@property (nonatomic, strong) CLLocationManager *locationMgr;
@property (nonatomic) CLLocationCoordinate2D zoomLocation;
@property (nonatomic, readonly) CGFloat placeTvTopMinusSuperVwBottom;
@property (nonatomic, strong) NSArray *placesTableData;
@property (nonatomic, strong) NSMutableArray *openTasks;

@end

@implementation ViewController

#pragma mark Lifecycle methods

- (id)init {
    if (self = [super initWithNibName:@"View" bundle:nil]) {
        [LoadGoogleData manager].googleDelegate = self;
        _openTasks = [@[] mutableCopy];
        
        _locationMgr = [[CLLocationManager alloc] init];
        _locationMgr.distanceFilter = kCLDistanceFilterNone;
        _locationMgr.desiredAccuracy = kCLLocationAccuracyKilometer;
        _locationMgr.delegate = self;
        
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse)
            [_locationMgr requestWhenInUseAuthorization];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.mapView.delegate = self;
    
    self.whereToTextField.delegate = self;
    [self.autoCompleteSpinner stopAnimating];
    self.autoCompleteSpinner.hidden = YES;
    
    self.placesTvBottomConstr.constant = self.placeTvTopMinusSuperVwBottom;
    
    self.placesTableView.tableHeaderView = nil;
    self.placesTableView.dataSource = self;
    self.placesTableView.delegate = self;
    [self.placesTableView registerNib:[UINib nibWithNibName:@"PlacesTableViewCell" bundle:nil] forCellReuseIdentifier:cellReuserIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateOpenPlacesTblVw:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    self.mapView.showsUserLocation = ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse);
}

#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (userLocation.location) {
        ((GooglePlace *) [Places manager].savedPlaces.firstObject).latitude = userLocation.location.coordinate.latitude;
        ((GooglePlace *) [Places manager].savedPlaces.firstObject).longitude = userLocation.location.coordinate.longitude;
        
        if ([[Places manager] currentLocationIsSelectedPlace])
            [self redrawMapViewAnimated:YES radius:[Places manager].selectedPlace.zoomRadius];
    }
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.whereToTextField.text = @"";
    [self showSavedPlacesInTblView];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self quitTasksAndSpinners];
    NSString *autoCompleteText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([autoCompleteText length] >= kAutoCompleteMinimumNumberOfCharacters) {
        if (self.placesTableData == [Places manager].savedPlaces) {
            self.placesTableData = [NSMutableArray array];
            [self.placesTableView reloadData];
        }
        [self.openTasks addObject:[LoadGoogleData autocomplete:autoCompleteText]];
        self.autoCompleteSpinner.hidden = NO;
        [self.autoCompleteSpinner startAnimating];
    } else {
        return [self textFieldShouldClear:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self showSavedPlacesInTblView];
    [self quitTasksAndSpinners];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.placesTableData == [Places manager].savedPlaces) {
        self.whereToTextField.text = [Places manager].selectedPlace.placeDescription;
    } else if (self.placesTableData.count) {
        GoogleAutocompletePlace *gap = self.placesTableData[0];
        [LoadGoogleData loadPlaceDetails:gap.placeId];
        self.whereToTextField.text = gap.placeDescription;
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateClosePlacesTblVw];
}

#pragma mark LoadGoogleDataDelegate methods

- (void)loadedData:(GOOGLE_DATA_TYPE)dataType toObject:(NetworkResponse *)googleObject {
    switch (dataType) {
        case GOOGLE_AUTOCOMPLETE: {
            [self.autoCompleteSpinner stopAnimating];
            self.autoCompleteSpinner.hidden = YES;
            self.placesTableData = googleObject.responseRecords;
            [self.placesTableView reloadData];
            break;
        }
            
        case GOOGLE_PLACE_DETAILS: {
            [self resetSelectedPlace:(GooglePlace *) googleObject];
            break;
        }
    }
}

- (void)requestTimedOut:(GOOGLE_DATA_TYPE)dataType {
    [self alertToFailure:@"Request Timed Out" message:@"The request timed out"];
}

- (void)requestFailedOffline:(GOOGLE_DATA_TYPE)dataType {
    [self alertToFailure:@"No network connection" message:@"Please check your connection and try again"];
}

- (void)requestFailed:(GOOGLE_DATA_TYPE)dataType {
    [self alertToFailure:@"Request Failed" message:@"Please try again later"];
}

- (void)alertToFailure:(NSString *)title message:(NSString *)message {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
    [self quitTasksAndSpinners];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.placesTableData.count;
}

- (PlacesTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlacesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuserIdentifier];
    GoogleAutocompletePlace *gap = self.placesTableData[indexPath.row];
    cell.placeDescription.text = gap.placeDescription;
    return cell;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5f)];
    topSeparator.backgroundColor = UIColorFromRGB(0xbbbbbb);
    [self.placesTableView addSubview:topSeparator];
    return topSeparator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id w = self.placesTableData[indexPath.row];
    if ([w isKindOfClass:[GooglePlace class]]) [self resetSelectedPlace:w];
    else if ([w isKindOfClass:[GoogleAutocompletePlace class]])
        [LoadGoogleData loadPlaceDetails:((GoogleAutocompletePlace *)w).placeId];
    [self.view endEditing:YES];
}

#pragma mark Various

- (void)redrawMapViewAnimated:(BOOL)animated radius:(double)radius {
    double w = radius * 1.6 * kMetersPerMile;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.zoomLocation, w, w);
    [self.mapView setRegion:viewRegion animated:animated];
}

- (CLLocationCoordinate2D)zoomLocation {
    GooglePlace *sp = [Places manager].selectedPlace;
    return (_zoomLocation = CLLocationCoordinate2DMake(sp.latitude, sp.longitude));
}

- (void)quitTasksAndSpinners {
    [self.openTasks makeObjectsPerformSelector:@selector(cancel)];
    [self.autoCompleteSpinner stopAnimating];
    self.autoCompleteSpinner.hidden = YES;
}

- (CGFloat)placeTvTopMinusSuperVwBottom {
    return [[UIScreen mainScreen] bounds].size.height - self.placesTableView.frame.origin.y;
}

- (void)animateOpenPlacesTblVw:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    __weak typeof(self) ws = self;
    [ws.view layoutIfNeeded];
    ws.placesTvBottomConstr.constant = keyboardFrame.size.height;
    [UIView animateWithDuration:0.3 animations:^{ [ws.view layoutIfNeeded]; }];
}

- (void)animateClosePlacesTblVw {
    __weak typeof(self) ws = self;
    [ws.view layoutIfNeeded];
    ws.placesTvBottomConstr.constant = ws.placeTvTopMinusSuperVwBottom;
    [UIView animateWithDuration:0.3 animations:^{ [ws.view layoutIfNeeded]; }];
}

- (void)resetSelectedPlace:(GooglePlace *)gp {
    [Places manager].selectedPlace = gp;
    self.whereToTextField.text = [Places manager].selectedPlace.placeDescription;
    [self redrawMapViewAnimated:YES radius:[Places manager].selectedPlace.zoomRadius];
}

- (void)showSavedPlacesInTblView {
    if (self.placesTableData != [Places manager].savedPlaces) {
        self.placesTableData = [Places manager].savedPlaces;
        [self.placesTableView reloadData];
    }
}

@end
