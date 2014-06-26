//
//  RobustMatcher.h
//  CulturalGuide
//
//  Created by Kliment Lambevski on 6/19/14.
//  Copyright (c) 2014 Kliment Lambevski. All rights reserved.
//

#ifndef __CulturalGuide__RobustMatcher__
#define __CulturalGuide__RobustMatcher__

#include <stdio.h>
#include <iostream>
#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include "opencv2/nonfree/nonfree.hpp"
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/legacy/legacy.hpp>

class RobustMatcher {
private:
    // pointer to the feature point detector object
    // cv::Ptr<cv::FeatureDetector> detector;
    // pointer to the feature descriptor extractor object
    cv::Ptr<cv::DescriptorExtractor> extractor;
    float ratio; // max ratio between 1st and 2nd NN
    bool refineF; // if true will refine the F matrix
    double distance; // min distance to epipolar
    double confidence; // confidence level (probability)
public:
    RobustMatcher() : ratio(0.65f), refineF(true),
    confidence(0.99), distance(3.0) {
        // SURF is the default feature
        extractor= cv::DescriptorExtractor::create("SURF");
        
        //detector= cv::FeatureDetector::create("SURF");
        
    }
     
    // Set the feature detector
    void setFeatureDetector(cv::Ptr<cv::FeatureDetector>& detect) {
        //detector= detect;
    }
    // Set the descriptor extractor
    void setDescriptorExtractor(cv::Ptr<cv::DescriptorExtractor>& desc) {
        //extractor= desc;
    }
    // Match feature points using symmetry test and RANSAC
    // returns fundemental matrix
    int match(cv::Mat& image1,
              cv::Mat& image2, // input images
              // output matches and keypoints
              std::vector<cv::DMatch>& matches,
              std::vector<cv::KeyPoint>& keypoints1,
              std::vector<cv::KeyPoint>& keypoints2) {
        cv::SurfFeatureDetector detector(800);
        // 1a. Detection of the SURF features
        detector.detect(image1,keypoints1);
        detector.detect(image2,keypoints2);
        // 1b. Extraction of the SURF descriptors
        cv::Mat descriptors1, descriptors2;
        extractor->compute(image1,keypoints1,descriptors1);
        extractor->compute(image2,keypoints2,descriptors2);
        // 2. Match the two image descriptors
        // Construction of the matcher
        cv::BruteForceMatcher<cv::L2<float>> matcher;
        
        //cv::BruteForceMatcher<cv::L2<float>> matcher;
        // from image 1 to image 2
        // based on k nearest neighbours (with k=2)
        std::vector<std::vector<cv::DMatch>> matches1;
        matcher.knnMatch(descriptors1,descriptors2,
                         matches1, // vector of matches (up to 2 per entry)
                         2);        // return 2 nearest neighbours
        // from image 2 to image 1
        // based on k nearest neighbours (with k=2)
        std::vector<std::vector<cv::DMatch>> matches2;
        matcher.knnMatch(descriptors2,descriptors1,
                         matches2, // vector of matches (up to 2 per entry)
                         2);        // return 2 nearest neighbours
        // 3. Remove matches for which NN ratio is
        // > than threshold
        // clean image 1 -> image 2 matches
        int removed= ratioTest(matches1);
        std::cout<<"removed"<<matches1.size()<<"\n";
        std::cout<<"syn matches1 "<<matches1.size()<<"\n";
        // clean image 2 -> image 1 matches
        removed= ratioTest(matches2);
        std::cout<<"removed"<<matches2.size()<<"\n";
        // 4. Remove non-symmetrical matches
        std::vector<cv::DMatch> symMatches;
        std::cout<<"syn matches2 "<<matches2.size()<<"\n";
        symmetryTest(matches1,matches2,symMatches);
        std::cout<<"syn matches"<<symMatches.size()<<"\n";
        // 5. Validate matches using RANSAC
        return ransacTest(symMatches,keypoints1, keypoints2, matches);
        // return the found fundemental matrix
        
    }
    
    int matchRnasac(
                    // input keypoints and keypoints
                    std::vector<cv::DMatch>& matches,
                    std::vector<cv::KeyPoint>& keypoints1,
                    std::vector<cv::KeyPoint>& keypoints2,
                    cv::Mat descriptors1,
                    cv::Mat descriptors2){
        cv::SurfFeatureDetector detector(800);
        cv::BruteForceMatcher<cv::L2<float>> matcher;
        
        //cv::BruteForceMatcher<cv::L2<float>> matcher;
        // from image 1 to image 2
        // based on k nearest neighbours (with k=2)
        std::vector<std::vector<cv::DMatch>> matches1;
        matcher.knnMatch(descriptors1,descriptors2,
                         matches1, // vector of matches (up to 2 per entry)
                         2);        // return 2 nearest neighbours
        // from image 2 to image 1
        // based on k nearest neighbours (with k=2)
        std::vector<std::vector<cv::DMatch>> matches2;
        matcher.knnMatch(descriptors2,descriptors1,
                         matches2, // vector of matches (up to 2 per entry)
                         2);        // return 2 nearest neighbours
        // 3. Remove matches for which NN ratio is
        // > than threshold
        // clean image 1 -> image 2 matches
        int removed= ratioTest(matches1);
        
        removed= ratioTest(matches2);
        
        std::vector<cv::DMatch> symMatches;
        //Symetry filter for matches
        symmetryTest(matches1,matches2,symMatches);
        
        // 5. Validate matches using RANSAC
        return ransacTest(symMatches,keypoints1, keypoints2, matches);
        // return the found fundemental matrix
        
        return 1;
    }
    
