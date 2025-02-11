% === Base di conoscenza ===
:- dynamic condizione_meteo/2, illuminazione/2, superficie_stradale/2, gravita_incidente/2.

% Clausole definite per la classificazione della gravità
% ∀ID: incidente_grave(ID) se ci sono almeno due condizioni pericolose
incidente_grave(ID) :- 
    almeno_due_condizioni_pericolose(ID, Conditions),
    length(Conditions, N),
    N >= 2.

% Raccolta e verifica delle condizioni pericolose
% ∀ID: almeno_due_condizioni_pericolose(ID, Conditions) se esiste un insieme di condizioni pericolose
almeno_due_condizioni_pericolose(ID, ConditionsWithDetails) :-
    findall(Condition-Descr, (
        (scarsa_visibilita(ID, Descr), Condition = 'Scarsa visibilità');
        (meteo_estremo(ID, Descr), Condition = 'Meteo estremo');
        (superficie_pericolosa(ID, Descr), Condition = 'Superficie pericolosa');
        (combinazione_critica(ID, Descr), Condition = 'Combinazione critica')
    ), ConditionsWithDetails).

% Regole per la scarsa visibilità
% ∀ID: scarsa_visibilita(ID, Descrizione) se esiste una descrizione valida
scarsa_visibilita(ID, Descrizione) :-
    (illuminazione(ID, buio), \+ illuminazione(ID, artificiale)) ->
        Descrizione = 'Buio senza illuminazione artificiale'
    ; (condizione_meteo(ID, nebbia)) ->
        Descrizione = 'Presenza di nebbia'
    ; fail.

% Regole per il meteo estremo
% ∀ID: meteo_estremo(ID, Descrizione) se esiste una descrizione valida
meteo_estremo(ID, Descrizione) :-
    (condizione_meteo(ID, nebbia)) ->
        Descrizione = 'Presenza di nebbia densa'
    ; (condizione_meteo(ID, neve)) ->
        Descrizione = 'Presenza di neve'
    ; (condizione_meteo(ID, grandine)) ->
        Descrizione = 'Presenza di grandine'
    ; (condizione_meteo(ID, vento_forte), condizione_meteo(ID, pioggia)) ->
        Descrizione = 'Vento forte con pioggia'
    ; fail.

% Regole per la superficie pericolosa
% ∀ID: superficie_pericolosa(ID, Descrizione) se esiste una descrizione valida
superficie_pericolosa(ID, Descrizione) :-
    (superficie_stradale(ID, ghiacciata)) ->
        Descrizione = 'Strada ghiacciata'
    ; (superficie_stradale(ID, bagnata), condizione_meteo(ID, pioggia)) ->
        Descrizione = 'Strada bagnata con pioggia'
    ; (superficie_stradale(ID, umida), condizione_meteo(ID, nebbia)) ->
        Descrizione = 'Strada umida con nebbia'
    ; fail.

% Regole per le combinazioni critiche
% ∀ID: combinazione_critica(ID, Descrizione) se esiste una descrizione valida
combinazione_critica(ID, Descrizione) :-
    (illuminazione(ID, buio), condizione_meteo(ID, nebbia)) ->
        Descrizione = 'Buio con nebbia'
    ; (superficie_stradale(ID, ghiacciata), 
       (condizione_meteo(ID, pioggia); condizione_meteo(ID, neve))) ->
        Descrizione = 'Superficie ghiacciata con precipitazioni'
    ; (condizione_meteo(ID, vento_forte), 
       condizione_meteo(ID, pioggia), 
       superficie_stradale(ID, bagnata)) ->
        Descrizione = 'Vento forte con pioggia su strada bagnata'
    ; fail.

% Completamento di Clark per le regole
% ∀ID: scarsa_visibilita(ID, Descrizione) ↔ (illuminazione(ID, buio) ∧ ¬illuminazione(ID, artificiale)) ∨ condizione_meteo(ID, nebbia)
% ∀ID: meteo_estremo(ID, Descrizione) ↔ condizione_meteo(ID, nebbia) ∨ condizione_meteo(ID, neve) ∨ condizione_meteo(ID, grandine) ∨ (condizione_meteo(ID, vento_forte) ∧ condizione_meteo(ID, pioggia))
% ∀ID: superficie_pericolosa(ID, Descrizione) ↔ superficie_stradale(ID, ghiacciata) ∨ (superficie_stradale(ID, bagnata) ∧ condizione_meteo(ID, pioggia)) ∨ (superficie_stradale(ID, umida) ∧ condizione_meteo(ID, nebbia))
% ∀ID: combinazione_critica(ID, Descrizione) ↔ (illuminazione(ID, buio) ∧ condizione_meteo(ID, nebbia)) ∨ (superficie_stradale(ID, ghiacciata) ∧ (condizione_meteo(ID, pioggia) ∨ condizione_meteo(ID, neve))) ∨ (condizione_meteo(ID, vento_forte) ∧ condizione_meteo(ID, pioggia) ∧ superficie_stradale(ID, bagnata))

% Abduzione migliorata
% ∃ID: applica_abduzione(ID) se esiste un ID per cui è possibile dedurre nuove informazioni
applica_abduzione(ID) :-
    abduzione_da_meteo(ID),
    abduzione_da_superficie(ID),
    abduzione_da_illuminazione(ID).

