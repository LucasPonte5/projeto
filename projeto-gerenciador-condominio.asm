# Universidade Federal Rural de Pernambuco - UFRPE
# Arquitetura e Organização de Computadores - 2025.1
# Projeto 01 - Assembly MIPS e Simulador MARS

# GRUPO: Gabriel Nascimento e Lucas Pontes

# PROJETO - ASSEMBLY MIPS - GERENCIADOR DE CONDOMINIO
# Implementação de um gerenciador de condominio, onde é possível registrar até 5 moradores para cada apartamento (nº0 ... nº39).
# Além disso, para cada apartamento pode-se guardar 2 motos ou 1 carro.

.data
shell: .asciiz "GL-shell>> " # Banner do shell de comandos
linha: .asciiz "\n" 		# Quebra de linha
espaco: .asciiz "\t"
input_buffer: .space 100	# Espaço reservado para o input do usuário
tipo_buffer: .space 2		# Espaço reservado para o input do tipo do veiculo
modelo_buffer: .space 17	# Espaço reservado para o modelo do veiculo
cor_buffer: .space 13		# Espaço reservado para a cor do veiculo

# Configuração de espaço na memória
apartamentos: .space 6400  # 40 apartamentos × 5 moradores × 32 (para o nome). 160 bytes cada apt
nome_buffer: .space 32	   # Espaço reservado para o input do nome de um morador
veiculos: .space 2560	   # 1 tipo + 17 modelo + 13 cor = 32. 32 * 2 veiculos = 64. 64 * 40 apt = 2560

#Gerenciamento de arquivos
arquivo_apartamentos: .asciiz "C:\Users\Lukin\Documents\apartamentos.txt"
arquivo_veiculos: .asciiz "C:\Users\Lukin\Documents\veiculos.txt"

# Comandos disponiveis
cmd_1: .asciiz "ad_morador"
cmd_2: .asciiz "rm_morador"
cmd_3: .asciiz "ad_auto"
cmd_4: .asciiz "rm_auto"
cmd_5: .asciiz "limpar_ap"
cmd_6: .asciiz "info_ap"
cmd_7: .asciiz "info_geral"
cmd_8: .asciiz "salvar"
cmd_9: .asciiz "recarregar"
cmd_10: .asciiz "formatar"
cmd_11: .asciiz "sair"

# MENSAGENS
cmd_invalido: .asciiz "Comando invalido\n"
ap_invalido: .asciiz "Falha: AP invalido\n"
ap_cheio: .asciiz "Falha: AP com numero max de moradores\n"
morador_add: .asciiz "Morador adicionado com sucesso!\n"
morador_nao_encontrado: .asciiz "Falha: morador nao encontrado\n"
morador_rmv: .asciiz "Morador removido com sucesso!\n"
ap_limpo: .asciiz "Apartamento limpado com sucesso!\n"
veiculo_add: .asciiz "Veiculo adicionado com sucesso!\n"
tp_invalido: .asciiz "Falha: tipo invalido\n"
garagem_cheia: .asciiz "Falha: AP com numero max de automóveis\n"
veiculo_removido: .asciiz "Veiculo removido com sucesso\n"
veiculo_nao_enc: .asciiz "Falha: automóvel nao encontrado\n"
arquivo_salvo: .asciiz "O arquivo foi salvo\n"
arquivo_recarregado: .asciiz "O arquivo foi recarregado\n"
apartamentos_formatados:.asciiz "Apartamentos formatados\n"
veiculos_formatados: .asciiz "Veiculos formatados\n"
formatado: .asciiz "Todos os dados foram formatados\n"
msg_nao_vazios: .asciiz "Não vazios:\t"
msg_vazios: .asciiz "Vazios:\t\t"
par_abrir: .asciiz " ("
par_fechar: .asciiz "%)\n"

ap_prefixo: .asciiz "AP: "
moradores_label: .asciiz "Moradores:\n"
ap_vazio: .asciiz "Apartamento vazio\n"
carro_label: .asciiz "Carro:\n"
moto_label: .asciiz "Moto:\n"
modelo_label: .asciiz "\tModelo: "
cor_label: .asciiz "\n\tCor: "
all: .asciiz "all"

# Macro para a quebra de linha no terminal
.macro print_line
	li $v0, 4
	la $a0, linha
	syscall
.end_macro

# Macro para a impressão de mensagens no terminal
.macro print_string %string
	li $v0, 4
	la $a0, %string
	syscall
.end_macro 

.text

# Loop principal do programa, verifica constantemente pelo input do usuário
input_loop:
	print_string(shell)	# Imprime o banner
	
	# Solicita pelo input do usuário
	li $v0, 8
	la $a0, input_buffer
	la $a1, 100	# Tamanho máximo do input
	syscall
	
	# Chamada para o interpretador de comandos
	jal interpretador_cmd

	j input_loop

li $v0, 10
syscall

# Função responsável por interpretar o input digitado pelo usuário, identificando os comandos do sistema e retornando mensagens
# de erro no caso de comandos inválidos.
interpretador_cmd:
# cmd_1 - ad_morador
	la $a0, input_buffer	# Carrega o endereço do input do usuário em $a0
	la $a1, cmd_1		# Carrega o endereço da string cmd_1 em $a1
	la $a3, 10		# O input vai ser comparado com os 10 bytes da string "ad_morador"
	
	# Chamada a função de comparação de strings (strncmp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strncmp
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	beq $v0, $zero, ad_morador	# Comando ad_morador identificado
	
