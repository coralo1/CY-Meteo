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
   echo "DATE : optionnel. la première date doit être plus faible que la 2e"
   echo "format : -d <min> <max>"
   echo "exemple : -d 2010-02-23 2010-04-23"
   echo "pour sélectionner entre le 23 février et 23 avril 2010"
   echo
   echo "FICHIER : obligatoire. max 1."
   echo "syntaxe : -f [nom du fichier]"
   echo "seul le fichier meteo_filtered_data.csv original peut fonctionner, tout autre fichier entrainera une erreur"
   echo "la vérification est rudimentaire, donc insérer un fichier de la même taille en bytes que l'original trompera le programme et entrainera très probablement un plantage"
   echo
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
                temperature=1 ;;
                -t2) 
                temperature=2 ;;
                -t3) 
                temperature=3 ;;
                -*) echo "${!i} : veuillez indiquer un mode correct [1-3] avec la température"
                inconnu=2
                break 3 ;;
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
                pression=1 ;;
                -p2) 
                pression=2 ;;
                -p3) 
                pression=3 ;;
                -*) echo "${!i} : veuillez indiquer un mode correct [1-3] avec la pression"
                inconnu=2
                break 3 ;;
            esac
            ;;

            ### vent ###
            -w) 
            inconnu=-3 
            vent=1 ;;

            ### humidité ###
            -m)
            inconnu=-4
            humidite=1 ;;

            ### altitude ###
            -h)
            inconnu=-5
            altitude=1 ;;

            ##### LIEUX ####

            ### France ###
            -F)
            lieu=1 ;;

            ### Guyane ###
            -G)
            lieu=2 ;;

            ### Saint-Pierre et Miquelon ###
            -S)
            lieu=3 ;;

            ### Antilles ###
            -A)
            lieu=4 ;;

            ### Océan Indien ###
            -O)
            lieu=5 ;;

            ### Antarctique ###
            -Q)
            lieu=6 ;;

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
            break 2 ;;

            ### autres cas ###
            *) echo "${!i} : commande inconnue. essayez --help pour plus d'informations" 
            inconnu=1
            break 2;;
        esac
    done
}


### vérifie qu'il y a les arguments nécessaire et leur validité
VerifArgument()
{
    #argument inconnu
    if [[ $inconnu -eq 1 ]] ; then
        exit
    #arguments manquants
    elif [[ $inconnu -eq 0 ]] ; then
        echo "paramètres d'entrée insufisants. essayez --help pour plus d'informations"
        exit
    #mauvaise syntaxe dans les arguments
    elif [[ $inconnu -eq 2 ]] ; then
        echo "syntaxe erronée. essayez --help pour plus d'informations"
        exit
    #erreur autre ?    
    elif [[ $inconnu -eq 3 ]] ; then
        echo "erreur inattendue"
        exit
    fi

    # --help
    if [[ $aide -eq 1 ]] ; then
        Help
        exit
    fi

    # vérifie que le fichier existe
    if [[ $fichier_existe -eq 0 ]] ; then
        echo "il faut indiquer un fichier qui existe. essayez --help pour plus d'informations"
        exit
    fi

    # vérification rapide que le fichier est correct
    if [[ $(stat -c%s $fichier) -ne 238860184 ]] ; then
        echo "le fichier spécifié n'est pas valide. essayez --help pour plus d'informations"
        exit
    fi
}

