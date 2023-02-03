#!/bin/bash

################################# fonctions

### vérification des paramètres (c'est du debug)
Paramètres()
{
    echo "statut actuel :"
    echo "MODE :"
    echo "temperature   $temperature"
    echo "pression      $pression"
    echo "vent          $vent"
    echo "humidite      $humidite"
    echo "altitude      $altitude"
    echo
    echo "LIEU: $lieu"
    echo
    echo "DATE: $datemin | $datemax"
}

### commande d'aide
Help()
{
   echo "Description du programme :)"
   echo
   echo "Syntaxe : $0 [MODE] [LIEU] [DATE] [FICHIER]"
   echo "MODE: obligatoire. pas de max. Le même mode ne peut pas être sélectionné plus d'une fois (pour la température et la pression"
   echo "-t[1-3]     température"
   echo "-p[1-3]     pression"
   echo "-w          vent"
   echo "-m          humidité"
   echo "-h          altitude"
   echo
   echo "LIEU : optionnel. max 1. filtre les données selon un lieu. Si plusieurs sont sélectionnés, seul le dernier sera considéré"
   echo "-F          France métropolitaine + Corse"
   echo "-G          Guyane française"
   echo "-S          Saint-Pierre et Miquelon"
   echo "-A          Antilles"
   echo "-O          Océan Indien"
   echo "-Q          Antarctique"
   echo "le filtrage par lieu fonctionne à une vitesse correcte"
   echo
   echo "DATE : optionnel. la première date doit être plus faible que la 2e. pour les dates à 1 chiffre (comme janvier), il faut écrire 01 et pas 1"
   echo "format : -d <min> <max>"
   echo
   echo "FICHIER : obligatoire. max 1."
   echo "syntaxe : -f [nom du fichier]"
   echo "seul le fichier meteo_filtered_data.csv original peut fonctionner, tout autre fichier entrainera une erreur"
   echo "la vérification est rudimentaire, donc insérer un fichier de la même taille que l'original trompera le programme et entrainera très probablement un plantage"
   echo
   echo "Les commandes -avl, -abr et -tab sont reconnues mais ne sont pas implantées"
}

### initialisation des variables
Initialisation()
{
    inconnu=0
    lieu=0
    aide=0
    temperature=0
    pression=0
    vent=0
    humidite=0
    altitude=0
    datemin=0
    datemax=0
    fichier_existe=0
    modetri=0
}

