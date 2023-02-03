#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Structures : 

typedef struct data {
    int id;
    float temp;
    float min;
    float max;
    int altitude;
    int humidite;
} Data;

typedef struct arbre_avl {
    Data valeur;
    struct arbre *fGauche;
    struct arbre *fDroit;
    int equilibre;
} ArbreAVL;

typedef struct arbre {
    Data valeur;
    struct arbre *fGauche;
    struct arbre *fDroit;
} Arbre;


// Fonctions plus générales :

void afficherCSV();
int compteurLignesCSV();
int max(int a, int b);
int min(int a, int b);


// Fonctions arbreAVL : 

ArbreAVL *creationNoeud_m(int id, int hum);
ArbreAVL *creationNoeud_h(int id, int alt);
ArbreAVL *creationNoeud_t1_p1(int id, float temp, float min, float max);
void traiter(Arbre *pNoeud);
ArbreAVL *rotationGauche(ArbreAVL *pNoeud);
ArbreAVL *rotationDroite(ArbreAVL *pNoeud);
ArbreAVL *doubleRotationGauche(ArbreAVL *pNoeud);
ArbreAVL *doubleRotationDroite(ArbreAVL *pNoeud);
ArbreAVL *equilibrageAVL(ArbreAVL *pNoeud);
void parcoursInfixe(ArbreAVL *pNoeud);
void ecritureInfixe(ArbreAVL *pNoeud,FILE *fp);
void ecritureDecroissant_h(ArbreAVL *pNoeud,FILE *fp);
void ecritureDecroissant_m(ArbreAVL *pNoeud,FILE *fp);
ArbreAVL *insertionAVL_t1_p1(ArbreAVL *pNoeud, int id, float temp, float max, float min);
ArbreAVL *insertionAVL_h(ArbreAVL *pNoeud, int id, int alt);
ArbreAVL *insertionAVL_m(ArbreAVL *pNoeud, int id,int hum);
ArbreAVL *dataArbreAVL_t1_p1(ArbreAVL *pNoeud);
ArbreAVL *dataArbreAVL_h(ArbreAVL *pNoeud);
ArbreAVL *dataArbreAVL_m(ArbreAVL *pNoeud);
void copieDataCSV(ArbreAVL *pNoeud);

// Fonctions arbreABR :

Arbre *creationNoeud_m(int id, int hum);
Arbre *creationNoeud_h(int id, int alt);
Arbre *creationNoeud_t1_p1(int id, float temp);
Arbre *insertionABR_id(Arbre *pNoeud, int id, int b);
Arbre *insertionABR_m(Arbre *pNoeud, int id, int hum);
Arbre *insertionABR_h(Arbre *pNoeud, int id, int alt);
Arbre *dataArbreABR_t1_p1(Arbre *pNoeud);
Arbre *dataArbreABR_h(Arbre *pNoeud);
Arbre *dataArbreABR_m(Arbre *pNoeud);
void copieDataCSV(Arbre *pNoeud);
void parcoursInfixe(Arbre *pNoeud);
void ecritureInfixe(Arbre *pNoeud,FILE *fp);
void ecritureDecroissant_h(Arbre *pNoeud,FILE *fp);
void ecritureDecroissant_m(Arbre *pNoeud,FILE *fp);




























