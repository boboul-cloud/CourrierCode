// === COURRIER CODÉ ===
// Application d'écriture codée : A=01, B=02... Z=26, 0=27... 9=36
// Avec mode sécurisé : décalage variable selon le jour de la semaine

// === SYSTÈME DE DÉCALAGE PAR JOUR ===
// Chaque jour a un décalage unique pour rendre le décodage impossible sans connaître le jour
const DECALAGES_JOURS = {
    0: 7,   // Dimanche : +7
    1: 3,   // Lundi : +3
    2: 11,  // Mardi : +11
    3: 5,   // Mercredi : +5
    4: 9,   // Jeudi : +9
    5: 2,   // Vendredi : +2
    6: 13   // Samedi : +13
};

const NOMS_JOURS = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];

function getDecalageJour(jour = null) {
    if (jour === null) {
        jour = new Date().getDay();
    }
    return DECALAGES_JOURS[jour];
}

function getJourActuel() {
    return new Date().getDay();
}

// Fonction pour supprimer les accents
function supprimerAccents(texte) {
    const accents = {
        'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'æ': 'ae',
        'ç': 'c',
        'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
        'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
        'ñ': 'n',
        'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'œ': 'oe',
        'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
        'ý': 'y', 'ÿ': 'y',
        'À': 'A', 'Á': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A', 'Å': 'A', 'Æ': 'AE',
        'Ç': 'C',
        'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E',
        'Ì': 'I', 'Í': 'I', 'Î': 'I', 'Ï': 'I',
        'Ñ': 'N',
        'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö': 'O', 'Ø': 'O', 'Œ': 'OE',
        'Ù': 'U', 'Ú': 'U', 'Û': 'U', 'Ü': 'U',
        'Ý': 'Y', 'Ÿ': 'Y'
    };
    
    return texte.split('').map(char => accents[char] || char).join('');
}

// Éléments du DOM
const texteOriginal = document.getElementById('texteOriginal');
const resultatCode = document.getElementById('resultatCode');
const resultatInverse = document.getElementById('resultatInverse');
const texteCrypte = document.getElementById('texteCrypte');
const resultatDecode = document.getElementById('resultatDecode');

const btnInverser = document.getElementById('btnInverser');
const btnCopier = document.getElementById('btnCopier');
const btnEffacer = document.getElementById('btnEffacer');
const btnDecoder = document.getElementById('btnDecoder');
const btnDecoderInverse = document.getElementById('btnDecoderInverse');
const btnEffacerDecodeur = document.getElementById('btnEffacerDecodeur');
const btnColler = document.getElementById('btnColler');
const btnDecoderSmart = document.getElementById('btnDecoderSmart');

// Éléments du mode jour
const modeJour = document.getElementById('modeJour');
const modeJourDecode = document.getElementById('modeJourDecode');
const jourActuelDiv = document.getElementById('jourActuel');
const jourDecodeSelect = document.getElementById('jourDecode');

// Éléments du mode mélange
const modeMelange = document.getElementById('modeMelange');
const melangeBox = document.getElementById('melangeBox');
const resultatMelange = document.getElementById('resultatMelange');
const btnRemelanger = document.getElementById('btnRemelanger');
const btnCopierMelange = document.getElementById('btnCopierMelange');

// Afficher le jour actuel
function afficherJourActuel() {
    const jour = getJourActuel();
    const nomJour = NOMS_JOURS[jour];
    const decalage = DECALAGES_JOURS[jour];
    jourActuelDiv.textContent = `${nomJour} (décalage: +${decalage})`;
}

// Fonction pour mélanger un tableau (Fisher-Yates shuffle)
function melangerTableau(tableau) {
    const copie = [...tableau];
    for (let i = copie.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [copie[i], copie[j]] = [copie[j], copie[i]];
    }
    return copie;
}

// Fonction pour mélanger les mots d'un texte
function melangerMots(texte) {
    if (!texte || texte.trim() === '') return '';
    
    // Séparer le texte en mots (en gardant la ponctuation attachée)
    const mots = texte.trim().split(/\s+/);
    
    if (mots.length <= 1) return texte;
    
    // Mélanger les mots
    const motsMelanges = melangerTableau(mots);
    
    return motsMelanges.join(' ');
}

// Afficher les mots mélangés
function afficherMotsMelanges() {
    const texte = texteOriginal.value;
    if (modeMelange.checked && texte.trim() !== '') {
        melangeBox.style.display = 'block';
        const melange = melangerMots(texte);
        resultatMelange.textContent = melange;
        resultatMelange.classList.add('updated');
        setTimeout(() => resultatMelange.classList.remove('updated'), 300);
    } else {
        melangeBox.style.display = 'none';
        resultatMelange.textContent = '';
    }
}

// Initialiser l'affichage du jour
afficherJourActuel();