% Abduzione dalle condizioni meteo
% ∃ID: abduzione_da_meteo(ID) se esiste un ID per cui è possibile dedurre nuove informazioni
abduzione_da_meteo(ID) :-
    (condizione_meteo(ID, pioggia),
     \+ superficie_stradale(ID, _) ->
        assertz(superficie_stradale(ID, bagnata)),
        format('Abduzione: Dedotta superficie bagnata per presenza di pioggia~n')
    ; true),
    
    (condizione_meteo(ID, neve),
     \+ superficie_stradale(ID, _) ->
        assertz(superficie_stradale(ID, ghiacciata)),
        format('Abduzione: Dedotta superficie ghiacciata per presenza di neve~n')
    ; true),
    
    (condizione_meteo(ID, nebbia),
     \+ illuminazione(ID, _) ->
        assertz(illuminazione(ID, ridotta)),
        format('Abduzione: Dedotta illuminazione ridotta per presenza di nebbia~n')
    ; true).

% Abduzione dalla superficie
% ∃ID: abduzione_da_superficie(ID) se esiste un ID per cui è possibile dedurre nuove informazioni
abduzione_da_superficie(ID) :-
    (superficie_stradale(ID, bagnata),
     \+ (condizione_meteo(ID, _)) ->
        assertz(condizione_meteo(ID, pioggia)),
        format('Abduzione: Dedotta pioggia da superficie bagnata~n')
    ; true),
    
    (condizione_meteo(ID, nebbia),
     \+ superficie_stradale(ID, _) ->
        assertz(superficie_stradale(ID, umida)),
        format('Abduzione: Dedotta superficie umida per presenza di nebbia~n')
    ; true).

% Abduzione dall'illuminazione
% ∃ID: abduzione_da_illuminazione(ID) se esiste un ID per cui è possibile dedurre nuove informazioni
abduzione_da_illuminazione(ID) :-
    (condizione_meteo(ID, nebbia),
     \+ illuminazione(ID, _) ->
        assertz(illuminazione(ID, ridotta)),
        format('Abduzione: Dedotta illuminazione ridotta per presenza di nebbia~n')
    ; true).

% Analisi completa dell'incidente
% ∀ID: analizza_incidente(ID) se esiste un ID per cui è possibile analizzare l'incidente
analizza_incidente(ID) :-
    format('~n=== Analisi dell\'incidente ~w ===~n', [ID]),
    mostra_condizioni(ID),
    applica_abduzione(ID),
    format('~nCondizioni dopo abduzione:~n'),
    mostra_condizioni(ID),
    (almeno_due_condizioni_pericolose(ID, Conditions) ->
        length(Conditions, N),
        format('Rilevate ~w condizioni pericolose:~n', [N]),
        stampa_condizioni_pericolose(Conditions),
        (N >= 2 ->
            retractall(gravita_incidente(ID, _)),
            assertz(gravita_incidente(ID, grave)),
            format('~nCONCLUSIONE: Incidente classificato come GRAVE~n')
        ;
            retractall(gravita_incidente(ID, _)),
            assertz(gravita_incidente(ID, lieve)),
            format('~nCONCLUSIONE: Incidente classificato come LIEVE~n'))
    ;
        format('Nessuna condizione pericolosa rilevata~n'),
        retractall(gravita_incidente(ID, _)),
        assertz(gravita_incidente(ID, lieve)),
        format('~nCONCLUSIONE: Incidente classificato come LIEVE~n')).

% Visualizzazione condizioni
% ∀ID: mostra_condizioni(ID) se esiste un ID per cui è possibile mostrare le condizioni
mostra_condizioni(ID) :-
    format('Condizioni dell\'incidente ~w:~n', [ID]),
    format('- Meteo: '),
    findall(M, condizione_meteo(ID, M), Meteo),
    (Meteo \= [] -> 
        atomic_list_concat(Meteo, ', ', MeteoStr),
        write(MeteoStr)
    ; write('non specificato')), nl,
    format('- Illuminazione: '),
    (illuminazione(ID, I) -> write(I); write('non specificato')), nl,
    format('- Superficie: '),
    (superficie_stradale(ID, S) -> write(S); write('non specificato')), nl,
    format('- Gravità: '),
    (gravita_incidente(ID, G) -> write(G); write('non ancora valutato')), nl.

% Stampa delle condizioni pericolose
% ∀ID: stampa_condizioni_pericolose(Conditions) se esiste un insieme di condizioni pericolose
stampa_condizioni_pericolose([]).
stampa_condizioni_pericolose([Condition-Descrizione|Rest]) :-
    format('- ~w: ~w~n', [Condition, Descrizione]),
    stampa_condizioni_pericolose(Rest).

% Utility per reset
% ∀ID: reset_incidente(ID) se esiste un ID per cui è possibile resettare le informazioni
reset_incidente(ID) :-
    retractall(condizione_meteo(ID, _)),
    retractall(illuminazione(ID, _)),
    retractall(superficie_stradale(ID, _)),
    retractall(gravita_incidente(ID, _)).