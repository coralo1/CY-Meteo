#include "librairie.h"

void afficherCSV(){
    FILE *fp = NULL;
    fp = fopen("data.csv","r");
    char ligne[1000];

    if (!fp) {
        printf("Erreur lecture !\n");
        exit(1);
    }

    fgets(ligne,sizeof(ligne),fp);
    while (!feof(fp)) {
        fgets(ligne,sizeof(ligne),fp);
        printf("%s",ligne);
    }
    fclose(fp);
}

int compteurLignesCSV(){
    FILE *fp = NULL;
    fp = fopen("data.csv","r");
    int n = 0;
    char ligne[1000];

    if (!fp) {
        printf("Erreur lecture !\n");
        exit(1);
    }

    fgets(ligne,sizeof(ligne),fp); // Passer la première ligne
    while (!feof(fp)) {
        fgets(ligne,sizeof(ligne),fp);
        n++;
    }
    
    fclose(fp);

    return (n-1);
}


ArbreAVL *creationNoeud_m(int id, int hum) {
    ArbreAVL *pNoeud = malloc(sizeof(ArbreAVL));
    if (pNoeud == NULL) {
        printf("Erreur initialisation pNoeud !");
        exit(1);
    }
    pNoeud->valeur.id = id;
    pNoeud->valeur.humidite = hum;
    pNoeud->fGauche = NULL;
    pNoeud->fDroit = NULL;
    pNoeud->equilibre = 0;
    return pNoeud;
}


ArbreAVL *creationNoeud_h(int id, int alt) {
    ArbreAVL *pNoeud = malloc(sizeof(ArbreAVL));
    if (pNoeud == NULL) {
        printf("Erreur initialisation pNoeud !");
        exit(1);
    }
    pNoeud->valeur.id = id;
    pNoeud->valeur.altitude = alt;
    pNoeud->fGauche = NULL;
    pNoeud->fDroit = NULL;
    pNoeud->equilibre = 0;
    return pNoeud;
}

ArbreAVL *creationNoeud_t1_p1(int id, float temp, float min, float max) {
    ArbreAVL *pNoeud = malloc(sizeof(ArbreAVL));
    if (pNoeud == NULL) {
        printf("Erreur initialisation pNoeud !");
        exit(1);
    }
    pNoeud->valeur.id = id;
    pNoeud->valeur.temp = temp;
    pNoeud->valeur.min = min;
    pNoeud->valeur.max = max;
    pNoeud->fGauche = NULL;
    pNoeud->fDroit = NULL;
    pNoeud->equilibre = 0;
    return pNoeud;
}

// Fonction exemple pour -t1
void traiter(Arbre *pNoeud) {
    if (pNoeud != NULL) {
        printf("ID : %d\n",pNoeud->valeur.id);
        printf("Temp : %f\n",pNoeud->valeur.temp);
        printf("Temp min : %f\n",pNoeud->valeur.min);
        printf("Temp max : %f\n",pNoeud->valeur.max);
    }
}

// Fonctions max et min nécessaires pour les rotations : (en C -> fmax() ou fmin() utilisent des flottants)
int max(int a, int b) {
    if (a >= b) 
        return a;
    else 
        return b;
}

int min(int a, int b) {
    if (a <= b) 
        return a;
    else   
        return b;
}

// Code pour équilibrageAVL :
ArbreAVL *rotationGauche(ArbreAVL *pNoeud) {
    ArbreAVL *pivot = NULL;
    pivot = pNoeud->fDroit;
    pNoeud->fDroit = pivot->fGauche;
    pivot->fGauche = pNoeud;
    int eq_pNoeud = pNoeud->equilibre;
    int eq_pivot = pivot->equilibre;
    pNoeud->equilibre = eq_pNoeud - max(eq_pivot,0) - 1;
    pivot->equilibre = min(eq_pNoeud-2,min(eq_pNoeud+eq_pivot-2,eq_pivot-1));
    pNoeud = pivot;
    return pNoeud;
}

ArbreAVL *rotationDroite(ArbreAVL *pNoeud) {
    ArbreAVL *pivot = NULL;
    pivot = pNoeud->fGauche;
    pNoeud->fGauche = pivot->fDroit;
    pivot->fDroit = pNoeud;
    int eq_pNoeud = pNoeud->equilibre;
    int eq_pivot = pivot->equilibre;
    pNoeud->equilibre = eq_pNoeud - min(eq_pivot,0) + 1;
    pivot->equilibre = max(eq_pNoeud+2,max(eq_pNoeud+eq_pivot+2,eq_pivot+1));
    pNoeud = pivot;
    return pNoeud;
}

ArbreAVL *doubleRotationGauche(ArbreAVL *pNoeud) {
    pNoeud->fDroit = rotationDroite(pNoeud->fDroit);
    return rotationGauche(pNoeud);
}

ArbreAVL *doubleRotationDroite(ArbreAVL *pNoeud) {
    pNoeud->fGauche = rotationGauche(pNoeud->fGauche);
    return rotationDroite(pNoeud);
}