// === DICTIONNAIRE FRANÇAIS ENRICHI ===
const DICTIONNAIRE = new Set([
    // Articles et déterminants
    "le", "la", "les", "un", "une", "des", "du", "de", "au", "aux", "l",
    "ce", "cet", "cette", "ces", "mon", "ma", "mes", "ton", "ta", "tes", 
    "son", "sa", "ses", "notre", "nos", "votre", "vos", "leur", "leurs",
    "quel", "quelle", "quels", "quelles", "tout", "tous", "toute", "toutes",
    
    // Pronoms
    "je", "tu", "il", "elle", "on", "nous", "vous", "ils", "elles",
    "me", "te", "se", "lui", "eux", "moi", "toi", "soi", "y", "en",
    "qui", "que", "quoi", "dont", "ou", "lequel", "laquelle", "lesquels",
    "celui", "celle", "ceux", "celles", "ceci", "cela", "ca",
    
    // Conjonctions et prépositions
    "et", "ou", "mais", "donc", "or", "ni", "car", "si", "que", "quand",
    "comme", "pour", "dans", "sur", "sous", "avec", "sans", "chez", "vers",
    "entre", "par", "contre", "depuis", "pendant", "avant", "apres", "jusque",
    "selon", "malgre", "sauf", "hors", "des", "lors", "pres", "loin",
    
    // Adverbes
    "ne", "pas", "plus", "moins", "jamais", "toujours", "souvent", "parfois",
    "bien", "mal", "mieux", "pire", "tres", "trop", "assez", "peu", "beaucoup",
    "encore", "deja", "aussi", "ainsi", "alors", "ensuite", "enfin", "puis",
    "ici", "la", "ou", "partout", "ailleurs", "dedans", "dehors", "dessus", "dessous",
    "maintenant", "hier", "demain", "aujourdhui", "autrefois", "bientot",
    "comment", "pourquoi", "combien", "vraiment", "seulement", "peut", "etre",
    "oui", "non", "si", "certes", "evidemment", "certainement", "probablement",
    
    // Verbes être et avoir (conjugaisons)
    "suis", "es", "est", "sommes", "etes", "sont", "etais", "etait", "etions",
    "etiez", "etaient", "fus", "fut", "fumes", "futes", "furent", "serai",
    "seras", "sera", "serons", "serez", "seront", "serais", "serait", "serions",
    "seriez", "seraient", "sois", "soit", "soyons", "soyez", "soient", "ete",
    "ai", "as", "a", "avons", "avez", "ont", "avais", "avait", "avions",
    "aviez", "avaient", "eus", "eut", "eumes", "eutes", "eurent", "aurai",
    "auras", "aura", "aurons", "aurez", "auront", "aurais", "aurait", "aurions",
    "auriez", "auraient", "aie", "aies", "ait", "ayons", "ayez", "aient", "eu",
    
    // Verbes courants infinitifs
    "etre", "avoir", "faire", "aller", "venir", "voir", "pouvoir", "vouloir",
    "devoir", "savoir", "falloir", "dire", "donner", "prendre", "partir",
    "sortir", "mettre", "lire", "ecrire", "croire", "connaitre", "paraitre",
    "vivre", "suivre", "tenir", "comprendre", "apprendre", "rendre", "attendre",
    "entendre", "repondre", "perdre", "permettre", "recevoir", "sentir", "servir",
    "rester", "passer", "trouver", "chercher", "donner", "parler", "aimer",
    "penser", "croire", "sembler", "laisser", "tomber", "montrer", "commencer",
    "jouer", "appeler", "porter", "demander", "garder", "regarder", "ecouter",
    "continuer", "manger", "marcher", "courir", "dormir", "ouvrir", "fermer",
    
    // Verbes conjugués courants
    "fait", "fais", "font", "faisons", "faites", "faisait", "fera", "ferait",
    "va", "vais", "vas", "vont", "allons", "allez", "allait", "ira", "irait",
    "viens", "vient", "venons", "venez", "viennent", "venait", "viendra",
    "vois", "voit", "voyons", "voyez", "voient", "voyait", "verra", "verrait",
    "peux", "peut", "pouvons", "pouvez", "peuvent", "pouvait", "pourra", "pourrait",
    "veux", "veut", "voulons", "voulez", "veulent", "voulait", "voudra", "voudrait",
    "dois", "doit", "devons", "devez", "doivent", "devait", "devra", "devrait",
    "sais", "sait", "savons", "savez", "savent", "savait", "saura", "saurait",
    "dit", "dis", "disons", "dites", "disent", "disait", "dira", "dirait",
    "prend", "prends", "prenons", "prenez", "prennent", "prenait", "prendra",
    "met", "mets", "mettons", "mettez", "mettent", "mettait", "mettra",
    "lit", "lis", "lisons", "lisez", "lisent", "lisait", "lira",
    "ecrit", "ecris", "ecrivons", "ecrivez", "ecrivent", "ecrivait", "ecrira",
    "croit", "crois", "croyons", "croyez", "croient", "croyait", "croira",
    "connait", "connais", "connaissons", "connaissez", "connaissent",
    "tient", "tiens", "tenons", "tenez", "tiennent", "tenait", "tiendra",
    "comprend", "comprends", "comprenons", "comprenez", "comprennent",
    "attend", "attends", "attendons", "attendez", "attendent", "attendait",
    "entend", "entends", "entendons", "entendez", "entendent",
    "repond", "reponds", "repondons", "repondez", "repondent",
    "reste", "restes", "restons", "restez", "restent", "restait", "restera",
    "passe", "passes", "passons", "passez", "passent", "passait", "passera",
    "trouve", "trouves", "trouvons", "trouvez", "trouvent", "trouvait",
    "cherche", "cherches", "cherchons", "cherchez", "cherchent",
    "donne", "donnes", "donnons", "donnez", "donnent", "donnait",
    "parle", "parles", "parlons", "parlez", "parlent", "parlait",
    "aime", "aimes", "aimons", "aimez", "aiment", "aimait", "aimera",
    "pense", "penses", "pensons", "pensez", "pensent", "pensait",
    "semble", "sembles", "semblons", "semblez", "semblent",
    "laisse", "laisses", "laissons", "laissez", "laissent",
    "tombe", "tombes", "tombons", "tombez", "tombent",
    "montre", "montres", "montrons", "montrez", "montrent",
    "commence", "commences", "commencons", "commencez", "commencent",
    "joue", "joues", "jouons", "jouez", "jouent",
    "appelle", "appelles", "appelons", "appelez", "appellent",
    "porte", "portes", "portons", "portez", "portent",
    "demande", "demandes", "demandons", "demandez", "demandent",
    "garde", "gardes", "gardons", "gardez", "gardent",
    "regarde", "regardes", "regardons", "regardez", "regardent",
    "ecoute", "ecoutes", "ecoutons", "ecoutez", "ecoutent",
    "continue", "continues", "continuons", "continuez", "continuent",
    "mange", "manges", "mangeons", "mangez", "mangent",
    "marche", "marches", "marchons", "marchez", "marchent",
    "court", "cours", "courons", "courez", "courent",
    "dort", "dors", "dormons", "dormez", "dorment",
    "ouvre", "ouvres", "ouvrons", "ouvrez", "ouvrent",
    "ferme", "fermes", "fermons", "fermez", "ferment",
    
    // Noms communs - temps
    "temps", "jour", "jours", "nuit", "nuits", "matin", "matins", "soir", "soirs",
    "heure", "heures", "minute", "minutes", "seconde", "secondes", "moment", "moments",
    "semaine", "semaines", "mois", "annee", "annees", "an", "ans", "siecle",
    "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche",
    "janvier", "fevrier", "mars", "avril", "mai", "juin", "juillet", "aout",
    "septembre", "octobre", "novembre", "decembre", "printemps", "ete", "automne", "hiver",
    
    // Noms communs - personnes
    "homme", "hommes", "femme", "femmes", "enfant", "enfants", "fille", "filles",
    "garcon", "garcons", "bebe", "bebes", "personne", "personnes", "gens",
    "pere", "mere", "parents", "frere", "soeur", "famille", "familles",
    "ami", "amie", "amis", "amies", "copain", "copine", "voisin", "voisine",
    "monsieur", "madame", "mademoiselle", "maitre", "maitresse",
    "docteur", "professeur", "eleve", "etudiant", "etudiante",
    
    // Noms communs - lieux
    "lieu", "lieux", "endroit", "endroits", "place", "places", "coin",
    "maison", "maisons", "appartement", "chambre", "chambres", "piece", "pieces",
    "cuisine", "salon", "salle", "bureau", "bureaux", "jardin", "jardins",
    "ville", "villes", "village", "villages", "quartier", "rue", "rues",
    "avenue", "boulevard", "route", "routes", "chemin", "chemins",
    "pays", "region", "departement", "france", "paris", "europe", "monde",
    "ecole", "ecoles", "college", "lycee", "universite", "classe", "classes",
    "hopital", "pharmacie", "magasin", "magasins", "boutique", "marche",
    "restaurant", "cafe", "hotel", "gare", "aeroport", "port",
    "mer", "mers", "ocean", "plage", "ile", "montagne", "montagnes",
    "foret", "forets", "campagne", "champ", "champs", "riviere", "fleuve", "lac",
    
    // Noms communs - objets
    "chose", "choses", "objet", "objets", "truc", "trucs", "machin",
    "porte", "portes", "fenetre", "fenetres", "mur", "murs", "sol", "plafond",
    "table", "tables", "chaise", "chaises", "lit", "lits", "armoire",
    "livre", "livres", "page", "pages", "cahier", "cahiers", "stylo", "crayon",
    "lettre", "lettres", "mot", "mots", "phrase", "texte", "message", "messages",
    "papier", "papiers", "carte", "cartes", "photo", "photos", "image", "images",
    "telephone", "ordinateur", "ecran", "clavier", "souris",
    "voiture", "voitures", "velo", "velos", "bus", "train", "avion", "bateau",
    "cle", "cles", "clef", "clefs", "sac", "sacs", "boite", "valise",
    "argent", "euros", "billet", "billets", "piece", "pieces", "monnaie",
    
    // Noms communs - corps
    "corps", "tete", "visage", "yeux", "oeil", "nez", "bouche", "oreille", "oreilles",
    "cheveux", "front", "joue", "joues", "menton", "cou", "epaule", "epaules",
    "bras", "main", "mains", "doigt", "doigts", "ongle", "ongles",
    "jambe", "jambes", "pied", "pieds", "genou", "genoux", "ventre", "dos",
    "coeur", "sang", "os", "peau", "muscle", "muscles",
    
    // Noms communs - nature/animaux
    "nature", "terre", "ciel", "soleil", "lune", "etoile", "etoiles",
    "air", "eau", "feu", "vent", "pluie", "neige", "nuage", "nuages",
    "arbre", "arbres", "fleur", "fleurs", "plante", "plantes", "herbe", "feuille",
    "animal", "animaux", "chien", "chiens", "chat", "chats", "oiseau", "oiseaux",
    "poisson", "poissons", "cheval", "chevaux", "vache", "mouton", "cochon",
    
    // Noms communs - nourriture
    "nourriture", "repas", "petit", "dejeuner", "diner", "gouter",
    "pain", "beurre", "fromage", "lait", "oeuf", "oeufs", "viande", "poisson",
    "legume", "legumes", "fruit", "fruits", "pomme", "orange", "banane",
    "salade", "soupe", "riz", "pates", "pizza", "sandwich", "gateau",
    "chocolat", "sucre", "sel", "cafe", "the", "jus", "vin", "biere",
    
    // Noms communs - abstraits
    "vie", "mort", "amour", "haine", "joie", "tristesse", "peur", "colere",
    "bonheur", "malheur", "chance", "courage", "force", "faiblesse",
    "idee", "idees", "pensee", "pensees", "reve", "reves", "espoir", "espoirs",
    "verite", "mensonge", "secret", "secrets", "mystere", "mysteres",
    "probleme", "problemes", "solution", "solutions", "question", "questions",
    "reponse", "reponses", "raison", "raisons", "cause", "causes",
    "travail", "travaux", "projet", "projets", "plan", "plans",
    "histoire", "histoires", "conte", "contes", "recit", "roman",
    "art", "musique", "chanson", "film", "cinema", "theatre", "danse",
    "sport", "jeu", "jeux", "match", "equipe", "joueur", "joueurs",
    
    // Adjectifs courants
    "bon", "bonne", "bons", "bonnes", "mauvais", "mauvaise",
    "grand", "grande", "grands", "grandes", "petit", "petite", "petits", "petites",
    "gros", "grosse", "mince", "long", "longue", "court", "courte",
    "haut", "haute", "bas", "basse", "large", "etroit", "etroite",
    "vieux", "vieille", "vieilles", "jeune", "jeunes", "nouveau", "nouvelle", "nouveaux",
    "beau", "belle", "beaux", "belles", "joli", "jolie", "jolis", "jolies",
    "blanc", "blanche", "blancs", "blanches", "noir", "noire", "noirs", "noires",
    "rouge", "rouges", "bleu", "bleue", "bleus", "bleues", "vert", "verte",
    "jaune", "jaunes", "orange", "rose", "roses", "violet", "violette",
    "gris", "grise", "marron", "beige", "dore", "argente",
    "chaud", "chaude", "froid", "froide", "sec", "seche", "humide",
    "dur", "dure", "mou", "molle", "doux", "douce", "lisse", "rugueux",
    "lourd", "lourde", "leger", "legere", "plein", "pleine", "vide",
    "ouvert", "ouverte", "ouverts", "ouvertes", "ferme", "fermee",
    "propre", "propres", "sale", "sales", "neuf", "neuve", "use",
    "facile", "faciles", "difficile", "difficiles", "simple", "simples",
    "rapide", "rapides", "lent", "lente", "lents", "lentes",
    "fort", "forte", "forts", "fortes", "faible", "faibles",
    "riche", "riches", "pauvre", "pauvres", "cher", "chere",
    "content", "contente", "contents", "contentes", "heureux", "heureuse",
    "triste", "tristes", "fache", "fachee", "inquiet", "inquiete",
    "fatigue", "fatiguee", "malade", "malades", "pret", "prete",
    "seul", "seule", "seuls", "seules", "ensemble", "different", "differente",
    "meme", "memes", "autre", "autres", "premier", "premiere", "dernier", "derniere",
    "prochain", "prochaine", "suivant", "suivante", "precedent", "precedente",
    "certain", "certaine", "certains", "certaines", "quelques", "plusieurs",
    "vrai", "vraie", "vrais", "vraies", "faux", "fausse",
    "possible", "impossible", "necessaire", "important", "importante",
    "special", "speciale", "normal", "normale", "naturel", "naturelle",
    "public", "publique", "prive", "privee", "libre", "libres",
    
    // Nombres en lettres
    "zero", "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf",
    "dix", "onze", "douze", "treize", "quatorze", "quinze", "seize",
    "vingt", "trente", "quarante", "cinquante", "soixante",
    "cent", "cents", "mille", "million", "millions", "milliard",
    
    // Mots pour messages secrets
    "rendez", "vous", "rendezvous", "code", "codes", "cle", "cles", "clef",
    "secret", "secrets", "cache", "caches", "cachee", "cachees",
    "tresor", "tresors", "indice", "indices", "piste", "pistes",
    "mission", "missions", "objectif", "objectifs", "cible", "cibles",
    "attention", "danger", "dangers", "urgent", "urgente", "urgents",
    "important", "importante", "importants", "importantes",
    "confidentiel", "confidentiels", "prive", "privee", "prives",
    "nord", "sud", "est", "ouest", "droite", "gauche", "haut", "bas",
    "devant", "derriere", "dessus", "dessous", "entre", "milieu", "centre",
    "numero", "numeros", "adresse", "adresses", "contact", "contacts",
    "signal", "signaux", "signe", "signes", "marque", "marques",
    "retrouve", "retrouves", "retrouver", "rejoindre", "rejoins",
    
    // Mots du message test (dictionnaire/algorithme)
    "dictionnaire", "dictionnaires", "contient", "mots", "francais", "courant", "courants",
    "utilise", "utilises", "utiliser", "algorithme", "algorithmes", "meilleur", "meilleure", "meilleurs",
    "facon", "maniere", "decouper", "decoupe", "texte", "textes",
    "reconnaissable", "reconnaissables", "reconnu", "reconnue",
    
    // Verbes en -er infinitifs courants
    "ameliorer", "analyser", "annoncer", "arreter", "arriver", "assurer",
    "augmenter", "avancer", "cacher", "calculer", "changer", "chanter",
    "charger", "chercher", "cliquer", "coder", "coller", "commander",
    "comparer", "completer", "composer", "compter", "concentrer", "confirmer",
    "connaitre", "considerer", "construire", "contacter", "contenir", "continuer",
    "controler", "copier", "corriger", "couper", "creer", "decider", "decoder",
    "decouvrir", "definir", "demander", "demarrer", "deplacer", "deposer",
    "designer", "desirer", "dessiner", "determiner", "developper", "diminuer",
    "diriger", "discuter", "disposer", "diviser", "documenter", "effectuer",
    "elaborer", "eliminer", "employer", "encourager", "engager", "enseigner",
    "enregistrer", "entrer", "envoyer", "essayer", "etablir", "etudier",
    "evaluer", "eviter", "executer", "exister", "expliquer", "exprimer",
    "fabriquer", "faciliter", "fermer", "finir", "fonctionner", "former",
    "fournir", "gagner", "generer", "gerer", "identifier", "ignorer",
    "illustrer", "imaginer", "importer", "imposer", "inclure", "indiquer",
    "informer", "installer", "integrer", "interesser", "interpreter", "introduire",
    "inventer", "inviter", "joindre", "juger", "justifier", "lancer",
    "lever", "liberer", "limiter", "localiser", "maintenir", "manipuler",
    "marquer", "melanger", "memoriser", "mener", "mesurer", "modifier",
    "montrer", "multiplier", "noter", "obtenir", "occuper", "offrir",
    "operer", "optimiser", "organiser", "oublier", "partager", "participer",
    "payer", "permettre", "personnaliser", "placer", "planifier", "posseder",
    "poursuivre", "pousser", "preciser", "preferer", "preparer", "presenter",
    "preserver", "prevenir", "prevoir", "prier", "produire", "programmer",
    "progresser", "projeter", "promettre", "proposer", "proteger", "prouver",
    "publier", "quitter", "raconter", "rappeler", "realiser", "recevoir",
    "rechercher", "recommander", "reconnaitre", "recuperer", "reduire", "reflechir",
    "refuser", "regretter", "rejoindre", "remarquer", "remercier", "remplacer",
    "remplir", "rencontrer", "rendre", "renouveler", "renseigner", "rentrer",
    "reparer", "repeter", "repondre", "representer", "reproduire", "resoudre",
    "respecter", "ressembler", "rester", "retenir", "retirer", "retrouver",
    "reunir", "reussir", "reveler", "revenir", "risquer", "rouler",
    "sauver", "selectionner", "separer", "signaler", "signifier", "simplifier",
    "situer", "soigner", "songer", "sortir", "souhaiter", "souligner",
    "soumettre", "soutenir", "suffire", "suggerer", "suivre", "supporter",
    "supprimer", "surveiller", "tenter", "terminer", "tester", "tirer",
    "toucher", "tourner", "traiter", "transformer", "transmettre", "transporter",
    "travailler", "traverser", "trouver", "tuer", "utiliser", "valider",
    "verifier", "viser", "visiter", "vivre", "voir", "voler",
    
    // Adverbes courants
    "absolument", "actuellement", "apparemment", "automatiquement", "certainement",
    "clairement", "completement", "constamment", "correctement", "directement",
    "doucement", "egalement", "enormement", "entierement", "environ",
    "essentiellement", "evidemment", "exactement", "extremement", "facilement",
    "finalement", "forcement", "fortement", "frequemment", "generalement",
    "gentiment", "globalement", "grandement", "habituellement", "heureusement",
    "immediatement", "independamment", "instantanement", "intelligemment",
    "justement", "largement", "legerement", "lentement", "librement",
    "longtemps", "lourdement", "maintenant", "malheureusement", "manifestement",
    "naturellement", "necessairement", "normalement", "notamment", "nouvellement",
    "nullement", "obligatoirement", "officiellement", "originalement", "parfaitement",
    "partiellement", "particulierement", "personnellement", "pleinement", "precisement",
    "premierement", "presque", "principalement", "probablement", "profondement",
    "progressivement", "proprement", "purement", "rapidement", "rarement",
    "reellement", "recemment", "regulierement", "relativement", "remarquablement",
    "sagement", "salement", "secondement", "sensiblement", "separement",
    "serieusement", "settlement", "significativement", "simplement", "sincerement",
    "soigneusement", "solidement", "specialement", "strictement", "subitement",
    "suffisamment", "suivant", "superieurement", "supplement", "supremement",
    "surement", "tellement", "temporairement", "totalement", "tranquillement",
    "tristement", "typiquement", "ultimement", "uniquement", "universellement",
    "utilement", "vaguement", "vigoureusement", "vivement", "volontairement",
    "vraiment",
    
    // Adjectifs manquants
    "complet", "complete", "complets", "completes", "intelligent", "intelligente",
    "significatif", "significative", "significatifs", "significatives",
    "automatique", "automatiques", "numerique", "numeriques", "informatique",
    
    // Noms techniques
    "decodeur", "decodeurs", "encodeur", "encodeurs", "codage", "decodage",
    "programme", "programmes", "logiciel", "logiciels", "application", "applications",
    "systeme", "systemes", "ordinateur", "ordinateurs", "internet", "site", "sites",
    "fichier", "fichiers", "dossier", "dossiers", "donnee", "donnees",
    "information", "informations", "fonction", "fonctions", "option", "options",
    "bouton", "boutons", "menu", "menus", "interface", "interfaces",
    
    // Mots manquants fréquents
    "prefere", "preferes", "preferent", "preferons", "preferez", "preferer",
    "plutot", "reconnaitre", "reconnaissons", "reconnaissez", "reconnaissent",
    "inconnu", "inconnue", "inconnus", "inconnues", "connu", "connue", "connus", "connues",
    "grand", "grands", "grande", "grandes", "petit", "petits", "petite", "petites",
    "mot", "mots", "lettre", "lettres", "chiffre", "chiffres", "nombre", "nombres",
    "alors", "donc", "ainsi", "ensuite", "enfin", "puis", "apres", "avant",
    "que", "qui", "quoi", "dont", "ou", "quand", "comment", "pourquoi",
    "car", "parce", "puisque", "lorsque", "comme", "si", "sinon",
    "aucun", "aucune", "aucuns", "aucunes", "nul", "nulle", "nuls", "nulles",
    "chaque", "quelque", "quelques", "plusieurs", "certain", "certains", "certaine", "certaines",
    "tel", "telle", "tels", "telles", "meme", "memes",
    "peu", "beaucoup", "trop", "assez", "moins", "plus", "tres", "bien", "mal",
    "toujours", "jamais", "souvent", "parfois", "rarement", "encore", "deja",
    "ici", "la", "ou", "partout", "ailleurs", "loin", "pres", "proche",
    "haut", "bas", "dessus", "dessous", "devant", "derriere", "entre", "parmi",
    
    // Mots avec apostrophe (collés)
    "jai", "jai", "tas", "tas", "la", "las", "nas", "nai",
    "cest", "sest", "mest", "test", "lest",
    "quil", "quelle", "quon", "quoi",
    "dun", "dune", "dautre", "dautres", "dici", "daccord",
    "lautre", "lun", "lune", "lautre",
    "jusqua", "jusquau", "jusquici", "jusquou",
    "quelquun", "quelquune", "quelquechose",
    "aujourdhui", "peutetre", "bientot", "plutot",
    "nimporte", "naurait", "naurais", "navait", "navais", "naura", "naurai",
    "jaime", "jadore", "jattends", "jarrive", "jespere", "jirai", "jirais",
    "taime", "tattends", "tarrive",
    "sil", "quil", "quils", "quelle", "quelles",
    
    // Verbes conjugués courants (participes passés)
    "casse", "casses", "cassee", "cassees", "casser", "cassait", "cassera",
    "mange", "manges", "mangee", "mangees", "manger", "mangeait", "mangera",
    "achete", "achetes", "achetee", "achetees", "acheter", "achetait",
    "appele", "appeles", "appelee", "appelees", "appeler", "appelait",
    "arrive", "arrives", "arrivee", "arrivees", "arriver", "arrivait",
    "demande", "demandes", "demandee", "demandees", "demander", "demandait",
    "donne", "donnes", "donnee", "donnees", "donner", "donnait", "donnera",
    "entre", "entres", "entree", "entrees", "entrer", "entrait",
    "envoye", "envoyes", "envoyee", "envoyees", "envoyer", "envoyait",
    "ferme", "fermes", "fermee", "fermees", "fermer", "fermait",
    "laisse", "laisses", "laissee", "laissees", "laisser", "laissait",
    "oublie", "oublies", "oubliee", "oubliees", "oublier", "oubliait",
    "passe", "passes", "passee", "passees", "passer", "passait", "passera",
    "perdu", "perdus", "perdue", "perdues", "perdre", "perdait",
    "pose", "poses", "posee", "posees", "poser", "posait",
    "pris", "prise", "prises", "prendre", "prenait",
    "range", "ranges", "rangee", "rangees", "ranger", "rangeait",
    "rate", "rates", "ratee", "ratees", "rater", "ratait",
    "repare", "repares", "reparee", "reparees", "reparer", "reparait",
    "tombe", "tombes", "tombee", "tombees", "tomber", "tombait",
    "touche", "touches", "touchee", "touchees", "toucher", "touchait",
    "trouve", "trouves", "trouvee", "trouvees", "trouver", "trouvait",
    "vu", "vue", "vus", "vues", "voir", "voyait",
    "mis", "mise", "mises", "mettre", "mettait",
    "dit", "dite", "dites", "dire", "disait",
    "fait", "faite", "faits", "faites", "faire", "faisait",
    "eu", "eue", "eus", "eues", "avoir", "avait",
    "ete", "etre", "etait",
    "alle", "alles", "allee", "allees", "aller", "allait",
    "venu", "venus", "venue", "venues", "venir", "venait",
    "sorti", "sortis", "sortie", "sorties", "sortir", "sortait",
    "parti", "partis", "partie", "parties", "partir", "partait",
    "rentre", "rentres", "rentree", "rentrees", "rentrer", "rentrait",
    "reste", "restes", "restee", "restees", "rester", "restait",
    "monte", "montes", "montee", "montees", "monter", "montait",
    "descendu", "descendus", "descendue", "descendues", "descendre",
    "tenu", "tenus", "tenue", "tenues", "tenir", "tenait",
    "voulu", "voulus", "voulue", "voulues", "vouloir", "voulait",
    "pu", "pouvoir", "pouvait",
    "su", "savoir", "savait",
    "du", "dus", "due", "dues", "devoir", "devait",
    "recu", "recus", "recue", "recues", "recevoir", "recevait",
    "lu", "lus", "lue", "lues", "lire", "lisait",
    "ecrit", "ecrits", "ecrite", "ecrites", "ecrire", "ecrivait",
    "ouvert", "ouverts", "ouverte", "ouvertes", "ouvrir", "ouvrait",
    "offert", "offerts", "offerte", "offertes", "offrir", "offrait",
    "decouvert", "decouverts", "decouverte", "decouvertes",
    "mort", "morts", "morte", "mortes", "mourir", "mourait",
    "ne", "nes", "nee", "nees", "naitre", "naissait",
    
    // Objets quotidiens (abréviations courantes)
    "tele", "teles", "television", "televisions", "tv",
    "ordi", "ordis", "ordinateur", "ordinateurs", "pc",
    "tel", "telephone", "telephones", "portable", "portables", "mobile", "mobiles",
    "frigo", "frigos", "refrigerateur", "refrigerateurs",
    "micro", "micros", "microonde", "microondes",
    "radio", "radios", "stereo", "stereos",
    "photo", "photos", "video", "videos", "film", "films",
    "voiture", "voitures", "auto", "autos", "bagnole", "bagnoles",
    "velo", "velos", "moto", "motos", "scooter", "scooters",
    "bus", "metro", "tram", "train", "trains", "avion", "avions",
    "cle", "cles", "clef", "clefs",
    "sac", "sacs", "valise", "valises", "bagage", "bagages",
    "lit", "lits", "canape", "canapes", "sofa", "sofas", "fauteuil", "fauteuils",
    "table", "tables", "chaise", "chaises", "bureau", "bureaux",
    "lampe", "lampes", "lumiere", "lumieres",
    "porte", "portes", "fenetre", "fenetres", "mur", "murs",
    "sol", "sols", "plafond", "plafonds", "toit", "toits",
    "cuisine", "cuisines", "salon", "salons", "chambre", "chambres",
    "salle", "salles", "bain", "bains", "douche", "douches", "toilette", "toilettes", "wc",
    "jardin", "jardins", "terrasse", "terrasses", "balcon", "balcons",
    "garage", "garages", "cave", "caves", "grenier", "greniers"
]);

