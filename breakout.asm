
#Display:
#Unit Width -> 8
#Unit Height -> 8
#Display Width -> 512
#Display Height -> 256
#Base adress -> 010040000


#numero de linhas:32,pois 256(altura)/8(numero de bits por pixel)=32
#numero de colunas:64,pois 512(largura)/8(numero de bits por pixel)=64

.data
	#a primeira linha deve ser reservada para as cores e outras definicoes
	#a serem postas na memoria
	vermelho:.word 0x00FF0000
	laranja: .word 0x00FFA500
	amarelo:.word  0x00FFFF00
	verdeClaro: .word 0x007CFC00
	verde:	.word 0x00008000
	#espaco1: .space 1024
	azul:	.word 0x000000FF
	preto:	.word 0x00000000
	cinza:	.word 0x00808080
	roxo: .word 0x00800080
	cinzaEscuro: .word 0x002F4F4F
	azulEscuro : .word 0x0000008B
	ciano:	.word 0x0000FFFF
	branco: .word 0x00FFFFFF
	.space 40  
	divirta_se: .asciiz "A movimentação é feita com ponto(>) e vírgula(<), pressione enter para começar"
	vidas:	.asciiz "\n\n\n\n\n\n\n\n\nVidas: "
	pontos: .asciiz "\nPontos: "
	gameOver: .asciiz "Game Over!\n\nPontos: "
	congrats: .asciiz "Parabéns!Você ganhou o jogo!"
	
	
	
	
.text
#mostrando mensagem inicial
MInicial:    
	la $a0, divirta_se
	li $a1, 1
	li $v0, 55
	syscall

again:	jal telaInicial
	nop
	
			
	li $v0,32
	li $a0,100
	syscall
	
	jal clearBitMap
	nop
	
	li $v0,32
	li $a0,100
	syscall
	
	jal tecladoStart
	nop
	
	beq $v0,1,iniciaJogo	
	nop
	
	j again
	nop

iniciaJogo:

	
	#constroi inicialmente as linhas de blocos na memoria .data
#again:	
	jal constroiLinhasMem
	nop
	
	#constroi inicialmente as colunas e linhas limites em .data
	jal constroiLimitesMem
	nop
	

	#la $t9,laranja
	#lw $t8,0($t9)
	#lui $t7,0x1001
	#addi $t7,$t7,6672
	#sw $t8,0($t7)
	
	#j again
	#nop	
	#preenche de preto todo o bitmap da heap
	jal clearBitMap
	nop
	
	li $s0,10		#guarda o numero de vidas
	li $s1,0		#guarda a pontuacao
	
	la $a0,vidas
	li $v0,4
	syscall
	
	move $a0,$s0
	li $v0,1
	syscall
	
	
			

	move $a0,$0		#zera o a0,que sera argumento para a subrotina pegaEntrada,
				#que movera o paddle de acordo com a entrada do usuario
	
	li $a1,6776#$0		#recebe o deslocamento do paddle(0 a 8192)
	li $a2,4736		#recebe a posicao relativa da bola no bitmap
	li $a3,0		#0->identifica movimento x++,y++
				#1->identifica movimento x++,y--
				#2->identifica movimento x--,y--
				#3->identifica movimento x--,Y++

				
	#constroi as linhas na .heap com base nos endereços em .data
loop:	
	jal contaPontos
	nop
	
	#se for menor que 2304 ou maior que 3840,esta fora das linhas de blocos de cor
	slti $s2,$a2,2304
	beq $s2,1,fazNorm
	nop
	slti $s2,$a2,3840
	beq $s2,0,fazNorm
	nop 
	
	j pulaFazNorm
	nop
	
fazNorm:	
	jal normalizaBlocos
	nop
pulaFazNorm:
	jal constroiLimitesMem
	nop

	jal constroiLinhasBMP
	nop
	
	#li $a0,100
	#li $v0,32
	#syscall
	
	jal pegaEntrada		#-1 pra esquerda,1 para direita em v0 como retorno
	nop
	
	move $a0,$v0		#a0 recebe o retorno da entrada do teclado
	move $a1,$v1		#a1 recebe o deslocamente relativo a posicao base do paddle
	
	jal montaPaddle
	nop
	
	move $a1,$v1
	
#---------------------------------Movimenta  a bola----------------------
	
		andi $t2,$t2,0x0000
		lui $t2,0x1001		#posicao atual da bola
		add $t2,$t2,$a2
		
		la $t0,ciano
		lw $t1,0($t0)
	
		sw $t1,0($t2)		#pinta na .data a bola
	
		#delay-sleep
		li $a0,75#50#100
		li $v0,32
		syscall
		
		#la $t6,roxo
		#lw $t7,0($t6)
		
		#lui $t8,0x1001
		#addi $t8,$t8,2312
		
		#sw $t7,0($t8)
		
		slti $t3,$a2,8704		#endereço da ultima linha da .data
		beq $t3,$0,resetaBola		#a .data tem duas linhas reservadas para
		nop				#dados de cores
		
		beq $a3,0,movimento0		#x++,y++
		nop
		
		beq $a3,1,movimento1		#x++,y--
		nop
		
		beq $a3,2,movimento2		#x--,y--
		nop
		
		beq $a3,3,movimento3		#x--,y++
		nop
		
		
#--------------------------------Movimento 0(x++,y++)-------------------------------		
movimento0:	## X++,Y++ 


		move $t5,$t2			#pinta de preto a posicao anterior da bola
		addi $t5,$t5,-260#-260
		
		sw $0,0($t5)

		addi $a2,$a2,260#260		#x++ e y++->256 para outra linha e 4
						#para outra coluna
		li $t5,0
		lui $t5,0x1001			#proxima posicao diagonal
		add $t5,$t5,$a2
		
		lw $t8,0($t5)			#pega a cor nessa posicao de .data
		
		#la $t6,cinzaEscuro
		#lw $t7,0($t6)
		
		slti $t3,$a2,8704		#endereço da ultima linha da .data
		beq $t3,$0,resetaBola		#a .data tem duas linhas reservadas para
		nop	
		
		bne $t8,$0,testaColisao0
		nop
		
		#beq $t8,$t7,colisaoPaddle01	#colidiu com paddle
		#nop 
		
		j loop
		nop
		