# cmd_2 - rm_morador
	la $a0, input_buffer	# Carrega o endereço do input do usuário em $a0
	la $a1, cmd_2		# Carrega o endereço da string cmd_2 em $a1
				# $a3 já está carregado com o valor 10 (oculta-se)
	
	# Chamada a função de comparação de strings (strncmp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strncmp
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	beq $v0, $zero, rm_morador # Comando rm_morador identificado
	
# cmd_3 - ad_auto
	la $a0, input_buffer 	# Carrega o endereço do input do usuário em $a0
	la $a1, cmd_3			# Carrega o endereço da string cmd_3 em $a1
	la $a3, 7				# O input vai ser comparado com os 7 bytes da string "ad_auto"
	
	# Chamada a função de comparação de strings (strncmp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strncmp
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	beq $v0, $zero, ad_auto	# Comando ad_auto identificado
	
# cmd_4 - rm_auto
	la $a0, input_buffer	# Carrega o endereço do input do usuário em $a0
	la $a1, cmd_4			# Carrega o endereço da string cmd_4 em $a1
							# $a3 já está carregado com o valor 7 (oculta-se)
	
	# Chamada a função de comparação de strings (strncmp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strncmp
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	beq $v0, $zero, rm_auto	# Comando rm_auto identificado
	
# cmd_5 - limpar_ap
	la $a0, input_buffer	# Carrega o endereço do input do usuário em $a0
	la $a1, cmd_5		# Carrega o endereço da string cmd_5 em $a1
	la $a3, 9		# O input vai ser comparado com os 9 bytes da string "limpar_ap"

	# Chamada a função de comparação de strings (strncmp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strncmp
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	beq $v0, $zero, limpar_ap # Comando limpar_ap identificado
	
# cmd_6 - info_ap
	la $a0, input_buffer	# Carrega o endereço do input do usuário em $a0
	la $a1, cmd_6		# Carrega o endereço da string cmd_6 em $a1
	la $a3, 7		# O input vai ser comparado com os 7 bytes da string "info_ap"
	
	# Chamada a função de comparação de strings (strncmp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strncmp
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	beq $v0, $zero, info_ap	# Comando info_ap identificado
	
# cmd_7 - info_geral
	la $a0, input_buffer	# Carrega o endereço do input do usuário em $a0
	la $a1, cmd_7		# Carrega o endereço da string cmd_7 em $a1
	la $a3, 10		# O input vai ser comparado com os 10 bytes da string "info_geral"
	
	# Chamada a função de comparação de strings (strncmp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strncmp
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	beq $v0, $zero, info_geral	# Comando info_geral identificado
	
# cmd_8 - salvar
	la $a0, input_buffer	# Carrega o endereço do input do usuário em $a0
	la $a1, cmd_8		# Carrega o endereço da string cmd_8 em $a1
	la $a3, 6		# O input vai ser comparado com os 6 bytes da string "salvar"

	# Chamada a função de comparação de strings (strncmp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strncmp
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	beq $v0, $zero, salvar	# Comando salvar identificado
	
# cmd_9 - recarregar
	la $a0, input_buffer	# Carrega o endereço do input do usuário em $a0
	la $a1, cmd_9		# Carrega o endereço da string cmd_9 em $a1
	la $a3, 10		# O input vai ser comparado com os 10 bytes da string "recarregar"
	
	# Chamada a função de comparação de strings (strncmp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strncmp
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	beq $v0, $zero, recarregar	# Comando recarregar identificado
	
# cmd_10 - formatar
	la $a0, input_buffer	# Carrega o endereço do input do usuário em $a0
	la $a1, cmd_10		# Carrega o endereço da string cmd_10 em $a1
	la $a3, 8		# O input vai ser comparado com os 8 bytes da string "formatar"

	# Chamada a função de comparação de strings (strncmp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strncmp
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	beq $v0, $zero, formatar	# Comando formatar identificado
	
# cmd_11 - sair
	la $a0, input_buffer	# Carrega o endereço do input do usuário em $a0
	la $a1, cmd_11		# Carrega o endereço da string cmd_11 em $a1
	la $a3, 4		# O input vai ser comparado com os 4 bytes da string "sair"

	# Chamada a função de comparação de strings (strncmp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strncmp
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	beq $v0, $zero, sair	# Comando sair identificado
	
	# Não detectou um comando válido
	comando_invalido:
		print_string(cmd_invalido)
		print_line
		j input_loop
	
	# Numéro de apt inválido
	apt_invalido:
    		print_string(ap_invalido)
    		print_line
    		j input_loop
    
    # Apt atingiu a capacidade máxima
	apt_cheio:
		print_string(ap_cheio)
		print_line
    		j input_loop   	

