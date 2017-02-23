//
//  ViewController.m
//  SearchBarPrjct
//
//  Created by Nagam Pawan on 10/5/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
//#import "artObject.h"

@interface ViewController ()

@end

@implementation ViewController{
    
        NSDictionary *json;
        NSMutableArray *shortResults;
        NSManagedObject *artObject;
    }

//-(NSPersistentContainer *)persistentContainer {
//    return ((AppDelegate *)[UIApplication sharedApplication].delegate).persistentContainer;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
    [self.tableView reloadData];
    
    self.artistsObject = [[NSMutableArray alloc]init];
    json = [[NSDictionary alloc]init];


}
-(void)refresh:(UIRefreshControl *)refresh{
    [refresh endRefreshing];
}
-(NSManagedObjectContext *)getContext{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    return context;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)download:(id)sender {
    
    [self.tableView reloadData];
    NSManagedObjectContext *context = [self getContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Artists"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"artistName" ascending:YES]];
    NSError *error = nil;
    
    self.artistsObject = [[NSArray alloc] initWithArray:[context executeFetchRequest:fetchRequest error:&error]];
    shortResults = [[NSMutableArray alloc]initWithArray:self.artistsObject];
    NSLog(@"Short rasults are: %@", shortResults);
        if (self.artistsObject.count == 0) {
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *downloadTask = [session dataTaskWithURL:[NSURL URLWithString:@"https://itunes.apple.com/search?term=apple&media=software"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSArray *jsonResult = [json valueForKey:@"results"];
                for (NSDictionary *performDic in jsonResult){
                    NSManagedObject *artistObjectFronDb = [NSEntityDescription insertNewObjectForEntityForName:@"Artists" inManagedObjectContext:context];
                    NSString *tempName = [performDic objectForKey:@"artistName"];
                    [artistObjectFronDb setValue:tempName forKey:@"artistName"];
                    NSString *tempId = [NSString stringWithFormat:@"%@", [performDic objectForKey:@"artistId"]];
                    [artistObjectFronDb setValue:tempId forKey:@"artistID"];
                    if (![context save:nil]) {
                        NSLog(@"Not saved");
                    }
                    else{
                        NSLog(@"Data saved Successfully");
                        [self.tableView reloadData];
                    }
                }

            }];
            [downloadTask resume];
            [self.tableView reloadData];
        }
        else{
            NSLog(@"Data is present");
            dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            });
        }
        
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return shortResults.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    artObject = [shortResults objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont systemFontOfSize:20.0]];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:15.0]];
    
    
    cell.textLabel.textColor = [UIColor redColor];
    cell.detailTextLabel.textColor = [UIColor blueColor];
    
    cell.textLabel.text = [artObject valueForKey:@"artistName"];
    cell.detailTextLabel.text = [artObject valueForKey:@"artistID"];
    return cell;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length == 0) {
        [shortResults removeAllObjects];
        [shortResults addObjectsFromArray:self.artistsObject];
    }
    else{
        [shortResults removeAllObjects];
        for (artObject in _artistsObject) {
            NSRange range = [[artObject valueForKey:@"artistName"] rangeOfString:searchText];
            if (range.location != NSNotFound) {
                [shortResults addObject:artObject];
            }
        }
    }
    [self.tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    
}
@end
