(define (script-fu-anaglyph_displ_map theImage drawable displacement_offset_x displacement_offset_y  displacement_type edge_behavior rescale_levels levelsmode apply_blur blur_x blur_y anaglyph_algorithm)

  (let* (
	 (theLayersList (cadr (gimp-image-get-layers theImage)))
	 (displmapLyr (aref theLayersList 0)) ;if you have multiple layers the image map needs to be the topmost layer
	 (theBackgroundLayer (aref theLayersList 1))
	 (redLyr (car (gimp-layer-copy drawable TRUE)))
	 (cyanLyr (car (gimp-layer-copy drawable TRUE)))
	 (isRGBmode (car (gimp-drawable-is-rgb drawable)))
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


					;Displacement map should be top layer
					;image to be displaced should be the layer that is selected.


					;TODO:auto turn the displ map layer visibility off
					;DONE: 2012-03-15 TODO:make sure opacity 100%

					;create undo group 
    (gimp-image-undo-group-start theImage)

    (gimp-message-set-handler 0)
					;(gimp-message "Bitches")
    (gimp-message (number->string anaglyph_algorithm 10))

    (gimp-selection-all theImage)
    (if ( = isRGBmode FALSE)
	(gimp-image-convert-rgb theImage) ;the parens are crucial or it will fail
	)
					;make sure opacity at 100%
    (gimp-layer-set-opacity drawable 100 )
    (gimp-layer-set-opacity displmapLyr 100 )
    (gimp-layer-set-opacity theBackgroundLayer 100 )

(cond 
[(= anaglyph_algorithm 0) (gimp-message "optimo")] ;
[(= anaglyph_algorithm 1) (gimp-message "half color")]; 
[(= anaglyph_algorithm 2) (gimp-message "gray")]; 
[(= anaglyph_algorithm 3) (gimp-message "full color")] ; full color
)

;I could never get scheme's (case or the above (cond thingee to work.
;it also appears that in the if statement only the first line/command is executed
;ugggh wtf. 


;this if statement "leaks" I'm not sure if it really just performs the one plug-in-colors or if it does multiple. when undoing the undo group I see only one "channel-mixer" item show up in the undo tab.
;(set! anaglyph_algorithm 2)
(if (= anaglyph_algorithm 0)
;optimized
(plug-in-colors-channel-mixer RUN-NONINTERACTIVE theImage drawable FALSE 0.0   0.7 0.3 0.0 1.0 0.0 0.0 0.0 1.0) 
(gimp-message "we have a 0")
)
(if (= anaglyph_algorithm 1)
; half color
(plug-in-colors-channel-mixer RUN-NONINTERACTIVE theImage drawable FALSE 0.299 0.587 0.114 0.0 1.0 0.0 0.0 0.0 1.0)  
(gimp-message "we have a 1")
)
(if (= anaglyph_algorithm 2)
;gray
(plug-in-colors-channel-mixer RUN-NONINTERACTIVE theImage drawable FALSE 0.299 0.587 0.114 0.299 0.587 0.114 0.299 0.587 0.114)  
(gimp-message "we have a 2")
)
(if (= anaglyph_algorithm 3)
(gimp-message "we have a 3a")
(gimp-message "we have a 3b")
)

					;creating copies here bc if created when program called they will cause an error if we need to convert to RGB. image will be RGB but layers will be of diff type.
    (set! redLyr (car (gimp-layer-copy drawable TRUE ))) 
    (set! cyanLyr (car (gimp-layer-copy drawable TRUE ))) 

					;I had this commented out even though we want to switch based on its input 2012-03-14 , for some reason I can't get this if statment to work. I had the data type wrong. Works now.
    (if ( = rescale_levels TRUE)
	(gimp-levels displmapLyr levelsmode 0 255 1.0 0 128)
	) ;close the if rescale levels
					;create Cyan layer                                         
    (gimp-image-add-layer theImage cyanLyr -1)
    (gimp-drawable-set-name cyanLyr "Cyan Layer")
    
					;create Red layer                                          
    (gimp-image-add-layer theImage redLyr -1)
    (gimp-drawable-set-name redLyr "Red Layer")
    (gimp-layer-set-mode redLyr SCREEN-MODE)


					;this could be done easier using the channels mixer
					;mask channels to create Red image, Cyan image
    (gimp-curves-spline cyanLyr 1 8 points)
    (gimp-curves-spline redLyr 2 8 points)
    (gimp-curves-spline redLyr 3 8 points)

					;apply blur if desired ; this helps tremendously with the jagged edges that sometimes are produced
    (if ( = apply_blur TRUE)
	(plug-in-gauss TRUE theImage displmapLyr blur_x blur_y 0)
	) ;close 
    
                                        ;Apply displacement map, the negative of the value is used for the cyan layer   
    (plug-in-displace RUN-NONINTERACTIVE theImage redLyr displacement_offset_x displacement_offset_y 1 1 displmapLyr displmapLyr edge_behavior)
    (plug-in-displace RUN-NONINTERACTIVE theImage cyanLyr (- 0 displacement_offset_x) (- 0 displacement_offset_y) 1 1 displmapLyr displmapLyr edge_behavior)


					;merge layers down to clean up and create the single anaglyph image

    (gimp-image-merge-down theImage redLyr 2)

					;turn off visibility of 
    (gimp-layer-set-visible displmapLyr FALSE )
					;end undo group 
    (gimp-image-undo-group-end theImage)

    (gimp-displays-flush)
    )
  )

(script-fu-register "script-fu-anaglyph_displ_map"
                    _"<Image>/Script-Fu/AnaglyphTools/Anaglyph-from-Image-and-Displ-Map"
                    "Processes an image and its depth map creating an anaglyph. Topmost layer = depth map, background layer selected"
                    "InkyDinky"
                    "InkyDinky"
                    "2011 11 9"
                    "*"
                    SF-IMAGE        "Image"     0
                    SF-DRAWABLE     "Drawable"  0
		    SF-ADJUSTMENT "X/Radial Displacement Offset (pixels)" (list 10 0 60 1 10 0 SF-SLIDER )
		    SF-ADJUSTMENT "Y/Tangent Displacement Offset (pixels)" (list 0 0 60 1 10 0 SF-SLIDER )
		    SF-OPTION "Displacement Mode"  '("Cartesian" "Polar");this doesn't do anything
		    SF-OPTION "Edge Behavior"  '("Wrap" "Smear" "Black")
		    SF-TOGGLE     "Rescale Levels?"   TRUE
		    SF-OPTION "Levels Mode"  '("Value" "Red" "Green" "Blue" "Alpha" "RGB")
		    SF-TOGGLE     "Apply Gaussian Blur?"   TRUE
		    SF-ADJUSTMENT "X Blur Radius (pixels)" (list 10 0 60 1 10 1 SF-SLIDER )
		    SF-ADJUSTMENT "Y Blur Radius (pixels)" (list 10 0 60 1 10 1 SF-SLIDER )

		    SF-OPTION     "Anaglyph Mode"        '("optimized" "half color"  "gray" "color" )
                    )

					;script to creat array of 256 zeroes to remove channels.
					;#!/bin/bash                                                                                                                                                   ;  
					;x=0
					;while [ $x -lt 256 ]
					;do
					;echo "(aset points $x 0)"
					;let "x+=1"
					;done;