testaColisao0:
		la $t6,cinza           	#Carrega cor cinza  para comparar colisao parede
 		lw $t7, ($t6)
		
		beq $t8,$t7, colisaoParede0     
		nop
		
		la $t6,cinzaEscuro           	#Carrega cinza escuro  para comparar
 		lw $t7, ($t6)			#colisao com o paddle
		
		beq $t8,$t7, colisaoPaddle01     
		nop
		
		j colisaoBloco0    		#eh colisao com bloco de cor  
		nop
		
colisaoParede0:
		#Movimento 0(x++,y++) encontrou parede, muda para movimento 3(x--,y++)
		andi $t2,$t2,0x0000     
		lui $t2,0x1001		#posicao atual da bola
		add $t2,$t2,$a2	
		addi $t2,$t2,-260#-260	#previamente 260 foi adicionado para teste de cor 	 		 
					#da proxima posiçao
		sw $0,0($t2)		#pinta a bola de preto
		
		addi $a2,$a2,-260#-260
		
		blt $a2,6500,sohPula0		#se for menor que 6k,nao adiciona espaco
		nop				#para retorno da bola
		
		addi $a2,$a2,-260#-260		
		addi $a2,$a2,-260#-260
		addi $a2,$a2,-260#-260			
		#addi $a2,$a2,-8   	#x--,y++
		
sohPula0:	li $a3, 3		#troca para movimento 3
			
		j loop
		nop
		
colisaoPaddle01:	
		#addi $t2,$t2,-260	#previamente 260 foi adicionado para teste de cor 	 		 
					#da proxima posiçao
		sw $0,0($t2)
		
	#	addi $a2,$a2,8		#move duas posicoes a direita
		#addi $a2,$a2,-256	#move para cima
		#addi $a2,$a2,4
		#addi $a2,$a2,-256
		
		li $a3,1			#muda movimento de 0 para 1
		
		
		##CHAMANDO O SOM
		move $t3,$a3
		move $t2,$a2
		move $t1, $a1
		
		li $a0, 79   #Tom
		li $a1, 500  #Duração
		li $a2, 120  #Instrumento 
		li $a3, 127  #Volume
		li $v0,31    #Chamada syscall
		syscall
		
		move $a3,$t3
		move $a2,$t2
		move $a1, $t1
		
		
		
		j loop
		nop
		
colisaoBloco0:	sw $0,0($t2)			#pinta a posicao atual da bola de preto

		li $t2,0
		lui $t2,0x1001			#endereço da proxima posiçao
		add $t2,$t2,$a2
		
		
		la $t6,vermelho	
		lui $t8,0x1001
		addi $t8,$t8,2312
		
		

		
		
iteraBlocos:		
				
		lw $t7,0($t6)
		lw $t4,0($t8)			#carrega a cor da linha atual
		beq $t4,$t7,eliminaBloco	#se tiverem a mesma cor,eliminar bloco
		nop				#na determinada posiçao
		
		addi $t6,$t6,4
		addi $t8,$t8,256
		
		j iteraBlocos
		nop
		
eliminaBloco:	
		sub $t9,$t2,$t6			#subtrai o valor da posicao a ser eliminada		
						#de seu inicio de linha
									
		li $t7,8			#valor de um bloco
procuraBloco:		
		slt $t8,$t9,$t7			#se for menor que o valor em t7,
						#pertence ao n bloco de cor e carrega 1 a t8
		beq $t8,1,encontrouBloco
		nop
		
		addi $t7,$t7,8
		
		j procuraBloco
		nop

encontrouBloco:	
		addi $t7,$t7,-8			#denota a posiçao a começar a eliminar
		add $t6,$t6,$t7			
									
		sw $0,0($t6)   		#pintou o bloco de preto (apos colisao)
		sw $0,4($t6)   		#pintou o bloco de preto (apos colisao)
		sw $0,8($t6)   		#pintou o bloco de preto (apos colisao)
		sw $0,12($t6)   		#pintou o bloco de preto (apos colisao)
		
		#addi $t2,$t2,-260	#previamente 260 foi adicionado para teste de cor 	 		 
					#da proxima posiçao
					
		addi $a2,$a2,-260#-260	#previamente 260 foi adicionado para teste de cor 	 		 
					#da proxima posiçao
		
		#addi $a2,$a2,-504       #movimentou pra linha anterior (x++,y--)
		#addi $a2,$a2,8 
			
		li $a3,1		#muda movimento de 0 para 1
		
		
		##CHAMANDO O SOM
		move $t3,$a3
		move $t2,$a2
		move $t1, $a1
		
		li $a0, 100  #Tom
		li $a1, 400  #Duração
		li $a2, 120  #Instrumento 
		li $a3, 127  #Volume
		li $v0,31    #Chamada syscall
		syscall
		
		move $a3,$t3
		move $a2,$t2
		move $a1, $t1
		
		
		j loop
		nop
		
#--------------------------------Movimento 1(x++,y--)-------------------------------


movimento1:	##x++, y--
		move $t5,$t2			#pinta de preto a posicao anterior da bola
		addi $t5,$t5,252
		sw $0,0($t5)	
		
		addi $a2,$a2,-252		#x++ e y-- ->-256 para outra linha e -4
						#para outra coluna
		li $t5,0
		lui $t5,0x1001			#posicao anterior diagonal
		add $t5,$t5,$a2
		
		lw $t8,0($t5)			#pega a cor nessa posicao de .data
		
		
		bne $t8,$zero, testaColisao1      #se houver colisao apos movimento1
		nop
		
		j loop
		nop					

