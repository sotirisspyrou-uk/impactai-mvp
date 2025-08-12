# Supporting Scripts for ImpactAI MVP

# =============================================================================
# setup.sh - Initial Project Setup Script
# =============================================================================

#!/bin/bash

echo "🚀 Setting up ImpactAI MVP Development Environment..."

# Check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js is required. Please install Node.js 18+ from https://nodejs.org/"
        exit 1
    fi
    
    # Check npm version
    NODE_VERSION=$(node -v | cut -d'v' -f2)
    if ! [[ $NODE_VERSION =~ ^1[8-9]|^[2-9][0-9] ]]; then
        echo "❌ Node.js 18+ is required. Current version: $NODE_VERSION"
        exit 1
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        echo "❌ Git is required. Please install Git from https://git-scm.com/"
        exit 1
    fi
    
    echo "✅ Prerequisites check passed"
}

# Setup project structure
setup_project_structure() {
    echo "Creating project structure..."
    
    mkdir -p {
        apps/{web,admin,api},
        packages/{ui,database,auth,config},
        docs/{api,user-guides,development},
        tests/{unit,integration,e2e},
        scripts/{build,deploy,maintenance},
        tools/{generators,validators},
        config/{environments,docker}
    }
    
    echo "✅ Project structure created"
}

# Initialize package.json
setup_package_json() {
    echo "Setting up package.json..."
    
    cat > package.json << 'EOF'
{
  "name": "impactai-mvp",
  "version": "1.0.0",
  "description": "Democratizing AI for Social Good Organizations",
  "main": "dist/index.js",
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "test": "turbo run test",
    "test:ci": "turbo run test:ci",
    "test:e2e": "turbo run test:e2e",
    "lint": "turbo run lint",
    "type-check": "turbo run type-check",
    "deploy:staging": "bash scripts/deploy-staging.sh",
    "deploy:prod": "bash scripts/deploy-production.sh",
    "db:migrate": "turbo run db:migrate",
    "db:seed": "turbo run db:seed",
    "setup": "bash scripts/setup.sh",
    "postinstall": "bash scripts/postinstall.sh"
  },
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "devDependencies": {
    "turbo": "^1.10.0",
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0",
    "eslint": "^8.0.0",
    "prettier": "^3.0.0",
    "jest": "^29.0.0",
    "playwright": "^1.35.0"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/sotirisspyrou-uk/impactai-mvp.git"
  },
  "author": "ImpactAI Team",
  "license": "MIT"
}
EOF
    
    echo "✅ package.json created"
}

# Setup environment files
setup_environment() {
    echo "Setting up environment configuration..."
    
    # Development environment
    cat > .env.example << 'EOF'
# Database
DATABASE_URL="postgresql://impactai:password@localhost:5432/impactai_dev"
REDIS_URL="redis://localhost:6379"

# AI Providers
OPENAI_API_KEY="your_openai_key_here"
ANTHROPIC_API_KEY="your_anthropic_key_here"
GOOGLE_AI_API_KEY="your_google_ai_key_here"

# Authentication
NEXTAUTH_SECRET="your_nextauth_secret_here"
NEXTAUTH_URL="http://localhost:3000"

# Google OAuth
GOOGLE_CLIENT_ID="your_google_client_id"
GOOGLE_CLIENT_SECRET="your_google_client_secret"

# File Storage
AWS_ACCESS_KEY_ID="your_aws_access_key"
AWS_SECRET_ACCESS_KEY="your_aws_secret_key"
AWS_S3_BUCKET="impactai-dev-files"
AWS_REGION="us-east-1"

# Monitoring
SENTRY_DSN="your_sentry_dsn"
MIXPANEL_TOKEN="your_mixpanel_token"

# Feature Flags
ENABLE_BETA_FEATURES="true"
ENABLE_AI_FINE_TUNING="false"
EOF

    cp .env.example .env.local
    
    echo "✅ Environment files created"
}

