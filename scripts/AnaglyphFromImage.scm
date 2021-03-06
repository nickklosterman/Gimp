(define (script-fu-anaglyph_from_image theImage drawable displacement_offset_x displacement_offset_y  displacement_type edge_behavior levelsmode levels_gamma)


  (let* (
	 (displmapLyr (car (gimp-layer-copy drawable TRUE)))
	 (redLyr (car (gimp-layer-copy drawable TRUE)))
	 (cyanLyr (car (gimp-layer-copy drawable TRUE)))
	 (points (make-vector 8 'byte))
	 )

    (aset points 0 0)
    (aset points 1 0)
    (aset points 2 0)
    (aset points 3 0)
    (aset points 4 0)
    (aset points 5 0)
    (aset points 6 0)
    (aset points 7 0)

					;create undo group 
    (gimp-image-undo-group-start theImage)
					;create Displacement Map Layer
    (gimp-image-add-layer theImage displmapLyr -1)
    (gimp-desaturate-full displmapLyr DESATURATE-LUMINOSITY)
    (gimp-levels-stretch displmapLyr);stretch the levels to cover whole range. This won't make that much of a difference unless the image is horribly biased toward light or dark colors. This is because the amount of stretching is halved unless I fiddle with the gamma
    (gimp-levels displmapLyr levelsmode 0 255 levels_gamma 0 128);now restrict to 0-128


					;create Cyan layer         
    (gimp-image-add-layer theImage cyanLyr -1)
    (gimp-drawable-set-name cyanLyr "AnaglyphRedCyan")
					;create Red layer         
    (gimp-image-add-layer theImage redLyr -1)
    (gimp-drawable-set-name redLyr "Red")
    (gimp-layer-set-mode redLyr SCREEN-MODE)
					;mask channels                         
    (gimp-curves-spline cyanLyr 1 8 points)
    (gimp-curves-spline redLyr 2 8 points)
    (gimp-curves-spline redLyr 3 8 points)

					;Apply displacement map, the negative of the value is used for the cyan layer
    (plug-in-displace RUN-NONINTERACTIVE theImage redLyr displacement_offset_x displacement_offset_y 1 1 displmapLyr displmapLyr edge_behavior)
    (plug-in-displace RUN-NONINTERACTIVE theImage cyanLyr (- 0 displacement_offset_x) (- 0 displacement_offset_y) 1 1 displmapLyr displmapLyr edge_behavior)  

;merge layers down to clean up and create the single anaglyph image
    (gimp-image-merge-down theImage redLyr 2)
					;create undo group 
    (gimp-image-undo-group-end theImage)

    (gimp-displays-flush)
    )
  )
(script-fu-register "script-fu-anaglyph_from_image"
                    _"<Image>/Script-Fu/AnaglyphTools/Anaglyph-From-Image"
                    "Processes an image createing a depth map from the given image and then creating an anaglyph."
                    "InkyDinky"
                    "InkyDinky"
                    "2011 11 9"
                    "*"
                    SF-IMAGE        "Image"     0
                    SF-DRAWABLE     "Drawable"  0
		    SF-ADJUSTMENT "X/Radial Displacement Offset (pixels)" (list 20 0 60 1 10 0 SF-SLIDER )
		    SF-ADJUSTMENT "Y/Tangent Displacement Offset (pixels)" (list 0 0 60 1 10 0 SF-SLIDER )
		    SF-OPTION "Displacement Mode"  '("Cartesian" "Polar");this doesn't do anything
		    SF-OPTION "Edge Behavior"  '("Wrap" "Smear" "Black")
		    SF-OPTION "Levels Mode"  '("Value" "Red" "Green" "Blue" "Al\
pha" "RGB")
		    SF-ADJUSTMENT "Levels Gamma (high num darkens ie less movement, low num lightens ie more movement)" (list 1.0 0.1 10 0.5 10 1 SF-SLIDER )
                    )

					;script to creat array of 256 zeroes to remove channels.
					;#!/bin/bash                                                                                                                                                   ;  
					;x=0
					;while [ $x -lt 256 ]
					;do
					;echo "(aset points $x 0)"
					;let "x+=1"
					;done;
