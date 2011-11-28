;
; Script-Fu template, fill in the blanks and have fun   :)
;
; (C) 2004-2009 Simon Budig <simon@gimp.org>
;
; This template is in the public domain, I'd like to encourage you to
; place your script under the GPL or LGPL.
;

; GIMP uses the tiny-scheme interpreter. Please look at its documentation
; for the builtin functions.

; The Gimp-specific functions are made available to scripts via the
; PDB (Procedural Data Base). You can look up functions in the GIMP
; with the DB-Browser, available in the Toolbox->Xtns menu.
;
; Important: Constants in the PDB-Browser have a different name than
; in Script-Fu. Omit the "GIMP_" prefix and make dashes from the
; underscores and to get the script fu constants.
; For example: GIMP_CHANNEL_OP_REPLACE becomes CHANNEL-OP-REPLACE

; Lets start the actual script. First define the function that does the
; actual work. Choose a name that does not clash with other names in the
; PDB. It starts with "script-fu" by convention.

; Functions that should be registered in the images context menu have
; to take the image and current drawable as the first two arguments.

(define (script-fu-template image drawable color)

        ; the let* environment allows you to define local variables.
	; It is considered good style to define all variables used
	; in the script here, so that the global namespace does not
	; get polluted. This will be enforced in the next generation
	; of script-fu.

	(let* (
		; calls to PDB functions always return a list. We have
		; to pick the first element with "car" explicitely, even
		; when the function called returns just one value.

		(width  (car  (gimp-drawable-width drawable)))
		(height (car  (gimp-drawable-height drawable)))
		(x0     (car  (gimp-drawable-offsets drawable)))
		(y0     (cadr (gimp-drawable-offsets drawable)))
		;        ^^^^ - here we pick the second element of the
		;               returned list...
	      )

            ; since we tweak the foreground color in our script and
            ; might konfuse our user if the color in the GUI would change
            ; we push a copy of the working context on an gimp internal
            ; stack and later restore it with -pop)

            (gimp-context-push)

	    ; Ok, we are about to do multiple actions on the image, so
	    ; when the user wants to undo the effect he should not have
	    ; to wade through lots of script-generated steps. Hence
	    ; we create a undo group on our image.

	    (gimp-image-undo-group-start image)

	    ; Here you'd implement your own ideas. For now we
	    ; just select and fill a rectangle centered on the
	    ; currently active drawable.

	    (gimp-rect-select image
			      (+ x0 (* width 0.25))
			      (+ y0 (* height 0.25))
			      (* width 0.5)
			      (* height 0.5)
			      CHANNEL-OP-REPLACE
			      0 0)

	    (gimp-context-set-foreground color)

	    (gimp-edit-fill drawable FOREGROUND-FILL)

	    ; We are done with our actions. End the undo group
	    ; opened earlier. Be careful to properly end undo
	    ; groups again, otherwise the undo stack of the image
	    ; is messed up.

	    (gimp-image-undo-group-end image)

	    ; Now we restore the context saved earlier again.

	    (gimp-context-pop)

	    ; finally we notify the UI that something has changed.

	    (gimp-displays-flush)
	)
)


; Here we register the function in the GIMPs PDB.
; We have just one additional parameter to the default parameters:
; the user can choose the color for the script. For more available
; script-fu user interface elements see the "test-sphere.scm" script.

(script-fu-register "script-fu-template"
		    "Rectangle..."
		    "script-fu template (right now renders just a rectangle)"
		    "Simon Budig  <simon@gimp.org>"
		    "Simon Budig"
		    "2009-01-08"
		    "RGB* GRAY*"
		    SF-IMAGE "Input Image" 0
		    SF-DRAWABLE "Input Drawable" 0
		    SF-COLOR "Rectangle Color" '(10 80 256)
)

(script-fu-menu-register "script-fu-template"
                         "<Image>/Script-Fu/Render")
