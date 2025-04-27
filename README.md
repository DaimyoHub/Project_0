# Projet Programmation Fonctionnelle Avancée
- POCQUET ALEXIS
- PARENT YVAN

## Propriétés générales

- Arena shooter
- Roguelite (Selection d'augmentations au fur et à mesure pour personnaliser sa partie)
- Deux joueurs en coopération
- Vue d'en haut

## Gameplay

- Le but du jeu est de réussir à survivre 1 minute sur la carte en ayant le plus d'éléminations d'ennemis que possible

- Les touches sont affichées en jeu, il suffit d'aller sur le Menu avec la touche 'm', toutes les touches y sont décrites, ainsi que les statistiques des joueurs sur la partie actuelle.

- Deux personnages sont controlables simultanément par deux personnes différentes jouant localement sur la même machine.
- Les joueurs peuvent réaliser différentes actions simples mais cruciales : 
    - Se déplacer et sauter :
      *Les déplacements peuvent être contraints et modifiés par la présence de vent sur certaines parties de la carte*
    - Tirer des projectiles
    - Poser un portail : 
      *chaque joueur est en mesure de poser une sortie de téléporteur, mais ces derniers ne sont actifs que lorsque les deux joueurs en ont créés, afin de pouvoir se téléporter d'un bout à l'autre*
    - Tirer à travers un portail :
      *Si un portail est actif, les joueurs peuvent tirer à travers les portails afin que les projectiles se téléportent sur l'autre sortie*
- Périodiquement, des ennemis apparaissent sur la carte :
    - Leur but est de tuer les joueurs
    - Ils se dirigent en permanence vers le joueur le plus proche
    - Ils tirent périodiquement des projectiles en direction des joueurs
    - Les ennemis deviennent de plus en plus puissants de manière passive au fur et à mesure de la partie
- Chaque fois qu'un ennemi est vaincu, les joueurs peuvent choisir un bonus :
    - Les bonus sont partagés par les deux joueurs
    - Il existe 10 différentes améliorations possibles :
        - Des points de vie max supplémentaires sont accordés
        - Les joueurs régénèrent des points de vies
        - Un bouclier est accordé, annulant la prochaine source de dégâts
        - La vitesse d'attaque des joueurs est augmentée
        - La vitesse des projectiles envoyés par les joueurs est augmentée
        - Les joueurs ont leur vitesse de déplacement augmentée
        - Les joueurs infligent plus de dégâts
        - Les joueurs gagnent un stack d'armure, réduisant tous les dégâts subis jusqu'à la fin de la partie par le nombre d'armures acquises
        - La taille des projectiles est aggrandie
        - Si l'un des joueurs est mort, il est possible de le réanimer avec 1 point de vie (avec pour contrainte qu'il est impossible de choisir un autre bonus à la place)
    - A chaque élimination, deux améliorations parmis toutes celles existantes sont proposées
    - Toutes ces améliorations continuent d'être proposées même si elles ont déjà été choisies. Il est donc par exemple possible de seulement choisir des boosts de vitesse si ils sont proposés, ou de seulement choisir d'augmenter la taille de ses projectiles jusqu'à ce qu'ils deviennent énormes.

## Fonctionnalités implémentées

### Fonctionnalités orientées physique

- **Wind system :**
    - Le système simule une courant d'air latéral puissant sur tout le terrain.
    Il ajoute de la difficulté au gameplay en rendant les déplacements des joueurs
    du nord au sud de la map peu pratiques. 

    - Concrètement, c'est un system de l'ECS qui, à chaque update, modifie le 
    vecteur position des entités sur lesquelles il agit, en y ajoutant un vecteur
    vent latéral. Lorsque l'entité ne se trouve pas au sol, le vecteur vent est
    deux fois plus fort qu'initialement. Le système prend effet dans une zone de
    vent préalablement définie. Le long d'une partie, le sens du vent alterne entre
    gauche-droite et droite-gauche.

    - Concernant le design du système, celui-ci est complètement générique et
    réutilisable : il est possible de créer des vents de gauche à droite, de haut en
    bas, etc. il est possible de travailler sur n'importe quelle zone de vent. 
    L'interface du système est simple à utiliser et tout prend effet comme voulu,
    sans devoir modifier l'essentiel de son implémentation. Nous avons cependant
    adapté son usage au cas de notre jeu : la zone de vent est fixée ainsi que la
    direction du vent.

- **Blocs surélevés :**
    - Les blocs surélevés simulent des murs que l'on peut franchir en sautant.

    - Ils sont implémentés au sein de la map et les contraintes physiques qu'ils
    imposent aux joueurs sont générées au travers d'une composante z_position
    représentant une hauteur.

    - Voir le design du système de génération et de rendu de la map pour plus
    d'informations.

- **Sauts des joueurs :**
    - Le saut d'un joueur nécessite de travailler sur deux axes : la hauteur du
    joueur, et l'animation du joueur. Lorsqu'un joueur saute, sa z_position est 
    augmentée de 1 durant un certain temps. Pour l'animation du joueur, sont 
    saut est divisée en deux phases : la première affiche une certaine texture,
    puis la seconde affiche une autre texture.

    - Pour pouvoir calculer la bonne texture à afficher, le système d'animation 
    doit connaitre la phase de l'animation et le sens du joueur concerné.
    L'algorithme fonctionne de la manière suivante : on extrait le vecteur
    vitesse v du joueur et la phase courante de l'animation du joueur, puis on
    sélectionne la texture correspondant à la prochaine phase et orientée selon v.

    - Nous avons fait le choix de ne pas rendre le système d'animation générique
    à cause des contraintes de temps sur le rendu et parce qu'il n'aurait été 
    utilisé que pour le saut des joueurs. Cependant, l'algorithme implémenté est
    n'est pas complexe et est réutilisable dans le cadre de notre jeu vidéo.

    - Voir le design du système de chargement et d'utilisation de textures pour
    plus d'informations.

