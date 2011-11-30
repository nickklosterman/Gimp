(define (script-fu-crayon-pixel-art theImage drawable dithertype scale_factor interpolation chosen_palette autolevels)

  (let* (
	 ; calls to PDB functions always return a list. We have
	 ; to pick the first element with "car" explicitely, even
	 ; when the function called returns just one value.
	 (width  (car  (gimp-drawable-width drawable)))
	 (height (car  (gimp-drawable-height drawable)))
	 (new_width    (* width  scale_factor ))
	 (new_height   (* height  scale_factor))
	 
	       )


					;create undo group 
    (gimp-image-undo-group-start theImage)

;    (gimp-image-scale-full theImage (* (gimp-image-width theImage) scale_factor) (* (gimp-image-height theImage) scale_factor)  0);can't do this :(

    (gimp-image-convert-rgb theImage);need to set to rgb so interpolation takes effect and need it so can convert to indexed as well.
    (gimp-image-scale-full theImage new_width new_height interpolation );we don't interpolate when we scale






;apply autoleveling if desired
;this is pretty useless if the image is a gif as typically pure white and pure black are two of the colors in the palette so this does nothing in those cases.
(if (= autolevels TRUE)
    (gimp-levels-stretch theImage))

;apply dither
(if (= dithertype 1)
    (gimp-drawable-set-name drawable "FloydSteinbergDither"))
(if (= dithertype 2)
    (gimp-drawable-set-name drawable "FloydSteinbergLowBleedDither"))
(if (= dithertype 3)
    (gimp-drawable-set-name drawable "FixedDither"))

(gimp-image-convert-indexed theImage dithertype 4 0 FALSE FALSE chosen_palette )

		;create undo group 
(gimp-image-undo-group-end theImage)
(gimp-displays-flush)
)

)
;I was receiving a "eval unbound variable error" because I had mistyped my variable
;I was receiving an "illegal token" error because I had deleted the "let" statement and didn't realize that it had a matching parens way at the end of the script before we register the script ...this also might manifest as a "mismatched or unmatched parens" error

(script-fu-register "script-fu-crayon-pixel-art"
                    _"<Image>/Script-Fu/Pixel/Crayon-Pixel-Art"
                    "Processes an image creating a pixelized image given a palette. Assumes input is a indexed gif."
                    "InkyDinky"
                    "InkyDinky"
                    "2011 11 28"
                    "*"
                    SF-IMAGE        "Image"     0
                    SF-DRAWABLE     "Drawable"  0
		    ;SF-ENUM       "Dither"      '("DitherType" "GIMP_FS_DITHER") google gimp enum types
		    SF-OPTION       "Dither"      '("None" "Floyd-Steinberg" "Floyd-Steinberg Low Bleed" "Fixed")
		    SF-ADJUSTMENT "Scale Factor" (list 2 0 10 1 2 0 SF-SLIDER )
		    SF-OPTION       "Interpolation"      '("None" "Linear" "Cubic" "Sinc (Lanczos3)");I wish I knew how to use the enum types but not worth the hassle when can use options and works right away. http://developer.gimp.org/api/2.0/libgimpbase/libgimpbase-gimpbaseenums.html
		    SF-PALETTE    "Palette"            "RGBY"
		    SF-TOGGLE     "Auto-level image?"             TRUE
                    )

