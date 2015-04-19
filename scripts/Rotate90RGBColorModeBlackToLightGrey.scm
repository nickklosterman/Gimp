(define (script-fu-comic-inking-prep theImage drawable )

  (let* (
 
	 (levelledDrawableLayer (car (gimp-layer-copy drawable TRUE)))
         )

					;create undo group 
    (gimp-image-undo-group-start theImage)
;rotate image onto side for printing
    (gimp-image-rotate theImage 0)
;change to RGB mode since most images are GIFs
    (gimp-image-convert-rgb theImage)
;adjust levels such that black is changed to a light grey for printing
    (gimp-levels drawable 0 0 255 1 200 255)

					;set opacity at 40%
;    (gimp-layer-set-opacity AnaglyphDisplMapLyr  40 )

					;end undo group 
    (gimp-image-undo-group-end theImage)

    (gimp-displays-flush)
    )
  )

(script-fu-register "script-fu-comic-inking-prep"
                    _"<Image>/Script-Fu/ComicStrip/Inking-Prep"
                    "Rotates Image 90 degrees, changes color mode to RGB, change black to a light grey: designed to be a prep for printing BW comic strips for inking"
                    "InkyDinky"
                    "InkyDinky"
                    "2014 01 28"
                    "*"
                    SF-IMAGE        "Image"     0
                    SF-DRAWABLE     "Drawable"  0

                    )
