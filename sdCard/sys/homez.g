; homez.g
; called to home the Z axis
;
G91						; relative positioning
G1 Z5 F1000 S2			; lift Z relative to current position
G90						; absolute positioning
G1 X162.5 Y162.5 F6000	; go to first probe point
G30						; home Z by probing the bed

; Uncomment the following lines to lift Z after probing
G91						; relative positioning
G1 S2 Z5 F100			; lift Z relative to current position
G90						; absolute positioning