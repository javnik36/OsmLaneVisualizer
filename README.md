#OsmLaneVisualizer <img alt="pl version" style="height:24px; transform:skewX(-30deg)" src="https://upload.wikimedia.org/wikipedia/commons/f/f0/Nuvola_Polish_flag.svg">

Narzędzie słuące do wizualizacji tagów dotyczących dróg, głównie tagu destination wprowadzonych do OpenStreetMap. Dane są pobierane przez skrypt perla z Overpass API, z którego tworzony jest kod html.

Fork kodu użytkownika mueschel dostosowany do polskiego oznakowania drogowego.

##Chcesz odpalić u siebie?<br>
Bardzo uproszczone instrukcje dostępne w pliku [installing_on_server](https://github.com/javnik36/OsmLaneVisualizer/blob/master/installing_on_server).

##Jak to działa?<br>
1) Otwórz http://javnik.tk/OLV/render.pl<br>
2) Wpisz zapytanie do Overpassa, id drogi, bądź tag ref, name, lub id relacji<br>
3) Poczekaj trochę...<br>
4) Ciesz się wizualizacją :tada: i sprawdź czy nie popełniłeś jakiegoś błędu.:thought_balloon:

##Obsługiwane tagowanie(en):
*  **bicycle[:lanes][:forward|:backward|:both_ways]** The values no, designated and official are displayed
*  **bridge[:name]** Bridges are displayed using a shadow behind the lanes, the name is shown
*  **bus[:lanes][:forward|:backward|:both_ways]** The values designated and official are displayed
*  **change[:lanes][:forward|:backward|:both_ways]** Shown as solid or dashed lines between lanes
*  **destination[:lanes][:forward|:backward|:both_ways]** Shown using german-style destination signs.
*  **destination:colour[:lanes][:forward|:backward|:both_ways]** Used as background color for individual destinations on a sign.
*  **destination:country[:lanes][:forward|:backward|:both_ways]** If the number of entries matches the number of destination's, the country codes are listed next to the destination, otherwise they are grouped at the bottom of the sign.
*  **destination:ref[:lanes][:forward|:backward|:both_ways]** Shown using german-style destination signs. The ref's are listed at the bottom of each sign
*  **destination:ref:to[:lanes][:forward|:backward|:both_ways]** Shown using german-style destination signs. The ref's are listed at the bottom of each sign
*  **destination:symbol[:lanes][:forward|:backward|:both_ways]** Some common symbols are displayed. They are listed next to destination names
*  **destination:symbol:to[:lanes][:forward|:backward|:both_ways]** Some common symbols are displayed. They are listed next to destination names
*  **destination:to:ref[:lanes][:forward|:backward|:both_ways]** Shown using german-style destination signs. The ref's are listed at the bottom of each sign
*  **foot[:lanes][:forward|:backward|:both_ways]** The values no, designated and official are displayed
*  **highway=motorway_junction** Junction name and ref are displayed, if they are located at the end of a way
*  **highway=(traffic_signals|give_way|stop|crossing|mini_roundabout)** Some highway tags on nodes are shown using the corresponding traffic sign
*  **hgv[:lanes][:forward|:backward|:both_ways]** The values no, designated and official are displayed
*  **int_ref** Shown in left column and on signs
*  **junction=roundabout** Roundabouts are marked
*  **lanes[:forward|:backward|:both_ways]**  Used to determine the number of lanes. Might be overruled by other tags
*  **maxspeed**  
 * **maxspeed[:lanes][:forward|:backward|:both_ways]**  Supported, shown on left-hand side. Displayed inside lane for lane dependent tags
 * **maxspeed:conditional**   Supported, shown on left-hand side, no lane or direction dependence.
 * **maxspeed:hgv**   Supported, shown on left-hand side, no lane or direction dependence
*  **motorroad** If yes, the corresponding sign is shown
*  **name** Shown in left column
*  **oneway**  Mostly supported, oneway=-1 might fail in some cases
*  **overtaking[:hgv][:forward|:backward]** Shown as solid line between forward and backward lanes
*  **placement[:forward|:backward][:start|:end]** Used for positioning lanes if enabled. Additional: Experimental support for a tag proposed by Imagic to give further detail in case of placement=transistion
*  **psv[:lanes][:forward|:backward|:both_ways]** The values designated and official are displayed
*  **ref** Shown in left column, used to determine color of signs
*  **shoulder[:left|:right]** Shoulders are drawn as gray area left and right of the road
*  **sidewalk[:left|:right|:both]** Shown in light blue on left and right side of the road
*  **sidewalk[:left|:right|:both]:width** Used if enabled
*  **traffic_calming=island** Shown on ways between lanes as dark area
*  **traffic_calming:width** Used if enabled
*  **tunnel:name** Name is shown if available
*  **turn[:lanes][:forward|:backward|:both_ways]** Rendered by using Unicode characters.
*  **width[:lanes][:forward|:backward]** Used if enabled

##Inne<br>
Oryginalne readme dostępne [tutaj](https://github.com/javnik36/OsmLaneVisualizer/blob/master/README_orig.md)

Jeśli widzisz jakieś błędy, lub chcesz współtworzyć kod, śmiało! Zachęcam! :)

Ten fork może się różnić od aktualnej wersji dostępnej pod https://github.com/mueschel/OsmLaneVisualizer

@Stworzono na [licencji CC-BY-NC-SA](https://github.com/javnik36/OsmLaneVisualizer/blob/master/LICENCE) przez [mueschel](https://github.com/mueschel) i javnik36.