# cmd_1: ad_morador-<apt>-<nome_morador>
ad_morador:
	# Ler número do apartamento
	la $t0, input_buffer	# carrega o endereço do input inserido
	addi $t0, $t0, 10	# pula para a parte do comando deve estar o '-'
	
	# Verifica se tem hífen após o comando
	lb $t1, 0($t0)
	bne $t1, 45, comando_invalido   # '-' = 45
	addi $t0, $t0, 1		# vai para o endereço contendo o primeiro digito do apt
	
	# Faz a leitura do num do apt do input buffer
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal read_ap
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
   	beq $t1, 10, comando_invalido # verifica se o usuário digitou apenas a opção de num do apt
   	
   	# Verifica se o apt é válido (0 ... 39)
	blt $s0, $zero, apt_invalido # não pode ser menor que 0
	bgt $s0, 39, apt_invalido    # não pode ser maior que 39

	addi $t0, $t0, 1 # vai para o proxímo endereço do input, onde se inicia o nome do morador
    	
	la $a0, nome_buffer	# carrega o endereço do buffer de nome
	add $a1, $zero, $t0	# carrega o endereço do nome contido no input digitado pelo usuário
    
	# Faz a cópia do nome inserido no input para o buffer de nome
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strcpy		
	lw $ra, 0($sp)
	addi $sp, $sp, 4
		
	add $s1, $zero, $v0 # guarda o endereço do nome em $s1.
	
	# Calcula endereço do apartamento
	# end = apartamentos + apt * 160
	addi $t0, $zero, 160 	# cada apartamento ocupa 160 bytes
	mul $s0, $s0, 160	# calcula o endereço do apt
	la $s2, apartamentos	# carrega o endereço do espaço alocado para os apartamentos
	add $s2, $s2, $s0	# $s2 aponta para o primeiro morador do apartamento especificado
	li $t1, 0		# contador de moradores
	# Verifica a quantidade de moradores que ocupam o apt.
	verificar_num_moradores:
		beq $t1, 5, apt_cheio	# se $t1 = 5 -> apt cheio
		lb $t0, 0($s2)		# carrega o byte do endereço atual
		beq $t0, $zero, adicionar_morador	# se for igual a 0, essa área está vaga. Adiciona o morador em seguida
		addi $t1, $t1, 1	# incrementa o contador de moradores no apt
				
		addi $s2, $s2, 32	# vai para o próximo endereço de morador do apartamento (32 por morador)
	j verificar_num_moradores
	
	# Adiciona o morador do o nome passado no comando	
	adicionar_morador:
		la $a1, nome_buffer # carrega o endereço do nome digitado no arg a1
		add $a0, $zero, $s2 # carrega o endereço do morador no arg a0
		
		# Copia o nome do morador do buffer para o espaço vago do apartamento
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal strcpy		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		# Mensagem de sucesso
		print_string(morador_add)
		print_line
	j input_loop

# cmd_2: rm_morador-<apt>-<nome_morador>	
rm_morador:
	# Avança o ponteiro para após "rm_morador" (10 caracteres)
	la $t0, input_buffer
	addi $t0, $t0, 10
	
	# Verifica se tem hífen após o comando
	lb $t1, 0($t0)
	bne $t1, 45, comando_invalido   # '-' = 45
	addi $t0, $t0, 1		# vai para o endereço contendo o primeiro digito do apt

	# Faz a leitura do num do apt do input buffer
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal read_ap
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
   	beq $t1, 10, comando_invalido # verifica se o usuário digitou apenas a opção de num do apt
   	
   	# Verifica se o apt é válido (0..39)
	blt $s0, $zero, apt_invalido # não pode ser menor que 0
	bgt $s0, 39, apt_invalido    # não pode ser maior que 39
	
	addi $t0, $t0, 1 # Vai para o endereço contendo o nome do morador

	# Copia nome do morador para nome_buffer
	la $a0, nome_buffer
	
	add $a1, $zero, $t0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strcpy		
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	# Calcula endereço do apartamento
	# end = apartamentos + apt * 160
	li $t1, 160				# calcula o endereço do apt
	mul $t2, $s0, $t1		# calcula o endereço do apt
	la $s2, apartamentos	# carrega o endereço do espaço alocado para os apartamentos
	add $s2, $s2, $t2   	 # $s2 aponta para o primeiro morador do apt

	# Loop para procurar o morador
	li $t3, 0             # contador de moradores (0 a 4)
	procurar_morador:
		beq $t3, 5, nao_encontrado
		add $a0, $zero, $s2         # slot atual
		la $a1, nome_buffer			# carrega o nome digitado no comando
		
		# Verifica se um morador com o nome passado existe no apartamento	
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal strcmp					
		lw $ra, 0($sp)
		addi $sp, $sp, 4
								
		beq $v0, $zero, remover_morador # morador encontrado, remove-o em seguida

		# Próximo slot
		addi $s2, $s2, 32	# vai para o próximo endereço de morador
		addi $t3, $t3, 1	# incrementa o contador de moradores
	j procurar_morador
	
	# Apaga o nome do morador encontrado
	remover_morador:
		li $t5, 0 # contador (até 32)
		apagar_nome_loop:
			beq $t5, 32, fim_remocao 	# zerou todos os 32 bytes contendo o nome do morador
			sb $zero, 0($s2)		# zera (apaga) o char do endereço
			addi $s2, $s2, 1		# vai para o próximo endereço de byte
			addi $t5, $t5, 1		# incremtena o número de char zerados
		j apagar_nome_loop
	
	# Imprime uma mensagem de sucesso
	fim_remocao:
		print_string(morador_rmv)
		print_line
		j input_loop

	# Imprime uma mensagem de erro caso o morador não seja encontrado
	nao_encontrado:
		print_string(morador_nao_encontrado)
		print_line
		j input_loop
			
