

(define (script-fu-expand-contract-disp-map theImage drawable )

  (let* (
;create undo group 
	 (gimp-image-undo-group-start theImage)
	 (gimp-levels-stretch drawable )
	 (gimp-levels-auto drawable )
;	 (gimp-levels drawable 5 0 255 1.0 0 127);might consider playing with the gamma (set here to 1.0) to change the way the displ map is created. Read the Procedure Browser for more info
	 (gimp-image-undo-group-end theImage)

	 (gimp-displays-flush)
	 )
    )
  )
(script-fu-register "script-fu-expand-contract-disp-map"
		    _"<Image>/Script-Fu/AnaglyphTools/ExpandContractDisplacementMap"
		    "Processes an image and depth-map into a red-cyan anaglyph.Background as bottommost layer, disp map as topmost layer" ; works best if disp map is scaled using curves to 0-127 vs 0-255
		    "InkyDinky"
		    "InkyDinky"
		    "2011 11 7"
		    "*"
		    SF-IMAGE        "Image"     0
		    SF-DRAWABLE     "Drawable"  0
		    )

