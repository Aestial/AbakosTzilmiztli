			title	'Pila y funciones'
;-----MACROINSTRUCCIONES-----
;---Encapsula cmpsb para comparar cada comando parametro:cadena de 3 caracteres
compi		macro	comand
			lea		si,comand
			mov		di,bx
			inc		di
			mov		cx,3		;compara solamente tres caracteres
			inc		dx
	rep		cmpsb				;cmpsb (compara string c/byte) con etiqueta rep
			je		sigue		;salta a comparacion de comandos
			endm
;---Posiciona cursor posicion (x,y)
cursor		macro	x,y
			push	x
			push	y
			call	posxy
			endm
;---Imprime un numero de punto flotante, tiene como parametro la cadena destino,
;-variables: la direccion de ésta y el numero de digitos postpunto, utliza Float2String
printf		macro	cadenin			
			push	offset cadenin
			push	decfloat
			call	Float2Str	;procedimiento por MIBO (profesor) en oceotlMIBO.lib
			lea		dx,cadenin	;imprime la cadena
			mov		ah,09h
			int		21h
			endm
;---Imprime una cadena cualquiera con terminacion $
print		macro	cadenin
			lea		dx,cadenin
			mov		ah,09h
			int		21h
			endm
;-----ESTRUCTURAS-----
;---Pila, con 12 elementos y un indice
pila		struc	
elem		dt		12 dup(0.0)	;doce elementos adyacentes
indice		dw		1			;indice del tope de la pila
pila		ends
;Declaracion de modelo small y tipo de procesador y coprocesador
			.model	small
			.386			;Procesador 80386 y coprocesador 80387
			.387
			.stack 	256		;Tamaño del stack en memoria de 256
			.data			;Segmento de datos
;.....Variables
semi		dt		180.0   ;Pi radianes en grados
temp1		dw		?		;Variable auxiliar
;...Cadenas que limpian la pila y el prompt
clean1		db		27 dup(32),"$"
clean2		db		60 dup(32),"$"
pointer		db		25 dup(32),249,"$"	;Cadena que contiene el apuntador de pila
;...Cadenas de mensajes pila con over y underflow
pilallena	db		7,"Oh ... la pila est",160," llena$"
pilavacia	db		7,"No!... la pila est",160," vacia$"
;...Cadena para almacenar los numeros de punto flotante
chain		db		32 dup (" ")
decfloat	dw		5		;Numero de cifras postpunto flotante
stapel		pila	<>		;Variable tipo pila
opc			db		?		;Opcion de comando
;...Cadenas que representan un comando:
ayud		db		'ayu'	;opc	1
divi		db		'div'	;opc	2
cose		db		'cos'	;opc	3
abso		db		'abs'	;opc	4
fact		db		'fac'	;opc	5
raiz		db		'sqr'	;opc	6
mult		db		'mul'	;opc	7
pote		db		'pow'	;opc	8
rsta		db		'res'	;opc	9
suma		db		'sum'	;opc	10
tang		db		'tan'	;opc	11
sale		db		'off'	;opc	12
nega		db		'neg'	;opc	13
ldpi		db		'pii'	;opc	14
gr2r		db		'rad'	;opc	15
r2gr		db		'gra'	;opc	16
saca		db		'pop'	;opc	17
loga		db		'log'	;opc	18
lnat		db		'lnt'	;opc	19
ente		db		'rnd'	;opc	20
npil		db		'new'	;opc	21
seno		db		'sen'	;opc	22
;...Valores de opc para los distintos comandos:
nayud		equ		01
ndivi		equ		02
ncose		equ		03
nabso		equ		04
nfact		equ		05
nraiz		equ		06
nmult		equ		07
npote		equ		08
nrsta		equ		09
nsuma		equ		10
ntang		equ		11
nsale		equ		12
nnega		equ		13
nldpi		equ		14
ngr2r		equ		15
nr2gr		equ		16
nsaca		equ		17
nloga		equ		18
nlnat		equ		19
nente		equ		20
nnpil		equ		21
nseno		equ		22
;...Variables auxiliares
retadd		dw		?		
bxsup		dw		?
cxsup		dw		?
aux			dt		0.0		
printp		dw		7
			.code		;Segmento de código
;-----Procedimientos externos
			extrn	Float2Str:proc,read:proc,obten:proc,limpia:proc,helpi:proc
			extrn 	posxy:proc, interfaz:proc,imprDate:proc,limpiapv:proc
Start:
main:			
			mov		ax,@data
			mov		ds,ax
			mov		es,ax
			finit
			call	interfaz
otra:		
			call	imprDate
			call 	imprimp
poste:		cursor	09,22
			print	clean2
			cursor	09,22
			call 	obten
			call	compa
sigue:		
			mov		opc,dl
			cmp		opc,22
			ja		@noinst
			call	compe
