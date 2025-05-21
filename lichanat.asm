			title	'Biblioteca para calculadora de punto flotante (Tzilmiztli)'
;-----MACROINSTRUCCIONES-----
;---Posiciona cursor posicion: coordenadas (x,y)
cursor		macro	x,y
			push	x
			push	y
			call	posxy
			endm
;---Interrupcion cursor
curint		macro	
			mov 	ah, 02h
			int	 	10h
			endm
;---Imprime marcos posicion inicial: coordenadas(x,y), base, altura
cuadro		macro	x,y,b,h
			xor		bh,bh
			push	h
			push	b
			push	y
			push	x
			call	marco
			endm
;---Imprime cualquier cadena de caracteres hasta el fin($)
print		macro	cadenin
			lea		dx,cadenin
			mov		ah,09h
			int		21h
			endm
;Declaracion de modelo small y tipo de procesador y coprocesador
			.model	small
			.386			;Procesador 80386
			.387			;Coprocesador numérico
			.stack 	256		;Tamaño de la pila (stack) en memoria
			.data			;Segmento de datos
;.....Variables para proceso read			
sign		db		?
temp1		dw		?
ten			dt		10.0
numb		dt		0.0
cden		db		29,30 dup (?)
;.....Variables para mostrar la hora y la fecha
diez 		db 		10
time 		db 		"hh:mm","$"
date 		db 		"dd/mm/aaaa","$"
;.....Variables tipo string para mostrar datos y ayuda
clean1		db		26 dup(32),"$"
nombre		db		"...::: Abakos       Tzilmiztli :::...$"
goya		db		"Universidad Nacional Aut",162,"noma de M",130,"xico$"
inge		db		"Facultad de Ingenier",161,"a$"
txt1		db		"Calculadora de punto flotante.$"
txt2		db		"Por Jaime.   Para Estructura y $"
txt3		db		"Programaci",162,"n de Computadoras.$"
txt4		db		"Para m",160,"s informaci",162,"n y ayuda: ayu$"
txt5		db		"Terminar el programa:  off$"
titu		db		"Calculadora Abakos Tzilmiztli, realizada en lenguaje ensamblador.$"
ver			db		"Versi",162,"n	1.0$"
ayud1		db		"Para realizar alguna operaci",162,"n es necesario cargar uno o m",160,"s $"
ayud2		db		"operandos (n",163,"meros reales) en la pila que se muestra en pantalla,$"
ayud3		db		"posteriormente util",161,"cese el comando de la funci",162,"n deseada.$"
ayud4		db		"En la pila pueden almacenarse un m",160,"ximo de 12 operandos.$"
opera		db		175," Operaciones: $"
oper1		db		"Aritm",130,"ticas: sum, res, mul, div, pow(potencia), sqr(ra",161,"z cuadrada)$"
oper2		db		"Trascendentales: sen, cos, tan, log, lnt(logaritmo natural)$"
oper3		db		"Signo: abs(valor absoluto), neg(negativo)    Valor de ",227,": pii$"
oper4		db		"Redondear al entero cercano: rnd  Factorial (operador entero): fac$"
oper5		db		"Convertir grados a radianes: rad  Convertir radianes a grados: gra$"
oper6		db		"Sacar el valor del tope de la pila: pop    Vaciar la pila: new$"
excep		db		"S",161," se introduce un comando/n",163,"mero inv",160,"lido,"
excep2		db		"carga cero a la pila.$"
siga		db		178,178,178,177,177,176," Presione ",39,"return",39
siga2		db		" para continuar... ",176,177,177,178,178,178,"$"
prompt		db		175,"$"
;.....Variable auxiliar para almacenar direccion de retorno en las funciones(procedimientos)
retadd		dw		?
;.....Declaracion de caracteres del cuadro
esqSD 		equ 	187		;esquina superior derecha
esqSI 		equ 	201		;esquina superior izquierda
esqID 		equ 	188		;esquina inferior derecha
esqII 		equ 	200		;esquina inferior izquierda
elemH 		equ 	205		;elemento horizontal
elemV 		equ 	186		;elemento vertical
x	 		db		?		;variable de coordenada x
y    		db 		?		;variable de coordenada y
b			db 		?		;variable de base
h			db 		?		;variable de altura
;....Variable coordenada y para la impresion de pila de la calculadora
printp		dw		7		
			.code			;Segmento de código
Start:
;-----Declaración de procedimientos públicos de la biblioteca
			public 	read, obten, limpia, limpiapv, helpi
			public 	posxy, interfaz, imprDate	
	;:::	PROCEDIMIENTOS	:::
;-----Procedimiento que lee un mumero de punto flotante desde el teclado
;---y lo almacena en el tope del stack del coprocesador (FUENTE BREY,BARRY ;TIMP ;3RA)
read		proc	 
			fldz				;almacena un zero (cualquier caso, no instruccion)
			inc		bx			;apunta bx al primer elemento de la cadena
			mov		sign,0		;clear sign
			call	get			;read a character
			cmp		al,'-'		;test for minus
			jne		read1		;if not miuns
			mov		sign,0ffh	;set sign for minus
			jmp		read3		;Get integer part
