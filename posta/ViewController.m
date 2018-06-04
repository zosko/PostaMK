//
//  ViewController.m
//  posta
//
//  Created by Bosko Petreski on 11/6/17.
//  Copyright © 2017 Bosko Petreski. All rights reserved.
//

#import "ViewController.h"
#import "XMLReader.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *arrTracking;
    IBOutlet UITableView *tblTracking;
}

@end

@implementation ViewController

-(IBAction)onBtnAdd:(id)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [arrTracking addObject:@{@"tracking":[NSString stringWithFormat:@"%@",alert.textFields[0].text.uppercaseString],
                                 @"detail":[NSString stringWithFormat:@"%@",alert.textFields[1].text]
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
            NSLog(@"%@",dict);
            
            NSMutableString *strToShow = [NSMutableString stringWithString:@""];
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
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [arrTracking removeObjectAtIndex:indexPath.row];
        [tblTracking reloadData];
        [[NSUserDefaults standardUserDefaults] setObject:arrTracking forKey:@"database"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrTracking.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tracking" forIndexPath:indexPath];
    
    cell.textLabel.text = arrTracking[indexPath.row][@"tracking"];
    cell.detailTextLabel.text = arrTracking[indexPath.row][@"detail"];
    
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