;----Operaciones que realizan los comandos sobre los valores que estan en la pila 
;-(stapel) del programa y continuan en etiqueta otra, menos off. Usa Coprocesador.
;---Operacion de off (cerrar el programa)
@sale:		call	limpia	;limpia pantalla
			mov		ah,4ch	;entrega el control al S.O.
			int		21h
@ayud:		call	help	;Operacion de ayuda
			jmp		otra			
@divi:		call	popx	;Operacion de division
			call	popx
			fdivr			;division invertida
			call	pushx	
			jmp		otra	
@cose:		call	popx	;Operacion de coseno
			fcos			
			call	pushx
			jmp		otra
@seno:		call	popx	;Operacion de seno
			fsin	
			call	pushx
			jmp		otra
@abso:		call	popx	;Operacion de valor absoluto
			fabs	
			call	pushx
			jmp		otra
@raiz:		call	popx	;Operacion de raiz cuadrada
			fsqrt	
			call	pushx
			jmp		otra
@mult:		call	popx	;Operacion de multiplicacion
			call	popx
			fmul		
			call	pushx
			jmp		otra
@rsta:		call	popx	;Operacion de resta
			call	popx
			fsubr	
			call	pushx
			jmp		otra
@suma:		call	popx	;Operacion de suma
			call	popx
			fadd	
			call	pushx	
			jmp		otra
@tang:		call	popx	;Operacion tangente
			fptan
			fxch	st(1)	
			call	pushx
			jmp		otra
@nega:		call	popx	;Operacion cambia signo
			fchs				
			call	pushx
			jmp		otra
@ldpi:		fldpi			;Carga pi
			call	pushx	
			jmp		otra
@fact:		call	popx	;Factorial de un numero entero positivo
			fabs
			frndint
			ftst			
			fstsw	ax		 ;carga statusword del cop a ax
			and		ax,4500h ;nos quedamos con c3,c2 y c0
			cmp		ax,4000h ;verificamos si es cero
			je		@faccero ;Continua en el factorial de cero
			fstp	aux
			fld		aux
@facto:
			fld		aux
			fld1
			fchs
			fadd
			ftst			
			fstsw	ax		 ;carga statusword del cop a ax
			and		ax,4500h ;nos quedamos con c3,c2 y c0
			cmp		ax,4000h ;verificamos si es cero
			je		@@facto
			fstp	aux
			fld		aux
			fmul			
			jmp		@facto
@faccero:	fstp	aux		;factorial del caso especial cero
			fld1
			jmp		@@faccero
@@facto:	fstp	aux
@@faccero:	call	pushx
			jmp		otra
@pote:		call	popx	;Operacion potencia
			call	popx
			fxch
			fistp	temp1
			mov		cx,temp1
			cmp		cx,0
			je		@pcero
			cmp		cx,1
			je		@@poten
			dec		cx
			fstp	aux
			fld		aux
			fld		aux
@poten:
			fmul
			fld		aux
			loop	@poten
			fstp	aux
			jmp		@@poten
@pcero:		fld1			;caso especial exponente cero
			jmp		@@poten
@@poten:
			call	pushx
			jmp		otra
@gr2r:		call	popx	;Conversion grados a radianes
			fldpi
			fmul
			fld		semi
			fdiv
			call	pushx
			jmp		otra
@r2gr:		call	popx	;Conversion radianes a grados
			fldpi
			fdiv
			fld		semi
			fmul
			call	pushx
			jmp		otra
@saca:		call	popx	;Elimina el valor tope de la pila
			jmp		otra
@loga:		fld1			;Logaritmo vulgar
			call	popx
			fyl2x
			fldl2t
			fdiv
			call	pushx
			jmp		otra
@lnat:		fld1			;Logaritmo natural
			call	popx
			fyl2x
			fldl2e
			fdiv
			call	pushx
			jmp		otra
@ente:		call	popx	;Redondeo al entero mas cercano
			frndint
			call	pushx
			jmp		otra
@npil:		call	vaciar	;Vacia la pila
			jmp		otra
;---No es instruccion ni numero (carga cero)
@noinst:	pop		retadd	
			call	read
			call	pushx		
			jmp		otra
;---Saltos aislados (fuera de procedimientos)
@point:							
			cursor	8,printp
			print	pointer
			inc		printp
			jmp		vas	
noprin:		
			call	limpiapv
			jmp		sigprin
;--------PROCEDIMIENTOS
;.......Pila
;-----Procedimiento que realiza un pop en la pila (stapel)
popx		proc	 
			push	bx
			cmp		stapel.indice,1	;Compara el indice (1:vacia)
			je		vacia
			lea		bx,stapel.elem	;Obtiene la direccion de los elementos
			mov		cx,word ptr[stapel.indice]
			dec		cx
luq:		add		bx,10			;Encuentra el elemento deseado
			loop	luq
			sub		bx,10
			fld		tbyte ptr[bx]	;Carga al coprocesador
			dec		stapel.indice
			jmp		conti
