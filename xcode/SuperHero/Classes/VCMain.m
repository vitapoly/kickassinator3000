//
//  VCMain.m
//  BlunoTest
//
//  Created by Seifer on 13-12-1.
//  Copyright (c) 2013年 DFRobot. All rights reserved.
//

#import "VCMain.h"
#import "../unirest/Unirest/UNIRest.h"

const int POS_OPEN = 0;
const int POS_MIDDLE = 1;
const int POS_CLOSE = 2;

@interface VCMain ()

@end

@implementation VCMain

#pragma mark- LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.blunoManager = [DFBlunoManager sharedInstance];
    self.blunoManager.delegate = self;
    self.aryDevices = [[NSMutableArray alloc] init];
    self.lbReady.text = @"Not Ready!";

    self.speechSyn = [[AVSpeechSynthesizer alloc] init];
    self.speechSyn.delegate = self;
    
    self.speechToTextObj = [[SpeechToTextModule alloc] initWithCustomDisplay:@"SineWaveViewController"];
    [self.speechToTextObj setDelegate:self];
    recognizingSpeech = FALSE;
    
    self.boosters.alpha = 0;
    self.magnet.alpha = 0;
    self.laser.alpha = 0;
    self.motion.alpha = 0;
    self.lights.alpha = 0;
    
    self.webView.frame = CGRectMake(0, 0, self.webView.frame.size.width, self.webView.frame.size.height);
    self.webView.alpha = 0;
    
//    [self didReceiveVoiceResponse:[@"{\"result\":[{\"alternative\":[{\"transcript\":\"hello Google\",\"confidence\":0.98762906}],\"final\":true}],\"result_index\":0}" dataUsingEncoding:NSUTF8StringEncoding]];
    
//    [self recognizeImage];
//    [self showNightVision];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Actions

- (IBAction)actionSearch:(id)sender
{
    [self.aryDevices removeAllObjects];
    [self.tbDevices reloadData];
    [self.SearchIndicator startAnimating];
    self.viewDevices.hidden = NO;
    
    [self.blunoManager scan];
}

- (IBAction)actionReturn:(id)sender
{
    [self.SearchIndicator stopAnimating];
    [self.blunoManager stop];
    self.viewDevices.hidden = YES;
}

- (IBAction)actionSend:(id)sender
{
    [self sendBT:@"on"];
    return;
    [self.txtSendMsg resignFirstResponder];
    if (self.blunoDev.bReadyToWrite)
    {
        NSString* strTemp = [NSString stringWithFormat:@"%@\n", self.txtSendMsg.text];
        NSData* data = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        [self.blunoManager writeDataToDevice:data Device:self.blunoDev];
    }
}

- (IBAction)actionDidEnd:(id)sender
{
    [self.txtSendMsg resignFirstResponder];
}

#pragma mark- DFBlunoDelegate

-(void)bleDidUpdateState:(BOOL)bleSupported
{
    if(bleSupported)
    {
//        [self.blunoManager scan];
    }
}
-(void)didDiscoverDevice:(DFBlunoDevice*)dev
{
    BOOL bRepeat = NO;
    for (DFBlunoDevice* bleDevice in self.aryDevices)
    {
        if ([bleDevice isEqual:dev])
        {
            bRepeat = YES;
            break;
        }
    }
    if (!bRepeat)
    {
        [self.aryDevices addObject:dev];
        
//        if ([dev.identifier isEqualToString:@"E57458DD-E9D6-4FFE-541D-CDA93404EABC"])
        if ([dev.name isEqualToString:@"BlunoV1.8"])
        {
            if (self.blunoDev == nil)
            {
                self.blunoDev = dev;
                [self.blunoManager connectToDevice:self.blunoDev];
            }
            else if ([dev isEqual:self.blunoDev])
            {
                if (!self.blunoDev.bReadyToWrite)
                {
                    [self.blunoManager connectToDevice:self.blunoDev];
                }
            }
            else
            {
                if (self.blunoDev.bReadyToWrite)
                {
                    [self.blunoManager disconnectToDevice:self.blunoDev];
                    self.blunoDev = nil;
                }
                
                [self.blunoManager connectToDevice:dev];
            }

        }
    }
//    [self.tbDevices reloadData];
}
-(void)readyToCommunicate:(DFBlunoDevice*)dev
{
    self.blunoDev = dev;
    self.lbReady.text = @"Ready!";
}
-(void)didDisconnectDevice:(DFBlunoDevice*)dev
{
    self.lbReady.text = @"Not Ready!";
}
-(void)didWriteData:(DFBlunoDevice*)dev
{
    
}
-(void)didReceiveData:(NSData*)data Device:(DFBlunoDevice*)dev
{
    NSString* msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.lbReceivedMsg.text = msg;
    [self receiveBT:msg];
}