testaColisao1:
		la $t6,cinza           	#Carrega cor cinza  para comparar colisao parede
 		lw $t7, ($t6)
		
		beq $t8,$t7, colisaoParede1     
		nop
		
		la $t6,cinzaEscuro      #Carrega cinza escuro  para comparar colisao parede
 		lw $t7, ($t6) 	
 		
 		beq $t8,$t7, colisaoCima1	
		nop
		
		j colisaoBloco1    		#Colisao com bloco de cor  
		nop


colisaoBloco1:	
		#sw $0,0($t2)
		
		li $t2,0
		lui $t2,0x1001		#posicao atual da bola
		add $t2,$t2,$a2
		
		la $t6,vermelho	
		lui $t8,0x1001
		addi $t8,$t8,2312
		
		
		
		
iteraBlocos1:		
				
		lw $t7,0($t6)
		lw $t4,0($t8)			#carrega a cor da linha atual
		beq $t4,$t7,eliminaBloco1	#se tiverem a mesma cor,eliminar bloco
		nop				#na determinada posiçao
		
		addi $t6,$t6,4
		addi $t8,$t8,256
		
		j iteraBlocos1
		nop
		
eliminaBloco1:	
		sub $t9,$t2,$t6			#subtrai o valor da posicao a ser eliminada		
						#de seu inicio de linha
									
		li $t7,8#16			#valor de um bloco
procuraBloco1:		
		slt $t8,$t9,$t7			#se for menor que o valor em t7,
						#pertence ao n bloco de cor e carrega 1 a t8
		beq $t8,1,encontrouBloco1
		nop
		
		addi $t7,$t7,8#16
		
		j procuraBloco1
		nop

encontrouBloco1:	
		addi $t7,$t7,-8#-4	#denota a posiçao a começar a eliminar
		add $t6,$t6,$t7			
									
		sw $0,0($t6)   		#pintou o bloco de preto (apos colisao)
		sw $0,4($t6)   		#pintou o bloco de preto (apos colisao)
		sw $0,8($t6)   		#pintou o bloco de preto (apos colisao)
		sw $0,12($t6)   		#pintou o bloco de preto (apos colisao)
		
		#addi $t2,$t2,252	#previamente -252 foi adicionado para teste de cor 	 		 
					#da proxima posiçao
		#sw $0,0($t2)			#pinta a posicao atual da bola de preto
		
		addi $a2,$a2,252	#previamente -252 foi adicionado para teste de cor 	 		 
					#da proxima posiçao
		addi $a2,$a2,260#260
		
			
		li $a3,0		#muda movimento de 1 para 0
		
	
		##CHAMANDO O SOM
		move $t3,$a3
		move $t2,$a2
		move $t1, $a1
		
		li $a0, 100  #Tom
		li $a1, 400  #Duração
		li $a2, 120  #Instrumento 
		li $a3, 127  #Volume
		li $v0,31    #Chamada syscall
		syscall
		
		move $a3,$t3
		move $a2,$t2
		move $a1, $t1
		
		
		
		j loop
		nop

colisaoParede1:
		#Movimento 1(x++,y--) encontrou parede, muda para movimento 2(X--,Y--)
		li $t2,0     
		lui $t2,0x1001		#posicao atual da bola
		add $t2,$t2,$a2		 		 
		addi $t2,$t2,252	#previamente -252 foi adicionado para teste de cor 	 		 
					#da proxima posiçao
					
		sw $0,0($t2)		#pinta a bola de preto
		
		addi $a2,$a2,252
		
		blt $a2,6500,sohPula1
		nop
		
		addi $a2,$a2,252
		addi $a2,$a2,252
		addi $a2,$a2,252
		#addi $a2,$a2,-8
		#addi $a2,$a2, -520   	#x--,y--
		
sohPula1:	li $a3,2		#troca para movimento 2
			
		j loop
		nop
		
colisaoCima1:	#muda movimento 1(x++,y--) para movimento 0(x++,y++)
		
		li $t2,0     
		lui $t2,0x1001		#posicao atual da bola
		add $t2,$t2,$a2		 		 
		addi $t2,$t2,252	#previamente -252 foi adicionado para teste de cor 	 		 
					#da proxima posiçao
					
		sw $0,0($t2)		#pinta a bola de preto
		
		addi $a2,$a2,252
		#addi $a2,$a2,520   	#x++,y++
		
		li $a3,0		#troca para movimento 2
			
		j loop
		nop

#--------------------------------Movimento 2(x--,y--)-------------------------------
 
movimento2:

		move $t5,$t2			#pinta de preto a posicao anterior da bola
		addi $t5,$t5,260
		
		sw $0,0($t5)	
		addi $a2,$a2,-260		#x-- e y-- ->-256 para outra linha e -4
						#para outra coluna
		li $t5,0
		
		#proxima posicao diagonal	
		lui $t5,0x1001			
		add $t5,$t5,$a2			
		
		lw $t8,0($t5)			#pega a cor nessa posicao de .data
		
		bne $t8,$0,testaColisao2
		nop
		
		j loop
		nop
		
testaColisao2:
		la $t6,cinza           	#Carrega cor cinza  para comparar colisao parede
 		lw $t7, ($t6)
		
		beq $t8,$t7, colisaoParede2     
		nop
		
		la $t6,cinzaEscuro
		lw $t7,0($t6)
		
		beq $t8,$t7,colisaoCima2
		nop
		
		j colisaoBloco2    		#eh colisao com bloco de cor  
		nop
		