### y'a une version juste en dessous (FiltrageDate2) qui est beaucoup plus rapide
### crée un fichier et filtre uniquement l'intervalle de temps voulu
### très très lent (~1min. 40 pour 30 000 lignes)
### bouh nul cosplay escargot
FiltrageDate()
{
    if [[ -f "filtre2.temp" ]] ; then
        rm filtre2.temp
    fi
    echo "$datemin">datemin.temp
    echo "$datemax">datemax.temp
    #tail -n +2 "$fichier_temp" > filtre1.temp
    #echo "datemax : $datemax"
    dmax1=$(date -d $datemax +%s)
    dmin1=$(date -d $datemin +%s)
    awk -F ";" '{print $2}' filtre.temp > lignes.temp
    cut -dT -f1 lignes.temp > lignecut.temp
    #echo $ligne
    #echo "$amin $mmin $jmin | $amax $mmax $jmax"
    #head -n1 filtre1.temp
    nombreligne=$(wc -l < filtre.temp)
    #echo $nombreligne
    start3=`date +%s.%N`
    for (( i=1 ; i<=$nombreligne ; i++ )) ; do
        
        #ligne=$(sed "${i}q;d" filtre1.temp) LENT
        #echo danlaboucl
        #exit
        #ligne=$(awk -F ";" '{print $2}' filtre1.temp)
        #echo $ligne
        
        #echo
        #start=`date +%s.%N`
        ligne=$(awk 'NR=='$i'{ print; exit }' lignecut.temp)
        #end=`date +%s.%N`
        #echo "$ligne"
        #start2=`date +%s.%N`
        dtemp=$(date -d $ligne +%s)
        #end2=`date +%s.%N`

        #echo "$dtemp"
        #echo $ligne_temp
        #date_csv=$(cut -d ";" -f 2 "ligne.temp")
        #dtemp=${ligne:6:10}
        #echo $dtemp
        #echo $date_csv
        #echo "date csv 0 4 : ${date_csv:0:4} - ${date_csv:5:2} - ${date_csv:8:2}"
        #atemp=${date_csv:0:4}
        #mtemp=${date_csv:5:2}
        #jtemp=${date_csv:8:2}
        #echo $dtemp 
        #echo "temp : $dtemp | min : $dmin1 | max : $dmax1 "
        #start1=`date +%s.%N`
        #echo "dtemp $dtemp | dmin $dmin1 | dmax $dmax1"
        if [[ $dtemp -ge $dmin1 ]] && [[ $dtemp -le $dmax1 ]] ; then

            awk 'NR=='$i'{ print; exit }' filtre.temp  >> filtre2.temp
        fi
        #end1=`date +%s.%N`
        #echo awk
        #echo "$end - $start" | bc -l
        #echo date 
        #echo "$end2 - $start2" | bc -l
        #echo write
        #echo "$end1 - $start1" | bc -l
        #echo -----
        
        #rm ligne.temp

        
    done
    end3=`date +%s.%N`
    echo "$end3 - $start3" | bc -l
    #echo $jmin $jmax

    #clean up everything
    cp filtre2.temp filtre.temp
    rm datemin.temp
    rm datemax.temp
    rm lignes.temp
    rm lignecut.temp
    rm filtre2.temp
    
    #rm filtre1.temp
    
}

### ouah trop rapide
### le fada de la complexité temporelle
FiltrageDate2() 
{

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
        exit
        ;;

    esac
}

# appelle le programme c avec les bons arguments
#syntaxe générale : ./ProgrammeC $filtre.temp [fichier sortie] [quoi trier] [-r]
AppelC()
{
    case $inconnu in 

        -1) # temperature
        case $temperature in 
            1) #  min, max, moy (11,12,13) trié par n° de station croissant
            #####   ./ProgrammeC $filtre.temp [fichier sortie] 1
            
            
            #awk -F ";" '{print $1}' filtre.temp

            ;;

            2) #  moyenne par date dans l'ordre chronologique (toutes stations)
            #####   ./ProgrammeC filtre.temp [fichier sortie] 2
            ;;

            3) #  temp par date et par station, trié par ordre chrono puis par ID de station
            ####    ./ProgrammeC filtre.temp [fichier sortie1] 1
            ####    ./ProgrammeC [fichier sortie1] [fichier sortie2] 2
            ;; 

            *) echo '$temperature a une valeur inattendue dans AppelC'
            exit
            ;;
        esac
        ;;

        -2) # pression
        case $temperature in 
            1) #  pression + variation (8,9) trié par n° de station croissant
            #####   ./ProgrammeC $filtre.temp [fichier sortie] 1
            
            
            #awk -F ";" '{print $1}' filtre.temp

            ;;

            2) #  moyenne par date dans l'ordre chronologique (toutes stations)
            #####   ./ProgrammeC filtre.temp [fichier sortie] 2
            ;;

            3) #  pression par date et par station, trié par ordre chrono puis par ID de station
            ####    ./ProgrammeC filtre.temp [fichier sortie1] 1
            ####    ./ProgrammeC [fichier sortie1] [fichier sortie2] 2
            ;; 

            *) echo '$pression a une valeur inattendue dans AppelC :'
            exit
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

        -5) # altitude/station, ordre décroissant (alt)
        #### ./ProgrammeC $filtre.temp [fichier sortie] 14 -r
        ;;

        *) echo "How did we get there ?"
        echo '$inconnu a une valeur inattendue dans AppelC'
        exit
        ;;
    esac
}




###############################   programme principal

# initialisation des variables
Initialisation
# lecture des arguments
LectureArgument $@
# vérification des arguments
VerifArgument
# filtrage par lieu
if [[ $lieu -ne 0 ]] ; then
    FiltrageLieu
fi
if [[ $(date -d $datemin +%s) -ne 0 ]] ; then 
    start3=`date +%s.%N`
    FiltrageDate2
    end3=`date +%s.%N`
    echo "$end3 - $start3" | bc -l
else
    echo pas de date
fi
AppelC


