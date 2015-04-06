#import "ViewControllerTwo.h"

@implementation ViewControllerTwo

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Details";
	self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