colisaoParede2:




		#Movimento 2(x--,y--) encontrou parede, muda para movimento 1(x++,y--)
		andi $t2,$t2,0x0000     
		lui $t2,0x1001		#posicao atual da bola
		add $t2,$t2,$a2		 		 
		addi $t2,$t2,260	#previamente -260 foi adicionado para teste de cor 	 		 
					#da proxima posiçao
					
		sw $0,0($t2)		#pinta a bola de preto
		
		addi $a2,$a2,260
		
		blt $a2,6000,sohPula2
		nop
		
		addi $a2,$a2,260
		addi $a2,$a2,260
		addi $a2,$a2,260
		addi $a2,$a2,8
		#addi $a2,$a2,-504   	#x++,y--
		
sohPula2:	li $a3,1		#troca para movimento 1
			
		j loop
		nop

colisaoBloco2:	#Movimento 2(x--,y--) encontrou bloco, muda para movimento 3(x--,y++)

		sw $0,0($t2)			#pinta a posicao atual da bola de preto

		li $t2,0
		lui $t2,0x1001		#posicao atual da bola
		add $t2,$t2,$a2
		
		
		
		la $t6,vermelho	
		lui $t8,0x1001
		addi $t8,$t8,2312
		
iteraBlocos2:		
				
		lw $t7,0($t6)
		lw $t4,0($t8)			#carrega a cor da linha atual
		beq $t4,$t7,eliminaBloco2	#se tiverem a mesma cor,eliminar bloco
		nop				#na determinada posiçao
		
		addi $t6,$t6,4
		addi $t8,$t8,256
		
		j iteraBlocos2
		nop
		
eliminaBloco2:	
		sub $t9,$t2,$t6			#subtrai o valor da posicao a ser eliminada		
						#de seu inicio de linha
									
		li $t7,8#16			#valor de um bloco
procuraBloco2:		
		slt $t8,$t9,$t7			#se for menor que o valor em t7,
						#pertence ao n bloco de cor e carrega 1 a t8
		beq $t8,1,encontrouBloco2
		nop
		
		addi $t7,$t7,8#16
		
		j procuraBloco2
		nop

encontrouBloco2:	
		addi $t7,$t7,-8#-4			#denota a posiçao a começar a eliminar
		add $t6,$t6,$t7			
									
		sw $0,0($t6)   		#pintou o bloco de preto (apos colisao)
		sw $0,4($t6)   		#pintou o bloco de preto (apos colisao)
		sw $0,8($t6)   		#pintou o bloco de preto (apos colisao)
		sw $0,12($t6)   		#pintou o bloco de preto (apos colisao)
		
		
		addi $a2,$a2,260	#previamente -260 foi adicionado para teste de cor 	 		 
					#da proxima posiçao
		addi $a2,$a2,252
		
		#addi $a2,$a2,504      	#movimentou pra proxima linha diagonalmente(x--,y++)
			
		li $a3,3		#muda movimento de 2 para 3
		
		
		##CHAMANDO O SOM
		move $t3,$a3
		move $t2,$a2
		move $t1, $a1
		
		li $a0, 100  #Tom
		li $a1, 400  #Duração
		li $a2, 120  #Instrumento 
		li $a3, 127  #Volume
		li $v0,31    #Chamada syscall
		syscall
		
		move $a3,$t3
		move $a2,$t2
		move $a1, $t1
		
		
		
		
		j loop
		nop
		
colisaoCima2:	#muda movimento 2(x--,y--) para movimento 3(x--,y++)
		
		li $t2,0     
		lui $t2,0x1001		#posicao atual da bola
		add $t2,$t2,$a2		 		 
		addi $t2,$t2,260	#previamente -252 foi adicionado para teste de cor 	 		 
					#da proxima posiçao
					
		sw $0,0($t2)		#pinta a bola de preto
		
		addi $a2,$a2,260
		#addi $a2,$a2,504   	#x--,y++
		
		li $a3,3		#troca para movimento 3
		
		
					
		j loop
		nop
		
#----------------------------------Movimento 3(x--,y++)----------------------


movimento3:	## X--,Y++ 


		move $t5,$t2			#pinta de preto a posicao anterior da bola
		addi $t5,$t5,-252
		
		sw $0,0($t5)

		addi $a2,$a2,252		#x-- e y++->256 para outra linha e -4
						#para outra coluna
		li $t5,0
		lui $t5,0x1001			#proxima posicao diagonal
		add $t5,$t5,$a2
		
		lw $t8,0($t5)			#pega a cor nessa posicao de .data
		
			
		slti $t3,$a2,8704		#endereço da ultima linha da .data
		beq $t3,$0,resetaBola		#a .data tem duas linhas reservadas para
		nop	
					
		bne $t8,$0,testaColisao3
		nop
		
		j loop
		nop
		
testaColisao3:
		la $t6,cinza           	#Carrega cor cinza  para comparar colisao parede
 		lw $t7, ($t6)
		
		beq $t8,$t7, colisaoParede3    
		nop
		
		la $t6,cinzaEscuro           	#Carrega cinza escuro  para comparar
 		lw $t7, ($t6)			#colisao com o paddle
		
		beq $t8,$t7, colisaoPaddle32     
		nop
		
		j colisaoBloco3   		#eh colisao com bloco de cor  
		nop
		
colisaoParede3:
		#Movimento 3(x--,y++) encontrou parede, muda para movimento 0(x++,y++)
		andi $t2,$t2,0x0000     
		lui $t2,0x1001		#posicao atual da bola
		add $t2,$t2,$a2
		addi $t2,$t2,-252	#previamente -252 foi adicionado para teste de cor 	 		 
					#da proxima posiçao	
					
		sw $0,0($t2)		#pinta a bola de preto	 		 
		
		addi $a2,$a2,-252
		
		blt $a2,6500,sohPula3
		nop
		
		addi $a2,$a2,-252
		addi $a2,$a2,-252
		addi $a2,$a2,-252
		addi $a2,$a2,-252
		#addi $a2,$a2,8
		#addi $a2,$a2,520  	#x++,y++
		
