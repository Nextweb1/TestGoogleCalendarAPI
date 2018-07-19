//
//  ViewController.m
//  GoogleCalendarApi
//
//  Created by Murali on 18/07/18.
//

#import "GCAFetchViewController.h"

#import "GCAEvent.h"
#import "GCAEventsSearchResponse.h"
#import "GCAEventsListViewController.h"
#import "GCALoginViewController.h"


static NSString const *kEventbriteEventsSearchURL = @"https://www.eventbriteapi.com/v3/events/search/";
static NSString const *kEventbriteAuthToken = @"33UIBE5JWGDOXNTJ2E2T";

@interface GCAFetchViewController ()
{
    UIDatePicker *pickerDate;
    UIView *pickerContainer;
    NSDate* selectedDate;
}
@property (nonatomic, strong) GTLServiceCalendar *calendarService;
@property (nonatomic, strong) UIButton *fetchEventsButton;
@property (nonatomic, strong) UIButton *fetchEventsByDate;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

- (void)didTapFetchEventsButton:(id)sender;
- (void)fetchEvents;
- (void)showActivityIndicator:(BOOL)show;
- (void)pushEventsListWithEvents:(NSArray *)events;

@end

@implementation GCAFetchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //============Google Signin==========//
    [GIDSignIn sharedInstance].uiDelegate = (id)self;
    [GIDSignIn sharedInstance].delegate = (id)self;
    [GIDSignIn sharedInstance].scopes = @[kGTLAuthScopeCalendar];
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
    //===================================//
    
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Logout"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(onLogout)];
    self.navigationItem.rightBarButtonItem = flipButton;

    
    // Fetch events by Date button
    _fetchEventsByDate = [UIButton buttonWithType:UIButtonTypeCustom];
    _fetchEventsByDate.frame = CGRectMake(10, self.view.frame.size.height/4, self.view.frame.size.width-20, 50);
    _fetchEventsByDate.tag = 1;
    [_fetchEventsByDate setTitle:@"Fetch events by Date" forState:UIControlStateNormal];
    [_fetchEventsByDate setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_fetchEventsByDate setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_fetchEventsByDate addTarget:self action:@selector(didTapFetchEventsButton:) forControlEvents:UIControlEventTouchUpInside];
    _fetchEventsByDate.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_fetchEventsByDate];
    
    
    // Fetch events button
    _fetchEventsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _fetchEventsButton.frame = CGRectMake(10, _fetchEventsByDate.frame.origin.y+_fetchEventsByDate.frame.size.height+20.0f, self.view.frame.size.width-20, 50);
    _fetchEventsButton.tag = 2;
    [_fetchEventsButton setTitle:@"Fetch events from Eventbrite" forState:UIControlStateNormal];
    [_fetchEventsButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_fetchEventsButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_fetchEventsButton addTarget:self action:@selector(didTapFetchEventsButton:) forControlEvents:UIControlEventTouchUpInside];
    _fetchEventsButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_fetchEventsButton];

    
    // Activity indicator
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initForAutoLayout];

    _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    [self.view addSubview:_activityIndicatorView];

    [_activityIndicatorView autoCenterInSuperview];
    
    
}

#pragma mark - Actions

- (void)didTapFetchEventsButton:(id)sender {
    UIButton* btnRef = (UIButton*)sender;
    switch (btnRef.tag) {
        case 1:{
            [self createDatePicker];
            break;
        }
            
        case 2:{
            [self fetchEvents];
            break;
        }
            
        default:
            break;
    }
    
}

-(IBAction)onLogout
{
    GCALoginViewController *lgv = [[GCALoginViewController alloc] init];
    [lgv logoutFromApp];
    [self presentViewController:lgv animated:YES completion:nil];
}

#pragma mark - Events Loading

- (void)fetchEvents {
    [self showActivityIndicator:YES];

    HIPNetworkClient *networkClient = [HIPNetworkClient new];

    // Prepare url
    NSString *requestURLString = [NSString stringWithFormat:@"%@?token=%@",
                                                                kEventbriteEventsSearchURL,
                                                                kEventbriteAuthToken];

    NSURL *requestURL = [NSURL URLWithString:requestURLString];

    NSURLRequest *fetchRequest = [networkClient requestWithURL:requestURL
                                                        method:HIPNetworkClientRequestMethodGet
                                                          data:nil];

    [networkClient performRequest:fetchRequest
                    withParseMode:HIPNetworkClientParseModeJSON
                       identifier:nil
                        indexPath:nil
                     cacheResults:NO
                completionHandler:^(id parsedData, NSURLResponse *response, NSError *error) {
                    if (error == nil) {
                        GCAEventsSearchResponse *searchResponse = [[GCAEventsSearchResponse alloc]
                                                                   initWithParsedData:parsedData];
                        NSArray *events = searchResponse.events;

                        [self pushEventsListWithEvents:events];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc]
                                              initWithTitle:NSLocalizedString(@"Fethcing Failed", nil)
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
                        [alert show];
                    }

                    [self showActivityIndicator:NO];
                }];
}

- (void)showActivityIndicator:(BOOL)show {
    _fetchEventsButton.hidden = show;

    if (show) {
        [_activityIndicatorView startAnimating];
    } else {
        [_activityIndicatorView stopAnimating];
    }
}

#pragma mark - Navigation

- (void)pushEventsListWithEvents:(NSArray *)events {
    GCAEventsListViewController *controller = [[GCAEventsListViewController alloc]
                                               initWithEvents:events];

    [self.navigationController pushViewController:controller
                                         animated:YES];
}



//Fetch Events By Data