# Setup Git hooks
setup_git_hooks() {
    echo "Setting up Git hooks..."
    
    # Pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running pre-commit checks..."

# Run linting
npm run lint
if [ $? -ne 0 ]; then
    echo "❌ Linting failed. Please fix the issues before committing."
    exit 1
fi

# Run type checking
npm run type-check
if [ $? -ne 0 ]; then
    echo "❌ Type checking failed. Please fix the issues before committing."
    exit 1
fi

# Run tests
npm run test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Please fix the issues before committing."
    exit 1
fi

echo "✅ Pre-commit checks passed"
EOF

    chmod +x .git/hooks/pre-commit
    
    echo "✅ Git hooks configured"
}

# Setup Docker configuration
setup_docker() {
    echo "Setting up Docker configuration..."
    
    # Dockerfile for development
    cat > Dockerfile.dev << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Install development dependencies
RUN npm install --save-dev nodemon

EXPOSE 3000 3001 3002

CMD ["npm", "run", "dev"]
EOF

    # Docker Compose for development
    cat > docker-compose.dev.yml << 'EOF'
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules
    env_file:
      - .env.local
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: impactai_dev
      POSTGRES_USER: impactai
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
EOF
    
    echo "✅ Docker configuration created"
}

# Main setup function
main() {
    check_prerequisites
    setup_project_structure
    setup_package_json
    setup_environment
    setup_git_hooks
    setup_docker
    
    echo ""
    echo "🎉 ImpactAI MVP development environment setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Update .env.local with your API keys"
    echo "2. Run 'npm install' to install dependencies"
    echo "3. Run 'npm run dev' to start development"
    echo ""
    echo "For more information, see the README.md file."
}

main "$@"

# =============================================================================
# deploy-staging.sh - Staging Deployment Script
# =============================================================================

#!/bin/bash

echo "🚀 Deploying ImpactAI MVP to Staging..."

# Configuration
STAGING_ENV="staging"
DOCKER_IMAGE="impactai/mvp:staging-$(git rev-parse --short HEAD)"

# Pre-deployment checks
check_staging_prerequisites() {
    echo "Running pre-deployment checks..."
    
    # Check if on correct branch
    BRANCH=$(git branch --show-current)
    if [ "$BRANCH" != "develop" ]; then
        echo "❌ Must be on 'develop' branch for staging deployment. Current: $BRANCH"
        exit 1
    fi
    
    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo "❌ You have uncommitted changes. Please commit or stash them."
        exit 1
    fi
    
    # Run tests
    echo "Running tests..."
    npm run test:ci
    if [ $? -ne 0 ]; then
        echo "❌ Tests failed. Deployment aborted."
        exit 1
    fi
    
    echo "✅ Pre-deployment checks passed"
}

# Build and push Docker image
build_and_push() {
    echo "Building Docker image..."
    
    docker build -t $DOCKER_IMAGE .
    if [ $? -ne 0 ]; then
        echo "❌ Docker build failed"
        exit 1
    fi
    
    echo "Pushing to registry..."
    docker push $DOCKER_IMAGE
    if [ $? -ne 0 ]; then
        echo "❌ Docker push failed"
        exit 1
    fi
    
    echo "✅ Docker image built and pushed"
}

# Deploy to staging environment
deploy_to_staging() {
    echo "Deploying to staging environment..."
    
    # Update Kubernetes deployment
    kubectl set image deployment/impactai-staging impactai=$DOCKER_IMAGE
    
    # Wait for rollout to complete
    kubectl rollout status deployment/impactai-staging --timeout=600s
    
    if [ $? -eq 0 ]; then
        echo "✅ Deployment successful"
    else
        echo "❌ Deployment failed"
        kubectl rollout undo deployment/impactai-staging
        exit 1
    fi
}