// === FONCTIONS D'ENCODAGE ===

/**
 * Encode un texte en remplaçant chaque lettre par son numéro sur 2 chiffres (A=01, B=02...)
 * Les chiffres sont aussi encodés : 0=27, 1=28, 2=29... 9=36
 * Les accents sont automatiquement convertis (é→E, ç→C, etc.)
 * Les apostrophes et tirets sont ignorés (j'ai → JAI, peut-être → PEUTETRE)
 * Sans espaces ni tirets pour plus de difficulté !
 * 
 * Si le mode jour est activé, un décalage est appliqué selon le jour de la semaine
 * ET le jour est encodé au milieu du message avec le marqueur "00" suivi de "0X" (X = jour 0-6)
 */
function encoderTexte(texte, avecDecalage = false) {
    let output = '';
    const jour = getJourActuel();
    const decalage = avecDecalage ? DECALAGES_JOURS[jour] : 0;
    
    // Supprimer les accents puis mettre en majuscules
    const texteNormalise = supprimerAccents(texte).toUpperCase();
    
    for (let i = 0; i < texteNormalise.length; i++) {
        const char = texteNormalise[i];
        
        if (char >= 'A' && char <= 'Z') {
            // Convertir la lettre en nombre sur 2 chiffres (A=01, B=02, etc.)
            let numero = char.charCodeAt(0) - 64;
            // Appliquer le décalage (avec modulo pour rester dans 1-26)
            numero = ((numero - 1 + decalage) % 26) + 1;
            output += numero.toString().padStart(2, '0');
        } else if (char >= '0' && char <= '9') {
            // Convertir le chiffre (0=27, 1=28, ..., 9=36)
            let numero = parseInt(char) + 27;
            // Appliquer le décalage pour les chiffres aussi (modulo 10, reste dans 27-36)
            numero = 27 + ((numero - 27 + decalage) % 10);
            output += numero.toString();
        }
        // Les espaces, apostrophes, tirets et autres caractères spéciaux sont ignorés
    }
    
    // Si mode jour activé, insérer le marqueur du jour au milieu
    // Format: "00" + jour sur 2 chiffres (00-06)
    if (avecDecalage && output.length >= 4) {
        const milieu = Math.floor(output.length / 2);
        // S'assurer que le milieu est sur une position paire (pour ne pas couper une paire)
        const positionInsertion = milieu - (milieu % 2);
        const marqueurJour = "00" + jour.toString().padStart(2, '0');
        output = output.slice(0, positionInsertion) + marqueurJour + output.slice(positionInsertion);
    }
    
    return output;
}