read1:
			cmp		al,'+'		;test for plus
			je		read3		;get integer part
			cmp		al,'0'		;test for number
			jb		read2
			cmp		al,'9'		
			ja		read2		;if a number
			jmp		read4
read2:
			ret
read3:		
			call	get			;read integer part
read4:
			cmp		al,'.'		;test for fraction
			je		read7		;if fraction
			cmp		al,'0'		;test for number
			jb		read5		
			cmp		al,'9'
			ja		read5
			fld		ten			;form integer
			fmul	
			xor		ah,ah
			sub		al,'0'
			mov		temp1,ax
			fiadd	temp1
			jmp		read3
read5:
			cmp		sign,0		;adjust sign
			jne		read6
			ret
read6:
			fchs
			ret
read7:
			fld1				;form fraction
			fld		ten
			fdiv	
read8:		
			call	get			;read character
			cmp		al,'0'		;test for number
			jb		read9
			cmp		al,'9'
			ja		read9
			xor		ah,ah
			sub		al,'0'
			mov		temp1,ax
			fild	temp1
			fmul	st,st(1)	;load number
			fadd	st(2),st	;form fraction
			fcomp
			fld		ten
			fdiv	
			jmp		read8
read9:
			fcomp				
			jmp		read5		;clear stack
			ret
read		endp
;-----Procedimiento que obtiene un caracter de una cadena (para read:proc)
get			proc	 
			mov		al,[bx]
			inc		bx
			ret
get			endp
;-----Procedimiento que obtiene una cadena del buffer del teclado con eco a pantalla
obten		proc	 
			lea		dx,cden
			mov		ah,0ah
			int		21h
			mov		bx,dx
			inc		bx			;apunta al segundo elemento de la cadena (tamaño de cadena)
			ret
obten		endp
;-----Procedimiento que limpia la pantalla 
limpia		proc
			mov		ah,00h
			mov		al,03h
			int		10h
			ret
limpia		endp
;-----Procedimiento que posiciona el cursor en coordenadas x,y
;---Variables: coordenada y, coordenada x en el stack (push y,push x)
posxy		proc	 
			pop		retadd		;almacena la direccion anterior a ser llamada
			pop		ax
			mov 	dh, al
			pop		ax
			mov 	dl, al
			push	bx
			xor		bx,bx		;cero a bx, pagina cero de interrupcion 10h
			curint
			pop		bx
			push	retadd		;regresa la direccion a la pila
			ret
posxy		endp
;-----Procedimiento que muestra marcos, texto y fecha en pantalla
interfaz	proc	 
			call	limpia		;limpia pantalla
			cuadro	4,1,69,3	;dibuja marcos 
			cuadro	4,6,30,13
			cuadro	37,6,36,4
			cuadro	37,12,36,7
			cuadro	4,21,69,1
			cursor	21,2		;imprime datos 
			print	nombre
			cursor	20,3
			print	goya
			cursor	28,4
			print	inge
			cursor	39,14
			print	txt1			
			cursor	39,15
			print	txt2
			cursor	39,16
			print	txt3			
			cursor	39,17
			print	txt4
			cursor	39,18
			print	txt5			
			cursor	7,22		;imprime el prompt
			print	prompt
			call	imprDate	;imprime fecha y hora
			ret
interfaz	endp
;-----Procedimiento que imprime las cadenas Hora y Fecha en la posicion indicada
imprDate	proc	 
			mov 	ah, 2Ch		;interrupcion para obtener 1a hora
			int 	21h
			call 	ConvHora	;cast de la hora a una cadena
			cursor	54,8
			print	time
			mov 	ah, 2ah		;interrupcion para obtener la fecha
			int 	21h
			call 	ConvFec		;cast de la fecha a una cadena
			cursor	51,9
			print	date	
			ret
imprDate	endp
;-----Procedimiento que obtiene la Hora y la escribe a una cadena
ConvHora 	proc
			mov 	ax, 00		
			mov 	al, ch		;obtiene las horas en decimal
			div 	byte PTR [diez]
			add 	al, 30h		;los convierte a su respectivo caracter
			add 	ah, 30h
			lea 	bx, time	;los almacena en la cadena time
			mov 	[bx],al
			inc 	bx
			mov 	[bx],ah
			inc 	bx			;brincamos los puntos
			inc 	bx
			mov 	ax, 00
			mov 	al, cl		;obtiene los minutos en decimal
			div 	byte PTR [diez]
			add 	al, 30h		;los convierte a su respectivo caracter
			add 	ah, 30h
			mov 	[bx],al		;los almacena en la cadena time
			inc 	bx
			mov 	[bx],ah
			ret
