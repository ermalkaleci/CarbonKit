//
//  CategoriesTableViewController.m
//  Test 2
//
//  Created by Ermal Kaleci on 26/02/15.
//  Copyright (c) 2015 Ermal Kaleci. All rights reserved.
//

#import "CategoriesTableViewController.h"
#import "../../CarbonKit.h"

@interface CategoriesTableViewController ()
{
	CarbonSwipeRefresh *refresh;
}

@end

@implementation CategoriesTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	refresh = [[CarbonSwipeRefresh alloc] initWithScrollView:self.tableView];
	[refresh setMarginTop:0];
	[refresh setColors:@[[UIColor blueColor], [UIColor redColor], [UIColor orangeColor], [UIColor greenColor]]];
	[self.view addSubview:refresh];
	
	[refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	
	// Configure the cell...
	
	return cell;
}

- (void)refresh:(id)sender {
	NSLog(@"REFRESH");
	
	[self performSelector:@selector(endRefreshing) withObject:nil afterDelay:6];
}

- (void)endRefreshing {
	[refresh endRefreshing];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[refresh setMarginTop:0];
}


@end
