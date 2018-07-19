//
//  GCALoginViewController.h
//  GoogleCalendarApi
//
//  Created by Murali on 18/07/18.
//

#import <UIKit/UIKit.h>

@import GoogleSignIn;

@interface GCALoginViewController : UIViewController <GIDSignInDelegate>
-(void)logoutFromApp;
@end
