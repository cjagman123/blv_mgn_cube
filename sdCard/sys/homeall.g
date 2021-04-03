; homeall.g
; called to home all axes
;
G91                     ; relative positioning
G1 Z5 F2000 S2          ; lift Z relative to current position
G1 H1 X-355 Y355 F4000  ; move quickly to X or Y endstop and stop there (first pass)
G1 H1 X-355             ; home X axis
G1 H1 Y355              ; home Y axis
G1 H2 X5 Y-5 F3000      ; go back a few mm
G1 H1 X-355 F360        ; move slowly to X axis endstop once more (second pass)
G1 H1 Y355 F360         ; then move slowly to Y axis endstop
G90                     ; absolute positioning
G1 X152 Y166.4 F4000 	; go to first bed probe point and home Z
G30                     ; home Z by probing the bed
G32 S2
						; Uncomment the following lines to lift Z after probing
G91                    ; relative positioning
G1 S2 Z5 F100          ; lift Z relative to current position
G90                    ; absolute positioning