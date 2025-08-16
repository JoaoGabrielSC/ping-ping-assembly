;********************************************
;		João Gabriel Santos Custodio		*
;			Projeto de Laboratorio			*
;		  Sistemas Embarcados 2025/1		*
;********************************************

segment code
..start:
    mov 		ax,data
    mov 		ds,ax
    mov 		ax,stack
    mov 		ss,ax
    mov 		sp,stacktop

    mov  		ah,0Fh
    int  		10h
    mov  		[prev_mod],al   

    mov     	al,12h
   	mov     	ah,0
    int     	10h

	cli
	xor     ax, ax
	mov     ES, ax
	mov     ax, [ES:int9*4]
	mov     [offset_dos], ax       
	mov     ax, [ES:int9*4+2]      
	mov     [cs_dos], ax		 
	mov     [ES:int9*4+2], CS
	mov     WORD [ES:int9*4],keyint
		
	sti

	call draw_interface
	
	mov 	di, 320
	mov 	si, 240


ball_moviment:
	move_x:
		add 	di, [x_upper]
		cmp 	di, 618
		jc		prox					
		call 	check_paddle
		call 	increase_score
		cmp		byte[game_score],	1		
		jmp		x_collision

	prox:
		cmp di, 11
		jc	x_collision	 
		jmp move_y

	x_collision:
		neg word [x_upper]
		jmp move_y

	move_y:
		add 	si, [y_upper]
		cmp 	si, 417
		jae		y_collision
		cmp 	si, 13
		jc		y_collision
		jmp 	draw_ball	

	y_collision:
		neg word [y_upper]
		jmp draw_ball

	draw_ball:
		mov		byte[cor], vermelho	
		mov		ax,			di  		
		push	ax
		mov		ax,			si  		
		push	ax
		mov		ax,			circle_radius
		push	ax
		call	full_circle
		call 	delay
		jb		erase_ball
					

	erase_ball:		
		mov		byte[cor],	preto
		mov		ax,			di  		
		push	ax
		mov		ax,			si  		
		push	ax
		mov		ax,			circle_radius
		push	ax
		call	full_circle  
		call	check_keyboard	
		

draw_interface: 
	call 	interface
	call 	title_interface
	call 	write_game_score
	call 	write_current_velocity
	call	draw_paddle
	ret	
		

paddle:
	push	bx
	mov		bx, 630		
	push	bx
	mov		ax,	word[paddle_position]	
	push	ax
	push	bx   						
	add		ax,	50			
	push	ax
	call		line
	pop		bx
	ret

	draw_paddle:
		mov		byte[cor], branco_intenso
		call paddle
	ret
	remove_paddle:
		mov		byte[cor], preto
		call paddle
		ret


check_paddle:
	push 	ax
	cmp		si,			[paddle_position]
	jc 		perdendo
	mov		ax, 		[paddle_position]
	add 	ax, 		50
	cmp		si,			ax
	ja 		perdendo
	pop 	ax
	mov		byte[game_score], 1
	ret
	
	perdendo:
		pop ax
		mov	byte[game_score], 0
		ret
		

check_keyboard:
	IL1:
		mov     ax,[ponteiro_i]
		CMP     ax,[ponteiro_t]
		JE      call_ball_moviment
		inc     word[ponteiro_t]
		and     word[ponteiro_t],7
		mov     bx,[ponteiro_t]
		XOR     AX, AX
		MOV     AL, [bx+tecla]
		mov     [teclar],al
		MOV     BL, 16
		DIV     BL
		ADD     Al, 30h
		CMP     AL, 3Ah                                                                                              
		jb      cont
		ADD     AL, 07h

	call_ball_moviment:
		jmp	ball_moviment

	cont:        
		MOV     [teclas], AL
		ADD     AH, 30h
		CMP     AH, 3Ah
		jmp      pressed_keys
		ADD     AH, 07h

	pressed_keys:
		cmp     BYTE [teclar], 01h  ;tecla esc (sai do programa)      
		je      call_close_program
		cmp     BYTE [teclar], 4Eh  ;tecla + (aumenta a velocidade)
		je 	    aumenta_vel
		cmp	    BYTE [teclar], 4Ah  ;tecla - (diminui a velocidade)    
		je 	    diminui_vel
		cmp	    BYTE [teclar], 48h  ;seta para cima (move a barra para cima)
		je 	    up_paddle
		cmp	    BYTE [teclar], 50H  ;seta para baixo (move a barra para baixo)   
		je 	    desce_raquete
		jmp     IL1

