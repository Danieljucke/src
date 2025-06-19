const app = require('./app');
const logger = require('./utils/logger');
const config = require('./config/database');

const PORT = process.env.PORT || 3000;
// Graceful shutdown
process.on('SIGTERM', () => {
    logger.info('SIGTERM received, shutting down gracefully');
    process.exit(0);
});

process.on('SIGINT', () => {
    logger.info('SIGINT received, shutting down gracefully');
    process.exit(0);
});

// Unhandled promise rejection
process.on('unhandledRejection', (err) => {
    logger.error('Unhandled Promise Rejection:', err);
    process.exit(1);
});

// Uncaught exception
process.on('uncaughtException', (err) => {
    logger.error('Uncaught Exception:', err);
    process.exit(1);
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});