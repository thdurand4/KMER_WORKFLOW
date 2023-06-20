#!/usr/bin/perl

use strict;
use warnings;
use GD::Simple;
use GD::SVG;
use Data::Dumper;
use Getopt::Long;


#=========================================================
# module a charger, command et exemple de fichier d'entrée 
#=========================================================

# module load perllib/5.16.3
# perl /home/garsmeuro/scripts/GraphKmer_v2.pl -in count_intersections_10X_268Accs_divide1000_onlyMultipleAccs_TOP150.tab -list List_all_accessions -outprefix test -police 6

#exemple -in (nombre de kmers partagés et accessions (tabulé)
# 1005    fasta1	Erianthus_fulvus_EF001-JGI      Narenga_porphyrocoma_Narenga-JGI        Narenga_sp_N001-JGI
# 864     fasta1	Miscanthus_Floridus_MiscFlo-PI295762-JGI        Miscanthus_sinense_JW484-JGI
# 814     fasta1	Miscanthus_Floridus_MiscFlo-PI295762-JGI        Miscanthus_sinense_JW484-JGI    Miscanthus_sinense_NG7722-JGI   Saccharum_x_Miscanthus_hybrid_Toaeho-JGI
# 804     fasta1	Miscanthus_sinense_JW484-JGI    Miscanthus_sinense_NG7722-JGI
# 733     fasta1	Erianthus_arundinaceus_EA001-JGI        Erianthus_arundinaceus_IK_76-48-JGI


#exemple -list (accession_name color (tabulé)
# Erianthus_arundinaceus_EA001-JGI        black
# Erianthus_arundinaceus_IK_76-48-JGI     black
# Erianthus_fulvus_EF001-JGI      black
# Miscanthus_Floridus_MiscFlo-PI295762-JGI        black
# Miscanthus_sinense_JW484-JGI    black
# Miscanthus_sinense_NG7722-JGI   black
# Narenga_porphyrocoma_Narenga-JGI        black
# Narenga_sp_N001-JGI     black
# Saccharum_barberi_Chunnee-JGI   purple
# Saccharum_barberi_GANAPATHY-JGI purple

#police : taille de la police de charactere (par default calculée automatiquement en fonction de la taille de l'image

#=======================================================
#options du programme
#=======================================================

my $in;
my $list;
my $outprefix;
my $police=6;

GetOptions(
	'in=s' => \$in,
	'list=s' => \$list,
	'police=s' => \$police,
	'outprefix=s' => \$outprefix
);

open(ERR,">$outprefix.err");


#===========================================
# variables globales
#===========================================

