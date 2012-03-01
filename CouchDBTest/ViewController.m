/*Copyright 2012 Philippe Possemiers - Artesis University College
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.*/

#import "ViewController.h"
#import "LoginViewController.h"
#import <CouchCocoa/CouchDatabase.h>
#import <CouchCocoa/CouchQuery.h>
#import <CouchCocoa/CouchDocument.h>
#import <CouchCocoa/CouchRevision.h>
#import <CouchCocoa/CouchPersistentReplication.h>
#import <CouchCocoa/RESTOperation.h>

@implementation ViewController

#define kmasterURL @"http://jack:jack@3mobile.iriscouch.com/%@"
#define kbackgroundHTML @"<html><head><link rel='stylesheet' href='stylesheet.css'></head><body></body></html>"
#define kwaitTitle @"Please wait..."
#define kscanTitle @"Click on the scan button to scan a QR code"

@synthesize serverURL, localDatabase, masterDatabase;
@synthesize webView, navBar, scanButton;
@synthesize userID, token;
@synthesize currentItem, resultDoc;
@synthesize zBarReader;
@synthesize locationManager;
@synthesize replicated;
@synthesize currentLatitude, currentLongitude;
@synthesize stylesheet;

- (void)dealloc {

	[super dealloc];
	[localDatabase release];
	localDatabase = nil;
	[masterDatabase release];
	masterDatabase = nil;
	resultDoc = nil;
	[locationManager release];
	locationManager = nil;
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
	webView.delegate = self;
	
	if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
	
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
	
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500;
    [locationManager startUpdatingLocation];
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
		
	[super viewDidAppear:animated];

	// Show wait screen and disable scan button
	navBar.topItem.title = kwaitTitle;
	[scanButton setEnabled:FALSE];
	
	if(userID == nil) {
        LoginViewController *loginView = [[LoginViewController alloc] init];
        loginView.master = self;
        [self presentModalViewController:loginView animated:YES];
        [loginView release];
    }
	else {		

		// URL that points to the server database
		NSURL *masterURL = [NSURL URLWithString:[NSString stringWithFormat:kmasterURL, token]];
		
		// Initiate local database
		CouchServer *server = [[CouchServer alloc] initWithURL:serverURL];
		localDatabase = [server databaseNamed:token];
		[localDatabase ensureCreated:nil];
		[server release];
		
		// Initiate remote database
		masterDatabase = [CouchDatabase databaseWithURL:masterURL];

		if (!resultDoc) {
			
			// Create results document for this user
			double d = [[NSDate date] timeIntervalSince1970];
			NSString *docName = [userID stringByAppendingString:[NSString stringWithFormat:@"-%f",d]];
			resultDoc = [localDatabase documentWithID:docName];
			NSMutableDictionary *props = [[NSMutableDictionary alloc] initWithCapacity:1];
			RESTOperation* op = [resultDoc putProperties: props];
			[op start];
			[props release];
		}

		// Start replication to load questions from master DB and upload answers
		[localDatabase replicateWithURL:masterURL exclusively:TRUE];
		
		// Show the background page, set the title adn enable button
		[self.webView loadHTMLString:[self translateHTMLCodes:kbackgroundHTML] baseURL:nil];
		navBar.topItem.title = kscanTitle;
		[scanButton setEnabled:TRUE];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    // Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} 
	else {
	    return YES;
	}
}

- (void)showMessage:(NSString *)msg {
	
    UIAlertView *messageBox = [[UIAlertView alloc] initWithTitle: token message: msg delegate: self 
											   cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    [messageBox show];
    [messageBox release];
}

#pragma mark - CouchBase methods

// Get the body of an item, translate it 
// and load it in the webView
- (void)loadItem:(NSString *)itemName {
	
	NSMutableArray *ids = [[NSMutableArray alloc] initWithObjects:itemName, nil];
	CouchQuery *allDocs = [localDatabase getDocumentsWithIDs:ids];
	
	CouchQueryRow *row = [allDocs.rows rowAtIndex:0];
	CouchDocument *doc = row.document;
	NSString *body = [doc.userProperties objectForKey:@"body"];
	
	if (body) {
		// Replication is ok for this doc
		replicated = true;
		[ids release];
		ids = nil;
	}
	else {
		// Replication not finished yet
		replicated = false;
		allDocs = [masterDatabase getDocumentsWithIDs:ids];
		row = [allDocs.rows rowAtIndex:0];
		doc = row.document;
		body = [doc.userProperties objectForKey:@"body"];
		[ids release];
		ids = nil;
	}
	
	[self.webView loadHTMLString:[self translateHTMLCodes:body] baseURL:nil];
	navBar.topItem.title = @"";
	//[scanButton setEnabled:FALSE];
}

// Just get the body of an item
- (NSString *)getItem:(NSString *)itemName {
	
	NSMutableArray *ids = [[NSMutableArray alloc] initWithObjects:itemName, nil];
	CouchQuery *allDocs = [localDatabase getDocumentsWithIDs:ids];
	
	CouchQueryRow *row = [allDocs.rows rowAtIndex:0];
	CouchDocument *doc = row.document;
	NSString *body = [doc.userProperties objectForKey:@"body"];
	
	if (body) {
		// Replication is ok for this doc
		replicated = true;
		[ids release];
		ids = nil;
	}
	else {
		// Replication not finished yet
		replicated = false;
		allDocs = [masterDatabase getDocumentsWithIDs:ids];
		row = [allDocs.rows rowAtIndex:0];
		doc = row.document;
		body = [doc.userProperties objectForKey:@"body"];
		[ids release];
		ids = nil;
	}
	
	return body;
}

// Utility method for checking database contents
- (IBAction)listAllDocuments:(id)sender {
	
	CouchQuery* allDocs = [localDatabase getAllDocuments];
	for (CouchQueryRow *row in allDocs.rows) {
		//[self showMessage:[NSString stringWithFormat:@"Doc ID : %@", row.documentID]];
		NSLog(@"%@", [NSString stringWithFormat:@"Doc ID : %@", row.documentID]);
	}
}

#pragma mark - Processing HTML Form methods

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request
											navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *url = request.URL.absoluteString;
    NSRange range = [url rangeOfString:@"?"];
    
    if (range.length > 0) {

        NSString *optionString = [url substringFromIndex:range.location + 1];
        NSArray *options = [optionString componentsSeparatedByString:@"&"];
        [self processFormResult:options];
		
        return NO;
    }
	
    return YES;
}

- (void)processFormResult:(NSArray *)options {
    
	CouchRevision *latest = resultDoc.currentRevision;
	NSMutableDictionary *props = [[latest.properties mutableCopy] autorelease];
	
    for (NSString *valuePair in options) {
		
        NSArray *array = [valuePair componentsSeparatedByString:@"="];
		[props setObject:[array objectAtIndex:1] forKey:[array objectAtIndex:0]];
    }
	
	// Now add location
	[props setObject:[NSString stringWithFormat:@"%+.6f", currentLatitude] forKey:@"Latitude"];
	[props setObject:[NSString stringWithFormat:@"%+.6f", currentLongitude] forKey:@"Longitude"];
		
	RESTOperation *op = [resultDoc putProperties:props];
	[op start];
	
	// Show the background page
	[self.webView loadHTMLString:[self translateHTMLCodes:kbackgroundHTML] baseURL:nil];
	navBar.topItem.title = kscanTitle;
	[scanButton setEnabled:TRUE];
}

- (NSString *)translateHTMLCodes:(NSString *)html {
	
	NSString *attachmentURL;
	
	// Load stylesheet
	if (!stylesheet)
		stylesheet = [self getItem:@"stylesheet"];
	
	if(replicated) {
		attachmentURL = [NSString stringWithFormat:@"%@/%@", [localDatabase.URL absoluteString], currentItem];
	}
	else {
		attachmentURL = [NSString stringWithFormat:@"%@/%@", [masterDatabase.URL absoluteString], currentItem];
	}
	
	// Fill html with stylesheet entries
	html = [html stringByReplacingOccurrencesOfString:@"<link rel='stylesheet' href='stylesheet.css'>" 
						withString:[NSString stringWithFormat:@"<style type='text/css'>%@</style>", stylesheet]];
	
	return [html stringByReplacingOccurrencesOfString:@"$db" withString:attachmentURL];
}

#pragma mark - ZBar methods

- (IBAction)scanPressed:(id)sender {
	
    zBarReader = [ZBarReaderViewController new];
    zBarReader.readerDelegate = self;
    [self presentModalViewController:zBarReader animated:YES];
    [zBarReader release];
}

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info {
    
    // Must be dismissed with animation set to NO because of apparent bug!
    [reader dismissModalViewControllerAnimated: NO];
    
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
	
	for(ZBarSymbol *symbol in results) {
        currentItem = symbol.data;
	}
	
	[self loadItem:currentItem];
}

#pragma mark - CLLocationManager delegate method

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation 
														fromLocation:(CLLocation *)oldLocation {
	currentLatitude = newLocation.coordinate.latitude;
	currentLongitude = newLocation.coordinate.longitude;
}

@end
