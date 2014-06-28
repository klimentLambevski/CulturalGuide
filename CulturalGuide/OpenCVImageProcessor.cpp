/*
 * This file is a part of sample project which demonstrates how to use OpenCV
 * library with the XCode to write the iOS-based applications.
 * 
 * Written by Eugene Khvedchenya.
 * Distributed via GPL license. 
 * Support site: http://computer-vision-talks.com
 */

#include "OpenCVImageProcessor.h"
#include <opencv2/nonfree/features2d.hpp>
#include <opencv2/features2d/features2d.hpp>
#include "RobustMatcher.h"

// A helper macro

using namespace cv;

Mat OpenCVImageProcessor::drawDetectedObject(Mat srcImage,Mat sceneImage){
    Mat img_object = srcImage;
    Mat img_scene =sceneImage;
    
    //-- Step 1: Detect the keypoints using SURF Detector
    int minHessian = 400;
    
    SurfFeatureDetector detector( minHessian );
    
    std::vector<KeyPoint> keypoints_object, keypoints_scene;
    
    detector.detect( img_object, keypoints_object );
    detector.detect( img_scene, keypoints_scene );

    //-- Step 2: Calculate descriptors (feature vectors)
    SurfDescriptorExtractor extractor;
    
    Mat descriptors_object, descriptors_scene;
    
    extractor.compute( img_object, keypoints_object, descriptors_object );
    extractor.compute( img_scene, keypoints_scene, descriptors_scene );

    //-- Step 3: Matching descriptor vectors using FLANN matcher
    FlannBasedMatcher matcher;
    std::vector< DMatch > matches;
    matcher.match( descriptors_object, descriptors_scene, matches );
    
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors_object.rows; i++ )
    { double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    printf("-- Max dist : %f \n", max_dist );
    printf("-- Min dist : %f \n", min_dist );
    
    //-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
    std::vector< DMatch > good_matches;
    
    for( int i = 0; i < descriptors_object.rows; i++ )
    { if( matches[i].distance < 3*min_dist )
    { good_matches.push_back( matches[i]); }
    }
    
    Mat img_matches;
    drawMatches( img_object, keypoints_object, img_scene, keypoints_scene,
                good_matches, img_matches, Scalar::all(-1), Scalar::all(-1),
                std::vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
    
    //-- Localize the object
    std::vector<Point2f> obj;
    std::vector<Point2f> scene;
    
    for( int i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        obj.push_back( keypoints_object[ good_matches[i].queryIdx ].pt );
        scene.push_back( keypoints_scene[ good_matches[i].trainIdx ].pt );
    }
    
    Mat H = findHomography( obj, scene, FM_RANSAC );
    
    //-- Get the corners from the image_1 ( the object to be "detected" )
    std::vector<Point2f> obj_corners(4);
    obj_corners[0] = cvPoint(0,0); obj_corners[1] = cvPoint( img_object.cols, 0 );
    obj_corners[2] = cvPoint( img_object.cols, img_object.rows ); obj_corners[3] = cvPoint( 0, img_object.rows );
    std::vector<Point2f> scene_corners(4);
    
    perspectiveTransform( obj_corners, scene_corners, H);
    //-- Draw lines between the corners (the mapped object in the scene - image_2 )
    line( img_matches, scene_corners[0] + Point2f( img_object.cols, 0), scene_corners[1] + Point2f( img_object.cols, 0), Scalar(0, 255, 0), 4 );
    line( img_matches, scene_corners[1] + Point2f( img_object.cols, 0), scene_corners[2] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
    line( img_matches, scene_corners[2] + Point2f( img_object.cols, 0), scene_corners[3] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
    line( img_matches, scene_corners[3] + Point2f( img_object.cols, 0), scene_corners[0] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );


    return sceneImage;
}

int OpenCVImageProcessor::saveImageDescriptor(Mat srcImage,std::string *name,std::string *path,int firstItem){
    Size size(320,220);
   
    int minHessian = 400;
    Mat src_image,object_descriptor,resizedImage;
    resize(srcImage, resizedImage, size);
    cvtColor( resizedImage,src_image, cv::COLOR_BGR2GRAY);
    SurfFeatureDetector detector( minHessian );
    std::vector<KeyPoint> keypoints_object, keypoints_scene;
    
    detector.detect( src_image, keypoints_object );
    SurfDescriptorExtractor extractor;
    extractor.compute( src_image, keypoints_object, object_descriptor );
    if(firstItem){
        FileStorage fs(*path,FileStorage::APPEND);
        write(fs,*name,object_descriptor);
        name->append("_keypoints");
        write(fs,*name,keypoints_object);
         fs.release();
    }
    else {
        FileStorage fs(*path,FileStorage::WRITE);
        write(fs,*name,object_descriptor);
        name->append("_keypoints");
        write(fs,*name,keypoints_object);
         fs.release();
    }
    
   
    return 1;
}
int OpenCVImageProcessor::getImageInfo(Mat srcImage, std::string *path, std::vector<std::string> desc){
    
    FileStorage fs(*path,FileStorage::READ);
    int minHessian = 400;
    Mat src_image,object_descriptor,scene_descriptor,resizedImage;
    Size size(320,220);
    resize(srcImage, resizedImage, size);
    cvtColor( resizedImage,src_image, cv::COLOR_BGR2GRAY);
    SurfFeatureDetector detector( minHessian );
    std::vector<KeyPoint> keypoints_object, keypoints_scene;
    
    detector.detect( src_image, keypoints_object );
    SurfDescriptorExtractor extractor;
    extractor.compute( src_image, keypoints_object, object_descriptor );
    std::vector<cv::DMatch> matches;
    printf("se desi %d; %d %d\n",src_image.cols,src_image.rows,desc.size());
    for(int i=0;i<desc.size();i++){
        FileNode descriptor=fs[desc[i]];
        std::string keypoints=desc[i];
        keypoints.append("_keypoints");
        FileNode keypointsfn=fs[keypoints];
        read(descriptor, scene_descriptor);
        read(keypointsfn , keypoints_scene);
        RobustMatcher matcher;
        int result=matcher.matchRnasac(matches, keypoints_object, keypoints_scene, object_descriptor, scene_descriptor);
        if(result>0) return i;
    }
    return -1;
}


