//
//  SelectClientViewController.m
//  Tech Face
//
//  Created by MedEXO on 07/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "TreatmentTypeViewController.h"
//#import "PractitionerSearchViewController.h"
#import "SaveTreatmentViewController.h"
#import "Reachability.h"
#import "Server.h"
#import "ToastView.h"
#import "NSString+Extended.h"
#import "UIViewController+Extended.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface TreatmentTypeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSString *logout;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *catno;
@property (strong, nonatomic) NSString *cid;
@property (strong, nonatomic) NSMutableDictionary *arrCategoryTreatmentTypes;

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableArray *catArray;
@property (strong, nonatomic) NSMutableArray *previosItems;
@property (strong, nonatomic) NSArray *filteredItems;
@property (strong, nonatomic) NSString *arrayType;
@property (strong, nonatomic) NSString *selectedCatno;
@property (nonatomic, getter=isModalInPresentation) BOOL modalInPresentation;

@property (weak, nonatomic) IBOutlet UISearchBar *SearchBarLabel;
@property (weak, nonatomic) IBOutlet UILabel *SearchLabel;

@property (strong, nonatomic) NSString *searchText;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

- (IBAction)doBackAction:(id)sender;

@end

@implementation TreatmentTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modalInPresentation = true;

    // Setup background to dismiss keyboard
    
    [self setTapToDismissKeyboardForView:self.view];
    // Setup tableview to use auto height
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    [self.tableView setEstimatedRowHeight:100];
    // Setup pull-to-refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSDictionary *data = [userDefaults dictionaryForKey:@"homedata"];
    
    self.arrCategoryTreatmentTypes =[[NSMutableDictionary alloc] init];
    self.selectedArray = [[NSMutableDictionary alloc] init];
    
    NSObject *getMultiTreatment = [userDefaults objectForKey:@"selectedtreatment"];
    
    for(NSData *obj in getMultiTreatment){
        
        NSError *error;
        NSMutableDictionary *getDataCheck = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSMutableDictionary class] fromData:obj error:&error];
        
        for(NSString *key in getDataCheck){
            NSString *name = [getDataCheck objectForKey:key];
            [self.selectedArray setValue:name forKey:key];
        
        }
        
    }
   
    
    self.tableView.delegate = (id)self;
    self.tableView.dataSource = (id)self;
    [self updateCategoryTreatment:@"load"];
    
}


- (void)updateCategoryTreatment:(NSString *)action{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *catArray =[[NSMutableArray alloc] init];
    
    bool runLoop = true;
    int countLooop = 0;
    
    [self.tableView setEditing:NO animated:NO];
    //[self.tableView setEditing:YES animated:YES];
   
    while(runLoop){
        
        if([action isEqualToString:@"back"]){
            break;
        }
        
        if([NSString isEmpty:self.catno] && [NSString isEmpty:self.cid]){
            self.items=[userDefaults objectForKey:@"categoryTreatmentType"];
           [self.arrCategoryTreatmentTypes setValue:self.items forKey:@"cat_0"];
            break;
        } else {
            catArray = self.items;
            if([self.arrayType isEqualToString:@"category"]){
            [self.arrCategoryTreatmentTypes setValue:self.items forKey:self.catno];
            }
        }
        

        for (NSMutableArray* obj in catArray) {
            NSString *getCatno = [obj valueForKeyPath:@"catno"];
            NSString *getCid = [obj valueForKeyPath:@"id"];
            NSMutableArray *submenu = [obj valueForKeyPath:@"submenu"];
            NSMutableArray *treatmentSubmenu = [obj valueForKeyPath:@"treatmentSubmenu"];
    
            if(self.cid==getCid && self.catno==getCatno){
                
                if ([submenu count] > 0) {
                    self.searchText = nil;
                    self.SearchBarLabel.text=nil;
                    self.items=submenu;
                    runLoop=false;
                    break;
                } else if([treatmentSubmenu count] >0 ){
                    self.searchText = nil;
                    self.SearchBarLabel.text=nil;
                    self.items=treatmentSubmenu;
                    runLoop=false;
                    break;
                }
            }
            
            runLoop=false;
            if(countLooop > 2000){
                break;
            }
            
            countLooop++;
  
        }
        
        
        if(countLooop > 2000){
            break;
        }
        countLooop++;
        
    }

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // DiNSUserDefaults resources that can be recreated.
}

