//
//  klcDescriptorViewController.m
//  CulturalGuide
//
//  Created by Kliment Lambevski on 6/15/14.
//  Copyright (c) 2014 Kliment Lambevski. All rights reserved.
//

#import "klcDescriptorViewController.h"
#import "klcAppDelegate.h"

@interface klcDescriptorViewController ()

@end

@implementation klcDescriptorViewController
@synthesize  popoverController;

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
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *fileName = @"descriptors.json";
    NSString *filePath = [directory stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:NULL];
    [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:@"descriptors.yml"] error:NULL];
    // Do any additional setup after loading the view.
}

- (IBAction)AddImageDescriptor:(UIButton *)sender {
    // When the user taps on screen we present the image picker dialog to select the input image
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    
}


#pragma mark - UIImagePickerControllerDelegate implementation

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissModalViewControllerAnimated:YES];
    
    klcAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSError *error;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *fileName = @"descriptors.json";
    NSString *filePath = [directory stringByAppendingPathComponent:fileName];
    NSData *data=[NSData dataWithContentsOfFile:filePath];
    NSArray *niza=[[NSArray alloc] init];
    if(data==nil){
        
    }
    else{
       niza = [NSJSONSerialization
                         JSONObjectWithData:data //1
                         
                         options:kNilOptions
                         error:&error];

    }
          //NSArray *niza=[json objectForKey:@"descriptors"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSString *name=[[self ImageName] text];
    NSString *info=[[self ImageInfo] text];
    [dict setValue:name forKey:@"name"];
    [dict setValue:info forKey:@"info"];
    NSMutableArray *niza1=[niza mutableCopy];
    
    [niza1 addObject:dict];
    NSData *jsondata=[NSJSONSerialization dataWithJSONObject:niza1 options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    [jsonString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    int result=[[appDelegate imageProcessor] saveDescriptor:image secondParametar:name pathforFile:[directory stringByAppendingPathComponent:@"descriptors.yml"] isFirstItem:[niza count]];
    printf("%d",result);
    NSLog(@"%@",[directory stringByAppendingPathComponent:@"descriptors.yml"]);
   
    NSData *data1=[NSData dataWithContentsOfFile:filePath];
    NSArray *niza2 = [NSJSONSerialization
                     JSONObjectWithData:data1 //1
                     
                     options:kNilOptions
                     error:&error];
    NSLog(@"%@",niza2);
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

- (IBAction)syncWithServer:(id)sender {
    printf("------- start upload ------\n");
    NSError *error;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *fileName = @"descriptors.json";
    NSString *filePath = [directory stringByAppendingPathComponent:fileName];
    NSData *data=[NSData dataWithContentsOfFile:filePath];

    NSString *urlString = @"http://najdismestuvanje.x10.mx/culturalguide/upload.php";
    NSString *filename = @"filename";
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:data]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", returnString);
    printf("------- end upload ------\n");
    [self uploadDescriptors];
}
-(void)uploadDescriptors
{
    printf("------- start upload ------\n");
    NSError *error;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *fileName = @"descriptors.yml";
    NSString *filePath = [directory stringByAppendingPathComponent:fileName];
    NSData *data=[NSData dataWithContentsOfFile:filePath];
    
    NSString *urlString = @"http://najdismestuvanje.x10.mx/culturalguide/upload.php";
    NSString *filename = @"filename";
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:data]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", returnString);
    printf("------- end upload ------\n");
}
@end
