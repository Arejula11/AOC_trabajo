    AREA prog, CODE, READONLY
	EXPORT ordena

ordena push{fp,lr}
	mov fp,sp
	;push{r0}
	push{r1}
	push{r2}
	sub r1, r1, #1  ;n-1
	mov r2, #0
	push{r0}	;@T
	push{r1}	;n-1
	push {r2}	;0
	bl qksort
	pop{r2}
	pop{r1}
	pop{r0}
	pop{r2}
	pop{r1}
	pop{r0}
	pop {fp, pc}
	
qksort push{fp, lr}
	mov fp, sp
	push{r0, r1, r2, r3, r4, r5, r6, r7, r8, r9}
	ldr r2,[fp,#8]		;r2=izq
	mov r3, r2			;r3=i
	ldr r1,[fp,#12]		;r1=der-1
	mov r4, r1			;r4=j
	add r5, r1, r2
	mov r6,r5,lsr#1		;r6=(der-1-izq)/2
	ldr r0,[fp,#16]		;r0=@T
	ldr r7,[r0, r6,lsl #2]	;r7=T[(der-1-izq)*4/2]=x
while ldr r2,[fp,#8]	;r2=izq
	mov r3, r2			;r3=i
	ldr r1,[fp,#12]		;r1=der-1
	mov r4, r1			;r4=j
	add r5, r1, r2
	mov r6,r5,lsr#1		;r6=(der-1-izq)/2
	ldr r0,[fp,#16]		;r0=@T
	ldr r7,[r0, r6,lsl #2]	;r7=T[(der-1-izq)*4/2]=x
bucle1	ldr r8,[r0,r3, lsl #2]	;r8=T[i]
	cmp r8, r7			;T[i]<x
	bge fin_bucle1
	add r3, r3, #1
	b bucle1
fin_bucle1
bucle2 ldr r9,[r0, r4, lsl #2]	;r9=T[j]
	cmp r7, r9			;T[j]>x
	bge fin_bucle2
	sub r4, r4, #1
	b bucle2
fin_bucle2
	cmp r3, r4		;i<=j
	bgt paso
	ldr r6, [r0,r3, lsl #2]		;r6=T[i]
	str r9, [r0, r3, lsl #2]	;w=T[i]
	str r6, [r0, r4, lsl #2]	;T[i]=T[j]
	add r3, r3, #1				;i++
	sub r4, r4, #1				;j--
paso
	cmp r3, r4		;i<=j
	bgt fin_while
	b while
fin_while 

if1 cmp r2, r4		;if(iz<j)
	bge salto1
	push{r0}
	push{r4}
	push{r2}
	bl qksort		
	pop{r2}
	pop{r4}
	pop{r0}
salto1
if2 cmp r3, r1		;if(iz<j)
	bge salto2
	push{r0}
	push{r1}
	push{r3}		
	bl qksort
	pop{r3}
	pop{r1}
	pop{r0}
salto2
	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9}
	pop{fp,pc}
	
	END
		
		