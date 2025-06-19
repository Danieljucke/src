const errorHandler = (err, req, res, next) => {
    console.error('Error:', err);

    // Default error
    let error = {
        success: false,
        message: err.message || 'Internal server error',
        status: err.status || 500
    };

    // Supabase errors
    if (err.code) {
        switch (err.code) {
            case '23505': // Unique violation
                error.message = 'Resource already exists';
                error.status = 409;
                break;
            case '23503': // Foreign key violation
                error.message = 'Referenced resource not found';
                error.status = 400;
                break;
            case '23514': // Check violation
                error.message = 'Invalid data provided';
                error.status = 400;
                break;
        }
    }

    // JWT errors
    if (err.name === 'JsonWebTokenError') {
        error.message = 'Invalid token';
        error.status = 401;
    }

    // Validation errors
    if (err.name === 'ValidationError') {
        error.message = 'Validation failed';
        error.status = 400;
        error.details = err.details;
    }

    res.status(error.status).json(error);
};

module.exports = errorHandler;