- (IBAction)unwindOnPracitionerSelected:(UIStoryboardSegue *)segue {
    [SVProgressHUD show];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.parentViewController performSegueWithIdentifier:@"Start Capture" sender:nil];
    });
}

- (void)refreshTable {
    //TODO: refresh your data
    [self.refreshControl endRefreshing];
   // [self BackGroundProcess];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([NSString isEmpty:self.searchText]) {
        return [self.items count];
    }
    return [self.filteredItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Display item in the table cell

    UILabel *nameLabel = (UILabel *)[cell viewWithTag:11];
    UILabel *nameRoundContainerLabel = (UILabel *)[cell viewWithTag:12];
    NSArray *array = [NSString isEmpty:self.searchText] ? self.items : self.filteredItems;
    
   // DLog(@"client array %@", array);
    NSDictionary *itemDict = array[indexPath.row];
    NSString *selected = [itemDict valueForKeyPath:@"selected"];
    cell.accessoryType=UITableViewCellAccessoryNone;
    nameLabel.textColor=[UIColor blackColor];
    UIFont *fontstyle = [UIFont fontWithName:@"Arial" size:15.0];
    nameLabel.font =fontstyle;
    
  //  NSMutableArray *treatmentSubmenu = [[NSMutableArray alloc] init];
    NSMutableArray *treatmentSubmenu = [array[indexPath.row] valueForKey:@"treatmentSubmenu"];
    NSString  *lastfolder = [itemDict valueForKeyPath:@"lastfolder"];
    if([treatmentSubmenu count] > 0)
    {
        nameRoundContainerLabel.layer.borderWidth = 3;
        nameRoundContainerLabel.layer.borderColor =[[UIColor systemBlueColor] CGColor];
    } else {
        nameRoundContainerLabel.layer.borderWidth = 0;
        
    }
    
    if(![NSString isEmpty:selected]){
        
        NSString *treatmentId = [itemDict valueForKeyPath:@"id"];
        NSString *checked =@"N";
        if([self.selectedArray objectForKey:treatmentId]!=nil){
            checked =@"Y";
        }
        
        
        if([checked isEqualToString:@"Y"]){
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
            nameLabel.textColor=[UIColor blueColor];
            UIFont *fontstyle = [UIFont fontWithName:@"Arial" size:20.0];
            nameLabel.font =fontstyle;
            
        }
    }

  //  nameLabel.text = [NSString stringWithFormat:@"[%@] %@", [itemDict valueForKeyPath:@"name"], [itemDict valueForKeyPath:@"name"]];

  //  NSString *selectedCatno = [itemDict valueForKeyPath:@"catno"];
    self.selectedCatno =  [itemDict valueForKeyPath:@"catno"];
    nameLabel.text = [NSString stringWithFormat:@"%@", [itemDict valueForKeyPath:@"name"]];
    [self setSerachTextTitle];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    NSArray *array = [NSString isEmpty:self.searchText] ? self.items : self.filteredItems;
   // NSData *itemsData = [NSKeyedArchiver archivedDataWithRootObject:array];
   // NSNumber *itemIndex = [NSNumber numberWithInteger:indexPath.row];
   
    self.arrayType = [array[indexPath.row] valueForKey:@"arraytype"];
    
    
    bool runUpdate = true;
    if([self.arrayType isEqualToString:@"category"]){

        NSMutableArray *submenu = [array[indexPath.row] valueForKey:@"submenu"];
        NSMutableArray *treatmentSubmenu = [array[indexPath.row] valueForKey:@"treatmentSubmenu"];
        
        if([submenu count] > 0 || [treatmentSubmenu count]){
        
            self.catno=[array[indexPath.row] valueForKey:@"catno"];
            self.cid=[array[indexPath.row] valueForKey:@"id"];
        } else {
            
            runUpdate = false;
        }
    } else if([self.arrayType isEqualToString:@"treatment"]) {
       
        NSString *treatmentId = [array[indexPath.row] valueForKey:@"id"];
        NSString *name = [array[indexPath.row] valueForKey:@"name"];

        NSString *checked =@"N";
        
        if([self.selectedArray objectForKey:treatmentId]!=nil){
            checked =@"Y";
        }

        if([checked isEqualToString:@"Y"]){
            [self.selectedArray removeObjectForKey:treatmentId];
        } else {
            [self.selectedArray setValue:name forKey:treatmentId];
        }
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        if([self.selectedArray count] > 0){
      
            NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:[self.selectedArray count]];
            NSError *error;
            NSData *treatmentObj =[NSKeyedArchiver archivedDataWithRootObject:self.selectedArray requiringSecureCoding:YES error:&error];
            [archiveArray addObject:treatmentObj];
            
            [userDefaults setObject:archiveArray forKey:@"selectedtreatment"];

        } else {
            [userDefaults setObject:nil forKey:@"selectedtreatment"];
        }
        
        [userDefaults synchronize];
        
    }
    
    if(runUpdate){
    [self updateCategoryTreatment:@"load"];    
    [self.tableView reloadData];
    }
    
 
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchText = searchText;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@ || (name contains[c] %@ && name != '')", searchText, searchText];
    
    self.filteredItems = [self.items filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}



