# ===========================================================
# Identificacao do grupo:  [T?? para Tagus ou A?? para Alameda]
# A36
# Membros [istID, primeiro + ultimo nome]
# 1. ist1113887 - Francisco Pinto
# 2. ist1114077 - Francisco Carvalho
# 3. ist1113875 - Tiago Andrês
$
# ===========================================================
# Descricao da ISA Implementada
#
# == Formato das Instrucoes ==
# Indicar a divisao dos campos da instrucao
# Justificar decisoes: Por que escolheram esse numero de bits? Ha instrucoes com formatos diferentes?
  O nosso processador suporta dois formatos de instrução, um para as operações que utilizam imediato (addi, subi, li) e outro para as que não utilizam imediato (abs, relu). Passamos agora a descrever o primeiro formato, este possui o seguinte formato:

Imediato (6 bits) | opcode (2 bits)
 
Escolhemos este formato pois reserva bastante espaço para o imediato (incluindo um bit de sinal), permitindo realizar estas operações com imediatos de dimensões razoáveis, com sinal e em simultâneo não perde nenhuma capacidade de controlar a operação a realizar pois estas instruções apenas dependem de um opcode de 2 bits. Apresentamos agora os opcodes específicos de cada instrução que utiliza este formato:

Addi- 01
Subi- 10
Li- 11

Passamos agora a descrever o seguinte formato de instrução, este é utilizado pelas instruções que não utilizam imediatos nas suas operações, e portanto para conseguirmos manter apenas os 2 bits de opcode adicionamos mais um bit de controlo específico para escolher entre estas duas operações, chamamos a esse bit funct, dito isto os restantes bits da instrução são insignificantes, ficamos portanto com o seguinte formato da instrução:

5 bits insignificantes | funct (1 bit) | opcode (2bits)

Tanto a relu como a abs são operações deste tipo usando portanto o mesmo opcode, sendo este opcode=00, o que as distingue é o bit de funct, sendo o bit funct = 0 referente à operação abs e o bit funct = 1 referente a operação relu. Ficamos portando com as seguintes especificações destas duas instruções:

abs – funct = 0, opcode = 00
relu – funct = 1, opcode = 00

Estes dois tipos de instruções permitem-nos manter a simplicidade do processador e a sua versatilidade levando em conta as diferenças entre as operações com imediatos e sem imediatos e conferindo uma lógica simples.

#
# == Sumario dos Estagios do Pipeline==
# Descrever brevemente cada estagio (componentes de hardware utilizados)
O nosso processador é de ciclo único não utilizando, portanto pipelining. Os estágios que o nosso processador tem são:
1-instruction fetch: neste estágio é passado o conteúdo do pc (program counter) para a ROM obtendo a instrução a ser executada, de seguida o pc é incrementado e fica pronto para o fetch da próxima instrução

2-instruction decode: neste estágio a instrução e dividida pelos bits que correspondem a cada parte da instrução, ou seja, os dois bits menos significativos serão o opcode, o terceiro bit é o bit funct no caso das instruções que não usam imediato, para as instruções que usam imediato do terceiro ao oitavo bit é o imediato, este e passado para um extensor que o vai colocá-lo a 8 bits para serem realizadas as operações necessárias.

3-Execute: neste estagio as operações são executadas, por exemplo a faz a soma ou subtração do conteúdo presente no registo com o imediato pretendido, no caso das operações com o imediato, na abs, é extraído o bit mais significativo do conteúdo do registo, este será o bit  de seleção para um MUX em que a primeira entrada é o conteúdo do registo sem alterações, e a segunda entrada é o resultado da operação 0-conteudo do registo, ou seja o simétrico do conteúdo, logo o se o bit mais significativo for 0 (o numero é positivo) passa o numero original, se for 1 (o numero é negativo) passa o seu simétrico, a relu segue um lógica semelhante, é extraído o bit mais significativo, e este torna a ser o bit de seleção de um MUX em que a primeira entrada é novamente o conteúdo do registo sem alterações, mas a segunda entrada é a constante zero, ou seja, se o bit mais significativo for 0 (número positivo) passa o numero original, se o bit mais significativo for 1  (número negativo) passa zero, por fim e selecionado o resultado da abs ou relu utilizando um MUX que utiliza como bit de seleção o bit funct da instrução. No caso da operação li, o processo é mais simples, o imediato é apenas convertido para 8 bits.

4-write back: neste estágio é selecionada a operação relativa à instrução no MUX final, utilizando o opcode da instrução e o resultado é escrito no registo.

#
# == Sinais de Controlo ==
# Explicar o que cada sinal ativa/desativa/seleciona e como sao gerados.
Como foi dito anteriormente o nosso processador tem dois sinais de controlo, o opcode, utilizado por todas as instruções, este serve para selecionar no MUX final o resultado a ser passado para escrita no registo. O outro sinal de controlo é o bit funct, este é apenas usado pelas instruções abs e relu, e serve para escolher num MUX anterior ao MUX final qual das operações abs ou relu passar para o MUX final, permitindo assim que o MUX final tenha apenas 4 entradas, sem perder funcionalidades. 
#
# ===========================================================
# Requisitos do enunciado que *nao* estao corretamente implementados:
# (indicar um por linha, ou responder "nenhum")
# - nenhum
#
# ===========================================================
# Top-3 das otimizacoes que a vossa solucao incorpora:
# (maximo 140 caracteres por cada otimizacao)
#
# 1.
#
# 2.
#
# 3.
#
# ===========================================================