call_close_program:
	jmp close_program
	    

up_paddle:
	call 	remove_paddle
	cmp 	word[paddle_position], paddle_position_limit
	je		call_ball_mov
	add		word[paddle_position], 10
	call	draw_paddle
		
call_ball_mov:
	jmp ball_moviment

desce_raquete:
	call 	remove_paddle
	cmp 	word[paddle_position], zero_paddle_position
	je		call_ball_moviment_2
	sub		word[paddle_position], 10
	call	draw_paddle

call_ball_moviment_2:
	jmp ball_moviment

aumenta_vel:
	cmp 	word[velocity], 3000 
	je		call_ball_moviment_3
	sub		word[velocity], 3000 
	mov 	ax, [vel]
	inc 	ax
	mov		[vel],	ax
	call	display_velocity
			
call_ball_moviment_3:
	jmp ball_moviment

diminui_vel:
	cmp word[velocity], 9000	
	je	call_ball_moviment_4
	add	word[velocity], 3000 
	mov 	ax, [vel]
	dec 	ax
	mov		[vel],	ax
	call	display_velocity

call_ball_moviment_4:
	jmp ball_moviment
	ret

increase_score:
    cmp     byte[game_score],   1
    jz      paddle_hit
    jmp     paddle_miss
        
paddle_hit: ; jogador rebateu a bola -> adicionar ponto
    inc     word[player_points]
    mov     dl, 36 ; Start position for player score
    mov     [print_begin], dl
    mov     ax, [player_points]
    jmp     update_score

paddle_miss: ; jogador não rebateu -> ponto para o computador
    inc     word[sum_points]
    mov     dl, 41 ; Start position for computer score
    mov     [print_begin], dl
    mov     ax, [sum_points]

update_score:
    mov     bx, 10
    xor     cx, cx

counter:
    xor     dx, dx
    div     bx
    push    dx
    inc     cx
    test    ax, ax
    jnz     counter

    mov     byte[cor], branco_intenso
    mov     dh, 2
    mov     dl, [print_begin]
    
    ; Adjust dl based on the number of digits to align the score correctly
    cmp     cx, 1
    je      align_one_digit
    jmp     print_score_digits

align_one_digit:
    inc     dl

print_score_digits:
    call    cursor
    pop     ax
    add     ax, 48
    call    caracter
    inc     dl              
    loop    print_score_digits
    ret


close_program:
	CLI
	XOR     AX, AX
	MOV     ES, AX
	MOV     AX, [cs_dos]
	MOV     [ES:int9*4+2], AX
	MOV     AX, [offset_dos]
	MOV     [ES:int9*4], AX
	mov 	ah,0
	mov 	al,[prev_mod]
	int 	10h 
	MOV     AH, 4Ch
	int     21h
			

;delay function: interruption with int 15h
delay:
	pushf
	push 		ax
	push		cx
	push		dx
	push		di
	mov			ah,	86h
	mov 		cx,	0
	mov			dx,	word[velocity]
	int 15h
	pop			di
	pop			dx
	pop			cx
	pop			ax
	popf
	ret
		

title_interface:
	mov		byte[cor],branco_intenso

	push		di
	push 		ax
	push 		bx
	push		cx
	push		dx
		
	mov     	cx, 58
	mov     	bx, 0
	mov     	dh, 1
	mov     	dl, 10

loop_title:
	call	cursor
	mov     al,[bx+project_title]
	call	caracter
	inc     bx
	inc		dl
	loop    loop_title

	pop		dx
	pop		cx
	pop		bx
	pop		ax
	pop		bp
	ret

write_game_score:
	mov		byte[cor],branco_intenso

	push		si
	push		di
	push		bp
	push 		ax
	push 		bx
	push		cx
	push		dx

	mov     	cx, 45
	mov     	bx, 0
	mov     	dh, 2
	mov     	dl, 8

rect_write_game_score:
	call	cursor
	mov     al,	[bx+score_label]
	call	caracter
	inc     bx
	inc		dl
	loop    rect_write_game_score

	pop		dx
	pop		cx
	pop		bx
	pop		ax
	pop		bp
	pop		di
	pop		si
	ret

