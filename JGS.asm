;João Gabriel Santos Custodio
;Projeto de Laboratorio
;Sistemas Embarcados 2025/1

segment code
..start:
    mov 		ax,data
    mov 		ds,ax
    mov 		ax,stack
    mov 		ss,ax
    mov 		sp,stacktop

    mov  		ah,0Fh
    int  		10h
    mov  		[modo_anterior],al   

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

	call desenha_interface
	
	mov 	di, 320
	mov 	si, 240


movimento_bola:
	move_x:
		add 	di, [x_upper]
		cmp 	di, 618
		jc		prox					
		call 	check_paddle
		call 	increase_score
		cmp		byte[placar],	1		
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
		jae		y_encosta
		cmp 	si, 13
		jc		y_encosta
		jmp 	desenha_bola			
		y_encosta:
			neg word [y_upper]
			jmp desenha_bola

;************************************************************************
;************************************************************************
;Funcao desenhar bola
	desenha_bola:
		mov		byte[cor], vermelho	
		mov		ax,			di  		
		push	ax
		mov		ax,			si  		
		push	ax
		mov		ax,			10   		;raio do circulo
		push	ax
		call	full_circle
		call 	delay	;intervalo para que a bola seja desenhada
		jb		apaga_bola
				
;************************************************************************	
;************************************************************************	
;Funcao que apagara o circulo
	apaga_bola:		
		mov		byte[cor],	preto
		mov		ax,			di  		
		push	ax
		mov		ax,			si  		
		push	ax
		mov		ax,			10	;raio do circulo
		push	ax
		call	full_circle  
		call	verifica_teclado	;chama a interrupcao e verifica o teclado
		
;************************************************************************
;************************************************************************
;Chama as funcoes que criam a interface do programa
	desenha_interface: 
		call 	interface
		call 	titulo
		call 	escreve_placar
		call 	escreve_velocidade_atual
		call	desenha_raquete
		ret	
		
;************************************************************************
;************************************************************************
;Funcao que cria a raquete
	raquete:
		push	bx
		mov		bx, 630	 ;Coluna em que a raquete fica			
		push	bx
		mov		ax,	word[posicao_raquete]	
		push	ax
		push	bx   						
		add		ax,	50  ;Tamanho da raquete					
		push	ax
		call		line
		pop		bx
		ret
;Desenha a raquete
	desenha_raquete:
		mov		byte[cor], branco_intenso
		call raquete
	ret
;Desenha uma raquete preta para apagar a branca
	apaga_raquete:
		mov		byte[cor], preto
		call raquete
		ret

;************************************************************************
;************************************************************************
;Verifica se houve toque da bola na raquete
	check_paddle:
		push 	ax
		cmp		si,			[posicao_raquete]
		jc 		perdendo
		mov		ax, 		[posicao_raquete]
		add 	ax, 		50
		cmp		si,			ax
		ja 		perdendo
		pop 	ax
		mov		byte[placar], 1
		ret
		perdendo:
			pop ax
			mov	byte[placar], 0
		ret
		
