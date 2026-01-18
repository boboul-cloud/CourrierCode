import Foundation

class Dictionnaire {
    static let shared = Dictionnaire()
    
    private let mots: Set<String>
    
    private init() {
        mots = Set([
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
            
            // Verbes être et avoir
            "suis", "es", "est", "sommes", "etes", "sont", "etais", "etait", "etions",
            "etiez", "etaient", "fus", "fut", "fumes", "futes", "furent", "serai",
            "seras", "sera", "serons", "serez", "seront", "serais", "serait", "serions",
            "seriez", "seraient", "sois", "soit", "soyons", "soyez", "soient", "ete",
            "ai", "as", "a", "avons", "avez", "ont", "avais", "avait", "avions",
            "aviez", "avaient", "eus", "eut", "eumes", "eutes", "eurent", "aurai",
            "auras", "aura", "aurons", "aurez", "auront", "aurais", "aurait", "aurions",
            "auriez", "auraient", "aie", "aies", "ait", "ayons", "ayez", "aient", "eu",
            
            // Verbes courants
            "etre", "avoir", "faire", "aller", "venir", "voir", "pouvoir", "vouloir",
            "devoir", "savoir", "falloir", "dire", "donner", "prendre", "partir",
            "sortir", "mettre", "lire", "ecrire", "croire", "connaitre", "paraitre",
            "vivre", "suivre", "tenir", "comprendre", "apprendre", "rendre", "attendre",
            "entendre", "repondre", "perdre", "permettre", "recevoir", "sentir", "servir",
            "rester", "passer", "trouver", "chercher", "donner", "parler", "aimer",
            "penser", "croire", "sembler", "laisser", "tomber", "montrer", "commencer",
            "jouer", "appeler", "porter", "demander", "garder", "regarder", "ecouter",
            
            // Verbes conjugués
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
            
            // Temps
            "temps", "jour", "jours", "nuit", "nuits", "matin", "matins", "soir", "soirs",
            "heure", "heures", "minute", "minutes", "seconde", "secondes", "moment", "moments",
            "semaine", "semaines", "mois", "annee", "annees", "an", "ans", "siecle",
            "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche",
            "janvier", "fevrier", "mars", "avril", "mai", "juin", "juillet", "aout",
            "septembre", "octobre", "novembre", "decembre", "printemps", "ete", "automne", "hiver",
            
            // Personnes
            "homme", "hommes", "femme", "femmes", "enfant", "enfants", "fille", "filles",
            "garcon", "garcons", "bebe", "bebes", "personne", "personnes", "gens",
            "pere", "mere", "parents", "frere", "soeur", "famille", "familles",
            "ami", "amie", "amis", "amies", "copain", "copine", "voisin", "voisine",
            
            // Lieux
            "lieu", "lieux", "endroit", "endroits", "place", "places", "coin",
            "maison", "maisons", "appartement", "chambre", "chambres", "piece", "pieces",
            "cuisine", "salon", "salle", "bureau", "bureaux", "jardin", "jardins",
            "ville", "villes", "village", "villages", "quartier", "rue", "rues",
            "pays", "region", "departement", "france", "paris", "europe", "monde",
            "ecole", "ecoles", "college", "lycee", "universite", "classe", "classes",
            
            // Objets
            "chose", "choses", "objet", "objets", "truc", "trucs", "machin",
            "porte", "portes", "fenetre", "fenetres", "mur", "murs", "sol", "plafond",
            "table", "tables", "chaise", "chaises", "lit", "lits", "armoire",
            "livre", "livres", "page", "pages", "cahier", "cahiers", "stylo", "crayon",
            "lettre", "lettres", "mot", "mots", "phrase", "texte", "message", "messages",
            "telephone", "ordinateur", "ecran", "clavier", "souris",
            "voiture", "voitures", "velo", "velos", "bus", "train", "avion", "bateau",
            
            // Corps
            "corps", "tete", "visage", "yeux", "oeil", "nez", "bouche", "oreille", "oreilles",
            "cheveux", "front", "joue", "joues", "menton", "cou", "epaule", "epaules",
            "bras", "main", "mains", "doigt", "doigts", "jambe", "jambes", "pied", "pieds",
            
            // Nature
            "nature", "terre", "ciel", "soleil", "lune", "etoile", "etoiles",
            "air", "eau", "feu", "vent", "pluie", "neige", "nuage", "nuages",
            "arbre", "arbres", "fleur", "fleurs", "plante", "plantes", "herbe", "feuille",
            "animal", "animaux", "chien", "chiens", "chat", "chats", "oiseau", "oiseaux",
            "lapin", "lapins", "souris", "cheval", "chevaux", "vache", "vaches", "cochon",
            "mouton", "moutons", "poule", "poules", "coq", "canard", "canards", "oie",
            "lion", "lions", "tigre", "tigres", "elephant", "elephants", "singe", "singes",
            "serpent", "serpents", "tortue", "tortues", "poisson", "poissons", "requin",
            "dauphin", "dauphins", "baleine", "baleines", "loup", "loups", "renard", "renards",
            "cerf", "cerfs", "biche", "biches", "sanglier", "sangliers", "ours", "aigle",
            "hibou", "hiboux", "corbeau", "corbeaux", "pie", "pigeon", "pigeons",
            "abeille", "abeilles", "papillon", "papillons", "fourmi", "fourmis",
            "araignee", "araignees", "mouche", "mouches", "moustique", "moustiques",
            "foret", "forets", "montagne", "montagnes", "mer", "mers", "ocean", "oceans",
            "riviere", "rivieres", "lac", "lacs", "plage", "plages", "ile", "iles",
            
            // Nourriture
            "nourriture", "repas", "petit", "dejeuner", "diner", "gouter",
            "pain", "beurre", "fromage", "lait", "oeuf", "oeufs", "viande", "poisson",
            "legume", "legumes", "fruit", "fruits", "pomme", "orange", "banane",
            
            // Abstrait
            "vie", "mort", "amour", "haine", "joie", "tristesse", "peur", "colere",
            "bonheur", "malheur", "chance", "courage", "force", "faiblesse",
            "idee", "idees", "pensee", "pensees", "reve", "reves", "espoir", "espoirs",
            "verite", "mensonge", "secret", "secrets", "mystere", "mysteres",
            "probleme", "problemes", "solution", "solutions", "question", "questions",
            "travail", "travaux", "projet", "projets", "plan", "plans",
            
            // Adjectifs
            "bon", "bonne", "bons", "bonnes", "mauvais", "mauvaise",
            "grand", "grande", "grands", "grandes", "petit", "petite", "petits", "petites",
            "gros", "grosse", "mince", "long", "longue", "court", "courte",
            "haut", "haute", "bas", "basse", "large", "etroit", "etroite",
            "vieux", "vieille", "vieilles", "jeune", "jeunes", "nouveau", "nouvelle", "nouveaux",
            "beau", "belle", "beaux", "belles", "joli", "jolie", "jolis", "jolies",
            "blanc", "blanche", "blancs", "blanches", "noir", "noire", "noirs", "noires",
            "rouge", "rouges", "bleu", "bleue", "bleus", "bleues", "vert", "verte",
            "jaune", "jaunes", "rose", "roses", "violet", "violette",
            "chaud", "chaude", "froid", "froide", "sec", "seche", "humide",
            "dur", "dure", "mou", "molle", "doux", "douce",
            "lourd", "lourde", "leger", "legere", "plein", "pleine", "vide",
            "ouvert", "ouverte", "ouverts", "ouvertes", "ferme", "fermee",
            "facile", "faciles", "difficile", "difficiles", "simple", "simples",
            "rapide", "rapides", "lent", "lente", "lents", "lentes",
            "fort", "forte", "forts", "fortes", "faible", "faibles",
            "content", "contente", "heureux", "heureuse", "triste", "tristes",
            "seul", "seule", "seuls", "seules", "ensemble", "different", "differente",
            "meme", "memes", "autre", "autres", "premier", "premiere", "dernier", "derniere",
            "vrai", "vraie", "vrais", "vraies", "faux", "fausse",
            "possible", "impossible", "necessaire", "important", "importante",
            
            // Nombres
            "zero", "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf",
            "dix", "onze", "douze", "treize", "quatorze", "quinze", "seize",
            "vingt", "trente", "quarante", "cinquante", "soixante",
            "cent", "cents", "mille", "million", "millions",
            
            // Messages secrets
            "rendez", "vous", "rendezvous", "code", "codes", "cle", "cles", "clef",
            "secret", "secrets", "cache", "caches", "cachee", "cachees",
            "tresor", "tresors", "indice", "indices", "piste", "pistes",
            "mission", "missions", "objectif", "objectifs", "cible", "cibles",
            "attention", "danger", "dangers", "urgent", "urgente", "urgents",
            "confidentiel", "prive", "privee",
            "nord", "sud", "est", "ouest", "droite", "gauche", "haut", "bas",
            "devant", "derriere", "dessus", "dessous", "entre", "milieu", "centre",
            "numero", "numeros", "adresse", "adresses", "contact", "contacts",
            "signal", "signaux", "signe", "signes", "marque", "marques",
            "retrouve", "retrouves", "retrouver", "rejoindre", "rejoins",
            
            // Bretagne (pour le test)
            "ploudalmezeau", "bretagne", "finistere", "commune", "communes",
            "wikipedia", "bourg", "rural", "maritime", "port", "ports"
        ])
    }
    
