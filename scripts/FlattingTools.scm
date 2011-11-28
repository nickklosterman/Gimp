;flattingtools.scm
; by Rob Antonishen
; http://ffaat.pointclark.net

; Version 1.3 (20090211)

; Changes:
; V1.3 - Change the search logic to speed it up in some cases.
;      - Converted to channel opes as they are faster

; Description
; will fill each separate area with a different coulour, either randomly, or from a selected palette

; License:
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version. 
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; The GNU Public License is available at
; http://www.gnu.org/copyleft/gpl.html

(define (script_fu_Flatting img inLayer)

(let*
	(
	(width (car (gimp-image-width img)))
	(height (car (gimp-image-height img)))
)
	;  it begins here
	(gimp-context-push)
	(gimp-image-undo-group-start img)
	;logging
	;(gimp-message-set-handler ERROR-CONSOLE)
	;(gimp-message-set-handler CONSOLE)
	;(gimp-message-set-handler MESSAGE-BOX)
	;or start GIMP wwith "gimp --console-messages" to spawn a console box
	;then use this:
	;(gimp-message "foobar") 

	;testing for functions defined
	;(if (defined? 'plug-in-shift) (gimp-message "It Exists") (gimp-message "Doesnt Exist"))

	(gimp-by-color-select inLayer (list 0 0 0) 0 CHANNEL-OP-REPLACE FALSE TRUE 0.5 FALSE)
	
	(while (= (car (gimp-selection-is-empty img)) FALSE)
	(plug-in-dilate RUN-NONINTERACTIVE img inLayer 1 HISTOGRAM-VALUE 1.0 7 0 255)
	(gimp-by-color-select inLayer (list 0 0 0) 0 CHANNEL-OP-REPLACE FALSE TRUE 0.5 FALSE)
	)
	
	;done
	(gimp-image-undo-group-end img)
	(gimp-progress-end)
	(gimp-displays-flush)
	(gimp-context-pop)
)
)

(script-fu-register "script_fu_Flatting"
					"<Image>/Filters/Flatting/Flatten"
					"Flattens an image that has been multicoloured"
					"Rob Antonishen"
					"Rob Antonishen"
					"Jan 2009"
					"RGB* GRAY*"
					SF-IMAGE      "image"      0
					SF-DRAWABLE   "drawable"   0						
)


(define (script_fu_MultiFill img inLayer inColour inThresh inRandom inPalette inIgnoreSize inFlagSize inFlagColour inHowCheck inMakeCopy inFlatten)

;helper function to compare two lists . .i.e. colours
(define (listeql? list1 list2)
(let* ((result TRUE)
		(counter (length list1)))
		(if (<> (length list1) (length list2))
		(set! result FALSE)
		(while (> counter 0)
			(set! counter (- counter 1))
			(if (<> (list-ref list1 counter) (list-ref list2 counter))
				(set! result FALSE)
			)
		)
		)   
		result
)
)

(let*
	(
	(width (car (gimp-image-width img)))
	(height (car (gimp-image-height img)))
	(bounds 0)
	(countX 0)
	(selectionValue 0)
	(numcolours (car (gimp-palette-get-colors inPalette)))
	(palettecount 0)
	(nextcolour 0)
	(layercopy 0)
	(temp 0)
	(channel 0)
	(lastY 0)
	)
	;  it begins here
	(gimp-context-push)
	(gimp-image-undo-group-start img)
	(gimp-image-undo-disable img)
	;logging
	;(gimp-message-set-handler ERROR-CONSOLE)
	;(gimp-message-set-handler CONSOLE)
	;(gimp-message-set-handler MESSAGE-BOX)
	;or start GIMP wwith "gimp --console-messages" to spawn a console box
	;then use this:
	;(gimp-message "foobar") 

	;testing for functions defined
	;(if (defined? 'plug-in-shift) (gimp-message "It Exists") (gimp-message "Doesnt Exist"))

	(if (= inMakeCopy TRUE)
		(begin
		(set! layercopy (car (gimp-layer-copy inLayer (car (gimp-drawable-has-alpha inLayer)))))
		(gimp-image-add-layer img layercopy -1)
		(gimp-layer-set-mode layercopy MULTIPLY-MODE)
		(gimp-image-set-active-layer img inLayer)
		)
	)
	
	;  Change to pure B & W
	(gimp-by-color-select inLayer inColour inThresh CHANNEL-OP-REPLACE FALSE FALSE 0 FALSE)
	(gimp-context-set-foreground (list 255 255 255))
	(gimp-edit-fill inLayer FOREGROUND-FILL)
    ;Save it to a channel
    (set! channel (car (gimp-selection-save img)))

	(gimp-selection-invert img)
	(gimp-context-set-foreground (list 0 0 0))
	(gimp-edit-fill inLayer FOREGROUND-FILL)
     
	;select white
	(gimp-by-color-select inLayer (list 255 255 255) 0 CHANNEL-OP-REPLACE FALSE FALSE 0 FALSE)
	
	(while (= (car (gimp-selection-is-empty img)) FALSE)
		(set! bounds (gimp-selection-bounds img))
		;get start the loop looking for this colour)
		
		(if (<> lastY (caddr bounds)) ; there is a change in Y, get the new boundary
		(begin
		(set! countX (cadr bounds)) ; x1
		  (set! lastY (caddr bounds))
		)
		)

		(set! lastY (caddr bounds))
		
		(set! selectionValue (car (gimp-selection-value img countX (caddr bounds))))
	
		;find a bg area
		(while (< selectionValue 255) ; while not white
			(set! countX (+ countX 1))
			(set! selectionValue (car (gimp-selection-value img countX (caddr bounds))))
        )
	
		;select and fill
		(gimp-fuzzy-select inLayer countX (caddr bounds) 0 CHANNEL-OP-REPLACE FALSE FALSE 0 FALSE)
		(set! bounds (gimp-selection-bounds img))
		
		(if (or (and (= inHowCheck 0) (<= (- (cadddr bounds) (cadr bounds)) inIgnoreSize) (<= (- (list-ref bounds 4) (caddr bounds)) inIgnoreSize)) ; X and Y size
		        (and (= inHowCheck 1) (<= (cadddr (gimp-histogram inLayer HISTOGRAM-VALUE 0 255)) inIgnoreSize))) ; area
			(gimp-context-set-foreground (list 0 0 0)) ; fill with black - will be ignored in flatten step
			(if (or (and (= inHowCheck 0) (> (- (cadddr bounds) (cadr bounds)) inFlagSize) (> (- (list-ref bounds 4) (caddr bounds)) inFlagSize)) ; X and Y size
				(and (= inHowCheck 1) (> (cadddr (gimp-histogram inLayer HISTOGRAM-VALUE 0 255)) inFlagSize))) ; area
				(begin
				(if (= inRandom TRUE)
					(begin
					(set! nextcolour (list (+ (rand 254) 1) (+ (rand 254) 1) (+ (rand 254) 1))) ;Random colour - not B, W or flagcoulor
					(while (= (listeql? nextcolour inFlagColour) TRUE)
						(set! nextcolour (list (+ (rand 254) 1) (+ (rand 254) 1) (+ (rand 254) 1)))
					)
					)
					(begin
					(set! nextcolour (car (gimp-palette-entry-get-color inPalette palettecount))) ; next palette colour, - not B, W or flagcoulor
					(while (or (= (+ (car nextcolour) (cadr nextcolour) (caddr nextcolour)) 765)
							(= (+ (car nextcolour) (cadr nextcolour) (caddr nextcolour)) 0)
							(= (listeql? nextcolour inFlagColour) TRUE))
					    (set! palettecount (modulo (+ palettecount 1) numcolours)) ; increment palette
						(set! nextcolour (car (gimp-palette-entry-get-color inPalette palettecount)))
					)			
					
					(set! palettecount (modulo (+ palettecount 1) numcolours)) ; increment palette
					)
				)
				(gimp-context-set-foreground nextcolour)
				)
			(gimp-context-set-foreground inFlagColour)
			)
		)
		(gimp-edit-fill inLayer FOREGROUND-FILL)
		(gimp-displays-flush)
        (gimp-channel-combine-masks channel (car (gimp-image-get-selection img)) CHANNEL-OP-SUBTRACT 0 0)
        (gimp-selection-load channel)
	)

	(gimp-selection-none img)
	
	(if (= inFlatten TRUE)
		(begin
		(gimp-by-color-select inLayer (list 0 0 0) 0 CHANNEL-OP-REPLACE FALSE TRUE 0.5 FALSE)
	
		(while (= (car (gimp-selection-is-empty img)) FALSE)
			(plug-in-dilate RUN-NONINTERACTIVE img inLayer 1 HISTOGRAM-VALUE 1.0 7 0 255)
			(gimp-by-color-select inLayer (list 0 0 0) 0 CHANNEL-OP-REPLACE FALSE TRUE 0.5 FALSE)
		)
		)
	)
	
	(gimp-image-remove-channel img channel)
	
	;done
    (gimp-image-undo-enable img)
	(gimp-image-undo-group-end img)
	(gimp-progress-end)
	(gimp-displays-flush)
	(gimp-context-pop)
)
)

(script-fu-register "script_fu_MultiFill"
					"<Image>/Filters/Flatting/MultiFill..."
					"Fills every separate area with a different colour from the palette."
					"Rob Antonishen"
					"Rob Antonishen"
					"Dec 2008"
					"RGB* GRAY*"
					SF-IMAGE      "image"      0
					SF-DRAWABLE   "drawable"   0
					SF-COLOR      "MultiFill Colour"       "white"
					SF-ADJUSTMENT "Colour Threshold"       (list 16 0 255 1 10 0 SF-SLIDER)
					SF-TOGGLE     "Use Random Colours or"  FALSE
					SF-PALETTE    "Choose Fill Palette"    "Default"
					SF-ADJUSTMENT "Ignore Areas <="        (list 3 0 255 1 10 1 SF-SLIDER)
					SF-ADJUSTMENT "Flag Areas <="          (list 10 0 255 1 10 1 SF-SLIDER)
					SF-COLOR      "Flag Colour"            "magenta"
					SF-OPTION     "Area Size Check Method" (list "Width & Height" "Area")					
					SF-TOGGLE     "Copy Layer First"       TRUE
					SF-TOGGLE     "Flatten After"	       TRUE
)