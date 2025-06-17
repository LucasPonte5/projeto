# Universidade Federal Rural de Pernambuco - UFRPE
# Arquitetura e Organização de Computadores - 2025.1
# Projeto 01 - Assembly MIPS e Simulador MARS

# GRUPO: Gabriel Nascimento e Lucas Pontes

# Questão 1
# Esse arquivo contém a implementação em assembly MIPS das 
# seguintes funções da biblioteca "string.io" da linguagem C:
		
# strcpy, memcpy, strcmp, strncmp e strcat.

.data
	#Parâmetros para TESTE_STRCPY
	#end_origem: .asciiz "String de teste" 		#aloca um espaço na mémoria para a origem, contendo uma string.
	#end_destino: .space 50 					#aloca um espaço na mémora para o destino.
	
	#Parâmetros para TESTE_MEMCPY
	#end_origem2: .asciiz "0123456789"
	#end_destino2: .space 50
	#num: .word 20 								#número de bytes a ser copiado.
	
	#Parâmetros para TESTE_STRCMP/STRNCMP
	#str1: .asciiz "abc"						
	#str2: .asciiz "ab!"
	#STRNCMP
	#num: .word 2
	
	#Parâmetros para TESTE_STRCAT
	destination_str: .asciiz "Hello, "
	source_str: .asciiz "World!"
	