# Run post-deployment tests
run_smoke_tests() {
    echo "Running smoke tests..."
    
    # Wait for pods to be ready
    sleep 30
    
    # Health check
    HEALTH_URL="https://staging.impactai.org/health"
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_URL)
    
    if [ "$HTTP_STATUS" == "200" ]; then
        echo "✅ Health check passed"
    else
        echo "❌ Health check failed (HTTP $HTTP_STATUS)"
        exit 1
    fi
    
    # Run end-to-end tests
    npm run test:e2e:staging
    if [ $? -ne 0 ]; then
        echo "❌ E2E tests failed"
        exit 1
    fi
    
    echo "✅ Smoke tests passed"
}

# Send deployment notification
notify_deployment() {
    echo "Sending deployment notification..."
    
    COMMIT_HASH=$(git rev-parse --short HEAD)
    COMMIT_MESSAGE=$(git log -1 --pretty=%B)
    
    curl -X POST "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK" \
        -H 'Content-type: application/json' \
        --data "{
            \"text\": \"🚀 ImpactAI MVP deployed to staging\",
            \"attachments\": [{
                \"color\": \"good\",
                \"fields\": [
                    {\"title\": \"Environment\", \"value\": \"staging\", \"short\": true},
                    {\"title\": \"Commit\", \"value\": \"$COMMIT_HASH\", \"short\": true},
                    {\"title\": \"Message\", \"value\": \"$COMMIT_MESSAGE\", \"short\": false}
                ]
            }]
        }"
    
    echo "✅ Deployment notification sent"
}

# Main deployment function
main() {
    check_staging_prerequisites
    build_and_push
    deploy_to_staging
    run_smoke_tests
    notify_deployment
    
    echo ""
    echo "🎉 Staging deployment complete!"
    echo "🌐 URL: https://staging.impactai.org"
    echo "📊 Monitoring: https://monitoring.impactai.org/staging"
}

main "$@"

# =============================================================================
# validation.js - Data Validation and Ethics Checking
# =============================================================================

const Joi = require('joi');
const axios = require('axios');

// Organization verification schema
const organizationSchema = Joi.object({
    name: Joi.string().min(2).max(100).required(),
    type: Joi.string().valid(
        'nonprofit',
        'ngo',
        'social-enterprise',
        'government',
        'academic',
        'foundation'
    ).required(),
    taxId: Joi.string().pattern(/^[0-9]{2}-[0-9]{7}$/).required(),
    website: Joi.string().uri().required(),
    focusAreas: Joi.array().items(
        Joi.string().valid(
            'education',
            'healthcare',
            'environment',
            'poverty',
            'human-rights',
            'disaster-relief',
            'arts-culture',
            'community-development'
        )
    ).min(1).max(5).required(),
    geography: Joi.object({
        country: Joi.string().length(2).required(),
        regions: Joi.array().items(Joi.string()).max(10),
        global: Joi.boolean().default(false)
    }).required(),
    beneficiaries: Joi.object({
        primaryAge: Joi.string().valid(
            'children',
            'youth',
            'adults',
            'elderly',
            'all-ages'
        ).required(),
        demographics: Joi.array().items(
            Joi.string().valid(
                'low-income',
                'minorities',
                'refugees',
                'disabled',
                'indigenous',
                'lgbtq',
                'women',
                'general'
            )
        ).min(1).required(),
        estimatedReach: Joi.number().integer().min(1).max(1000000000)
    }).required()
});

// Bias detection keywords
const biasKeywords = {
    demographic: [
        'target wealthy', 'exclude poor', 'only rich', 'avoid minorities',
        'target white', 'exclude immigrants', 'only citizens'
    ],
    cultural: [
        'western approach only', 'ignore local customs', 'american way',
        'developed world standards', 'civilized nations'
    ],
    economic: [
        'enterprise only', 'high-end solution', 'premium approach',
        'expensive technology', 'corporate-grade only'
    ],
    technical: [
        'assume coding knowledge', 'technical expertise required',
        'advanced users only', 'programming background needed'
    ]
};

