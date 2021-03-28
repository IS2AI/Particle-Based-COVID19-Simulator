# import the necessary packages
from imutils import paths
import numpy as np
import argparse
import imutils
import time
import cv2
import os

# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-e", "--exp", required=True,
	help="path to the experiment")
ap.add_argument("-v", "--video", required=True,
	help="path to the output video")
args = vars(ap.parse_args())

# load epidemic map's legends
image_legend = cv2.imread("legends.jpg")
(h, w) = image_legend.shape[:2]

# initialize the video writer
writer = None
(W, H) = (None, None)

# sampling time in the simulation
delta_t = 0.0043

# grab paths to the images
imagePaths = list(paths.list_images(os.path.join(args["exp"], "map/")))

# loop over the images
for day in range(1, len(imagePaths)):
	if day != 1:
		day = day * 50

	#if day * delta_t > 5:
	#	break

	img_epidemic_map = cv2.imread(os.path.join(args["exp"], "map/ind_{}.png".format(day)))
	(he, we) = img_epidemic_map.shape[:2]
	img_epidemic_map[75:h + 75, we // 2 - w // 2 + 9:we // 2 + w // 2 + 10] = image_legend
	img_epidemic_map = img_epidemic_map[0:img_epidemic_map.shape[2]-50, 50:img_epidemic_map.shape[1]-60, :]

	img_age_vacc_map = cv2.imread(os.path.join(args["exp"], "map_age/ind_{}.png".format(day))) 
	img_age_vacc_map = img_age_vacc_map[0:img_age_vacc_map.shape[2]-50, 50:img_age_vacc_map.shape[1]-60, :]

	print("[INFO] Processing ind: {}".format(day))

	image = np.hstack([img_epidemic_map, img_age_vacc_map])
	cv2.putText(image, "# daily vaccines per thousand people = 2, day = {:.1f}".format(day * delta_t),
	 (image.shape[1]//4, 35), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 0), 2)

	#image[image.shape[0]-h-10:image.shape[0]-10, image.shape[1]//2-w//2+9:image.shape[1]//2+w//2+10] = image_legend

	# if the frame dimensions are empty, grab them
	if W is None or H is None:
		(H, W) = image.shape[:2]


	# check if the video writer is None
	if writer is None:
		# initialize our video writer
		fourcc = cv2.VideoWriter_fourcc(*"XVID")
		writer = cv2.VideoWriter(os.path.join(args["exp"], args["video"]), fourcc, 10,
			(image.shape[1], image.shape[0]), True)

	writer.write(image)

# release the file pointers
print("[INFO] cleaning up...")
writer.release()
