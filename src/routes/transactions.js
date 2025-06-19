const express = require('express');
const { body } = require('express-validator');
const TransactionController = require('../controllers/transactionController');
const { authenticateToken, requireRole } = require('../middlewares/auth');

const router = express.Router();

// Validation rules
const transactionValidation = [
    body('beneficiary_id').isUUID(),
    body('amount_sent').isFloat({ min: 1, max: 999999 }),
    body('currency_sent').isLength({ min: 3, max: 3 }),
    body('payment_method').isIn(['BANK_TRANSFER', 'MOBILE_MONEY', 'CARD'])
];

// Routes
router.post('/create', authenticateToken, transactionValidation, TransactionController.createTransaction);
router.get('/user', authenticateToken, TransactionController.getUserTransactions);
router.get('/calculate-fees', TransactionController.calculateFees);
router.get('/:id', authenticateToken, TransactionController.getTransactionById);
router.patch('/:id/status', authenticateToken, TransactionController.updateTransactionStatus);
router.get('/', authenticateToken, requireRole(['ADMIN']), TransactionController.getAllTransactions);

module.exports = router;