#!/bin/bash
#On définit les paramètres par défaut correspondant à chaque options
dp=""
hp=""
sp=""
rp=""
fp=""
ap=" --exclude='*/.*'" #On cache par défaut les fichiers secrets
op=""
gras=$(tput bold) # Commande pour écrire en gras
classique=$(tput sgr0) # Commande pour remettre le texte normalement

while getopts ":d:hsr:fao:" opt; do #On vérifie la présence des différentes options dont certaines avec un besoin d'argument
	case $opt in #En fonction de ce que l'on reçoit :
	  d)
		dp=" $OPTARG/" #On récupère le dossier passé en paramètre avec l'option -d
		;;
	  h)
		hp=" -h" #On effectue un affichage plus lisible (avec les tailles en Ko, Mo, Go)
		;;
	  s)
		sp=" | sort -hr" #On trie par ordre décroissant d'espace utilisé
		;;
	  r)
		rp=" | grep -E $OPTARG" #On permet de rechercher une expression régulière
		;;
	  f)
		fp=" -a" # On affiche les fichiers 
		;;
	  a)
		ap=" -a" # On affiche les fichiers et en redéfinissant la variable ap on permet l'affichage des dossiers secrets
		;;
	  o)
		echo "Commande utilisée : Projet.sh ${*} à $(date +'%T') le $(date +'%d/%m/%Y')" > $OPTARG #On écrit la commande effectuée par l'utilisateur, l heure et la date dans le fichier passé en paramètres, si il n existe pas, il est créé par défaut
		op=" >> $OPTARG" #On rajoute l'option pour écrire la sortie de notre commande dans le fichier passé en paramètre
		;;
	 \?)
		echo "Mauvaise option: -$OPTARG" #Si une option qui n existe est utilisé, on affiche l erreur et on quitte le script
		exit 1
		;;
	 :)
		echo "l'option -$OPTARG nécessite un argument" # Si une option qui a besoin d un argument n a pas d argument on envoi un message d erreur et on quitte le script
		exit 1
		;;
	esac
done

echo "${gras}Folder	Size${classique}" # On prépare l'affichage de la commande en écrivant en gras File et Size
cmd="du $fp$dp$hp$ap --max-depth=1$rp$sp$op 2>> erreurs.log" #On stocke la commande sous forme de chaine de caractères et on stock les erreurs dans un fichier log
eval $cmd # On exécute la commande

Check=$? # On récupère le statut de sortie de la dernière commande
if [ $Check -eq 0 ]; then # Si on ne détecte pas d'erreur 
	echo "Pas d'erreur détectée"
else	# Si on détecte un erreur
	echo "${gras}Une ou plusieurs erreurs ont été détectées, veuillez vérifier erreurs.log${classique}" # On informe que l'on a détecté une erreur
	if [ rp != "" ]; then
		echo "Aucun dossier ou fichier semblable à votre expression régulière" >> erreurs.log # Si il s'agit d'un problème au niveau de l'expression réguliere on l'ajoute au compte rendu
	fi
	echo "Commande utilisée : Projet.sh ${*} à $(date +'%T') le $(date +'%d/%m/%Y')" >> erreurs.log #On écrit un compte rendu de la commande effectuée par l'utilisateur avec l heure et la date dans les logs
	echo "" >> erreurs.log
fi