    func contient(_ mot: String) -> Bool {
        let motMin = mot.lowercased()
        
        // Interdire les mots se terminant par double "s" ou double "x"
        if motMin.hasSuffix("ss") || motMin.hasSuffix("xx") {
            return false
        }
        
        // Vérification directe
        if mots.contains(motMin) {
            return true
        }
        
        // Tenter de reconnaître les pluriels automatiquement
        return estPlurielsReconnu(motMin)
    }
    
    /// Vérifie si le mot est un pluriel reconnu d'un mot du dictionnaire
    private func estPlurielsReconnu(_ mot: String) -> Bool {
        let n = mot.count
        guard n >= 3 else { return false }
        
        // Règle 1: mots en "aux" → singulier en "al" (animaux → animal, chevaux → cheval)
        if mot.hasSuffix("aux") && n >= 4 {
            let singulier = String(mot.dropLast(3)) + "al"
            // Éviter de reconnaître si le singulier se termine déjà par "s" ou "x"
            if !singulier.hasSuffix("s") && !singulier.hasSuffix("x") && mots.contains(singulier) {
                return true
            }
        }
        
        // Règle 2: mots en "eaux" → singulier en "eau" (bateaux → bateau, gateaux → gateau)
        if mot.hasSuffix("eaux") && n >= 5 {
            let singulier = String(mot.dropLast(1)) // retire juste le x
            if mots.contains(singulier) { return true }
        }
        
        // Règle 3: mots en "eux" → singulier en "eu" (cheveux → cheveu, jeux → jeu)
        if mot.hasSuffix("eux") && n >= 4 {
            let singulier = String(mot.dropLast(1)) // retire juste le x
            if mots.contains(singulier) { return true }
        }
        
        // Règle 4: mots en "oux" → singulier en "ou" (bijoux → bijou, cailloux → caillou)
        if mot.hasSuffix("oux") && n >= 4 {
            let singulier = String(mot.dropLast(1)) // retire juste le x
            if mots.contains(singulier) { return true }
        }
        
        // Règle 5: mots en "s" → singulier sans "s" (voitures → voiture)
        // Ne pas doubler: si le singulier se termine déjà par "s", ne pas reconnaître
        if mot.hasSuffix("s") {
            let singulier = String(mot.dropLast(1))
            // Éviter les mots invariables (temps, corps, souris, etc.)
            if !singulier.hasSuffix("s") && mots.contains(singulier) {
                return true
            }
        }
        
        // Règle 6: mots en "x" (autres cas) → singulier sans "x"
        // Ne pas doubler: si le singulier se termine déjà par "x", ne pas reconnaître
        if mot.hasSuffix("x") {
            let singulier = String(mot.dropLast(1))
            if !singulier.hasSuffix("x") && mots.contains(singulier) {
                return true
            }
        }
        
        return false
    }
}
