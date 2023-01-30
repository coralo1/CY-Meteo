#!/bin/bash

#problèmes de grep vers la ligne 400

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

Help()
{
   echo "Description du programme :)"
   echo
   echo "Syntaxe : ./script.sh  [MODE] [LIEU] [DATE] [FICHIER]"
   echo "MODE: obligatoire. pas de max."
   echo "-t[1-3]     température"
   echo "-p[1-3]     pression"
   echo "-w          vent"
   echo "-m          humidité"
   echo "-h          altitude"
   echo
   echo "LIEU : optionnel. max 1. filtre les données selon un lieu. Si plusieurs sont sélectionnés, seulement le dernier sera considéré."
   echo "-F          France métropolitaine + Corse"
   echo "-G          Guyane française"
   echo "-S          Saint-Pierre et Miquelon"
   echo "-A          Antilles"
   echo "-O          Océan Indien"
   echo "-Q          Antarctique"
   echo
   echo "DATE : optionnel. entre 2010 et 2022 inclus"
   echo "format : -d <min> <max>"
   echo "exemple : -d 2010-02-23 2010-04-23"
   echo "pour sélectionner entre le 23 février et 23 avril 2010"
   echo "attention à bien inclure un"
   echo
   echo "FICHIER : obligatoire. max 1."
   echo "syntaxe : -f [nom du fichier]"
   echo "seul le fichier data.csv original peut fonctionner, tout autre fichier entrainera une erreur"
   echo
}




###             initialisation des variables
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

for (( i=1 ; i<=$# ; i++ )) ; do
    #echo "boucle $i"
    #echo
    #echo argument "$i" = "${!i}"
    case ${!i} in

        #### MODES ####

        ### temperature ###
        -t*) echo "température X"
        inconnu=-1 
        ###             si déja passé en argument auparavant
        if [ $temperature -ne 0 ] ; then
            echo "veuillez ne pas indiquer plus d'une option de température"
            inconnu=2
            break 3
        fi
        ###             case pour chaque option
        case ${!i} in
            -t1) echo "température min,max,moy par station X" 
            temperature=1 ;;
            -t2) echo "température moyenne par date sur toute les stations X"
            temperature=2 ;;
            -t3) echo "température par date & par station X"
            temperature=3 ;;
            -*) echo "${!i} : veuillez indiquer un mode correct [1-3] avec la température"
            inconnu=2
            break 3 ;;
        esac
        ;;

        ### presion ###
        -p*) echo "pression X" 
        inconnu=-1
        ###             si déjà passé en argument auparavant
        if [ $pression -ne 0 ] ; then
            echo "veuillez ne pas indiquer plus d'une option de pression"
            inconnu=2
            break 3
        fi
        ###             case pour chaque option
        case ${!i} in
            -p1) echo "pression min,max,moy par station X" 
            pression=1 ;;
            -p2) echo "pression moyenne par date sur toute les stations X"
            pression=2 ;;
            -p3) echo "pression par date & par station X"
            pression=3 ;;
            -*) echo "${!i} : veuillez indiquer un mode correct [1-3] avec la pression"
            inconnu=2
            break 3 ;;
        esac
        ;;

        ### vent ###
        -w) echo "vent X" 
        inconnu=-1 
        vent=1 ;;

        ### humidité ###
        -m) echo "humidité X" 
        inconnu=-1
        humidite=1 ;;

        ### altitude ###
        -h) echo "altitude X" 
        inconnu=-1
        altitude=1 ;;
        
        ##### LIEUX ####

        ### France ###
        -F) echo "France X" 
        lieu=1 ;;

        ### Guyane ###
        -G) echo "Guyane X"
        lieu=2 ;;

        ### Saint-Pierre et Miquelon ###
        -S) echo "Saint-Pierre et Miquelon X"
        lieu=3 ;;

        ### Antilles ###
        -A) echo "Antilles X"
        lieu=4 ;;

        ### Océan Indien ###
        -O) echo "Océan Indien X"
        lieu=5 ;;

        ### Antarctique ###
        -Q) echo "Antarctique X"
        lieu=6 ;;

        #### Date ####

        -d)
        ###             vérifie qu'une date n'a pas déjà été entrée
        if [ $datemin -ne 0 ] && [ $datemax -ne 0 ] ; then
            echo "veuillez ne pas indiquer plusieurs plages temporelles"
        fi
        ###             assigne les dates à des fichiers temporaires
        i=$(( $i+1 ))
        datemin=${!i}
        i=$(( $i+1 ))
        datemax=${!i}
        #echo $datemax>datemax.temp
        #echo $datemin>datemin.temp

        ###             vérifie que datemin et datemax sont bien des dates ;
        ###             c'est une adaptation de code que j'ai trouvé sur stackexchange quand je voulais vérifier que la date avait un format valide
        ###             j'avais codé a la main tout un système pour vérifier que la date est correcte (genre pas un 29 février sur une année non-bissextile)
        ###             en oubliant que la fonction  "date" existe, du coup je le laisse en commentaire en dessous
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

