# ICON-Project
Questo repository contiene varie applicazione degli argomenti discussi nel corso di Ingegneria della Conoscenza

### COMANDI PER ATTIVAZIONE VIRTUAL ENVIROMENTS

1. Nella directory della repository, per abilitare l'ambiente:
    ```fan_env\Scripts\activate```

2. Nella directory della repository, per disabilitare l'ambiente:
    ```deactivate```

### AGGIUNTA LIBRERIE UTILI ALLO SVILUPPO

1. Installazione delle librerie dopo aver abilitato l'ambiente:
    ```pip install "nome libreria"```

2. Per aggiornare la lista dei requirements, lanciare nella root della repository:
     ```pip freeze > requirements.txt```

> *INSTALLARE* NBConvert (previa installazione di pandoc, MikTeX e Jupyter. Previa anche aggiunta dei suddetti programmi a path)
> Comando per convertire un file Jupyter in .pdf
> ```jupyter nbconvert --to pdf <nome_file>.ipynb```

### ISTRUZIONI GENERALI
- Cercare di coprire quanti più aspetti possibili dell'argomento
- Creare un documento per la documentazione associato ad ogni issue seguendo il template nella cartella ./Doc, chiamato con il nome della Issue
