#include "librairie.h"

Arbre *creationNoeud_m(int id, int hum) {
    Arbre *pNoeud = malloc(sizeof(Arbre));
    if (pNoeud == NULL) {
        printf("Erreur initialisation pNoeud !");
        exit(1);
    }
    pNoeud->valeur.id = id;
    pNoeud->valeur.humidite = hum;
    pNoeud->fGauche = NULL;
    pNoeud->fDroit = NULL;
    return pNoeud;
}


Arbre *creationNoeud_h(int id, int alt) {
    Arbre *pNoeud = malloc(sizeof(Arbre));
    if (pNoeud == NULL) {
        printf("Erreur initialisation pNoeud !");
        exit(1);
    }
    pNoeud->valeur.id = id;
    pNoeud->valeur.altitude = alt;
    pNoeud->fGauche = NULL;
    pNoeud->fDroit = NULL;
    return pNoeud;
}

Arbre *creationNoeud_t1_p1(int id, float temp) {
    Arbre *pNoeud = malloc(sizeof(Arbre));
    if (pNoeud == NULL) {
        printf("Erreur initialisation pNoeud !");
        exit(1);
    }
    pNoeud->valeur.id = id;
    pNoeud->valeur.temp = temp;
    pNoeud->fGauche = NULL;
    pNoeud->fDroit = NULL;
    return pNoeud;
}

// A chaque fois deux données importantes à insérer dans l'arbre : id et (soit temp, soit alt, soit hum, etc)
Arbre *insertionABR_id(Arbre *pNoeud, int id, int b) {
    if (pNoeud == NULL)
        return creationNoeud_t1_p1(id,b);
    else if (pNoeud->valeur.id > id)
        pNoeud->fGauche = insertionABR_id(pNoeud->fGauche,id,b);
    else if (pNoeud->valeur.id < id)
        pNoeud->fDroit = insertionABR_id(pNoeud->fDroit,id,b);
    return pNoeud;
}
Arbre *insertionABR_m(Arbre *pNoeud, int id, int hum) {
    if (pNoeud == NULL)
        return creationNoeud_m(id,hum);
    else if (pNoeud->valeur.humidite > hum)
        pNoeud->fGauche = insertionABR_m(pNoeud->fGauche,id,hum);
    else if (pNoeud->valeur.humidite < hum)
        pNoeud->fDroit = insertionABR_m(pNoeud->fDroit,id,hum);
    return pNoeud;
}
Arbre *insertionABR_h(Arbre *pNoeud, int id, int alt) {
    if (pNoeud == NULL)
        return creationNoeud_h(id,alt);
    else if (pNoeud->valeur.altitude > alt)
        pNoeud->fGauche = insertionABR_h(pNoeud->fGauche,id,alt);
    else if (pNoeud->valeur.altitude < alt)
        pNoeud->fDroit = insertionABR_h(pNoeud->fDroit,id,alt);
    return pNoeud;
}



// Reçoit un "fichier.csv" qui n'a que les colonnes id, temp, min, max
Arbre *dataArbreABR_t1_p1(Arbre *pNoeud) {
    FILE *fp = NULL;
    fp = fopen("fichier.csv","r");
    char ligne[1000];
    int id;
    float temp, min, max;
    if (!fp) {
        printf("Erreur lecture\n");
        exit(2);
    }
    
    fgets(ligne,sizeof(ligne),fp); // Pour passer la première ligne (en-tête)
    // printf("%s",ligne); Affichage première ligne
    while (fgets(ligne,sizeof(ligne),fp) != NULL) {
        int lecture = sscanf(ligne,"%d;%f;%f;%f",&id,&temp,&min,&max);
        // if (lecture != 4) {
        //     printf("Problèmes lectures data\n");
        //     exit(4);
        // }
        // Affichage test :
        // printf("%d;%f;%f;%f\n",id,temp,min,max);
        pNoeud = insertionABR_id(pNoeud,id,temp);
    }

    fclose(fp);
    return pNoeud;
}


