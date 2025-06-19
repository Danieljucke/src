const express = require('express');
const { body } = require('express-validator');
const BeneficiaryController = require('../controllers/beneficiaryController');
const { authenticateToken } = require('../middlewares/auth');

const router = express.Router();

// Validation rules
const beneficiaryValidation = [
    body('first_name').trim().isLength({ min: 2, max: 100 }),
    body('last_name').trim().isLength({ min: 2, max: 100 }),
    body('phone_number').optional().isMobilePhone(),
    body('email').optional().isEmail().normalizeEmail(),
    body('country_code').isLength({ min: 2, max: 3 }),
    body('relationship').optional().isLength({ max: 50 })
];

// Routes
router.post('/create', authenticateToken, beneficiaryValidation, BeneficiaryController.createBeneficiary);
router.get('/list', authenticateToken, BeneficiaryController.getUserBeneficiaries);
router.get('/:id', authenticateToken, BeneficiaryController.getBeneficiaryById);
router.put('/:id', authenticateToken, beneficiaryValidation, BeneficiaryController.updateBeneficiary);
router.delete('/:id', authenticateToken, BeneficiaryController.deleteBeneficiary);

module.exports = router;
