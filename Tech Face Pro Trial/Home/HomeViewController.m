//
//  HomeViewController.m
//  Tech Face
//
//  Created by MedEXO on 25/08/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//


#import "HomeViewController.h"
#import "HomeCaptureViewController.h"
#import "Reachability.h"
#import "Server.h"
#import "ToastView.h"
#import "NSData+Extended.h"
#import "NSString+Extended.h"
#import "UIViewController+Extended.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>



@interface HomeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *Compnayuserprofile;
@property (weak, nonatomic) IBOutlet UIImageView *companyBannerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *companyAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyuser;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *Companyname;
@property (weak, nonatomic) IBOutlet UILabel *companydetails;
@property (weak, nonatomic) IBOutlet UILabel *totaltreatments;
@property (weak, nonatomic) IBOutlet UILabel *totalclients;
@property (weak, nonatomic) IBOutlet UILabel *totalschedule;
@property (weak, nonatomic) IBOutlet UIButton *companyBannerButton;
@property (weak, nonatomic) IBOutlet UIButton *companyAvatarButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *practitionersArray;

@property (assign, nonatomic) BOOL isCompanyBanner;
@property (assign, nonatomic) BOOL isCompanyAvatar;

@end

@implementation HomeViewController

NSString *comp_user_id, *company_id, *tf_token, *logout, *message;
UIRefreshControl *refreshControl_pract;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupEmptyBackButtonOnPushed];
    // Setup tableview to use auto height
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    [self.tableView setEstimatedRowHeight:100];
    //  BFLog(@"Hello world!"); // use BFLog as you would use DLog
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *savedValue = [userDefaults objectForKey:@"homedata"];
    NSDictionary *myDictionary = [userDefaults dictionaryForKey:@"homedata"];
    // NSData* data = [savedValue dataUsingEncoding:NSUTF8StringEncoding];
    // NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    // NSString *ad = [s objectForKey:@"vw_company_id"] ;
    // NSString *homedata = [s objectForKey:@"name"] ;
    DLog(@"%@", [myDictionary valueForKeyPath:@"vw_user_id"]);
    DLog(@"%@", [myDictionary valueForKeyPath:@"vw_company_id"]);
    comp_user_id = [myDictionary valueForKeyPath:@"vw_user_id"];
    company_id = [myDictionary valueForKeyPath:@"vw_company_id"];
    tf_token = [myDictionary valueForKeyPath:@"tf_token"];
    DLog(@"%@", savedValue);
    //[self addTapGestureToView:self.companyBannerImageView action:@selector(changeCompanyBanner)];
    //[self addTapGestureToView:self.companyAvatarImageView action:@selector(changeCompanyAvatar)];
    refreshControl_pract = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl_pract];
    [refreshControl_pract addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:@"selected_client_id"];
    [userDefaults setObject:@"0" forKey:@"selected_pract_id"];
    [userDefaults setObject:@"0" forKey:@"pract_shop_id"];
    [userDefaults synchronize];
    
    [self BackGroundProcess];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToSingle:) name:@"pushToSingle" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (IBAction)unwindToHome:(UIStoryboardSegue *)segue {
    // Do nothing
}

- (void)refreshTable {
    //TODO: refresh your data
    [refreshControl_pract endRefreshing];
    [self BackGroundProcess];
}

- (IBAction)changeCompanyBannerAction:(id)sender {
    [self changeCompanyBanner];
}

- (IBAction)changeCompanyAvatarAction:(id)sender {
    [self changeCompanyAvatar];
}

- (void)changeCompanyBanner {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    // picker.allowsEditing = true;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:true completion:nil];
    self.isCompanyBanner = true;
    self.isCompanyAvatar = false;
}

- (void)changeCompanyAvatar {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = true;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:true completion:nil];
    self.isCompanyBanner = false;
    self.isCompanyAvatar = true;
}

