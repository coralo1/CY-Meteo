#!/bin/bash

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
   echo "Syntaxe: ./script.sh  [MODE] [LIEU] [date]"
   echo "MODE: au moins un. pas de max."
   echo "-t[1-3]     température"
   echo "-p[1-3]     pression"
   echo "-w          vent"
   echo "-m          humidité"
   echo "-h          altitude"
   echo
   echo "LIEU: optionnel. max 1. filtre les données selon un lieu. Si plusieurs sont sélectionnés, seulement le dernier sera considéré."
   echo "-F          France métropolitaine + Corse"
   echo "-G          Guyane française"
   echo "-S          Saint-Pierre et Miquelon"
   echo "-A          Antilles"
   echo "-O          Océan Indien"
   echo "-Q          Antarctique"
   echo
   echo "DATE : optionnel."
   echo "format : -d <min> <max>"
   echo "exemple : -d 2010-2-23 2010-4-23"
   echo "pour sélectionner entre le 23 février et 23 avri 2010"
}




#initialisation des variables
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

for (( i=1 ; i<=$# ; i++ )) ; do
    #echo argument "$i" = "${!i}"
    case ${!i} in

        #### MODES ####

        ### temperature ###
        -t*) echo "température X"
        inconnu=-1 
        #si déja passé en argument auparavant
        if [ $temperature -ne 0 ] ; then
            echo "veuillez ne pas indiquer plus d'une option de température"
            inconnu=2
            break 3
        fi
        #case pour chaque option
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
        #si déjà passé en argument auparavant
        if [ $pression -ne 0 ] ; then
            echo "veuillez ne pas indiquer plus d'une option de pression"
            inconnu=2
            break 3
        fi
        #case pour chaque option
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
        #vérifie qu'une date n'a pas déjà été entrée
        if [ $datemin -ne 0 ] && [ $datemax -ne 0 ] ; then
            echo "veuillez ne pas indiquer plusieurs plages temporelles"
        fi
        datemin=${!i+1}
        datemax=${!i+2}
        #vérification de datemin et datemax
        for (( j=1 ; j<=3 ; j++ )); do
            temp1=$(cut -d- -f$j "$datemin")
            temp2=$(cut -d- -f$j "$datemax")
            echo "$temp1 $temp2"
            
            #vérifie que les dates sont valides
            case $j in
                1) 
                if [ $datemin -lt 2010 ] || [ $datemax -lt 2010 ] || [ $datemin -gt 2022 ] || [ $datemax -gt 2022 ]; then
                    echo "veuillez entrer une date entre 2010 et 2022 inclus"
                fi
                amin=datemin
                amax=datemax
                ;;

                2) 
                if [ $datemin -lt 1 ] || [ $datemax -lt 1 ] || [ $datemin -gt 12 ] || [ $datemax -gt 12 ]; then
                    echo "veuillez entrer une date valide"
                fi
                mmin=datemin
                mmax=datemax
                ;;

                3)
                if [ $datemin -lt 1 ] || [ $datemax -lt 1 ] || [ $datemin -gt 31 ] || [ $datemax -gt 31 ]; then
                    echo "veuillez entrer une date valide"
                fi
                
                ;;

                #autres (ne devrait jamais arriver ?)
                *) echo "erreur inattendue pendant la vérification de date"
                inconnu=3;
                break 4;
            esac
            if [ $temp1 -lt $temp2 ] ; then
                echo "la première date est plus faible que la deuxième, on les inverse donc"
                j=j+2
            fi
        done
        ;;


        #### Autres ####

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

#on vérifie que les arguments sont valides/qu'il y en a
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


# --help
if [ $aide -eq 1 ] ; then
    Help
    exit
fi

# petite verif
Paramètres


#altitude
#on veut l'altitude par station et par ordre décroissant
#1 : Id
#14 : altitude



#humidite
#1 : id
#6 : humidite



#temperature=0
#pression=0
#vent=0
#if temperature=1
#    ./programme temp1.csv temp2.csv 1
#elif temperature=2
#    ./programme temp1.csv temp2.csv 5 -r
#./[programme] [fichier entrée] [fichier sortie] [quoi trier] [-r]