;************************************************************************
;************************************************************************
;Verifica as teclas do teclado
	verifica_teclado:
	;Interrupcoes do teclado vindas do codigo tecbuf
	   	IL1:
			mov     ax,[ponteiro_i]
			CMP     ax,[ponteiro_t]
			JE      chama_movimento_bola
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
		chama_movimento_bola:
			jmp	movimento_bola
	    cont:        
	    	MOV     [teclas], AL
	    	ADD     AH, 30h
	    	CMP     AH, 3Ah
	    	jmp      teclas_apertadas
	    	ADD     AH, 07h
	;Teclas usadas no programa
	   teclas_apertadas:
	  		 cmp     BYTE [teclar], 01h             ;tecla esc (sai do programa)      
	    	je      chama_sair
	        cmp     BYTE [teclar], 4Eh             ;tecla + (aumenta a velocidade)
	    	je 	    aumenta_vel
	    	cmp	    BYTE [teclar], 4Ah             ;tecla - (diminui a velocidade)    
	    	je 	    diminui_vel
	    	cmp	    BYTE [teclar], 48h 	        ;seta para cima (move a barra para cima)
	    	je 	    sobe_raquete
	    	cmp	    BYTE [teclar], 50H 	        ;seta para baixo (move a barra para baixo)   
	    	je 	    desce_raquete
	    	jmp     IL1

			chama_sair:
				jmp sair
	    

		sobe_raquete:
			call 	apaga_raquete ;apaga toda vez que a raquete se mexe
			cmp 	word[posicao_raquete], 390 ;limita as linhas, a partir disso a barra some	
			je		chama_movimento_bola_1
			add		word[posicao_raquete], 10
			call	desenha_raquete
			
			chama_movimento_bola_1:
				jmp movimento_bola

		desce_raquete:
			call 	apaga_raquete
			cmp 	word[posicao_raquete], 0 ;limitar a posicao em zero da posicao
			je		chama_movimento_bola_2
			sub		word[posicao_raquete], 10
			call	desenha_raquete
			
			chama_movimento_bola_2:
				jmp movimento_bola

		aumenta_vel: ;logica da velocidade
			cmp 	word[velocidade], 3000 
			je		chama_movimento_bola_3;os 
			sub		word[velocidade], 3000 
			mov 	ax, [vel]
			inc 	ax
			mov		[vel],	ax
			call	print_velocidade
			
			chama_movimento_bola_3:
				jmp movimento_bola
			;velocidade maxima = 9k e a minima = 3k
		diminui_vel:
			cmp word[velocidade], 9000	
			je	chama_movimento_bola_4
			add	word[velocidade], 3000 
			mov 	ax, [vel]
			dec 	ax
			mov		[vel],	ax
			call	print_velocidade

			chama_movimento_bola_4:
				jmp movimento_bola
	ret
;**************************************************************
;FUNÇÃO SUBIR PLACAR
	increase_score: ;EM CASO DE REBATIDA, TEMOS 1 EM CASO DE NAO REBATIDA TEMOS ZERO
		cmp		byte[placar],	1		
		jz 		rebateu
		jmp		nao_rebateu
        
		rebateu:
			inc		word[player_points]
			mov	 	dl, 					34	;nessa posicao tiraremos o 00 e passaremos a contar o valor				
			mov 	[print_begin], 				dl
			mov  	ax, 					[player_points] 	 
			jmp 	pontuar	;os pontos serão somados

		nao_rebateu:
			inc		word[somar_pontos]
			mov	 	dl, 					39	;a mesma funcao sera feita para o 00 do computador				
			mov 	[print_begin], 				dl
			mov 	ax, [somar_pontos]	;os pontos serão somados
		
		pontuar:
			mov 	bx, 					10 ;divisor
			xor 	cx, 					cx	;zera o contaodr
		
		contagem: ;aqui sera feito a subida de valores
			xor 	dx, 					dx 
			div 	bx							;dividi o valor
			push 	dx 							;salva o resto no stack
			inc 	cx
			test 	ax, 					ax
			jnz 	contagem

			mov		byte[cor], 	branco_intenso
			mov 	bx, 		3
			sub 	bx, 		cx
			mov		dh, 		2			;posicao da linha em 0-29		
			mov 	dl, 		[print_begin]
			add 	dl,			bl

		ret_pontuar: ;essa pontuacao terá q estar em um loop ate x
			call 	cursor
			pop 	ax
			add 	ax, 		48
			call 	caracter
			inc		bx				
			inc		dl				
			loop 	ret_pontuar
    ret

;************************************************************************
;************************************************************************
;Saida do programa
	sair: ;Interrupcao utilizada para sair do programa
	    	CLI
	    	XOR     AX, AX
	    	MOV     ES, AX
	    	MOV     AX, [cs_dos]
	    	MOV     [ES:int9*4+2], AX
	    	MOV     AX, [offset_dos]
	    	MOV     [ES:int9*4], AX
			mov 	ah,0 ; modo de video
			mov 	al,[modo_anterior] ; recupera o modo anterior
			int 	10h 
	    	MOV     AH, 4Ch
	    	int     21h ;No final da interrupcao o programa e terminado
			
;************************************************************************
;************************************************************************
;Funcao delay atraves da interrupcao int 15h
	delay:
			pushf
			push 		ax
			push		cx
			push		dx
			push		di
		mov	ah,	86h ;interrupcao disponibilizada
		mov cx,	0
		mov	dx,	word[velocidade]
		int 15h
			pop		di
			pop		dx
			pop		cx
			pop		ax
			popf
		ret
		