/**
 * Inverse complètement l'ordre des caractères d'une chaîne
 */
function inverserTexte(texte) {
    return texte.split('').reverse().join('');
}

/**
 * Extrait le jour encodé dans un message (marqueur "00" + "0X")
 * Retourne le jour (0-6) ou null si non trouvé
 */
function extraireJourDuCode(code) {
    // Chercher le marqueur "00" suivi de "0X" où X est 0-6
    const regex = /00(0[0-6])/g;
    let match;
    
    while ((match = regex.exec(code)) !== null) {
        const jour = parseInt(match[1]);
        if (jour >= 0 && jour <= 6) {
            return {
                jour: jour,
                position: match.index,
                longueur: 4
            };
        }
    }
    return null;
}

/**
 * Retire le marqueur du jour du code pour le décodage
 */
function retirerMarqueurJour(code, info) {
    if (!info) return code;
    return code.slice(0, info.position) + code.slice(info.position + info.longueur);
}

/**
 * Décode un texte codé (format sans tirets ni espaces) en lettres
 * Chaque lettre est codée sur 2 chiffres
 * 
 * Si un décalage est fourni, il est inversé pour retrouver le texte original
 */
function decoderTexte(texteCrypte, decalage = 0) {
    let resultat = '';
    
    // Supprimer tous les espaces éventuels
    const code = texteCrypte.replace(/\s/g, '');
    
    // Lire les chiffres par paires de 2
    for (let i = 0; i < code.length; i += 2) {
        if (i + 1 < code.length) {
            const paire = code.substring(i, i + 2);
            let num = parseInt(paire);
            
            if (!isNaN(num) && num >= 1 && num <= 26) {
                // Inverser le décalage pour les lettres
                num = ((num - 1 - decalage % 26 + 26) % 26) + 1;
                // Convertir le nombre en lettre (1=A, 2=B, etc.)
                const lettre = String.fromCharCode(64 + num);
                resultat += lettre;
            } else if (!isNaN(num) && num >= 27 && num <= 36) {
                // Inverser le décalage pour les chiffres
                let chiffre = (num - 27 - decalage % 10 + 10) % 10;
                resultat += chiffre.toString();
            }
        }
    }
    
    return resultat;
}

