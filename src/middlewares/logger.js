const logger = (req, res, next) => {
    const start = Date.now();
    
    res.on('finish', () => {
        const duration = Date.now() - start;
        const log = {
            method: req.method,
            url: req.url,
            status: res.statusCode,
            duration: `${duration}ms`,
            ip: req.ip,
            userAgent: req.get('User-Agent'),
            timestamp: new Date().toISOString()
        };
        
        if (req.user) {
            log.userId = req.user.user_id;
        }
        
        console.log(JSON.stringify(log));
    });
    
    next();
};

module.exports = logger;