write_current_velocity:
	mov			byte[cor],branco_intenso
	push		di
	push 		ax
	push 		bx
	push		cx
	push		dx

	mov     	cx, 19
	mov     	bx, 0
	mov     	dh, 2
	mov     	dl, 54

ret1:
	call	cursor
	mov     al,	[bx+current_velocity]
	call	caracter
	inc     bx
	inc		dl
	loop    ret1

	pop		dx
	pop		cx
	pop		bx
	pop		ax	
	pop		di
	ret


display_velocity:
	mov			byte[cor],branco_intenso
	pushf
	push 		ax
	push		dx
	push		di
	mov			dh,		2
	mov	 		dl, 	72
	call		cursor
	mov  		ax, 	word[current_velocity]
	call 		caracter
	pop			di
	pop			dx
	pop			ax
	popf
	ret

;************************************************************************
interface:
	;Superior Bar
	mov			byte[cor],branco_intenso
	mov		ax,0   
	push	ax
	mov		ax,479  
	push	ax
	mov		ax,639 
	push	ax
	mov		ax,479  
	push	ax
	call	line
	
	;Left bar
	mov			byte[cor],branco_intenso
	mov		ax,0  
	push	ax
	mov		ax,0  
	push	ax
	mov		ax,0 
	push	ax
	mov		ax,479  
	push	ax
	call	line
	
	;Right bar
	mov			byte[cor],branco_intenso
	mov		ax,639  
	push	ax
	mov		ax,479  
	push	ax
	mov		ax,639  
	push	ax
	mov		ax,0  
	push	ax
	call	line
	
	;Bottom bar of the rectangle
	mov			byte[cor],branco_intenso
	mov		ax,639  
	push	ax
	mov		ax,0  
	push	ax
	mov		ax,0  
	push	ax
	mov		ax,0  
	push	ax
	call	line
	
	mov			byte[cor],branco_intenso
	mov		ax, 0   
	push	ax
	mov		ax,431  
	push	ax
	mov		ax,640  
	push	ax
	mov		ax,431  
	push	ax
	call	line
	ret

;************************************************************************
;Utils from labs

cursor:
	pushf
	push 		ax
	push 		bx
	push		cx
	push		dx
	push		si
	push		di
	push		bp
	mov     	ah,2
	mov     	bh,0
	int     	10h
	pop		bp
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	ret

line:
	push		bp
	mov		bp,sp
	pushf
	push 		ax
	push 		bx
	push		cx
	push		dx
	push		si
	push		di
	mov		ax,[bp+10]
	mov		bx,[bp+8]
	mov		cx,[bp+6]
	mov		dx,[bp+4]
	cmp		ax,cx
	je		line2
	jb		line1
	xchg		ax,cx
	xchg		bx,dx
	jmp		line1

line2:		
		cmp		bx,dx  ;subtrai dx de bx
		jb		line3
		xchg		bx,dx


line3:	; dx > bx
		push		ax
		push		bx
		call 		plot_xy
		cmp		bx,dx
		jne		line31
		jmp		end_line

line31:		
	inc		bx
	jmp		line3

line1:
	push		cx
	sub		cx,ax
	mov		[deltax],cx
	pop		cx
	push		dx
	sub		dx,bx
	ja		line32
	neg		dx

line32:
		mov		[deltay],dx
		pop		dx

		push		ax
		mov		ax,[deltax]
		cmp		ax,[deltay]
		pop		ax
		jb		line5

	; cx > ax e deltax>deltay
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx

		mov		si,ax

line4:
		push		ax
		push		dx
		push		si
		sub			si,ax	;(x-x1)
		mov			ax,[deltay]
		imul		si
		mov			si,[deltax]
		shr			si,1
		cmp			dx,0
		jl			ar1
		add			ax,si
		adc			dx,0
		jmp			arc1

ar1:		
		sub		ax,si
		sbb		dx,0

arc1:
		idiv		word [deltax]
		add		ax,bx
		pop		si
		push		si
		push		ax
		call		plot_xy
		pop		dx
		pop		ax
		cmp		si,cx
		je		end_line
		inc		si
		jmp		line4

line5:		
		cmp		bx,dx
		jb 		line7
		xchg		ax,cx
		xchg		bx,dx

line7:
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx



		mov		si,bx
line6:
		push		dx
		push		si
		push		ax
		sub		si,bx	;(y-y1)
		mov		ax,[deltax]
		imul		si
		mov		si,[deltay]		;arredondar
		shr		si,1
		cmp		dx,0
		jl		ar2
		add		ax,si
		adc		dx,0
		jmp		arc2
