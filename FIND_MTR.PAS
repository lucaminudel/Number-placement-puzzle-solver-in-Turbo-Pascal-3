
PROGRAM quadrati_magici(input,output);

{$R-}
{$U-}
{$C-}
{$V-}

CONST
      max_lato = 10;
      max_n_caselle = 100; { max_lato x max_lato }
      lato = 5;            { lato ó max_lato }
      n_caselle = 25;      { lato x lato }
      fuori_lato_d = 8;    { lato + 3 }
      fuori_lato_s = -2;

TYPE
     t_mossa = RECORD
                 x,y : 1..lato;
               END;
     t_mosse = RECORD
                 scelta : ARRAY[1..8] OF t_mossa;
                 n_scelte : 0..8;
               END;
     t_scacchiera = ARRAY[1..lato,1..lato] OF 0..n_caselle;

VAR
    out : text;
    scacchiera : t_scacchiera;
    mossa_attuale,
    mossa_iniziale : t_mossa;
    mosse : t_mosse;
    numero : 1..n_caselle;
    mossa_scelta : 1..8;
    numero_tentativi,
    tentativi_riusciti,
    sum_risultati,
    tmp : real;
    max_risultato,
    max_parziale : integer;
    ok : boolean;
    print_mtr : ARRAY[1..max_lato,1..max_lato] OF 1..max_n_caselle;
    print_margine : integer;
    scr_prt:char;

PROCEDURE pulisci_scacchiera;
VAR
    i,j : 1..lato;
BEGIN
  numero:=1;
  FOR i:=1 TO lato DO
    FOR j:=1 TO lato DO
      scacchiera[i,j]:=0;
END;

PROCEDURE stampa_scacchiera(pos:integer);
VAR 
    i,j : 1..lato;
    off_set_x,
    off_set_y : integer;
BEGIN
  FOR i:=1 TO lato DO
    FOR j:=1 TO lato DO
      BEGIN
        IF (pos=1) OR (pos=4)
          THEN
          off_set_x:=0
        ELSE
          off_set_x:=1;
        IF (pos=1) OR (pos=2) 
          THEN
          off_set_y:=0
        ELSE
          off_set_y:=1;
        gotoxy(i*4+off_set_x*lato*4,j+off_set_y*lato);
        write(scacchiera[i,j]+(pos-1)*n_caselle : 3);
      END;
END;

PROCEDURE salva_mtr(pos:integer);
VAR 
    i,j : 1..lato;
    off_set_x,
    off_set_y : integer;
BEGIN
  FOR i:=1 TO lato DO
    FOR j:=1 TO lato DO 
      BEGIN
        IF (pos=1) OR (pos=4) 
          THEN
          off_set_x:=0
        ELSE
          off_set_x:=lato;
        IF (pos=1) OR (pos=2) 
          THEN
          off_set_y:=0
        ELSE
          off_set_y:=lato;
        print_mtr[j+off_set_y,i+off_set_x]:=scacchiera[i,j]+(pos-1)*n_caselle;
      END;
END;

PROCEDURE stampa_mtr;
VAR
    i,j,k : 1..lato;
BEGIN
  writeln(out);
  writeln(out);
  FOR i:=1 TO 2*lato DO 
    BEGIN
      FOR k:=1 TO print_margine DO
        write(out,' ');
      FOR j:=1 TO 2*lato DO
        write(out,print_mtr[i,j]:4);
      writeln(out);
    END;
  writeln(out);
END;

PROCEDURE cerca_mosse_possibili(mossa:t_mossa; VAR mosse_cercate:t_mosse);
VAR
    x_candidato,y_candidato : fuori_lato_s..fuori_lato_d;

PROCEDURE verifica_scacchiera_libera;
BEGIN
  IF (scacchiera[x_candidato,y_candidato]=0)  THEN
    WITH mosse_cercate DO
      BEGIN
        n_scelte:=n_scelte+1;
        scelta[n_scelte].x:=x_candidato;
        scelta[n_scelte].y:=y_candidato;
      END;
END;

BEGIN
  mosse_cercate.n_scelte:=0;
  WITH mossa DO
    BEGIN
      x_candidato:=x;
      y_candidato:=y+3;
      IF (y_candidato)<=lato THEN
        verifica_scacchiera_libera;
      x_candidato:=x;
      y_candidato:=y-3;
      IF (y_candidato)>=1 THEN
        verifica_scacchiera_libera;
      x_candidato:=x+3;
      y_candidato:=y;
      IF (x_candidato)<=lato THEN
        verifica_scacchiera_libera;
      x_candidato:=x-3;
      y_candidato:=y;
      IF (x_candidato)>=1 THEN
        verifica_scacchiera_libera;
      x_candidato:=x+2;
      y_candidato:=y+2;
      IF ((x_candidato<=lato) AND (y_candidato<=lato)) THEN
        verifica_scacchiera_libera;
      x_candidato:=x-2;
      y_candidato:=y+2;
      IF ((x_candidato>=1) AND (y_candidato<=lato)) THEN
        verifica_scacchiera_libera;
      x_candidato:=x-2;
      y_candidato:=y-2;
      IF ((x_candidato>=1) AND (y_candidato>=1)) THEN
        verifica_scacchiera_libera;
      x_candidato:=x+2;
      y_candidato:=y-2;
      IF ((y_candidato>=1) AND (x_candidato<=lato)) THEN
        verifica_scacchiera_libera;
    END;