- (void)fetchEvents_byDate {
    GTLQueryCalendar *query = [GTLQueryCalendar queryForEventsListWithCalendarId:@"primary"];
    query.maxResults = 10;
    query.timeMin = [GTLDateTime dateTimeWithDate:[NSDate date]
                                         timeZone:[NSTimeZone localTimeZone]];;
    query.singleEvents = YES;
    query.orderBy = kGTLCalendarOrderByStartTime;
    
    [_calendarService executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
    
}

- (void)displayResultWithTicket:(GTLServiceTicket *)ticket
             finishedWithObject:(GTLCalendarEvents *)events
                          error:(NSError *)error {
    if (error == nil) {
        
        NSLog(@"events.items : %@",events.items);
        NSMutableString *eventString = [[NSMutableString alloc] init];
        if (events.items.count > 0) {
            /*for (GTLCalendarEvent *event in events) {
                GTLDateTime *start = event.start.dateTime ?: event.start.date;
                NSString *startString =
                [NSDateFormatter localizedStringFromDate:[start date]
                                               dateStyle:NSDateFormatterShortStyle
                                               timeStyle:NSDateFormatterShortStyle];
                [eventString appendFormat:@"/n  %@/n  %@/n/n%@/n", event.summary, startString, event.descriptionProperty];
                
            }*/
            
            [self pushEventsListWithEvents:events.items];
            
        } else {
            [eventString appendString:@"No upcoming events found."];
        }
        
        NSLog(@"eventString %@",eventString);
        
    } else {
        NSLog(@"Error : %@",error.localizedDescription);
    }
}

#pragma mark - Date Picker

-(void)createDatePicker
{
    
    [pickerContainer removeFromSuperview];
    [pickerDate removeFromSuperview];
    
    [self.view endEditing:YES];
    UIToolbar *controlToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    controlToolbar.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:51.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
    [controlToolbar setBarTintColor:[UIColor colorWithRed:255.0f/255.0f green:51.0f/255.0f blue:102.0f/255.0f alpha:1.0f]];
    [controlToolbar sizeToFit];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UILabel *controlToolbarTit = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    [spacer setTintColor:[UIColor whiteColor]];
    [controlToolbarTit setBackgroundColor:[UIColor clearColor]];
    [controlToolbarTit sizeToFit];
    controlToolbarTit.center = controlToolbar.center;
    controlToolbarTit.textColor = [UIColor whiteColor];
    [spacer setCustomView:controlToolbarTit];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onDoneBarBtn:)];
    [doneButton setTintColor:[UIColor whiteColor]];
    doneButton.tag = 1;
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelBarBtn:)];
    [cancelBarButton setTintColor:[UIColor whiteColor]];
    cancelBarButton.tag = 1;
    
    [controlToolbar setItems:[NSArray arrayWithObjects:cancelBarButton,spacer, doneButton, nil] animated:NO];
    
    pickerContainer = [[UIView alloc] initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height - (140+controlToolbar.frame.size.height) , [UIScreen mainScreen].bounds.size.width, 140+controlToolbar.frame.size.height)];
    
    CGFloat pickerViewYpositionHidden = [UIScreen mainScreen].bounds.size.height + pickerContainer.frame.size.height;
    
    CGFloat pickerViewYposition = [UIScreen mainScreen].bounds.size.height - pickerContainer.frame.size.height;
    
    [pickerContainer setFrame:CGRectMake(pickerContainer.frame.origin.x,
                                         pickerViewYpositionHidden,
                                         pickerContainer.frame.size.width,
                                         pickerContainer.frame.size.height)];
    [pickerContainer setBackgroundColor:[UIColor whiteColor]];
    [pickerContainer addSubview:controlToolbar];
    
    pickerDate = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, controlToolbar.frame.size.height, pickerContainer.frame.size.width, 180-controlToolbar.frame.size.height)];
    pickerDate.hidden = NO;
    pickerDate.date = [NSDate date];
    pickerDate.backgroundColor = [UIColor whiteColor];
    [pickerContainer addSubview:pickerDate];
    [pickerDate setHidden:NO];
    
    controlToolbarTit.text = @"Choose your Date";
    pickerDate.datePickerMode = UIDatePickerModeDate;
    
    [self.view addSubview:pickerContainer];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [pickerContainer setFrame:CGRectMake(pickerContainer.frame.origin.x,
                                                              pickerViewYposition,
                                                              pickerContainer.frame.size.width,
                                                              pickerContainer.frame.size.height)];
                     }
                     completion:nil];
    
}

#pragma mark - Pickers delegate

-(void)onCancelBarBtn:(id)sender
{
    CGFloat pickerViewYpositionHidden = [UIScreen mainScreen].bounds.size.height + pickerContainer.frame.size.height;
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [pickerContainer setFrame:CGRectMake(pickerContainer.frame.origin.x,
                                                              pickerViewYpositionHidden,
                                                              pickerContainer.frame.size.width,
                                                              pickerContainer.frame.size.height)];
                     }
                     completion:nil];
}

-(void)onDoneBarBtn:(id)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    UIButton* btn = (UIButton*)sender;
    if(btn.tag==1)
    {
        [formatter setDateFormat:@"dd/MM/yyy"];
        selectedDate = pickerDate.date;
        NSLog(@"selectedDate : %@",selectedDate);
        
        [_fetchEventsByDate setTitle:[NSString stringWithFormat:@"Fetch events by Date : %@",[formatter stringFromDate:pickerDate.date]] forState:UIControlStateNormal];
    }
    
    CGFloat pickerViewYpositionHidden = [UIScreen mainScreen].bounds.size.height + pickerContainer.frame.size.height;
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [pickerContainer setFrame:CGRectMake(pickerContainer.frame.origin.x,
                                                              pickerViewYpositionHidden,
                                                              pickerContainer.frame.size.width,
                                                              pickerContainer.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [self fetchEvents_byDate];
                     }];
}

@end