### lit les arguments
LectureArgument()
{
    #echo "$compteur"
    for (( i=1 ; i<=$# ; i++ )) ; do
        case ${!i} in

            #### MODES ####

            ### temperature ###
            -t*)
            inconnu=-1 
            # si déja passé en argument auparavant
            if [[ $temperature -ne 0 ]] ; then
                echo "veuillez ne pas indiquer plus d'une option de température"
                inconnu=2
                break 3
            fi
            # case pour chaque option
            case ${!i} in
                -t1) 
                temperature=1
                ;;

                -t2) 
                temperature=2
                ;;

                -t3) 
                temperature=3
                ;;

                -*) echo "${!i} : veuillez indiquer un mode correct [1-3] avec la température"
                inconnu=2
                break 3
                ;;
            esac
            ;;

            ### presion ###
            -p*) 
            inconnu=-2
            # si déjà passé en argument auparavant
            if [[ $pression -ne 0 ]] ; then
                echo "veuillez ne pas indiquer plus d'une option de pression"
                inconnu=2
                break 3
            fi
            # case pour chaque option
            case ${!i} in
                -p1) 
                pression=1
                ;;

                -p2) 
                pression=2
                ;;

                -p3) 
                pression=3
                ;;

                -*) echo "${!i} : veuillez indiquer un mode correct [1-3] avec la pression"
                inconnu=2
                break 3
                ;;
            esac
            ;;

            ### vent ###
            -w) 
            inconnu=-3 
            vent=1
            ;;

            ### humidité ###
            -m)
            inconnu=-4
            humidite=1
            ;;

            ### altitude ###
            -h)
            inconnu=-5
            altitude=1 
            ;;

            ##### LIEUX ####

            ### France ###
            -F)
            lieu=1 
            ;;

            ### Guyane ###
            -G)
            lieu=2
            ;;

            ### Saint-Pierre et Miquelon ###
            -S)
            lieu=3
            ;;

            ### Antilles ###
            -A)
            lieu=4
            ;;

            ### Océan Indien ###
            -O)
            lieu=5
            ;;

            ### Antarctique ###
            -Q)
            lieu=6
            ;;

            #### Date ####

            -d)
            # vérifie qu'une date n'a pas déjà été entrée
            if [[ $datemin != '0' ]] && [[ $datemax != '0' ]] ; then
                echo "veuillez ne pas indiquer plusieurs plages temporelles"
            fi
            # assigne les dates à des fichiers temporaires
            i=$(( $i+1 ))
            datemin=${!i}
            i=$(( $i+1 ))
            datemax=${!i}
            dmax1=$(date -d $datemax +%s)
            dmin1=$(date -d $datemin +%s)
            # vérifie que datemin et datemax sont bien des dates
            if [[ $datemin =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "$datemin" >/dev/null ; then
                a=1
            else echo "$datemin n'est pas une date valide"
                inconnu=2
                break 2
            fi

            if [[ $datemax =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "$datemax" >/dev/null ; then
                a=1
            else echo "$datemax n'est pas une date valide"
                inconnu=2
                break 2
            fi
            if [[ $dmin1 -gt $dmax1 ]] ; then
                echo "veuillez indiquer les dates dans le bon sens"
                inconnu=2
                break 2
            fi
            ;;

            #### Autres ####

            ### fichier ###
            -f)
            i=$(( $i+1 ))
            fichier=${!i}
            if [[ -f "$fichier" ]] ; then
                fichier_existe=1
            else 
                echo "pas de fichier"
            fi
            ;;

            ### aide ###
            --help)
            inconnu=-1
            aide=1; 
            break 2
            ;;

            ### avl ###
            -avl)
            modetri=${!i}
            ;;

            ### abr ###
            -abr)
            modetri=${!i}
            ;;

            ### tab ###
            -tab)
            modetri=${!i}
            ;;

            ### autres cas ###
            *) echo "${!i} : commande inconnue. essayez --help pour plus d'informations" 
            inconnu=1
            break 2
            ;;
        esac
    done
}


### vérifie qu'il y a les arguments nécessaire et leur validité
VerifArgument()
{
    #argument inconnu
    if [[ $inconnu -eq 1 ]] ; then
        exit 1
    #arguments manquants
    elif [[ $inconnu -eq 0 ]] ; then
        echo "paramètres d'entrée insufisants. essayez --help pour plus d'informations"
        exit 1
    #mauvaise syntaxe dans les arguments
    elif [[ $inconnu -eq 2 ]] ; then
        echo "syntaxe erronée. essayez --help pour plus d'informations"
        exit 1
    #erreur autre ?    
    elif [[ $inconnu -eq 3 ]] ; then
        echo "erreur inattendue"
        exit 1
    fi

    # --help
    if [[ $aide -eq 1 ]] ; then
        Help
        exit 1
    fi

    # vérifie que le fichier existe
    if [[ $fichier_existe -eq 0 ]] ; then
        echo "il faut indiquer un fichier qui existe. essayez --help pour plus d'informations"
        exit 1
    fi

    # vérification rapide que le fichier est correct
    if [[ $(stat -c%s $fichier) -ne 238860184 ]] ; then
        echo "le fichier spécifié n'est pas valide. essayez --help pour plus d'informations"
        exit 1
    fi
}

