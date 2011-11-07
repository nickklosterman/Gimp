

(define (script-fu-anaglyph3 theImage drawable displacement_offset_x displacement_offset_y  displacement_type edge_behavior)
;displacement_type <-this doesn't do anything unless its a 1

  (let* (
        (redLyr (car (gimp-layer-copy drawable TRUE)))
        (cyanLyr (car (gimp-layer-copy drawable TRUE)))
	(theLayersList (cadr (gimp-image-get-layers theImage)))
        (theImageMapLayer (aref theLayersList 0)) ;if you have multiple layers the image map ne
        (theBackgroundLayer (aref theLayersList 1))
;	((num_bytes 256))
;	(displacement_offset_neg (- 0 displacement_offset))
        (points (make-vector 8 'byte))
 ;       ((count 0))
  ;      ((zero 0))

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
;create Cyan layer                                                                                                                                              
    (gimp-image-add-layer theImage cyanLyr -1)
    (gimp-drawable-set-name cyanLyr "Cyan")
;create Red layer                                                                                                                                               
    (gimp-image-add-layer theImage redLyr -1)
    (gimp-drawable-set-name redLyr "Red")
    (gimp-layer-set-mode redLyr SCREEN-MODE)
;mask channels                                                                                                                                                 
;At one pont I had channel-mixer working but now it is broken. Not sure exactly what the "gain" does. I just want to blank out the unwanted channels 
;    (plug-in-colors-channel-mixer RUN-NONINTERACTIVE theImage cyanLyr FALSE 0.0 0.0 0.0 0.99 0.99 0.99 0.99 0.99 0.99 )
;    (plug-in-colors-channel-mixer RUN-NONINTERACTIVE theImage redLyr  FALSE 0.0099 0.0099 0.0099 0.0 0.0 0.0 0.0 0.0 0.0 )
;    (gimp-curves-explicit cyanLyr 1 256 points )
;   (gimp-curves-explicit redLyr 2 256 points )
;   (gimp-curves-explicit redLyr 3 256 points )

(gimp-curves-spline cyanLyr 1 8 points);somehow this works with the 8point spline so that we flatten the R channel for cyan layer and G/B channel for the red layer
(gimp-curves-spline redLyr 2 8 points)
(gimp-curves-spline redLyr 3 8 points)


;Apply displacement map
(plug-in-displace RUN-NONINTERACTIVE theImage redLyr displacement_offset_x displacement_offset_y 1 1 theImageMapLayer theImageMapLayer edge_behavior)

(plug-in-displace RUN-NONINTERACTIVE theImage cyanLyr (- 0 displacement_offset_x) (- 0 displacement_offset_y) 1 1 theImageMapLayer theImageMapLayer edge_behavior)  ;if I change the do-x and do-y variables (from  1's to 0's) then I don't get the vector-ref out of bounds error
;create undo group 
 (gimp-image-undo-group-end theImage)

    (gimp-displays-flush)
    )
  )
(script-fu-register "script-fu-anaglyph3"
                    _"<Image>/Script-Fu/AnaglyphTools/Anaglyph3"
                    "Processes an image and depth-map into a red-cyan anaglyph.Background as bottommost layer, disp map as topmost layer" ; works best if disp map is scaled using curves to 0-127 vs 0-255
                    "InkyDinky"
                    "InkyDinky"
                    "2011 11 7"
                    "*"
                    SF-IMAGE        "Image"     0
                    SF-DRAWABLE     "Drawable"  0
		    SF-ADJUSTMENT "X/Radial Displacement Offset (pixels)" (list 20 0 60 1 10 0 SF-SLIDER )
		    SF-ADJUSTMENT "Y/Tangent Displacement Offset (pixels)" (list 0 0 60 1 10 0 SF-SLIDER )
		    SF-OPTION "Displacement Mode"  '("Cartesian" "Polar");this doesn't do anything
		    SF-OPTION "Edge Behavior"  '("Wrap" "Smear" "Black")

                    )

;script to creat array of 256 zeroes to remove channels.
;#!/bin/bash                                                                                                                                                   ;  
;x=0
;while [ $x -lt 256 ]
;do
;echo "(aset points $x 0)"
;let "x+=1"
;done;
