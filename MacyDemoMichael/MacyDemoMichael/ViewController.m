//
//  ViewController.m
//  MacyDemoMichael
//
//  Created by 钱骏 on 16/5/3.
//  Copyright © 2016年 钱骏. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#define keyPath @"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf="


@interface ViewController ()
   

@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
- (IBAction)sbtnPress:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong,nonatomic)NSMutableArray *jsonResult;

@end

BOOL flag;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setUIAndMemory];
}

-(void)setUIAndMemory{
     self.view.backgroundColor = [UIColor blackColor];
     [self.tblView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0]];
     self.searchTF.layer.cornerRadius = 8;
     self.searchButton.layer.cornerRadius = 12;
     self.searchTF.returnKeyType = UIReturnKeySearch;
    
     _jsonResult = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sbtnPress:(id)sender {
    [self.searchTF resignFirstResponder];
    _jsonResult = nil;
    if (![self.searchTF.text length]) {
        flag = true;
        [_tblView reloadData];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Loading...";
    [self jsonParse:self.searchTF.text];
}


-(void)jsonParse:(NSString *)stringInput{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];

    NSString *stringSearch = [NSString stringWithFormat:@"%@%@",keyPath,stringInput];
    NSURL *url = [NSURL URLWithString:stringSearch];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    //create the urlSessiomDataTask
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if(error){
            //if the error and set flag is 0, updata the UI and shows the network error
            flag = false;
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showAlert:@"Networking error"];
            });
        }
        else{//if have the data, shows the flag as 1 and update UI, reload the data in the tableView
            id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            if([jsonData firstObject]){
                flag = true;
                _jsonResult = [jsonData mutableCopy];
                NSLog(@"%@",_jsonResult);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tblView reloadData];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }
            
            else{  //if the network works fine, and no data, update UI here
                flag = false;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tblView reloadData];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showAlert:@"No Resault founded on the server"];
                    
                });
            }
            
        }
    }];
    
    [dataTask resume];
}


#pragma show alert

-(void)showAlert:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction  *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:^{
    }];
}

#pragma -mark UITableViewDelegate Method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.jsonResult.count == 0)// when no result or no begin search, use 1 cell to show "Sorry, no result found :(" or nothing.
        return 1;
    else
        return [[[_jsonResult firstObject] valueForKey:@"lfs"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    cell.textLabel.text = [[[_jsonResult valueForKey:@"lfs"] objectAtIndex:indexPath.row]valueForKey:@"lf"];
    
    
    if ([[[_jsonResult firstObject] valueForKey:@"lfs"] count] == 0)
    {
        if (flag == false){
            cell.textLabel.text = @"";//when no begin search, show nothing at cell.
            cell.detailTextLabel.text = @"";
        }
        else{
            cell.textLabel.text = @"Sorry, no result found :(";//when no search results.
            cell.detailTextLabel.text = @"Sorry, no result found :(";
        }
    }
    else{
        cell.textLabel.text= [[[[_jsonResult firstObject] valueForKey:@"lfs"] objectAtIndex:indexPath.row] valueForKey:@"lf"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"The freq show is %@",[[[[_jsonResult firstObject] valueForKey:@"lfs"] objectAtIndex:indexPath.row] valueForKey:@"freq"]];
    }
    cell.layer.cornerRadius = 3;
    cell.contentView.layer.cornerRadius = 8;
    cell.contentView.layer.borderColor = [UIColor purpleColor].CGColor;
    cell.contentView.layer.borderWidth = 1;
    return cell;
}

@end