;************************************************************************
;************************************************************************
;Escreve o titulo do trabalho (nome da materia, ano e semestre)
	titulo:
		mov		byte[cor],branco_intenso

		push		di
		push 		ax
		push 		bx
		push		cx
		push		dx
			
    	mov     	cx, 58			;numero de caracteres
    	mov     	bx, 0
    	mov     	dh, 1			;linha 0-29
    	mov     	dl, 10			;coluna 0-79

		loop_titulo:
			call	cursor
			mov     al,[bx+titulo_trabalho]
			call	caracter
			inc     bx				;proximo caracter
			inc		dl				;avanca a coluna
			loop    loop_titulo

		pop		dx
		pop		cx
		pop		bx
		pop		ax
		pop		bp
		ret

;Escreve o placar na segunda linha do retangulo branco
	escreve_placar:
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

		ret_escreve_placar:
			call	cursor
			   mov     al,	[bx+legenda_placar]
			call	caracter
			inc     bx
			inc		dl
			loop    ret_escreve_placar

		pop		dx
		pop		cx
		pop		bx
		pop		ax
		pop		bp
		pop		di
		pop		si
		ret

;************************************************************************
;************************************************************************
;Escreve "Velocidade Atual: "
	escreve_velocidade_atual:
		mov		byte[cor],branco_intenso
		push		di
		push 		ax
		push 		bx
		push		cx
		push		dx

    	mov     	cx, 19			;numero de caracteres
    	mov     	bx, 0
    	mov     	dh, 2			;linha 0-29
    	mov     	dl, 54			;coluna 0-79

		ret1:
			call	cursor
			mov     al,	[bx+velocidade_atual]
			call	caracter
			inc     bx				;proximo caracter
			inc		dl				;avanca a coluna
			loop    ret1

		pop		dx
		pop		cx
		pop		bx
		pop		ax	
		pop		di
		ret

;************************************************************************
;************************************************************************
;Escreve o numero correspondente a velocidade atual
	print_velocidade:
		mov		byte[cor],branco_intenso
			pushf
			push 		ax
			push		dx
			push		di
		mov		dh,		2
		mov	 	dl, 	72					; Coluna
		call	cursor
		mov  	ax, 	word[vel]			; valor numerico da velocidade atual
		call 	caracter
			pop		di
			pop		dx
			pop		ax
			popf
		ret

;************************************************************************
;************************************************************************
;Desenha o retangulo da interface
	interface:
		;Barra superior do retangulo
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
		
		;Barra da esquerda do retangulo
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
		
		;Barra da direita do retangulo
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
		
		;Barra inferior do retangulo
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
		
		;Borda Limite jogo
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
;************************************************************************

;************************************************************************
;Funcoes dos laboratorios feitos ao longo do semestre
;************************************************************************

;Funcao cursor
	; dh = linha (0-29) e  dl=coluna  (0-79)
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

;************************************************************************
;************************************************************************
;Funcao line
	; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
	line:
		push		bp
		mov		bp,sp
		pushf                        ;coloca os flags na pilha
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		mov		ax,[bp+10]   ; resgata os valores das coordenadas
		mov		bx,[bp+8]    ; resgata os valores das coordenadas
		mov		cx,[bp+6]    ; resgata os valores das coordenadas
		mov		dx,[bp+4]    ; resgata os valores das coordenadas
		cmp		ax,cx
		je		line2
		jb		line1
		xchg		ax,cx
		xchg		bx,dx
		jmp		line1
		line2:		; deltax=0
				cmp		bx,dx  ;subtrai dx de bx
				jb		line3
				xchg		bx,dx        ;troca os valores de bx e dx entre eles
		line3:	; dx > bx
				push		ax
				push		bx
				call 		plot_xy
				cmp		bx,dx
				jne		line31
				jmp		fim_line
		line31:		inc		bx
				jmp		line3
		;deltax <>0
		line1:
		; comparar m�dulos de deltax e deltay sabendo que cx>ax
			; cx > ax
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
				sub		si,ax	;(x-x1)
				mov		ax,[deltay]
				imul		si
				mov		si,[deltax]		;arredondar
				shr		si,1
		; se numerador (DX)>0 soma se <0 subtrai
				cmp		dx,0
				jl		ar1
				add		ax,si
				adc		dx,0
				jmp		arc1
		ar1:		sub		ax,si
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
				je		fim_line
				inc		si
				jmp		line4

		line5:		cmp		bx,dx
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
		; se numerador (DX)>0 soma se <0 subtrai
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
				je		fim_line
				inc		si
				jmp		line6

		fim_line:
				pop		di
				pop		si
				pop		dx
				pop		cx
				pop		bx
				pop		ax
				popf
				pop		bp
				ret		8

