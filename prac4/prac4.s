    AREA prog, CODE, READONLY
	EXPORT ordena 

ordena push{fp,lr}
	mov fp,sp
	push{r0}
	push{r1}
	push{r2}
	sub r1, r1, #1
	mov r2, #0
	push{r0}
	push{r1}
	push {r2}
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
	ldr r2,[fp,#8]
	mov r3, r2
	ldr r1,[fp,#12]
	mov r4, r1
	add r5, r1, r2
	mov r6,r5,lsr#1
	ldr r0,[fp,#16]
	ldr r7,[r0, r6,lsl #2]
while ldr r2,[fp,#8]
	mov r3, r2
	ldr r1,[fp,#12]
	mov r4, r1
	add r5, r1, r2
	mov r6,r5,lsr#1
	ldr r0,[fp,#16]
	ldr r7,[r0, r6,lsl #2]
bucle1	ldr r8,[r0,r3, lsl #2]
	cmp r8, r7
	bge fin_bucle1
	add r3, r3, #1
	b bucle1
fin_bucle1
bucle2 ldr r9,[r0, r4, lsl #2]
	cmp r7, r9
	bge fin_bucle2
	sub r4, r4, #1
	b bucle2
fin_bucle2
	cmp r3, r4
	bgt paso
	ldr r6, [r0,r3, lsl #2]
	str r9, [r0, r3, lsl #2]
	str r6, [r0, r4, lsl #2]
	add r3, r3, #1
	sub r4, r4, #1
paso
	cmp r3, r4
	bgt fin_while
	b while
fin_while 

if1 cmp r2, r4
	bge salto1
	push{r0}
	push{r4}
	push{r2}
	bl qksort
	pop{r2}
	pop{r4}
	pop{r0}
salto1
if2 cmp r3, r1
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
		
		