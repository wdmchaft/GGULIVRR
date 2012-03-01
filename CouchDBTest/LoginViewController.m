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

#import "LoginViewController.h"

@implementation LoginViewController

@synthesize userID, token, master;

- (id)init {
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField*) textField {
    
    [textField resignFirstResponder]; 
    return NO;
}

- (IBAction)loginPressed:(id)sender {
    
    if(userID.text.length > 0 && token.text.length > 0) {
        //Login with userID and token
        master.userID = userID.text;
		master.token = [token.text lowercaseString];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    userID.delegate = self;
    token.delegate = self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

@end
