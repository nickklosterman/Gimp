

(define (script-fu-create-red-cyan-layerse theImage drawable )



  (let* (
	 (redLyr (car (gimp-layer-copy drawable TRUE)))
	 (cyanLyr (car (gimp-layer-copy drawable TRUE)))
	 )

;create undo group 
    (gimp-image-undo-group-start theImage)
;create Cyan layer
    (gimp-image-add-layer theImage cyanLyr -1)
    (gimp-drawable-set-name cyanLyr "Cyan")
;create Red layer
    (gimp-image-add-layer theImage redLyr -1)
    (gimp-drawable-set-name redLyr "Red")
    (gimp-layer-set-mode redLyr SCREEN-MODE)
    (gimp-image-undo-group-end theImage)
    (gimp-displays-flush)
    )
  )
(script-fu-register "script-fu-create-red-cyan-layers"
		    _"<Image>/Script-Fu/AnaglyphTools/CreateRedCyanLayers"
		    "Processes an image and depth-map into a red-cyan anaglyph.Background as bottommost layer, disp map as topmost layer" ; works best if disp map is scaled using curves to 0-127 vs 0-255
		    "InkyDinky"
		    "InkyDinky"
		    "2011 11 7"
		    "*"
		    SF-IMAGE        "Image"     0
		    SF-DRAWABLE     "Drawable"  0
		    )

