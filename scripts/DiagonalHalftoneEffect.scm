(define (script-fu-diagonal_halftone_effect theImage drawable lineSpacing blackPullOut angle overSample)

  
					;create undo group 
  (gimp-undo-push-group-start theImage)

					;(plug-in-newsprint run-mode image drawable cell-width colorspace k-pullout gry-ang gry-spotfn red-ang red-spotfn grn-ang grn-spotfn blu-ang blu-spotfn oversample)
;  (plug-in-newsprint RUN-NONINTERACTIVE theImage drawable lineSpacing 2 blackPullOut angle 1  0.0 0  0.0 0  0.0 0  overSample )

; here all the channels use the same spot function. Not sure if it would be worthwhile to do it differently. As far as stenciling goes, it doesn't really seem to matter since you are discarding the colors from the other channels.
  (plug-in-newsprint RUN-NONINTERACTIVE theImage drawable lineSpacing 2 blackPullOut angle 1  angle 1  angle 1 angle 1  overSample )

					; all but the NO-DITHER MONO-PALETTE options are ignored for what I want. Just need a valid value so it doesn't bitch
  (gimp-image-convert-indexed theImage NO-DITHER MONO-PALETTE 0 0 0 "Coffee")

					;close undo group 
  (gimp-undo-push-group-end theImage)

  (gimp-displays-flush)
  )

(script-fu-register "script-fu-diagonal_halftone_effect"
                    _"<Image>/Script-Fu/Diagonal-Halftone-Effect"
                    "Processes an image creating a diagonal halftone effect from the black channel. The result is a B/W halftoned image ideal for stenciling."
                    "InkyDinky"
                    "InkyDinky"
                    "2015 04 19"
                    "*"
                    SF-IMAGE        "Image"     0
                    SF-DRAWABLE     "Drawable"  0
		    SF-ADJUSTMENT "Cell Size" (list 10 3 100 1 10 0 SF-SLIDER )
		    SF-ADJUSTMENT "Black Pull Out (higher gives more weight to black)" (list 100 0 100 1 10 0 SF-SLIDER )
		    SF-ADJUSTMENT "Angle" (list 45 -90 90 1 10 0 SF-SLIDER )
		    SF-ADJUSTMENT "Oversample (higher is smoother lines/less jaggies; > 3 doesn't get you much more)" (list 1 1 15 1 2  0 SF-SLIDER )
                    )
