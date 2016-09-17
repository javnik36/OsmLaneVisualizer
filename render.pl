#!/usr/bin/perl

use Data::Dumper;
use warnings;
use strict;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use utf8;
binmode(STDIN, ":encoding(UTF-8)");
binmode(STDOUT, ":encoding(UTF-8)");
use JSON;
use LWP::Simple;
use URI::Escape qw(uri_unescape uri_escape);
use Encode qw(from_to);

use lib '.';
use lib '/www/htdocs/w00fe1e3/lanes/';
use OSMData;
use OSMLanes;
use OSMDraw;

print "Content-Type: text/html; charset=utf-8\r\n\r\n";

my $url = '<osm-script output="json" timeout="25"><union><query type="way"><id-query ref="224904418" type="way"/></query></union><print mode="body" order="quadtile"/><recurse type="down"/><print  order="quadtile"/></osm-script>'

my $start = 1;
my $totalstartpoints = 0;
# my $extendway = 0;
my $extrasizeactive = "";
my $currid;
my $opts;

if(defined $ENV{'QUERY_STRING'}) {
  my @args = split("&",$ENV{'QUERY_STRING'});
  foreach my $a (@args) {
    my @v = split('=',$a,2);
    $v[1] = uri_unescape($v[1]); from_to ($v[1],"utf-8","iso-8859-1"); $v[1] =~ s/\+/\ /g;
    $opts->{$v[0]} = $v[1] || 1;
    if($v[0] eq 'url')      {$url   = $v[1];}
    if($v[0] eq 'start')    {$start = $v[1];}
    if($v[0] eq 'placement'){$USEplacement = "checked";}
    if($v[0] eq 'adjacent') {$adjacent = "checked";}
    if($v[0] eq 'lanewidth') {$lanewidth = "checked";}
    if($v[0] eq 'extendway') {$extendway = "checked";}
    if($v[0] eq 'usenodes') {$usenodes = "checked";}
    if($v[0] eq 'extrasize') {$extrasize = "checked"; $extrasizeactive = "&extrasize"; $LANEWIDTH *= 1.53 if $extrasize;}
    if($v[0] eq 'wayid') {$url = '<osm-script output="json" timeout="25"><union><query type="way"><id-query ref="'.($v[1]).'" type="way"/></query></union><print mode="body" order="quadtile"/><recurse type="down"/><print  order="quadtile"/></osm-script>';}
    if($v[0] eq 'relid') {$url = '<osm-script output="json" timeout="25"><union><query type="relation"><id-query ref="'.($v[1]).'" type="relation"/></query></union><print mode="body" order="quadtile"/><recurse type="down"/><print  order="quadtile"/></osm-script>';}
    if($v[0] eq 'relname') {$url = '<osm-script output="json" timeout="25"><union><query type="relation"><has-kv k="name" v="'.($v[1]).'"/></query></union><print mode="body" order="quadtile"/><recurse type="down"/><print  order="quadtile"/></osm-script>';}
    if($v[0] eq 'relref') {$url = '<osm-script output="json" timeout="25"><union><query type="relation"><has-kv k="ref" v="'.($v[1]).'"/></query></union><print mode="body" order="quadtile"/><recurse type="down"/><print  order="quadtile"/></osm-script>';}
    }
  }



my $r = OSMData::readData($url,0);
unless($r) {
  #if only one way found, try to extent it a bit
  if($extendway && scalar keys %{$waydata} <= 4) {
    my $ref; my $id;
    foreach my $x (keys %{$waydata}) {
      $id  = $x;
      $ref = $waydata->{$x}{tags}{'ref'};
      }
    OSMData::readData('[out:json][timeout:25];(  way('.$id.');  >;  way(bn);  >;  way(bn);)->.a;(  way.a[highway][ref="'.$ref.'"];  >;);out body qt;',0);
    }


  OSMData::organizeWays();



  my $startcnt = $start;
  ## Find the Nth starting point

  foreach my $w (sort keys %{$waydata}) {
    if (!defined $waydata->{$w}->{before}) {
      $totalstartpoints++;
      if($startcnt > 0) {
        $currid = $w;
        $waydata->{$w}->{reversed} = 0;
        --$startcnt;
        }
      }
    }
  foreach my $w (sort keys %{$waydata}) {
    if (!defined $waydata->{$w}->{after}) {
      $totalstartpoints++;
      if($startcnt > 0) {
        $currid = $w;
        $waydata->{$w}->{reversed} = 1;
        --$startcnt;
        }
      }
    }


  if($adjacent) {
    #Get adjacent ways
    my $str = '<osm-script output="json" timeout="25"><union>';
    foreach my $w (keys %{$waydata}) {
#       next unless $waydata->{$w}{checked};
      $str .= '<id-query ref="'.$waydata->{$w}{end}.'" type="node"/>'
      }
    $str .= '</union>  <print />  <recurse type="node-way"/>  <print />  <recurse type="down"/>    <print /> </osm-script>';

    OSMData::readData($str,1);


    }
  }
