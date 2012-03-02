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


#import <UIKit/UIKit.h>
#import <CouchCocoa/CouchServer.h>
#import <CouchCocoa/CouchDatabase.h>
#import "ZBarSDK.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <UIWebViewDelegate, ZBarReaderDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *scanButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) NSURL *serverURL;
@property (nonatomic, retain) CouchDatabase *localDatabase;
@property (nonatomic, retain) CouchDatabase *masterDatabase;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *currentItem;
@property (nonatomic, retain) CouchDocument *resultDoc;
@property (nonatomic, retain) ZBarReaderViewController *zBarReader;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property(nonatomic, retain) NSString *stylesheet;
@property bool replicated;
@property float currentLatitude;
@property float currentLongitude;

- (void)showMessage:(NSString *)msg;
- (void)loadItem:(NSString *)itemName;
- (NSString *)getItem:(NSString *)itemName;
- (IBAction)listAllDocuments:(id)sender;
- (IBAction)backPressed:(id)sender;
- (IBAction)scanPressed:(id)sender;
- (void)processFormResult:(NSArray *)options;
- (NSString *)translateHTMLCodes:(NSString *)html;

@end