// Ethics validation functions
async function validateOrganization(orgData) {
    try {
        const validatedOrg = await organizationSchema.validateAsync(orgData);
        
        // Additional verification checks
        const verificationResults = await Promise.all([
            verifyTaxExemptStatus(validatedOrg.taxId, validatedOrg.geography.country),
            verifyWebsiteAuthenticity(validatedOrg.website),
            checkOrganizationReputation(validatedOrg.name)
        ]);
        
        return {
            valid: true,
            organization: validatedOrg,
            verification: {
                taxExempt: verificationResults[0],
                websiteValid: verificationResults[1],
                reputationCheck: verificationResults[2]
            }
        };
    } catch (error) {
        return {
            valid: false,
            errors: error.details?.map(detail => detail.message) || [error.message]
        };
    }
}

async function verifyTaxExemptStatus(taxId, country) {
    // Mock implementation - in production, integrate with tax authority APIs
    if (country === 'US') {
        // Integrate with IRS API for 501(c)(3) verification
        return { verified: true, status: '501c3', confidence: 0.95 };
    }
    
    return { verified: false, reason: 'Country not supported for automatic verification' };
}

async function verifyWebsiteAuthenticity(website) {
    try {
        const response = await axios.get(website, { timeout: 5000 });
        
        // Check for indicators of legitimate nonprofit website
        const indicators = {
            hasAboutSection: response.data.includes('about') || response.data.includes('mission'),
            hasDonationPage: response.data.includes('donate') || response.data.includes('support'),
            hasContactInfo: response.data.includes('contact') || response.data.includes('address'),
            hasSSL: website.startsWith('https://'),
            responsiveDesign: response.data.includes('viewport') || response.data.includes('responsive')
        };
        
        const score = Object.values(indicators).filter(Boolean).length / Object.keys(indicators).length;
        
        return {
            valid: score >= 0.6,
            score: score,
            indicators: indicators
        };
    } catch (error) {
        return {
            valid: false,
            error: error.message
        };
    }
}

async function checkOrganizationReputation(orgName) {
    // Mock implementation - in production, integrate with charity navigator, GuideStar, etc.
    const mockRatings = {
        'doctors without borders': { rating: 4.8, source: 'CharityNavigator' },
        'red cross': { rating: 4.5, source: 'CharityNavigator' },
        'oxfam': { rating: 4.3, source: 'CharityNavigator' }
    };
    
    const normalizedName = orgName.toLowerCase();
    const foundRating = Object.keys(mockRatings).find(key => 
        normalizedName.includes(key) || key.includes(normalizedName)
    );
    
    if (foundRating) {
        return {
            found: true,
            rating: mockRatings[foundRating],
            trusted: mockRatings[foundRating].rating >= 4.0
        };
    }
    
    return {
        found: false,
        suggestion: 'Manual verification recommended'
    };
}

function detectBias(text, context = {}) {
    const results = {
        overall: 0,
        categories: {
            demographic: 0,
            cultural: 0,
            economic: 0,
            technical: 0
        },
        detectedTerms: [],
        suggestions: []
    };
    
    const lowerText = text.toLowerCase();
    
    // Check each bias category
    Object.keys(biasKeywords).forEach(category => {
        const categoryTerms = biasKeywords[category];
        const foundTerms = categoryTerms.filter(term => lowerText.includes(term));
        
        if (foundTerms.length > 0) {
            results.categories[category] = foundTerms.length / categoryTerms.length;
            results.detectedTerms.push(...foundTerms);
        }
    });
    
    // Calculate overall bias score
    results.overall = Object.values(results.categories).reduce((sum, score) => sum + score, 0) / 4;
    
    // Generate suggestions based on detected bias
    if (results.categories.demographic > 0.3) {
        results.suggestions.push('Consider inclusive language that welcomes all demographics');
    }
    if (results.categories.economic > 0.3) {
        results.suggestions.push('Include low-cost and free alternatives');
    }
    if (results.categories.technical > 0.3) {
        results.suggestions.push('Provide solutions for varying technical skill levels');
    }
    if (results.categories.cultural > 0.3) {
        results.suggestions.push('Acknowledge diverse cultural contexts and practices');
    }
    
    return results;
}

