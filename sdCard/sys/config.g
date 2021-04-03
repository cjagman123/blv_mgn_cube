; Configuration file for Duet WiFi (firmware version 3.0 BETA)
; executed by the firmware on start-up
;
; Hand coded - Edward Palisoc
; Deviations from the base BLV design include the following, and need to be addressed where you see *EDP* followed by a number that corresponds and affected by the item changes listed below
;		1 - Three z-axis drives using a Duex5 expansion board
;		2 - Zesty Nimble Extruder
;		3 - Zesty Kyro Water-cooled Heatsink
;		4 - Kinematic Bed support
;		5 - BLTouch Z-Probe
;		6 - Mains voltage heating bed controlled by SSR
;		7 - PT100 RTD temp sensor for the extruder using the Duet daughterboard
;		8 - Andy Gallus' switchgear wiring - this variation includes an emergency stop button that
;			kills line voltage and sets a switch to let the controller board know an emergency stop occured.
;
; -------------------------------------------------------------------
;
; General Global Preferences and critical Drive Configuration Section -  These must come before all else.
G4 P2000													; Hold your Horses.  Add a little time to allow things to settle and complete.
G90  														; send absolute coordinates...
M83  														; ...but relative extruder moves
G21															; Set units to Millimeters
M550 P"EDP" 												; set printer name -  change this to whatever you'd like
M584 X0 Y1 Z2:5:6 E3:4:7:8:9 								; set drive mapping to each axis --- *EDP* - 1 The "Z2:5:6" would be Z2
															; for a standard BLV and binds the drivers to each axis it controls.  Note the
															; M567 commage later.  These are related and connected.  This command must always come
															; before a number of other commands.  Refer to https://duet3d.dozuki.com/Wiki/RepRapFirmware_3_overview

M669 K1														; Select CoreXY mode - New format
;
; -------------------------------------------------------------------
;
; Network Configuration Section
M552 S1 													; enable network
M587 S"YourSSID" P"Password"								; Add a WiFi host network to the rememebred list.
															; Once you connected properly, you can delete this line.
															; Enter the info within the quotes - do not delete the quotes.

M586 P0 S1 													; enable HTTP
M586 P1 S0 													; disable FTP
M586 P2 S0 													; disable Telnet
;
; -------------------------------------------------------------------
;
; Drives - Establish the Drive designation and the direction they turn.
; Validate these settings as a first step.
; If your wiring differs, you can fix the direction here instead of rewiring.
M569 P0 S0													; physical drive 0 goes backwards
M569 P1 S0 													; physical drive 1 goes backwards
M569 P2 S0 													; physical drive 2 goes backwards
M569 P3 S0 													; physical drive 3 goes backwards

M569 P4 S1 													; placeholder for unused drive.  Erratic behavior can occur
															; if unused drivers are not bound to a driver designation.

M569 P5 S0													; *EDP* - 1  Drive 5 goes backwards - added drive for three z-axis design
M569 P6 S0													; *EDP* - 1  Drive 6 goes backwards - added drive for three z-axis design

M671 X-52.5:377.5:377.5 Y162.5:282.5:42.5 S5				; Set up three Z-axis location
															; *EDP* - 1  This tells the Duet the physical location of the center of the leadscrews.
															; for reference the order/sequence of defined coordinate positions MUST correspond to
															; the order of axis drives that was specified above in the M584 gcode 1 - left, 2 - rear right and 3 - front right

M92 X200.00 Y200.00 Z400.00 E2794.48 						; set steps per mm, based on using 0.9 degree steppers for X/Y and 1.8 degree steppers for the Z axis.
															; *EDP* - 2  The Zesty Nimble uses a 30:1 gear reduction
															; so the Extruder steps are *FAR* different.  Use the configurator to get your setting
															; or refer to the base file in the BLV design.

M350 X16 Y16 Z16 E16 I1 									; configure micro-stepping with interpolation
M566 X60000.00 Y60000.00 Z2400.00 E120.00 					; set maximum instantaneous speed changes (mm/min)
M203 X18000.00 Y18000.00 Z1000.00 E1200.00 					; set maximum speeds (mm/min) *EDP*
M201 X1000.00 Y1000.00 Z120.00 E250.00 						; set accelerations (mm/s^2)
M906 X1000 Y1000 Z1000 E800 I30 							; set motor currents (mA) and motor idle factor in per cent
M84 S30  													; Set idle timeout
;
; -------------------------------------------------------------------
;
; Axis Limits
M208 X0 Y0 Z0 S1 											; set axis minima
M208 X310 Y310 Z350 S0 										; set axis maxima
;
; -------------------------------------------------------------------
;
; Endstops

