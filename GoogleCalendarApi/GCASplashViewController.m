//
//  GCASplashViewController.m
//  GoogleCalendarApi
//
//  Created by Murali on 18/07/18.
//

#import "GCASplashViewController.h"
#import "GCALoginViewController.h"
#import "GlobalConstant.h"
#import "GCAFetchViewController.h"

@interface GCASplashViewController ()
{
    UIActivityIndicatorView *actIndi;
}
@end

@implementation GCASplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *lblWelcomeNote = [[UILabel alloc] initWithFrame:CGRectMake(10, (self.view.frame.size.height/2)-20.0f, self.view.frame.size.width-20.0f, 40.0f)];
    lblWelcomeNote.text = [NSString stringWithFormat:@"Welcome to Google Calendar App"];
    lblWelcomeNote.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
    lblWelcomeNote.numberOfLines = 0;
    lblWelcomeNote.backgroundColor = [UIColor clearColor];
    lblWelcomeNote.textColor = [UIColor darkGrayColor];
    lblWelcomeNote.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblWelcomeNote];
    
    actIndi = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [actIndi setFrame:CGRectMake((self.view.frame.size.width/2)-10, (self.view.frame.size.height-(self.view.frame.size.height/3))+50, 20, 20)];
    [self.view addSubview:actIndi];
    actIndi.hidden = NO;
    [actIndi startAnimating];
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(gotoLogin) userInfo:nil repeats:NO];
}

-(void)gotoLogin
{
    [actIndi stopAnimating];
    actIndi.hidden = YES;
    NSLog(@"Login Status : %d",[[NSUserDefaults standardUserDefaults] boolForKey:IS_LOGGED_IN]);
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:IS_LOGGED_IN])// Logged in Already
    {
        [self loadLandingScreen];
    }
    else{
        GCALoginViewController *lgv = [[GCALoginViewController alloc] init];
        [self presentViewController:lgv animated:YES completion:nil];
    }
    
}

-(void)loadLandingScreen
{
    GCAFetchViewController *myViewController = [[GCAFetchViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
    
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    [top presentViewController:navigationController animated:YES completion: nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
