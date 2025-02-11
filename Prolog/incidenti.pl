% Dichiarazioni dinamiche
:- dynamic buio/0, luce_artificiale/0, pioggia/0, grandine/0, neve/0,
         vento_forte/0, superficie/1, nebbia/0, ghiacciato/0.

% Inizializzazione separata
:- initialization((
    retractall(buio),
    retractall(luce_artificiale),
    retractall(pioggia),
    retractall(grandine),
    retractall(neve),
    retractall(vento_forte),
    retractall(superficie(_)),
    retractall(nebbia),
    retractall(ghiacciato),
    assertz(superficie(asciutto))
)).

% Illuminazione
luce :- \+ buio.
buio_luce_artificiale :- buio, luce_artificiale.

% Meteo
tempo_sereno :- \+ (pioggia; grandine; neve; vento_forte).
nebbia :- vento_forte; pioggia.
vento :- vento_forte.
piove :- pioggia.

% Condizioni superficiali
asciutto :- superficie(asciutto).
bagnato :- superficie(bagnato).
ghiacciato :- superficie(ghiacciato).

% Regole per incidente grave
incidente_grave :- 
    condizione_pericolosa([scarsa_visibilita, meteo_estremo, superficie_pericolosa, combinazione_critica]).

scarsa_visibilita :- buio, \+ buio_luce_artificiale; nebbia.
meteo_estremo :- grandine; neve; vento_forte.
superficie_pericolosa :- ghiacciato; (bagnato, (pioggia; nebbia)).
combinazione_critica :- 
    (buio, nebbia);
    (ghiacciato, pioggia);
    (vento_forte, pioggia);
    (neve, buio);
    (grandine, vento_forte).

% Predicato generale per verificare condizioni
condizione_pericolosa([]) :- false.
condizione_pericolosa([H|T]) :- (call(H) -> true ; condizione_pericolosa(T)).

% Predicato di verifica flessibile
evaluta_condizioni(Condizioni, Risultato) :-
    setup_call_cleanup(
        apply_conditions(Condizioni, Aggiunte),
        (incidente_grave -> Risultato = true ; Risultato = false),
        maplist(retract_condition, Aggiunte)
    ).

apply_conditions([], []).
apply_conditions([\+ X | T], Aggiunte) :- !, % Gestione della negazione
    retractall(X),
    apply_conditions(T, Aggiunte).
apply_conditions([X | T], [X | Aggiunte]) :-
    assert_condition(X),
    apply_conditions(T, Aggiunte).

% Gestione condizioni
temp_assert_condition(superficie(X)) :- retractall(superficie(_)), assertz(superficie(X)).
temp_assert_condition(X) :- assertz(X).

assert_condition(X) :- temp_assert_condition(X).
retract_condition(superficie(X)) :- retractall(superficie(X)).
retract_condition(X) :- retractall(X).
