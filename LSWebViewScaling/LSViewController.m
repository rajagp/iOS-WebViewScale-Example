/*
*  LSViewController.m
*  LSWebViewScaling
*
*  Created by Priya Rajagopal on 8/15/13.
*  Copyright (c) 2013 Lunaria Software, LLC. All rights reserved.
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice,
*    this list of conditions and the following disclaimer in the documentation
*    and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
* BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
* OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "LSViewController.h"

#define DEFAULTWEBVIEWFONTSIZE 14
#define SAMPLE_HTML @"sample"
#pragma mark - private interface
@interface LSViewController ()

@property (nonatomic,assign)NSInteger stepperScale;
@end

@implementation LSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.stepperScale = DEFAULTWEBVIEWFONTSIZE;
    self.myStepper.minimumValue = 5.0;
    self.myStepper.value = 15.0;
    self.myStepper.maximumValue = 24.0;
    self.myStepper.stepValue = 5.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadWebViewContent];
}

#pragma mark - Loading Views
-(void)loadWebViewContent
{
    NSString* fileName = [NSBundle pathForResource:SAMPLE_HTML ofType:@"html" inDirectory:[NSBundle mainBundle].bundlePath];
    NSError* error;
    NSStringEncoding usedEncoding = NSUTF8StringEncoding;
    NSString* webViewContent = [NSString stringWithContentsOfFile:fileName usedEncoding:&usedEncoding error:&error];
    NSString *resourcePath = [[[[NSBundle mainBundle] resourcePath]
                               stringByReplacingOccurrencesOfString:@"/" withString:@"//"]
                              stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    [self.myWebView loadHTMLString:webViewContent baseURL:[NSURL URLWithString:  [NSString stringWithFormat:@"file:/%@//", resourcePath]]];
    self.myWebView.delegate = self;
    
}

#pragma mark - UIWebviewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!webView.isLoading)
    {
        [self scaleWebview];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Server Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}


#pragma mark - UIEvent handlers
- (IBAction)onStepperTapped:(id)sender {
    self.stepperScale = self.myStepper.value;
    [self performSelector:@selector(scaleWebview) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
}

#pragma mark - helpers
-(void)scaleWebview
{
    // Adjust the text size (specified as a percent. 100 is default normal)
    NSString *jsForTextSize = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", self.stepperScale*100/DEFAULTWEBVIEWFONTSIZE];
    [self.myWebView stringByEvaluatingJavaScriptFromString:jsForTextSize];
    
    // First reset the height of webview frame. Otherwise the sizeThatFits will return the current size
    // if it can fit the new text - works while scaling up but not useful when scaling down.
    CGRect adjustedFrame = self.myWebView.frame;
    adjustedFrame.size.height = 1;
    self.myWebView.frame = adjustedFrame;
    
    CGSize frameSize = [self.myWebView sizeThatFits:CGSizeZero];
    adjustedFrame.size.height = frameSize.height ;
    self.myWebView.frame = adjustedFrame;
   
    /// Adjust scroll view content size (Make sure your factor in the y-offset at which the webview begins)
    CGSize scrollViewSize = self.myScrollView.contentSize;
    scrollViewSize.height = adjustedFrame.size.height + self.myWebView.frame.origin.y ;
    self.myScrollView.contentSize = scrollViewSize;
    
    
}
@end
