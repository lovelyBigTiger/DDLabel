# DDLabel

此demo 仿照[FFLabel](https://github.com/liufan321/FFLabel), 在此向大神致敬!

### 用法

```~
- (void)viewDidLoad {
[super viewDidLoad];

DDLabel *label1 = [[DDLabel alloc] initWithFrame:CGRectMake(0, 100, 375, 300)];
label1.text = @"http://baidu.com哈哈哈哈哈http://hh9999hhh.com";
label1.delegate = self;
[self.view addSubview:label1];
}

- (void)label:(DDLabel *)label didSelectedAtText:(NSString *)text {
NSLog(@"%@---%@", label, text);
}
```
