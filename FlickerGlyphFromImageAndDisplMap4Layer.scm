(define (script-fu-flickerglyph_displ_map-4layer theImage drawable displacement_offset_x displacement_offset_y  displacement_type edge_behavior rescale_levels levelsmode)

  (let* (
 (theLayersList (cadr (gimp-image-get-layers theImage)))
        (displmapLyr (aref theLayersList 0)) ;if you have multiple layers the image map needs to be the topmost layer
        (theBackgroundLayer (aref theLayersList 1))
	(origimageLyr (car (gimp-layer-copy theBackgroundLayer TRUE)))
         (origimage2Lyr (car (gimp-layer-copy theBackgroundLayer TRUE)))

	 (redLyr (car (gimp-layer-copy drawable TRUE)))
	 (cyanLyr (car (gimp-layer-copy drawable TRUE)))

	 )

					;create undo group 
    (gimp-image-undo-group-start theImage)

;(if (rescale_levels)
    (gimp-levels displmapLyr levelsmode 0 255 1.0 0 128)

                                      ;create Cyan layer                                         
    (gimp-image-add-layer theImage cyanLyr -1)
    (gimp-drawable-set-name cyanLyr "Wiggle1 (100 ms)")

 ;create intermediate baground layer                                                                                                           
    (gimp-image-add-layer theImage origimageLyr -1)
    (gimp-drawable-set-name origimageLyr "NoWiggle1 (100 ms)")
    
                                    ;create Red layer                                          
    (gimp-image-add-layer theImage redLyr -1)
    (gimp-drawable-set-name redLyr "Wiggle2 (100 ms)")

;create intermediate baground layer                                                                                                           
    (gimp-image-add-layer theImage origimage2Lyr -1)
    (gimp-drawable-set-name origimage2Lyr "NoWiggle2 (100 ms)")
    
                                        ;Apply displacement map, the negative of the value is used for the cyan layer   
    (plug-in-displace RUN-NONINTERACTIVE theImage redLyr displacement_offset_x displacement_offset_y 1 1 displmapLyr displmapLyr edge_behavior)
    (plug-in-displace RUN-NONINTERACTIVE theImage cyanLyr (- 0 displacement_offset_x) (- 0 displacement_offset_y) 1 1 displmapLyr displmapLyr edge_behavior)

		;create undo group 
    (gimp-image-undo-group-end theImage)

    (gimp-displays-flush)
    )
  )
(script-fu-register "script-fu-flickerglyph_displ_map-4layer"
                    _"<Image>/Script-Fu/AnaglyphTools/FlickerGlyph-from-Image-and-Displ-Map-4Layer"
                    "Processes an image createing a depth map from the given image and then creating a flickerglyph."
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
  SF-TOGGLE     "Rescale Levels?"   FALSE
SF-OPTION "Levels Mode"  '("Value" "Red" "Green" "Blue" "Al\
pha" "RGB")

                    )

					;script to creat array of 256 zeroes to remove channels.
					;#!/bin/bash                                                                                                                                                   ;  
					;x=0
					;while [ $x -lt 256 ]
					;do
					;echo "(aset points $x 0)"
					;let "x+=1"
					;done;
