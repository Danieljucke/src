class CountryMappingUtils {
    // Mapping des codes pays ISO 3166-1 alpha-2 vers alpha-3
    static countryCodeMapping = {
        // Afrique du Nord
        'DZ': 'DZA', // Algérie
        'EG': 'EGY', // Égypte
        'LY': 'LBY', // Libye
        'MA': 'MAR', // Maroc
        'SD': 'SDN', // Soudan
        'TN': 'TUN', // Tunisie
        
        // Afrique de l'Ouest
        'BJ': 'BEN', // Bénin
        'BF': 'BFA', // Burkina Faso
        'CV': 'CPV', // Cap-Vert
        'CI': 'CIV', // Côte d'Ivoire
        'GM': 'GMB', // Gambie
        'GH': 'GHA', // Ghana
        'GN': 'GIN', // Guinée
        'GW': 'GNB', // Guinée-Bissau
        'LR': 'LBR', // Liberia
        'ML': 'MLI', // Mali
        'MR': 'MRT', // Mauritanie
        'NE': 'NER', // Niger
        'NG': 'NGA', // Nigeria
        'SN': 'SEN', // Sénégal
        'SL': 'SLE', // Sierra Leone
        'TG': 'TGO', // Togo
        
        // Afrique Centrale
        'AO': 'AGO', // Angola
        'CM': 'CMR', // Cameroun
        'CF': 'CAF', // République centrafricaine
        'TD': 'TCD', // Tchad
        'CG': 'COG', // République du Congo
        'CD': 'COD', // République démocratique du Congo
        'GQ': 'GNQ', // Guinée équatoriale
        'GA': 'GAB', // Gabon
        'ST': 'STP', // São Tomé-et-Príncipe
        
        // Afrique de l'Est
        'BI': 'BDI', // Burundi
        'KM': 'COM', // Comores
        'DJ': 'DJI', // Djibouti
        'ER': 'ERI', // Érythrée
        'ET': 'ETH', // Éthiopie
        'KE': 'KEN', // Kenya
        'MG': 'MDG', // Madagascar
        'MW': 'MWI', // Malawi
        'MU': 'MUS', // Maurice
        'MZ': 'MOZ', // Mozambique
        'RW': 'RWA', // Rwanda
        'SC': 'SYC', // Seychelles
        'SO': 'SOM', // Somalie
        'SS': 'SSD', // Soudan du Sud
        'TZ': 'TZA', // Tanzanie
        'UG': 'UGA', // Ouganda
        
        // Afrique Australe
        'BW': 'BWA', // Botswana
        'SZ': 'SWZ', // Eswatini
        'LS': 'LSO', // Lesotho
        'NA': 'NAM', // Namibie
        'ZA': 'ZAF', // Afrique du Sud
        'ZM': 'ZMB', // Zambie
        'ZW': 'ZWE', // Zimbabwe
        
        // Top 10 économies mondiales
        'US': 'USA', // États-Unis
        'CN': 'CHN', // Chine
        'JP': 'JPN', // Japon
        'DE': 'DEU', // Allemagne
        'IN': 'IND', // Inde
        'GB': 'GBR', // Royaume-Uni
        'FR': 'FRA', // France
        'IT': 'ITA', // Italie
        'BR': 'BRA', // Brésil
        'CA': 'CAN', // Canada
        
        // Pays supplémentaires stratégiques
        'ES': 'ESP', // Espagne
        'NL': 'NLD', // Pays-Bas
        'BE': 'BEL', // Belgique
        'CH': 'CHE', // Suisse
        'AU': 'AUS', // Australie
        'KR': 'KOR', // Corée du Sud
        'MX': 'MEX', // Mexique
        'RU': 'RUS', // Russie
        'TR': 'TUR', // Turquie
        'AE': 'ARE', // Émirats arabes unis
        'SA': 'SAU'  // Arabie saoudite
    };

    /**
     * Convertit un code pays ISO 3166-1 alpha-2 en alpha-3
     * @param {string} alpha2Code - Code pays à 2 lettres (ex: "US")
     * @returns {string|null} - Code pays à 3 lettres (ex: "USA") ou null si non trouvé
     */
    static mapAlpha2ToAlpha3(alpha2Code) {
        if (!alpha2Code) return null;
        
        const upperCode = alpha2Code.toUpperCase();
        return this.countryCodeMapping[upperCode] || null;
    }

    /**
     * Détermine le code pays à partir des données utilisateur
     * @param {object} userData - Données utilisateur (Google/Apple)
     * @returns {string|null} - Code pays à 3 lettres ou null
     */
    static determineCountryCode(userData) {
        // Priorité 1: locale de Google/Apple
        if (userData.locale) {
            const localeParts = userData.locale.split(/[-_]/);
            if (localeParts.length > 1) {
                const countryCode = this.mapAlpha2ToAlpha3(localeParts[1]);
                if (countryCode) return countryCode;
            }
        }

        // Priorité 2: hd (hosted domain) pour Google
        if (userData.hd) {
            // Extraire le pays du domaine si possible
            const domainParts = userData.hd.split('.');
            const tld = domainParts[domainParts.length - 1];
            if (tld.length === 2) {
                const countryCode = this.mapAlpha2ToAlpha3(tld.toUpperCase());
                if (countryCode) return countryCode;
            }
        }

        // Priorité 3: Analyser l'email pour des indices géographiques
        if (userData.email) {
            const emailDomain = userData.email.split('@')[1];
            if (emailDomain) {
                const domainParts = emailDomain.split('.');
                const tld = domainParts[domainParts.length - 1];
                if (tld.length === 2 && tld !== 'com') {
                    const countryCode = this.mapAlpha2ToAlpha3(tld.toUpperCase());
                    if (countryCode) return countryCode;
                }
            }
        }

        // Par défaut: Maroc (votre pays principal)
        return 'MAR';
    }

    /**
     * Valide si un code pays existe dans votre base de données
     * @param {string} countryCode - Code pays à 3 lettres
     * @returns {boolean} - true si le code existe
     */
    static isValidCountryCode(countryCode) {
        const validCodes = Object.values(this.countryCodeMapping);
        return validCodes.includes(countryCode);
    }
}

module.exports = CountryMappingUtils;