my $urlescaped = uri_escape($url);
my $querystring = $ENV{'QUERY_STRING'};
my $wayid = $opts->{'wayid'} || 224904418;
my $relid = $opts->{'relid'} || 11037;
my $relname = $opts->{'relname'} || 'Bundesstraße 521';
my $relref  = $opts->{'relref'} || 'A 661';

print <<"HDOC";
<!DOCTYPE html>
<html lang="en">
<head>
 <title>OSM Lane Visualizer</title>
 <link rel="stylesheet" type="text/css" href="../OLV_style.css">
 <meta  charset="UTF-8"/>

<script type="text/javascript">
  function changeURL(x,str) {
    var url = "?";
    if (str)
      url += x+'='+str;
    else
      url += x+'='+encodeURI(document.getElementsByName(x)[0].value);
    url += "&start="+document.getElementsByName('start')[0].value;
    url += document.getElementsByName('placement')[0].checked?"&placement":"";
    url += document.getElementsByName('adjacent')[0].checked?"&adjacent":"";
    url += document.getElementsByName('lanewidth')[0].checked?"&lanewidth":"";
    url += document.getElementsByName('usenodes')[0].checked?"&usenodes":"";
    url += document.getElementsByName('extendway')[0].checked?"&extendway":"";
    window.location.href=url;
    }
</script>
<link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.css" />
<script src="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.js"></script>

</head>
<body class="$extrasizeactive">
<h1>OSM Lane Visualizer <img alt="pl version" style="height:24px; transform:skewX(-30deg)" src="../imgs/pl_flag.svg"></h1>
<div id="header">
<p>Wprowadź poprawne zapytanie do <a>Overpassa</a> zawierające listę następujących po sobie linii, np. jak <a href="http://overpass-turbo.eu/s/6vr">w tym przykładzie</a>. Wpisz swoje zapytanie w oknie poniżej.<br>
Ponieważ w każdym zestawie danych są co najmniej 2 linie końcowe, wybierz jeden koniec i wpisz jego numer w okienku poniżej (przy złym wpisaniu droga będzie po prostu w drugim kierunku).<br>
Pełne otagowanie danej linii oraz położenie na minimapie pokazuje się po najechaniu kursorem na jej numer (po lewej stronie).<br><br>
Kod sforkowany od użytkownika <a href="https://github.com/mueschel/OSMLaneVisualizer">mueschel</a> dostosowany do polskiego oznakowania drogowego. Kod dostępny na licencji <a href="https://creativecommons.org/licenses/by-nc-sa/4.0/">CC-BY-NC-SA 4.0 International</a>.<br>
Więcej informacji na <a href="https://github.com/javnik36/OsmLaneVisualizer">Githubie.</a></p>
<div class="config">
<h3>Ustawienia:</h3>
<label title="Bierz pod uwagę tag placement, by uzyskać bardziej naturalne ułożenie pasow">
  <input type="checkbox" name="placement" $USEplacement>Tag <i>placement</i></label>
<br><label title="Pokaż położenie wszytkich linii połączonych na końcowych węzłach każdego segmentu">
  <input style="margin_left:30px;" type="checkbox" name="adjacent" $adjacent >Pokaż przyległe linie</label>
<br><label title="Przelicz szerokość pasów jezdni z tagu width. Nie działa najlepiej w kombinacji ze znakami kierunkowymi(destination)">
  <input style="margin_left:30px;" type="checkbox" name="lanewidth" $lanewidth >Przeliczaj szerokość</label>
<br><label title="Uwzględnij tagowanie węzłów by uzyskać dodatkowe informacje">
  <input style="margin_left:30px;" type="checkbox" name="usenodes" $usenodes >Informacje z węzłów</label>
<!--<br><label title="Increase the size of all lanes by 50% in each direction">
  <input style="margin_left:30px;" type="checkbox" name="extrasize" $extrasize >Larger lanes</label>-->