/**
 * Segmente un texte en mots en utilisant le dictionnaire
 * Algorithme de programmation dynamique amélioré
 */
function segmenterEnMots(texte) {
    const texteMin = texte.toLowerCase();
    const n = texteMin.length;
    
    if (n === 0) return '';
    
    // dp[i] = meilleure segmentation pour les i premiers caractères
    const dp = new Array(n + 1).fill(null);
    dp[0] = { score: 0, segmentation: [], nbMotsDico: 0 };
    
    // Longueur maximale d'un mot à chercher
    const maxLen = 20;
    
    for (let i = 1; i <= n; i++) {
        let meilleur = null;
        
        // Essayer tous les mots possibles se terminant à la position i
        const startMin = Math.max(0, i - maxLen);
        
        for (let j = startMin; j < i; j++) {
            if (dp[j] === null) continue;
            
            const mot = texteMin.substring(j, i);
            const longueur = mot.length;
            
            // Vérifier si c'est un mot du dictionnaire
            const estDansDico = DICTIONNAIRE.has(mot);
            
            let score;
            let nbMotsDico = dp[j].nbMotsDico;
            
            if (estDansDico) {
                // Très gros bonus pour les mots du dictionnaire
                // Bonus exponentiel pour les mots longs
                score = dp[j].score + (longueur * longueur * longueur);
                nbMotsDico++;
            } else if (longueur === 1) {
                // Les lettres seules sont très pénalisées
                score = dp[j].score - 100;
            } else if (longueur === 2) {
                // Petits mots inconnus très pénalisés
                score = dp[j].score - 50;
            } else if (longueur === 3) {
                // Mots de 3 lettres inconnus pénalisés
                score = dp[j].score - 20;
            } else {
                // Mots plus longs inconnus - légère pénalité
                // Mais on préfère un long mot inconnu à plusieurs petits inconnus
                score = dp[j].score + (longueur * 2) - 30;
            }
            
            // Bonus si on a plus de mots du dictionnaire
            const scoreAjuste = score + (nbMotsDico * 5);
            
            if (meilleur === null || scoreAjuste > meilleur.scoreAjuste) {
                meilleur = {
                    score: score,
                    scoreAjuste: scoreAjuste,
                    segmentation: [...dp[j].segmentation, mot.toUpperCase()],
                    nbMotsDico: nbMotsDico
                };
            }
        }
        
        dp[i] = meilleur;
    }
    
    if (dp[n] && dp[n].segmentation.length > 0) {
        return dp[n].segmentation.join(' ');
    }
    
    return texte;
}