#pragma mark- TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger nCount = [self.aryDevices count];
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"ScanDeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [[NSBundle mainBundle] loadNibNamed:@"CellDeviceList" owner:self options:nil];
        }
        else
        {
            
        }
        
        cell = self.cellDevices;
	}
    
    UILabel* lbName             = (UILabel*)[cell viewWithTag:1];
    UILabel* lbUUID             = (UILabel*)[cell viewWithTag:2];
    DFBlunoDevice* peripheral   = [self.aryDevices objectAtIndex:indexPath.row];
    
    lbName.text = peripheral.name;
    lbUUID.text = peripheral.identifier;
    
    return cell;
    
}


#pragma mark- TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFBlunoDevice* device = [self.aryDevices objectAtIndex:indexPath.row];
    if (self.blunoDev == nil)
    {
        self.blunoDev = device;
        [self.blunoManager connectToDevice:self.blunoDev];
    }
    else if ([device isEqual:self.blunoDev])
    {
        if (!self.blunoDev.bReadyToWrite)
        {
            [self.blunoManager connectToDevice:self.blunoDev];
        }
    }
    else
    {
        if (self.blunoDev.bReadyToWrite)
        {
            [self.blunoManager disconnectToDevice:self.blunoDev];
            self.blunoDev = nil;
        }
        
        [self.blunoManager connectToDevice:device];
    }
    self.viewDevices.hidden = YES;
    [self.SearchIndicator stopAnimating];
}







-(void)start
{
    //TODO: start tcp server
}

-(IBAction)connectBT:(id)sender
{
    [self speak:@"connecting to bluetooth"];
    [self.aryDevices removeAllObjects];
    [self.blunoManager scan];
    
//    [self startSpeechRecognition];
}

-(void)sendBT:(NSString *)msg
{
    [self speak:msg];
    if (self.blunoDev.bReadyToWrite)
    {
        NSString* strTemp = [NSString stringWithFormat:@"%@\n", msg];
        NSData* data = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        [self.blunoManager writeDataToDevice:data Device:self.blunoDev];
    }
}

-(void)receiveBT:(NSString *)msg
{
    //TODO: do something with bt msg
    NSLog(@"receiveBT: %@", msg);
    if ([msg rangeOfString:@"start_speech"].location != NSNotFound)
        [self startSpeechRecognition];
    else if ([msg rangeOfString:@"stop_speech"].location != NSNotFound)
        [self stopSpeechRecognition];
    else if ([msg rangeOfString:@"magnet"].location != NSNotFound)
    {
        [self showMagnet];
    }
    else if ([msg rangeOfString:@"motion"].location != NSNotFound)
    {
        [self showMotion];
    }
    else if ([msg rangeOfString:@"hand:"].location != NSNotFound)
    {
        [self parseHand:msg];
    }
}

-(void)sendIP:(NSString *)msg
{
    
}

-(void)receiveIP:(NSString *)msg
{
    
}

-(void)speak:(NSString *)msg
{
    NSLog(@"speak: %@", msg);
    AVSpeechUtterance* utterance = [[AVSpeechUtterance alloc] initWithString:msg];
    utterance.rate = 0.30;
    [self.speechSyn speakUtterance:utterance];
}

-(void)startSpeechRecognition
{
    NSLog(@"startSpeechRecognition");
    if (!recognizingSpeech)
    {
        recognizingSpeech = YES;
        [self.speechToTextObj beginRecording];
    }
}