ArbreAVL *equilibrageAVL(ArbreAVL *pNoeud) {
    if (pNoeud->equilibre >= 2) {
        if (pNoeud->fDroit->equilibre >= 0)
            return rotationGauche(pNoeud);
        else 
            return doubleRotationGauche(pNoeud);
    }
    else if (pNoeud->equilibre <= -2) {
        if (pNoeud->fGauche->equilibre <= 0)
            return rotationDroite(pNoeud);
        else 
            return doubleRotationDroite(pNoeud);
    }
    return pNoeud;
}

// Affichage, parcours infixe (fGauche, noeud, fDroit);
void parcoursInfixe(ArbreAVL *pNoeud) {
    if (pNoeud != NULL) {
        parcoursInfixe(pNoeud->fGauche);
        traiter(pNoeud);
        parcoursInfixe(pNoeud->fDroit);
    }
}

// Écriture ordre croissant à l'aide du parcours infixe pour t1_p1
void ecritureInfixe(ArbreAVL *pNoeud,FILE *fp) {
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
void ecritureDecroissant_h(ArbreAVL *pNoeud,FILE *fp) {
    if (pNoeud != NULL) {
        ecritureDecroissant_h(pNoeud->fDroit,fp);
        fprintf(fp,"%d;%d",pNoeud->valeur.id,pNoeud->valeur.altitude);
        ecritureDecroissant_h(pNoeud->fGauche,fp);
    }
}
void ecritureDecroissant_m(ArbreAVL *pNoeud,FILE *fp) {
    if (pNoeud != NULL) {
        ecritureDecroissant_m(pNoeud->fDroit,fp);
        fprintf(fp,"%d;%d",pNoeud->valeur.id,pNoeud->valeur.humidite);
        ecritureDecroissant_m(pNoeud->fGauche,fp);
    }
}


// Insertion dans un AVL : (avec équilibrage)
ArbreAVL *insertionAVL_t1_p1(ArbreAVL *pNoeud, int id, float temp, float max, float min) {
    int *h;
    if (pNoeud == NULL) {
        *h = 1;
        return creationNoeud_t1_p1(id,temp,max,min);
    }
    else if (id < pNoeud->valeur.id) {
        pNoeud->fGauche = insertionAVL_t1_p1(pNoeud->fGauche,id,temp,max,min);
        *h = -*h;
    }
    else if (id > pNoeud->valeur.id) {
        pNoeud->fDroit = insertionAVL_t1_p1(pNoeud->fDroit,id,temp,max,min);
    }
    else {
        *h = 0;
        return pNoeud;
    }
    if (*h != 0) {
        pNoeud->equilibre += *h;
        pNoeud = equilibrageAVL(pNoeud);
        if (pNoeud->equilibre == 0)
            *h = 0;
        else 
            *h = 1;
    }
    return pNoeud;
}

ArbreAVL *insertionAVL_h(ArbreAVL *pNoeud, int id, int alt) {
    int *h;
    if (pNoeud == NULL) {
        *h = 1;
        return creationNoeud_h(id,alt);
    }
    else if (alt < pNoeud->valeur.altitude) {
        pNoeud->fGauche = insertionAVL_h(pNoeud->fGauche,id,alt);
        *h = -*h;
    }
    else if (alt > pNoeud->valeur.altitude) {
        pNoeud->fDroit = insertionAVL_h(pNoeud->fDroit,id,alt);
    }
    else {
        *h = 0;
        return pNoeud;
    }
    if (*h != 0) {
        pNoeud->equilibre += *h;
        pNoeud = equilibrageAVL(pNoeud);
        if (pNoeud->equilibre == 0)
            *h = 0;
        else 
            *h = 1;
    }
    return pNoeud;
}

ArbreAVL *insertionAVL_m(ArbreAVL *pNoeud, int id,int hum) {
    int *h;
    if (pNoeud == NULL) {
        *h = 1;
        return creationNoeud_m(id,hum);
    }
    else if (hum < pNoeud->valeur.humidite) {
        pNoeud->fGauche = insertionAVL_m(pNoeud->fGauche,id,hum);
        *h = -*h;
    }
    else if (hum > pNoeud->valeur.humidite) {
        pNoeud->fDroit = insertionAVL_m(pNoeud->fDroit,id,hum);
    }
    else {
        *h = 0;
        return pNoeud;
    }
    if (*h != 0) {
        pNoeud->equilibre += *h;
        pNoeud = equilibrageAVL(pNoeud);
        if (pNoeud->equilibre == 0)
            *h = 0;
        else 
            *h = 1;
    }
    return pNoeud;
}

// Reçoit un "fichier.csv" qui n'a que les colonnes id, temp, min, max
ArbreAVL *dataArbreAVL_t1_p1(ArbreAVL *pNoeud) {
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
        pNoeud = insertionAVL_t1_p1(pNoeud,id,temp,min,max);
    }

    fclose(fp);
    return pNoeud;
}


ArbreAVL *dataArbreAVL_h(ArbreAVL *pNoeud) {
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
        pNoeud = insertionAVL_h(pNoeud,id,alt);
    }

    fclose(fp);
    return pNoeud;
}

ArbreAVL *dataArbreAVL_m(ArbreAVL *pNoeud) {
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
        pNoeud = insertionAVL_h(pNoeud,id,hum);
    }

    fclose(fp);
    return pNoeud;
}

// Récupération des données du CSV :
void copieDataCSV(ArbreAVL *pNoeud) {
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