ad_auto:
	#analise apartamento
	la $t0, input_buffer
	addi $t0, $t0, 7         # pula "ad_auto-"

	# Verifica se tem hífen após o comando
	lb $t1, 0($t0)
	bne $t1, 45, comando_invalido   # '-' = 45
	addi $t0, $t0, 1		# vai para o endereço contendo o primeiro digito do apt

	# Faz a leitura do num do apt do input buffer
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal read_ap
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
   	beq $t1, 10, comando_invalido # verifica se o usuário digitou apenas a opção de num do apt
	
	# Verifica se o apt é válido (0..39)
	blt $s0, $zero, apt_invalido # não pode ser menor que 0
	bgt $s0, 39, apt_invalido    # não pode ser maior que 39

	addi $t0, $t0, 1	# pula '-'

	# analise tipo (apenas 1 caractere)
	lb $t2, 0($t0)
	sb $t2, tipo_buffer
	addi $t0, $t0, 2         # pula tipo e '-'

	# valida tipo
	li $t3, 'm'
	beq $t2, $t3, tipo_ok
	li $t3, 'c'
	beq $t2, $t3, tipo_ok
	j tipo_invalido

	tipo_ok:
		# analise modelo
		la $a0, modelo_buffer
	
		ler_modelo:
			lb $t2, 0($t0)
			beq $t2, 45, fim_modelo # "'-' = 45 (ASCII)"
			sb $t2, 0($a0)
			addi $t0, $t0, 1
			addi $a0, $a0, 1
		j ler_modelo
	
		fim_modelo:
			sb $zero, 0($a0)
			addi $t0, $t0, 1         # pula '-'

		# analise cor
		la $a0, cor_buffer
		ler_cor:
			lb $t2, 0($t0)
			beq $t2, 10, fim_cor
			sb $t2, 0($a0)
			addi $t0, $t0, 1
			addi $a0, $a0, 1
		j ler_cor
	
		fim_cor:
		sb $zero, 0($a0)

	# valida se há espaço no AP
	la $t1, veiculos
	li $t3, 64               # cada AP = 2 veículos = 64 bytes
	mul $t4, $s0, $t3		 # calcula o endereço do automóvel com base no número do apt
	add $t1, $t1, $t4        # t1 = base do AP

	li $t5, 0                # contador de veículos
	li $t6, 0                # motos
	li $t7, 0                # carros
	
	# Verifica se a espaço para veiculos
	checar_slots:
		bge $t5, 2, fim_checar  # já percorreu os 2 slots
		lb $t8, 0($t1)
		beq $t8, 0, proximo_slot # slot vazio, mas ainda conta

		beq $t8, 'm', conta_moto
		beq $t8, 'c', conta_carro
		
		proximo_slot:
			addi $t1, $t1, 32
			addi $t5, $t5, 1
	j checar_slots
	
	# Conta uma moto do apt
	conta_moto:
		addi $t6, $t6, 1
		j proximo_slot
		
	# Conta um carro do apt
	conta_carro:
   		addi $t7, $t7, 1
    	j proximo_slot
    	
	fim_checar:
    	# pega o tipo atual
		la $a0, tipo_buffer
		lb $t9, 0($a0)    # tipo atual (m ou c)
		
		# Se for carro
		li $t3, 'c'
		beq $t9, $t3, verifica_carro
		
		# Se for moto
		li $t3, 'm'
		beq $t9, $t3, verifica_moto
		
		j tipo_invalido # segurança

	verifica_carro:
		# Já tem 1 carro?
		bge $t7, 1, msg_max_auto

		# Já tem qualquer moto? (não pode misturar)
		bgt $t6, 0, msg_max_auto

		j pode_gravar
		
	verifica_moto:
		# Verificação de carro, não pode misturar carro e moto
		bgt $t7, 0, msg_max_auto

		# Verificação se tem 2 motos
		bge $t6, 2, msg_max_auto

		j pode_gravar
	
	pode_gravar:
		# encontrar o primeiro slot vazio de novo
		la $t1, veiculos
		li $t3, 64               # cada AP = 2 veículos = 64 bytes
		mul $t4, $s0, $t3
		add $t1, $t1, $t4
		
		li $t5, 0
		encontrar_slot_vazio:
			bge $t5, 2, msg_max_auto      # segurança extra
			lb $t8, 0($t1)
			beq $t8, 0, gravar_veiculo
			addi $t1, $t1, 32
			addi $t5, $t5, 1
			j encontrar_slot_vazio

	gravar_veiculo:
		# grava tipo
		la $a0, tipo_buffer
		lb $t2, 0($a0)
		sb $t2, 0($t1)
		
		# grava modelo
		la $a0, modelo_buffer
		addi $t1, $t1, 1
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal strcpy
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		# grava cor
		la $a0, cor_buffer
		addi $t1, $t1, 16
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal strcpy
		lw $ra, 0($sp)
		addi $sp, $sp, 4
	
		print_string(veiculo_add)
		print_line
		j input_loop
		
	tipo_invalido:
		print_string(tp_invalido)
		print_line
		j input_loop
			
	msg_max_auto:
		print_string(garagem_cheia)
		print_line
		j input_loop
		
