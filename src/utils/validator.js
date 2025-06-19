const { body, param, query } = require('express-validator');

const validators = {
    // User validation
    userRegistration: [
        body('email').isEmail().normalizeEmail(),
        body('phone_number').isMobilePhone(),
        body('first_name').trim().isLength({ min: 2, max: 100 }),
        body('last_name').trim().isLength({ min: 2, max: 100 }),
        body('password').isLength({ min: 8 }).matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/),
        body('country_code').isLength({ min: 2, max: 3 }),
        body('user_type').isIn(['SENDER', 'RECEIVER'])
    ],

    // Transaction validation
    createTransaction: [
        body('beneficiary_id').isUUID(),
        body('amount_sent').isFloat({ min: 1, max: 999999 }),
        body('currency_sent').isLength({ min: 3, max: 3 }),
        body('payment_method').isIn(['BANK_TRANSFER', 'MOBILE_MONEY', 'CARD'])
    ],

    // Beneficiary validation
    createBeneficiary: [
        body('first_name').trim().isLength({ min: 2, max: 100 }),
        body('last_name').trim().isLength({ min: 2, max: 100 }),
        body('phone_number').optional().isMobilePhone(),
        body('email').optional().isEmail().normalizeEmail(),
        body('country_code').isLength({ min: 2, max: 3 }),
        body('relationship').optional().isLength({ max: 50 })
    ],

    // Parameter validation
    uuidParam: [
        param('id').isUUID()
    ],

    // Query validation
    pagination: [
        query('page').optional().isInt({ min: 1 }),
        query('limit').optional().isInt({ min: 1, max: 100 })
    ]
};

module.exports = validators;
