(define (script-fu-anaglyph_prep theImage drawable )

  (let* (
	
	 (AnaglyphDisplMapLyr (car (gimp-layer-copy drawable TRUE)))
(histo_values)
(mean_value)
(median_value)
(thresholdval)
(std_dev_value)
         )

					;create undo group 
    (gimp-image-undo-group-start theImage)


					;create DisplMap layer                                         
    (gimp-image-add-layer theImage AnaglyphDisplMapLyr -1)
    (gimp-drawable-set-name AnaglyphDisplMapLyr "DisplMap")

;perform edge detection
    (plug-in-edge RUN-INTERACTIVE theImage AnaglyphDisplMapLyr  1.0 0 4)


 ; get the histogram values as a list                                                                                                                                                            
          (set! histo_values (gimp-histogram AnaglyphDisplMapLyr 5 0 255))   ;5->rgb channel
					;extract the wanted values from the list
	  (set! mean_value (number->string (car histo_values)))
;          (set! std_dev_value (number->string (car (cdr histo_values))))
          (set! std_dev_value  (car (cdr histo_values)))
;          (set! median_value (number->string (car (cdr (cdr histo_values)))))     
          (set! median_value  (car (cdr (cdr histo_values))))
	  (set! thresholdval (+ std_dev_value  median_value)) ;this seems to make for a good threshold level since can't do interactive thresholding.
;    (plug-in-threshold-alpha RUN-INTERACTIVE theImage AnaglyphDisplMapLyr 255)
    (gimp-threshold  AnaglyphDisplMapLyr 0 thresholdval) ;there isn't an interactive threshold...arg
;    (gimp-invert AnaglyphDisplMapLyr)

;set opacity at 40%
    (gimp-layer-set-opacity AnaglyphDisplMapLyr  40 )

					;end undo group 
    (gimp-image-undo-group-end theImage)

    (gimp-displays-flush)
    )
  )

(script-fu-register "script-fu-anaglyph_prep"
                    _"<Image>/Script-Fu/AnaglyphTools/Anaglyph-Image-Prep-for-Displ-Map"
                    "Preps an image to create a depth map for an anaglyph"
                    "InkyDinky"
                    "InkyDinky"
                    "2012 03 19"
                    "*"
                    SF-IMAGE        "Image"     0
                    SF-DRAWABLE     "Drawable"  0

                    )