### ouah trop rapide
### le fada de la complexité temporelle
FiltrageDate2() 
{

		if [ -f filtre.temp ] ; then
		a=1 #inutile
		else 
			tail -n +2 "$fichier" > filtre.temp
		fi
    nombreligne=$(wc -l < filtre.temp)
    index=$(( $nombreligne / 2 ))
    conditionmax=1
    conditionmin=1
    
    # ceux la sont utile pour la dichotomie en dessous
    imax1=0 #             valeur min de dichotomie
    imax2=$nombreligne #  valeur max
    imin1=0 #             même principe
    imin2=$nombreligne

    # on trie par date au préalable et on fait une recherche dichotomique
    cp filtre.temp filtre2.temp
    sort -t ";" -k2.1,2.4n -k2.6,2.7n -k2.9,2.10n filtre2.temp > filtre.temp
    awk -F ";" '{print $2}' filtre.temp > lignes.temp
    cut -dT -f1 lignes.temp > lignecut.temp
    rm filtre2.temp

		
    # cas spécial date trop grande
    lignetest=$(awk 'NR=='$nombreligne'{ print; exit }' lignecut.temp)
    datetest=$(date -d $lignetest +%s)
    if [[ $datetest -lt $dmax1 ]] ; then
        conditionmax=0
        lignemax=$nombreligne
    fi

    ###  recherche de la date max
    while [[ $conditionmax -eq 1 ]] ; do

        ligne=$(awk 'NR=='$index'{ print; exit }' lignecut.temp) ### on récupère la ligne de moitié
        dtemp=$(date -d $ligne +%s) # on prend la date de la ligne moitié
				
        # pour vérifier qu'on est bien à la limite
        indexmoins=$(( $index - 1 ))
        if [[ $indexmoins -ge 1 ]] ; then
            lignemoins=$(awk 'NR=='$indexmoins'{ print; exit }' lignecut.temp)
            dtempmoins=$(date -d $lignemoins +%s)
        fi

        indexp=$(( $index + 1 ))
        if [[ $indexp -le $nombreligne ]] ; then
            ligneplus=$(awk 'NR=='$indexp'{ print; exit }' lignecut.temp)
            dtempplus=$(date -d $ligneplus +%s)
        fi

        #echo "-----------------"
        #echo "dtemp : $dtemp"
        #echo "dmax1 : $dmax1"
        #echo "index : $index"
        #echo "imax1 : $imax1"
        #echo "imax2 : $imax2"
        #echo "ligne : $ligne"
        #echo "dtempplus : $dtempplus"
        #echo "dtempmoins : $dtempmoins"


        #si on est déjà tout à la fin du fichier
        if [[ $index -ge $nombreligne ]] ; then
            lignemax=$index
            conditionmax=0
            break

        # si on est égal et qu'en dessous est trop grand, on est au bon endroit
        elif [[ $dtemp -eq $dmax1 ]] && [[ $dtempplus -gt $dmax1 ]] ; then
            lignemax=$index
            conditionmax=0
            break

        ### si on est au dessus de la date max, on se déplace vers le haut du fichier
        elif [[ $dtemp -gt $dmax1 ]] ; then 
            #si c'est la plus petite valeur trop grande, on se restreint
            if [[ $index -lt $imax2 ]] ; then
                imax2=$index
            fi

            ### si la valeur prédcédente est acceptable mais pas la suivante, on s'arrête (je me rends compte que la suivante osef parce que on est déjà au dessus strict)
            if [[  $dtempmoins -le $dmax1 ]] && [[ $dtempplus -gt $dmax1 ]] ; then
                conditionmax=0
                lignemax=$indexmoins
                break 2

            ### sinon on continue
            else
                index=$(( $imax1 + $imax2 ))
                index=$(( $index/ 2 ))
                conditionmax=1
            fi

        ### si on est en dessous, on se déplace vers le bas
        elif [[ $dtemp -le $dmax1 ]] ; then 
            # si c'est la plus grande valeur trop petite, on se restreint
            if [[ $index -gt $imax1 ]] ; then
                imax1=$index
            fi
            # on continue
            index=$(( $imax1 + $imax2 ))
            index=$(( $index / 2 ))
            conditionmax=1
        fi 
    done

		#read -p "Press enter to continue"
    #on remet l'index a 0 pour le min
    index=$(( $nombreligne / 2 ))

    # cas spécial date trop petite
    lignetest=$(awk 'NR==1{ print; exit }' lignecut.temp)
    datetest=$(date -d $lignetest +%s)
    if [[ $datetest -gt $dmax1 ]] ; then
        conditionmin=0
        lignemin=1
    fi

    ###  recherche de la date min
    while [[ $conditionmin -eq 1 ]] ; do




        ligne=$(awk 'NR=='$index'{ print; exit }' lignecut.temp) ### on récupère la ligne de moitié
        dtemp=$(date -d $ligne +%s) # on prend la date de la ligne moitié

        # ceux la c'est pour la vérif quand on arrive au bon endroit
        
        indexmoins=$(( $index - 1 ))
        if [[ $indexmoins -ge 1 ]] ; then
            lignemoins=$(awk 'NR=='$indexmoins'{ print; exit }' lignecut.temp)
            dtempmoins=$(date -d $lignemoins +%s)
        fi

        indexp=$(( $index + 1 ))
        if [[ $indexp -le $nombreligne ]] ; then
            ligneplus=$(awk 'NR=='$indexp'{ print; exit }' lignecut.temp)
            dtempplus=$(date -d $ligneplus +%s)
        fi
        
        #echo "-----------------"
        #echo "dtemp : $dtemp"
        #echo "dmin1 : $dmin1"
        #echo "index : $index"
        #echo "imin1 : $imin1"
        #echo "imin2 : $imin2"
        #echo "ligne : $ligne"
        #echo "dtempplus : $dtempplus"
        #echo "dtempmoins : $dtempmoins"
    


        #si on est déjà tout au début du fichier
        if [[ $index -eq 1 ]] || [[ $index -eq 0 ]]; then
            lignemin=$index
            conditionmin=0
            break
        
        # si on est égal et qu'au dessus est trop petit, on est au bon endroit
        elif  [[ $dtemp -eq $dmin1 ]] && [[ $dtempmoins -lt $dmin1 ]] ; then
            lignemin=$index
            conditionmin=0
            break

        ### si on est en dessous de la date min, on se déplace vers le bas du fichier
        elif [[ $dtemp -lt $dmin1 ]] ; then 
            #si c'est la plus grande valeur trop petite, on se restreint
            if [[ $index -gt $imin1 ]] ; then
                imin1=$index
            fi
            
            ### on on continue
                index=$(( $imin1 + $imin2 ))
                index=$(( $index/ 2 ))
                conditionmin=1

        ### si on est au dessus, on se déplace vers le haut
        elif [[ $dtemp -ge $dmin1 ]] ; then 
            # si c'est la plus petite valeur trop grande, on se restreint
            if [[ $index -lt $imin2 ]] ; then
                imin2=$index
            fi

            ### si la valeur suivante est acceptable mais pas la précédente, on s'arrête
            if [[  $dtempplus -le $dmin1 ]] && [[ $dtempmoins -gt $dmin1 ]] ; then
                conditionmin=0
                lignemax=$indexplus
                break 2
            
            # on continue
            else
            index=$(( $imin1 + $imin2 ))
            index=$(( $index / 2 ))
            conditionmin=1
            fi
        fi 
    done

    sed -n ""$lignemin","$lignemax"p;$(( $lignemax + 1 ))q" filtre.temp > filtre2.temp
    cat filtre2.temp > filtre.temp
    rm filtre2.temp
    rm lignecut.temp
    rm lignes.temp
}


