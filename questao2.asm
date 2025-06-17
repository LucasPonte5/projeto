# Universidade Federal Rural de Pernambuco - UFRPE
# Arquitetura e Organização de Computadores - 2025.1
# Projeto 01 - Assembly MIPS e Simulador MARS

# GRUPO: Gabriel Nascimento e Lucas Pontes

# QUESTÃO 2
#
.data

	receiver_control: .word 0xffff0000
	receiver_data: .word 0xffff0004
	transmitter_control: .word 0xffff0008
	transmitter_data: .word 0xffff000c
	
.text
	
		lw $t0, receiver_data		#carrega o endereço de receiver data em $t0.
		lw $t1,	receiver_control	#carrega o endereço de receiver control em $t1.
				
		lw $t2, transmitter_data		#carrega o endereço de trasmitter data em $t2.
		lw $t3,	transmitter_control		#carrega o endereço de trasmitter control em $t3.
		
		#monitora constantemente se o usuário digitou um caractere.
		echo:
			lw $t5, 0($t1)
			beq $t5, $zero, echo  #$t5 (receiver control ready bit), se for igual a 0 significa que o usuário ainda não digitou.
			
			lw $t4, 0($t0)		  #lê o último caractere digitado pelo usuário.
			sw $t4, 0($t2)		  #copia o caractere para o registrador transmitter data para ser impresso.
		
			j echo