;************************************************************************
;************************************************************************
;Funcao caracter 
		; escrito na posicao do cursor
		; al= caracter a ser escrito
		; cor definida na variavel cor
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

;************************************************************************
;************************************************************************
;Funcao plot_xy
		; push x; push y; call plot_xy;  (x<639, y<479)
		; cor definida na variavel cor
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

;************************************************************************
;************************************************************************
;Funcao circle
		; push xc; push yc; push r; call circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
		; cor definida na variavel cor
	circle:
		push 	bp
		mov	 	bp,sp
		pushf                        ;coloca os flags na pilha
		push 	ax
		push 	bx
		push	cx
		push	dx
		push	si
		push	di

		mov		ax,[bp+8]    ; resgata xc
		mov		bx,[bp+6]    ; resgata yc
		mov		cx,[bp+4]    ; resgata r

		mov 	dx,bx	
		add		dx,cx       ;ponto extremo superior
		push    ax			
		push	dx
		call plot_xy

		mov		dx,bx
		sub		dx,cx       ;ponto extremo inferior
		push    ax			
		push	dx
		call plot_xy

		mov 	dx,ax	
		add		dx,cx       ;ponto extremo direita
		push    dx			
		push	bx
		call plot_xy

		mov		dx,ax
		sub		dx,cx       ;ponto extremo esquerda
		push    dx			
		push	bx
		call plot_xy

		mov		di,cx
		sub		di,1	 ;di=r-1
		mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y

		;aqui em cima a l�gica foi invertida, 1-r => r-1
		;e as compara��es passaram a ser jl => jg, assim garante 
		;valores positivos para d

		stay:				;loop
			mov		si,di
			cmp		si,0
			jg		inf       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
			mov		si,dx		;o jl � importante porque trata-se de conta com sinal
			sal		si,1		;multiplica por doi (shift arithmetic left)
			add		si,3
			add		di,si     ;nesse ponto d=d+2*dx+3
			inc		dx		;incrementa dx
			jmp		plotar
		inf:	
			mov		si,dx
			sub		si,cx  		;faz x - y (dx-cx), e salva em di 
			sal		si,1
			add		si,5
			add		di,si		;nesse ponto d=d+2*(dx-cx)+5
			inc		dx		;incrementa x (dx)
			dec		cx		;decrementa y (cx)

		plotar:	
			mov		si,dx
			add		si,ax
			push    si			;coloca a abcisa x+xc na pilha
			mov		si,cx
			add		si,bx
			push    si			;coloca a ordenada y+yc na pilha
			call plot_xy		;toma conta do segundo octante
			mov		si,ax
			add		si,dx
			push    si			;coloca a abcisa xc+x na pilha
			mov		si,bx
			sub		si,cx
			push    si			;coloca a ordenada yc-y na pilha
			call plot_xy		;toma conta do s�timo octante
			mov		si,ax
			add		si,cx
			push    si			;coloca a abcisa xc+y na pilha
			mov		si,bx
			add		si,dx
			push    si			;coloca a ordenada yc+x na pilha
			call plot_xy		;toma conta do segundo octante
			mov		si,ax
			add		si,cx
			push    si			;coloca a abcisa xc+y na pilha
			mov		si,bx
			sub		si,dx
			push    si			;coloca a ordenada yc-x na pilha
			call plot_xy		;toma conta do oitavo octante
			mov		si,ax
			sub		si,dx
			push    si			;coloca a abcisa xc-x na pilha
			mov		si,bx
			add		si,cx
			push    si			;coloca a ordenada yc+y na pilha
			call plot_xy		;toma conta do terceiro octante
			mov		si,ax
			sub		si,dx
			push    si			;coloca a abcisa xc-x na pilha
			mov		si,bx
			sub		si,cx
			push    si			;coloca a ordenada yc-y na pilha
			call plot_xy		;toma conta do sexto octante
			mov		si,ax
			sub		si,cx
			push    si			;coloca a abcisa xc-y na pilha
			mov		si,bx
			sub		si,dx
			push    si			;coloca a ordenada yc-x na pilha
			call plot_xy		;toma conta do quinto octante
			mov		si,ax
			sub		si,cx
			push    si			;coloca a abcisa xc-y na pilha
			mov		si,bx
			add		si,dx
			push    si			;coloca a ordenada yc-x na pilha
			call plot_xy		;toma conta do quarto octante

			cmp		cx,dx
			jb		fim_circle  ;se cx (y) est� abaixo de dx (x), termina     
			jmp		stay		;se cx (y) est� acima de dx (x), continua no loop


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