sohPula3:	li $a3,0		#troca para movimento 0
			
		j loop
		nop
		
colisaoPaddle32:
		#addi $t2,$t2,252	#previamente -252 foi adicionado para teste de cor 	 		 
					#da proxima posiçao
		sw $0,0($t2)			#pinta de preto a posicao atual
		addi $a2,$a2,-8		#move duas posicoes a esquerda
		#addi $a2,$a2,-520	#move para cima
		
		addi $a2,$a2,8
		
		li $a3,2			#muda movimento de 3 para 2
		
		
		##CHAMANDO O SOM
		move $t3,$a3
		move $t2,$a2
		move $t1, $a1
		
		li $a0, 79   #Tom
		li $a1, 500  #Duração
		li $a2, 120  #Instrumento 
		li $a3, 127  #Volume
		li $v0,31    #Chamada syscall
		syscall
		
		move $a3,$t3
		move $a2,$t2
		move $a1, $t1
		
		
		j loop
		nop
		
colisaoBloco3:	sw $0,0($t2)			#pinta a posicao atual da bola de preto

		andi $t2,$t2,0x0000
		lui $t2,0x1001		#posicao atual da bola
		add $t2,$t2,$a2
		
		
		
		la $t6,vermelho	
		lui $t8,0x1001
		addi $t8,$t8,2312
		
iteraBlocos3:		
				
		lw $t7,0($t6)
		lw $t4,0($t8)			#carrega a cor da linha atual
		beq $t4,$t7,eliminaBloco3	#se tiverem a mesma cor,eliminar bloco
		nop				#na determinada posiçao
		
		addi $t6,$t6,4
		addi $t8,$t8,256
		
		j iteraBlocos3
		nop
		
eliminaBloco3:	
		sub $t9,$t2,$t6			#subtrai o valor da posicao a ser eliminada		
						#de seu inicio de linha
									
		li $t7,8#16			#valor de um bloco
procuraBloco3:		
		slt $t8,$t9,$t7			#se for menor que o valor em t7,
						#pertence ao n bloco de cor e carrega 1 a t8
		beq $t8,1,encontrouBloco3
		nop
		
		addi $t7,$t7,8#16
		
		j procuraBloco3
		nop

encontrouBloco3:	
		addi $t7,$t7,-8#-16	#denota a posiçao a começar a eliminar
		add $t6,$t6,$t7			
									
		sw $0,0($t6)   		#pintou o bloco de preto (apos colisao)
		sw $0,4($t6)   		#pintou o bloco de preto (apos colisao)
		sw $0,8($t6)   		#pintou o bloco de preto (apos colisao)
		sw $0,12($t6)   		#pintou o bloco de preto (apos colisao)
					
		
		#addi $a2,$a2,-260       #movimentou pra linha anterior (x--,y--)
		
		addi $a2,$a2,-252
		
		addi $a2,$a2,-260
			
		li $a3,2		#muda movimento de 3 para 2
		
		
		
		##CHAMANDO O SOM
		move $t3,$a3
		move $t2,$a2
		move $t1, $a1
		
		li $a0, 100  #Tom
		li $a1, 400  #Duração
		li $a2, 120  #Instrumento 
		li $a3, 127  #Volume
		li $v0,31    #Chamada syscall
		syscall
		
		move $a3,$t3
		move $a2,$t2
		move $a1, $t1
		
		
		
		j loop
		nop


resetaBola:	
		move $t5,$t2
		
		
		sw $0,0($t5)
		li $a2,0
		li $a2,4736
		
		jal contaPontos
		nop		
		
		
		addi $s0,$s0,-1
		
		beq $s0,0,final
		nop
		
		la $a0,vidas
		li $v0,4
		syscall
		
		move $a0,$s0
		li $v0,1
		syscall
		
		la $a0,pontos
		li $v0,4
		syscall
		
		move $a0,$s1
		li $v0,1
		syscall
		
		
	
	
		j loop
		nop						
				
								
		j final
		nop
		
		
#colisaoBloco:
#		sw $0,0($t2)			#pinta de preto a posicao atual
#		addi $a2,$a2,260
		
#		li $a3,0			#muda movimento de 1 para 0
		
#		j loop
#		nop
#		j final
#		nop



#para atualizar as cores dos blocos, deve-se ler os blocos da memoria estatica(0x10010000)
#e copia-los sempre para a heap/bitmap atraves de uma subrotina que diga que pixel deve ser
#atualizado e pintado de preto

#--------------------------------Carrega as linhas na memoria .data-----------------------

constroiLinhasMem:
		lui $t2,0x1001#0x1001		#ponteiro do inicio da dos dados de linhas
		ori $t2,$t2,0x0900#0x0100
		
		li $t3,0	#contador de blocos/quadrados construídos
		li $t4,64#32	#denota o numero de blocos por linha
		
		la $t0,vermelho
		
		la $t6,384#192	#numero total de blocos nas linha -> 32*6
		la $t7,0	#conta o numero global de blocos contruidos
		
		lw $t1,0($t0)
	
pinta:
	
		sw $t1,0($t2)
	
		addi $t2,$t2,4
		addi $t3,$t3,1
	
		beq $t3,$t4,acabouLinha
		nop
		
		beq $t6,$t7,acabouRotina
	
		j pinta
		nop

		#se acabou a linha,deve mover o ponteiro t5 para a proxima posicao e pegar
		#o valor da outra cor para pintar a proxima linha
