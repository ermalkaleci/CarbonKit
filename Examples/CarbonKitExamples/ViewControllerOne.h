#import <UIKit/UIKit.h>

@interface ViewControllerOne : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