rm_auto:
	# Pula "rm_auto-"
	la $t0, input_buffer
	addi $t0, $t0, 7          # 7 letras + 1 hífen

	# Verifica hífen após comando
	lb $t1, 0($t0)
	bne $t1, 45, comando_invalido  # '-' ascii 45
	addi $t0, $t0, 1

	# Lê número do apartamento (usando função read_ap)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal read_ap
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	# Valida apt (0..39)
	blt $s0, $zero, apt_invalido
	bgt $s0, 39, apt_invalido

	addi $t0, $t0, 1     # pula '-'

	# Lê tipo (1 caractere)
	lb $t2, 0($t0)
	sb $t2, tipo_buffer
	li $t3, 'c'
	beq $t2, $t3, tipo_valido
	li $t3, 'm'
	beq $t2, $t3, tipo_valido
	j tipo_invalido

	tipo_valido:
	addi $t0, $t0, 2     # pula tipo e '-'

	# Lê modelo (até 16 chars ou até encontrar '-')
	la $a0, modelo_buffer
	li $t9, 0
	ler_modelo_rm:
	lb $t2, 0($t0)
	beq $t2, 45, fim_modelo_rm    # '-' ascii 45
	sb $t2, 0($a0)
	addi $t0, $t0, 1
	addi $a0, $a0, 1
	addi $t9, $t9, 1
	li $t8, 16
	bge $t9, $t8, fim_modelo_rm
	j ler_modelo_rm
	fim_modelo_rm:
	sb $zero, 0($a0)
	addi $t0, $t0, 1     # pula '-'

	# Lê cor (até 13 chars ou até encontrar '\n' ou zero)
	la $a0, cor_buffer
	li $t9, 0
	ler_cor_rm:
	lb $t2, 0($t0)
	beq $t2, 10, fim_cor_rm    # newline
	beq $t2, $zero, fim_cor_rm
	sb $t2, 0($a0)
	addi $t0, $t0, 1
	addi $a0, $a0, 1
	addi $t9, $t9, 1
	li $t8, 13
	bge $t9, $t8, fim_cor_rm
	j ler_cor_rm
	fim_cor_rm:
	sb $zero, 0($a0)

	# Calcula endereço base dos veículos do apt
	la $t1, veiculos
	li $t3, 64
	mul $t4, $s0, $t3
	add $t1, $t1, $t4

	# Loop nos dois slots do apt para encontrar o veículo
	li $t5, 0                # contador de slots
	buscar_auto:
	bge $t5, 2, veiculo_nao_encontrado

	# Verifica tipo
	lb $t6, 0($t1)
	lb $t7, tipo_buffer
	bne $t6, $t7, prox_auto

	# Compara modelo com strcmp
	addi $a0, $t1, 1
	la $a1, modelo_buffer
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strcmp
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	bne $v0, $zero, prox_auto

	# Compara cor com strcmp
	addi $a0, $t1, 17
	la $a1, cor_buffer
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strcmp
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	bne $v0, $zero, prox_auto

 	# Veículo encontrado então apaga os 32 bytes da entrada
	li $t9, 0
	limpar_auto:
	li $t8, 32
	beq $t9, $t8, fim_remocao_auto
	sb $zero, 0($t1)
	addi $t1, $t1, 1
	addi $t9, $t9, 1
	j limpar_auto

	fim_remocao_auto:
	print_string(veiculo_removido)
	print_line
	j input_loop

	prox_auto:
	addi $t1, $t1, 32
	addi $t5, $t5, 1
	j buscar_auto

	veiculo_nao_encontrado:
	print_string(veiculo_nao_enc)
	print_line
	j input_loop

# cmd_5: limpar_ap-<apt>
limpar_ap:
	# Avança o ponteiro para após "limpar_ap" (9 caracteres)
	la $t0, input_buffer
	addi $t0, $t0, 9
	
	# Verifica se tem hífen após o comando
	lb $t1, 0($t0)
	bne $t1, 45, comando_invalido   # '-' = 45
	addi $t0, $t0, 1				# vai para o endereço contendo o primeiro digito do apt

	# Faz a leitura do num do apt do input buffer
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal read_ap
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
   	beq $t1, 45, comando_invalido # verifica se o usuário digitou '-' após o num do apt
   	
   	# Verifica se o apt é válido
	blt $s0, $zero, apt_invalido
	bgt $s0, 39, apt_invalido
		
	# Exclui todos os moradores do apt especificado
	remover_moradores_ap:
		# Calcula endereço do apartamento
		# end = apartamentos + apt * 160
		li $t1, 160
		mul $t2, $s0, $t1
		la $s2, apartamentos
		add $s2, $s2, $t2    # $s2 aponta para o primeiro morador do apt
	
		li $t5, 0 # contador (até 160)
		apagar_moradores_loop:
			beq $t5, 160, fim_remocao_moradores # excluiu todos os moradores
			sb $zero, 0($s2)		# zera (apaga) o char do endereço
			addi $s2, $s2, 1		# vai para o próximo char
			addi $t5, $t5, 1		# incrementa o número de char zerados
		j apagar_moradores_loop
		
	fim_remocao_moradores:
	
	# Exclui todos os automóveis do apt especificado
	remover_automoveis_ap:
		# Calcula endereço dos automóveis do apt
		# end = veiculos + apt * 64
		li $t1, 64
		mul $t2, $s0, $t1
		la $s2, veiculos
		add $s2, $s2, $t2    # $s2 aponta para o primeiro automovel do apt
	
		li $t5, 0 # contador (até 64)
		apagar_automoveis_loop:
			beq $t5, 64, fim_remocao_automoveis # excluiu todos os automoveis
			sb $zero, 0($s2)		# zera (apaga) o char do endereço
			addi $s2, $s2, 1		# vai para o próximo char
			addi $t5, $t5, 1		# incrementa o número de char zerados
		j apagar_automoveis_loop
	
	# Imprime uma mensagem de sucesso
	fim_remocao_automoveis:
		print_string(ap_limpo)
		print_line
		j input_loop