acabouLinha:	
		add $t7,$t7,$t3			#adiciona ao numero global de blocos
		move $t3,$0			#zera o contador de blocos para a proxima cor
		
		addi $t0,$t0,4			#aponta para a proxima cor
		lw $t1,0($t0)			#carrega essa nova cor
		
		j pinta
		nop
	
acabouRotina: 	jr $ra
		nop
		
		
		
		
#---------------------------da um clear no bitmap,iniciando-o com a cor preta------------ 		
		
		
		
clearBitMap:	
		#la $t3,azul			#utilizados para teste do bitmap
		#lw $t4,0($t3)
		li $t2,0
		lui $t0,0x1004
		li $t1,2048			#eh o numero de blocos->64 colunas x 32 linhas
						#=2048 e pinta de preto(0x00000000)
						#todos os blocos 
clear:		sw $0,0($t0)			#utiliza $t4 ao inves de $0 nos testes
		addi $t0,$t0,4			
		addi $t2,$t2,1
		
		beq $t2,$t1,acabouClear
		nop
		
		j clear
		nop
		
acabouClear:	jr $ra
		nop		
		
		
		
#-------------------------Constroi o bitmao na heap a partir da data------------------------		
		
		
		
constroiLinhasBMP:	
		lui $t2,0x1004			#ponteiro do inicio da dos dados de linhas
		#ori $t2,$t2,0x0900#0x0100
		
		li $t3,0			#contador de blocos/quadrados construídos
		li $t4,2048#384#192		#denota o numero total de blocos
		
		lui $t0,0x1001
		ori $t0,$t0,0x200
		#ori $t0,$t0,0x0900#0x0100	#endereço dos blocos em .data
		
		
pintaBMP:
		lw $t1,0($t0)			#carrega a cor em .data
		
		sw $t1,0($t2)			#escrever a cor no BitMap Display da .heap
	
		addi $t2,$t2,4			#incrementa os ponteiros da heap e da data
		addi $t0,$t0,4			#e o numero de contagens de blocos
		addi $t3,$t3,1			#para haver sincronizacao no processo
	
		beq $t3,$t4,acabouCopia
		nop
	
		j pintaBMP
		nop
		
acabouCopia:	jr $ra
		nop
		
		
#--------------------Constroi colunas e linha limites de colisao na memoria---------------		
		
		
constroiLimitesMem:	
		lui $t0,0x1001			#ponteiro para o inicio do bitmap da .data
		ori $t0,$t0,0x200#512		#utilizavel, afinal deve ser reservada uma
						#linha para as cores		
		li $t1,128#32			#numero de blocos para duas linhas
		move $t2,$0			#contador dos blocos da primeira linha
		
		la $t3,cinzaEscuro		#carrega o endereço do cinza escuro
						#para as duas primeiras linhas
		lw $t4,0($t3)			#carrega o cinza
pintaLimite:	
		sw $t4,0($t0)
	
		addi $t0,$t0,4
		addi $t2,$t2,1
	
		beq $t2,$t1,acabouPrimeirasLinhas
		nop
		
		j pintaLimite
		nop

acabouPrimeirasLinhas:
		la $t3,cinza		#cinza eh a cor das colunas limite laterais
		lw $t4,0($t3)
		
		move $t2,$0		#zera o contador
		li $t1,30		#numero de "linhas"a mais no bitmap,delimita ate onde pintar
montaColunaEsquerda:
		sw $t4,0($t0)		#pinta as duas primeiras colunas de cinza,como limite
		sw $t4,4($t0)
		
		addi $t0,$t0,256#128	#atualiza ponteiro para o bloco da linha de baixo,
		addi $t2,$t2,1		#mesma coluna(32 blocos,4 bytes por bloco-64*4)
		
		beq $t2,$t1,acabouColunaEsquerda
		nop
	
		j montaColunaEsquerda
		nop
		
acabouColunaEsquerda:	
		move $t2,$0		#zera o contador
		li $t1,30		#numero de "linhas"a mais no bitmap,delimita ate onde pintar
		
		lui $t0,0x1001		
		ori $t0,$t0,1276	#endereço em t0 sera o da ultima coluna da quinta 
					#linha de .data,que corresponde a quarta de .heap
					#pois a primeira linha de .data eh reservada as cores
montaColunaDireita:
		sw $t4,0($t0)		#pinta as duas primeiras colunas de cinza,como limite
		sw $t4,-4($t0)
		
		addi $t0,$t0,256#128	#atualiza ponteiro para o bloco da linha de baixo,
		addi $t2,$t2,1		#mesma coluna(32 blocos,4 bytes por bloco-64*4)
		
		beq $t2,$t1,acabaLimite
		nop
	
		j montaColunaDireita
		nop		
						
acabaLimite:	jr $ra
		nop
		
			
				
					
#--------------------------Desenha o paddle no bitmap da heap-----------------------							
		
		
montaPaddle:	
		li $t2,0x00000000
		lui $t2,0x1001
		add $t2,$t2,$a1		#6752
		
		#li $t7,0
		
		
		li $t3,6		#tamanho do paddle horizonalmente
		li $t4,0		#contador de blocos do paddle construidos
		
		la $t0,cinzaEscuro
		
		beq $a0,1,vaiDireita
		nop
		
		beq $a0,-1,vaiEsquerda
		nop
		
		lui $t7,0x1001		
		add $t7,$t2,$t7
		
		#li $t8,6672
		#beq $t7,$t8,pintaPaddleEsquerda
		#nop
		
		
		j pintaPaddleDireita
		nop
		
vaiDireita:	move $t5,$t2
		addi $t5,$t5,8			#adiciona 8 do movimento
		addi $t5,$t5,16#28			#e 20 dos blocos
		
		lw $t6,0($t5)
		
		beq $t6,0x808080,ajustaDeslocamentoDir  #se for cinza o proximo bloco,
		nop	
		
		j pintaPaddleDireita
		nop	
		
