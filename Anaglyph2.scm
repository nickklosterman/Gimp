
(define (script-fu-anaglyph2 theImage drawable)
  (let* (
	(redLyr (car (gimp-layer-copy drawable TRUE)))
	(cyanLyr (car (gimp-layer-copy drawable TRUE)))
;	((num_bytes 256))
;	(points (make-vector num_bytes 'byte))
;	((count 0))
;	((zero 0))

)


;create Cyan layer
    (gimp-image-add-layer theImage cyanLyr -1)
    (gimp-drawable-set-name cyanLyr "Cyan")
;create Red layer
    (gimp-image-add-layer theImage redLyr -1)
    (gimp-drawable-set-name redLyr "Red")
    (gimp-layer-set-mode redLyr SCREEN-MODE)    
;mask channels
;    (plug-in-colors-channel-mixer RUN-NONINTERACTIVE theImage cyanLyr FALSE 0.0 0.0 0.0 0.99 0.99 0.99 0.99 0.99 0.99 )                                  
;    (plug-in-colors-channel-mixer RUN-NONINTERACTIVE theImage redLyr  FALSE 0.0099 0.0099 0.0099 0.0 0.0 0.0 0.0 0.0 0.0 ) 
;    (gimp-curves-explicit cyanLyr 1 256 flat_curve )
;(gimp-curves-spline cyanLyr 1 8 points)
    (gimp-displays-flush)
    )
  )
(script-fu-register "script-fu-anaglyph2"
		    _"<Image>/Script-Fu/Anaglyph2"
		    "Processes an image and depth-map into a red-cyan anaglyph"
		    "InkyDinky"
		    "InkyDinky"
		    "2011 11 7"
		    "*"
		    SF-IMAGE        "Image"     0
		    SF-DRAWABLE     "Drawable"  0
		    )
