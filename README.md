# Projet Programmation Fonctionnelle Avancée

## Propriétés générales

- Rogue-like coop
- Deux joueurs
- Vue de face et **d'en haut** (à voir)

## Résumé scénario

Jones et Peter, deux apprentis magiciens, sont partis à l'aventure pour retrouver
l'Arkenstone, un précieux artéfact découvert par le peuple des nains plusieurs
centenaires auparavant. Il parcoureront les grandes mines de la Moria, combattront 
Orques, Gobelins et tant de créatures qui vous n'oseriez imaginer. Les deux compagnons
pourront-ils compter l'un sur l'autre dans cette quête pour l'Arkenstone.

## Gameplay

Les différents étages des mines de la Moria sont généré aléatoirement. Chaque étage
se finit par un boss aléatoire. Une fois battu, avant de passer à l'étage inférieur,
les deux joueurs pourront choisir parmi un certain nombre d'améliorations existantes.

À la fin, les deux joueurs doivent combattre entre eux pour qu'il n'y ait qu'un
survivant.

Un étage est composé de plusieurs salles. Dans chaque salle, il faut résoudre un
mini-défi et/ou faire face à des ennemis. Lorsque le travail est terminé dans une
salle, une porte se révèle pour donner accès à une nouvelle salle.

Lorsque le boss est tué, on passe à un étage inférieur.

Un peu avant de combat fratricide, l'écran se sépare en deux car ils ne sont pas d'accord,
chaque joueur doit descendre individuellement et ceux-ci se rejoignent finalement
dans la salle du combat PVP.

## Fonctionnalités implémentées

### Fonctionnélités orientées physique

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
    tente de passer au dessus, il sera téléporté vers l'autre portail.

    - Le portail est une entité dont les composantes de forme sont copiées collées
    sur celles du bloc sur lequel il se trouve. La téléportation se fait dans la
    fonction resolve du système de collisions. Lorsqu'un joueur est téléporté, 
    nous avons fait en sorte que le sens du joueur soit conservé par la téléportation.
    S'il rentre à gauche, il ressortira à droite.

    - Si un joueur a déjà posé son portail, il peut le déplacer autre part. 
    La composante position du portail déplacé est alors mise à jour et correspond
    nouvel endroit.

- **Tire de munitions :**
    - **TODO**

- **Autre ?**

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

