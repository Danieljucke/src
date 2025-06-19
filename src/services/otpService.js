const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const nodemailer = require('nodemailer');

class OTPService {
    constructor() {
        // Configuration du transporteur email
        this.transporter = nodemailer.createTransport({
            host: process.env.SMTP_HOST || 'smtp.gmail.com',
            port: parseInt(process.env.SMTP_PORT) || 587,
            secure: false, // true pour 465, false pour d'autres ports
            auth: {
                user: process.env.SMTP_USER,
                pass: process.env.SMTP_PASS
            },
            tls: {
                rejectUnauthorized: false
            }
        });

        // Vérifier la configuration SMTP
        this.transporter.verify((error, success) => {
            if (error) {
                console.error('SMTP configuration error:', error);
            } else {
                console.log('SMTP server ready');
            }
        });
    }

    // Génère un OTP de 6 chiffres
    generateOTP() {
        const otp = Math.floor(1000 + Math.random() * 9000).toString();
        console.log('Generated OTP:', otp);
        return otp;
    }

    // Crée un token temporaire contenant l'OTP hashé et les données utilisateur
    createOTPToken(userData, otp, action = 'verify') {
        try {

            const hashedOTP = crypto.createHash('sha256').update(otp).digest('hex');
        
            const payload = {
                ...userData,
                hashedOTP,
                action,
                exp: Math.floor(Date.now() / 1000) + (10 * 60) // Expire dans 10 minutes
            };

            const secret = process.env.OTP_SECRET || 'otp-secret-key';

            const token = jwt.sign(payload, secret);
            
            return token;
        } catch (error) {
            console.error('Error creating OTP token:', error);
            throw error;
        }
    }

    // Vérifie l'OTP fourni par l'utilisateur
    verifyOTP(token, providedOTP) {
        try {
            console.log('Provided OTP:', providedOTP);

            if (!token || !providedOTP) {
                throw new Error('Token and OTP are required');
            }

            const secret = process.env.OTP_SECRET || 'otp-secret-key';
            const decoded = jwt.verify(token, secret);
            const hashedProvidedOTP = crypto.createHash('sha256').update(providedOTP.toString()).digest('hex');
           
            if (decoded.hashedOTP !== hashedProvidedOTP) {
                throw new Error('Invalid OTP');
            }

            // Retourne les données utilisateur sans l'OTP
            const { hashedOTP, exp, iat, ...userData } = decoded;
            return userData;
        } catch (error) {
            console.error('OTP verification error:', error);
            
            if (error.name === 'TokenExpiredError') {
                throw new Error('OTP expired');
            }
            if (error.name === 'JsonWebTokenError') {
                throw new Error('Invalid OTP token');
            }
            throw error;
        }
    }

    // Envoie l'OTP par email
    async sendOTPEmail(email, otp, firstName, action = 'verify') {
        try {

            if (!this.transporter) {
                throw new Error('Email transporter not configured');
            }

            const actionText = {
                'verify': 'check your account',
                'login': 'confirm your connection',
                'register': 'activate your account'
            };

             const mailOptions = {
            from: process.env.FROM_EMAIL || 'noreply@votreDomaine.com',
            to: email,
            subject: `Verification Code - ${otp}`,
            html: `
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Code de vérification</title>
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                        .content { background: #f9f9f9; padding: 30px; border: 1px solid #ddd; }
                        .otp-box { background: #fff; border: 2px solid #667eea; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0; }
                        .otp-code { font-size: 32px; font-weight: bold; color: #667eea; letter-spacing: 5px; margin: 10px 0; }
                        .warning { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }
                        .footer { background: #333; color: white; padding: 20px; text-align: center; border-radius: 0 0 10px 10px; font-size: 14px; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h1>🔐 Verification Code</h1>
                        </div>
                        
                        <div class="content">
                            <h2>Hello ${firstName} !,</h2>
                            <p>We have received a request for ${actionText[action]}. Use the verification code below :</p>
                            
                            <div class="otp-box">
                                <p style="margin: 0; font-size: 16px;">Your Verification code </p>
                                <div class="otp-code">${otp}</div>
                            </div>
                            
                            <div class="warning">
                                <strong>⚠️ Important :</strong>
                                <ul style="margin: 10px 0; padding-left: 20px;">
                                    <li>This code will expire in <strong>10 minutes</strong></li>
                                    <li>Never share this code with anyone.</li>
                                    <li>If you did not request this code, please ignore this email</li>
                                </ul>
                            </div>
                            
                            <p>If you have any questions, please contact our customer support.</p>
                            <p>Thanks,<br>The safety team</p>
                        </div>
                        
                        <div class="footer">
                            <p>This email has been sent automatically, please do not reply.</p>
                            <p>&copy; 2025 Wallet Africa. All rights reserved.</p>
                        </div>
                    </div>
                </body>
                </html>
            `
        };

            console.log('Mail options prepared:', { to: mailOptions.to, from: mailOptions.from });

            const info = await this.transporter.sendMail(mailOptions);
            console.log('Email sent successfully:', info.messageId);
            
            return true;
        } catch (error) {
            throw new Error('Failed to send OTP email: ' + error.message);
        }
    }

    // Méthode principale pour générer et envoyer l'OTP
    async generateAndSendOTP(userData, action = 'verify') {
        try {
            
            if (!userData || !userData.email) {
                throw new Error('User data and email are required');
            }

            const otp = this.generateOTP();
            const token = this.createOTPToken(userData, otp, action);
            
            await this.sendOTPEmail(
                userData.email, 
                otp, 
                userData.first_name || userData.firstName,
                action
            );
            return token;
        } catch (error) {
            console.error('Error in generateAndSendOTP:', error);
            throw error;
        }
    }
}

module.exports = new OTPService();