# créée un fichier et filtre uniquement les lieux sélectionnés
FiltrageLieu()
{
    # filtrage du fichier par lieu :
    # lieu                                ID $lieu     ID Station
    # -------------------------------------------------------------
    # france métropolitaine + corse       1            tout le reste
    # guyane                              2            81415 81408 81405 81401
    # saint pierre et miquelon            3            71805
    # antilles                            4            78925 78922 78890 78897 78894
    # océan indien                        5            61980 61976 61968 67005 61970 61972 61996 61997 61998
    # antarctique                         6            89642

    # sélection du lieu


    #echo $lieu $fichier
    #echo "grep '71805;' $fichier>filtre.temp"
    case $lieu in
        # vu que j'ai fonctionné par station pour les autres lieux (certains ont pas de département et hum la longitude/latitude)
        # j'ai juste décidé de prendre tout le reste pour la france
        1)
        tail -n +2 "$fichier" > filtre1.temp
        grep -v '81415;\|81408;\|81405;\|81401;\|71805;\|78925;\|78922;\|78890;\|78894;\|78897;\|61980;\|61976;\|61968;\|67005;\|61970;\|61972;\|61996;\|61997;\|61998;\|89642;' filtre1.temp > filtre.temp
        rm filtre1.temp
        ;;

        2)
        grep '81415;\|81408;\|81405;\|81401;' $fichier>filtre.temp
        #head filtre.temp
        ;;

        3)
        grep '71805;' $fichier>filtre.temp
        #head filtre.temp
        ;;

        4)
        grep '78925;\|78922;\|78890;\|78894;\|78897;' $fichier>filtre.temp
        #head filtre.temp
        ;;

        5)
        grep '61980;\|61976;\|61968;\|67005;\|61970;\|61972;\|61996;\|61997;\|61998;' $fichier>filtre.temp
        ;;

        6)
        grep '89642;' $fichier>filtre.temp
        ;;

        *) echo "erreur inattendue lors de la sélection de lieu : $lieu a une valeur incorrecte"
        exit 1
        ;;

    esac
}

