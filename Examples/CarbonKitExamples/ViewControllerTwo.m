#import <CarbonKit/CarbonKit.h>
#import "ViewControllerThree.h"
#import "ViewControllerTwo.h"


@interface ViewControllerTwo () <UICollectionViewDelegate, UICollectionViewDataSource> {
    CarbonSwipeRefresh *refreshControl;
}

@end

@implementation ViewControllerTwo

- (void)viewDidLoad {
    [super viewDidLoad];

    refreshControl = [[CarbonSwipeRefresh alloc] initWithScrollView:self.collectionView];
    [refreshControl addTarget:self
                       action:@selector(refresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    UICollectionViewFlowLayout *flowLayout =
        (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake((self.view.frame.size.width - 30) / 2, 145);
}

- (void)refresh:(id)sender {
    NSLog(@"REFRESH");

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
    });
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ViewControllerThree *view =
        [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerThree"];
    [self.navigationController pushViewController:view animated:YES];
}

@end
