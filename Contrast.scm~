(define (script-fu-increase-contrast img drw)
  (let ((pop-base (car (gimp-layer-copy drw TRUE)))
        (pop-ovly (car (gimp-layer-copy drw TRUE))))
    
    (gimp-image-undo-group-start img)
    (gimp-image-add-layer img pop-base -1)
    (gimp-drawable-set-name pop-base "pop")
    (gimp-image-add-layer img pop-ovly -1)
;    (plug-in-colors-channel-mixer RUN-NONINTERACTIVE img pop-base FALSE 100.0 100.0 100.0 100.0 100.0 100.0 100.0 100.0 100.0 )
    (gimp-drawable-set-name pop-ovly "pop-ovly")
    (gimp-layer-set-mode pop-ovly 5)
    (gimp-layer-set-opacity pop-ovly 50)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)))

(script-fu-register
    "script-fu-increase-contrast"
    "contrast+";name that shows in menu
    "Increase contrast to give an image some extra pop"
    "Marco S Hyman <marc@snafu.org>"
    "PUBLIC DOMAIN: No Rights Reserved"
    "2007-11-24"
    "RGB RGBA GRAY GRAYA"
    SF-IMAGE "Image" 0
    SF-DRAWABLE "Drawable" 0)

(script-fu-menu-register "script-fu-increase-contrast"
    "<Image>/Script-Fu")