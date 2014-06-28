//
//  klcViewController.m
//  CulturalGuide
//
//  Created by Kliment Lambevski on 5/29/14.
//  Copyright (c) 2014 Kliment Lambevski. All rights reserved.
//

#import "klcViewController.h"

#import "klcAppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface klcViewController ()

@end

@implementation klcViewController
@synthesize mainButton, popoverController;

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    //[[self ImageInfo] backgroundColor:[UIColor colorWithRed:((float)37 / 255.0f) green:((float)37 / 255.0f) blue:((float)37 / 255.0f) alpha:0.6]];
    self.ImageInfo.backgroundColor=[UIColor colorWithRed:((float)37 / 255.0f) green:((float)37 / 255.0f) blue:((float)37 / 255.0f) alpha:0.6];
    self.ImageInfo.textColor=[UIColor whiteColor];
   /*
    self.imagePreview.hidden=YES;
    self.CameraScreen.hidden=YES;
    self.ImageInfo.hidden=YES;
    [self.loadingView startAnimating];
    NSString *stringURL = @"http://najdismestuvanje.x10.mx/culturalguide/descriptors.yml";
    NSURL  *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if ( urlData )
    {
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"descriptors.yml"];
        [urlData writeToFile:filePath atomically:YES];
    }
    stringURL = @"http://najdismestuvanje.x10.mx/culturalguide/descriptors.yml";
    url = [NSURL URLWithString:stringURL];
    urlData = [NSData dataWithContentsOfURL:url];
    if ( urlData )
    {
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"descriptors.json"];
        [urlData writeToFile:filePath atomically:YES];
    }
    [self.loadingView stopAnimating];
   */
     }
- (void)viewDidUnload
{
    [self setMainButton:nil];
    [super viewDidUnload];
   
}
- (void)viewDidAppear:(BOOL)animated {
    [self initializeCamera];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

#pragma mark - Selecting image from photo album
-(void) getInfo:(id)sender{
    printf("Kliknata slikata");
}
- (IBAction)getInfoForImage:(UIButton *)sender {
    // When the user taps on screen we present the image picker dialog to select the input image
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        self.popoverController.delegate = self;
        [self.popoverController presentPopoverFromRect:mainButton.bounds inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self presentModalViewController:picker animated:YES];
    }

}
- (void) buttonDidTapped:(id)sender
{
    // When the user taps on screen we present the image picker dialog to select the input image
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        self.popoverController.delegate = self;
        [self.popoverController presentPopoverFromRect:mainButton.bounds inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self presentModalViewController:picker animated:YES];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return true;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    
}


#pragma mark - UIImagePickerControllerDelegate implementation

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissModalViewControllerAnimated:YES];
    
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"descriptors" ofType:@"json"];
    NSData *data=[NSData dataWithContentsOfFile:filePath];
    NSArray *niza = [NSJSONSerialization
                          JSONObjectWithData:data //1
                          
                          options:kNilOptions
                          error:&error];
    
  
    
    
    klcAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    int result=[appDelegate.imageProcessor searchImageInfo:image pathForFile:@"descriptors.yml" arrayOfDescriptors:niza];
    [[self CameraScreen] setImage:image];
    if(result>-1)
        self.ImageInfo.text=[[niza objectAtIndex:result] objectForKey:@"info"];
    else self.ImageInfo.text=@"Info not found";
   //int resultRobust=[appDelegate.imageProcessor robustMatch:[UIImage imageNamed:@"monalisa.jpg"] sceneImage:image];
    //printf("robust result:%d\n",resultRobust);
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}
// Create and configure a capture session and start it running


//AVCaptureSession to show live video feed in view
- (void) initializeCamera {
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPreset640x480;
	
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
	captureVideoPreviewLayer.frame = self.imagePreview.bounds;
	[self.imagePreview.layer addSublayer:captureVideoPreviewLayer];
	
    UIView *view = [self imagePreview];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
       // NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    if (!FrontCamera) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        [session addInput:input];
    }
    
    if (FrontCamera) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        [session addInput:input];
    }
	
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:self.stillImageOutput];
    
	[session startRunning];
}











- (IBAction)snapImage:(id)sender {
    
    if (!haveImage) {
        self.CameraScreen.image = nil; //remove old image from view
        self.CameraScreen.hidden = NO; //show the captured image view
        self.imagePreview.hidden = YES; //hide the live video feed
        self.ImageInfo.hidden=YES;
        self.loadingView.hidden=NO;
        [self.loadingView startAnimating];
        [self capImage];
    }
    else {
        //self.CameraScreen.hidden = YES;
        self.imagePreview.hidden = NO;
        haveImage = NO;
    }
}

- (void) capImage { //method to capture image from AVCaptureSession video feed
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", self.stillImageOutput);
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            [self processImage:[UIImage imageWithData:imageData]];
        }
    }];
}


- (void) processImage:(UIImage *)image { //process captured image, crop, resize and rotate
    haveImage = YES;
    printf("processed image\n");
    [[self CameraScreen] setImage:image];
    NSError *error;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *fileName = @"descriptors.json";
    NSString *filePath = [directory stringByAppendingPathComponent:fileName];
    NSData *data=[NSData dataWithContentsOfFile:filePath];
    NSArray *niza = [NSJSONSerialization
                     JSONObjectWithData:data //1
                     
                     options:kNilOptions
                     error:&error];
    
    
    
    printf("Start search for info");
    NSLog(@"niza:%@",niza);
    [directory stringByAppendingPathComponent:@"descriptors.yml"];
    klcAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    int result=[appDelegate.imageProcessor searchImageInfo:image pathForFile:[directory stringByAppendingPathComponent:@"descriptors.yml"] arrayOfDescriptors:niza];
    
    printf("info result: %d\n",result);
    
    if(result>-1)
        self.ImageInfo.text=[[niza objectAtIndex:result] objectForKey:@"info"];
    else self.ImageInfo.text=@"Info not found";
    self.loadingView.stopAnimating;
    self.loadingView.hidden=YES;
    CGRect frame;
    frame=self.ImageInfo.frame;
    frame.size.height=[self.ImageInfo contentSize].height;
    self.ImageInfo.frame=frame;
    self.ImageInfo.hidden=NO;
    //adjust image orientation based on device orientation
    
    
    //self.imagePreview.hidden=NO;
   printf("End search for info");
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)switchToCamera:(id)sender {
    self.imagePreview.hidden=NO;
}
@end

