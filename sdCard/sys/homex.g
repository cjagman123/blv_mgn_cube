; homex.g
; called to home the X axis
;
G91					; relative positioning
G1 Z5 F1000 S2		; lift Z relative to current position
G1 H1 X-355 F4000	; move quickly to X axis endstop and stop there (first pass)
G1 H2 X5 Y5 F3000	; go back a few mm
G1 H1 X-355 F360	; move slowly to X axis endstop once more (second pass)
G90					; absolute positioning