- (void)showSineWaveView:(SineWaveViewController *)view
{
    //    [fakeTextField setInputView:view.view];
    //    [fakeTextField becomeFirstResponder];
}
- (void)dismissSineWaveView:(SineWaveViewController *)view cancelled:(BOOL)wasCancelled
{
    //     [fakeTextField resignFirstResponder];
}

-(void)stopSpeechRecognition
{
    NSLog(@"stopSpeechRecognition");
    if (recognizingSpeech)
    {
        recognizingSpeech = NO;
        [self.speechToTextObj stopRecording:YES];
    }
}

- (BOOL)didReceiveVoiceResponse:(NSData *)data
{
    recognizingSpeech = NO;
    
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange range = [responseString rangeOfString:@"{\"result\":[]}"];
    if (range.location == 0)
        responseString = [responseString substringFromIndex:range.length];
    NSLog(@"responseString: %@",responseString);
    
    @try
    {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        
        if (error)
            [NSException raise:@"error" format:@"error"];
        
        NSArray* result = [json objectForKey:@"result"];
        if (!result || result.count == 0)
            [NSException raise:@"error" format:@"error"];
        
        NSDictionary* result0 = [result objectAtIndex:0];
        NSArray* alternative = [result0 objectForKey:@"alternative"];
        if (!alternative || alternative.count == 0)
            [NSException raise:@"error" format:@"error"];

        NSDictionary* alternative0 = [alternative objectAtIndex:0];
        NSString* transcript = [alternative0 objectForKey:@"transcript"];
        
        if (!transcript)
            [NSException raise:@"error" format:@"error"];

        [self processSpeech:transcript];
    }
    @catch (NSException *exception)
    {
        [self speak:@"Error processing speech."];
    }
    
    return YES;
}

-(void)processSpeech:(NSString *) speech
{
    //TODO: do something with speech
    NSLog(@"recognized speech: %@", speech);
    if ([speech rangeOfString:@"activate night vision"].location != NSNotFound)
    {
        [self showNightVision];
    }
    else if ([speech rangeOfString:@"night vision off"].location != NSNotFound)
    {
        [self hideNightVision];
    }
    else if ([speech rangeOfString:@"jarvis"].location != NSNotFound)
    {
        [self speak:@"i am siri, and you are not iron man."];
    }
    else if ([speech rangeOfString:@"tell me a joke"].location != NSNotFound)
    {
        [self speak:@"you look ridiculous."];
    }
}





-(void)recognizeImage
{
    // These code snippets use an open-source library. http://unirest.io/objective-c
//    NSURL *urlimage_request = [NSURL URLWithString:@"http://www.imagemme.com/wp-content/uploads/2011/12/bigcoke.jpg"];
//    NSURL *urlimage_request = [NSURL URLWithString:@"http://192.168.43.200:88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=super&pwd=hero"];
    
    NSString *stringURL = @"http://192.168.43.200:88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=super&pwd=hero";
    NSURL  *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if ( !urlData )
        return;
    
    UIImage * image = [UIImage imageWithData:urlData];

    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"filename3.jpg"];

    [UIImageJPEGRepresentation(image, 0.8) writeToFile:filePath atomically:NO];
    
    
//    [urlData writeToFile:filePath atomically:NO];

    NSURL *urlimage_request = [NSURL URLWithString:filePath];

    
    NSDictionary *headers = @{@"X-Mashape-Key": @"WikhDMvOkqmshzVFrBackB3hSdD7p1JjFJVjsnFqGXiSCttFiE"};
    NSDictionary *parameters = @{@"focus[x]": @"480", @"focus[y]": @"640", @"image_request[altitude]": @"27.912109375", @"image_request[image]": urlimage_request, @"image_request[language]": @"en", @"image_request[latitude]": @"35.8714220766008", @"image_request[locale]": @"en_US", @"image_request[longitude]": @"14.3583203002251"/*, @"image_request[remote_image_url]": @"http://www.imagemme.com/wp-content/uploads/2011/12/bigcoke.jpg"*/};
    UNIUrlConnection *asyncConnection = [[UNIRest post:^(UNISimpleRequest *request) {
        [request setUrl:@"https://camfind.p.mashape.com/image_requests"];
        [request setHeaders:headers];
        [request setParameters:parameters];
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
        NSInteger code = response.code;
        NSDictionary *responseHeaders = response.headers;
        UNIJsonNode *body = response.body;
        NSData *rawBody = response.rawBody;
        NSLog(@"image response: %@", [NSString stringWithUTF8String:rawBody.bytes]);
        
        [self checkImageResult:[body.object objectForKey:@"token"]];
    }];
}

