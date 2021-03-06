(define (script-fu-flickerglyph_no_displ_map theImage drawable displacement_offset_x displacement_offset_y  displacement_type edge_behavior levelsmode)

  (let* (
	 (displmapLyr (car (gimp-layer-copy drawable TRUE)))
	 (redLyr (car (gimp-layer-copy drawable TRUE)))
	 (cyanLyr (car (gimp-layer-copy drawable TRUE)))

	 )

					;create undo group 
    (gimp-image-undo-group-start theImage)

					;create Displacement Map Layer
    (gimp-image-add-layer theImage displmapLyr -1)
    (gimp-desaturate-full displmapLyr DESATURATE-LUMINOSITY)
    (gimp-levels-stretch displmapLyr);stretch the levels to cover whole range. This won't make that much of a difference unless the image is horribly biased toward light or dark colors. This is because the amount of stretching is halved unless I fiddle with the gamma
    (gimp-levels displmapLyr levelsmode 0 255 1.0 0 128);now restrict to 0-128


                                      ;create Cyan layer                                         
    (gimp-image-add-layer theImage cyanLyr -1)
    (gimp-drawable-set-name cyanLyr "Wiggle1 (100 ms)")
    
                                    ;create Red layer                                          
    (gimp-image-add-layer theImage redLyr -1)
    (gimp-drawable-set-name redLyr "Wiggle2 (100 ms)")
    
                                        ;Apply displacement map, the negative of the value is used for the cyan layer   
    (plug-in-displace RUN-NONINTERACTIVE theImage redLyr displacement_offset_x displacement_offset_y 1 1 displmapLyr displmapLyr edge_behavior)
    (plug-in-displace RUN-NONINTERACTIVE theImage cyanLyr (- 0 displacement_offset_x) (- 0 displacement_offset_y) 1 1 displmapLyr displmapLyr edge_behavior)

		;create undo group 
    (gimp-image-undo-group-end theImage)

    (gimp-displays-flush)
    )
  )
(script-fu-register "script-fu-flickerglyph_no_displ_map"
                    _"<Image>/Script-Fu/AnaglyphTools/FlickerGlyph-From-Image"
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