Arbre *dataArbreABR_h(Arbre *pNoeud) {
    FILE *fp = NULL;
    fp = fopen("fichier.csv","r");
    char ligne[1000];
    int id, alt;
    if (!fp) {
        printf("Erreur lecture\n");
        exit(2);
    }
    
    fgets(ligne,sizeof(ligne),fp); // Pour passer la première ligne (en-tête)
    // printf("%s",ligne); Affichage première ligne
    while (fgets(ligne,sizeof(ligne),fp) != NULL) {
        int lecture = sscanf(ligne,"%d;%d",&id,&alt);
        // if (lecture != 4) {
        //     printf("Problèmes lectures data\n");
        //     exit(4);
        // }
        // Affichage test :
        // printf("%d;%d\n",id,alt);
        pNoeud = insertionABR_h(pNoeud,id,alt);
    }

    fclose(fp);
    return pNoeud;
}

Arbre *dataArbreABR_m(Arbre *pNoeud) {
    FILE *fp = NULL;
    fp = fopen("fichier.csv","r");
    char ligne[1000];
    int id, hum;
    if (!fp) {
        printf("Erreur lecture\n");
        exit(2);
    }
    
    fgets(ligne,sizeof(ligne),fp); // Pour passer la première ligne (en-tête)
    // printf("%s",ligne); Affichage première ligne
    while (fgets(ligne,sizeof(ligne),fp) != NULL) {
        int lecture = sscanf(ligne,"%d;%d",&id,&hum);
        // if (lecture != 4) {
        //     printf("Problèmes lectures data\n");
        //     exit(4);
        // }
        // Affichage test :
        // printf("%d;%d\n",id,alt);
        pNoeud = insertionABR_m(pNoeud,id,hum);
    }

    fclose(fp);
    return pNoeud;
}

void copieDataCSV(Arbre *pNoeud) {
    FILE *fSort = NULL;
    fSort = fopen("copie_fichier.csv","w");
    char ligne[1000];

    // Test écriture :
    if (!fSort) {
        printf("Erreur fichier écriture\n");
        exit(3);
    }

    ecritureInfixe(pNoeud,fSort);

    fclose(fSort);
}

void parcoursInfixe(Arbre *pNoeud) {
    if (pNoeud != NULL) {
        parcoursInfixe(pNoeud->fGauche);
        traiter(pNoeud);
        parcoursInfixe(pNoeud->fDroit);
    }
}

// Écriture ordre croissant à l'aide du parcours infixe pour t1_p1
void ecritureInfixe(Arbre *pNoeud,FILE *fp) {
    if (pNoeud != NULL) {   
        ecritureInfixe(pNoeud->fGauche,fp);
        fprintf(fp,"%d;%f;%f;%f\n",
                pNoeud->valeur.id,
                pNoeud->valeur.temp,
                pNoeud->valeur.min,
                pNoeud->valeur.max);
        ecritureInfixe(pNoeud->fDroit,fp);
    }

}

// Écriture ordre décroissant pour -h -m
void ecritureDecroissant_h(Arbre *pNoeud,FILE *fp) {
    if (pNoeud != NULL) {
        ecritureDecroissant_h(pNoeud->fDroit,fp);
        fprintf(fp,"%d;%d",pNoeud->valeur.id,pNoeud->valeur.altitude);
        ecritureDecroissant_h(pNoeud->fGauche,fp);
    }
}
void ecritureDecroissant_m(Arbre *pNoeud,FILE *fp) {
    if (pNoeud != NULL) {
        ecritureDecroissant_m(pNoeud->fDroit,fp);
        fprintf(fp,"%d;%d",pNoeud->valeur.id,pNoeud->valeur.humidite);
        ecritureDecroissant_m(pNoeud->fGauche,fp);
    }
}
