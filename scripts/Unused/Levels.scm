(define (script-fu-levels theImage drawable displacement_offset_x displacement_offset_y  displacement_type edge_behavior levelsmode)


  (let* (
	 (theLayersList (cadr (gimp-image-get-layers theImage)))

	 ( displmapLyr  (aref theLayersList 0)) ;if you have multiple layers  the image map ne                                                                
	 (theBackgroundLayer (aref theLayersList 1))
	 (displmapLyr (car (gimp-layer-copy drawable TRUE)))
	 (redLyr (car (gimp-layer-copy drawable TRUE)))
	 (cyanLyr (car (gimp-layer-copy drawable TRUE)))

	 )

					;create undo group 
    (gimp-image-undo-group-start theImage)

					;create Displacement Map Layer
    (gimp-image-add-layer theImage displmapLyr -1)
;    (gimp-desaturate-full displmapLyr DESATURATE-LUMINOSITY)
    (gimp-levels displmapLyr levelsmode 0 255 1.0 0 128)
					;create undo group 
    (gimp-image-undo-group-end theImage)

    (gimp-displays-flush)
    )
  )
(script-fu-register "script-fu-levels"
                    _"<Image>/Script-Fu/AnaglyphTools/Levels"
                    "modifiy levels."
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
		    SF-OPTION "Levels Mode"  '("Value" "Red" "Green" "Blue" "Alpha" "RGB")

                    )

					;script to creat array of 256 zeroes to remove channels.
					;#!/bin/bash                                                                                                                                                   ;  
					;x=0
					;while [ $x -lt 256 ]
					;do
					;echo "(aset points $x 0)"
					;let "x+=1"
					;done;