# appelle le programme c avec les bons arguments
#syntaxe générale : ./ProgrammeC $filtre.temp [fichier sortie] [quoi trier] [-r]
#bon du coup ça formatte aussi à un format mieux pour gnuplot (j'espère)
AppelC()
{
    case $inconnu in 

        -1) # temperature
        case $temperature in 
            1) #  min, max, moy (11,12,13) trié par n° de station croissant
						
						cut -d ";" -f 1,11 filtre.temp > filtre2.temp #on garde uniquement la date et les températures

            ./progc $filtre2.temp [fichier sortie] 1
            #sort -t ";" -k1n filtre2.temp > filtre.temp #tri par date
            
            rm filtre2.temp

            #maintenant il faut faire le min, max, moy par station
            condition=1
            if [ -f filtre4.temp ] ; then
                rm filtre4.temp
            fi
						#tant qu'il y reste des lignes dans filtre.temp
            while [[ $condition -eq 1 ]] ; do
                #on prend l'id de la premiere ligne
                awk 'NR==1{ print; exit }' filtre.temp > filtre2.temp #filtre 2=1e ligne
                id_test=$(cut -d ";" -f 1 "filtre2.temp")

                #on rend toutes les lignes ayant le même id, et on ne garde que les temperatures
                grep "$id_test" filtre.temp > filtre2.temp #filtre2=toutes les stations d'id $idtest
                cut -d ";" -f2 filtre2.temp > filtre3.temp #filtre3=toutes les temperaturesd'id idtest
                sort -n filtre3.temp > filtre2.temp #filtre2 = toutes les temperatures d'id idtest (trie)
                
								# temperature moyenne, min, max
								nombreligne=$(wc -l < filtre3.temp)
								somme=$(awk '{s+=$1} END {print s}' filtre3.temp)
                moy=$(bc <<<"scale=2;$somme/$nombreligne")
                valmin=$(head -1 filtre2.temp)
                valmax=$(tail -1 filtre2.temp)
                
								#on insère dans filtre4 au format id;moyenne;min;max
                echo "$id_test;$moy;$valmin;$valmax" >> filtre4.temp

								#on supprime les lignes qu'on vient d'écrire de filtre.temp
                sed -i -e '1,'$nombreligne'd' filtre.temp

								#on continue tant qu'il y reste des lignes
                nombreligne=$(wc -l < filtre.temp)
                if [[ $nombreligne -gt 1 ]] ; then
                    condition=1
                else
                    condition=0
                fi
            done

            rm filtre2.temp
            rm filtre3.temp
						cat filtre4.temp > filtre.temp
						rm filtre4.temp

						gnuplot -p gnuplottemp1.sh

            ;;

            2) #  moyenne par date dans l'ordre chronologique (toutes stations)
            
						cut -d ";" -f 2,11 filtre.temp > filtre2.temp #on garde que la date et la temperature

						./progc filtre2.temp [fichier sortie] 2
            #sort -t ";" -k2.1,2.4n -k2.6,2.7n -k2.9,2.10n -k2.12,2.13n -k2.15,2.16n filtre2.temp > filtre.temp #tri par date et par heure
						
            
            cut -d ";" -f 2 filtre.temp > filtre2.temp #filtre2.temp = que les temperatures

            
						condition=1
            if [ -f filtre4.temp ] ; then
                rm filtre4.temp
            fi
						#tant que filtre.temp n'est pas vide
            while [[ $condition -eq 1 ]] ; do
                #on prend la première ligne
                awk 'NR==1{ print; exit }' filtre.temp > filtre2.temp

								#on récupère la date et l'heure de la 1e ligne (en ignorant les fuseaux horaires)
								datetest=$(cut -d ";" -f 1 "filtre2.temp" | cut -d "T" -f 1) # date sans heure
								heuretest=$(cut -d ";" -f 1 "filtre2.temp" | cut -d "T" -f 2 | cut -d "+" -f 1) # heure sans date
								
                #on prend toutes les dates qui correspondent et on ne garde que les temperatures
                grep "$datetest"T"$heuretest"* filtre.temp > filtre2.temp 
                cut -d ";" -f2 filtre2.temp > filtre3.temp 

								#calcul de la moyenne
                nombreligne=$(wc -l < filtre3.temp)
                somme=$(awk '{s+=$1} END {print s}' filtre3.temp)
                moy=$(bc -l <<< "scale=2;$somme/$nombreligne")

								#on insère une nouvelle ligne dans filtre4.temp au format date;heure;moyenne
                echo "$datetest;$heuretest;$moy" >> filtre4.temp
                
								#on enlève toutes les lignes qu'on vient de moyenner de filtre.temp
								sed -i -e '1,'$nombreligne'd' filtre.temp
                
								#tant qu'il reste des données, on continue
								nombreligne=$(wc -l < filtre.temp)
                if [[ $nombreligne -gt 1 ]] ; then
                    condition=1
                else
                    condition=0
                fi
            done

            rm filtre2.temp
            rm filtre3.temp
						cat filtre4.temp > filtre.temp
						rm filtre4.temp
            ;;

            3) #  temp par date et par station, trié par ordre chrono puis par ID de station
            #./progc filtre.temp [fichier sortie1] 1
            #./progc [fichier sortie1] [fichier sortie2] 2
            ;; 

            *) echo '$temperature a une valeur inattendue dans AppelC'
            exit
            ;;
        esac
        ;;

        -2) # pression
				case $pression in
					1) #  pression (7) trié par n° de station croissant
            
						cut -d ";" -f 1,7 filtre.temp > filtre2.temp #on garde uniquement la date et la pression

						./progc $filtre.temp [fichier sortie] 1
            #sort -t ";" -k1n filtre2.temp > filtre.temp #tri par date

            
            rm filtre2.temp

            #maintenant il faut faire le min, max, moy par station
            condition=1
            if [ -f filtre4.temp ] ; then
                rm filtre4.temp
            fi
						#tant qu'il y reste des lignes dans filtre.temp
            while [[ $condition -eq 1 ]] ; do
                #on prend l'id de la premiere ligne
                awk 'NR==1{ print; exit }' filtre.temp > filtre2.temp #filtre 2=1e ligne
                id_test=$(cut -d ";" -f 1 "filtre2.temp")

                #on rend toutes les lignes ayant le même id, et on ne garde que la pression
                grep "$id_test" filtre.temp > filtre2.temp #filtre2=toutes les stations d'id $idtest
                cut -d ";" -f2 filtre2.temp > filtre3.temp #filtre3=toutes les pression d'id idtest
                sort -n filtre3.temp > filtre2.temp #filtre2 = toutes les pressions d'id idtest (triees)
                
								# pression moyenne, min, max
								nombreligne=$(wc -l < filtre3.temp)
								somme=$(awk '{s+=$1} END {print s}' filtre3.temp)
                moy=$(bc <<<"scale=2;$somme/$nombreligne")
                valmin=$(head -1 filtre2.temp)
                valmax=$(tail -1 filtre2.temp)
                
								#on insère dans filtre4 au format id;moyenne;min;max
                echo "$id_test;$moy;$valmin;$valmax" >> filtre4.temp

								#on supprime les lignes qu'on vient d'écrire de filtre.temp
                sed -i -e '1,'$nombreligne'd' filtre.temp

								#on continue tant qu'il y reste des lignes
                nombreligne=$(wc -l < filtre.temp)
                if [[ $nombreligne -gt 1 ]] ; then
                    condition=1
                else
                    condition=0
                fi
            done

            rm filtre2.temp
            rm filtre3.temp
						cat filtre4.temp > filtre.temp
						rm filtre4.temp

						gnuplot -p gnuplotpress1.sh
            ;;

            2) #  moyenne par date dans l'ordre chronologique (toutes stations)
            
						cut -d ";" -f 2,11 filtre.temp > filtre2.temp #on garde que la date et la pression

						./ProgrammeC filtre.temp [fichier sortie] 2
            #sort -t ";" -k2.1,2.4n -k2.6,2.7n -k2.9,2.10n -k2.12,2.13n -k2.15,2.16n filtre2.temp > filtre.temp #tri par date et par heure

            
            cut -d ";" -f 2 filtre.temp > filtre2.temp #filtre2.temp = que les pression

            
            
            #
						condition=1
            if [ -f filtre4.temp ] ; then
                rm filtre4.temp
            fi
						#tant que filtre.temp n'est pas vide
            while [[ $condition -eq 1 ]] ; do
                #on prend la première ligne
                awk 'NR==1{ print; exit }' filtre.temp > filtre2.temp

								#on récupère la date et l'heure de la 1e ligne (en ignorant les fuseaux horaires)
								datetest=$(cut -d ";" -f 1 "filtre2.temp" | cut -d "T" -f 1) # date sans heure
								heuretest=$(cut -d ";" -f 1 "filtre2.temp" | cut -d "T" -f 2 | cut -d "+" -f 1) # heure sans date

                #on prend toutes les dates qui correspondent et on ne garde que les temperatures
                grep "$datetest"T"$heuretest"* filtre.temp > filtre2.temp 
                cut -d ";" -f2 filtre2.temp > filtre3.temp 

								#calcul de la moyenne
                nombreligne=$(wc -l < filtre3.temp)
                somme=$(awk '{s+=$1} END {print s}' filtre3.temp)
                moy=$(bc -l <<< "scale=2;$somme/$nombreligne")

								#on insère une nouvelle ligne dans filtre4.temp au format date;heure;moyenne
                echo "$datetest;$heuretest;$moy" >> filtre4.temp
                
								#on enlève toutes les lignes qu'on vient de moyenner de filtre.temp
								sed -i -e '1,'$nombreligne'd' filtre.temp
                
								#tant qu'il reste des données, on continue
								nombreligne=$(wc -l < filtre.temp)
                if [[ $nombreligne -gt 1 ]] ; then
                    condition=1
                else
                    condition=0
                fi
            done

            rm filtre2.temp
            rm filtre3.temp
						cat filtre4.temp > filtre.temp
						rm filtre4.temp
            ;;

            3) #  pression par date et par station, trié par ordre chrono puis par ID de station
            ####    ./ProgrammeC filtre.temp [fichier sortie1] 1
            ####    ./ProgrammeC [fichier sortie1] [fichier sortie2] 2
            ;; 

            *) echo '$pression a une valeur inattendue dans AppelC'
            exit 1
            ;;

						
        esac
        ;;

        -3) # vent
        # orientation moyenne et vitesse moyenne
        # = somme de chaque composante du vecteur + moyenne
        # moyenne sur X et sur Y : 2 résultats
        # triée par ID de station

        #### ./ProgrammeC $filtre.temp [fichier sortie] 1
        ;;

        -4) # humidité max/station, ordre décroissant
        #### ./ProgrammeC $filtre.temp [fichier sortie1] 6 -r
        #### ./ProgrammeC [fichier sortie1] [fichier sortie2]
        #### ensuite faudra re-filtrer les stations en double, je m'en occuperai
        #### je suis pas tout à fait sur qu'il faille faire comme ça
        ;;

        -5) # altitude/station, ordre décroissant (alt) il faut altitude, longitude, latitude (10 & 14)
        
				cut -d ";" -f 10,14 filtre.temp > filtre2.temp #on garde uniquement les coordonnées et l'altitude

				./ProgrammeC $filtre.temp [fichier sortie] 14 -r
				#sort -t ";"  -k14nr filtre2.temp > filtre.temp #tri par altitude descendant

				
        rm filtre2.temp

				#tant que filtre.temp n'est pas vide
				condition=1
				while [[ $condition -eq 1 ]] ; do
        	#on prend la première ligne
          awk 'NR==1{ print; exit }' filtre.temp > filtre2.temp

					#on récupère les informations de la 1e ligne
					coordonnees=$(cut -d ";" -f 1 "filtre2.temp") 
					longitude=$(cut -d ";" -f 1 "filtre2.temp" | cut -d "," -f 1) # longitude
					latitude=$(cut -d ";" -f 1 "filtre2.temp" | cut -d "," -f 2) # latitude
					altitude=$(cut -d ";" -f 2 "filtre2.temp")
          
					#on prend toutes les coordonnes qui correspondent
          grep "$coordonnees" filtre.temp > filtre2.temp 

					#on insère une nouvelle ligne dans filtre4.temp au format longitude;latitude;altitude
          echo "$longitude;$latitude;$altitude" >> filtre4.temp
                
					#on enlève toutes les lignes qu'on vient d'insérer de filtre.temp
					nombreligne=$(wc -l < filtre2.temp)
					sed -i -e '1,'$nombreligne'd' filtre.temp
                
					#tant qu'il reste des données, on continue
					nombreligne=$(wc -l < filtre.temp)
          if [[ $nombreligne -gt 1 ]] ; then
          	condition=1
          else
          	condition=0
          fi
				done

				rm filtre2.temp
				cat filtre4.temp > filtre.temp
				rm filtre4.temp
        ;;

        *) echo "How did we get there ?"
        echo '$inconnu a une valeur inattendue dans AppelC'
        exit 1
        ;;

    esac
		while [[ -f "sed*" ]] ; do
			$(rm sed*)
		done
}



###############################   programme principal

# initialisation des variables
Initialisation
# lecture des arguments
LectureArgument $@
# vérification des arguments
VerifArgument
#si filtre.temp existe déjà (utile pour le filtrage par date sans filtrage par lieu)
if [[ -f filtre.temp ]] ; then
	rm filtre.temp
fi
# filtrage par lieu
if [[ $lieu -ne 0 ]] ; then
    FiltrageLieu
fi

# filtrage par date

if [[ $datemin -ne 0 ]] ; then 
	FiltrageDate2
fi

if [[ $lieu -eq 0 ]] && [[ $datemin -eq "0" ]] ; then
	tail -n +2 "$fichier" > filtre.temp
	echo "Vu qu'il n'y a ni filtrage par date, ni par lieu, le script ne va pas bien fonctionner"
	read -p "appuyez sur entrée pour continuer"

fi
AppelC

if [ -f filtre1.temp ] ; then
	rm filtre1.temp
fi
if [ -f filtre2.temp ] ; then
	rm filtre2.temp
fi

if [ -f filtre3.temp ] ; then
	rm filtre3.temp
fi

if [ -f filtre4.temp ] ; then
	rm filtre4.temp
fi
if [[ -f sed* ]] ; then
	rm sed*
fi


