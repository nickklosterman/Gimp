
(define (script-fu-anaglyph theImage drawable)
  (let* (
;	(cyanLyr (car (gimp-layer-copy drawable TRUE)))
;	(redLyr (car (gimp-layer-copy drawable TRUE)))
	(theLayersList (cadr (gimp-image-get-layers theImage)))
	(theImageMapLayer (aref theLayersList 0))
	(theBackgroundLayer (aref theLayersList 1))
	(redLyr (car (gimp-layer-copy theBackgroundLayer TRUE)))
	(cyanLyr (car (gimp-layer-copy theBackgroundLayer TRUE)))
	)

;theLayersList gave unbound variable?? when it was just let instead of let*

    (gimp-image-add-layer theImage cyanLyr -1)
    (gimp-drawable-set-name cyanLyr "Cyan")
 ;   (plug-in-colors-channel-mixer RUN-NONINTERACTIVE theImage cyanLyr FALSE 0.0 0.0 0.0 100.0 100.0 100.0 100.0 100.0 100.0 )


    (gimp-image-add-layer theImage redLyr -1)
    (gimp-drawable-set-name redLyr "Red")
    ;(plug-in-colors-channel-mixer RUN-NONINTERACTIVE theImage redLyr FALSE 100.00 100.0 100.0 00.0 00.0 00.0 00.0 00.0 00.0 )
    (gimp-layer-set-mode redLyr SCREEN-MODE)    

					;(gimp-curves-explicit cyanLyr HISTOGRAM-RED 
					;perform displacement
;    (plug-in-displace RUN-NONINTERACTIVE theImage cyanLyr 10 0 0.0 0 theImageMapLayer theImageMapLayer 1) 
;    (plug-in-displace RUN-INTERACTIVE theImage cyanLyr 10 0 0.0 0 theImageMapLayer theImageMapLayer 1) 
					;0 WRAP 1 SMEAR 2 BLACK
;    (plug-in-displace RUN-NONINTERACTIVE theImage redLyr -10.0 0.0 1 1 theImageMapLayer theImageMapLayer 2)  ;if the do-x and do-y variables (currently 1's to 0's) then I don't get the vector-ref out of bounds error
;   (plug-in-displace RUN-INTERACTIVE theImage redLyr -10 0 TRUE TRUE 0 theImageMapLayer theImageMapLayer 2) 
    (gimp-displays-flush)
    )
  )
(script-fu-register "script-fu-anaglyph"
		    _"<Image>/Script-Fu/Anaglyph"
		    "Processes an image and depth-map into a red-cyan anaglyph"
		    "InkyDinky"
		    "InkyDinky"
		    "2011 11 7"
		    "*"
		    SF-IMAGE        "Image"     0
		    SF-DRAWABLE     "Drawable"  0
		    )
					; the Red layer is the top layer, set to screen mode
					; even though we opened two parens we only close one here, close the other at the end of the script