// === ÉVÉNEMENTS ===

// Encodage en temps réel lors de la saisie
texteOriginal.addEventListener('input', function() {
    const texte = this.value;
    const avecDecalage = modeJour.checked;
    const code = encoderTexte(texte, avecDecalage);
    
    resultatCode.textContent = code || '...';
    resultatCode.classList.add('updated');
    setTimeout(() => resultatCode.classList.remove('updated'), 300);
    
    // Réinitialiser le résultat inversé
    resultatInverse.textContent = '';
    
    // Mettre à jour les mots mélangés si le mode est activé
    afficherMotsMelanges();
});

// Mettre à jour l'encodage quand on change le mode jour
modeJour.addEventListener('change', function() {
    afficherJourActuel();
    // Ré-encoder le texte avec le nouveau mode
    const texte = texteOriginal.value;
    if (texte) {
        const avecDecalage = modeJour.checked;
        const code = encoderTexte(texte, avecDecalage);
        resultatCode.textContent = code || '...';
        resultatInverse.textContent = '';
    }
});

// Toggle du mode mélange
modeMelange.addEventListener('change', function() {
    afficherMotsMelanges();
});

// Bouton Remélanger
btnRemelanger.addEventListener('click', function() {
    const texte = texteOriginal.value;
    if (texte.trim() !== '') {
        const melange = melangerMots(texte);
        resultatMelange.textContent = melange;
        resultatMelange.classList.add('updated');
        setTimeout(() => resultatMelange.classList.remove('updated'), 300);
    }
});