my $taille_de_police = $police;
my $img; 											# objet image
my %COLORS;											# hash avec correspondance couleur au format RGB : black-->0,0,0
my $marge_haute=20*$police; 								# marge axe X 
my $marge_gauche=10*$police; 								# marge axe Y
my $black_txt_color;								# couleur du texte pour les nombres de kmers
my $color_svg; 										# variable contenant le code couleur au format RGB
my %ACCESSION_A_ANALYSER;							# Hash qui liste les accessions à représenter sur le graph : accession-->accession
my $number_of_accessions=0; 						# initialisation nombre d'accession
my $largeur_colonne_pour_accession_name=0; 			
my $longuest_accession_name=0;						# nombres de characteres dans le plus long nom d'accession
my $nb_intersection=0;								# initialisation nbre d'intersection
my $largeur; 										# largeur de l'image (calculée automatiquement en fonction du nombre d'intersections dans le Graph)
my $hauteur; 										# lauteur de l'image (calculée automatiquement en fonction du nombre d'accessions dans le Graph)
my $nb_kmer_in_intersection;						# initialise le nombre de kmer dans une intersection
my $coordonnee_X=0;									# coordonnée X (valeur fixe) pour ecrire la liste (colonne) noms des accessions
my $coordonnee_Y=0;									# coordonnée Y du nom de la premiere accession 
my %COORDONNEE_Y_ACC;								# hash qui renseigne accession->position (axe Y) sur le graph
my $interligne=$taille_de_police+10;					# taille de l'interligne entre les noms d'accessions sur le graph
my $intercolonne=$taille_de_police+10;					# taille de l'intercolonne entre les intersections kmers
my $coordonnee_x_valeur_kmer_specifiques=0; 		# coordonnée X pour ecrire le nombre de kmers specifique a une accession (à coté du nom de l'accession)
my $coordonnee_y_valeur_kmer_specifiques=0; 		# coordonnée Y pour ecrire le nombre de kmers specifique a une accession(à coté du nom de l'accession)
my $first_accession_in_intersection;				# nom de la première accession impliquée dans l'intersection (sert à determiner où commence le trait)
my $last_accession_in_intersection;					# nom de la dernière accession impliquée dans l'intersection (sert à determiner où s'arrete le trait)
my $nb_accession_in_current_intersection;			# compte le nombre d'accessions dans l'intersection analysée
my %plus_petite_coordonnees_Y_dans_intersection;	# hash qui renseigne : numero_intersection->coordonée sur axe Y pour la première accession de l'intersection 
my %plus_grande_coordonnees_Y_dans_intersection;	# hash qui renseigne : numero_intersection->coordonée sur axe Y pour la dernière accession de l'intersection 
my $intersection_count=0;							# initialise le numéro de l'intersection
my $coordonnee_Histo_specific_X=0;					# coordonnée axe X pour dessiner les histogrammes (pour les kmers spécifiques à une accession
my $coordonnee_Histo_specific_Y=0;					# coordonnée axe Y pour dessiner les histogrammes (pour les kmers spécifiques à une accession
my $coordonnee_ligne_x=0;
my $coordonnee_ligne_y=0;
my %RGB_color_code;									# hash permettant de passer du code couleur format text au code couleur format RGB : accession->couleur au format RGB
my $kmer_count=0;									# plus grande valeur de kmers dans une intersection ou specifique a une accession 
my $current_accession; 
my $INTERSECTION_X=0;
my $INTERSECTION_Y;
my %color_code;
my %coordonnee_x_longuest_histogramme;
my %coordonnee_Y_first_accession;
my $fasta_file_intersection;

#====================================================================
# DEFINITION COLORS, éditer cette liste si une couleur est manquante
#=====================================================================