<br><label title="Jeśli API zwróci pojedynczą linię, pokaż do 2 więcej linii, przed i po wybranej przez Ciebie, z tym samym tagiem ref">
  <input style="margin_left:30px;" type="checkbox" name="extendway" $extendway >Linie przed i po</label>
<br><label>Start na końcu linii numer <input type="text" name="start" value="$start" style="width:30px;">(Znaleziono $totalstartpoints węzłów końcowych)</label>
</div>

<div class="selectquery">
<h3>Pokaż:</h3>
<p><label>Relację z ref = <input type="text" name="relref" value="$relref"></label><input type="button" value=" Go " onClick="changeURL('relref');">
<br><label>Relację z name = <input type="text" name="relname" value="$relname"></label><input type="button" value=" Go " onClick="changeURL('relname');">
<br><label>Relację z id = <input type="text" name="relid" value="$relid"></label><input type="button" value=" Go " onClick="changeURL('relid');">
<br><label>Linię z id = <input type="text" name="wayid" value="$wayid"></label><input type="button" value=" Go " onClick="changeURL('wayid');">
<br>Uwaga! Nie wczytuj zbyt długich relacji, bo...będziesz czekał lata i możesz się nie doczekać.
</div>

<div class="selectquery" style="width:350px;">
<h3 title="Wpisz zapytanie do Overpassa zwracające listę mniej lub bardziej przyległych odcinków dróg">Zapytanie</h3>
<textarea name="url" cols="45" rows="5">$url</textarea>
<br><input type="button" value=" Go " onClick="changeURL('url');">
<hr>
<a target="_blank" href="http://overpass-turbo.eu/?Q=$urlescaped">Pokaż na Overpass Turbo</a>
<br><a href="http://javnik.tk/OLV/render.pl?$querystring">Link do tej strony</a>
</div>
</div>
<div id="map"></div>
<hr style="margin-bottom:50px;margin-top:10px;clear:both;">
HDOC

unless($r) {
  my @outarr;

  while(1) {
    push(@outarr,OSMDraw::linkWay($currid,"down"));
    while(1) { #first, show way from selected starting point
      last if defined $waydata->{$currid}{used};
      $waydata->{$currid}{used} = 1;

      #Reverse ways where needed
#       $waydata->{$currid}{checked} = 1;

      if($waydata->{$currid}->{reversed}) {
        my $tmp = $waydata->{$currid}{end};
        $waydata->{$currid}{end} = $waydata->{$currid}{begin};
        $waydata->{$currid}{begin} = $tmp;

        $tmp = $waydata->{$currid}{after};
        $waydata->{$currid}{after} = $waydata->{$currid}{before};
        $waydata->{$currid}{before} = $tmp;

        my @tmp = reverse @{$waydata->{$currid}{nodes}};
        $waydata->{$currid}{nodes} = \@tmp;
        }

      push(@outarr,OSMDraw::drawWay($currid));

      last unless defined $waydata->{$currid}{after};
      my $nextid = OSMDraw::getBestNext($currid);
      if($waydata->{$currid}{end} == $waydata->{$nextid}{end}) {
        $waydata->{$nextid}->{reversed} = 1;
        }
      else {
        $waydata->{$nextid}->{reversed} = 0;
        }
      $currid = $nextid; #OSMDraw::getBestNext($currid);
      }
    push(@outarr,OSMDraw::linkWay($currid,"up"));
    print reverse @outarr;

    $currid = 0;
    foreach my $w (sort keys %{$waydata}) { #select all other starting points
      if (!defined $waydata->{$w}->{before} && !$waydata->{$w}{used}) {
        $currid = $w;
        }
      }
    if($currid == 0) {  #lastly, show all ways not used so far
      foreach my $w (sort keys %{$waydata}) {
        if (!$waydata->{$w}{used}) {
          $currid = $w;
          }
        }
      }
    last if $currid == 0;
    print "<hr>";
    @outarr = ();
    }
  }
print <<HDOC;
</body>
<script type="text/javascript">
var map = L.map('map').setView([51.873,19.775], 7);
L.tileLayer('http://tile.openstreetmap.org/{z}/{x}/{y}.png',
	{ attribution: 'Map &copy; <a href="https://www.openstreetmap.org">OpenStreetMap</a>' }).addTo(map);
var marker = L.marker(map.getCenter(), { draggable: false }).addTo(map);
var polyline = L.polyline([[0,0]]).addTo(map);
</script>
</html>
HDOC
1;
