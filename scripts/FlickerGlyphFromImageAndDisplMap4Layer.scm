(define (script-fu-flickerglyph_displ_map-4layer theImage drawable displacement_offset_x displacement_offset_y  displacement_type edge_behavior rescale_levels levelsmode apply_blur blur_x blur_y)
  (let* (
	 (theLayersList (cadr (gimp-image-get-layers theImage)))
	 (displmapLyr (aref theLayersList 0)) ;if you have multiple layers the image map needs to be the topmost layer
	 (theBackgroundLayer (aref theLayersList 1))
	 (origimageLyr (car (gimp-layer-copy theBackgroundLayer TRUE)))
         (origimage2Lyr (car (gimp-layer-copy theBackgroundLayer TRUE)))
	 (isRGBmode (car (gimp-drawable-is-rgb drawable)))
	 (redLyr (car (gimp-layer-copy drawable TRUE)))
	 (cyanLyr (car (gimp-layer-copy drawable TRUE)))

	 )

					;create undo group 
    (gimp-image-undo-group-start theImage)


    (if ( = isRGBmode FALSE)
	(gimp-image-convert-rgb theImage) ;the parens are crucial or it will fail
	)
					;make sure opacity at 100%
    (gimp-layer-set-opacity drawable 100 )
    (gimp-layer-set-opacity displmapLyr 100 )
    (gimp-layer-set-opacity theBackgroundLayer 100 )


					;creating copies here bc if created when program called they will cause an error if we need to convert to RGB. image will be RGB but layers will be of diff type.
    (set! redLyr (car (gimp-layer-copy drawable TRUE ))) 
    (set! cyanLyr (car (gimp-layer-copy drawable TRUE ))) 


    (if ( = rescale_levels TRUE)
	(gimp-levels displmapLyr levelsmode 0 255 1.0 0 128)
	)

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


					;apply blur if desired ; this helps tremendously with the jagged edges that sometimes are produced
    (if ( = apply_blur TRUE)
	(plug-in-gauss TRUE theImage displmapLyr blur_x blur_y 0)
	) ;close 
    
                                        ;Apply displacement map, the negative of the value is used for the cyan layer   
    (plug-in-displace RUN-NONINTERACTIVE theImage redLyr displacement_offset_x displacement_offset_y 1 1 displmapLyr displmapLyr edge_behavior)
    (plug-in-displace RUN-NONINTERACTIVE theImage cyanLyr (- 0 displacement_offset_x) (- 0 displacement_offset_y) 1 1 displmapLyr displmapLyr edge_behavior)

					;turn off visibility of 
    (gimp-layer-set-visible displmapLyr FALSE )
					;create undo group 
    (gimp-image-undo-group-end theImage)

    (gimp-displays-flush)
    )
  )
(script-fu-register "script-fu-flickerglyph_displ_map-4layer"
                    _"<Image>/Script-Fu/AnaglyphTools/FlickerGlyph-from-Image-and-Displ-Map-4Layer"
                    "Processes an image and depth map and then creates a flickerglyph that loops nicely back on itself. Uses 4 frames for added smoothness instead of 3. Topmost layer=depth map, background layer selected"
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

		    SF-TOGGLE     "Apply Gaussian Blur?"   FALSE
		    SF-ADJUSTMENT "X Blur Radius (pixels)" (list 10 0 60 1 10 1 SF-SLIDER )
		    SF-ADJUSTMENT "Y Blur Radius (pixels)" (list 10 0 60 1 10 1 SF-SLIDER )

                    )

					;script to creat array of 256 zeroes to remove channels.
					;#!/bin/bash                                                                                                                                                   ;  
					;x=0
					;while [ $x -lt 256 ]
					;do
					;echo "(aset points $x 0)"
					;let "x+=1"
					;done;
