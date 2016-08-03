/********* DocumentPreview.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DocumentViewerViewController.h"
#import "DocumentWebviewViewController.h"

@interface DocumentPreview : CDVPlugin {
  // Member variables go here.
  NSString *localFile;
}

@property (retain, nonatomic) DocumentViewerViewController* previewViewController;

- (void)openDocument:(CDVInvokedUrlCommand*)command;
@end

@implementation DocumentPreview

- (void)openDocument:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;

    // Get Arguments
    NSString *filePath = [command.arguments objectAtIndex:0];
    NSString *fileMIMEType = [command.arguments objectAtIndex:1];
    NSNumber* previewDoc = [command.arguments objectAtIndex:2];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];

        if([fileURL isFileURL])
            NSLog(@"it's a file url");
        
        localFile = fileURL.path;

        if([fileMIMEType containsString:@"video"]){
            NSLog(@"Open Video with player");
            [self openVideoUrl:filePath andCommand:command];
            return;
        }
        
        if ([filePath hasPrefix:@"http://"] || [filePath hasPrefix:@"https://"])
        {
            DocumentWebviewViewController *docWebviewViewController = [[DocumentWebviewViewController alloc] init];
            [[super viewController] presentViewController:docWebviewViewController animated:YES completion:nil];
            [docWebviewViewController loadDocumentWithUrl:filePath];
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            // do something
            return;
        }
        
        //
      /*  NSFileManager *fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath: localFile]){
            NSDictionary *jsonObj = @{@"status" : @"9",
                                      @"message" : @"File does not exist"};
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsDictionary:jsonObj];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        } */

        if([previewDoc boolValue] == YES) {
            //Preview Docs
            CDVPluginResult* pluginResult = nil;
            BOOL pluginSuccess = NO;
            
            self.previewViewController = [[DocumentViewerViewController alloc] init];
            pluginSuccess = [self.previewViewController viewFile:filePath usingViewController:[super viewController]];
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:pluginSuccess];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
            
            
        } else {
            self.previewViewController = [[DocumentViewerViewController alloc] init];
            [self.previewViewController openFile:fileURL usingViewController:[super viewController]];
        }

    });

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(void) openVideoUrl:(NSString*) url andCommand:(CDVInvokedUrlCommand*) command
{
    CDVPluginResult* pluginResult = nil;
    NSURL *videoURL;
    
    videoURL = [NSURL URLWithString:url];
    
    NSLog(@"url %@", videoURL);
    MPMoviePlayerViewController *videoPlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [super.viewController presentMoviePlayerViewControllerAnimated:videoPlayerView];
    [videoPlayerView.moviePlayer play];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end