- **Portails et téléportation**
    - Le jeu permet aux joueurs d'être téléportés lorsque certaines conditions
    sont réunies. Il faut que chaque joueur ait posé l'unique portail dont il
    dispose.

    - La pose d'un portail se passe ainsi : elle ne se fait que lorsque le joueur
    est au sol. Le second bloc devant lui est plus foncé que les autres blocs,
    il correspond à l'endroit ou le portail peut être posé. Le joueur pose alors
    le portail. Si l'autre joueur a aussi posé son portail et que l'un des deux
    tente de passer au dessus, il sera téléporté vers l'autre portail. Il en va de même si un projectile tiré par un joueur passe à travers un portail.

    - Le portail est une entité dont les composantes de forme sont copiées collées
    sur celles du bloc sur lequel il se trouve. La téléportation se fait dans la
    fonction resolve du système de collisions. Lorsqu'un joueur est téléporté, 
    nous avons fait en sorte que le sens du joueur soit conservé par la téléportation.
    S'il rentre à gauche, il ressortira à droite. Les cas limites sont également pris en compte : Si un joueur se téléporte vers une zone invalide (un mur), il n'est pas téléporté, ou du moins il ne bug pas dans un mur

    - Si un joueur a déjà posé son portail, il peut le déplacer autre part. 
    La composante position du portail déplacé est alors mise à jour et correspond
    nouvel endroit.

- **Tire de munitions :**
    - Le jeu permet de tirer des munitions de différentes tailles (infiniment grandes), différenciées par l'origine du tireur (allié vs ennemi, représenté par la couleur jaune vs violette) : une entité ne peut pas infliger de dégâts à un coéquipier.
    
    - Une munition est représentée par une entité simple qui disparait à la première collision, en réalisant une action suivant l'entité à laquelle elle est entrée en collision (Portail, joueur, ennemi)

### Fonctionnalités essentielles

- **Generation et rendu du terrain :** 
    - Le gestionnaire de terrains a été conçu pour que la création de terrains 
    soit rapide et intègre le plus d'informations possibles. En effet, le terrain
    est un élément essentiel du jeu vidéo.

    - Un terrain est implémenté sous forme d'une matrice d'entités map_pixeL.
    Les entités map_pixel disposent surtout d'un attribut level représentant le
    type de pixel qui nous intéresse (c'est implémenté par un type algébrique). 
    Elles comportent aussi une composante z_position permettant ainsi de représenter
    les blocs surélevés au sein de la map. Pour que la construction d'un terrain
    soit rapide, nous avons voulu rendre la structure sous-jacente persistante et
    nous avons implémenté plusieurs fonctions monadiques sur celle-ci, ainsi que
    des fonctions d'itération.

    - Le potentiel de la map n'est pas exploité au maximum dans notre jeu, le
    choix de la persistance de la structure aurait pu permettre de faire varier
    la forme de la map tout au long d'une partie. Cependant, son interface a 
    notamment permis d'implémenter une fonctionnalité auxiliaire intéressante :
    l'affichage en sombre d'un bloc ciblé pour poser un portail, devant chaque
    joueur. De plus, il est aisé de créer une map de A à Z en quelques lignes,
    sans devoir l'encoder en dur.

    - Nous aurions aussi voulu optimiser la structure sous-jacente pour éviter de
    trop itérer dessus. À notre niveau, cela n'affecte probablement pas les
    performances du jeu, mais ça aurait été un bon exercice d'optimisation...

- **Fonctionnement des augmentations**
    - Les améliorations/augments sont un système majeur du jeu, étant donné qu'il offre la rejouabilité et le fun dont un jeu de ce type a besoin, nous sommes d'ailleurs fier de ce que ce système fourni en terme de différences de gameplay d'une partie à l'autre. 

    - Les augments sont représentés par un type énuméré modulable très facilement afin d'en rajouter d'autres aisément. Lorsque les joueurs choisissent un augment, une fonction permet d'appliquer les effets du bonus aux deux joueurs, en modifiant leurs statistiques.
    
    - Ainsi, tous les fichiers ont du être modifiés de façon à ce que ces modifications soient prises en compte dans le déroulement des mouvements, des résolution d'impacts de balles, etc...
- **Fonctionnement des ennemis**
    - Les ennemies sont la raison d'être du jeu, dans le sens où le jeu n'aurait aucun intérêt sans

    - Un monstre est invoqué sur les bords de la carte (emplacement aléatoire) toutes les 6 secondes.

    - Pour des raisons de performance, les ennemis ne peuvent être que 5 maximums sur le terrain à la fois, cependant les joueurs font moins d'éliminations totales et choisissent moins d'augments si ils empêchent les ennemis de spawn, ce qui rend cette décision acceptable.
    
    - Toutes les 5 invocations, les prochains ennemis voient leurs statistiques améliorées (de la même façon que les joueurs peuvent améliorer leur propres statistiques et compétences) : la durée de la partie étant de 1 minute, les ennemis s'améliorent 5 à 6 fois par partie

    - Le but premier des ennemis étant de tuer les joueurs, ils analysent à chaque étape de jeu quel est le joueur le plus proche, afin de calculer leur nouvelle direction, et vers où ils vont tirer.
    
    - Si un ennemi arrive sur un joueur et rentre en collision avec lui, il lui infligera des dégâts périodiquement (toutes les 2 ou 3 secondes), forçant le joueur à fuir ou se mettre en hauteur sur des rochers.