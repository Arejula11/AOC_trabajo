		AREA datos,DATA
;vuestras variables y constantes
reloj DCD 0 ;contador de centesimas de segundo
max DCD 8 ;velocidad de movimiento (en centesimas s.)
cont DCD 0 ;instante siguiente movimiento
dirx DCB 0 ;direccion mov. caracter ‘H’ (-1 izda.,0 stop,1 der.)
diry DCB 0 ;direccion mov. caracter ‘H’ (-1 arriba,0 stop,1 abajo)
fin DCB 0 ;indicador fin de programa (si vale 1)

VICBaseEnabl	EQU 0xFFFFF000			;base para activar IRQ
IntEnableOffset	EQU 0x10				;selecciona activar IRQ4
IRQ4_Index 	EQU 4			   	;Nº de IRQ del Timer
IRQ7_Index  EQU 7

VICIntEnable 	EQU 0xFFFFF010 
VICIntEnClr 	EQU 0xFFFFF014			;desactivar IRQs (solo bits 1)

VICVectAddr0	EQU 0xFFFFF100	
VICVectAddr		EQU 0xFFFFF030
	
T0_IR	 EQU 0xE0004000

I_Bit	 EQU 0x80

RDAT 				EQU 0xE0010000 ;reg. datos teclado UART1

IOSET				EQU 0xE0028004 ;reg. datos GPIO (activar bits)
IOCLR 			EQU 0xE002800C ;reg. datos GPIO (desact. bits)

reloj_var	DCD 0
tecl_var	DCD 0
	
FILAS 		EQU 16
COLUMNAS 	EQU 32
filabajo	DCD 0
teclado		DCD 0


i_pantalla 	EQU 0x40007E00
f_pantalla 	EQU 0x40007FFF

carretera EQU '#'


		AREA codigo,CODE
		EXPORT inicio			; forma de enlazar con el startup.s
		IMPORT srand			; para poder invocar SBR srand
		IMPORT rand				; para poder invocar SBR rand