function validateAIResponse(response, originalRequest) {
    const validation = {
        safe: true,
        issues: [],
        score: 0,
        improvements: []
    };
    
    // Check for bias in response
    const biasCheck = detectBias(response, originalRequest.context);
    if (biasCheck.overall > 0.5) {
        validation.issues.push('High bias detected in response');
        validation.safe = false;
    }
    
    // Check for harmful content
    const harmfulIndicators = [
        'discriminate against',
        'exclude based on',
        'target only wealthy',
        'ignore local needs',
        'western standards only'
    ];
    
    const foundHarmful = harmfulIndicators.filter(indicator => 
        response.toLowerCase().includes(indicator)
    );
    
    if (foundHarmful.length > 0) {
        validation.issues.push('Potentially harmful content detected');
        validation.safe = false;
    }
    
    // Check for actionability
    const actionIndicators = [
        'step', 'action', 'implement', 'start', 'begin',
        'create', 'develop', 'establish', 'contact'
    ];
    
    const actionScore = actionIndicators.filter(indicator => 
        response.toLowerCase().includes(indicator)
    ).length / actionIndicators.length;
    
    validation.score = Math.max(0, 1 - biasCheck.overall) * 0.4 + actionScore * 0.6;
    
    // Generate improvement suggestions
    if (biasCheck.overall > 0.3) {
        validation.improvements.push('Reduce biased language and assumptions');
    }
    if (actionScore < 0.5) {
        validation.improvements.push('Include more specific, actionable recommendations');
    }
    
    return validation;
}

module.exports = {
    validateOrganization,
    detectBias,
    validateAIResponse,
    organizationSchema
};

# =============================================================================
# monitoring.js - System Monitoring and Analytics
# =============================================================================

const prometheus = require('prom-client');
const winston = require('winston');

// Prometheus metrics
const httpRequestDuration = new prometheus.Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'route', 'status_code']
});

const aiRequestsTotal = new prometheus.Counter({
    name: 'ai_requests_total',
    help: 'Total number of AI requests',
    labelNames: ['provider', 'model', 'organization_type']
});

const biasDetectedTotal = new prometheus.Counter({
    name: 'bias_detected_total',
    help: 'Total number of bias incidents detected',
    labelNames: ['bias_type', 'severity']
});

const impactScoreHistogram = new prometheus.Histogram({
    name: 'impact_score',
    help: 'Distribution of impact scores',
    buckets: [0.1, 0.3, 0.5, 0.7, 0.9, 1.0]
});

// Winston logger configuration
const logger = winston.createLogger({
    level: 'info',
    format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.errors({ stack: true }),
        winston.format.json()
    ),
    defaultMeta: { service: 'impactai-mvp' },
    transports: [
        new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
        new winston.transports.File({ filename: 'logs/combined.log' }),
        new winston.transports.Console({
            format: winston.format.simple()
        })
    ]
});

// Monitoring middleware
function createMonitoringMiddleware() {
    return (req, res, next) => {
        const start = Date.now();
        
        res.on('finish', () => {
            const duration = (Date.now() - start) / 1000;
            
            httpRequestDuration
                .labels(req.method, req.route?.path || req.path, res.statusCode)
                .observe(duration);
            
            logger.info('HTTP Request', {
                method: req.method,
                url: req.url,
                statusCode: res.statusCode,
                duration: duration,
                userAgent: req.get('User-Agent'),
                ip: req.ip
            });
        });
        
        next();
    };
}

