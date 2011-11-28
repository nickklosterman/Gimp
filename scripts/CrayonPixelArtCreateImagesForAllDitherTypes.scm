(define (script-fu-crayon-pixel-art-all-dither theImage drawable scale_factor interpolation chosen_palette autolevels)

  (let* (
	 ; calls to PDB functions always return a list. We have
	 ; to pick the first element with "car" explicitely, even
	 ; when the function called returns just one value.
	 (width  (car  (gimp-drawable-width drawable)))
	 (height (car  (gimp-drawable-height drawable)))
	 (new_width    (* width  scale_factor ))
	 (new_height   (* height  scale_factor))

	 (FSDither); (gimp-image-new new_width new_height 0));0 for rgb
	 (FSLBDither); (gimp-image-new new_width new_height 0));0 for rgb
	 (FixedDither); (gimp-image-new new_width new_height 0));0 for rgb
	 (NoDither)
	       )


					;create undo group 
    (gimp-image-undo-group-start theImage)

;apply autoleveling if desired
;this is pretty useless if the image is a gif as typically pure white and pure black are two of the colors in the palette so this does nothing in those cases.
(if (= autolevels TRUE)
    (gimp-levels-stretch theImage)
)

;Scale the Image to blow up the gif so we can see it. this helps to allow for a more pleasing picture to dither. if the image is too small the dithering is awful
(gimp-convert-rgb theImage)
(gimp-image-scale-full theImage new_width new_height interpolation );we don't interpolate when we scale

;Create NO DITHER image
(gimp-edit-named-copy-visible theImage "ImgVisible")
(set! NoDither ( car (gimp-edit-named-paste-as-new "ImgVisible")))
(gimp-display-new NoDither)
(gimp-image-convert-indexed NoDither 0 4 0 FALSE FALSE chosen_palette )

;Create FS DITHER image
(gimp-edit-named-copy-visible theImage "ImgVisible")
(set! FSDither ( car (gimp-edit-named-paste-as-new "ImgVisible")))
(gimp-display-new FSDither)
(gimp-image-convert-indexed FSDither 1 4 0 FALSE FALSE chosen_palette )

;Create FS Low Bleed DITHER image
(gimp-edit-named-copy-visible theImage "ImgVisible")
(set! FSLBDither ( car (gimp-edit-named-paste-as-new "ImgVisible")))
(gimp-display-new FSLBDither)
(gimp-image-convert-indexed FSLBDither 2 4 0 FALSE FALSE chosen_palette )

;Create FIXED DITHER image
(gimp-edit-named-copy-visible theImage "ImgVisible")
(set! FixedDither ( car (gimp-edit-named-paste-as-new "ImgVisible")))
(gimp-display-new FixedDither)
(gimp-image-convert-indexed FixedDither 3 4 0 FALSE FALSE chosen_palette )


; empty the buffer
( gimp-buffer-delete "ImgVisible")

		;create undo group 
(gimp-image-undo-group-end theImage)
(gimp-displays-flush)
)

)
;I was receiving a "eval unbound variable error" because I had mistyped my variable
;I was receiving an "illegal token" error because I had deleted the "let" statement and didn't realize that it had a matching parens way at the end of the script before we register the script ...this also might manifest as a "mismatched or unmatched parens" error

(script-fu-register "script-fu-crayon-pixel-art-all-dither"
                    _"<Image>/Script-Fu/Pixel/Crayon-Pixel-Art-All-Dither"
                    "Processes an image creating a pixelized image given a palette. Assumes input is a indexed gif."
                    "InkyDinky"
                    "InkyDinky"
                    "2011 11 28"
                    "*"
                    SF-IMAGE        "Image"     0
                    SF-DRAWABLE     "Drawable"  0
		    ;SF-ENUM       "Dither"      '("DitherType" "GIMP_FS_DITHER") google gimp enum types
;		    SF-OPTION       "Dither"      '("None" "Floyd-Steinberg" "Floyd-Steinberg Low Bleed" "Fixed")
		    SF-ADJUSTMENT "Scale Factor" (list 2 0 10 1 2 0 SF-SLIDER )
		    SF-OPTION       "Interpolation"      '("None" "Linear" "Cubic" "Sinc (Lanczos3)");I wish I knew how to use the enum types but not worth the hassle when can use options and works right away. http://developer.gimp.org/api/2.0/libgimpbase/libgimpbase-gimpbaseenums.html
		    SF-PALETTE    "Palette"            "RGBY"
		    SF-TOGGLE     "Auto-level image?"             TRUE
                    )

