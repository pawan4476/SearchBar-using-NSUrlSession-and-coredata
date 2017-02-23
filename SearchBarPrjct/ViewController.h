//
//  ViewController.h
//  SearchBarPrjct
//
//  Created by Nagam Pawan on 10/5/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)download:(id)sender;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultController;
@property (strong, nonatomic) NSArray *artistsObject;
@property (strong, nonatomic) NSIndexPath *selectedPath;
@end