- (void)BackGroundProcess {
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [self showAlertWithTitle:@"Oops !!"
                         message:@"Internet Is not avalible"
               cancelButtonTitle:@"Quit App"
                   cancelHandler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }
                   okButtonTitle:@"Retry"
                       okHandler:^(UIAlertAction * _Nonnull action) {
            [self BackGroundProcess];
        }];
        DLog(@"NOT REACHABLE");
    } else {
        [self performSelectorInBackground:@selector(executeInBackgroundHomeconfig) withObject:nil];
        DLog(@"IS REACHABILE");
        [SVProgressHUD show];
    }
}

- (void)checkIsValidAppVersion {
    NSString *latest_version = [app_version valueForKeyPath:@"version"];
    NSString *latest_build = [app_version valueForKeyPath:@"build"];
    NSString *call_update =[app_version valueForKeyPath:@"call_update"];
    int latest_build_int = [latest_build intValue];
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [info objectForKey:@"CFBundleVersion"];
    int build_int = [build intValue];
    
    if ( [call_update isEqualToString:@"Y"] && (![version isEqualToString:latest_version] || build_int < latest_build_int)) {
        [self showAlertWithTitle:@"Oops !!"
                         message:[NSString stringWithFormat:@"Your app version is out of date. Please update app version to %@ (%@).", latest_version, latest_build]
               cancelButtonTitle:@"Quit App"
                   cancelHandler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }
                   okButtonTitle:@"Ok"
                       okHandler:^(UIAlertAction * _Nonnull action) {
      
            [self performSelectorOnMainThread:@selector(updateVersion) withObject:nil waitUntilDone:true];
            
        }];
    }
    
    
    
    if ([logout isEqualToString:@"Y"]){
        
        
        [self showAlertWithTitle:@"Message !!"
                         message:[NSString stringWithFormat:@"%@", message]
               cancelButtonTitle:@"Quit App"
                   cancelHandler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }
                   okButtonTitle:@"Log in again"
                       okHandler:^(UIAlertAction * _Nonnull action) {
            // exit(0);
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"signincheck"];
            [userDefaults synchronize];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Auth" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"login"];
            [self presentViewController:vc animated:true completion:nil];
            
        }];
        
    }
    
}


-(void) updateVersion{

    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/apple-store/id1554967792?mt=8"];
    [application openURL:URL options:@{} completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"Opened url");
        } else {
            exit(0);
        }
    }];
    
    
}

NSDictionary *app_version;
NSDictionary *com_details;
NSDictionary *shop_details;
NSDictionary *com_user_details;
NSDictionary *company_states;

