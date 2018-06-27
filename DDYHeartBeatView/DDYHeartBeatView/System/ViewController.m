#import "ViewController.h"
#import "DDYHeartBeat.h"

#define DDYTopH (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *testDataArray;

@property (nonatomic, strong) DDYHeartBeat *testView1;

@property (nonatomic, strong) DDYHeartBeat *testView2;

@property (nonatomic, assign) BOOL isDied;

@end

@implementation ViewController

- (DDYHeartBeat *)testView1 {
    if (!_testView1) {
        _testView1 = [DDYHeartBeat heartBeatViewWithMaxPointCount:50 type:DDYHeartBeatTypeRefresh];
        _testView1.backgroundColor = [UIColor blackColor];
        _testView1.frame = CGRectMake(10, DDYTopH + 15, self.view.bounds.size.width-20, 220);
    }
    return _testView1;
}

- (DDYHeartBeat *)testView2 {
    if (!_testView2) {
        _testView2 = [DDYHeartBeat heartBeatViewWithMaxPointCount:100 type:DDYHeartBeatTypeTranslation];
        _testView2.backgroundColor = [UIColor blackColor];
        _testView2.frame = CGRectMake(10, DDYTopH + 15 + 220 + 15, self.view.bounds.size.width-20, 220);
    }
    return _testView2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:self.testView1];
    [self.view addSubview:self.testView2];
    [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(addData) userInfo:nil repeats:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isDied = YES;
    });
}

- (void)addData {
    static NSInteger index = 0;
    if (_isDied) {
        [self.testView1 addData:@"0"];
        [self.testView2 addData:@"0"];
    } else {
        [self.testView1 addData:self.testDataArray[index]];
        [self.testView2 addData:self.testDataArray[index]];
    }
        
    index ++;
    index %= 100;
}

- (NSMutableArray *)testDataArray {
    if (!_testDataArray) {
        _testDataArray = [NSMutableArray arrayWithObjects:@"-100",@"-100",@"-100",@"-4",@"-5",@"-5",@"-5",@"-5",@"-5",@"-5",@"-5",@"-12",@"-16",@"-19",@"-21",@"-22",@"-21",@"-20",@"-18",@"-16",@"-13",@"-10",@"-8",@"-7",@"-7",@"-7",@"-7",@"-7",@"-7",@"-7",@"-8",@"-9",@"-9",@"-9",@"-8",@"-7",@"-6",@"-5",@"-4",@"-2",@"-1",@"-0",@"1",@"2",@"3",@"4",@"3",@"1",@"-1",@"-4",@"-6",@"-6",@"-6",@"-4",@"-2",@"1",@"4",@"8",@"10",@"10",@"9",@"7",@"5",@"2",@"1",@"-1",@"-2",@"-4",@"-5",@"-6",@"-6",@"-6",@"-17",@"-27",@"-27",@"8",@"107",@"150",@"150",@"100",@"90",@"4",@"-17",@"-17",@"-9",@"0",@"0",@"0",@"0",@"0",@"0",@"4",@"12",@"16",@"19",@"21",@"23",@"26",@"30",@"32", nil];
    }
    return _testDataArray;
}

@end