M574 X1 S1 P"xstop"											; X min active high endstop switch
M574 Y2 S1 P"ystop"  										; Y max active high endstop switch
;
; -------------------------------------------------------------------
;
; *EDP* - 5 BLTouch Z-Probe implemented on the Duex5 expansion board
M574 Z1 S2		 											; set endstops controlled by probe
M558 P9 C"zprobe.in" H5 F40000 T8000 						; set Z probe type to bltouch and the dive height + speeds
															; With RRF3, you do not need to disable a heater first
															; all heaters are NOT defined unless specifically done so. Pins are now named, and
															; and identified in the overview.
															; Reference https://duet3d.dozuki.com/Wiki/RepRapFirmware_3_overview
															; If you're not using an expansion board, chance the C variable according to what pin you're going to use.
G31 P500 X28.5 Y-5 Z0.1	 									; set Z probe trigger value, offset and trigger height
G30 S-2			 											; Set the Home Z by probing Z
;
; -------------------------------------------------------------------
;
; Configure Heaters and Sensors - This will be the most involved section.  Be careful here.
M307 H0 A65.3 C100.4 D1.1 V23.6 B0										; disable bang-bang mode for the bed heater and set PWM limit
																		; *EDP* - 6 These PWM settings are for a 120v line voltage heated 750w keenovo
																		; silicone bed. Recommend using first "M307 H0" and then autotuning per Ben's directions.
																		; It's easy and quick. Have the gcode console open on the DWC to see the valuese you'll need.

M308 S0 P"bedtemp" Y"thermistor" A"Bed Temp" T100000 B3950				; Configure bed temperature sensor - This is a standard temp sensor and the typical format
																		; you'll use for most temp sensors.
M143 H0 S120															; set temperature limit for heater 0 to 120C
M307 H1 A892.0 C209.3 D7.1 V23.6 B0
M308 S1 P"spi.cs1" Y"rtd-max31865" A"Main Nozzle Temp"  				; *EDP* - 7 Configure extruder_0 temperature sensor - specific to a PT100 sensor on daughterboard.
																		; refer to https://duet3d.dozuki.com/Wiki/RepRapFirmware_3_overview for pin name nomenclature.
M143 H1 S280                                     						; set temperature limit for heater 1 to 280C
M308 S2 P"e1temp" Y"thermistor" A"Coolant Temp" T10000 B3950 C0 R4700	; *EDP* - 3 Configure Coolant Temp Sensor
																		; This was added to allow me to see my coolant temps.
																		; It is not part of the base BLV build

; Fans
M106 P0 S0 H1 C"Parts Cooler"											; set fan 0. Parts Cooler on Printhead
M106 P1 S1 H2 T15:45 C"Radiator" 										; *EDP* - 3 Set fan 1 to thermistically manage the Radiator fan for water-cooled loop.
;
; -------------------------------------------------------------------
;
; Define Sensors and Fans - Once you configure the heaters and sensors above, you need to now define their use.  This
: commands ALWAYS must be after the commands above, never before.

M950 H0 C"bedheat" T0 										; Define heater 0 (bed heater) - bind the bed_heat pin and Temp Sensor 0 together
															; as defined above as "P0"

M950 H1 C"e0heat" T1 										; Define heater 1 (hot-end E0) - bind the "e0_heat" pin (default first extruder) and Temp Sensor 1
															; together, as defined above as "P1"

M950 F0 C"fan0" Q500										; Define Fan_0 for use - Parts Cooler on Printhead - 4010 fan
M950 F1 C"!fan1" Q25000										; *EDP* - 3 Define Fan_1 for use - Radiator cooling - WC heatsink. - PWM fan
M950 S0 C"duex.pwm1"										; *EDP* - 5 Define GPIO port 0 to heater3 on expansion connector, servo mode - BLTouch Z-Probe
															; you will need to chance the C value to whatever pin you're using to control the probe.  On the BLTouch
															; it will be whatever the Orange/Yellow wire from the BLtouch is connected to.
;
; -------------------------------------------------------------------
;
; Set up the Tools, which combine heaters, fans, and sensors to work as one....Tool.
; This brings together all the definitions and configurations done above.
M563 P0 S"Main Nozzle" D0 H1 F0								; define tool 0. Fan 0 operates with an active hot-end
G10 P0 X0 Y0 Z0 											; set tool 0 axis offsets
G10 P0 R0 S0 												; set initial tool 0 active and standby temperatures to 0C
;
; -------------------------------------------------------------------
;
; Emergency Stop 											*EDP* - 8
M574 P"duex.e6stop" S0  									; Define E6 duex endstop - emergency stop switch condition
M581 P"duex.e6stop" T0  									; Define action to be taken with activation of emergency stop switch
;
; -------------------------------------------------------------------
;
; Miscellaneous
T0 															; select first tool
M501														; Store parameters