- (void)executeInBackgroundHomeconfig {
    DLog(@"executeInBackground");
    NSURL *url = [Server url:@"/techface_api/getPractitioners?company_id=%@&company_user_id=%@&tf_token=%@&trial=Y", company_id, comp_user_id,tf_token];
    DLog(@"%@", url.absoluteString);
    // Init the URLRequest
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
        //  DLog(@"Respose : %@", response);
        //   DLog(@"Data : %@", data);
        //   DLog(@"Error : %@", error);
        DLog(@"String sent from server %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [SVProgressHUD dismiss];
        NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.practitionersArray = [s objectForKey:@"pract_list"];
        app_version = [s objectForKey:@"app_version"];
        com_details = [s objectForKey:@"com_details"];
        shop_details = [s objectForKey:@"shop_details"];
        com_user_details = [s objectForKey:@"com_user_details"];
        company_states = [s objectForKey:@"company_states"];
        logout = [s objectForKey:@"logout"];
        message = [s objectForKey:@"message"];
        NSString *upload_data_limit = [s objectForKey:@"upload_data_limit"];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:upload_data_limit forKey:@"upload_data_limit"];

       
      //  NSDictionary *myDictionary = [userDefaults dictionaryForKey:@"homedata"];
      //  NSString *data_limit= [myDictionary valueForKeyPath:@"upload_data_limit"];//
      //  [[myDictionary valueForKeyPath:@"upload_data_limit"] mutableSetValueForKey:get_data_limit];
     //   [myDictionary setValue:get_data_limit forKeyPath:@"upload_data_limit"];
     //   [myDictionary mutableSetValueForKeyPath:<#(nonnull NSString *)#>]
    
        
        
        [userDefaults setObject:logout forKey:@"logout"];
        [userDefaults setObject:message forKey:@"message"];
        [userDefaults synchronize];
        
        if (!app_version || app_version == (id)[NSNull null]) {
            app_version = [NSDictionary dictionary]; }
        if (!com_details || com_details == (id)[NSNull null]) {
            com_details = [NSDictionary dictionary]; }
        if (!shop_details || shop_details == (id)[NSNull null]) {
            shop_details = [NSDictionary dictionary]; }
        if (!com_user_details || com_user_details == (id)[NSNull null]) { com_user_details = [NSDictionary dictionary]; }
        if (!company_states || company_states == (id)[NSNull null]) { company_states = [NSDictionary dictionary]; }
        DLog(@"%@", self.practitionersArray);
        DLog(@"%@", com_details);
        DLog(@"%@", shop_details);
        DLog(@"%@", com_user_details);
        DLog(@"%@", company_states);
        [self performSelectorOnMainThread:@selector(checkIsValidAppVersion) withObject:nil waitUntilDone:true];
        [self performSelectorOnMainThread:@selector(executeInMain) withObject:nil waitUntilDone:true];
    }];
    [dataTask resume];
  
}