ar2:		sub		ax,si
		sbb		dx,0
arc2:
		idiv		word [deltay]
		mov		di,ax
		pop		ax
		add		di,ax
		pop		si
		push		di
		push		si
		call		plot_xy
		pop		dx
		cmp		si,dx
		je		end_line
		inc		si
		jmp		line6

end_line:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		8

caracter:
	pushf
	push 		ax
	push 		bx
	push		cx
	push		dx
	push		si
	push		di
	push		bp
	mov     	ah,9
	mov     	bh,0
	mov     	cx,1
	mov     	bl,[cor]
	int     	10h
	pop		bp
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	ret

plot_xy:
	push		bp
	mov		bp,sp
	pushf
	push 		ax
	push 		bx
	push		cx
	push		dx
	push		si
	push		di
	mov     	ah,0ch
	mov     	al,[cor]
	mov     	bh,0
	mov     	dx,479
	sub			dx,[bp+4]
	mov     	cx,[bp+6]
	int     	10h
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		4

circle:
	push 	bp
	mov	 	bp,sp
	pushf
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di

	mov		ax,[bp+8]
	mov		bx,[bp+6]
	mov		cx,[bp+4]

	mov 	dx,bx	
	add		dx,cx
	push    ax			
	push	dx
	call plot_xy

	mov		dx,bx
	sub		dx,cx
	push    ax			
	push	dx
	call plot_xy

	mov 	dx,ax	
	add		dx,cx
	push    dx			
	push	bx
	call plot_xy

	mov		dx,ax
	sub		dx,cx
	push    dx			
	push	bx
	call plot_xy

	mov		di,cx
	sub		di,1
	mov		dx,0

stay:
	mov		si,di
	cmp		si,0
	jg		inf
	mov		si,dx
	sal		si,1
	add		si,3
	add		di,si
	inc		dx
	jmp		plotar
inf:	
	mov		si,dx
	sub		si,cx
	sal		si,1
	add		si,5
	add		di,si
	inc		dx		
	dec		cx

plotar:	
	mov		si,dx
	add		si,ax
	push    si			
	mov		si,cx
	add		si,bx
	push    si			
	call plot_xy		
	mov		si,ax
	add		si,dx
	push    si			
	mov		si,bx
	sub		si,cx
	push    si			
	call plot_xy		
	mov		si,ax
	add		si,cx
	push    si			
	mov		si,bx
	add		si,dx
	push    si			
	call plot_xy		
	mov		si,ax
	add		si,cx
	push    si			
	mov		si,bx
	sub		si,dx
	push    si			
	call plot_xy		
	mov		si,ax
	sub		si,dx
	push    si			
	mov		si,bx
	add		si,cx
	push    si			
	call plot_xy		
	mov		si,ax
	sub		si,dx
	push    si			
	mov		si,bx
	sub		si,cx
	push    si			
	call plot_xy		
	mov		si,ax
	sub		si,cx
	push    si			
	mov		si,bx
	sub		si,dx
	push    si			
	call plot_xy		
	mov		si,ax
	sub		si,cx
	push    si			
	mov		si,bx
	add		si,dx
	push    si			
	call plot_xy		

	cmp		cx,dx
	jb		fim_circle  
	jmp		stay		


fim_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6

				  
full_circle:
	push 	bp
	mov	 	bp,sp
	pushf
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di

	mov		ax,[bp+8]
	mov		bx,[bp+6]
	mov		cx,[bp+4]

	mov		si,bx
	sub		si,cx
	push    ax			;coloca xc na pilha			
	push	si			;coloca yc-r na pilha
	mov		si,bx
	add		si,cx
	push	ax		;coloca xc na pilha
	push	si		;coloca yc+r na pilha
	call line


	mov		di,cx
	sub		di,1	 ;di=r-1
	mov		dx,0

stay_full:				;loop
	mov		si,di
	cmp		si,0
	jg		inf_full       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
	mov		si,dx		;o jl � importante porque trata-se de conta com sinal
	sal		si,1		;multiplica por doi (shift arithmetic left)
	add		si,3
	add		di,si     ;nesse ponto d=d+2*dx+3
	inc		dx		;incrementa dx
	jmp		plotar_full