// AI interaction logging
function logAIInteraction(data) {
    const {
        provider,
        model,
        organizationType,
        request,
        response,
        biasScore,
        impactScore,
        processingTime
    } = data;
    
    // Update metrics
    aiRequestsTotal.labels(provider, model, organizationType).inc();
    impactScoreHistogram.observe(impactScore);
    
    if (biasScore > 0.5) {
        biasDetectedTotal.labels('overall', 'medium').inc();
    }
    if (biasScore > 0.7) {
        biasDetectedTotal.labels('overall', 'high').inc();
    }
    
    // Log interaction
    logger.info('AI Interaction', {
        provider,
        model,
        organizationType,
        biasScore,
        impactScore,
        processingTime,
        requestLength: request.length,
        responseLength: response.length,
        timestamp: new Date().toISOString()
    });
}

// Health check endpoint
function createHealthCheck() {
    return async (req, res) => {
        const health = {
            status: 'healthy',
            timestamp: new Date().toISOString(),
            uptime: process.uptime(),
            memory: process.memoryUsage(),
            checks: {}
        };
        
        // Database check
        try {
            // Add actual database connection check here
            health.checks.database = 'healthy';
        } catch (error) {
            health.checks.database = 'unhealthy';
            health.status = 'unhealthy';
        }
        
        // Redis check
        try {
            // Add actual Redis connection check here
            health.checks.redis = 'healthy';
        } catch (error) {
            health.checks.redis = 'unhealthy';
            health.status = 'unhealthy';
        }
        
        // AI providers check
        health.checks.aiProviders = {
            openai: 'healthy', // Add actual checks
            anthropic: 'healthy',
            google: 'healthy'
        };
        
        const statusCode = health.status === 'healthy' ? 200 : 503;
        res.status(statusCode).json(health);
    };
}

// Error handling and alerting
function handleError(error, context = {}) {
    logger.error('Application Error', {
        error: error.message,
        stack: error.stack,
        context
    });
    
    // Send alert for critical errors
    if (error.severity === 'critical') {
        sendAlert('Critical Error', {
            error: error.message,
            context,
            timestamp: new Date().toISOString()
        });
    }
}

async function sendAlert(title, details) {
    // Integration with alerting services (Slack, PagerDuty, etc.)
    try {
        await fetch(process.env.SLACK_WEBHOOK_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                text: `🚨 ${title}`,
                attachments: [{
                    color: 'danger',
                    fields: Object.entries(details).map(([key, value]) => ({
                        title: key,
                        value: typeof value === 'object' ? JSON.stringify(value) : value,
                        short: true
                    }))
                }]
            })
        });
    } catch (alertError) {
        logger.error('Failed to send alert', { alertError: alertError.message });
    }
}

module.exports = {
    createMonitoringMiddleware,
    logAIInteraction,
    createHealthCheck,
    handleError,
    logger,
    // Export metrics for Prometheus scraping
    register: prometheus.register
};

# =============================================================================
# postinstall.sh - Post-installation setup
# =============================================================================

#!/bin/bash

echo "Running post-installation setup..."

# Create necessary directories
mkdir -p logs
mkdir -p uploads
mkdir -p backups

# Set up development database
if command -v docker &> /dev/null; then
    echo "Setting up development database with Docker..."
    docker-compose -f docker-compose.dev.yml up -d postgres redis
    
    # Wait for database to be ready
    echo "Waiting for database to be ready..."
    sleep 10
    
    # Run database migrations
    npm run db:migrate
    npm run db:seed
else
    echo "Docker not found. Please set up PostgreSQL and Redis manually."
fi

# Install Playwright browsers
if command -v npx &> /dev/null; then
    echo "Installing Playwright browsers..."
    npx playwright install
fi

# Create sample configuration files
if [ ! -f "config/local.yml" ]; then
    cp config/development.yml config/local.yml
    echo "Created local configuration file"
fi

echo "✅ Post-installation setup complete"

echo ""
echo "🎉 ImpactAI MVP is ready for development!"
echo ""
echo "To get started:"
echo "1. Update .env.local with your API keys"
echo "2. Run 'npm run dev' to start the development server"
echo "3. Visit http://localhost:3000 to see the application"
echo ""
