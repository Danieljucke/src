const Beneficiary = require('../models/Beneficiary');
const { validationResult } = require('express-validator');

class BeneficiaryController {
    static async createBeneficiary(req, res, next) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const beneficiaryData = {
                ...req.body,
                user_id: req.user.user_id
            };

            const beneficiary = await Beneficiary.create(beneficiaryData);

            res.status(201).json({
                success: true,
                message: 'Beneficiary created successfully',
                data: { beneficiary }
            });
        } catch (error) {
            next(error);
        }
    }

    static async getUserBeneficiaries(req, res, next) {
        try {
            const beneficiaries = await Beneficiary.findByUserId(req.user.user_id);

            res.json({
                success: true,
                data: { beneficiaries }
            });
        } catch (error) {
            next(error);
        }
    }

    static async getBeneficiaryById(req, res, next) {
        try {
            const { id } = req.params;
            const beneficiary = await Beneficiary.findById(id);

            if (!beneficiary || beneficiary.user_id !== req.user.user_id) {
                return res.status(404).json({
                    success: false,
                    message: 'Beneficiary not found'
                });
            }

            res.json({
                success: true,
                data: { beneficiary }
            });
        } catch (error) {
            next(error);
        }
    }

    static async updateBeneficiary(req, res, next) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const { id } = req.params;
            const beneficiary = await Beneficiary.update(id, req.body, req.user.user_id);

            if (!beneficiary) {
                return res.status(404).json({
                    success: false,
                    message: 'Beneficiary not found'
                });
            }

            res.json({
                success: true,
                message: 'Beneficiary updated successfully',
                data: { beneficiary }
            });
        } catch (error) {
            next(error);
        }
    }

    static async deleteBeneficiary(req, res, next) {
        try {
            const { id } = req.params;
            const success = await Beneficiary.delete(id, req.user.user_id);

            if (!success) {
                return res.status(404).json({
                    success: false,
                    message: 'Beneficiary not found'
                });
            }

            res.json({
                success: true,
                message: 'Beneficiary deleted successfully'
            });
        } catch (error) {
            next(error);
        }
    }
}

module.exports = BeneficiaryController;
