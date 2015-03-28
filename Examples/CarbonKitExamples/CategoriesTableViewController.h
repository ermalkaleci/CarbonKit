//
//  CategoriesTableViewController.h
//  Test 2
//
//  Created by Ermal Kaleci on 26/02/15.
//  Copyright (c) 2015 Ermal Kaleci. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoriesTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