$COLORS{'maroon'}='128,0,0';
$COLORS{'dark_red'}='139,0,0';
$COLORS{'brown'}='165,42,42';
$COLORS{'firebrick'}='178,34,34';
$COLORS{'crimson'}='220,20,60';
$COLORS{'red'}='255,0,0';
$COLORS{'tomato'}='255,99,71';
$COLORS{'coral'}='255,127,80';
$COLORS{'indian_red'}='205,92,92';
$COLORS{'light_coral'}='240,128,128';
$COLORS{'dark_salmon'}='233,150,122';
$COLORS{'salmon'}='250,128,114';
$COLORS{'light_salmon'}='255,160,122';
$COLORS{'orange_red'}='255,69,0';
$COLORS{'dark_orange'}='255,140,0';
$COLORS{'orange'}='255,165,0';
$COLORS{'gold'}='255,215,0';
$COLORS{'dark_golden_rod'}='184,134,11';
$COLORS{'golden_rod'}='218,165,32';
$COLORS{'pale_golden_rod'}='238,232,170';
$COLORS{'dark_khaki'}='189,183,107';
$COLORS{'khaki'}='240,230,140';
$COLORS{'olive'}='128,128,0';
$COLORS{'yellow'}='255,255,0';
$COLORS{'yellow_green'}='154,205,50';
$COLORS{'dark_olive_green'}='85,107,47';
$COLORS{'olive_drab'}='107,142,35';
$COLORS{'lawn_green'}='124,252,0';
$COLORS{'chart_reuse'}='127,255,0';
$COLORS{'green_yellow'}='173,255,47';
$COLORS{'dark_green'}='0,100,0';
$COLORS{'green'}='0,128,0';
$COLORS{'forest_green'}='34,139,34';
$COLORS{'lime'}='0,255,0';
$COLORS{'lime_green'}='50,205,50';
$COLORS{'light_green'}='144,238,144';
$COLORS{'pale_green'}='152,251,152';
$COLORS{'dark_sea_green'}='143,188,143';
$COLORS{'medium_spring_green'}='0,250,154';
$COLORS{'spring_green'}='0,255,127';
$COLORS{'sea_green'}='46,139,87';
$COLORS{'medium_aqua_marine'}='102,205,170';
$COLORS{'medium_sea_green'}='60,179,113';
$COLORS{'light_sea_green'}='32,178,170';
$COLORS{'dark_slate_gray'}='47,79,79';
$COLORS{'teal'}='0,128,128';
$COLORS{'dark_cyan'}='0,139,139';
$COLORS{'aqua'}='0,255,255';
$COLORS{'cyan'}='0,255,255';
$COLORS{'light_cyan'}='224,255,255';
$COLORS{'dark_turquoise'}='0,206,209';
$COLORS{'turquoise'}='64,224,208';
$COLORS{'medium_turquoise'}='72,209,204';
$COLORS{'pale_turquoise'}='175,238,238';
$COLORS{'aqua_marine'}='127,255,212';
$COLORS{'powder_blue'}='176,224,230';
$COLORS{'cadet_blue'}='95,158,160';
$COLORS{'steel_blue'}='70,130,180';
$COLORS{'corn_flower_blue'}='100,149,237';
$COLORS{'deep_sky_blue'}='0,191,255';
$COLORS{'dodger_blue'}='30,144,255';
$COLORS{'light_blue'}='173,216,230';
$COLORS{'sky_blue'}='135,206,235';
$COLORS{'light_sky_blue'}='135,206,250';
$COLORS{'midnight_blue'}='25,25,112';
$COLORS{'navy'}='0,0,128';
$COLORS{'dark_blue'}='0,0,139';
$COLORS{'medium_blue'}='0,0,205';
$COLORS{'blue'}='0,0,255';
$COLORS{'royal_blue'}='65,105,225';
$COLORS{'blue_violet'}='138,43,226';
$COLORS{'indigo'}='75,0,130';
$COLORS{'dark_slate_blue'}='72,61,139';
$COLORS{'slate_blue'}='106,90,205';
$COLORS{'medium_slate_blue'}='123,104,238';
$COLORS{'medium_purple'}='147,112,219';
$COLORS{'dark_magenta'}='139,0,139';
$COLORS{'dark_violet'}='148,0,211';
$COLORS{'dark_orchid'}='153,50,204';
$COLORS{'medium_orchid'}='186,85,211';
$COLORS{'purple'}='128,0,128';
$COLORS{'thistle'}='216,191,216';
$COLORS{'plum'}='221,160,221';
$COLORS{'violet'}='238,130,238';
$COLORS{'magenta'}='255,0,255';
$COLORS{'orchid'}='218,112,214';
$COLORS{'medium_violet_red'}='199,21,133';
$COLORS{'pale_violet_red'}='219,112,147';
$COLORS{'deep_pink'}='255,20,147';
$COLORS{'hot_pink'}='255,105,180';
$COLORS{'light_pink'}='255,182,193';
$COLORS{'pink'}='255,192,203';
$COLORS{'antique_white'}='250,235,215';
$COLORS{'beige'}='245,245,220';
$COLORS{'bisque'}='255,228,196';
$COLORS{'blanched_almond'}='255,235,205';
$COLORS{'wheat'}='245,222,179';
$COLORS{'corn_silk'}='255,248,220';
$COLORS{'lemon_chiffon'}='255,250,205';
$COLORS{'light_golden_rod_yellow'}='250,250,210';
$COLORS{'light_yellow'}='255,255,224';
$COLORS{'saddle_brown'}='139,69,19';
$COLORS{'sienna'}='160,82,45';
$COLORS{'chocolate'}='210,105,30';
$COLORS{'peru'}='205,133,63';
$COLORS{'sandy_brown'}='244,164,96';
$COLORS{'burly_wood'}='222,184,135';
$COLORS{'tan'}='210,180,140';
$COLORS{'rosy_brown'}='188,143,143';
$COLORS{'moccasin'}='255,228,181';
$COLORS{'navajo_white'}='255,222,173';
$COLORS{'peach_puff'}='255,218,185';
$COLORS{'misty_rose'}='255,228,225';
$COLORS{'lavender_blush'}='255,240,245';
$COLORS{'linen'}='250,240,230';
$COLORS{'old_lace'}='253,245,230';
$COLORS{'papaya_whip'}='255,239,213';
$COLORS{'sea_shell'}='255,245,238';
$COLORS{'mint_cream'}='245,255,250';
$COLORS{'slate_gray'}='112,128,144';
$COLORS{'light_slate_gray'}='119,136,153';
$COLORS{'light_steel_blue'}='176,196,222';
$COLORS{'lavender'}='230,230,250';
$COLORS{'floral_white'}='255,250,240';
$COLORS{'alice_blue'}='240,248,255';
$COLORS{'ghost_white'}='248,248,255';
$COLORS{'honeydew'}='240,255,240';
$COLORS{'ivory'}='255,255,240';
$COLORS{'azure'}='240,255,255';
$COLORS{'snow'}='255,250,250';
$COLORS{'black'}='0,0,0';
$COLORS{'dim_gray'}='105,105,105';
$COLORS{'gray'}='128,128,128';
$COLORS{'dark_gray'}='169,169,169';
$COLORS{'silver'}='192,192,192';
$COLORS{'light_gray'}='211,211,211';
$COLORS{'gainsboro'}='220,220,220';
$COLORS{'white_smoke'}='245,245,245';
$COLORS{'white'}='255,255,255';
$COLORS{'blue'}='0,0,255';