# cmd_6: info_ap-<apt>
info_ap:
	# Avança o ponteiro para após "info_ap" (7 caracteres)
	la $t0, input_buffer
	addi $t0, $t0, 7
	
	# Verifica se tem hífen após o comando
	lb $t1, 0($t0)
	bne $t1, 45, comando_invalido   # '-' = 45
	addi $t0, $t0, 1				# vai para o endereço contendo o primeiro digito do apt
	
	add $a0, $zero, $t0  	# Carrega o endereço do input do usuário em $a0
	la $a1, all				# Carrega o endereço da string "all" em $a1
	la $a3, 3				# O input vai ser comparado com os 3 bytes da string "all"

	# Verifica se o argumento passado é igual a "all"
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	jal strncmp
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	addi $sp, $sp, 8
	
	beq $v0, $zero, info_ap_all	# Opcao "all" identificada
	
	# Faz a leitura do num do apt do input buffer
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal read_ap
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
   	beq $t1, 45, comando_invalido # verifica se o usuário digitou '-' após o num do apt
   	
   	# Verifica se o apt é válido (0..39)
	blt $s0, $zero, apt_invalido
	bgt $s0, 39, apt_invalido
	
	verificar_vazio:
		# Calcula endereço do apartamento
		# end = apartamentos + apt * 160
		li $t1, 160
		mul $t2, $s0, $t1		# calcula o endereço do apt
		la $s2, apartamentos	# carrega o endereço do espaço alocado para os apartamentos
		add $s2, $s2, $t2       # $s2 aponta para o primeiro morador do apt

		# Loop para verificar se o apt está vazio
		li $t3, 0             # contador de vagas disponiveis (0..4)
		verificar_vazio_loop:
			beq $t3, 5, apt_vazio
		
			lb $t1, 0($s2)		
			bne $t1, $zero, print_ap

			# Próximo slot
			addi $s2, $s2, 32	# vai para o próximo endereço de morador
			addi $t3, $t3, 1	# incrementa o contador vagas disponiveis
		j verificar_vazio_loop
		
		print_ap:
			# "AP":
			print_string(ap_prefixo)
			li $v0, 1
			move $a0, $s0     # imprime número do apt
			syscall
			print_line
			
			# "Moradores:\n"
			print_string(moradores_label)

			imprimir_moradores:
				beq $t3, 5, verificar_automoveis
				lb $t0, 0($s2)
				beq $t0, $zero, proximo_morador
				#imprimir espaço
				li $v0, 4
				la $a0, espaco
				syscall
				# imprimir nome do morador
				li $v0, 4
				add $a0, $zero, $s2
				syscall

				proximo_morador:
					addi $s2, $s2, 32
					addi $t3, $t3, 1
			j imprimir_moradores

			verificar_automoveis:
				# Calcula endereço da seção de veículos
				li $t1, 64			# cada veículo ocupa 64 bytes
				mul $t2, $s0, $t1	# cálcula o endereço do veículo com base no num do apt
				la $s3, veiculos	# carrega o endereço do espaço reservado para os veículos
				add $s3, $s3, $t2	# $s3 aponta para o primeiro veículo do apartamento especificado
			
				lb $t0, 0($s3)		# carrega o primeiro byte do veículo

				beq $t0, $zero, fim_print_ap # Nenhum automóvel cadastrado para o apt
			
				beq $t0, 'c', imprimir_carro
				beq $t0, 'm', imprimir_moto
			j input_loop

			imprimir_carro:
				# "Carro:\n"
				print_string(carro_label)
				# "Modelo: "
				print_string(modelo_label)
				# O modelo inicia após o byte de tipo
				addi $a0, $s3, 1
				li $v0, 4
				syscall
				print_line
				# "Cor: "
				print_string(cor_label)
				addi $a0, $s3, 18    # A cor inicia após modelo (1 + 17)
				li $v0, 4
				syscall
			j input_loop

			imprimir_moto:
				# "Moto:\n"
				print_string(moto_label)
				# Moto 1
				print_string(modelo_label)
				# O modelo inicia após o byte de tipo
				addi $a0, $s3, 1
				li $v0, 4
				syscall
				print_line
				# "Cor: "
				print_string(cor_label)
				addi $a0, $s3, 21
				li $v0, 4
				syscall

			# Moto 2 (verifica se existe)
			addi $s3, $s3, 32    # próximo slot de automóvel
			lb $t1, 0($s3)
			beq $t1, 'm', moto2
			j input_loop

			moto2:
				# "Modelo: "
				print_string(modelo_label)
				# O modelo inicia após o byte de tipo
				addi $a0, $s3, 1
				li $v0, 4
				syscall
				print_line
				# "Cor: "
				print_string(cor_label)
				addi $a0, $s3, 21
				li $v0, 4
				syscall
			j input_loop
		fim_print_ap:
			jr $ra
	
	# Imprime os dados de todos os apartamentos que não estão vazios em ordem crescente
	info_ap_all:
	li $t4, 0   # contador de apartamentos $t4 = 0 a 39

	loop_info_ap_all:
		bgt $t4, 39, input_loop  # se $t4 > 39, fim

		# Carrega número do AP atual em $s0 (usado por print_ap e demais funções)
		add $s0, $zero, $t4

		# Verifica se o apartamento está vazio
		# Calcula endereço base do ap: apartamentos + 160 * i
		li $t1, 160
		mul $t2, $s0, $t1
		la $s2, apartamentos
		add $s2, $s2, $t2    # $s2 aponta para o primeiro morador do apt atual

		li $t3, 0             		 # contador de vagas verificadas
		ap_vazio_all:
			beq $t3, 5, print_ap_vazio  # se 5 moradores checados e todos vazios -> vazio
			lb $t0, 0($s2)
			bne $t0, $zero, print_ap_all # encontrou um morador, então printar
			addi $s2, $s2, 32
			addi $t3, $t3, 1
		j ap_vazio_all
	j loop_info_ap_all

	print_ap_vazio:
		# Imprime "AP: <num_apt>" mesmo se vazio
		print_string(ap_prefixo)
		li $v0, 1
		add $a0, $zero, $s0
		syscall
		print_line
		print_string(ap_vazio)
	j proximo_ap_all
	
	print_ap_all:
		# Chama o mesmo código do print_ap
		addi $sp, $sp, -4	
		sw $ra, 0($sp)
		jal print_ap
		lw $ra, 0($sp)
		addi $sp, $sp, 4

	proximo_ap_all:
		addi $t4, $t4, 1
		j loop_info_ap_all

	apt_vazio:
		# Imprime que o apartamento está vazio
		print_string(ap_vazio)
		print_line
	j input_loop
	