    int ratioTest(std::vector<std::vector<cv::DMatch>> &matches) {
        int removed=0;
        for(std::vector<std::vector<cv::DMatch>>::iterator matchIterator= matches.begin();matchIterator!=matches.end();++matchIterator){
            // if 2 NN has been identified
            if (matchIterator->size() > 1) {
                // check distance ratio
                if ((*matchIterator)[0].distance/
                    (*matchIterator)[1].distance > ratio) {
                    matchIterator->clear(); // remove match
                    removed++; }
            } else { // does not have 2 neighbours
                matchIterator->clear(); // remove match
                removed++;
            }
        }
        return removed;
    }
    // Insert symmetrical matches in symMatches vector
    void symmetryTest(
                      const std::vector<std::vector<cv::DMatch>>& matches1,
                      const std::vector<std::vector<cv::DMatch>>& matches2,
                      std::vector<cv::DMatch>& symMatches) {
        // for all matches image 1 -> image 2
        for (std::vector<std::vector<cv::DMatch>>::
             const_iterator matchIterator1= matches1.begin();
             matchIterator1!= matches1.end(); ++matchIterator1) {
            // ignore deleted matches
            if (matchIterator1->size() < 2)
                continue;
            // for all matches image 2 -> image 1
            for (std::vector<std::vector<cv::DMatch>>::
                 const_iterator matchIterator2= matches2.begin();
                 matchIterator2!= matches2.end();
                 ++matchIterator2) {
                // ignore deleted matches
                if (matchIterator2->size() < 2)
                    continue;
                // Match symmetry test
                if ((*matchIterator1)[0].queryIdx ==
                    (*matchIterator2)[0].trainIdx  &&
                    (*matchIterator2)[0].queryIdx ==
                    (*matchIterator1)[0].trainIdx) {
                    // add symmetrical match
                    symMatches.push_back(cv::DMatch((*matchIterator1)[0].queryIdx,
                                                    (*matchIterator1)[0].trainIdx,
                                                    (*matchIterator1)[0].distance));
                    break; // next match in image 1 -> image 2
                }
            }
        }
    }
    int ransacTest(
                   const std::vector<cv::DMatch>& matches,
                   const std::vector<cv::KeyPoint>& keypoints1,
                   const std::vector<cv::KeyPoint>& keypoints2,
                   std::vector<cv::DMatch>& outMatches) {
        // Convert keypoints into Point2f
        std::vector<cv::Point2f> points1, points2;
        for (std::vector<cv::DMatch>::
             const_iterator it= matches.begin();
             it!= matches.end(); ++it) {
            // Get the position of left keypoints
            float x= keypoints1[it->queryIdx].pt.x;
            float y= keypoints1[it->queryIdx].pt.y;
            points1.push_back(cv::Point2f(x,y));
            // Get the position of right keypoints
            x= keypoints2[it->trainIdx].pt.x;
            y= keypoints2[it->trainIdx].pt.y;
            points2.push_back(cv::Point2f(x,y));
        }
        // Compute F matrix using RANSAC
        std::vector<uchar> inliers(points1.size(),0);
        cv::Mat fundemental= cv::findFundamentalMat(
                                                    cv::Mat(points1),cv::Mat(points2), // matching points
                                                    inliers,      // match status (inlier or outlier)
                                                    CV_FM_RANSAC, // RANSAC method
                                                    distance,     // distance to epipolar line
                                                    confidence);  // confidence probability
        // extract the surviving (inliers) matches
        // extract the surviving (inliers) matches
        std::vector<uchar>::const_iterator
        itIn= inliers.begin();
        std::vector<cv::DMatch>::const_iterator
        itM= matches.begin();
        // for all matches
        for ( ;itIn!= inliers.end(); ++itIn, ++itM){
            if(*itIn){
                outMatches.push_back(*itM);
            }
        }
        std::cout<<"out matches"<<outMatches.size()<<"\n";
        return outMatches.size();
    }
};
#endif /* defined(__CulturalGuide__RobustMatcher__) */
