# CLAUDE.md – Allenati in sessione

App personale di Matteo (studente di Ingegneria Informatica, si allena in palestra e corre): organizza palestra e corsa in base al calendario degli esami e a come si sente ogni giorno. Progetto a tempo perso, senza scadenze, fatto per imparare.

## Stack
- Flutter (Dart), target **web** → PWA installata su **iPhone** da Safari ("Aggiungi alla schermata Home").
- Dati solo locali sul dispositivo (nessun backend per ora). Prevedere export/import JSON.
- Deploy: `flutter build web` + GitHub Pages (ricordare `--base-href /<nome-repo>/`).
- Tutto deve restare gratuito. Niente build native iOS/Android per ora.

## Comandi utili
- Avvio in sviluppo: `flutter run -d chrome`
- Test dall'iPhone (stessa WiFi): `flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080`, poi aprire `http://<IP-del-PC>:8080`
- Analisi e test: `flutter analyze`, `flutter test`

## Prima versione (3 schermate)
1. **Oggi**: avviso esame vicino, check-in (Stanco / Normale / Carico), allenamento del giorno con motivazione, pulsanti "Fatto" / "Sposta".
2. **Registra allenamento**: palestra (esercizio, serie, ripetizioni, kg) o corsa (km, tempo, sensazione).
3. **Progressi**: carico settimanale, andamento di squat e tempi sui 5 km.

Logica a regole "se... allora..." leggibili e facili da modificare, tenute separate dalla UI (es. esame entro 7 giorni → volume -30%; gambe ieri → niente corsa intensa; stanco 3 giorni di fila → riposo).

## Come lavorare con me
- Rispondi **in italiano**.
- Voglio **imparare**: spiega le parti importanti del codice e il perché delle scelte. Se posso farlo da solo con un suggerimento, dammi prima il suggerimento.
- **Un passo alla volta**: modifiche piccole che posso provare subito. Non riscrivere o ristrutturare file interi senza chiedermelo.
- Prima di aggiungere un pacchetto (pub.dev) spiegami a cosa serve e se c'è un'alternativa più semplice.
- Codice semplice e leggibile prima di tutto; niente architetture complicate per un'app di questa dimensione.
- Se sto complicando troppo le cose o aggiungendo funzioni inutili, dimmelo.
- L'app non sostituisce un medico o un professionista dello sport.
