//
//  klcDescriptorViewController.h
//  CulturalGuide
//
//  Created by Kliment Lambevski on 6/15/14.
//  Copyright (c) 2014 Kliment Lambevski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface klcDescriptorViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate>
{
    UIButton *mainButton;
    UIPopoverController *popoverController;
}
@property (weak, nonatomic) IBOutlet UITextView *ImageInfo;
@property (weak, nonatomic) IBOutlet UITextField *ImageName;
@property (nonatomic, retain) UIPopoverController *popoverController;
- (IBAction)syncWithServer:(id)sender;

@end
