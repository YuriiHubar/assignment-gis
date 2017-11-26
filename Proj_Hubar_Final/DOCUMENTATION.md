# �vod
T�to aplik�cia vyh�ad�va pod�a umiestnenej zna�ky, citlivosti, typu analyzovan�ch bodov a v�h miesta, ktor� maj� najlep�ie hodnotenie. Hodnotenie sa po��ta na z�klade vzdialenost� najbli���ch objektov zadan�ho typu a v�h pre tieto typy. N�jdene miesta bud� ozna�en� zna�kami.

# D�ta
V �lohe sme pou�ili d�ta dostupn� na Open Street Maps (adresa https://www.openstreetmap.org/).
V pr�ci vyu��vame dump s d�tumu 29.10.2017, ohrani�en� Bratislavou.

S�radnice ohrani�enia mapy:
		SRID 4326			SRID 900913
min_x		16.9775515188954	1889932.39
max_x	17.2376983251162	1918891.80
min_y		48.0992451999721	6123381.61
max_y	48.2250000000000	6144368.78

Tento dump sme nahrali do datab�zy pomocou programu osm2pgsql.
Kv�li v�po�tovej n�ro�nosti vypo��tavania hodnotenia na z�klade 5 typov objektov, vzdialenos� do najbli��ieho objektu ka�d�ho typu sa nevypo��tav� operat�vne, ale vypo��tava sa jeden raz pri pr�prave DB. Na to sa pou��vaj� dopl�uj�ce st�pce do ktor�ch sa v�sledky aj zapisuj�.
Okrem faktick�ch bodov s mapy tam sa prid�vaj� aj generovan� cez ka�d�ch 50, 100 a 200 metrov body.
Pod�a intervalu generovania body maj� identifik�tor level: real = 0, 50m = 1, 100m = 2, 200m = 3. 
Skripty na pr�pravu datab�zy s� v s�bori prepare.sql.


# Funkcie aplik�cie
- vyh�ad�vanie miest s najlep��m hodnoten�m
- vyh�ad�vanie na z�klade zadanej maxim�lnej vzdialenosti v rozsahu 	0...10 km
- vyh�ad�vanie na z�klade koeficientu citlivosti 					1...3000
- vyh�ad�vanie na z�klade v�h pre ka�d� typ objektu 				-10...10
- ur�enie mno�stva n�jden�ch bodov v rozsahu 				0 - 350
- zmena ukazovate�a aktu�lnej poz�cie
- pre ka�d� n�jden� objekt vyskakuje popup okno s inform�ciou o s�radniciach a hodnoten�
- pre ukazovate� sa zobrazuje popup okno s aktu�lnymi s�radnicami

# Fungovanie aplik�cie
Aplik�cia sa sklad� s Backendu, ktor� je naprogramovan� v C# a webov�ho Frontendu naprogramovan�ho v HTML a Javascript.
Backend poskytuje Web Service funkciu FindPoints(), ktorej n�vratov� hodnota je geojson s dopytovan�m v�sledkom.
Frontend sl��i na zad�vanie dopytu a zobrazovanie v�sledku. Na kreslenie pozadia mapy sa pou��va MapBox.

**Uk�ka dopytu na n�jdenie 350 bodov s najvy���m hodnoten�m v okol� 2000m pod�a faktick�ch bodov a v�h 5,5,5,5,-5**

'POST WebForm1.aspx/FindPoints?latC=17.07171320915222&longC=48.153840297249474&distance=2000&count=350&level=0&sens=0&w1=5&w2=5&w3=5&w4=5&lw5=-5' 

# Uk�ka aplik�cie
![Screenshot](screen-1.png)
![Screenshot](screen-2.png)
![Screenshot](screen-3.png)
![Screenshot](screen-4.png)
![Screenshot](screen-5.png)