// Bouton Copier le texte mélangé
btnCopierMelange.addEventListener('click', function() {
    const texteACopier = resultatMelange.textContent;
    
    if (texteACopier && texteACopier !== '') {
        navigator.clipboard.writeText(texteACopier).then(() => {
            const originalText = this.textContent;
            this.textContent = '✅ Copié !';
            setTimeout(() => {
                this.textContent = originalText;
            }, 1500);
        });
    }
});

// Bouton Inverser
btnInverser.addEventListener('click', function() {
    const code = resultatCode.textContent;
    
    if (code && code !== '...') {
        const inverse = inverserTexte(code);
        resultatInverse.textContent = inverse;
        resultatInverse.classList.add('updated');
        setTimeout(() => resultatInverse.classList.remove('updated'), 300);
    }
});

// Bouton Copier
btnCopier.addEventListener('click', function() {
    const texteACopier = resultatInverse.textContent || resultatCode.textContent;
    
    if (texteACopier && texteACopier !== '...') {
        navigator.clipboard.writeText(texteACopier).then(() => {
            afficherMessage('✅ Copié dans le presse-papier !');
        });
    }
});

// Bouton Effacer (Encodeur)
btnEffacer.addEventListener('click', function() {
    texteOriginal.value = '';
    resultatCode.textContent = '...';
    resultatInverse.textContent = '';
    melangeBox.style.display = 'none';
    resultatMelange.textContent = '';
});

// Fonction pour obtenir le décalage selon le mode et le jour sélectionné
function getDecalageDecode() {
    if (!modeJourDecode.checked) {
        return 0;
    }
    const jourSelect = jourDecodeSelect.value;
    if (jourSelect === 'auto') {
        return getDecalageJour();
    }
    return DECALAGES_JOURS[parseInt(jourSelect)];
}

// Bouton Décoder (normal)
btnDecoder.addEventListener('click', function() {
    const code = texteCrypte.value.trim();
    
    if (code) {
        const decalage = getDecalageDecode();
        const decode = decoderTexte(code, decalage);
        resultatDecode.textContent = decode || 'Aucun texte décodé';
        resultatDecode.classList.add('updated');
        setTimeout(() => resultatDecode.classList.remove('updated'), 300);
    }
});

// Bouton Décoder (inversé - remet d'abord dans le bon ordre)
btnDecoderInverse.addEventListener('click', function() {
    const code = texteCrypte.value.trim();
    
    if (code) {
        // D'abord inverser pour remettre dans l'ordre original
        const codeRemisEnOrdre = inverserTexte(code);
        const decalage = getDecalageDecode();
        const decode = decoderTexte(codeRemisEnOrdre, decalage);
        resultatDecode.textContent = decode || 'Aucun texte décodé';
        resultatDecode.classList.add('updated');
        setTimeout(() => resultatDecode.classList.remove('updated'), 300);
    }
});

// Bouton Effacer (Décodeur)
btnEffacerDecodeur.addEventListener('click', function() {
    texteCrypte.value = '';
    resultatDecode.textContent = '';
});

// Bouton Coller
btnColler.addEventListener('click', function() {
    navigator.clipboard.readText().then(text => {
        texteCrypte.value = text;
        afficherMessage('✅ Texte collé !');
    }).catch(() => {
        afficherMessage('❌ Impossible de coller');
    });
});

// Bouton Décoder Intelligent
btnDecoderSmart.addEventListener('click', function() {
    let code = texteCrypte.value.trim();
    
    if (code) {
        let meilleurResultat = null;
        let meilleurScore = -1;
        let meilleurJour = null;
        let estInverse = false;
        let jourDetecte = null;
        
        // D'abord, chercher si le jour est encodé dans le message
        const infoJour = extraireJourDuCode(code);
        const infoJourInverse = extraireJourDuCode(inverserTexte(code));
        
        if (modeJourDecode.checked && (infoJour || infoJourInverse)) {
            // Jour trouvé dans le code ! Utiliser directement ce jour
            
            if (infoJour) {
                const codeSansMarqueur = retirerMarqueurJour(code, infoJour);
                const decalage = DECALAGES_JOURS[infoJour.jour];
                const decode = decoderTexte(codeSansMarqueur, decalage);
                const seg = segmenterEnMots(decode);
                const score = compterMotsReconnus(seg);
                
                if (score > meilleurScore) {
                    meilleurScore = score;
                    meilleurResultat = seg;
                    meilleurJour = infoJour.jour;
                    jourDetecte = true;
                    estInverse = false;
                }
            }
            
            if (infoJourInverse) {
                const codeInverse = inverserTexte(code);
                const codeSansMarqueur = retirerMarqueurJour(codeInverse, infoJourInverse);
                const decalage = DECALAGES_JOURS[infoJourInverse.jour];
                const decode = decoderTexte(codeSansMarqueur, decalage);
                const seg = segmenterEnMots(decode);
                const score = compterMotsReconnus(seg);
                
                if (score > meilleurScore) {
                    meilleurScore = score;
                    meilleurResultat = seg;
                    meilleurJour = infoJourInverse.jour;
                    jourDetecte = true;
                    estInverse = true;
                }
            }
            
        } else if (modeJourDecode.checked) {
            // Pas de marqueur trouvé, tester tous les jours
            for (let jour = 0; jour < 7; jour++) {
                const decalage = DECALAGES_JOURS[jour];
                
                // Version normale
                const decode1 = decoderTexte(code, decalage);
                const seg1 = segmenterEnMots(decode1);
                const score1 = compterMotsReconnus(seg1);
                
                if (score1 > meilleurScore) {
                    meilleurScore = score1;
                    meilleurResultat = seg1;
                    meilleurJour = jour;
                    estInverse = false;
                }
                
                // Version inversée
                const decode2 = decoderTexte(inverserTexte(code), decalage);
                const seg2 = segmenterEnMots(decode2);
                const score2 = compterMotsReconnus(seg2);
                
                if (score2 > meilleurScore) {
                    meilleurScore = score2;
                    meilleurResultat = seg2;
                    meilleurJour = jour;
                    estInverse = true;
                }
            }
        } else {
            // Mode sans décalage - comportement classique
            const decode1 = decoderTexte(code, 0);
            const decode2 = decoderTexte(inverserTexte(code), 0);
            
            const seg1 = segmenterEnMots(decode1);
            const seg2 = segmenterEnMots(decode2);
            
            const score1 = compterMotsReconnus(seg1);
            const score2 = compterMotsReconnus(seg2);
            
            if (score2 > score1 * 1.2) {
                meilleurResultat = seg2;
                estInverse = true;
            } else {
                meilleurResultat = seg1;
            }
        }
        
        // Afficher le résultat avec indications
        let indication = '';
        if (meilleurJour !== null) {
            const emoji = jourDetecte ? '🔓' : '📅';
            indication = ` <span style="color: #fbbf24; font-size: 0.8em;">${emoji} ${NOMS_JOURS[meilleurJour]}</span>`;
        }
        if (estInverse) {
            indication += ' <span style="color: #94a3b8; font-size: 0.8em;">🔄</span>';
        }
        
        resultatDecode.innerHTML = (meilleurResultat || 'Aucun texte décodé') + indication;
        resultatDecode.classList.add('updated');
        setTimeout(() => resultatDecode.classList.remove('updated'), 300);
    }
});

