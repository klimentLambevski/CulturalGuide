/*
 * This file is a part of sample project which demonstrates how to use OpenCV
 * library with the XCode to write the iOS-based applications.
 * 
 * Written by Eugene Khvedchenya.
 * Distributed via GPL license. 
 * Support site: http://computer-vision-talks.com
 */

#ifndef iOSplusOpenCV_OpenCVImageProcessor_h
#define iOSplusOpenCV_OpenCVImageProcessor_h

#include <opencv2/opencv.hpp>


// Note - at this points you can't include OpenCV headers since it will cause "Statement expressions ..." error.
// Just a hint how to do forward declarations of OpenCV types if you need them.
struct _IplImage;
typedef _IplImage IplImage;

class OpenCVImageProcessor
{
public:
  
  /**
   * Performs Canny filter on the source image and puts the processed image to the dst.
   * Preconditions: src and dst has equal dimensions.
   */
  
 
  cv::Mat drawDetectedObject(cv::Mat srcImage,cv::Mat sceneImage);
    int saveImageDescriptor(cv::Mat srcImage,std::string *name,std::string *path);
    int getImageInfo(cv::Mat srcImage, std::string *path, std::vector<std::string> desc);
private:

 
};

#endif