-(void)checkImageResult:(NSString *)token
{
    NSDictionary *headers = @{@"X-Mashape-Key": @"WikhDMvOkqmshzVFrBackB3hSdD7p1JjFJVjsnFqGXiSCttFiE"};
    UNIUrlConnection *asyncConnection = [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:[NSString stringWithFormat:@"https://camfind.p.mashape.com/image_responses/%@", token]];
        [request setHeaders:headers];
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
        NSInteger code = response.code;
        NSDictionary *responseHeaders = response.headers;
        UNIJsonNode *body = response.body;
        NSData *rawBody = response.rawBody;
        
        if ([[body.object objectForKey:@"status"] isEqualToString:@"not completed"])
            [self checkImageResult:token];
        else if ([[body.object objectForKey:@"status"] isEqualToString:@"completed"])
            NSLog(@"image results: %@", [body.object objectForKey:@"name"]);
        else
            NSLog(@"error");
    }];
}


-(void)showNightVision {
    NSLog(@"show night vision");
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"nightvision" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:nil];
    self.webView.alpha = 1;
}

-(void)hideNightVision {
    NSLog(@"hide night vision");
    [self.webView loadHTMLString:[NSString string] baseURL:nil];
    self.webView.alpha = 0;
}

-(void)showMagnet {
    self.magnet.alpha = 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.magnet.alpha = 0;
    });
}

-(void)showMotion {
    self.motion.alpha = 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.motion.alpha = 0;
    });
}

-(void)parseHand:(NSString*)msg {
    NSArray *comps = [[msg substringFromIndex:5] componentsSeparatedByString:@","];
    if (comps.count != 3)
        return;
    
    int thumbPos = [[comps objectAtIndex:0] intValue];
    int pointerPos = [[comps objectAtIndex:1] intValue];
    int pinkyPos = [[comps objectAtIndex:2] intValue];
    
    if ((thumbPos == POS_OPEN) && (pointerPos == POS_OPEN) && (pinkyPos == POS_OPEN)) {
//        [self speak:@"]
        self.lights.alpha = 0;
        self.laser.alpha = 0;
        self.boosters.alpha = 0;
    } else if ((thumbPos == POS_CLOSE) && (pointerPos == POS_CLOSE) && (pinkyPos == POS_CLOSE)) {
        [self speak:@"it's a bird. no it's a plane. no it's a big fart."];
        self.lights.alpha = 0;
        self.laser.alpha = 0;
        self.boosters.alpha = 1;
    } else if ((thumbPos == POS_MIDDLE) && (pointerPos == POS_MIDDLE) && (pinkyPos == POS_MIDDLE)) {
        [self speak:@"let there be light."];
        self.lights.alpha = 1;
        self.laser.alpha = 0;
        self.boosters.alpha = 0;
    } else if ((thumbPos == POS_CLOSE) && (pointerPos == POS_OPEN) && (pinkyPos == POS_CLOSE)) {
        [self speak:@"target acquired."];
        self.lights.alpha = 0;
        self.laser.alpha = 1;
        self.boosters.alpha = 0;
    } else if ((thumbPos == POS_OPEN) && (pointerPos == POS_OPEN) && (pinkyPos == POS_CLOSE)) {
        [self speak:@"pew pew pew pew."];
        self.lights.alpha = 0;
        self.laser.alpha = 0;
        self.boosters.alpha = 0;
    }
}

@end
