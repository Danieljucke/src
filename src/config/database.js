// Charger les variables d'environnement
require('dotenv').config();

const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error('Variables d\'environnement manquantes:');
    console.error('SUPABASE_URL:', supabaseUrl ? 'Définie' : 'Non définie');
    console.error('SUPABASE_ANON_KEY:', supabaseKey ? 'Définie' : 'Non définie');
    throw new Error('Missing Supabase configuration');
}

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = {
    supabase,
    supabaseUrl,
    supabaseKey
};