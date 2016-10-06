% ============================================================================
% ============================================================================
%
%	   LOGICA PARA PROGRAMACAO - 2015/2016, 1o. ANO, 2o. SEMESTRE
%
%	             Labirintos | PROLOG - GRUPO 07, Al.
%	         83418 - Afonso Feijao, 83550 - Pedro Santos
%
% ============================================================================
% ============================================================================
%
% ==================================MOVIMENTOS================================
%
%(PREDICADO AUXILIAR)
% move/3 - move(Posicao, Tipo, Resultado) recebe a posicao e o tipo de
% movimento ([c,b,e,d]) e calcula a posicao final do movimento.
move((PosL, PosC), c, (c, Res, PosC)):- !,
	Res is PosL - 1.
move((PosL, PosC), b, (b, Res, PosC)):-	!,
	Res is PosL + 1.
move((PosL, PosC), e, (e, PosL, Res)):-	!,
	Res is PosC - 1.
move((PosL, PosC), d, (d, PosL, Res)):-	!,
	Res is PosC + 1.

% ====================== RESOLVES - Predicados Principais ====================
%
% resolve1/4 - resolve1(Lab, Pos_inicial, Pos_final, Movs) recebe o
% labirinto (Lab), a posicao inicial(Pos_inicial) e final(Pos_final) e
% calcula o resultado para o labirinto (Movs) escolhendo os movimentos
% pela ordem [c,b,e,d].
% (Processo iterativo).
resolve1(Lab, Pos_inicial, Pos_final, Movs):- !,
	resolve1(Lab, Pos_inicial, Pos_final, Movs, []).

resolve1(_, (PosL, PosC), (PosL, PosC), Movs, Movs):- !.
resolve1(Lab, (PosL, PosC), Pos_final, Movs, []):-
	!,
	resolve1(Lab, (PosL, PosC), Pos_final, Movs ,[(i , PosL, PosC)]).

resolve1(Lab, Pos, Pos_final, Poss, L):-
	movs_possiveis(Lab, Pos, L, Movs_aux),
	(
	nth1(1, Movs_aux, (T, PosL, PosC)); /*testa para todos os movs possiveis*/
	nth1(2, Movs_aux, (T, PosL, PosC)); /*(maximo de movimentos poss.= 3)*/
	nth1(3, Movs_aux, (T, PosL, PosC))
	),
	append( L ,[(T, PosL, PosC)], Res),
	resolve1(Lab, (PosL, PosC), Pos_final, Poss, Res), !.

% resolve2/4 - resolve2(Lab, Pos_inicial, Pos_final, Movs) recebe o
% labirinto (Lab), a posicao inicial(Pos_inicial) e final(Pos final) e
% calcula o resultado para o labirinto (Movs). Cada movimento e'
% escolhido de acordo com a distancia 'a posicao final e inicial.
% (Processo iterativo).
resolve2(Lab, Pos_inicial, Pos_final, Movs):- !,
	resolve2(Lab, Pos_inicial, Pos_final, Movs, [], Pos_inicial).

resolve2(_, (PosL, PosC), (PosL, PosC), Movs, Movs,_):- !.
resolve2(Lab, (PosL, PosC), Pos_final, Movs, [], Pos_inicial):-
	!,
	resolve2(Lab, (PosL, PosC), Pos_final, Movs ,[(i , PosL, PosC)], Pos_inicial).

resolve2(Lab, Pos, Pos_final, Poss, L, Pos_inicial):-
	movs_possiveis(Lab, Pos, L, L_1),
	ordena_poss(L_1, Movs_aux, Pos_inicial, Pos_final),
	(
	nth1(1, Movs_aux, (T, PosL, PosC)); /*testa para todos os movs possiveis*/
	nth1(2, Movs_aux, (T, PosL, PosC));  /*(maximo de movimentos poss.= 3)*/
	nth1(3, Movs_aux, (T, PosL, PosC))
	),
	append( L ,[(T, PosL, PosC)], Res),
	resolve2(Lab, (PosL, PosC), Pos_final, Poss, Res, Pos_inicial), !.

% ====================== MOVIMENTOS POSSIVEIS===========================
%
% movs_possiveis/4 - movs_possiveis(Lab, Posicao, Movs, Poss) recebe o
% labirinto (Lab), a posicao atual (Posicao) e calcula os movimentos
% possiveis com base nas restricoes do tabuleiro e os movimentos
% anteriores.
movs_possiveis(Lab, (PosL, PosC) , Movs , Poss):- !,
       nth1(PosL, Lab, Item),
       nth1(PosC, Item, Esp),
       subtract([c,b,e,d], Esp, Aux),
       cria_lista_movimentos(Aux, (PosL, PosC), Poss, Movs).