END;

PROCEDURE cerca_soluzione(pos:integer;VAR mossa_attuale:t_mossa);
BEGIN
  pulisci_scacchiera;
  scacchiera[mossa_attuale.x,mossa_attuale.y]:=numero;
  numero:=numero+1;
  cerca_mosse_possibili(mossa_attuale,mosse);
  REPEAT { mosse.n_scelte>0 & numero<n_caselle }
    (*     Si esegue una scelta tra le possibili mosse    *)
    mossa_scelta:=random(mosse.n_scelte)+1;
    (*  La mossa scelta e' in -mosse- al numero -mossa_scelta- *)
    IF mosse.n_scelte>0 THEN
      BEGIN
        mossa_attuale:=mosse.scelta[mossa_scelta];
        (* ho scelto la mossa successiva e la eseguo *)
        scacchiera[mosse.scelta[mossa_scelta].x,mosse.scelta[mossa_scelta].y]:=numero;
        numero:=numero+1;
        cerca_mosse_possibili(mossa_attuale,mosse); {  mosse successive }
      END;
  UNTIL (mosse.n_scelte=0) OR (numero=n_caselle+1);
END;


BEGIN
  clrscr;
  gotoxy(45,15);
  write(' Numero tentativi    :');
  gotoxy(45,16);
  write(' Tentativi riusciti  :');
  gotoxy(45,17);
  write(' Media tent.riusciti :');
  gotoxy(45,18);
  write(' Massimo risultato   :');
  gotoxy(45,19);
  write(' Massimo parziale    :');
  gotoxy(45,20);
  write(' Risultato medio     :');
  max_risultato:=0;
  max_parziale:=0;
  numero_tentativi:=0;
  tentativi_riusciti:=0;
  sum_risultati:=0;
  mossa_iniziale.x:=random(lato)+1;
  mossa_iniziale.y:=random(lato)+1;
  REPEAT
    REPEAT
      mossa_attuale:=mossa_iniziale;
      ok:=false;
      cerca_soluzione(round(tentativi_riusciti)+1,mossa_attuale);
      IF numero=n_caselle+1 THEN
        BEGIN
          CASE (round(tentativi_riusciti)+1) OF
            1 : IF mossa_attuale.x>=lato-2 THEN
                  ok:=true;
            2 : IF mossa_attuale.y>=lato-2 THEN
                  ok:=true;
            3 : IF mossa_attuale.x<=3 THEN
                  ok:=true;
            4 : ok:=true;
          END;
          IF ok THEN
            tentativi_riusciti:=tentativi_riusciti+1;
        END;
      numero_tentativi:=numero_tentativi+1;
      sum_risultati:=sum_risultati+numero-1;
      IF numero>max_risultato THEN
        max_risultato:=numero-1;
      IF numero-1>max_parziale THEN
        max_parziale:=numero-1;
      tmp:=numero_tentativi/50;
      IF (int(tmp)=tmp) OR ok THEN
        BEGIN
          gotoxy(69,15);
          write(numero_tentativi:0:0);
          gotoxy(69,20);
          write(sum_risultati/numero_tentativi:0:9);
          gotoxy(69,19);
          write(max_parziale);
          gotoxy(69,17);
          write(tentativi_riusciti/numero_tentativi:0:9);
          IF max_parziale=max_risultato THEN
            BEGIN
              gotoxy(69,16);
              write(tentativi_riusciti:0:0);
              gotoxy(69,18);
              write(max_risultato);
            END;
          max_parziale:=0;
        END;
    UNTIL ok;
    mossa_iniziale:=mossa_attuale;
    CASE round(tentativi_riusciti) OF
      1 : mossa_iniziale.x:=(mossa_attuale.x+3) MOD lato;
      2 : mossa_iniziale.y:=(mossa_attuale.y+3) MOD lato;
      3 : mossa_iniziale.x:=(mossa_attuale.x-3+lato);
    END;
    gotoxy(1,6);
    stampa_scacchiera(round(tentativi_riusciti));
    salva_mtr(round(tentativi_riusciti));
  UNTIL tentativi_riusciti=4;
  gotoxy(79,23);
  writeln;
  write(' Stampante o Schermo (p/S) ? ');
  repeat until keypressed;
  read(kbd,scr_prt);
  if upcase(scr_prt)='P'
    then assign(out,'lst:')
    else assign(out,'trm:');
  writeln;
  write(' Il margine di stampa :');
  readln(print_margine);
  stampa_mtr;
END.