info_geral:
    li $t0, 0          # contador geral de apartamentos (0..39)
    li $t1, 0          # contador de não vazios
    li $t2, 0          # contador de vazios

    la $t3, apartamentos   # base da estrutura de apartamentos (ajuste se necessário)

info_loop:
    bge $t0, 40, info_fim  # se chegou a 40, sai do loop

    lb $t4, 0($t3)         # lê byte que indica se apto está vazio (0) ou não vazio (1)

    beq $t4, $zero, apto_vazio

    # apartamento não vazio
    addi $t1, $t1, 1
    j prox_apt

apto_vazio:
    addi $t2, $t2, 1

prox_apt:
    addi $t3, $t3, 160  # avançar para o próximo apartamento (160 bytes)
    addi $t0, $t0, 1
    j info_loop

info_fim:
    li $t5, 40             # total de apartamentos

    # calcular porcentagem não vazios
    mul $t6, $t1, 100
    divu $t6, $t6, $t5     # usar divu para unsigned
    mflo $t7               # $t7 = % não vazios

    # calcular porcentagem vazios
    mul $t8, $t2, 100
    divu $t8, $t8, $t5     # usar divu para unsigned
    mflo $t9               # $t9 = % vazios

    # imprimir resultados

    # imprime "Não vazios:\t"
    la $a0, msg_nao_vazios
    li $v0, 4
    syscall

    # imprime número de não vazios
    move $a0, $t1
    li $v0, 1
    syscall

    # imprime " ("
    la $a0, par_abrir
    li $v0, 4
    syscall

    # imprime %
    move $a0, $t7
    li $v0, 1
    syscall

    # imprime "%)\n"
    la $a0, par_fechar
    li $v0, 4
    syscall

    # imprime "Vazios:\t\t"
    la $a0, msg_vazios
    li $v0, 4
    syscall

    # imprime número de vazios
    move $a0, $t2
    li $v0, 1
    syscall

    # imprime " ("
    la $a0, par_abrir
    li $v0, 4
    syscall

    # imprime %
    move $a0, $t9
    li $v0, 1
    syscall

    # imprime "%)\n"
    la $a0, par_fechar
    li $v0, 4
    syscall

    j input_loop    # volta para o loop principal