vaiEsquerda:
		move $t5,$t2
		addi $t5,$t5,-8
		#addi $t5,$t5,-4
		#addi $t5,$t5,-16
		
		lw $t6,0($t5)
		
		beq $t6,0x808080,ajustaDeslocamentoEsq  #se for cinza o proximo bloco,
		nop	
		
		j pintaPaddleEsquerda
		nop	
				
		
		#add $t2,$t2,$a1
pintaPaddleDireita:		
		lw $t1,0($t0)
	
		sw $t1,0($t2)
		
		addi $t4,$t4,1
		addi $t2,$t2,4		
		
		
		beq $t3,$t4,acabouPaddle
		nop
		
		j pintaPaddleDireita
		nop

				
ajustaDeslocamentoEsq:
				#volta a primeira posicao da linha do paddle
		#addi $a1,$a1,8 
		#add $t2,$t2,$a1
		#addi $t2,$t2,8
		addi $a1,$a1,8
		li $t4,2
		j pintaPaddleEsquerda		
		nop
		
ajustaDeslocamentoDir:
				#volta a ultima posicao da linha do paddle
		#addi $a1,$a1,-8
		#add $t2,$t2,$a1
		#addi $t2,$t2,-8
		addi $a1,$a1,-8
		li $t4,2
		j pintaPaddleDireita		
		nop		
		
pintaPaddleEsquerda:	
		lw $t1,0($t0)
	
		sw $t1,0($t2)
		
		addi $t4,$t4,1
		addi $t2,$t2,4  #-4		
		
		
		beq $t3,$t4,acabouPaddleEsq
		nop
		
		j pintaPaddleEsquerda
		nop

		
acabouPaddleEsq:
		sw $0,0($t2)
		sw $0,4($t2)			#pinta de preto o fim do paddle anterior
		sw $0,8($t2)
		sw $0,12($t2)
		#sw $0,16($t2)
		move $v1,$a1
		jr $ra
		nop
acabouPaddle:
		#sw $0,-20($t2)
		#sw $0,-24($t2)
		sw $0,-28($t2)
		sw $0,-32($t2)			
		sw $0,-36($t2)			#pinta de preto o inicio do paddle anterior
		sw $0,-40($t2)
		#sw $0,-44($t2)
		move $v1,$a1
		jr $ra
		nop
#-------------------------Trata as entradas do teclado-------------------------		
		
		
pegaEntrada:	lui $t0,0xffff		#palavra do teclado em 0xffff0004
		ori $t0,$t0,4
		
		lui $t1,0xffff
		
		#li $a0,1000
		#li $v0,32
		#syscall
		
		lw $t5,0($t1)
		
		andi $t5,$t5,1
		
		beq $t5,1,tecladoUsado
		nop
		
		move $t0,$0	
		
		add $v1,$a1,$0
		
retornaTecla:	
		jr $ra
		nop
		
tecladoUsado:	
		lw $t3,0($t0)
		li $t4,0x2C		#tecla , (alguns teclados a virgula é como <)
		
		beq $t3,$t4,moveEsquerda
		nop
		
		li $t4,0x2E		#tecla . (alguns teclados o ponto é como >)
								
		beq $t3,$t4,moveDireita
		nop
		
		#li $a0,100
		#li $v0,32
		#syscall
		
		move $v0,$0
		add $v1,$a1,$0
		
		#move $v1,$a1
		
		#li $a0,100
		#li $v0,32
		#syscall
		
		j retornaTecla
		nop
		
moveEsquerda:	
		#li $a0,100
		#li $v0,32
		#syscall

		li $v0,-1
		#move $v1,$a1
		addi $v1,$a1,-8			#deslocamento da word a ser retornada para
		j retornaTecla			#o paddle
		nop
		
moveDireita:	
		#li $a0,100
		#li $v0,32
		#li $v0,-1
		#syscall

		li $v0,1
		#move $v1,$a1
		addi $v1,$a1,8
		j retornaTecla
		nop

telaInicial:	la $t0,branco
		lw $t1,0($t0)
		
		lui $t2,0x1004
		addi $t2,$t2,3096
		
		li $t3,0
		
pintaS1:	sw $t1,0($t2)
		addi $t2,$t2,4
		addi $t3,$t3,1
		
		bne $t3,5,pintaS1
		nop
		
		addi $t2,$t2,256
		addi $t2,$t2,-20
		li $t3,0
	
pintaS2:	sw $t1,0($t2)
		addi $t2,$t2,256
		addi $t3,$t3,1
		
		bne $t3,4,pintaS2
		nop
		
		li $t3,0			
	
pintaS3:	sw $t1,0($t2)
		addi $t2,$t2,4
		addi $t3,$t3,1
		
		bne $t3,5,pintaS3
		nop
		
		addi $t2,$t2,256
		addi $t2,$t2,-4
		li $t3,0
	
pintaS4:	sw $t1,0($t2)
		addi $t2,$t2,256
		addi $t3,$t3,1
		
		bne $t3,4,pintaS4
		nop
		
		addi $t2,$t2,-16
		li $t3,0
						
pintaS5:	sw $t1,0($t2)
		addi $t2,$t2,4
		addi $t3,$t3,1
		
		bne $t3,5,pintaS5
		nop		
		
		li $t2,0		
		lui $t2,0x1004
		addi $t2,$t2,3136
		
		li $t3,0
						
pintaT1:	sw $t1,0($t2)
		addi $t2,$t2,4
		addi $t3,$t3,1
		
		bne $t3,5,pintaT1
		nop
		
		li $t3,0
		addi $t2,$t2,256
		addi $t2,$t2,-12								

pintaT2:	sw $t1,0($t2)
		addi $t2,$t2,256
		addi $t3,$t3,1
		
		bne $t3,10,pintaT2
		nop	
		
		
		li $t2,0		
		lui $t2,0x1004
		addi $t2,$t2,3176
		
		li $t3,0
		