#=======================================================================================================================
# entre en hash la liste des accessions à analyser = celle présentes dans le fichier d'entrée 'IN'
# enregistre le nombre total d'accessions à analyser pour calculer la hauteur de l'image
# determine le nom d'accession le plus long pour determiner la largeur de la colonne qui contiendra les noms d'accessions
# determine la valeur d'intersection la plus grande pour determiner la largeur de la colonne pour les kmers spécifiques
# determine si les kmers sont paratgés (intersection) ou specifique à une accession
#========================================================================================================================
print ERR "List of accessions analyzed:","\n";


my %ACCESSION_COLOR_CODE;

open (LIST,"$list");
while (my $line=<LIST>){
	if ($line=~ /^$/){
	}
	else{
		chomp $line;
		my ($acc, $color)=split("\t", $line);
		$ACCESSION_COLOR_CODE{$acc}=$color;
	}
}
close LIST;




open(IN,"$in");
my @table_intersection;

while (my $line =<IN>){

	if ($line =~ /^$/){

	}
	else {
		chomp $line;
		@table_intersection=split("\t",$line);
		

		#nombre d'intersections in line
		my $number_of_tab = () = $line =~ /\t/gi;
		if ($number_of_tab >= 3) {
			$nb_intersection = $nb_intersection + 1;
		}

		my @LIST_ACCESSION_IN_FILE = split("\t", $line);
		if ($kmer_count < length $LIST_ACCESSION_IN_FILE[0]) {
			$kmer_count = length $LIST_ACCESSION_IN_FILE[0];
		}
		splice @LIST_ACCESSION_IN_FILE, 0, 2;

		foreach my $accession_id (@LIST_ACCESSION_IN_FILE) {
			if (exists($ACCESSION_COLOR_CODE{$accession_id})){
			}
			else{
				print "color code for accession: ",$accession_id," is not defined in [list color file]\n";
			}
			
			if (exists($ACCESSION_A_ANALYSER{$accession_id})) {
			}
			else {
				print ERR $accession_id, "\n";
				$ACCESSION_A_ANALYSER{$accession_id} = $accession_id;
				$number_of_accessions = $number_of_accessions + 1;
				if ($longuest_accession_name < length($accession_id)) {
					$longuest_accession_name = length($accession_id);
				}
			}
		}
	}
}
close IN;

#=======================================================================================
# entre en hash l'ordre dans lequel les accessions seront listées dans le graph  
# entre en hash le code couleur RGB correspondant à l'accession
# calcule le nombre d'intersection à représenter pour dimensionner la largeur de l'image
#=======================================================================================





open (LIST,"$list");
while (my $line=<LIST>){
	
	if ($line=~ /^$/){
	}
	else{
	
		chomp $line;
		my ($acc, $color)=split("\t", $line);
		
		
		if (exists($ACCESSION_A_ANALYSER{$acc})){
			#print "analyzing ",$acc,"\n";
			
			
			#coordonnée sur axe Y de l'accession
			if (exists($COORDONNEE_Y_ACC{$acc})){
			}
			else{
				$COORDONNEE_Y_ACC{$acc}=$coordonnee_Y;
				$coordonnee_Y=$coordonnee_Y+$interligne;
				$color_code{$acc}=$color;
			
				#code couleur RGB pour l'accssion
				if (exists($COLORS{$color})){
					$RGB_color_code{$acc}=$COLORS{$color};
				}
			
				else {
					print ERR "$color is not defined. Edit GraphKmer_v02.pl file to add this color (RGB code required)\n";
					print ERR "$acc has been converted to black color in Graph\n";
					$RGB_color_code{$acc}=$COLORS{'black'};
				}
			}
		}
	}
	
}
close LIST;


