# CLAUDE.md – Balance

Balance è l'app personale di Matteo (studente di Ingegneria Informatica, si allena in palestra e corre): organizza palestra e corsa in base al calendario degli esami e a come si sente ogni giorno. Progetto a tempo perso, senza scadenze, fatto per imparare.

## Stack
- Flutter (Dart), target **web** → PWA installata su **iPhone** da Safari ("Aggiungi alla schermata Home").
- Dati solo locali sul dispositivo (nessun backend per ora). Prevedere export/import JSON.
- Deploy: `flutter build web` + GitHub Pages (ricordare `--base-href /<nome-repo>/`).
- Tutto deve restare gratuito. Niente build native iOS/Android per ora.

## Comandi utili
- Avvio in sviluppo: `flutter run -d chrome`
- Test dall'iPhone (stessa WiFi): `flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080`, poi aprire `http://<IP-del-PC>:8080`
- Analisi e test: `flutter analyze`, `flutter test`

## Funzioni (4 sezioni, barra di navigazione in basso)
1. **Oggi**: check-in "Come stai oggi?" → suggerimento su come impostare l'allenamento del giorno (dalla scheda) con motivazione; spunta dell'allenamento fatto con i dati essenziali; se manca circa una settimana a un esame, promemoria a concentrarsi sullo studio.
2. **Scheda**: scheda palestra inserita in modo strutturato (giorni → esercizi → serie, ripetizioni, carico), con durata della programmazione (settimane) e data di inizio, + eventuale foto/PDF allegato solo come riferimento.
3. **Calendario**: interno all'app, l'utente inserisce a mano le date degli esami (nessun collegamento a calendari esterni).
4. **Progressi e scarico**: andamento carichi e corse; settimana di scarico calcolata automaticamente dalla scheda in due casi: (a) fine della programmazione, (b) indolenzimento segnalato nel check-in per troppi giorni di fila.

Logica a regole "se... allora..." leggibili e facili da modificare, **separate dalla UI**.
**Importante:** gli esami NON devono mai ridurre volume o intensità dell'allenamento; generano solo un promemoria sullo studio.
Ordine di costruzione: Scheda → Oggi → Calendario → Progressi e scarico.

## Stile e responsive
- Semplice ed estetica: Material 3, un colore principale, card arrotondate, molto spazio.
- Deve funzionare su tutti gli iPhone: niente dimensioni fisse per i blocchi principali, `ListView` per lo scorrimento, `SafeArea`, larghezza massima ~500 centrata, testi dal `TextTheme`.
- Verificare su iPhone SE, iPhone 12 Pro (= iPhone 13 di Matteo) e iPhone 14 Pro Max (modalità dispositivo di Chrome).

## Come lavorare con me
- Rispondi **in italiano**.
- Voglio **imparare**: spiega le parti importanti del codice e il perché delle scelte. Se posso farlo da solo con un suggerimento, dammi prima il suggerimento.
- **Un passo alla volta**: modifiche piccole che posso provare subito. Non riscrivere o ristrutturare file interi senza chiedermelo.
- Prima di aggiungere un pacchetto (pub.dev) spiegami a cosa serve e se c'è un'alternativa più semplice.
- Codice semplice e leggibile prima di tutto; niente architetture complicate per un'app di questa dimensione.
- Se sto complicando troppo le cose o aggiungendo funzioni inutili, dimmelo.
- L'app non sostituisce un medico o un professionista dello sport.
