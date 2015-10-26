#Learning object scale from multiple view geometry
###### Ahmed AlMutawa, Austin Anderson, Rohit Raje, John Stechschulte, Wade Wu

We seek to build a computer vision system that can determine the scale of the world, and the objects in it. Multiple view geometry can construct a 3D model of a scene from a set of images of that scene, but the global scale of this model cannot be determined. Our first goal is to use image segmentation and object recognition to infer the overall scale of the model, using a small set of object classes for which we have provided prior scale information. Our second goal is for the system to then learn the scale of the other objects that it has segmented and labeled, and to determine which objects are most useful for global scale determination.