;************************************************************************
;************************************************************************
;Funcao full_circle
	; push xc; push yc; push r; call full_circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
	; cor definida na variavel cor					  
	full_circle:
		push 	bp
		mov	 	bp,sp
		pushf                        ;coloca os flags na pilha
		push 	ax
		push 	bx
		push	cx
		push	dx
		push	si
		push	di

		mov		ax,[bp+8]    ; resgata xc
		mov		bx,[bp+6]    ; resgata yc
		mov		cx,[bp+4]    ; resgata r

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
		mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y

		;aqui em cima a l�gica foi invertida, 1-r => r-1
		;e as compara��es passaram a ser jl => jg, assim garante 
		;valores positivos para d

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
			push	si		;coloca a abcisa y+xc na pilha			
			mov		si,bx
			sub		si,dx
			push    si		;coloca a ordenada yc-x na pilha
			mov		si,ax
			add		si,cx
			push	si		;coloca a abcisa y+xc na pilha	
			mov		si,bx
			add		si,dx
			push    si		;coloca a ordenada yc+x na pilha	
			call 	line

			mov		si,ax
			add		si,dx
			push	si		;coloca a abcisa xc+x na pilha			
			mov		si,bx
			sub		si,cx
			push    si		;coloca a ordenada yc-y na pilha
			mov		si,ax
			add		si,dx
			push	si		;coloca a abcisa xc+x na pilha	
			mov		si,bx
			add		si,cx
			push    si		;coloca a ordenada yc+y na pilha	
			call	line

			mov		si,ax
			sub		si,dx
			push	si		;coloca a abcisa xc-x na pilha			
			mov		si,bx
			sub		si,cx
			push    si		;coloca a ordenada yc-y na pilha
			mov		si,ax
			sub		si,dx
			push	si		;coloca a abcisa xc-x na pilha	
			mov		si,bx
			add		si,cx
			push    si		;coloca a ordenada yc+y na pilha	
			call	line

			mov		si,ax
			sub		si,cx
			push	si		;coloca a abcisa xc-y na pilha			
			mov		si,bx
			sub		si,dx
			push    si		;coloca a ordenada yc-x na pilha
			mov		si,ax
			sub		si,cx
			push	si		;coloca a abcisa xc-y na pilha	
			mov		si,bx
			add		si,dx
			push    si		;coloca a ordenada yc+x na pilha	
			call	line

			cmp		cx,dx
			jb		fim_full_circle  ;se cx (y) est� abaixo de dx (x), termina     
			jmp		stay_full		;se cx (y) est� acima de dx (x), continua no loop


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

;************************************************************************
;************************************************************************
;                            TABELA INTERRUPÇÕES
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

;************************************************************************
;************************************************************************
;Segmento de dados
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
		; 1 1 0 0 rosa
		; 1 1 0 1 magenta claro
		; 1 1 1 0 amarelo
		; 1 1 1 1 branco intenso
;************************************************************************
;************************************************************************
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

	;Dados para preenchimento do cabecalho da interface
	titulo_trabalho    	db  'Exercicio de Programacao de Sistemas Embarcados 1 - 2025/1'
	legenda_placar		db	'Joao Gabriel Santos Custodio 00 x 00 Computador'
	velocidade_atual	db	'Velocidade Atual: 1'

	;Dados
		modo_anterior	db	0
		linha   		dw  0
		coluna  		dw  0
		deltax			dw	0
		deltay			dw	0
		
	;Velocidade		
		velocidade  	dw  9000
		vel_raquete		dw	30
		vel				dw	49		;	1 em ascii	
		
	;Posicao
		x_upper  		dw  -2 ;Logica de movimentacao retirada do laboratorio feito em sala de aula
		y_upper		  	dw  2
		posicao_raquete dw	190
		
	;Pontuacao
		player_points	dw	0
		somar_pontos 	dw  0
		print_begin		dw	0
		placar			db	1

	    
	segment stack stack
	    		resb 		512
	stacktop:
