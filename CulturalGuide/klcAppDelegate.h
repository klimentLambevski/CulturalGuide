//
//  klcAppDelegate.h
//  CulturalGuide
//
//  Created by Kliment Lambevski on 5/29/14.
//  Copyright (c) 2014 Kliment Lambevski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageProcessingProtocol.h"
@interface klcAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<ImageProcessingProtocol> imageProcessor;
@end