- (void) dealloc
{
    DLog(@"TreatmentType dealloc");

}

- (void)setSerachTextTitle{
        
        if([self.selectedCatno isEqualToString:@"cat_0"]){
            self.SearchLabel.text=@"Category SEARCH";
        } else if([self.selectedCatno isEqualToString:@"cat_1"]){
            self.SearchLabel.text=@"1st Sub-Category SEARCH";
        } else if([self.selectedCatno isEqualToString:@"cat_2"]){
            self.SearchLabel.text=@"2nd Sub-Category SEARCH";
        } else if ([self.selectedCatno isEqualToString:@"cat_3"]){
            self.SearchLabel.text=@"3th Sub-Category SEARCH";
        } else if ([self.selectedCatno isEqualToString:@"cat_4"]){
            self.SearchLabel.text=@"4th Sub-Category SEARCH";
        } else {
            self.SearchLabel.text=@"Treatment List SEARCH";
        }
     
}


- (IBAction)doBackAction:(id)sender {
    
    self.searchText=nil;
    self.SearchBarLabel.text=nil;
    if (![NSString isEmpty:self.catno]) {
        
        self.items =  [self.arrCategoryTreatmentTypes valueForKey:self.catno];
        [self.arrCategoryTreatmentTypes setValue:nil forKey:self.catno];
        
        if([self.catno isEqualToString:@"cat_0"]){
            self.catno= NULL;
        } else if([self.catno isEqualToString:@"cat_1"]){
            self.catno=@"cat_0";
                                        
        } else if([self.catno isEqualToString:@"cat_2"]){
            self.catno=@"cat_1";
            
        } else if ([self.catno isEqualToString:@"cat_3"]){
            self.catno=@"cat_2";
            
        } else if ([self.catno isEqualToString:@"cat_4"]){
            self.catno=@"cat_3";
            
        }

     }
    
    [self updateCategoryTreatment:@"back"];
    
    [self.tableView reloadData];
   
}


- (IBAction)editControlWasClicked:(id)sender{
    
    DLog(@"clicked");
    
}


@end

