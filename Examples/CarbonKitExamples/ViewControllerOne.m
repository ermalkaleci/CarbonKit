
#import <CarbonKit/CarbonKit.h>
#import "ViewControllerOne.h"
#import "ViewControllerThree.h"


@interface ViewControllerOne () <UITableViewDelegate, UITableViewDataSource> {
    CarbonSwipeRefresh *refresh;
}

@end

@implementation ViewControllerOne

- (void)viewDidLoad {
    [super viewDidLoad];

    refresh = [[CarbonSwipeRefresh alloc] initWithScrollView:self.tableView];
    [self.view addSubview:refresh];

    [refresh setColors:@[
        [UIColor blueColor],
        [UIColor redColor],
        [UIColor orangeColor],
        [UIColor greenColor]
    ]];

    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"%@", coordinator);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", (int)indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewControllerThree *view =
        [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerThree"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)refresh:(id)sender {
    NSLog(@"REFRESH");

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

- (void)endRefreshing {
    [refresh endRefreshing];
}

@end