inf_full:	
	mov		si,dx
	sub		si,cx  		;faz x - y (dx-cx), e salva em di 
	sal		si,1
	add		si,5
	add		di,si		;nesse ponto d=d+2*(dx-cx)+5
	inc		dx		;incrementa x (dx)
	dec		cx		;decrementa y (cx)

plotar_full:	
	mov		si,ax
	add		si,cx
	push	si
	mov		si,bx
	sub		si,dx
	push    si
	mov		si,ax
	add		si,cx
	push	si
	mov		si,bx
	add		si,dx
	push    si
	call 	line

	mov		si,ax
	add		si,dx
	push	si
	mov		si,bx
	sub		si,cx
	push    si
	mov		si,ax
	add		si,dx
	push	si
	mov		si,bx
	add		si,cx
	push    si
	call	line

	mov		si,ax
	sub		si,dx
	push	si
	mov		si,bx
	sub		si,cx
	push    si
	mov		si,ax
	sub		si,dx
	push	si
	mov		si,bx
	add		si,cx
	push    si
	call	line

	mov		si,ax
	sub		si,cx
	push	si
	mov		si,bx
	sub		si,dx
	push    si
	mov		si,ax
	sub		si,cx
	push	si
	mov		si,bx
	add		si,dx
	push    si
	call	line

	cmp		cx,dx
	jb		fim_full_circle  
	jmp		stay_full


fim_full_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6

; Interruptions
keyint:
	push 	ax
	push    bx
	push    ds
	mov     ax,data
	mov     ds,ax
	IN      AL, kb_data
	inc     WORD [ponteiro_i]
	and     WORD [ponteiro_i],7
	mov     bx,[ponteiro_i]
	mov     [bx+tecla],al
	IN      AL, kb_ctl
	OR      AL, 80h
	OUT     kb_ctl, AL
	AND     AL, 7Fh
	OUT     kb_ctl, AL
	MOV     AL, eoi
	OUT     pictrl, AL
	pop     ds
	pop     bx
	pop		ax
	IRET


segment data
cor		db		branco_intenso
;
;	Legenda das Cores
	; I R G B COR
	; 0 0 0 0 preto
	; 0 0 0 1 azul
	; 0 0 1 0 verde
	; 0 0 1 1 cyan
	; 0 1 0 0 vermelho
	; 0 1 0 1 magenta
	; 0 1 1 0 marrom
	; 0 1 1 1 branco
	; 1 0 0 0 cinza
	; 1 0 0 1 azul claro
	; 1 0 1 0 verde claro
	; 1 0 1 1 cyan claro
	; 1 1 0 0 rosa claro
	; 1 1 0 1 magenta claro
	; 1 1 1 0 amarelo claro
	; 1 1 1 1 branco intenso

;Tabela de Interrupcoes 
kb_data 	EQU 	60h
kb_ctl  	EQU 	61h
pictrl  	EQU 	20h
eoi     	EQU 	20h
int9    	EQU 	9h
cs_dos  	DW  	1
offset_dos  DW 		1
teclar 		db 		0
tecla   	resb  	8 
ponteiro_i  dw  	0
ponteiro_t  dw  	0
teclas 		DB  	0,0,13,10,'$'

preto			equ		0
azul			equ		1
verde			equ		2
cyan			equ		3
vermelho		equ		4
magenta			equ		5
marrom			equ		6
branco			equ		7
cinza			equ		8
azul_claro		equ		9
verde_claro		equ		10
cyan_claro		equ		11
rosa			equ		12
magenta_claro	equ		13
amarelo			equ		14
branco_intenso	equ		15

circle_radius			equ		10
paddle_position_limit	equ		390
zero_paddle_position    equ     0
sum_points_position     equ     39


;cabecalho da interface
project_title    	db  'Exercicio de Programacao de Sistemas Embarcados 1 - 2025/1'
score_label		db	'Joao Gabriel Santos Custodio 00 x 00 Computador'
current_velocity	db	'Velocidade Atual: 1'

;Dados
prev_mod	db	0
linha   		dw  0
coluna  		dw  0
deltax			dw	0
deltay			dw	0

;Velocidade		
velocity  	dw  9000
vel_paddle	dw	30
vel				dw	49

;Posicao
x_upper  		dw  -2
y_upper		  	dw  2
paddle_position dw	190

;Pontuacao
player_points	dw	0
sum_points 	dw  0
print_begin		dw	0
game_score			db	1

	
segment stack stack
			resb 		512
stacktop:
