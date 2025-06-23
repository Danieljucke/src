class CountryMapping {
  final currencyFlags = {
    // Devises principales
    'USD': '🇺🇸', 'EUR': '🇪🇺', 'GBP': '🇬🇧', 'JPY': '🇯🇵', 'CHF': '🇨🇭',
    'CAD': '🇨🇦', 'AUD': '🇦🇺', 'CNY': '🇨🇳', 'SEK': '🇸🇪', 'NZD': '🇳🇿',
    
    // Asie-Pacifique
    'KRW': '🇰🇷', 'SGD': '🇸🇬', 'HKD': '🇭🇰', 'TWD': '🇹🇼', 'THB': '🇹🇭',
    'MYR': '🇲🇾', 'IDR': '🇮🇩', 'PHP': '🇵🇭', 'VND': '🇻🇳', 'INR': '🇮🇳',
    'PKR': '🇵🇰', 'BDT': '🇧🇩', 'LKR': '🇱🇰', 'NPR': '🇳🇵', 'MMK': '🇲🇲',
    'KHR': '🇰🇭', 'LAK': '🇱🇦', 'MNT': '🇲🇳', 'KZT': '🇰🇿', 'UZS': '🇺🇿',
    
    // Moyen-Orient
    'AED': '🇦🇪', 'SAR': '🇸🇦', 'QAR': '🇶🇦', 'KWD': '🇰🇼', 'BHD': '🇧🇭',
    'OMR': '🇴🇲', 'JOD': '🇯🇴', 'ILS': '🇮🇱', 'LBP': '🇱🇧', 'SYP': '🇸🇾',
    'IQD': '🇮🇶', 'IRR': '🇮🇷', 'AFN': '🇦🇫',
    
    // Europe
    'NOK': '🇳🇴', 'DKK': '🇩🇰', 'ISK': '🇮🇸', 'PLN': '🇵🇱', 'CZK': '🇨🇿',
    'HUF': '🇭🇺', 'RON': '🇷🇴', 'BGN': '🇧🇬', 'HRK': '🇭🇷', 'RSD': '🇷🇸',
    'BAM': '🇧🇦', 'MKD': '🇲🇰', 'ALL': '🇦🇱', 'TRY': '🇹🇷', 'RUB': '🇷🇺',
    'UAH': '🇺🇦', 'BYN': '🇧🇾', 'MDL': '🇲🇩', 'GEL': '🇬🇪', 'AMD': '🇦🇲',
    'AZN': '🇦🇿',
    
    // Amériques
    'MXN': '🇲🇽', 'BRL': '🇧🇷', 'ARS': '🇦🇷', 'CLP': '🇨🇱', 'COP': '🇨🇴',
    'PEN': '🇵🇪', 'BOB': '🇧🇴', 'UYU': '🇺🇾', 'PYG': '🇵🇾', 'VES': '🇻🇪',
    'GYD': '🇬🇾', 'SRD': '🇸🇷', 'TTD': '🇹🇹', 'JMD': '🇯🇲', 'BBD': '🇧🇧',
    'BSD': '🇧🇸', 'BZD': '🇧🇿', 'GTQ': '🇬🇹', 'HNL': '🇭🇳', 'NIO': '🇳🇮',
    'CRC': '🇨🇷', 'PAB': '🇵🇦', 'DOP': '🇩🇴', 'HTG': '🇭🇹', 'CUP': '🇨🇺',
    
    // Afrique
    'ZAR': '🇿🇦', 'NGN': '🇳🇬', 'EGP': '🇪🇬', 'MAD': '🇲🇦', 'TND': '🇹🇳',
    'DZD': '🇩🇿', 'LYD': '🇱🇾', 'SDG': '🇸🇩', 'ETB': '🇪🇹', 'KES': '🇰🇪',
    'UGX': '🇺🇬', 'TZS': '🇹🇿', 'RWF': '🇷🇼', 'BIF': '🇧🇮', 'MWK': '🇲🇼',
    'ZMW': '🇿🇲', 'BWP': '🇧🇼', 'SZL': '🇸🇿', 'LSL': '🇱🇸', 'NAD': '🇳🇦',
    'AOA': '🇦🇴', 'MZN': '🇲🇿', 'MUR': '🇲🇺', 'SCR': '🇸🇨', 'GMD': '🇬🇲',
    'SLL': '🇸🇱', 'LRD': '🇱🇷', 'GHS': '🇬🇭', 'CVE': '🇨🇻',
    
    // Franc CFA
    'XOF': '🇸🇳', // Utilisé par 8 pays d'Afrique de l'Ouest
    'XAF': '🇨🇲', // Utilisé par 6 pays d'Afrique Centrale
    
    // Océanie
    'FJD': '🇫🇯', 'PGK': '🇵🇬', 'SBD': '🇸🇧', 'VUV': '🇻🇺', 'WST': '🇼🇸',
    'TOP': '🇹🇴', 'XPF': '🇵🇫', // Franc Pacifique
  };

  final currencyNames = {
    // Devises principales
    'USD': 'Dollar US', 'EUR': 'Euro', 'GBP': 'Livre Sterling', 
    'JPY': 'Yen Japonais', 'CHF': 'Franc Suisse', 'CAD': 'Dollar Canadien',
    'AUD': 'Dollar Australien', 'CNY': 'Yuan Chinois', 'SEK': 'Couronne Suédoise',
    'NZD': 'Dollar Néo-zélandais',
    
    // Asie-Pacifique
    'KRW': 'Won Sud-coréen', 'SGD': 'Dollar de Singapour', 'HKD': 'Dollar de Hong Kong',
    'TWD': 'Dollar de Taïwan', 'THB': 'Baht Thaïlandais', 'MYR': 'Ringgit Malaisien',
    'IDR': 'Roupie Indonésienne', 'PHP': 'Peso Philippin', 'VND': 'Dong Vietnamien',
    'INR': 'Roupie Indienne', 'PKR': 'Roupie Pakistanaise', 'BDT': 'Taka Bangladais',
    'LKR': 'Roupie Sri-lankaise', 'NPR': 'Roupie Népalaise', 'MMK': 'Kyat Birman',
    'KHR': 'Riel Cambodgien', 'LAK': 'Kip Laotien', 'MNT': 'Tugrik Mongol',
    'KZT': 'Tenge Kazakh', 'UZS': 'Sum Ouzbek',
    
    // Moyen-Orient
    'AED': 'Dirham des Émirats', 'SAR': 'Riyal Saoudien', 'QAR': 'Riyal Qatarien',
    'KWD': 'Dinar Koweïtien', 'BHD': 'Dinar Bahreïni', 'OMR': 'Rial Omanais',
    'JOD': 'Dinar Jordanien', 'ILS': 'Shekel Israélien', 'LBP': 'Livre Libanaise',
    'SYP': 'Livre Syrienne', 'IQD': 'Dinar Irakien', 'IRR': 'Rial Iranien',
    'AFN': 'Afghani',
    
    // Europe
    'NOK': 'Couronne Norvégienne', 'DKK': 'Couronne Danoise', 'ISK': 'Couronne Islandaise',
    'PLN': 'Zloty Polonais', 'CZK': 'Couronne Tchèque', 'HUF': 'Forint Hongrois',
    'RON': 'Leu Roumain', 'BGN': 'Lev Bulgare', 'HRK': 'Kuna Croate',
    'RSD': 'Dinar Serbe', 'BAM': 'Mark Convertible', 'MKD': 'Denar Macédonien',
    'ALL': 'Lek Albanais', 'TRY': 'Livre Turque', 'RUB': 'Rouble Russe',
    'UAH': 'Hryvnia Ukrainienne', 'BYN': 'Rouble Biélorusse', 'MDL': 'Leu Moldave',
    'GEL': 'Lari Géorgien', 'AMD': 'Dram Arménien', 'AZN': 'Manat Azerbaïdjanais',
    
    // Amériques
    'MXN': 'Peso Mexicain', 'BRL': 'Real Brésilien', 'ARS': 'Peso Argentin',
    'CLP': 'Peso Chilien', 'COP': 'Peso Colombien', 'PEN': 'Sol Péruvien',
    'BOB': 'Boliviano', 'UYU': 'Peso Uruguayen', 'PYG': 'Guarani Paraguayen',
    'VES': 'Bolivar Vénézuélien', 'GYD': 'Dollar Guyanien', 'SRD': 'Dollar Surinamais',
    'TTD': 'Dollar de Trinité-et-Tobago', 'JMD': 'Dollar Jamaïcain', 'BBD': 'Dollar Barbadien',
    'BSD': 'Dollar Bahaméen', 'BZD': 'Dollar Bélizien', 'GTQ': 'Quetzal Guatémaltèque',
    'HNL': 'Lempira Hondurien', 'NIO': 'Córdoba Nicaraguayen', 'CRC': 'Colón Costaricien',
    'PAB': 'Balboa Panaméen', 'DOP': 'Peso Dominicain', 'HTG': 'Gourde Haïtienne',
    'CUP': 'Peso Cubain',
    
    // Afrique
    'ZAR': 'Rand Sud-africain', 'NGN': 'Naira Nigérian', 'EGP': 'Livre Égyptienne',
    'MAD': 'Dirham Marocain', 'TND': 'Dinar Tunisien', 'DZD': 'Dinar Algérien',
    'LYD': 'Dinar Libyen', 'SDG': 'Livre Soudanaise', 'ETB': 'Birr Éthiopien',
    'KES': 'Shilling Kenyan', 'UGX': 'Shilling Ougandais', 'TZS': 'Shilling Tanzanien',
    'RWF': 'Franc Rwandais', 'BIF': 'Franc Burundais', 'MWK': 'Kwacha Malawien',
    'ZMW': 'Kwacha Zambien', 'BWP': 'Pula Botswanais', 'SZL': 'Lilangeni Swazi',
    'LSL': 'Loti Lesothan', 'NAD': 'Dollar Namibien', 'AOA': 'Kwanza Angolais',
    'MZN': 'Metical Mozambicain', 'MUR': 'Roupie Mauricienne', 'SCR': 'Roupie Seychelloise',
    'GMD': 'Dalasi Gambien', 'SLL': 'Leone Sierra-léonais', 'LRD': 'Dollar Libérien',
    'GHS': 'Cedi Ghanéen', 'CVE': 'Escudo Cap-verdien',
    
    // Franc CFA
    'XOF': 'Franc CFA (BCEAO)', 'XAF': 'Franc CFA (BEAC)',
    
    // Océanie
    'FJD': 'Dollar Fidjien', 'PGK': 'Kina Papou-Nouvelle-Guinée', 'SBD': 'Dollar des Îles Salomon',
    'VUV': 'Vatu Vanuatais', 'WST': 'Tala Samoan', 'TOP': 'Pa\'anga Tongien',
    'XPF': 'Franc Pacifique',
  };

  final countries = {
    // Devises principales
    'USD': 'États-Unis', 'EUR': 'Zone Euro', 'GBP': 'Royaume-Uni',
    'JPY': 'Japon', 'CHF': 'Suisse', 'CAD': 'Canada',
    'AUD': 'Australie', 'CNY': 'Chine', 'SEK': 'Suède',
    'NZD': 'Nouvelle-Zélande',
    
    // Asie-Pacifique
    'KRW': 'Corée du Sud', 'SGD': 'Singapour', 'HKD': 'Hong Kong',
    'TWD': 'Taïwan', 'THB': 'Thaïlande', 'MYR': 'Malaisie',
    'IDR': 'Indonésie', 'PHP': 'Philippines', 'VND': 'Vietnam',
    'INR': 'Inde', 'PKR': 'Pakistan', 'BDT': 'Bangladesh',
    'LKR': 'Sri Lanka', 'NPR': 'Népal', 'MMK': 'Myanmar',
    'KHR': 'Cambodge', 'LAK': 'Laos', 'MNT': 'Mongolie',
    'KZT': 'Kazakhstan', 'UZS': 'Ouzbékistan',
    
    // Moyen-Orient
    'AED': 'Émirats Arabes Unis', 'SAR': 'Arabie Saoudite', 'QAR': 'Qatar',
    'KWD': 'Koweït', 'BHD': 'Bahreïn', 'OMR': 'Oman',
    'JOD': 'Jordanie', 'ILS': 'Israël', 'LBP': 'Liban',
    'SYP': 'Syrie', 'IQD': 'Irak', 'IRR': 'Iran',
    'AFN': 'Afghanistan',
    
    // Europe
    'NOK': 'Norvège', 'DKK': 'Danemark', 'ISK': 'Islande',
    'PLN': 'Pologne', 'CZK': 'République Tchèque', 'HUF': 'Hongrie',
    'RON': 'Roumanie', 'BGN': 'Bulgarie', 'HRK': 'Croatie',
    'RSD': 'Serbie', 'BAM': 'Bosnie-Herzégovine', 'MKD': 'Macédoine du Nord',
    'ALL': 'Albanie', 'TRY': 'Turquie', 'RUB': 'Russie',
    'UAH': 'Ukraine', 'BYN': 'Biélorussie', 'MDL': 'Moldavie',
    'GEL': 'Géorgie', 'AMD': 'Arménie', 'AZN': 'Azerbaïdjan',
    
    // Amériques
    'MXN': 'Mexique', 'BRL': 'Brésil', 'ARS': 'Argentine',
    'CLP': 'Chili', 'COP': 'Colombie', 'PEN': 'Pérou',
    'BOB': 'Bolivie', 'UYU': 'Uruguay', 'PYG': 'Paraguay',
    'VES': 'Venezuela', 'GYD': 'Guyana', 'SRD': 'Suriname',
    'TTD': 'Trinité-et-Tobago', 'JMD': 'Jamaïque', 'BBD': 'Barbade',
    'BSD': 'Bahamas', 'BZD': 'Belize', 'GTQ': 'Guatemala',
    'HNL': 'Honduras', 'NIO': 'Nicaragua', 'CRC': 'Costa Rica',
    'PAB': 'Panama', 'DOP': 'République Dominicaine', 'HTG': 'Haïti',
    'CUP': 'Cuba',
    
    // Afrique
    'ZAR': 'Afrique du Sud', 'NGN': 'Nigeria', 'EGP': 'Égypte',
    'MAD': 'Maroc', 'TND': 'Tunisie', 'DZD': 'Algérie',
    'LYD': 'Libye', 'SDG': 'Soudan', 'ETB': 'Éthiopie',
    'KES': 'Kenya', 'UGX': 'Ouganda', 'TZS': 'Tanzanie',
    'RWF': 'Rwanda', 'BIF': 'Burundi', 'MWK': 'Malawi',
    'ZMW': 'Zambie', 'BWP': 'Botswana', 'SZL': 'Eswatini',
    'LSL': 'Lesotho', 'NAD': 'Namibie', 'AOA': 'Angola',
    'MZN': 'Mozambique', 'MUR': 'Maurice', 'SCR': 'Seychelles',
    'GMD': 'Gambie', 'SLL': 'Sierra Leone', 'LRD': 'Liberia',
    'GHS': 'Ghana', 'CVE': 'Cap-Vert',
    
    // Franc CFA
    'XOF': 'Afrique de l\'Ouest (UEMOA)', 'XAF': 'Afrique Centrale (CEMAC)',
    
    // Océanie
    'FJD': 'Fidji', 'PGK': 'Papouasie-Nouvelle-Guinée', 'SBD': 'Îles Salomon',
    'VUV': 'Vanuatu', 'WST': 'Samoa', 'TOP': 'Tonga',
    'XPF': 'Polynésie Française',
  };

  final countriesPhoneCode = {
    // Afrique
    'DZA': '+213', // Algérie
    'AGO': '+244', // Angola
    'BEN': '+229', // Bénin
    'BWA': '+267', // Botswana
    'BFA': '+226', // Burkina Faso
    'BDI': '+257', // Burundi
    'CMR': '+237', // Cameroun
    'CPV': '+238', // Cap-Vert
    'CAF': '+236', // République centrafricaine
    'TCD': '+235', // Tchad
    'COM': '+269', // Comores
    'COG': '+242', // Congo-Brazzaville
    'COD': '+243', // RD Congo
    'CIV': '+225', // Côte d'Ivoire
    'DJI': '+253', // Djibouti
    'EGY': '+20',  // Égypte
    'GNQ': '+240', // Guinée équatoriale
    'ERI': '+291', // Érythrée
    'SWZ': '+268', // Eswatini
    'ETH': '+251', // Éthiopie
    'GAB': '+241', // Gabon
    'GMB': '+220', // Gambie
    'GHA': '+233', // Ghana
    'GIN': '+224', // Guinée
    'GNB': '+245', // Guinée-Bissau
    'KEN': '+254', // Kenya
    'LSO': '+266', // Lesotho
    'LBR': '+231', // Liberia
    'LBY': '+218', // Libye
    'MDG': '+261', // Madagascar
    'MWI': '+265', // Malawi
    'MLI': '+223', // Mali
    'MRT': '+222', // Mauritanie
    'MUS': '+230', // Maurice
    'MAR': '+212', // Maroc
    'MOZ': '+258', // Mozambique
    'NAM': '+264', // Namibie
    'NER': '+227', // Niger
    'NGA': '+234', // Nigeria
    'RWA': '+250', // Rwanda
    'STP': '+239', // Sao Tomé-et-Principe
    'SEN': '+221', // Sénégal
    'SYC': '+248', // Seychelles
    'SLE': '+232', // Sierra Leone
    'SOM': '+252', // Somalie
    'ZAF': '+27',  // Afrique du Sud
    'SSD': '+211', // Soudan du Sud
    'SDN': '+249', // Soudan
    'TZA': '+255', // Tanzanie
    'TGO': '+228', // Togo
    'TUN': '+216', // Tunisie
    'UGA': '+256', // Ouganda
    'ZMB': '+260', // Zambie
    'ZWE': '+263', // Zimbabwe

    // Franc CFA
    'XOF': '+226', // Afrique de l'Ouest (UEMOA)
    'XAF': '+237', // Afrique Centrale (CEMAC)
      // Économies majeures
    'USA': '+1',   // États-Unis
    'CHN': '+86',  // Chine
    'JPN': '+81',  // Japon
    'DEU': '+49',  // Allemagne
    'IND': '+91',  // Inde
    'GBR': '+44',  // Royaume-Uni
    'FRA': '+33',  // France
    'ITA': '+39',  // Italie
    'BRA': '+55',  // Brésil
    'CAN': '+1',   // Canada
    'RUS': '+7',   // Russie
    'KOR': '+82',  // Corée du Sud
    'AUS': '+61',  // Australie
    'ESP': '+34',  // Espagne
    'MEX': '+52',  // Mexique
    'IDN': '+62',  // Indonésie
    'NLD': '+31',  // Pays-Bas
    'SAU': '+966', // Arabie Saoudite
    'TUR': '+90',  // Turquie
    'CHE': '+41',  // Suisse
    'ARG': '+54',  // Argentine
    'SWE': '+46',  // Suède
    'POL': '+48',  // Pologne
    'BEL': '+32',  // Belgique
    'THA': '+66',  // Thaïlande
    'IRN': '+98',  // Iran
    'AUT': '+43',  // Autriche
    'NOR': '+47',  // Norvège
    'ARE': '+971', // Émirats Arabes Unis
    'ISR': '+972', // Israël
    'SGP': '+65',  // Singapour
    'MYS': '+60',  // Malaisie
    'DNK': '+45',  // Danemark
  };

  String? geCountryFromCountyPhoneCode(String? phoneCode) {
    return countriesPhoneCode.entries
        .firstWhere((entry) => entry.value == phoneCode, orElse: () => MapEntry('', ''))
        .key;
  }
}