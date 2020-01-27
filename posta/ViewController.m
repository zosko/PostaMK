//
//  ViewController.m
//  posta
//
//  Created by Bosko Petreski on 11/6/17.
//  Copyright © 2017 Bosko Petreski. All rights reserved.
//

#import "ViewController.h"
#import "XMLReader.h"

@import SafariServices;

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *arrTracking;
    IBOutlet UITableView *tblTracking;
}

@end

@implementation ViewController
-(NSString *)daysAgo:(NSDate *)startDate{
    NSDate *endDate = NSDate.date;
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    return [NSString stringWithFormat:@"%ld",(long)components.day];
}
-(IBAction)onBtnGenerate:(id)sender{
    NSMutableArray *strTrack = NSMutableArray.new;
    for(NSDictionary *dict in arrTracking){
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
        
        [arrTracking addObject:@{@"tracking":[NSString stringWithFormat:@"%@",alert.textFields[0].text.uppercaseString],
                                 @"detail":[NSString stringWithFormat:@"%@",alert.textFields[1].text],
                                 @"time":NSDate.date
                                 }];
        [tblTracking reloadData];
        
        [[NSUserDefaults standardUserDefaults] setObject:arrTracking forKey:@"database"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
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
    NSString *strPath = [NSString stringWithFormat:@"http://www.posta.com.mk/tnt/api/query?id=%@",arrTracking[indexPath.row][@"tracking"]];
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:strPath] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
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
        });
        
    }] resume];
}
-(nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Info" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        NSDictionary *dictItem = arrTracking[indexPath.row];
        
        UIAlertAction *actionz = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [arrTracking replaceObjectAtIndex:indexPath.row withObject:@{@"tracking":[NSString stringWithFormat:@"%@",alert.textFields[0].text.uppercaseString],
                                                                         @"detail":[NSString stringWithFormat:@"%@",alert.textFields[1].text],
                                                                         @"time":dictItem[@"time"]
                                                                         }];
            [tblTracking reloadData];
            
            [[NSUserDefaults standardUserDefaults] setObject:arrTracking forKey:@"database"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
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
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Remove" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [arrTracking removeObjectAtIndex:indexPath.row];
        [tblTracking reloadData];
        [[NSUserDefaults standardUserDefaults] setObject:arrTracking forKey:@"database"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }];
    
    UITableViewRowAction *arivedAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:[arrTracking[indexPath.row][@"arrived"] boolValue] ? @"Not Arrived" : @"Arrived" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        NSDictionary *dictItem = arrTracking[indexPath.row];
        [arrTracking replaceObjectAtIndex:indexPath.row withObject:@{@"tracking":dictItem[@"tracking"],
                                                                     @"detail":dictItem[@"detail"],
                                                                     @"time":dictItem[@"time"],
                                                                     @"arrived":@(![dictItem[@"arrived"] boolValue])
                                                                     }];
        [tblTracking reloadData];
        
        [[NSUserDefaults standardUserDefaults] setObject:arrTracking forKey:@"database"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }];
    arivedAction.backgroundColor = UIColor.blueColor;
    
    return @[editAction, arivedAction, deleteAction];
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrTracking.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tracking" forIndexPath:indexPath];
    
    NSDictionary *dictItem = arrTracking[indexPath.row];
    
    cell.textLabel.text = dictItem[@"tracking"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@days) %@",[self daysAgo:dictItem[@"time"]],dictItem[@"detail"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",dictItem[@"detail"]];
    cell.accessoryType = [dictItem[@"arrived"] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    arrTracking = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"database"]];
    [tblTracking reloadData];
}
-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