<<'commentaire'
        #vérification de datemin et datemax
        for (( j=1 ; j<=3 ; j++ )); do
            tempmin=$(cut -d- -f"$j" "datemin.temp")
            tempmax=$(cut -d- -f"$j" "datemax.temp")

            #temp2=$(cut -d- -f"$j" "$datemax")
            #echo "tempmin : $tempmin"
            #echo "tempmax : $tempmax"
            
            
            case $j in
                1) #vérifie que les années sont valides
                if [ $tempmin -lt 2010 ] || [ $tempmax -lt 2010 ] || [ $tempmin -gt 2022 ] || [ $tempmax -gt 2022 ] ; then
                    echo "veuillez entrer une date entre 2010 et 2022 inclus"
                    inconnu=2
                    break 5
                fi
                #vérifie que la 1e date est la plus ancienne
                if [ $tempmin -gt $tempmax ] ; then
                    echo "veuillez entrer une première date plus ancienne que la 2e(annee)"                
                    inconnu=2
                    break 5
                fi
                amin=$tempmin
                amax=$tempmax
                #echo "annees OK"
                ;;

                2) #vérifie que les mois sont valides
                if [ $tempmin -lt 1 ] || [ $tempmax -lt 1 ] || [ $tempmin -gt 12 ] || [ $tempmax -gt 12 ] ; then
                    echo "veuillez entrer une date valide"
                    inconnu=2
                    break 5
                fi
                #vérifie que la 1e date est la plus ancienne
                if [ $tempmin -gt $tempmax ] && [ $amin -eq $amax ] ; then
                    echo "veuillez entrer une première date plus ancienne que la 2e(mois)"                
                    inconnu=2
                    break 5
                fi
                mmin=$tempmin
                mmax=$tempmax
                #echo "mois OK"
                ;;

                3) #vérifie que les jours sont valides
                #vérifie que la 1e date est la plus ancienne
                if [ $tempmin -gt $tempmax ] && [ $amin -eq $amax ] && [ $mmin -eq $mmax ] ; then
                    echo "veuillez entrer une première date plus ancienne que la 2e(jours)"                
                    inconnu=2
                    break 5
                fi
                if [ $tempmin -lt 1 ] || [ $tempmax -lt 1 ] || [ $tempmin -gt 31 ] || [ $tempmax -gt 31 ] ; then
                    echo "veuillez entrer une date valide"
                    inconnu=2
                    break 5
                fi
                #mois à 30 jours (1e valeur)
                if [ $mmin -eq 4 ] || [ $mmin -eq 6 ] || [ $mmin -eq 9 ] || [ $mmin -eq 11 ] ; then
                    if [ $tempmin -gt 30 ] ; then
                        echo "le mois $mmin n'est pas à 31 jours"
                        inconnu=2
                        break 6
                    fi
                #mois à 30 jours (2e valeur)
                elif [ $mmax -eq 4 ] || [ $mmax -eq 6 ] || [ $mmax -eq 9 ] || [ $mmax -eq 11 ] ; then
                    if [ $tempmax -gt 30 ] ; then
                        echo "le mois $mmax n'est pas à 31 jours"
                        inconnu=2
                        break 6
                    fi
                #février (1e valeur)
                elif [ $mmin -eq 2 ] ; then
                    #années bissextiles
                    if [ $amin -eq 2012 ] || [ $amin -eq 2016 ] || [ $amin -eq 2020 ] ; then
                        if [ $tempmin -gt 29 ] ; then
                            echo "février $amin n'a que 29 jours"
                            inconnu=2
                            break 7
                        fi
                    #années normales
                    elif [ $tempmin -gt 28 ] ; then
                            echo "février $amin n'a que 28 jours"
                            inconnu=2
                            break 7
                    fi
                #février (2e valeur)
                elif [ $mmax -eq 2 ] ; then
                    #années bissextiles
                    if [ $amax -eq 2012 ] || [ $amax -eq 2016 ] || [ $amax -eq 2020 ] ; then
                        if [ $tempmax -gt 29 ] ; then
                            echo "février $amax n'a que 29 jours"
                            inconnu=2
                            break 7
                        fi
                    #années normales
                    elif [ $tempmax -gt 28 ] ; then
                            echo "février $amax n'a que 28 jours"
                            inconnu=2
                            break 7
                    fi
                fi
                jmin=$tempmin
                jmax=$tempmax
                #echo "jours OK"
                ;;

                #autres (ne devrait jamais arriver ?)
                *) echo "erreur inattendue pendant la vérification de date"
                inconnu=3
                break 4
                ;;
            esac
            #si la 1e date est plus récente que la 2e, on les échange
            
        
        done