%(PREDICADO AUXILIAR)
% cria_lista_movimentos/4 - cria_lista_movimentos(Poss, Pos_atual,
% Res, Movs) recebe os tipos de movimentos possiveis([c,b,e,d]) (Poss),
% a posicao atual (Pos_atual) e e os movimentos efetuados (Movs) e cria
% a lista dos movimentos possiveis tendo em conta os movimentos
% efetuados anteriormente.
% Exemplo: cria_lista_movimentos([e,b], (2,2), Res, (c,2,1))
% devolve: Res = [(b,3,2)]
% (Processo iterativo).
cria_lista_movimentos(L, Ponto, Poss, Movs):-
	cria_lista_movimentos(L, Ponto, Poss, Movs, []).
cria_lista_movimentos([],(_,_), Res,_,Res):- !.
cria_lista_movimentos([Cab|Resto], (PosL, PosC), Poss, Movs, Aux):-
	move( (PosL, PosC), Cab, (Tipo, PosL_1, PosC_1)),
	(   \+member( (_,PosL_1, PosC_1), Movs) ->
	append(Aux, [(Tipo, PosL_1, PosC_1)], Res),
	cria_lista_movimentos(Resto, (PosL, PosC), Poss, Movs, Res)
	;
	cria_lista_movimentos(Resto, (PosL, PosC), Poss, Movs, Aux)
	).

% ===========================DISTANCIA==================================
%
% distancia/3 - distancia(Posicao, Posicao, Dist)
% recebe dois pontos (Posicao) e calcula a distancia (Dist) entre os
% dois.
distancia( (L1, C1), (L2, C2), Dist) :- Dist is abs(L1-L2) + abs(C1 -C2).

% ====================== ORDENA POSSIVEIS===============================
%
% ordena_poss/4 - ordena_poss(Movs_poss, Poss_ord, Pos_inicial,
% Pos_final) recebe os movimentos possiveis (Movs_poss), a posicao
% inicial (Pos_inicial), a posicao final(Pos_final) e ordena os
% movimentos tendo por base a distancia entre a posicao atual e a
% posicao final e inicial. Obs: Implementacao do quicksort.
ordena_poss([],[],_,_):- ! .
ordena_poss([X|Resto], Poss_ord, Pos_inicial, Pos_final):-
    split(X, Resto, Small, Big, Pos_final, Pos_inicial),
    ordena_poss(Small, Ordenado_1, Pos_inicial, Pos_final),
    ordena_poss(Big, Ordenado_2, Pos_inicial, Pos_final),
    append(Ordenado_1, [X|Ordenado_2], Poss_ord),!.

% (PREDICADO AUXILIAR)
% Predicado de particao (partition: Auxiliar do quicksort)
split(_,[],[],[],_,_):- !.
split( (_,PosL, PosC) ,[ (Tipo,PosL_1, PosC_1) |Resto],
       [ (Tipo, PosL_1, PosC_1) |Small], Big, Pos_final, Pos_inicial):-
    distancia( (PosL, PosC), Pos_final, Res1),
    distancia( (PosL_1, PosC_1), Pos_final, Res2),
    Res1 > Res2,
    !,
    split((_,PosL, PosC), Resto, Small, Big, Pos_final, Pos_inicial).

split( (_,PosL, PosC) ,[ (Tipo, PosL_1, PosC_1) |Resto],
       [ (Tipo,PosL_1, PosC_1) |Small], Big, Pos_final, Pos_inicial):-
    distancia( (PosL, PosC), Pos_final, Res1),
    distancia( (PosL_1, PosC_1), Pos_final, Res2),
    Res1 == Res2,
    distancia( (PosL, PosC), Pos_inicial, Res_1),
    distancia( (PosL_1, PosC_1), Pos_inicial, Res_2),
    Res_1 < Res_2, %em caso de igualdade (distancia a posicao inicial)%
    !,
    split( (_,PosL, PosC), Resto, Small, Big, Pos_final, Pos_inicial).

split(X,[Y|Resto], Small, [Y|Resto_1], Pos_final, Pos_inicial):-
    split(X, Resto, Small, Resto_1, Pos_final, Pos_inicial).




