- (void)executeInMain {
    DLog(@"Total pract : %lu", (unsigned long)self.practitionersArray.count);
    [_tableView reloadData];
    // [self.CompanyDisplaypic sendActionsForControlEvents:UIControlEventTouchUpInside];
    self.Companyname.text = [NSString nonNull:[com_details valueForKeyPath:@"company_name"]];
    self.companydetails.text = [NSString nonNull:[shop_details valueForKeyPath:@"shop_name"]];
    self.companyuser.text = [NSString nonNull:[com_user_details valueForKeyPath:@"name"]];
    //	return;
    self.location.text = @"";
    self.totaltreatments.text = [(NSNumber *)[company_states valueForKeyPath:@"treamtments"] stringValue];
    self.totalclients.text = [(NSNumber *)[company_states valueForKeyPath:@"clients"] stringValue];
    self.totalschedule.text = [(NSNumber *)[company_states valueForKeyPath:@"schedule"] stringValue];
    if ([NSString isEmpty:[com_details valueForKeyPath:@"company_photo_url"]]) {
        DLog(@"company_photo_url : yes");
    } else {
        NSURL *imageUrl = [Server url:@"/storage/company/%@", [com_details valueForKeyPath:@"company_photo_url"]];
        [self.companyAvatarImageView sd_setImageWithURL:imageUrl placeholderImage:nil completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
            self.companyAvatarButton.hidden = TRUE;
        }];
    }
    if ([NSString isEmpty:[com_details valueForKeyPath:@"company_display_pic"]]) {
        DLog(@"company_display_pic : yes");
    } else {
        NSURL *imageUrl = [Server url:@"/storage/company/%@", [com_details valueForKeyPath:@"company_display_pic"]];
        [self.companyBannerImageView sd_setImageWithURL:imageUrl placeholderImage:nil completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
            self.companyBannerButton.hidden = TRUE;
            DLog(@"company_display_pic : yes hide");
        }];
    }
    NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [com_user_details valueForKeyPath:@"avatar"]];
    [self.Compnayuserprofile sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"female_avatar"] completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
        //  self.CompanyDisplaypic.hidden = TRUE;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    DLog(@"call");
    self.isCompanyAvatar = false;
    self.isCompanyBanner = false;
    [picker dismissViewControllerAnimated:true completion:nil];
    // [self dismissModalViewControllerAnimated:true];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable) {
        [self showDismissAlertWithTitle:@"Oops !!"
                                message:@"Internet Is not avalible"];
        DLog(@"NOT REACHABLE");
        return;
    }
    // output image
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:true completion:nil];
    if (self.isCompanyAvatar == true) {
        self.companyAvatarImageView.image = chosenImage;
        self.isCompanyAvatar = false;
        [self performSelectorInBackground:@selector(uploadCompanyAvatar) withObject:nil];
        [SVProgressHUD show];
    } else if (self.isCompanyBanner == true) {
        self.companyBannerImageView.image = chosenImage;
        self.isCompanyBanner = false;
        [self performSelectorInBackground:@selector(uploadCompanyBanner) withObject:nil];
        [SVProgressHUD show];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"%ld", (long)indexPath.row); // you can see selected row number in your console;
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = self.practitionersArray;
    NSData *itemsData = [NSKeyedArchiver archivedDataWithRootObject:array];
    NSNumber *itemIndex = [NSNumber numberWithInteger:indexPath.row];
    
    [userDefaults setObject:[array[indexPath.row] valueForKeyPath:@"vw_user_id"] forKey:@"selected_pract_id"];
    [userDefaults setObject:itemIndex forKey:@"selected_pract_row"];
    [userDefaults setObject:itemsData forKey:@"selected_pract"];
    [userDefaults synchronize];
    @try {
        HomeCaptureViewController *c = (HomeCaptureViewController*) [self.tabBarController.viewControllers objectAtIndex:1];
        c.isSelectedPrac = true;
        self.tabBarController.selectedViewController = c;
    } @catch (NSException *e) {
        NSLog(@"Exception: %@", e);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.practitionersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /* static NSString *simpleTableIdentifier = @"SimpleTableItem";
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
     if (cell == nil) {
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
     }
     cell.textLabel.text =  [pract_list valueForKeyPath:@"name"][indexPath.row];
     NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [pract_list valueForKeyPath:@"avatar"][indexPath.row]];
     DLog(@"Tableview %@", imageUrl);
     
     [cell.imageView sd_setImageWithURL:imageUrl
     placeholderImage:[UIImage imageNamed:@"female_avatar"]];
     */
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Display recipe in the table cell
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:10];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:11];
    NSDictionary *itemDict = self.practitionersArray[indexPath.row];
    NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [itemDict valueForKeyPath:@"avatar"]];
    [imageView sd_setImageWithURL:imageUrl
                 placeholderImage:[UIImage imageNamed:@"doctor_avatar"]];
    nameLabel.text = [itemDict valueForKeyPath:@"name"];
    return cell;
}

- (void)uploadCompanyBanner {
    DLog(@"executeInBackground");
    NSURL *url = [Server url:@"/techface_api/uploadCompanyDisplypic?company_id=%@", company_id];
    DLog(@"%@", url.absoluteString);
    DLog(@"1");
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSData *imageData = UIImageJPEGRepresentation(self.companyBannerImageView.image, 0.5);
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:false];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"unique-consistent-string";
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    // post body
    DLog(@"2");
    NSMutableData *body = [NSMutableData data];
    // add params (all params are strings)
    [body appendString:[NSString stringWithFormat:@"--%@\r\n", boundary]];
    [body appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"imageCaption"]];
    [body appendString:[NSString stringWithFormat:@"%@\r\n", @"Some Caption"]];
    // add image data
    if (imageData) {
        [body appendString:[NSString stringWithFormat:@"--%@\r\n", boundary]];
        [body appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=uploadCompanyDisplypic.jpg\r\n", @"uploadCompanyDisplypic"]];
        [body appendString:@"Content-Type: image/jpeg\r\n\r\n"];
        [body appendData:imageData];
        [body appendString:[NSString stringWithFormat:@"\r\n"]];
    }
    DLog(@"3");
    [body appendString:[NSString stringWithFormat:@"--%@--\r\n", boundary]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    DLog(@"4");
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
        DLog(@"Respose : %@", response);
        DLog(@"Data : %@", data);
        DLog(@"Error : %@", error);
        DLog(@"String sent from server %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        // NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //  DLog(myString);
        //  NSString *myStr = [myString stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *ad = [s objectForKey:@"message"];
        DLog(@"%@", ad);
        // if ([ad isEqualToString:@"Successfully Uploadded"]) {
        if (!error) {
            [SVProgressHUD dismiss];
            [self performSelectorOnMainThread:@selector(exinMainDisplayPic:) withObject:ad waitUntilDone:true];
        } else {
            [SVProgressHUD dismiss];
            [self showDismissAlertWithTitle:@"Upload failed" message:@"Unable to upload image to server."];
        }
    }];
    [dataTask resume];
   
    DLog(@"5");
}