.text	
	main:
	#TESTE_STRCPY
		#la $a1, end_origem		#carrega o endereço de memória da origem que aponta para a string de teste.
		#la $a0, end_destino 	#endereço de destino para teste.
		#jal strcpy 			#chamada da função.
		
		#add $a0, $zero, $v0 	#guarda o retorno da função em $a0 para que sua string seja impressa.
		#li $v0, 4 				#carrega o service number de impressão de string.
		#syscall
	
	#TESTE_MEMCPY
		#la $a1, end_origem2					
		#la $a0, end_destino2
		#lw $a2, num	
		#jal memcpy
		
	#TESTE_STRCMP/STRNCMP
		#la $a0, str1
		#la $a1, str2
		#lw $a3, num
		
		#jal strcmp

		#jal strncmp
		
		#imprimir retorno no console
		#add $a0, $zero, $v0 	
		#li $v0, 1				
		#syscall
		
	#TESTE_STRCAT
		la $a0, destination_str
		la $a1, source_str
		jal strcat
		
		#imprimir resultado no console
		add $a0, $zero, $v0 	
		li $v0, 4				
		syscall
		

		#finaliza o programa
		li $v0, 10
		syscall
	
	# Função a - strcpy	
	strcpy:
		add $v0, $zero, $a0	#guarda o endereço de destino em v0.
		
		strcpy_loop:
			lb $t0, 0($a1) 				#carrega um byte (caractere) da string apontada pelo endereço de origem.
			beq $t0, $zero, end_strcpy 	#verifica se o byte representa o caractere NULL '\0' = 0b(0000 0000) = 0.
			
			sb $t0, 0($a0) 		#copia o byte para a posição correspondente do endereço de destino.
			addi $a1, $a1, 1 	#incrementa a1 para acessar o próximo endereço de byte.
			addi $a0, $a0, 1 	#incrementa a0 para acessar o próximo endereço de byte.
			
			j strcpy_loop
		end_strcpy:
			sb $t0, 0($a0) 	#insere o caractere '\0'.
			jr $ra 			#retorna para a instrução seguinte do caller.
			
	# Função b - memcpy
	memcpy:
		add $v0, $zero, $a0 	#guarda o endereço de destino em v0.
		li $t1, 0				#atribui a $t1 (contador) o valor 0.
	
		memcpy_loop:
			slt $t0, $t1, $a2			#verifica se o contador $t1 é menor que 'num'.
			beq $t0, $zero, end_memcpy	#finaliza a copia de bytes caso a verificação acima de falso.
			
			lb $t0, 0($a1)	#carrega o valor do byte atual do bloco de origem.
			sb $t0, 0($a0)	#salva o mesmo valor na posição correspondente do destino.
			 						            
			addi $a1, $a1, 1 	#incrementa a1 para acessar o próximo endereço de byte.
			addi $a0, $a0, 1 	#incrementa a0 para acessar o próximo endereço de byte.
			
			addi $t1, $t1, 1	#incrementa o contador ($t1 = $t1 + 1).
			
			j memcpy_loop
		end_memcpy:
			jr $ra	#retorna para a instrução seguinte do caller.
	
	# Função c - strcmp
	strcmp:
		strcmp_loop:
			lb $t0, 0($a0)	#carrega o char do endereço base de str1.
			lb $t1, 0($a1)	#carrega o char do endereço base de str2.
			
			beq $t0, $zero, str1_null	#verifica se o char em str1 é '\0' (NULL).
			beq $t1, $zero, str2_less	#verifica se o char em str2 é '\0' (NULL).
	
			j is_equal #nenhum dos char é '\0' (NULL).
			
			str1_null:
				beq $t1, $zero, str1_str2_equal #verifica se o char em str2 também é '\0' (NULL).
				j str1_less 
			
			is_equal:
				beq $t0, $t1, equal	#verifica se os dois char são iguais.	
			
				#verifica se o char em str1 tem valor decimal menor que o char de str2, ou o contrário.	
				slt $t2, $t0, $t1
				bne $t2, $zero, str1_less	#str1 < str2
				j str2_less					#str2 < str1
			
			equal:
				addi $a0, $a0, 1	#incrementa a0 para acessar o próximo endereço de byte.
				addi $a1, $a1, 1	#incrementa a1 para acessar o próximo endereço de byte.
				j strcmp_loop
		
		#retorna -1 quando encontrado uma diferença, sendo o char de str1 com valor decimal menor que str2.	
		str1_less:
			addi $v0, $zero, -1
			j end_strcmp
			
		#retorna 1 quando encontrado uma diferença, sendo o char de str2 com valor decimal menor que str1.		
		str2_less:
			addi $v0, $zero, 1
			j end_strcmp
			
		#retorna 0 se str1 e str2 forem iguais.
		str1_str2_equal:
			add $v0, $zero, $zero
			j end_strcmp
			
		end_strcmp:
			jr $ra	#retorna para a instrução seguinte do caller.
				
	# Função d - strncmp
	strncmp:	
		strncmp_loop:
			#finaliza a comparação quando num ($a3) chega em 0.
			slti $t0, $a3, 1					#verifica se num ($a3) é menor que 1.
			bne $t0, $zero, strn1_strn2_equal		#caso sim, finaliza o looping de comparações.
			  		
			lb $t0, 0($a0)	#carrega o char do endereço base de str1.
			lb $t1, 0($a1)	#carrega o char do endereço base de str2.
			
			beq $t0, $zero, strn1_null	#verifica se o char em str1 é '\0' (NULL).
			beq $t1, $zero, strn2_less	#verifica se o char em str2 é '\0' (NULL).
	
			j is_equal_strn #nenhum dos char é '\0' (NULL).
			
			strn1_null:
				beq $t1, $zero, strn1_strn2_equal #verifica se o char em str2 também é '\0' (NULL).
				j strn1_less 
			
			is_equal_strn:
				beq $t0, $t1, equal_strn	#verifica se os dois char são iguais.	
			
				#verifica se o char em str1 tem valor decimal menor que o char de str2, ou o contrário.	
				slt $t2, $t0, $t1
				bne $t2, $zero, strn1_less	#str1 < str2
				j strn2_less				#str2 < str1
			
			equal_strn:
				addi $a0, $a0, 1	#incrementa a0 para acessar o próximo endereço de byte.
				addi $a1, $a1, 1	#incrementa a1 para acessar o próximo endereço de byte.
				addi $a3, $a3, -1	#decrementa num ($a3).
				j strncmp_loop
		
		#retorna -1 quando encontrado uma diferença, sendo o char de str1 com valor decimal menor que str2.	
		strn1_less:
			addi $v0, $zero, -1
			j end_strncmp
			
		#retorna 1 quando encontrado uma diferença, sendo o char de str2 com valor decimal menor que str1.		
		strn2_less:
			addi $v0, $zero, 1
			j end_strncmp
			
		#retorna 0 se str1 e str2 forem iguais.	
		strn1_strn2_equal:
			add $v0, $zero, $zero
			j end_strncmp
			
		end_strncmp:
			jr $ra	#retorna para a instrução seguinte do caller.
			
	# Função e - strcat
	strcat:
		add $v0, $zero, $a0 #guarda o endereço de destination
		
		while_not_null:
			lb $t0, 0($a0)	#carrega o byte de apontado por destination em t0.
			beq $t0, $zero, strcat_loop	#se t0 = 0, então NULL ('\0') foi encontrado no endereço ($a0).
			addi $a0, $a0, 1	#incrementa o endereço apontado por destination.
			j while_not_null	#loop
			
		strcat_loop:
			lb $t1, 0($a1)	#carrega o byte apontado por source.
			beq $t1, $zero, end_strcat	#source ponta para NULL.
			
			sb $t1, 0($a0) 		#copia o char para o endereço de destination.
			addi $a1, $a1, 1	#incrementa o endereço de source.
			addi $a0, $a0, 1	#incrementa o endereço de destination.
			j strcat_loop
		
		end_strcat:
			sb $zero, 0($a0) #adiciona NULL no final da concatenação
			jr $ra
		
		
		
		
	
					