salvar:
	#Salvando apartamentos
	li $v0, 13 #carrega codigo de abrir/criar um arquivo
	la $a0, arquivo_apartamentos #caminho do arquivo de apartamentos
	li $a1, 1 # carrega o codigo para escrever
	li $a2, 664 # permissão rw-rw-r-- do arquivo
	syscall #executa (abre o arquivo)
	
	move $s0, $v0 # salva o descritor que voltou em v0 em s0
	
	li $v0, 15 # carrega o codigo de escrever no arquivo
	move $a0, $s0 # descritor
	la $a1, apartamentos # origem dos dados
	li $a2, 6400 # tamanho em bytes
	syscall
	
	li $v0, 16 # syscall para fechar arquivo
	move $a0, $s0
	syscall
	
	#Salvando veiculos
	li $v0, 13 #carrega codigo de abrir/criar um arquivo
	la $a0, arquivo_veiculos #caminho do arquivo de veiculos
	li $a1, 1 # carrega o codigo para escrever
	li $a2, 664 # permissão rw-rw-r-- do arquivo
	syscall #executa (abre o arquivo)
	
	move $s0, $v0 # salva o descritor que voltou em v0 em s0
	
	li $v0, 15 # carrega o codigo de escrever no arquivo
	move $a0, $s0 # descritor
	la $a1, veiculos # origem dos dados
	li $a2, 2560 # tamanho em bytes
	syscall
	
	li $v0, 16 # syscall para fechar arquivo
	move $a0, $s0
	syscall
	
	print_string(arquivo_salvo)
	j input_loop

recarregar:
	#Recarregando apartamentos
	li $v0, 13 #carrega codigo de abrir/criar um arquivo
	la $a0, arquivo_apartamentos #caminho do arquivo de apartamentos
	li $a1, 0 #carrega o codigo de modo de leitura
	li $a2, 0 #nao sera utilizado para recarregar o arquivo
	syscall
	
	move $s0, $v0 # salva o descritor
	
	li $v0, 14 # carrega o codigo de leitura
	move $a0, $s0 # passa o descritor
	la $a1, apartamentos # carrega os dados dos apartamentos
	li $a2, 6400 # tamanho em bytes a ser lido
	syscall
	
	li $v0, 16 # carrega o comando de fechar o arquivo
	move $a0, $s0 # passa o descritor
	syscall # fecha o arquivo
	
	#Recarregando veiculos
	li $v0, 13 # carrega o codigo para abrir o arquivo de veiculos
	la $a0, arquivo_veiculos # passa o caminho do arquivo
	li $a1, 0 # carrega o codigo de leitura
	li $a2, 0 #nao sera utilizado para recarregar o arquivo
	syscall
	
	move $s0, $v0 # salva o descritor
	
	li $v0, 14 # carrega o codigo de ler
	move $a0, $s0 # passa o descritor
	la $a1, veiculos # carrega os dados dos veiculos
	li $a2, 2560 # tamanho em bytes a ser lido
	syscall
	
	li $v0, 16 # carrega o codigo de fechar o arquivo
	move $a0, $s0 # passa o descritor
	syscall
	
	print_string(arquivo_recarregado)
	j input_loop

formatar:
	# === ZERA memória dos apartamentos ===
	la $t0, apartamentos
	li $t1, 6400
	li $t2, 0

loop_zera_ap:
	beqz $t1, fim_zera_ap
	sb $t2, 0($t0)
	addi $t0, $t0, 1
	subi $t1, $t1, 1
	j loop_zera_ap

fim_zera_ap:

	#Zerando memória dos veículos
	la $t0, veiculos
	li $t1, 2560
	li $t2, 0

loop_zera_veic:
	beqz $t1, fim_zera_veic
	sb $t2, 0($t0)
	addi $t0, $t0, 1
	subi $t1, $t1, 1
	j loop_zera_veic

fim_zera_veic:

	#Sobrescrevendo o arquivo de apartamentos
	li $v0, 13
	la $a0, arquivo_apartamentos
	li $a1, 1          # modo escrita (recria)
	li $a2, 664        # permissões
	syscall
	move $s0, $v0

	li $v0, 15
	move $a0, $s0
	la $a1, apartamentos
	li $a2, 6400
	syscall

	li $v0, 16
	move $a0, $s0
	syscall

	# === Sobrescreve arquivo de veículos ===
	li $v0, 13
	la $a0, arquivo_veiculos
	li $a1, 1
	li $a2, 664
	syscall
	move $s0, $v0

	li $v0, 15
	move $a0, $s0
	la $a1, veiculos
	li $a2, 2560
	syscall

	li $v0, 16
	move $a0, $s0
	syscall

	# === MENSAGEM DE SUCESSO ===
	print_string(formatado)

	j input_loop
sair:
	li $v0, 10 #encerra o programa
	syscall

read_ap:
	# Converte o número do apartamento (ASCII -> int)
	li $s0, 0                      # $s0 armazenará o número do apartamento
	li $t2, 48                     # caractere '0'
	read_ap_loop:
		lb $t1, 0($t0)	# carrega o char do endereço atual
		
		beq $t1, 45, fim_read_ap       # encontrou o próximo hífen
		beq $t1, 10, fim_read_ap       # encontrou uma quebra de linha ('\n')
		blt $t1, 48, comando_invalido  # 48 é o código do menor digito em ascii ('0' = 48)
		bgt $t1, 57, comando_invalido  # 47 é o código do maior digito em ascii ('9' = 57)
		
		sub $t3, $t1, $t2              # dígito numérico
		mul $s0, $s0, 10			   # adicionado mais uma casa númerica
		add $s0, $s0, $t3			   # incrementa o digito no número do apartamento
		addi $t0, $t0, 1			   # vai para o próximo digito do num do apartamento
	j read_ap_loop

fim_read_ap:
	jr $ra
	
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