- (void)exinMainDisplayPic:(NSString *)aString; {
    self.companyBannerButton.hidden = TRUE;
    [ToastView showToastInParentView:self.view withText:@"Successfully Uploadded" withDuaration:1.0];
}
- (void)uploadCompanyAvatar {
    DLog(@"executeInBackground");
    NSURL *url = [Server url:@"/techface_api/uploadCompanyPhotopic?company_id=%@", company_id];
    DLog(@"%@", url.absoluteString);
    DLog(@"1");
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSData *imageData = UIImageJPEGRepresentation(self.companyAvatarImageView.image, 0.5);
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:false];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"unique-consistent-string";
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    // post body
    DLog(@"2");
    NSMutableData *body = [NSMutableData data];
    // add params (all params are strings)
    [body appendString:[NSString stringWithFormat:@"--%@\r\n", boundary]];
    [body appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"imageCaption"]];
    [body appendString:[NSString stringWithFormat:@"%@\r\n", @"Some Caption"]];
    // add image data
    if (imageData) {
        [body appendString:[NSString stringWithFormat:@"--%@\r\n", boundary]];
        [body appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=uploadCompanyPhotopic.jpg\r\n", @"uploadCompanyPhotopic"]];
        [body appendString:@"Content-Type: image/jpeg\r\n\r\n"];
        [body appendData:imageData];
        [body appendString:[NSString stringWithFormat:@"\r\n"]];
    }
    DLog(@"3");
    [body appendString:[NSString stringWithFormat:@"--%@--\r\n", boundary]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    DLog(@"4");
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
        DLog(@"Respose : %@", response);
        DLog(@"Data : %@", data);
        DLog(@"Error : %@", error);
        DLog(@"String sent from server %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        // NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //  DLog(myString);
        //  NSString *myStr = [myString stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *ad = [s objectForKey:@"message"];
        DLog(@"%@", ad);
        // if ([ad isEqualToString:@"Successfully Uploadded"]) {
        if (!error) {
            [SVProgressHUD dismiss];
            [self performSelectorOnMainThread:@selector(exinMainProfilepic:) withObject:ad waitUntilDone:true];
        } else {
            [SVProgressHUD dismiss];
            [self showDismissAlertWithTitle:@"Upload failed" message:@"Unable to upload image to server."];
        }
    }];
    [dataTask resume];
   
    DLog(@"5");
}

- (void)exinMainProfilepic:(NSString *)aString; {
    self.companyAvatarButton.hidden = TRUE;
    [ToastView showToastInParentView:self.view withText:@"Successfully Uploadded" withDuaration:1.0];
}

- (void)pushToSingle:(NSNotification *)notis {
    NSDictionary *dict = notis.userInfo;
    int post_id = [[dict objectForKey:@"post_id"] intValue];
    if (post_id == 100) {
        //        IBGLogVerbose(@"Pract called");
        [self BackGroundProcess];
    }
}



- (void) dealloc
{
    DLog(@"HomeViewController dealloc");
}






@end