#==============================================
# creation et dimension de l'image SVG
#===============================================


# hauteur et largeur de l'image
# -----------------------------

$largeur=($marge_gauche+($nb_intersection*$police)+($nb_intersection*$intercolonne)+(($longuest_accession_name*$police)*2))*2;
$hauteur=($marge_haute+($number_of_accessions*$police)+($number_of_accessions*$interligne)+($kmer_count*$police))*2;



# creation image svg:
# -------------------
GD::Simple->class('GD::SVG');
$img = GD::Simple->new($largeur, $hauteur);
#$img = GD::Simple->new(800, 800);
$black_txt_color = $img->colorAllocate(0,0,0); 

print ERR "resolution image: largeur x hauteur = $largeur x $hauteur pxls","\n";
print ERR "number of intersections = $nb_intersection","\n";
print ERR "number of accessions = $number_of_accessions","\n";


# graphique
#----------


# KMERS SPECIFIQUES A UNE ACCESSION/
#------------------------------------

my $number_of_singletons=0;

open(IN,"$in");
while (my $line =<IN>){
	chomp $line;
	
	my @table_intersection=split("\t",$line);
	$fasta_file_intersection=$table_intersection[1];
	$nb_kmer_in_intersection=$table_intersection[0];
	$nb_accession_in_current_intersection=(scalar(@table_intersection))-2;
	$first_accession_in_intersection=$table_intersection[2];
	$last_accession_in_intersection=$table_intersection[$nb_accession_in_current_intersection];	
	
	
	# ecris la liste (colonne) des accessions analysées dans l'ordre donné par le fichier 'LIST' et avec la couleur correspondante
	splice @table_intersection, 0, 2;
	foreach my $accession (@table_intersection){	
		
		#coordonnee accession name:
		$coordonnee_X=$marge_gauche;
		$coordonnee_Y=($marge_haute*2)+$COORDONNEE_Y_ACC{$accession};
		
		
		$color_svg=$RGB_color_code{$accession};
		
		my ($R,$G,$B);
		if($color_svg=~/,/){
			($R,$G,$B)=(split(/\,/,$color_svg));
			$color_svg=$img->colorAllocate($R,$G,$B);
		}
		$img->char(gdLargeFont,$coordonnee_X-50,$coordonnee_Y,$accession,$color_svg); #$img->stringFT($color_svg,'/home/garsmeuro/Fonts/TIMES.TTF',36,-90,$ACC_X,$ACC_Y,$accession);	
	
	
		# ecris le nombre de kmers specifiques à cette accession (à coté du nom de l'accession):
		if ($nb_accession_in_current_intersection <2){
			$number_of_singletons++;
			$current_accession=$first_accession_in_intersection;
			
			#coordonnee valeur kmer specifique
			$coordonnee_x_valeur_kmer_specifiques=$coordonnee_X+(($longuest_accession_name*$police)+$intercolonne+20);
			$coordonnee_y_valeur_kmer_specifiques=$coordonnee_Y;
			
			$img->char(gdLargeFont,$coordonnee_x_valeur_kmer_specifiques,$coordonnee_y_valeur_kmer_specifiques,$nb_kmer_in_intersection,$black_txt_color);
						
			#coordonnee histogram
			$coordonnee_Histo_specific_X=$coordonnee_x_valeur_kmer_specifiques+($intercolonne*4);
			$coordonnee_Histo_specific_Y=$coordonnee_Y;
			$img->fgcolor('black');
			$img->bgcolor('black');
			$img->rectangle($coordonnee_Histo_specific_X, $coordonnee_Histo_specific_Y+$police,$coordonnee_Histo_specific_X+($nb_kmer_in_intersection/(5000*$police)),$coordonnee_Histo_specific_Y+($police*2));
			
			if (exists($coordonnee_x_longuest_histogramme{'histogramme_length'})){
				if ($coordonnee_Histo_specific_X+($nb_kmer_in_intersection/(5000*$police))>$coordonnee_x_longuest_histogramme{'histogramme_length'}){
					$coordonnee_x_longuest_histogramme{'histogramme_length'}=$coordonnee_Histo_specific_X+($nb_kmer_in_intersection/(5000*$police));
				}
			}
			else{
				$coordonnee_x_longuest_histogramme{'histogramme_length'}=$coordonnee_Histo_specific_X+($nb_kmer_in_intersection/(5000*$police));
			}
		}
	}
}

