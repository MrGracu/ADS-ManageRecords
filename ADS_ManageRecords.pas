{ MADE BY GRACJAN MIKA ( https://www.gmika.pl ) }

program ADS_ManageRecords;

uses Crt,SysUtils;

type
  tosoba = record
    id: longint;
    Imie: string[20];
    Nazwisko: string[40];
    Pesel: string[11];
    Plec: string[1]; //K, M
  end;
  osoba = Array of tosoba;

  procedure wypelnijOsobami();
  var
    osoby:osoba;
    f:textfile;
    i,j,wylosowana:integer;
    rok, dzien, miesiac, reszta:string;
    imiona,nazwiska:Array of String;
    baza:File of tosoba;
    danaOs:tosoba;
  begin
    if(not(fileExists('imiona.txt') and fileExists('nazwiska.txt'))) then
    begin
      writeln('!!! BRAK WYMAGANYCH PLIKOW !!!');
      readln();
      exit;
    end;

    if(fileExists('bazaOsob.bin')) then exit;

    writeln('Wypelniam plik osobami...');
    assignfile(f, 'imiona.txt');
    reset(f);
    i:=0;
    while (not eof(f)) do
    begin
      setLength(imiona, (i+1));
      readln(f, imiona[i]);
      i:=i+1;
    end;
    closefile(f);

    assignfile(f, 'nazwiska.txt');
    reset(f);
    i:=0;
    while (not eof(f)) do
    begin
      setLength(nazwiska, (i+1));
      readln(f, nazwiska[i]);
      i:=i+1;
    end;
    closefile(f);

    for i:=0 to 24999 do
    begin
      setLength(osoby, (i+1));
      osoby[i].id:=i;
      osoby[i].Imie:=imiona[random(Length(imiona))];
      osoby[i].Nazwisko:=nazwiska[random(Length(nazwiska))];

      wylosowana:=random(100);
      rok:='';
      if(wylosowana < 10) then rok:='0'+IntToStr(wylosowana) else rok:=IntToStr(wylosowana);
      wylosowana:=random(12)+1;
      miesiac:='';
      if(wylosowana < 10) then miesiac:='0'+IntToStr(wylosowana) else miesiac:=IntToStr(wylosowana);
      wylosowana:=random(28)+1;
      dzien:='';
      if(wylosowana < 10) then dzien:='0'+IntToStr(wylosowana) else dzien:=IntToStr(wylosowana);
      wylosowana:=random(100000);
      reszta:='';
      if(wylosowana < 10) then reszta:='0000'+IntToStr(wylosowana) else if(wylosowana < 100) then reszta:='000'+IntToStr(wylosowana) else if(wylosowana < 1000) then reszta:='00'+IntToStr(wylosowana) else if(wylosowana < 100000) then reszta:='0'+IntToStr(wylosowana) else reszta:=IntToStr(wylosowana);
      osoby[i].Pesel:=rok+miesiac+dzien+reszta;
      j:=0;
      repeat
        if(osoby[j].Pesel = osoby[i].Pesel) then
        begin
          wylosowana:=random(100000);
          reszta:='';
          if(wylosowana < 10) then reszta:='0000'+IntToStr(wylosowana) else if(wylosowana < 100) then reszta:='000'+IntToStr(wylosowana) else if(wylosowana < 1000) then reszta:='00'+IntToStr(wylosowana) else if(wylosowana < 100000) then reszta:='0'+IntToStr(wylosowana) else reszta:=IntToStr(wylosowana);
          osoby[i].Pesel:=rok+miesiac+dzien+reszta;
          j:=0;
        end else j:=j+1;
      until (j = i);

      if(osoby[i].Imie[Length(osoby[i].Imie)] = 'a') then
      begin
        if(osoby[i].Nazwisko[Length(osoby[i].Nazwisko)] = 'i') then osoby[i].Nazwisko[Length(osoby[i].Nazwisko)]:='a';
        osoby[i].Plec:='K';
      end else osoby[i].Plec:='M';
    end;

    assignFile(baza,'bazaOsob.bin');
    rewrite(baza);
    for i:=0 to (length(osoby)-1) do
    begin
      danaOs:=osoby[i];
      write(baza,danaOs);
    end;
    closeFile(baza);
  end;

  procedure zapiszOsobyDoTxt();
  var
    osoby:osoba;
    danaOs:tosoba;
    i:Integer;
    f:textfile;
    baza:File of tosoba;
  begin
    ClrScr;
    assignFile(baza,'bazaOsob.bin');
    if(not fileExists('bazaOsob.bin')) then
    begin
      closeFile(baza);
      writeln('!!! BAZA OSOB NIE ISNIEJE !!!');
      readln();
      exit;
    end;
    writeln('Zapisuje baze osob do pliku: bazaOsob.txt');
    reset(baza);
    while not eof(baza) do
    begin
      read(baza,danaOs);
      SetLength(osoby,(length(osoby)+1));
      osoby[(length(osoby)-1)]:=danaOs;
    end;
    closeFile(baza);

    assignFile(f,'bazaOsob.txt');
    rewrite(f);
    for i:=0 to (Length(osoby)-1) do
    begin
      writeln(f,(IntToStr(osoby[i].id)+';'+osoby[i].Pesel+';'+osoby[i].Plec+';'+osoby[i].Imie+';'+osoby[i].Nazwisko));
    end;
    closeFile(f);
  end;

procedure wczytajCzescOsob(var czescOsob:osoba);
var
  d,e:integer;
  baza:File of tosoba;
  danaOs:tosoba;
begin
  ClrScr;
  writeln('+----------------------------------------------------+');
  writeln('|                      WCZYTAJ                       |');
  writeln('+----------------------------------------------------+');
  repeat
    writeln('+ Podaj poczatkowy numer z bazy (max 25000). Wpisz: 0, aby anulowac.');
    readln(d);
    if(d = 0) then break;
    writeln('+ Podaj koncowy numer z bazy (max 25000). Wpisz: 0, aby anulowac.');
    readln(e);
    if((d > 25000) or (e > 25000)) then writeln('+ Podano za duza wartosc.');
  until ((e = 0) or (d = 0) or ((d > 0) and (e > 0) and (e >= d) and (e <= 25000) and (d <= 25000)));
  if((e = 0) or (d = 0)) then exit;

  assignFile(baza,'bazaOsob.bin');
  if(not fileExists('bazaOsob.bin')) then
  begin
    closeFile(baza);
    writeln('!!! BAZA OSOB NIE ISNIEJE !!!');
    readln();
    exit;
  end;
  d:=d-1;
  e:=e-1;
  reset(baza);
  if(d > 0) then seek(baza,d);
  while (d <= e) do
  begin
    read(baza,danaOs);
    SetLength(czescOsob,(length(czescOsob)+1));
    czescOsob[(length(czescOsob)-1)]:=danaOs;
    d:=d+1;
  end;
  closeFile(baza);
end;

procedure wyszukajPoWzorcu(var czescOsob:osoba;nrWzoru:byte);
var
  pes:String;
  i:Integer;
begin
  ClrScr;
  writeln('+----------------------------------------------------+');
  writeln('|                      WYSZUKAJ                      |');
  writeln('+----------------------------------------------------+');
  write('+ Podaj tresc wzorca ');
  if(nrWzoru = 1) then
  begin
    writeln('nr PESEL:');
    repeat
      readln(pes);
    until (length(pes) = 11);
    ClrScr;
    for i:=0 to (Length(czescOsob)-1) do
    begin
      if(czescOsob[i].Pesel = pes) then
      begin
        writeln('+----------------------------------------------------+');
        writeln('+ Imie: ',czescOsob[i].Imie);
        writeln('+ Nazwisko: ',czescOsob[i].Nazwisko);
        writeln('+ PESEL: ',czescOsob[i].Pesel);
        writeln('+ Plec: ',czescOsob[i].Plec);
        writeln('+----------------------------------------------------+');
        writeln();
        writeln('Aby kontynuowac wyszukiwanie, wcisnij ENTER...');
        readln();
      end;
    end;
  end;
  if(nrWzoru = 2) then
  begin
    writeln('imienia:');
    readln(pes);
    ClrScr;
    for i:=0 to (Length(czescOsob)-1) do
    begin
      if(czescOsob[i].Imie = pes) then
      begin
        writeln('+----------------------------------------------------+');
        writeln('+ Imie: ',czescOsob[i].Imie);
        writeln('+ Nazwisko: ',czescOsob[i].Nazwisko);
        writeln('+ PESEL: ',czescOsob[i].Pesel);
        writeln('+ Plec: ',czescOsob[i].Plec);
        writeln('+----------------------------------------------------+');
        writeln();
        writeln('Aby kontynuowac wyszukiwanie, wcisnij ENTER...');
        readln();
      end;
    end;
  end;
  if(nrWzoru = 3) then
  begin
    writeln('nazwiska:');
    readln(pes);
    ClrScr;
    for i:=0 to (Length(czescOsob)-1) do
    begin
      if(czescOsob[i].Nazwisko = pes) then
      begin
        writeln('+----------------------------------------------------+');
        writeln('+ Imie: ',czescOsob[i].Imie);
        writeln('+ Nazwisko: ',czescOsob[i].Nazwisko);
        writeln('+ PESEL: ',czescOsob[i].Pesel);
        writeln('+ Plec: ',czescOsob[i].Plec);
        writeln('+----------------------------------------------------+');
        writeln();
        writeln('Aby kontynuowac wyszukiwanie, wcisnij ENTER...');
        readln();
      end;
    end;
  end;
  if(nrWzoru = 4) then
  begin
    writeln('plci (K lub M):');
    repeat
      readln(pes);
    until (length(pes) = 1);
    ClrScr;
    for i:=0 to (Length(czescOsob)-1) do
    begin
      if(czescOsob[i].Plec = uppercase(pes)) then
      begin
        writeln('+----------------------------------------------------+');
        writeln('+ Imie: ',czescOsob[i].Imie);
        writeln('+ Nazwisko: ',czescOsob[i].Nazwisko);
        writeln('+ PESEL: ',czescOsob[i].Pesel);
        writeln('+ Plec: ',czescOsob[i].Plec);
        writeln('+----------------------------------------------------+');
        writeln();
        writeln('Aby kontynuowac wyszukiwanie, wcisnij ENTER...');
        readln();
      end;
    end;
  end;
  writeln();
  writeln('Zakonczono wyszukiwanie.');
  writeln('Aby wrocic, wcisnij ENTER...');
  readln();
end;

procedure menuWzorcow(czescOsob:osoba);
var
  d:byte;
begin
  repeat
    ClrScr;
    writeln('+----------------------------------------------------+');
    writeln('|                      WYSZUKAJ                      |');
    writeln('+----------------------------------------------------+');
    writeln('| [1] Wyszukaj po nr PESEL                           |');
    writeln('| [2] Wyszukaj po imieniu                            |');
    writeln('| [3] Wyszukaj po nazwisku                           |');
    writeln('| [4] Wyswietl po plci                               |');
    writeln('|                                                    |');
    writeln('| [0] Powrot do MENU                                 |');
    writeln('+----------------------------------------------------+');
    writeln();
    readln(d);
    case d of
      1:wyszukajPoWzorcu(czescOsob,1);
      2:wyszukajPoWzorcu(czescOsob,2);
      3:wyszukajPoWzorcu(czescOsob,3);
      4:wyszukajPoWzorcu(czescOsob,4);
    end;
  until (d = 0);
end;

procedure wyswietlWczytane(czescOsob:osoba);
var
  i:Integer;
begin
  ClrScr;
  for i:=0 to (length(czescOsob)-1) do
  begin
    writeln('+----------------------------------------------------+');
    writeln('+ Osoba: ',i+1,'/',length(czescOsob));
    writeln('+----------------------------------------------------+');
    writeln('+ Imie: ',czescOsob[i].Imie);
    writeln('+ Nazwisko: ',czescOsob[i].Nazwisko);
    writeln('+ PESEL: ',czescOsob[i].Pesel);
    writeln('+ Plec: ',czescOsob[i].Plec);
    writeln('+----------------------------------------------------+');
    writeln();
    writeln('Aby pokazac nastepna osobe, wcisnij ENTER...');
    readln();
  end;
  if(length(czescOsob) = 0) then writeln('Brak elementow do wyswietlenia.');
  writeln();
  writeln('Zakonczono wyswietlanie.');
  writeln('Aby wrocic, wcisnij ENTER...');
  readln();
end;

procedure usunElement(var czescOsob:osoba);
var
  i,j:Integer;
  d:string;
  e:char;
  czyUsunieto:boolean;
begin
  ClrScr;
  writeln('+----------------------------------------------------+');
  writeln('|                        USUN                        |');
  writeln('+----------------------------------------------------+');
  writeln('+ Podaj numer PESEL osoby, ktora chcesz usunac:');
  repeat
    readln(d);
  until (length(d) = 11);
  i:=0;
  czyUsunieto:=false;
  while (i < length(czescOsob)) do
  begin
    if(czescOsob[i].Pesel = d) then
    begin
      ClrScr;
      writeln('+----------------------------------------------------+');
      writeln('+ Imie: ',czescOsob[i].Imie);
      writeln('+ Nazwisko: ',czescOsob[i].Nazwisko);
      writeln('+ PESEL: ',czescOsob[i].Pesel);
      writeln('+ Plec: ',czescOsob[i].Plec);
      writeln('+----------------------------------------------------+');
      writeln();
      writeln('Aby usunac, wpisz: T lub t, w przeciwnym razie usuwanie zostanie anulowane');
      readln(e);
      czyUsunieto:=true;
      if(upcase(e) = 'T') then
      begin
        if(not(i = (length(czescOsob)-1))) then
        begin
          for j:=i to (length(czescOsob)-2) do
          begin
            czescOsob[j]:=czescOsob[j+1];
          end;
        end;
        setLength(czescOsob, length(czescOsob)-1);
        ClrScr;
        writeln('Usunieto.');
      end else i:=i+1;
    end else i:=i+1;
  end;
  if(not czyUsunieto) then
  begin
    writeln('Nie znaleziono szukanej osoby.');
  end;
  writeln('Aby powrocic do MENU, wcisnij ENTER...');
  readln();
end;

var
  d:byte;
  czescOsob:osoba;

begin
  Randomize;
  wypelnijOsobami();
  repeat
    ClrScr;
    writeln('+----------------------------------------------------+');
    writeln('|                        MENU                        |');
    writeln('+----------------------------------------------------+');
    writeln('| [1] Zapisz baze do pliku TXT                       |');
    writeln('| [2] Wczytaj czesc osob                             |');
    writeln('| [3] Wyszukaj uzytkownika wedlug wzorca             |');
    writeln('| [4] Wyswietl wczytane osoby                        |');
    writeln('| [5] Usun osobe z bazy                              |');
    writeln('|                                                    |');
    writeln('| [0] Wyjscie                                        |');
    writeln('+----------------------------------------------------+');
    writeln();
    readln(d);
    case d of
      1:zapiszOsobyDoTxt();
      2:wczytajCzescOsob(czescOsob);
      3:menuWzorcow(czescOsob);
      4:wyswietlWczytane(czescOsob);
      5:usunElement(czescOsob);
    end;
  until (d = 0);
end.

