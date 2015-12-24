#Learning object scale from multiple view geometry
###### Ahmed AlMutawa, Austin Anderson, Rohit Raje, John Stechschulte, Wade Wu

###Project Goal
Robots navigating unknown environments must estimate the scale of the world around them. This can be done with active depth sensors, stereoscopic cameras, or fusion of data from multiple sensors. The goal of this project is to explore an alternative approach to learning environment scale by using a single camera and machine learning algorithms trained to estimate object scale from RGB images. At this stage, only learning depth from pre­segmented, labelled objects will be addressed. The identification and segmentation of objects from an image is left for future work.


###Implementation

Estimating distance to an object is a continuous prediction. The core estimator for this project is a linear regression that calculates weights for combining features extracted from the image data. The NYU dataset provides RGB-D images that have objects individually labelled and segmented. The dataset includes 894 different, labelled object classes. The full dataset is broken into a training set and a testing set for cross validation using a ¾, ¼ split. 

For a single object, the relevant training and testing images are extracted, and a preprocessing step is applied to separate individual objects of the specified type in each image. This is done by generating a binary mask of the labelled object indices and applying an erosion and a dilation filter. The erosion filter eliminates small objects and connections between objects. The dilation filter grows the mask uniformly to return to the original size. A connected component analysis is then run to isolate individual objects. These isolated objects are treated as separate data points for training, labelling, and testing. This step is especially important for objects that appear multiple times in a single image, like chairs.

Two major functions were developed one_obj_run.m and main_loop.m. One_obj_run.m runs an in-depth analysis of a single object type and can be used to tune preprocessing parameters to maximize fit performance. Main_loop.m runs a bulk analysis over all object types using a single preprocessing configuration. The results suggest which object classes warrant further analysis. 

A variety of features, both hand-engineered and learned, were tested. Most of these were rejected since they did not improve the testing error, and instead served to enable overtraining. Rejected features include,
Sparse filtering [1], an unsupervised feature learning algorithm that learns a linear transformation from a large number of input features to a small number of output features with advantageous sparse characteristics. Because a one-layer model was computationally intractable, a two-layer model was used. The first layer acted on image patches, generating intermediate features that were fed through the second layer, which had 20 output features.
Principal Component Analysis (PCA). The largest component should carry information about object size and be more orientation invariant.
Water filling [2]. This algorithm yielded statistics about max/min gray value of connected area, maximum ratio of connected area to gray value difference.
Hough Transform. Detects lines and peaks within an image, which could be a good identifier of various objects. A variant of this technique, the Circular Hough Transform, was also tried.
Edge detection. This generated too many features, and overlapped significantly with corner detection.



###Results

As expected, the classifier works better for some object classes than others. For instance, the “monitor” classifier performs far better than the “wall” classifier. There are multiple reasons for this, such as variation within an object class (walls come in a wider range of sizes than monitors), and variation in an object’s setting (walls are more likely to be occluded, or only partially in the image frame, than monitors). In the target application, the robot would only use more reliable objects for scale determination, and could also include a measure of uncertainty in the result. 

Initially, the whole data set was processed with the full set of features. Object classes with an insufficient number of training examples were discarded. For each acceptable regression, statistics on the estimated weighting coefficients were calculated. These statistics included a p-test to assess the statistical significance of the different feature weights. In the first run using all 10 features, regressions were run on 115 object classes. Based on these results the performance of individual features were assessed.

From this analysis it was determined that dx, x-pos, and num_corn were underperforming and were eliminated to reduce overfitting and processing time. 

Using the reduced set of features the regression model was run against the full dataset. With fewer features, 131 object classes had sufficient data for the regression. The following plots show the resulting performance sorted by increasing error of the training set:

Objects like ‘toilet paper’ and ‘paper towel’ are typically shaped like cylinders, and so have well defined sizes and constant width at all viewing angles. Inverse pixel height performed well for toilet paper and the linearized number of pixels performed well for paper towels. Objects like ‘sink’ tend to be in well defined locations in a scene, specifically in a countertop that is mounted to the floor. The pixel y-position of objects tended to perform well for a wide variety of object types. This was counterintuitive at first; an analysis was performed to understand it.

For a camera at a constant height, if an object moves along a plane such as the floor, it will appear to ascend in the vertical axis of the image. This explains the strong y-pos correlation observed throughout the data. 

The strength of the bias term can be understood by considering the distribution of depths in the training dataset. The histograms below show the number of objects at various depths across all object classes, in the training and testing datasets. 

The bias term is strong because the depth distribution has a strong mode--with no other information, the regression does pretty well by guessing an object’s depth is 2.5m. Ideally this distribution would be more uniform to improve the performance of the classifier in more generalized scenarios. 

###Conclusions

Across hundreds of object classes, the testing error varied by almost two orders of magnitude. Some classes of object have greater size variance, and factors such as occlusions and viewing angle can affect the result significantly, as well. This is to be expected, and is acceptable: in the target application, only the more reliable objects need be considered, and by aggregating information over many observations the effect of outliers is mitigated. 

As is often the case in the application of machine learning, this work uncovered as much insight about the training data and how it was collected as it did about the problem. For instance, the effectiveness of the y-coordinate in predicting depth was unexpected, but makes sense in retrospect considering the data was collected by a human carrying a camera at a fairly consistent height and angle to the ground. This, of course, limits the usefulness of the particular results obtained here: images captured looking down from a quadcopter or up from a small ground vehicle would have very high error in this regression. However, the overall method is still valid, and could be repeated with new training data that is representative of the desired application.

###Future Work

There are a variety of ways this work could be enhanced or extended. The goal application of scale determination would require also implementing object segmentation and recognition, likely through use of deep convolutional nets. Within the problem domain addressed here, improvements might be possible by augmenting the training data to make the regression more robust, and allowing parameters to be tuned for each object type and further determining how to tune them in a statistically rigorous and automatic manner.