commentaire
        #echo test1
        #echo "date ok : $datemin | $datemax"
        #rm datemax.temp
        #rm datemin.temp
        ;;


        #### Autres ####
        
        ### fichier ###
        -f)
        fichier_existe=1
        i=$(( $i+1 ))
        fichier=${!i}
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

###             on vérifie que les arguments sont valides/qu'il y en a
if [ $inconnu -eq 1 ] ; then
    exit
elif [ $inconnu -eq 0 ] ; then
    echo "paramètres d'entrée insufisants. essayez --help pour plus d'informations"
    exit
elif [ $inconnu -eq 2 ] ; then
    echo "syntaxe erronée. essayez --help pour plus d'informations"
    exit
elif [ $inconnu -eq 3 ] ; then
    echo "erreur inattendue"
    exit
fi
if [ $fichier_existe -eq 0 ] ; then
    echo "il faut indiquer un fichier"
    exit
fi


###             --help
if [ $aide -eq 1 ] ; then
    Help
    exit
fi

###             vérification rapide que le fichier est correct
if [ $(stat -c%s $fichier) -ne 238860185 ] ; then
    echo "le fichier spécifique n'est pas valide"
    exit
fi

#Paramètres

###             filtrage du fichier par lieu :
###             lieu                                ID $lieu     ID Station
###             -------------------------------------------------------------
###             france métropolitaine + corse       1            tout le reste
###             guyane                              2            81415 81408 81405 81401
###             saint pierre et miquelon            3            71805
###             antilles                            4            78925 78922 78890 78897 78894
###             océan indien                        5            61980 61976 61968 67005 61970 61972 61996 61997 61998
###             antarctique                         6            89642

###             sélection du lieu


#echo $lieu $fichier
echo "grep '71805;' $fichier>filtre.temp"
case $lieu in
    ###             vu que j'ai fonctionné par station pour les autres lieux (certains ont pas de département et hum la longitude/latitude)
    ###             j'ai juste décidé de prendre tout le reste pour la france
    1) echo "lieu france"
    grep -v '81415;\|81408;\|81405;\|81401;\|71805;\|78925;\|78922;\|78890;\|78894;\|78897;\|61980;\|61976;\|61968;\|67005;\|61970;\|61972;\|61996;\|61997;\|61998;\|89642;' $fichier>filtre.temp
    #head filtre.temp
    ;;

    2) echo "lieu guyane"
    echo $(grep '81415;\|81408;\|81405;\|81401;' "$fichier")>filtre.temp
    #head filtre.temp
    ;;

    3) echo "lieu saint pierre et miquelon"
    grep '71805;' $fichier>filtre.temp
    #head filtre.temp
    ;;

    4) echo "lieu antilles"
    grep '78925;\|78922;\|78890;\|78894;\|78897;' $fichier>filtre.temp
    #head filtre.temp
    ;;

    5) echo "lieu océan indien"
    grep '61980;\|61976;\|61968;\|67005;\|61970;\|61972;\|61996;\|61997;\|61998;' $fichier>filtre.temp
    #head filtre.temp
    ;;

    6) echo "lieu antarctique"
    grep '89642;' $fichier>filtre.temp
    #head filtre.temp
    ;;

    *) echo "erreur inattendue lors de la sélection de lieu : $lieu a une valeur incorrecte"
    exit
    ;;

esac


###             sélection de la date
echo "$datemin">datemin.temp
echo "$datemax">datemax.temp

amin=$(cut -d- -f1 "datemin.temp")
amax=$(cut -d- -f1 "datemax.temp")
mmin=$(cut -d- -f2 "datemin.temp")
mmax=$(cut -d- -f2 "datemax.temp")
jmin=$(cut -d- -f3 "datemin.temp")
jmax=$(cut -d- -f3 "datemax.temp")
grep 

#echo $jmin $jmax

rm datemin.temp
rm datemax.temp


#temperature=0
#pression=0
#vent=0
#if temperature=1
#    ./programme temp1.csv temp2.csv 1
#elif temperature=2
#    ./programme temp1.csv temp2.csv 5 -r
#./[programme] [fichier entrée] [fichier sortie] [quoi trier] [-r]

