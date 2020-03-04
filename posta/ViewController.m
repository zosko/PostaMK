//
//  ViewController.m
//  posta
//
//  Created by Bosko Petreski on 11/6/17.
//  Copyright © 2017 Bosko Petreski. All rights reserved.
//

#import "ViewController.h"
#import "XMLReader.h"
#import "MBProgressHUD.h"

@import CloudKit;
@import SafariServices;

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>{
    NSArray *arrTracking;
    IBOutlet UITableView *tblTracking;
}

@end

@implementation ViewController

-(void)showProgress{
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }];
}
-(void)hideProgress{
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}
-(void)getTrackings{
    [self showProgress];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
        CKQuery *query = [CKQuery.alloc initWithRecordType:@"TrackingData" predicate:predicate];
        query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        [CKContainer.defaultContainer.publicCloudDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
            if(!error){
                [NSOperationQueue.mainQueue addOperationWithBlock:^{
                    [self hideProgress];
                    arrTracking = results;
                    [tblTracking reloadData];
                }];
            }
        }];
    });
}
-(NSString *)daysAgo:(NSDate *)startDate{
    NSDate *endDate = NSDate.date;
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:startDate toDate:endDate options:0];
    return [NSString stringWithFormat:@"%ld",(long)components.day];
}
-(IBAction)onBtnGenerate:(id)sender{
    NSMutableArray *strTrack = NSMutableArray.new;
    for(CKRecord *dict in arrTracking){
        NSString *strTrackingNnumber = [NSString stringWithFormat:@"%@",dict[@"tracking"]];
        
        if(![dict[@"arrived"] boolValue]){
            [strTrack addObject:strTrackingNnumber];
        }
    }
    NSString *strOuput = [strTrack componentsJoinedByString:@","];
    
    NSString *strURL = [NSString stringWithFormat:@"https://www.17track.net/en/track?nums=%@",strOuput];
    strURL = [strURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:strURL]];
    [self presentViewController:controller animated:YES completion:nil];
}
-(IBAction)onBtnAdd:(id)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        CKRecord *record = [[CKRecord alloc] initWithRecordType:@"TrackingData"];
        record[@"detail"] = [NSString stringWithFormat:@"%@",alert.textFields[1].text];
        record[@"tracking"] = [NSString stringWithFormat:@"%@",alert.textFields[0].text.uppercaseString];
        record[@"arrived"] = @(NO);
        [self showProgress];
        [[CKContainer defaultContainer].publicCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
            [self hideProgress];
            if(!error){
                [self getTrackings];
            }
        }];
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"tracking";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"details";
    }];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action];
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showProgress];
    NSString *strPath = [NSString stringWithFormat:@"http://www.posta.com.mk/tnt/api/query?id=%@",arrTracking[indexPath.row][@"tracking"]];
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:strPath] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self hideProgress];
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            NSError *error = nil;
            NSDictionary *dict = [XMLReader dictionaryForXMLData:data options:XMLReaderOptionsProcessNamespaces error:&error];
            
            NSMutableString *strToShow = [NSMutableString stringWithString:@""];
            if(![[dict[@"ArrayOfTrackingData"] allKeys] containsObject:@"TrackingData"]){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Info" message:@"No Data" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            if([dict[@"ArrayOfTrackingData"][@"TrackingData"] isKindOfClass:[NSArray class]]){
                for(NSDictionary *dictTrack in dict[@"ArrayOfTrackingData"][@"TrackingData"]){
                    [strToShow appendString:[NSString stringWithFormat:@"----------\n"]];
                    [strToShow appendString:[NSString stringWithFormat:@"Date: %@\n",dictTrack[@"Date"][@"text"]]];
                    [strToShow appendString:[NSString stringWithFormat:@"Begining: %@\n",dictTrack[@"Begining"][@"text"]]];
                    [strToShow appendString:[NSString stringWithFormat:@"End: %@\n",dictTrack[@"End"][@"text"]]];
                    [strToShow appendString:[NSString stringWithFormat:@"ID: %@\n",dictTrack[@"ID"][@"text"]]];
                    [strToShow appendString:[NSString stringWithFormat:@"Notice: %@\n",dictTrack[@"Notice"][@"text"]]];
                    [strToShow appendString:[NSString stringWithFormat:@"----------\n"]];
                }
            }
            else{
                [strToShow appendString:[NSString stringWithFormat:@"----------\n"]];
                [strToShow appendString:[NSString stringWithFormat:@"Date: %@\n",dict[@"ArrayOfTrackingData"][@"TrackingData"][@"Date"][@"text"]]];
                [strToShow appendString:[NSString stringWithFormat:@"Begining: %@\n",dict[@"ArrayOfTrackingData"][@"TrackingData"][@"Begining"][@"text"]]];
                [strToShow appendString:[NSString stringWithFormat:@"End: %@\n",dict[@"ArrayOfTrackingData"][@"TrackingData"][@"End"][@"text"]]];
                [strToShow appendString:[NSString stringWithFormat:@"ID: %@\n",dict[@"ArrayOfTrackingData"][@"TrackingData"][@"ID"][@"text"]]];
                [strToShow appendString:[NSString stringWithFormat:@"Notice: %@\n",dict[@"ArrayOfTrackingData"][@"TrackingData"][@"Notice"][@"text"]]];
                [strToShow appendString:[NSString stringWithFormat:@"----------\n"]];
            }
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Info" message:strToShow preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }];
        
    }] resume];
}
- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIContextualAction *editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Edit" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Info" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        CKRecord *dictItem = arrTracking[indexPath.row];
        
        UIAlertAction *actionz = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showProgress];
            [[CKContainer defaultContainer].publicCloudDatabase fetchRecordWithID:dictItem.recordID completionHandler:^(CKRecord *record, NSError *error) {
                [self hideProgress];
                if (error) {
                    return;
                }
                [NSOperationQueue.mainQueue addOperationWithBlock:^{
                    [self showProgress];
                    record[@"tracking"] = [NSString stringWithFormat:@"%@",alert.textFields[0].text.uppercaseString];
                    record[@"detail"] = [NSString stringWithFormat:@"%@",alert.textFields[1].text];
                    [[CKContainer defaultContainer].publicCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                        [self hideProgress];
                        [self getTrackings];
                    }];
                }];
            }];
            
            
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = [NSString stringWithFormat:@"%@",dictItem[@"tracking"]];
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = [NSString stringWithFormat:@"%@",dictItem[@"detail"]];
        }];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert addAction:actionz];
        [alert addAction:action1];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
    UIContextualAction *removeAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Remove" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        CKRecord *dictItem = arrTracking[indexPath.row];
        
        [self showProgress];
        [[CKContainer defaultContainer].publicCloudDatabase deleteRecordWithID:dictItem.recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
            [self hideProgress];
            [self getTrackings];
        }];
    }];
    
    UIContextualAction *arrivedAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:[arrTracking[indexPath.row][@"arrived"] boolValue] ? @"Not Arrived" : @"Arrived" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        CKRecord *dictItem = arrTracking[indexPath.row];
        
        [self showProgress];
        [[CKContainer defaultContainer].publicCloudDatabase fetchRecordWithID:dictItem.recordID completionHandler:^(CKRecord *record, NSError *error) {
            [self hideProgress];
            if (error) {
                return;
            }
            record[@"arrived"] = @(![dictItem[@"arrived"] boolValue]);
            
            [self showProgress];
            [[CKContainer defaultContainer].publicCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                [self hideProgress];
                [self getTrackings];
            }];
        }];
    }];
    arrivedAction.backgroundColor = UIColor.blueColor;
    
    return [UISwipeActionsConfiguration configurationWithActions:@[editAction,removeAction,arrivedAction]];
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrTracking.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tracking" forIndexPath:indexPath];
    
    CKRecord *dictItem = arrTracking[indexPath.row];
    
    cell.textLabel.text = dictItem[@"tracking"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@days) %@",[self daysAgo:dictItem.creationDate],dictItem[@"detail"]];
    cell.accessoryType = [dictItem[@"arrived"] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self getTrackings];
}
-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