close IN;
#print $coordonnee_x_longuest_histogramme{'histogramme_length'};
	
# kmers partages par plusieurs accession:
#----------------------------------------

if ($number_of_singletons>0){
	$INTERSECTION_X=$coordonnee_x_longuest_histogramme{'histogramme_length'}+$intercolonne;
	$INTERSECTION_Y=$marge_haute;
}
else{
	$INTERSECTION_X=$coordonnee_X+(($longuest_accession_name*$police)+$intercolonne+20);
	$INTERSECTION_Y=$marge_haute;
}
	

my $fasta_name_and_nb_kmer;

open(IN,"$in");
while (my $line =<IN>){
	chomp $line;
	
	my @table_intersection=split("\t",$line);
	$fasta_file_intersection=$table_intersection[1];
	$nb_kmer_in_intersection=$table_intersection[0];
	$fasta_name_and_nb_kmer=$nb_kmer_in_intersection."-----".$fasta_file_intersection;
	$nb_accession_in_current_intersection=(scalar(@table_intersection))-2;
	$first_accession_in_intersection=$table_intersection[2];
	$last_accession_in_intersection=$table_intersection[$nb_accession_in_current_intersection];	

	if ($nb_accession_in_current_intersection >=2){
		splice @table_intersection, 0, 2;
	
		foreach my $accession (@table_intersection){
	
			# ecris le nombre de kmers partagés le long de l'axe X
			$intersection_count++;
			# coordonnee  valeur kmer partagé
			$img->stringUp(gdLargeFont,$INTERSECTION_X-10,$INTERSECTION_Y+$marge_haute-20,$fasta_name_and_nb_kmer,$black_txt_color);
			
			#determine le debut et la fin de la ligne:
			foreach my $accession (@table_intersection){
				
				my $current_Y=($marge_haute*2)+$COORDONNEE_Y_ACC{$accession};
				
				if (exists($plus_petite_coordonnees_Y_dans_intersection{$intersection_count})){
					if ($plus_petite_coordonnees_Y_dans_intersection{$intersection_count}<$current_Y){
					}
					else{
						$plus_petite_coordonnees_Y_dans_intersection{$intersection_count}=$current_Y;
					}
				}
				else{
					$plus_petite_coordonnees_Y_dans_intersection{$intersection_count}=$current_Y;
				}
				
				if (exists($plus_grande_coordonnees_Y_dans_intersection{$intersection_count})){
					
					if ($plus_grande_coordonnees_Y_dans_intersection{$intersection_count}>$current_Y){
					}
					else{
						$plus_grande_coordonnees_Y_dans_intersection{$intersection_count}=$current_Y;
					}
				}
				else{
					$plus_grande_coordonnees_Y_dans_intersection{$intersection_count}=$current_Y;
				}
			}
			
			#dessine la ligne
			$img->fgcolor('gray');
			$coordonnee_ligne_x=$INTERSECTION_X;
			$img->moveTo($coordonnee_ligne_x,$plus_petite_coordonnees_Y_dans_intersection{$intersection_count}+$police);
			$img->lineTo($coordonnee_ligne_x,$plus_grande_coordonnees_Y_dans_intersection{$intersection_count}+$police);
		}
		
		$INTERSECTION_X=$INTERSECTION_X+$intercolonne;
		
		foreach my $accession (@table_intersection){		
			#rond
			if (exists($color_code{$accession})){
				$coordonnee_Y=6+($marge_haute*2)+$COORDONNEE_Y_ACC{$accession};
				$img->moveTo($coordonnee_ligne_x,$coordonnee_Y);
				$img->fgcolor($color_code{$accession});
				$img->bgcolor($color_code{$accession});
				$img->ellipse($police+5,$police+5);
			}
		}	
	}
	
}	



my $fileimg=$outprefix.".svg";
open my $output, '>', $fileimg or die;
print $output $img->svg;
