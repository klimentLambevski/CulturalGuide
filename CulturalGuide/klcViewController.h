//
//  klcViewController.h
//  CulturalGuide
//
//  Created by Kliment Lambevski on 5/29/14.
//  Copyright (c) 2014 Kliment Lambevski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface klcViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate>
{
    UIButton *mainButton;
    UIPopoverController *popoverController;
    
    BOOL FrontCamera;
    BOOL haveImage;
}
@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (weak, nonatomic) IBOutlet UITextView *ImageInfo;
@property (strong, nonatomic) IBOutlet UIButton *mainButton;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (weak, nonatomic) IBOutlet UIImageView *CameraScreen;
@property (weak, nonatomic) IBOutlet UIView *imagePreview;
@property (weak, nonatomic) IBOutlet UIButton *switchToCameraButton;

- (IBAction)snapImage:(id)sender;

- (IBAction)buttonDidTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
- (IBAction)switchToCamera:(id)sender;


@end