ConvHora endp
;-----Procedimiento que obtiene la Fecha y la escribe a una cadena
ConvFec proc
			mov 	ax, 00
			mov 	al, dl		;obtiene el dia del mes en decimal
			div 	byte PTR [diez]
			add 	al, 30h		;los convierte a su respectivo caracter
			add 	ah, 30h
			lea 	bx, date	;los almacena en la cadena date
			mov 	[bx],al
			inc 	bx
			mov 	[bx],ah
			inc 	bx			;brincamos la diagonal
			inc 	bx
			mov 	ax, 00	
			mov 	al, dh		;obtiene el mes en decimal
			div 	byte PTR [diez]
			add 	al, 30h		;los convierte a su respectivo caracter
			add 	ah, 30h
			mov 	[bx],al		;los almacena en la cadena date
			inc 	bx
			mov 	[bx],ah
			mov 	ax, 00
			mov 	ax, cx
			add 	bx, 05		;va al fin de cadena para almacenar el año	
			div 	byte PTR [diez]
			add 	ah, 30h		;lo convierte a su respectivo caracter
			mov 	[bx],ah		;lo almacena en la cadena date
			dec 	bx
			mov 	ah, 00h
			div 	byte PTR [diez]
			add 	ah, 30h		;lo convierte a su respectivo caracter
			mov 	[bx],ah		;lo almacena en la cadena date
			dec 	bx
			mov 	ah, 00h
			div 	byte PTR [diez]
			add 	ah, 30h		;los convierte a su respectivo caracter
			add 	al, 30h		;los almacena en la cadena date
			mov 	[bx],ah
			dec 	bx
			mov 	[bx],al
			;dec 	bx
			ret
ConvFec 	endp
;-----Procedimiento que dibuja un marco rectangular en coordenadas x,y ,base y alura
;---especificos, almacenados en el stack como: push h,push b,push y,push x
marco 		proc 	 
			pop		retadd		;almacena la direccion anterior a ser llamada
;.....Linea Horizontal Superior
			pop		ax			;almacena variables
			mov		x,al
			pop		ax
			mov		y,al
			pop		ax
			mov		b,al
			pop		ax
			mov		h,al	
			mov 	dl, x		;posiciona cursor
			mov 	dh, y		
			curint 
			mov 	dl, esqSI	;imprime elemento de la esquina
			mov 	ah, 02h
			int 	21h
			mov 	dl, x		;posiciona cursor despues de la esquina
			inc		dl			
			curint 	
			mov 	cl, b		;imprime varios elemH (b)
			mov 	al, elemH
			mov 	ah, 0Ah
			int 	10h
			add 	dl, b		;posiciona cursor despues de elemH's
			curint 	
			mov 	dl, esqSD	;imprime la otra esquina
			mov 	ah, 02h
			int 	21h
;.....Lineas Verticales
			xor		cx,cx	
			mov 	cl, h 		;la altura del cuadro
lupeVer: 						;loop para imprimir varios elemV
			mov 	dl, x		;posiciona cursor una posicion abajo 
			inc 	dh
			curint
			mov 	dl, elemV
			mov 	ah, 02h
			int 	21h
			mov 	dl, x
			add		dl,b
			inc		dl
			curint
			mov		dl, elemV
			mov 	ah, 02h
			int 	21h
			loop 	lupeVer
			inc		dh			;posiciona cursor una posicion abajo
			mov 	dl, x
			curint
;.....Linea Horizontal Inferior
			mov 	dl, esqII	;imprime elemento de la esquina
			mov 	ah, 02h
			int 	21h
			mov 	dl, x
			inc		dl			;posiciona cursor despues de la esquina
			curint
			mov		cl,	b		;imprime varios elemH (b)
			mov 	al, elemH
			mov 	ah, 0Ah
			int 	10h
			add 	dl, b		;posiciona cursor despues de elemH's
			curint
			mov 	dl, esqID	;imprime la otra esquina
			mov 	ah, 02h
			int 	21h
			push	retadd
			ret
marco		endp
;-----Procedimiento que muestra la ayuda en pantalla
helpi		proc	near
			call	limpia	
			cuadro	4,1,69,3
			cuadro	4,6,69,16
			cursor	21,2
			print	nombre
			cursor	20,3
			print	goya
			cursor	28,4
			print	inge
			cursor	7,7
			print	titu
			cursor	30,8
			print	ver
			cursor	7,10
			print	ayud1
			cursor	7,11
			print	ayud2
			cursor	7,12
			print	ayud3
			cursor	7,13
			print	ayud4
			cursor	7,14
			print	excep
			cursor	7,15
			print	opera
			cursor	7,16
			print	oper1
			cursor	7,17
			print	oper2
			cursor	7,18
			print	oper3
			cursor	7,19
			print	oper4
			cursor	7,20
			print	oper5
			cursor	7,21
			print	oper6
			cursor	14,22
			print	siga
			ret
helpi		endp
;-----Procedimiento que limpia la pila cuando se encuentra vacia
limpiapv	proc	 
			mov		cx,12
			mov		printp,7
clinv:		
			cursor	7,printp
			print	clean1
			inc		printp
vasv:		loop	clinv
			ret
limpiapv	endp
			end		