vacia:		call	pvacia			;Muestra mensaje de pila vacia
conti:		pop		bx
			ret
popx		endp
;-----Procedimiento que vacia la pila
vaciar		proc	 
			mov		stapel.indice,1
			ret
vaciar		endp
;-----Procedimiento que muestra mensaje de pila vacia
pvacia		proc	 
			cursor	7,19
			print	pilavacia
			ret
pvacia		endp
;-----Procedimiento que realiza un push en la pila (stapel)
pushx		proc	near
			push	bx
			cmp		stapel.indice,13 ;Compara el inidce (13:llena)
			je		lleno
			lea		bx,stapel.elem	 ;Obtiene la direccion de los elementos
			mov		cx,word ptr[stapel.indice]
lup:		add		bx,10			 ;Encuentra el elemento deseado
			loop	lup
			sub		bx,10
			fstp	tbyte ptr[bx]	 ;Carga del coprocesador
			inc		stapel.indice
			jmp		cont
lleno:		call 	pllena			 ;Muestra mensaje de pila llena
cont:		pop		bx
			ret
pushx		endp
;-----Procedimiento que muestra mensaje de pila llena
pllena		proc	near
			call	imprimp
			cursor	7,19
			print	pilallena
			jmp		poste
			ret
pllena		endp
;-----Procedimiento que imprime la pila
imprimp		proc	near
			cmp		stapel.indice,1	;Verifica si esta vacia
			je		noprin			;No imprime elemento alguno
			call	limpiap			;Limpia el lugar de la pila
			lea		bx,stapel.elem	;Obtiene la direccion de los elementos
			mov		cx,word ptr[stapel.indice]
			dec		cx
			mov		printp,7
again:		;Imprime hasta la cantidad maxima de elementos en la pila, solamente
			fld		tbyte ptr[bx]			
			push	bx		;se hace un respaldo de los registros bx y cx
			push	cx
			cursor	7,printp
			printf	chain	;imprime el numero
			pop		temp1
			pop		temp1
			pop		cx
			pop		bx
			add		bx,10
			inc		printp
			loop	again
sigprin:	ret
imprimp		endp
;.......Pila
;-----Procedimiento que compara cadena y asigna un valor a dx,
;--- dependiendo del comando
compa		proc	near
			cmp		byte ptr[bx],3	;Compara el tamaño de caracteres en la cadena
			jne		@noinst			;Si es diferente, no es un comando
			xor		dx,dx	
			cld				;Limpia la bandera de direccion para cmpsb
			compi	ayud
			compi	divi
			compi	cose
			compi	abso
			compi	fact
			compi	raiz
			compi	mult
			compi	pote
			compi	rsta
			compi	suma
			compi	tang
			compi	sale
			compi	nega
			compi	ldpi
			compi	gr2r
			compi	r2gr
			compi	saca
			compi	loga
			compi	lnat
			compi	ente
			compi	npil
			compi	seno
			inc		dx
			ret
compa		endp
;----_Procedimiento que compara el valor de opc con el de un comando
compe		proc	near
			cmp		opc,nayud
			je		@ayud
			cmp		opc,ndivi
			je		@divi
			cmp		opc,ncose
			je		@cose	
			cmp		opc,nabso
			je		@abso
			cmp		opc,nfact
			je		@fact
			cmp		opc,nraiz
			je		@raiz
			cmp		opc,nmult
			je		@mult
			cmp		opc,npote
			je		@pote
			cmp		opc,nrsta
			je		@rsta
			cmp		opc,nsuma
			je		@suma
			cmp		opc,ntang
			je		@tang
			cmp		opc,nsale
			je		@sale
			cmp		opc,nnega
			je		@nega
			cmp		opc,nldpi
			je		@ldpi
			cmp		opc,ngr2r
			je		@gr2r
			cmp		opc,nr2gr
			je		@r2gr
			cmp		opc,nsaca
			je		@saca
			cmp		opc,nloga
			je		@loga
			cmp		opc,nlnat
			je		@lnat
			cmp		opc,nente
			je		@ente
			cmp		opc,nnpil
			je		@npil
			cmp		opc,nseno
			je		@seno
			ret
compe		endp
;-----Procedimiento que limpia la pila cuando tiene elementos (no mensaje de pila
;---con overflow u underflow)
limpiap		proc	near
			mov		cx,13
			mov		printp,7
clin:		
			mov		ax,15
			sub		ax,stapel.indice
			cmp		cx,ax
			je		@point
			cursor	7,printp
			print	clean1
			inc		printp
vas:		loop	clin			
			ret
limpiap		endp
;-----Procedimiento que muestra la ayuda en pantalla hasta que se presiona return
help		proc	near
			call	helpi
Readloop:   mov     ah, 0           ;Lee tecla
            int     16h
            cmp     al, 0dh         ;Compara con tecla return (ENTER)
            jne     ReadLoop
			call	interfaz
			jmp		otra
			ret
help		endp
			end		Start