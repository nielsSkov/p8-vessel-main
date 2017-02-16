TODO listen over alle at-gøre-lister
====================================

Overordnet mål
--------------
Formationskontrol med mindst to aauships
	- To måder: indivuduelle paths eller formation?
	- Det skal funke til sommer!
	- Bestem os for hvad for noget formation vi vil lave, læs papers igennem (formation eller individuelle paths)
 
Opgavelisten
------------
* Generer en path (NEDPRIORITERET) [Brug manuelle arrays med paths for nu]
* Få 'mariner.m' til at reagere på input OK
* Få mariner til at følge en path OK
* Heading autopilot til mariner OK
* Fix rælæafbrydere med nøgle
* Fix rqt GUI
  - Print data op gui
* Lav ny battery monitor print
* Lav software til battery monitor
* Få autopiloten ind i sin egen funktion i stedet for kode i main.m
* Heading autopilot til Twin Propeller Ship aauship.m
* Få flere mariner'ere til at følge en path OK
* Opdater mariner.m til at være AAUSHIP (modellering) [se chap 2 og 3 i fossen] OK
* Implementer path-follower på AAUSHIP (python)
* Tilføj flere AAUSHIPSs til flåden (praktisk ting)
* Få dem til at danne formation (group coordination task)
* Få formationen til at følge en path (formation mission task)


Andre ting der skal kigges på i ny og næ
----------------------------------------
For at få en funkende båd er der en række praktiske gøremål, der
berører:	

* Software
	- GRS
	- HLI
	- LLI
* Hardware
	- Knapafbryder i stedet for klemmerækken (praktisk ting)
	- Byg to både mere
		. Bestil manglende dele OK
		. Sæt delene sammen
* Dokumentation
	- Basal ledningsføringsdokumentation [nickoe]
	- Ledingsnet
	- Batterihåndtering
	- Hold grabberne væk hvis du er en spasser

Senere todo, når båden er sejlklar
----------------------------------
* Undersøg mere RTK GPS, det vi har nu er ikke testet vældigt godt under bevægelse.
* Få styr på LLI sw og HLI sw
* Mere SW
	- Implementer software til battery monitoren

Fuld manuel kontrol giver også angrebspunkt
Restoring forece mangler i B.15 og så videre, altså for at få anden
ordens differentialligning for for metode 2.
Bollard pull test på hver propel

Milepæle
--------

- ROS inlejret program på båden der kører
- Autonom styring af båden:
	- Simuleging
	- Hardware: Gps, andet?
- Gruppekoordineringsopgave
- Formationsfølgeropgave
- Eventuel undvigelsesopgave
- Litteratur research
	- Undersøgelse af formationsparadigmer
- Fuld dynamisk model af båden incl. forstyrrelser
- Udvidelse af flåden
- Implementering
	- Gruppe
	- Formation
	- Eventuel undvigelse

Opdeling af milepæle:
Datoer i () er til, og ikke med. Der er ikke lagt vægt på så meget til næste semester.
# Dette semester
- (Nu - Slut) Litteratur research
- (Uge 11) Undersøg formationsparadigmer
	Dette er mest en "opvarmning" til at skulle lave formationskontrol.
	Der skal undersøges hvad det kræver at lave
	formationskontrol. Indledning
- (Uge 13) Få enten ROS eller noget selvlavet op at køre på båden
	Systemet på den eksisterende båd skal fungere, så den kan sejle simpelt inden vi indkluderer noget formationskontrol til den. Dermed skal næste punkt også laves. Hvis ROS kan implementeres som et overordnet system og opbygningen i noder kan laves vil dette være fordelagtigt, da andre moduler allerede er under udarbejdning. Derfor er det sådan set kun _infrastruktur_ af ROS. Dette skal også dokumenteres.
- (Uge 14) Deltest af båden, manuel kontrol
	Dette er bare for at teste det simpleste system og funktioner.
- (Uge 18) Dynamisk model af båden incl. forstyrrelser
	En ordentlig model af båden vil være godt, da vi dermed kan styre den mere præcist. Vi regner med at bruge metoden fra _Fossen_, og derfor skal vi have bestemt nogle hydrodynamiske koefficienter ud fra enten nogle nye tests eller dem Lunde og Brian lavede sidste semester.
- (Uge 20) Simpel estimator/determinering
	Det at få nogle states som vi kan bruge til at sejle med
- (Uge 22) Simulering af autonom styring af båden med den nye model
	Når modelleringen er færdig skal båden simuleres i matlab. Måske kan vi også undersøge Gazebo.
- (Uge 23) Test af automon styring til båden
	Når alle forgående punkter er opfyldt skal det modelbaserede til båden implementeres. Herunder angår autonom styring og basal stifølger, skal dette testes. Dette skal skal som det sidste i den første halvdel af projektet.
- (Nu - Uge 23) Undersøg gruppekoordineringsopgave
	Vidensopbygning til næste del af projektet.
- (Nu - Uge 23) Undersøg formationsfølgeropgave
	Vidensopbygning til næste del af projektet.

# Næste semester [uger 37 til of med 49 (12 uger)]

JAL og Damkjær skal skrive RTK på indkøbslisten
Skal have skaffet computerer til de nye både

- (37) Succesfull seatrail in Klingenberg
OK  - Fix /lli_input interface in simulation and real process
OK  - Get GPS data properly into the NED frame, use the rotation origin from the map data, from Klingenberg.
  - Test thrust allocation on boat
