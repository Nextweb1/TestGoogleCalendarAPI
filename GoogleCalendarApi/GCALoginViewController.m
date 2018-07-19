//
//  GCALoginViewController.m
//  GoogleCalendarApi
//
//  Created by Murali on 18/07/18.
//

#import "GCALoginViewController.h"
#import "GlobalConstant.h"
#import "GCASplashViewController.h"
#import "GCAFetchViewController.h"

@interface GCALoginViewController ()

@end

@implementation GCALoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton* btnGS=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnGS setFrame:CGRectMake(20.0,self.view.frame.size.height/2-25.0f,self.view.frame.size.width-40.0,50.0f)];
    btnGS.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [btnGS addTarget:self action:@selector(onGoogleSignInButon) forControlEvents:UIControlEventTouchUpInside];
    btnGS.backgroundColor = [UIColor whiteColor];
    [btnGS setTitle:@"Sign in with Google" forState:UIControlStateNormal];
    btnGS.titleLabel.font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
    [btnGS setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:153.0f/255.0f blue:50.0f/255.0f alpha:0.7f] forState:UIControlStateNormal];
    [self.view addSubview:btnGS];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:btnGS.bounds];
    btnGS.layer.masksToBounds = NO;
    btnGS.layer.shadowColor = [UIColor blackColor].CGColor;
    btnGS.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    btnGS.layer.shadowOpacity = 0.5f;
    btnGS.layer.shadowPath = shadowPath.CGPath;
    
    //============Google Signin==========//
    [GIDSignIn sharedInstance].uiDelegate = (id)self;
    [GIDSignIn sharedInstance].delegate = (id)self;
    [GIDSignIn sharedInstance].scopes = @[kGTLAuthScopeCalendar];
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
    //===================================//
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Google Signin Delegates

-(void)onGoogleSignInButon
{
    [[GIDSignIn sharedInstance] signIn];
}

-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    
    if (error) {
        NSLog(@"G err1 : %@",[NSString stringWithFormat:@"Status: Authentication error: %@", error]);
        return;
    }
    
    NSString *userId = user.userID;
    NSString *fullName = user.profile.name;
    NSString *email = user.profile.email;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:fullName forKey:G_USER_NAME];
    [defaults setValue:email forKey:G_USER_EMAIL];
    [defaults setValue:userId forKey:G_USER_GID];
    
    if ([GIDSignIn sharedInstance].currentUser.profile.hasImage)
    {
        CGSize thumbSize=CGSizeMake(100, 100);
        NSUInteger dimension = round(thumbSize.width * [[UIScreen mainScreen] scale]);
        NSURL *imageURL = [user.profile imageURLWithDimension:dimension];
        [defaults setValue:[NSString stringWithFormat:@"%@",imageURL] forKey:G_USER_PROF];
    }
    
    NSLog(@"Google Signin User Info  ===> %@, %@, %@",userId,fullName,email);
    [defaults setBool:YES forKey:IS_LOGGED_IN];
    [defaults synchronize];
    
    GCAFetchViewController *myViewController = [[GCAFetchViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}


-(void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    if (error) {
        NSLog(@"Google Disconnect Error : %@",[NSString stringWithFormat:@"Status: Failed to disconnect: %@", error]);
    } else {
        NSLog(@"Google Disconnect : %@",[NSString stringWithFormat:@"Status: Disconnected"]);
    }
}

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    NSLog(@"Google Sign in Error:%@",error.localizedDescription);
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)logoutFromApp
{
    if([[GIDSignIn sharedInstance] hasAuthInKeychain])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@"" forKey:G_USER_NAME];
        [defaults setValue:@"" forKey:G_USER_EMAIL];
        [defaults setValue:@"" forKey:G_USER_GID];
        [defaults setValue:@"" forKey:G_USER_PROF];
        [defaults setBool:NO forKey:IS_LOGGED_IN];
        [defaults synchronize];
        
        NSLog(@"Google => Logged out");
        [[GIDSignIn sharedInstance] signOut];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