// Compter les mots reconnus dans une phrase (avec bonus pour mots longs)
function compterMotsReconnus(phrase) {
    const mots = phrase.toLowerCase().split(' ');
    let score = 0;
    for (const mot of mots) {
        if (DICTIONNAIRE.has(mot)) {
            score += mot.length * mot.length; // Carré de la longueur
        }
    }
    return score;
}

// === FONCTIONS UTILITAIRES ===

function afficherMessage(message) {
    const div = document.createElement('div');
    div.className = 'copy-message';
    div.textContent = message;
    document.body.appendChild(div);
    
    setTimeout(() => {
        div.remove();
    }, 2000);
}

// === GÉNÉRATION DE LA TABLE DE RÉFÉRENCE ===

function genererTableReference() {
    const table = document.getElementById('tableReference');
    
    // Lettres A-Z (01-26)
    for (let i = 1; i <= 26; i++) {
        const lettre = String.fromCharCode(64 + i);
        const numero = i.toString().padStart(2, '0');
        
        const item = document.createElement('div');
        item.className = 'table-item';
        item.innerHTML = `
            <div class="number">${numero}</div>
            <div class="letter">${lettre}</div>
        `;
        
        table.appendChild(item);
    }
    
    // Chiffres 0-9 (27-36)
    for (let i = 0; i <= 9; i++) {
        const numero = (i + 27).toString();
        
        const item = document.createElement('div');
        item.className = 'table-item table-item-number';
        item.innerHTML = `
            <div class="number">${numero}</div>
            <div class="letter">${i}</div>
        `;
        
        table.appendChild(item);
    }
}

// Initialisation
genererTableReference();

// === COFFRE-FORT ===

const codeSecretInput = document.getElementById('codeSecret');
const btnDeverrouiller = document.getElementById('btnDeverrouiller');
const btnVerrouiller = document.getElementById('btnVerrouiller');
const btnChangerCode = document.getElementById('btnChangerCode');
const coffreLock = document.querySelector('.coffre-lock');
const tableContainer = document.getElementById('tableContainer');
const erreurCode = document.getElementById('erreurCode');

// Code par défaut (peut être changé)
const CODE_DEFAUT = '1234';

// Récupérer le code stocké ou utiliser le code par défaut
function getCodeSecret() {
    return localStorage.getItem('coffreCode') || CODE_DEFAUT;
}

// Sauvegarder un nouveau code
function setCodeSecret(nouveauCode) {
    localStorage.setItem('coffreCode', nouveauCode);
}

// Déverrouiller le coffre
btnDeverrouiller.addEventListener('click', function() {
    const codeEntre = codeSecretInput.value;
    
    if (codeEntre === getCodeSecret()) {
        // Code correct - déverrouiller
        coffreLock.classList.add('unlocking');
        erreurCode.textContent = '';
        
        setTimeout(() => {
            coffreLock.style.display = 'none';
            tableContainer.classList.remove('hidden');
            tableContainer.classList.add('visible');
        }, 500);
    } else {
        // Code incorrect
        erreurCode.textContent = '❌ Code incorrect !';
        codeSecretInput.value = '';
        codeSecretInput.focus();
        
        // Animation de secousse
        codeSecretInput.style.animation = 'shake 0.3s ease';
        setTimeout(() => {
            codeSecretInput.style.animation = '';
        }, 300);
    }
});

// Permettre de valider avec Entrée
codeSecretInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        btnDeverrouiller.click();
    }
});

// Verrouiller le coffre
btnVerrouiller.addEventListener('click', function() {
    tableContainer.classList.add('hidden');
    tableContainer.classList.remove('visible');
    coffreLock.style.display = 'block';
    coffreLock.classList.remove('unlocking');
    codeSecretInput.value = '';
});

// Changer le code (depuis l'écran de verrouillage)
btnChangerCode.addEventListener('click', function() {
    changerCodeSecret();
});

// Changer le code (depuis l'intérieur du coffre)
const btnChangerCodeInterne = document.getElementById('btnChangerCodeInterne');
btnChangerCodeInterne.addEventListener('click', function() {
    changerCodeSecret();
});

// Fonction pour changer le code secret
function changerCodeSecret() {
    const ancienCode = prompt('Entrez le code actuel :');
    
    if (ancienCode === null) return; // Annulé
    
    if (ancienCode === getCodeSecret()) {
        const nouveauCode = prompt('Entrez le nouveau code :');
        
        if (nouveauCode === null) return; // Annulé
        
        if (nouveauCode && nouveauCode.length >= 1) {
            const confirmation = prompt('Confirmez le nouveau code :');
            
            if (confirmation === null) return; // Annulé
            
            if (nouveauCode === confirmation) {
                setCodeSecret(nouveauCode);
                afficherMessage('✅ Code changé avec succès !');
            } else {
                afficherMessage('❌ Les codes ne correspondent pas !');
            }
        } else {
            afficherMessage('❌ Le nouveau code ne peut pas être vide !');
        }
    } else {
        afficherMessage('❌ Code actuel incorrect !');
    }
}

// === ÉDITION DIRECTE DU MESSAGE DÉCODÉ ===
// La zone de résultat est maintenant directement éditable (contenteditable)
// L'utilisateur peut cliquer dessus et modifier le texte comme dans un éditeur

// Bouton Copier le message décodé
const btnCopierDecode = document.getElementById('btnCopierDecode');
btnCopierDecode.addEventListener('click', function() {
    const texte = resultatDecode.textContent || resultatDecode.innerText;
    
    if (texte && texte.trim()) {
        navigator.clipboard.writeText(texte).then(() => {
            afficherMessage('✅ Message copié !');
        });
    } else {
        afficherMessage('❌ Aucun message à copier');
    }
});