OK  - Implement thrust allocation in ROS in the control node and simulation node
OK  - Test with boat hardware, HIL testing
- Finish off the esitmation and modelling stuff in the report
- (?) Assembly of two other boats, same as the one we have
- Analyse different formation control strategies in more detail (documentaiton, with conclusion)  [slutningen af september]

husk at leder follower også kan være formation efter manualt styret båd, den med en mand på. Måske snak om hvordan dette f.eks. kan bruges i åløb. 

Find på så mange kriterer så muligt og snak med Søren fra havnen
Hetrogen eller homogen gruppe af robotter? altid være hetrogen på en eller anden facon

september beskriv nogle strategier, og udeluk nogle, fordi de ikke passer. Afgør strategier der ligner noget vi kan bruge og test dem. [skrivebordsanalyse] kommunikations krav er vigtig. Afgør hvor strikt formationen skal være. Sæt nogle kriterier op. Kommunikationsbehov, fleksibilitet hvis een dør, hvor strikt den skal holde formationen, objektundvigelse hvad skal gøres for det, [kriterievægting]  {energiforbrug, divergens, slitage, skalering af agenter (mht tid og sådant), ..., forbedringsforslag}
ved 30 sep skal vi stå klar med nogle kriterer og simulering der understøtter de ønskede implemteringer
oktober til analyse i smilerings miljøer, de og de tilfølde er gode osv, skal implemter en strategi per uge i oktober [dvs 3]
første uge af november til klargøring til mission, sammenligning af de tre tests data for at se om de stemmer overens med vor simulering
november til  test og resultatet dertil, noget addendum til de tests 

- Determination of practical group coordination (initialisation task)
- Implementation of leader-follower formation control (tracking task)
- Formation control is according to a given path of interest (implementation in ROS, at least with simulation model)
- Extend simulation model with environmental disturbances
- Optional future work, could be described. Agent-agent avoidance, and maybe other objects too

Kommentar fra Karl
Done skrevet noget i intro som lidt ekstra motivation, og også nævnt ordene digital map - Noget med at lave digitale kort, som vi ikke har sagt. Hvis man vil lave en model af tilsanding, er dette projekt brugbart for at verifisere tilsandingsmodel. Dette er en næsteskridts motivation. 
Multibeam - single beam; tænk på single beam formations kontrol versus multibeam. (tænk også på dette med formations topologien)
Lige meget hvordan båden rent faktisk organiserer sig, hvis det er en virtula structure. Hvordan skal andre opfatte formationen, hvordan vil de undvige. 
Han synes vi arbejder med en bottomup. Kan være farligt, måske vi skla lave ønsketænking med at starte fra toppen og håbe på at det neden under funker. (SLAM) Kunne bruge top down i stedet lidt, så vi kan få styr på nogle interfaces.
Ryd op på bibliografi, find reference fra nogle af de mere kendte. [kan Karl sende navne og jorunaler]?
Sørg for at få referencer fra mere kendte jornaler og sådant.
Done har skrevet lidt om en assumption at det vil gå hurtigere med både i formation end bare med en båd - Motivationsafsnittet. Grunder er ikke åbenlys, altså til hvorfor det skal være formatainskontrol.
Skalering af formationen. (matemagisk resonering)
Figur Figure 3.1 er ikke så precis, eller forklaret godt.
Evnentuelt diskussion af path og trajectorie controllere.
trapez cell decomposition, suggestion for making simple shapes to make lawnmover pattern
Ide: Brug en statisk optagelse af støjen af GPS til at tilføje støj, i stedet for at brug gaussisk


Kommentar fra JAL
Lavet udkast på papir, måske skal det dokumenteres - Hvad med formationskontrol med multibeam, formation skal ændres afhængig af dybde, afhængig af hvor meget overlap der er.
Done - "Two controls and Trajectory-Tracking control" kalligrafisk S, osv.
Et fragtskib der sejler gennem fjorden, det har sin egen sonar båd med.
Vi kan måske bruge single beam til at lave grov skanning under opmåling med multibeam.
Done nogenlunde den samme nu - Sørg for konsekvent citeringsmetode. evntuelt kombinere   "bla bla bla Jensen said that [42]"
Done - (3.7) ret col til ^\top
Done måske - (4.13) argument for at den linære approximation er valid
kaptiler 4, 5, 6 slutter brat
Done eller nu er det nævnt - Find ud af om der gør noget at båden ikke sejler precist, RTK log er nok fin. [BESKRIV DETTE ET STED]

https://github.com/nickoe/aauship-formation/commit/e6ec6c29eb7ab6736cedb969bc16a15cdd5e8d34#commitcomment-7837394




Navne etc fra Karl:
Det her er selvfølgelig ikke en udtømmende liste...

Navne:

    Vijay Kumar
    Roland Siegwart
    Daniella Rus
    Sebastian Thrun
    Tamio Arai
    Lynne E. Parker
    Howie Choset
    Raffaello D'Andrea
    Emillio Frazzoli
    Brian Gerkey
    Steven LaValle 


Kanaler:
Husk at der er forskel på tidsskrifter (også kaldet jounals, transactions, letters) og konferenceberetninger (proceedings). Tidsskrifter bliver nogle gange set som lidt finere. Det er i hvert fald sværere at få noget udgivet i et tidsskrift.

    IEEE Robotics and Automation Magazine
    Autonomous Robots (Springer)
    Transactions in Advanced Robotics (Springer)
    Robotica (Cambridge)
    Robotics and Autonomous Systems (Elsevier)
    Journal on Field Robotics (Wiley)
    Proceedings from IEEE/RSJ International Conference on Intelligent Robots and Systems (IROS)
    Proceedings from IEEE International Conference on Robotics and Automation (ICRA) 
