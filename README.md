#Learning object scale from multiple view geometry
###### Ahmed AlMutawa, Austin Anderson, Rohit Raje, John Stechschulte, Wade Wu

###Project Goal
Robots navigating unknown environments must estimate the scale of the world around them. This can be done with active depth sensors, stereoscopic cameras, or fusion of data from multiple sensors. The goal of this project is to explore an alternative approach to learning environment scale by using a single camera and machine learning algorithms trained to estimate object scale from RGB images. At this stage, only learning depth from pre­segmented, labelled objects will be addressed. The identification and segmentation of objects from an image is left for future work.


###Implementation

Estimating distance to an object is a continuous prediction. The core estimator for this project is a linear regression that calculates weights for combining features extracted from the image data. The NYU dataset provides RGB-D images that have objects individually labelled and segmented. The dataset includes 894 different, labelled object classes. The full dataset is broken into a training set and a testing set for cross validation using a ¾, ¼ split. 

For a single object, the relevant training and testing images are extracted, and a preprocessing step is applied to separate individual objects of the specified type in each image. This is done by generating a binary mask of the labelled object indices and applying an erosion and a dilation filter. The erosion filter eliminates small objects and connections between objects. The dilation filter grows the mask uniformly to return to the original size. A connected component analysis is then run to isolate individual objects. These isolated objects are treated as separate data points for training, labelling, and testing. This step is especially important for objects that appear multiple times in a single image, like chairs.


###Results

As expected, the classifier works better for some object classes than others. For instance, the “monitor” classifier performs far better than the “wall” classifier. There are multiple reasons for this, such as variation within an object class (walls come in a wider range of sizes than monitors), and variation in an object’s setting (walls are more likely to be occluded, or only partially in the image frame, than monitors). In the target application, the robot would only use more reliable objects for scale determination, and could also include a measure of uncertainty in the result. 

Initially, the whole data set was processed with the full set of features. Object classes with an insufficient number of training examples were discarded. For each acceptable regression, statistics on the estimated weighting coefficients were calculated. These statistics included a p-test to assess the statistical significance of the different feature weights. In the first run using all 10 features, regressions were run on 115 object classes. Based on these results the performance of individual features were assessed.

###Conclusions

Across hundreds of object classes, the testing error varied by almost two orders of magnitude. Some classes of object have greater size variance, and factors such as occlusions and viewing angle can affect the result significantly, as well. This is to be expected, and is acceptable: in the target application, only the more reliable objects need be considered, and by aggregating information over many observations the effect of outliers is mitigated. 

As is often the case in the application of machine learning, this work uncovered as much insight about the training data and how it was collected as it did about the problem. For instance, the effectiveness of the y-coordinate in predicting depth was unexpected, but makes sense in retrospect considering the data was collected by a human carrying a camera at a fairly consistent height and angle to the ground. This, of course, limits the usefulness of the particular results obtained here: images captured looking down from a quadcopter or up from a small ground vehicle would have very high error in this regression. However, the overall method is still valid, and could be repeated with new training data that is representative of the desired application.

###Future Work

There are a variety of ways this work could be enhanced or extended. The goal application of scale determination would require also implementing object segmentation and recognition, likely through use of deep convolutional nets. Within the problem domain addressed here, improvements might be possible by augmenting the training data to make the regression more robust, and allowing parameters to be tuned for each object type and further determining how to tune them in a statistically rigorous and automatic manner.