pintaA1:	sw $t1,0($t2)
		addi $t2,$t2,256
		addi $t3,$t3,1
		
		bne $t3,11,pintaA1
		nop																		
		
		li $t3,0
		addi $t2,$t2,-2812																																
		
pintaA2:	sw $t1,0($t2)
		addi $t2,$t2,4
		addi $t3,$t3,1
		
		bne $t3,3,pintaA2
		nop
		
		
		li $t3,0
		addi $t2,$t2,756
		
pintaA3:	sw $t1,0($t2)
		addi $t2,$t2,4
		addi $t3,$t3,1
		
		bne $t3,3,pintaA3
		nop		
		
		
		li $t3,0
		addi $t2,$t2,-768

	
pintaA4:	sw $t1,0($t2)
		addi $t2,$t2,256
		addi $t3,$t3,1
		
		bne $t3,11,pintaA4
		nop	
		
		li $t2,0		
		lui $t2,0x1004
		addi $t2,$t2,3216
		
		li $t3,0		
			
pintaR1:	sw $t1,0($t2)
		addi $t2,$t2,256
		addi $t3,$t3,1
		
		bne $t3,11,pintaR1
		nop	
		
		li $t3,0
		addi $t2,$t2,-2812						


pintaR2:	sw $t1,0($t2)
		addi $t2,$t2,4
		addi $t3,$t3,1
		
		bne $t3,5,pintaR2
		nop
						
		li $t3,0
		addi $t2,$t2,256
		
pintaR3:	sw $t1,0($t2)
		addi $t2,$t2,256
		addi $t3,$t3,1
		
		bne $t3,3,pintaR3
		nop
		
		li $t3,0
		addi $t2,$t2,-20						


pintaR4:	sw $t1,0($t2)
		addi $t2,$t2,4
		addi $t3,$t3,1
		
		bne $t3,5,pintaR4
		nop
		
		li $t3,0
		addi $t2,$t2,256						
																																																																								
pintaR5:	sw $t1,0($t2)
		addi $t2,$t2,256
		addi $t3,$t3,1
		
		bne $t3,6,pintaR5
		nop	
		
		li $t2,0		
		lui $t2,0x1004
		addi $t2,$t2,3264
		
		li $t3,0
		
pintaT3:	sw $t1,0($t2)
		addi $t2,$t2,4
		addi $t3,$t3,1
		
		bne $t3,5,pintaT3
		nop
		
		li $t3,0
		addi $t2,$t2,256
		addi $t2,$t2,-12								

pintaT4:	sw $t1,0($t2)
		addi $t2,$t2,256
		addi $t3,$t3,1
		
		bne $t3,10,pintaT4
		nop																								
																																																																																											
																																																																																														
		jr $ra
		nop


tecladoStart:
		lui $t0,0xffff		#palavra do teclado em 0xffff0004
		ori $t0,$t0,4
		
		lui $t1,0xffff
		
		#li $a0,1000
		#li $v0,32
		#syscall
		
		lw $t5,0($t1)
		
		andi $t5,$t5,1
		
		beq $t5,1,interrupTeclado
		nop
		
naoEnter:	jr $ra
		
interrupTeclado:
		lw $t3,0($t0)
		li $t4,10
		
		bne $t3,$t4,naoEnter	
		nop
		
		#foi teclado Enter
		li $v0,1
		
		jr $ra
		nop
		
contaPontos:	lui $t2,0x1001		#ponteiro do inicio da dos dados de linhas em .data
		ori $t2,$t2,0x0900
		li $s1,0		#reinicia a pontuacao, pois checara novamente
					#todos os blocos
		la $t3,384		#numero total de blocos nas linha -> 64*6
		la $t4,0		#conta o numero global de blocos contruidos
		
iteraLinhas:		
		lw $t1,0($t2)
		
		beq $t1,0,incPonto	#se estiver preto o bloco,incrementa a pontuacao 
		nop
incBloco:		
		addi $t2,$t2,4
		addi $t4,$t4,1
		
		bne $t4,$t3,iteraLinhas	#se passou por todas as linhas,sai da subrotina
		nop
		
		jr $ra
		nop
		
incPonto:
		addi $s1,$s1,1
		
		beq $s1,384,ganhouJogo
		nop
		
		j incBloco
		nop
		
normalizaBlocos:
		lui $t2,0x1001		#ponteiro seguinte ao inicio dos dados de linhas em .data
		ori $t2,$t2,0x0904
		
		li $t3,384		#numero de blocos nas linha - 1 bloco -> 64*6
		li $t4,0 
iteraNormal:		
		beq $t4,$t3,acabaNormal
		nop
		lw $t5,-4($t2)		#bloco anterior
		lw $t7,4($t2)		#proximo bloco
		
		
		addi $t4,$t4,1
		addi $t2,$t2,4
		
		bne $t5,0,iteraNormal
		nop
		bne $t7,0,iteraNormal
		nop
		
		#se os blocos anterior e proximo sao pretos, o bloco atual deve ser preto
		sw $0,-4($t2)
		
		j iteraNormal
		nop
		
acabaNormal:	jr $ra
		nop
		
		
		

ganhouJogo:	la $a0, congrats
		li $a1, 1
		li $v0, 55
		syscall
		
		li $v0,10
		syscall
		
final:		    
		la $a0,vidas
		li $v0,4
		syscall
		
		move $a0,$s0
		li $v0,1
		syscall
		
		la $a0,pontos
		li $v0,4
		syscall
		
		move $a0,$s1
		li $v0,1
		syscall
		
		la $a0, gameOver
		move $a1, $s1
		li $v0, 56
		syscall

		li $v0,10
		syscall
