const express = require('express');
const router = express.Router();
const OAuthController = require('../controllers/oauthController');
const { authenticateToken } = require('../middlewares/auth');

router.get('/google', OAuthController.googleAuth);
router.get('/google/callback', OAuthController.googleCallback);
router.post('/google/mobile',  OAuthController.googleMobileValidation, OAuthController.googleMobile );
router.post('/apple', OAuthController.appleValidation, OAuthController.appleAuth );
router.post('/link', authenticateToken, OAuthController.linkOAuthValidation, OAuthController.linkOAuthAccount );
router.delete('/unlink/:provider', authenticateToken, OAuthController.unlinkOAuthAccount );
router.get('/status', authenticateToken, OAuthController.getOAuthStatus );

module.exports = router;