inicio	; se recomienda poner punto de parada (breakpoint) en la primera
		; instruccion de código para poder ejecutar todo el Startup de golpe
 ;programar RSI_IRQ4 -> RSI_reloj
 	ldr r0, =VICVectAddr0
	ldr r1, =RSI_reloj
	ldr r2, =IRQ4_Index

	str r1, [r0, r2, LSL#2]

	ldr r0, =VICIntEnable
	ldr r1, [r0]
	orr r1, r1, #1<<IRQ4_Index

	str r1, [r0]

	
 ;programar RSI_IRQ7 -> RSI_teclado
			LDR r0,=VICVectAddr0
			LDR r1,=tecl_var
			mov r2,#IRQ7_Index
			ldr r3,[r0,r2,LSL #2]
			str r3,[r1]

			LDR r1,=RSI_teclado
			str r1,[r0,r2,LSL #2]


	
 ;activar IRQ4,IRQ7
	LDR r0,=VICIntEnable 
	mov r1,#0x90
	str r1,[r0]
	 
 ;dibujar pantalla inicial
	bl srand
	LDR r0,=i_pantalla
	mov r1, #FILAS
	
	mov r5, #COLUMNAS
	sub r1,r1,#1
	mul r4, r1, r5
	mov r2, #'H'
	add r4, r0,r4
	strb r2, [r4, #12]!
	mov r9, r4
	mov r1,#' '
	LDR r2,=f_pantalla
for2 cmp r0, r2
	bgt fin_for2
	strb r1,[r0]
	
	add r0, r0, #1
	b for2
fin_for2
	ldr r1,=carretera
	LDR r0,=i_pantalla
for cmp r0, r2
	bgt fin_for
	strb r1,[r0,#8]!
	strb r1,[r0,#8]!
	add r0, r0, #16
	b for
fin_for	
while	LDR r0,=fin
	ldrb r0,[r0]
	cmp r0, #0
	bne fin_while
	
vueltaretardo	LDR r4, =cont
	;push {r2}
	ldr r2, [r4]
	LDR r3, =max
	ldr r3,[r3]
	add r2, r2, r3

retardo	LDR r1, =reloj
	ldr r1,[r1]
		LDR r5,=dirx
	LDR r6,=diry
	ldrsb r5,[r5]
	ldrsb r6,[r6]
	add r10, r9, r5
	sub r10, r10, r6, LSL#5
	ldrb r8,[r10]
	cmp r8, #'#'
	bne poscorrect
termin	LDR r8,=fin
	mov r0,#1 
	strb r0,[r8]
	b while
poscorrect mov r7, #'H'
	strb r7,[r10]
	cmp r10, r9
	beq nomove
	mov r8,#' '
	strb r8,[r9]
	strb r7,[r10]
	mov r9, r10
	LDR r5,=dirx
	LDR r6,=diry
	mov r8, #0
	strb r8,[r5]
	strb r8,[r6]
nomove	cmp r1, r2
	bge fin_retardo
	b retardo
fin_retardo
	sub r10, r10, #32
	ldrb r10, [r10]
	cmp r10,#'#'
	beq termin
	;LDR r4, =cont
	;add r2,r2, r3
	;pop {r2}
	str r2,[r4]
	
	LDR r0, =i_pantalla
	mov r1, #FILAS
	sub r1, r1, #1
	mov r2, #0
	mov r3, #0
	mov r5, #COLUMNAS
	mul r4, r1, r5
	mov r7, #COLUMNAS
	sub r7, r7, #1
for_abajo cmp r2, r7
	bge fin_for_abajo
	add r4, r4, #1
	ldrb r5,[r0, r4]
	cmp r5, #'#'
	moveq r5,#' '
	strb r5,[r0, r4]
	add r2, r2, #1
	b for_abajo
fin_for_abajo

	sub r1, r1, #1 ;r1= filas -2
	mov r2, #0
	;mov r3, #0
	mov r5, #COLUMNAS
	mul r4, r1, r5 ; r4 = filas*columnas
	mov r7, #COLUMNAS
	sub r7, r7, #1
for_fil	cmp r1, #0
	blt fin_for_fil
for_mover cmp r2, r7
	bgt fin_for_mover
	
	ldrb r5,[r0, r4]
	cmp r5, #'#'
	bne suma
	mov r5,#' '
	strb r5,[r0, r4]
	mov r5,#'#'
	add r4,r4,#32
;	add r7, r0, r4
;	ldrb r7,[r7, #32]
;	cmp r7,#'H'
;	beq termin
;	LDR r8,=fin
;	mov r0,#1 
;	strb r0,[r8]
;	b while
	strb r5,[r0, r4]
	sub r4,r4,#32
	mov r6, r4
suma	add r2, r2, #1
	add r4, r4, #1
	b for_mover
fin_for_mover
	;add r4,r4, #1
	mov r2, #0
	sub r1, r1, #1
	sub r4, r4, #64
	
	
	b for_fil


fin_for_fil
	
	sub sp, sp, #4
	push {r3}
	bl rand 
	pop {r3}
	and r3, #7
	cmp r3, #2
	movle r3, #-1
	ble fin_cmp
	cmp r3, #4
	movle r3, #0
	movgt r3, #1
fin_cmp	
	mov r4, #'#'
	cmp r6, #31
	moveq r3, #-1
	cmp r6, #8
	moveq r3, #1
	add r3, r3, r6
	strb r4, [r0, r3]
	sub r3, r3, #8
	strb r4, [r0, r3]
	;b vueltaretardo
	

	
	b while
fin_while

;	mov r1, #FILAS
;	sub r1, r1, #1
;for_i	cmp r1, #0
;	blt fin_for_i
;	mov r2, #0
;for_j	cmp r2, #COLUMNAS
;	bge fin_for_j
	
	
 ;bucle ;mientras fin==0
 ; para cada elemento movil
 ; si toca mover elemento
 ; calcular instante siguiente movimiento
 ; borrar elemento anterior
 ; calcular nueva posicion (dirx) elemento
 ; dibujar nuevo elemento
 ; fin_si
 ; fin_para
 ; si toca añadir elemento movil
 ; calcular instante siguiente aparicion
 ; calcular instante siguiente movimiento
 ; generar posicion inicial
 ; dibujar nuevo elemento movil
 ; fin_si
 ;fin_mientras
 ;desactivar IRQ4,IRQ7
 ;desactivar RSI_reloj
 	ldr r0, =VICIntEnClr
	eor r1, r1, r1
	ldr r1, [r0]  ;haria falta?
	orr r1, r1, #16		;)
	
	str r1, [r0]
 ;desactivar RSI_teclado
 LDR r0,=VICIntEnClr 
			mov r1,#2_10000000 
			str r1,[r0] 
			LDR r0,=VICVectAddr0
			LDR r1,=tecl_var
			ldr r1,[r1]
			mov r2,#7
			str r1,[r0,r2,LSL #2]
bfin b bfin

RSI_reloj ;Rutina de servicio a la interrupcion IRQ4 (timer 0)
 ;Cada 0,01 s. llega una peticion de interrupcion
	sub lr, lr,#4	;actualiza el PC de retorno para que 				;apunte a la @siguiente
	push {lr}
	mrs r14,spsr 
	push {r14}	;se guarda la spsr en la pila (usando lr)

;salva registros a usar
	push {r0,r1}

;activa IRQ
	mrs r1,cpsr	;para habilitar IRQ de la palabra de estado 			;del modo activo
	bic r1,r1,#I_Bit		;pone a 0 el bit de las IRQ
	msr	cpsr_c,r1	;_c indica se copian el byte menos significativo

;deactiva del VIC la petición
	ldr r0,=T0_IR
	mov r1,#1
	str r1, [r0]
;tratamiento interrupción
	ldr r0,=reloj		;carga la variable contador
	ldr r1,[r0]
	add r1,r1,#1		;decrementa la cuenta
	str r1,[r0]		;almacena el valor en contador
	 
;desactiva IRQ
	mrs r1,cpsr
	orr r1,r1,#I_Bit
	msr cpsr_cxsf,r1
	
;restaura registros
	pop {r0,r1}	

;desapila spsr y retorna al programa principal
   	pop {r14}
	msr spsr_cxsf,r14  	;restaura el spsr dela pila
	ldr r14,=VICVectAddr
	str r14,[r14]
	pop {pc}^
RSI_teclado ;Rutina de servicio a la interrupcion IRQ7 (teclado)
 ;al pulsar cada tecla llega peticion de interrupcion IRQ7
				sub lr,lr,#4
				PUSH {lr}
				mrs r14,spsr
				PUSH {r14}
				msr cpsr_c,#2_01010010
				PUSH {r0-r2} 
				LDR r1,=RDAT
				ldrb r0,[r1] 
				;bic r0,r0,#2_100000 
				cmp r0, #'k'
				bne arriba
				LDR r0, =diry
				ldrb r1,[r0]
				mov r1, #-1
				strb r1, [r0]
arriba			cmp r0, #'i'
				bne derecha
				LDR r0, =diry
				ldrb r1,[r0]
				mov r1, #1
				strb r1, [r0]
derecha			cmp r0, #'l'
				bne izq
				LDR r0, =dirx
				ldrb r1,[r0]
				mov r1, #1
				strb r1, [r0]
izq				cmp r0, #'j'
				bne parar2
				LDR r0, =dirx
				ldrb r1,[r0]
				mov r1, #-1
				strb r1, [r0]
parar2				cmp r0,#'Q'	
				beq parar
				cmp r0,#'q'
				;bne sigue	
				bne mas
parar			LDR r1,=fin
				 mov r0,#1 
				strb r0,[r1] 
				;b fintec 
mas			cmp r0, #'+'
			bne	menos
			LDR r0, =max
			ldr r1, [r0]
			mov r1, r1,lsr #1
			cmp r1, #1
			movle r1, #1
			str r1,[r0] 
menos 		cmp r0, #'-'
			bne	fintec
			LDR r0, =max
			ldr r1, [r0]
			mov r1, r1,lsl #1
			cmp r1, #128
			movge r1, #128
			str r1,[r0] 
fintec		POP {r0-r2} 
			msr cpsr_c,#2_11010010
			POP {r14}
			msr spsr_fsxc,r14
			LDR r14,=VICVectAddr
			str r14,[r14]
			POP {pc}^


		END
