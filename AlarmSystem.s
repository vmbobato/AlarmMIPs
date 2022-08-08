			area project, code, readonly
RS			equ 0x20 ;3.5
RW 			equ 0x40 ;3.6
EN			equ 0x80 ;3.7
			export __main
			
__main		proc
			
			;outputs:
			;red LED P5.4
			;green LED P5.5
			;buzzer P5.6
			
			;inputs:
			;swicth key P5.2 (green cable switch)
			;swicth on/off P5.0
			;sensor P5.1
			
			;r0: Port 3 (RS, RW, EN pins)
			;r1: Port 4 (LCD Data pins, function uses r4)
			;r2: Port 5 (Inputs and Outputs)
			
			BL LCDInit
			BL swCfg
			
repeat		mov r5, #0x20
			strb r5, [r2, #0x02] ; high bit to green and low to red (disarmed)
			;lcd alarm: off
			;
			mov r4, #0x01
			BL LCDCommand
			mov r4, #0x38
			BL LCDCommand
			mov r4, #0x0E
			BL LCDCommand
			mov r4, #0x02
			BL LCDCommand
			
			mov r4, #"A"
			BL LCDData
			mov r4, #"l"
			BL LCDData
			mov r4, #"a"
			BL LCDData
			mov r4, #"r"
			BL LCDData
			mov r4, #"m"
			BL LCDData
			mov r4, #" "
			BL LCDData
			mov r4, #"O"
			BL LCDData
			mov r4, #"f"
			BL LCDData
			mov r4, #"f"
			BL LCDData
			;
			ldrb r6, [r2, #0x00] ; check on/off
			and r6, #0x01		 ;
			cmp r6, #0			 ;
			beq repeat
			
keyCheck1	ldrb r6, [r2, #0x00]
			and r6, #0x04
			cmp r6, #0
			bne keyCheck1
			
IRcheck1	ldrb r6, [r2, #0x00]
			and r6, #0x02
			cmp r6, #0
			beq IRcheck1
			
armed		mov r5, #0x10    ; high bit to red
			strb r5, [r2, #0x02]
			mov r4, #0x01
			BL LCDCommand
			;write "alarm: On:" LCD
			mov r4, #0x38
			BL LCDCommand
			mov r4, #0x0E
			BL LCDCommand
			mov r4, #0x02
			BL LCDCommand
			
			mov r7, #"A"
			BL LCDData
			mov r7, #"l"
			BL LCDData
			mov r7, #"a"
			BL LCDData
			mov r7, #"r"
			BL LCDData
			mov r7, #"m"
			BL LCDData
			mov r7, #" "
			BL LCDData
			mov r7, #"O"
			BL LCDData
			mov r7, #"n"
			BL LCDData
			
keyCheck2	ldrb r6, [r2, #0x00]    
			and r6, #0x04
			cmp r6, #0
			bne repeat
			
IRcheck2	ldrb r6, [r2, #0x00]
			and r6, #0x02
			cmp r6, #0
			bne armed
			;lcd clear
			;
			mov r4, #0x01
			BL LCDCommand
			mov r4, #0x38   ;2 lines     ***Every time we need to write on LCD???
			BL LCDCommand
			mov r4, #0x0E	;display on and cursor on
			BL LCDCommand
			;
			;LCD display "intruder"
			mov r7, #"I"
			BL LCDData
			mov r7, #"n"
			BL LCDData
			mov r7, #"t"
			BL LCDData
			mov r7, #"r"
			BL LCDData
			mov r7, #"u"
			BL LCDData
			mov r7, #"d"
			BL LCDData
			mov r7, #"e"
			BL LCDData
			mov r7, #"r"
			BL LCDData
			mov r7, #"!"
			BL LCDData
			
alarmRep	mov r5, #0x40   ;buzzer
			strb r5, [r2, #0x02]
			BL blink
			
keyCheck3	ldrb r6, [r2, #0x00]
			and r6, #0x04
			cmp r6, #0
			bne LCDclear
			
			
onOff		ldrb r6, [r2, #0x00]
			and r6, #0x01
			cmp r6, #0
			beq LCDclear
			b alarmRep
			
			endp
			
LCDclear	function
			;clear lcd
			mov r4, #0x01
			BL LCDCommand
			b repeat
			BX LR
			endp

swCfg		function
			ldr r2, =0x40004C40 ;P5
			mov r3, #0xF0    ; 1 1 1 1 0 0 0 0 (4,5,6,7 as op)
			strb r3, [r2, #0x04] ;PxDIR P1
			mov r3, #0
			strb r3, [r2, #0x02] ;Pull-Down
			mov r3, #0x0F
			strb r3, [r2, #0x06] ;PxREN enabled for pins 0,1,2,3
			BX lr
			endp
			
LCDInit		function
			ldr r0, =0x40004C20 ;Port 3
			ldr r1, =0x40004C21 ;Port 4
			
			mov r4, #0xE0
			strb r4, [r0, #0x04]
			mov r4, #0xFF
			strb r4, [r1, #0x04]
			
			push {LR}
			mov r4, #0x38
			BL LCDCommand
			mov r4, #0x0E
			BL LCDCommand
			mov r4, #0x01
			BL LCDCommand
			mov r4, #0x06
			BL LCDCommand
			pop {LR}
			BX LR
			endp
				
LCDCommand	function
			strb r4, [r1, #0x02]
			mov r4, #EN
			strb r4, [r0, #0x02]
			
			push {LR}
			;BL delay
			pop {LR}
			mov r4, #0x00
			strb r4, [r0, #0x02]
			
			BX LR
			endp
				
LCDData		function
			strb r7, [r1, #0x02]
			mov r4, #RW
			mvn r4, r4
			strb r4, [r0, #0x02]
			push {LR}
			;BL delay
			pop {LR}
			
			mov r4, #RS
			strb r4, [r0, #0x02]
			BX LR
			endp
			
blink		function
			mov r5, #0x10
			strb r5, [r2, #0x02]
			;BL delayLED
			mov r5, #0
			strb r5, [r2, #0x02]
			;BL delayLED
			BX LR
			endp
			
			end
			
