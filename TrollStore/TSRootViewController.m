#import "TSRootViewController.h"
#import "TSAppTableViewController.h"
#import "TSSettingsListController.h"
#import "TSExperimentalViewController.h" // 1. Импортируем наш новый контроллер

@implementation TSRootViewController // 2. КРИТИЧЕСКИ ВАЖНО: ЭТА СТРОКА ДОЛЖНА БЫТЬ!

- (void)viewDidLoad {
    [super viewDidLoad];

    // Настраиваем внешний вид панелей
    [self setupBarAppearances];

    // 1. Вкладка Apps (индекс 0)
    TSAppTableViewController *appsVC = [[TSAppTableViewController alloc] init];
    UINavigationController *appsNav = [[UINavigationController alloc] initWithRootViewController:appsVC];
    appsNav.navigationBar.prefersLargeTitles = YES;
    appsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Apps"
                                                       image:[UIImage systemImageNamed:@"square.stack.3d.up"]
                                               selectedImage:[UIImage systemImageNamed:@"square.stack.3d.up.fill"]];

    // 2. Вкладка Experimental (индекс 1 - ПОСЕРЕДИНЕ)
    TSExperimentalViewController *experimentalVC = [[TSExperimentalViewController alloc] init];
    UINavigationController *experimentalNav = [[UINavigationController alloc] initWithRootViewController:experimentalVC];
    experimentalNav.navigationBar.prefersLargeTitles = YES;

    UIImage *flaskImg     = [UIImage systemImageNamed:@"flask"] ?: [UIImage systemImageNamed:@"wrench.and.screwdriver"];
    UIImage *flaskFillImg = [UIImage systemImageNamed:@"flask.fill"] ?: [UIImage systemImageNamed:@"wrench.and.screwdriver.fill"];

    experimentalNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Experimental"
                                                               image:flaskImg
                                                       selectedImage:flaskFillImg];

    // 3. Вкладка Settings (индекс 2)
    TSSettingsListController *settingsVC = [[TSSettingsListController alloc] init];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsNav.navigationBar.prefersLargeTitles = YES;
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings"
                                                          image:[UIImage systemImageNamed:@"gearshape"]
                                                  selectedImage:[UIImage systemImageNamed:@"gearshape.fill"]];

    // Устанавливаем массив вкладок: Apps -> Experimental -> Settings
    self.viewControllers = @[appsNav, experimentalNav, settingsNav];
}

- (void)setupBarAppearances {
    UITabBarAppearance *tabBarAppearance = [[UITabBarAppearance alloc] init];
    [tabBarAppearance configureWithDefaultBackground];
    self.tabBar.standardAppearance = tabBarAppearance;
    self.tabBar.tintColor = [UIColor systemBlueColor];

    if (@available(iOS 15.0, *)) {
        self.tabBar.scrollEdgeAppearance = tabBarAppearance;
    }

    UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
    [navBarAppearance configureWithDefaultBackground];

    UINavigationBar.appearance.standardAppearance = navBarAppearance;
    UINavigationBar.appearance.compactAppearance  = navBarAppearance;

    if (@available(iOS 15.0, *)) {
        UINavigationBar.appearance.scrollEdgeAppearance = navBarAppearance;
    }
}

@end // 3. КРИТИЧЕСКИ ВАЖНО: В КОНЦЕ ФАЙЛА ДОЛЖНО БЫТЬ @end