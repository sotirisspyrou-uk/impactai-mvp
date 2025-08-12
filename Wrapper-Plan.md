# ImpactAI System Prompt Wrapper - Implementation Plan

## Overview

This document outlines the technical approach for creating a robust wrapper system around the ImpactAI system prompt that can work across multiple AI providers (OpenAI, Anthropic, Google, etc.) while maintaining consistent behavior, ethics enforcement, and social good optimization.

## Architecture Design

### Core Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    ImpactAI Wrapper System                     │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Request        │  │   Ethics        │  │   Response      │ │
│  │  Preprocessor   │  │   Validator     │  │   Postprocessor │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Bias Detection │  │  Content Filter │  │  Impact Scorer  │ │
│  │  Engine         │  │  & Safety       │  │  & Metrics      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                    AI Provider Router                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌───────────┐ │
│  │   OpenAI    │ │  Anthropic  │ │   Google    │ │  Hugging  │ │
│  │   GPT-4     │ │   Claude    │ │   Gemini    │ │   Face    │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └───────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Context Store  │  │  Session Mgmt   │  │  Audit Log      │ │
│  │  (Org Profile) │  │  & History      │  │  & Analytics    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Technology Stack

**Backend Framework**: Node.js with TypeScript
**API Framework**: Express.js with tRPC for type safety
**Database**: PostgreSQL with Prisma ORM
**Caching**: Redis for session and context management
**Message Queue**: Bull Queue for async processing
**Monitoring**: Sentry for error tracking, DataDog for metrics

## Implementation Components

### 1. Request Preprocessor

```typescript
interface ImpactAIRequest {
  userMessage: string;
  organizationContext: OrganizationProfile;
  sessionContext: SessionHistory;
  userProfile: UserProfile;
  requestType: 'query' | 'generation' | 'analysis' | 'collaboration';
}

class RequestPreprocessor {
  async processRequest(request: ImpactAIRequest): Promise<ProcessedRequest> {
    // 1. Context enrichment
    const enrichedContext = await this.enrichContext(request);
    
    // 2. Intent classification
    const intent = await this.classifyIntent(request.userMessage);
    
    // 3. Risk assessment
    const riskLevel = await this.assessRisk(request);
    
    // 4. System prompt selection
    const systemPrompt = await this.selectSystemPrompt(intent, riskLevel);
    
    return {
      ...request,
      enrichedContext,
      intent,
      riskLevel,
      systemPrompt
    };
  }

  private async enrichContext(request: ImpactAIRequest): Promise<EnrichedContext> {
    return {
      organizationType: request.organizationContext.type,
      focusAreas: request.organizationContext.focusAreas,
      beneficiaryDemographics: request.organizationContext.beneficiaries,
      geographicContext: request.organizationContext.geography,
      technicalCapacity: request.organizationContext.techCapacity,
      budgetConstraints: request.organizationContext.budget,
      regulatoryEnvironment: await this.getRegulationsByGeo(
        request.organizationContext.geography
      )
    };
  }
}
```

### 2. Ethics Validator & Bias Detection

```typescript
interface EthicsCheck {
  biasScore: number;
  harmRisk: 'low' | 'medium' | 'high';
  culturalSensitivity: boolean;
  vulnerablePopulationImpact: boolean;
  recommendations: string[];
}

class EthicsValidator {
  async validateRequest(request: ProcessedRequest): Promise<EthicsCheck> {
    const checks = await Promise.all([
      this.checkBias(request),
      this.assessHarmRisk(request),
      this.validateCulturalSensitivity(request),
      this.checkVulnerablePopulations(request)
    ]);

    return this.synthesizeEthicsCheck(checks);
  }

  private async checkBias(request: ProcessedRequest): Promise<BiasAssessment> {
    // Use multiple bias detection models
    const [
      demographicBias,
      economicBias,
      culturalBias,
      technicalBias
    ] = await Promise.all([
      this.detectDemographicBias(request.userMessage),
      this.detectEconomicBias(request.enrichedContext),
      this.detectCulturalBias(request.enrichedContext.geographicContext),
      this.detectTechnicalBias(request.enrichedContext.technicalCapacity)
    ]);

    return {
      overall: Math.max(demographicBias, economicBias, culturalBias, technicalBias),
      breakdown: { demographicBias, economicBias, culturalBias, technicalBias },
      mitigationStrategies: this.generateMitigationStrategies(...)
    };
  }
}
```

### 3. AI Provider Router

```typescript
interface AIProvider {
  name: string;
  model: string;
  capabilities: string[];
  costPerToken: number;
  maxTokens: number;
  specializations: string[];
}

class AIProviderRouter {
  private providers: Map<string, AIProvider> = new Map([
    ['openai-gpt4', {
      name: 'OpenAI',
      model: 'gpt-4-turbo-preview',
      capabilities: ['text', 'reasoning', 'code'],
      costPerToken: 0.00003,
      maxTokens: 4096,
      specializations: ['general', 'technical']
    }],
    ['anthropic-claude', {
      name: 'Anthropic',
      model: 'claude-3-opus',
      capabilities: ['text', 'reasoning', 'safety'],
      costPerToken: 0.000015,
      maxTokens: 4096,
      specializations: ['ethics', 'safety', 'complex-reasoning']
    }],
    ['google-gemini', {
      name: 'Google',
      model: 'gemini-pro',
      capabilities: ['text', 'multimodal', 'search'],
      costPerToken: 0.00001,
      maxTokens: 2048,
      specializations: ['research', 'factual']
    }]
  ]);

  async selectProvider(request: ProcessedRequest): Promise<string> {
    const requirements = this.analyzeRequirements(request);
    
    // Score providers based on:
    // 1. Capability match
    // 2. Cost efficiency
    // 3. Specialization alignment
    // 4. Current load/availability
    
    const scores = new Map<string, number>();
    
    for (const [id, provider] of this.providers) {
      const capabilityScore = this.scoreCapabilities(provider, requirements);
      const costScore = this.scoreCost(provider, requirements);
      const specializationScore = this.scoreSpecialization(provider, request.intent);
      const availabilityScore = await this.checkAvailability(id);
      
      const totalScore = (
        capabilityScore * 0.4 +
        costScore * 0.2 +
        specializationScore * 0.3 +
        availabilityScore * 0.1
      );
      
      scores.set(id, totalScore);
    }
    
    return Array.from(scores.entries())
      .sort(([,a], [,b]) => b - a)[0][0];
  }
}
```

### 4. Response Postprocessor

```typescript
class ResponsePostprocessor {
  async processResponse(
    response: string,
    originalRequest: ProcessedRequest
  ): Promise<ProcessedResponse> {
    // 1. Content validation
    const contentValidation = await this.validateContent(response);
    
    // 2. Impact scoring
    const impactScore = await this.scoreImpact(response, originalRequest);
    
    // 3. Bias detection in response
    const responseEthicsCheck = await this.checkResponseEthics(response);
    
    // 4. Actionability enhancement
    const enhancedResponse = await this.enhanceActionability(
      response,
      originalRequest.enrichedContext
    );
    
    // 5. Resource enrichment
    const enrichedResponse = await this.addResources(
      enhancedResponse,
      originalRequest.intent
    );
    
    return {
      content: enrichedResponse,
      impactScore,
      ethicsValidation: responseEthicsCheck,
      confidence: contentValidation.confidence,
      suggestions: this.generateFollowUpSuggestions(originalRequest),
      resources: this.gatherRelevantResources(originalRequest)
    };
  }

  private async scoreImpact(
    response: string,
    request: ProcessedRequest
  ): Promise<ImpactScore> {
    // Score based on potential social impact
    const metrics = {
      beneficiaryReach: this.estimateBeneficiaryReach(response),
      costEffectiveness: this.estimateCostEffectiveness(response),
      sustainabilityScore: this.assessSustainability(response),
      equityScore: this.assessEquity(response),
      innovationScore: this.assessInnovation(response),
      feasibilityScore: this.assessFeasibility(response, request.enrichedContext)
    };

    return {
      overall: this.calculateOverallImpact(metrics),
      breakdown: metrics,
      improvements: this.suggestImprovements(metrics)
    };
  }
}
```

### 5. System Prompt Manager

```typescript
class SystemPromptManager {
  private prompts: Map<string, SystemPromptTemplate> = new Map();

  constructor() {
    this.loadPrompts();
  }

  async getSystemPrompt(
    intent: string,
    context: EnrichedContext,
    riskLevel: string
  ): Promise<string> {
    const basePrompt = this.prompts.get('base-social-good');
    const intentPrompt = this.prompts.get(`intent-${intent}`);
    const riskPrompt = this.prompts.get(`risk-${riskLevel}`);
    
    return this.combinePrompts([
      basePrompt,
      intentPrompt,
      riskPrompt,
      this.generateContextualPrompt(context)
    ]);
  }

  private generateContextualPrompt(context: EnrichedContext): string {
    return `
      Organization Context:
      - Type: ${context.organizationType}
      - Focus Areas: ${context.focusAreas.join(', ')}
      - Geographic Context: ${context.geographicContext}
      - Technical Capacity: ${context.technicalCapacity}
      - Budget Level: ${context.budgetConstraints}
      
      Special Considerations:
      - Regulatory Environment: ${context.regulatoryEnvironment}
      - Beneficiary Demographics: ${context.beneficiaryDemographics}
      
      Adaptation Instructions:
      - Adjust technical complexity to match organization capacity
      - Consider local cultural and regulatory context
      - Prioritize cost-effective solutions within budget constraints
      - Ensure recommendations are appropriate for beneficiary demographics
    `;
  }
}
```

## Safety & Monitoring Systems

### Real-time Monitoring

```typescript
class SafetyMonitor {
  async monitorInteraction(
    request: ProcessedRequest,
    response: ProcessedResponse
  ): Promise<SafetyReport> {
    const alerts = [];

    // Real-time bias detection
    if (response.ethicsValidation.biasScore > 0.7) {
      alerts.push({
        type: 'HIGH_BIAS_DETECTED',
        severity: 'HIGH',
        details: response.ethicsValidation.breakdown
      });
    }

    // Harm risk assessment
    if (response.ethicsValidation.harmRisk === 'high') {
      alerts.push({
        type: 'POTENTIAL_HARM_RISK',
        severity: 'CRITICAL',
        action: 'REQUIRES_HUMAN_REVIEW'
      });
    }

    // Impact quality check
    if (response.impactScore.overall < 0.3) {
      alerts.push({
        type: 'LOW_IMPACT_RESPONSE',
        severity: 'MEDIUM',
        suggestion: 'SUGGEST_ALTERNATIVE_APPROACH'
      });
    }

    return {
      safe: alerts.filter(a => a.severity === 'CRITICAL').length === 0,
      alerts,
      recommendations: this.generateSafetyRecommendations(alerts)
    };
  }
}
```

### Audit & Analytics

```typescript
interface InteractionLog {
  timestamp: Date;
  organizationId: string;
  userId: string;
  request: ProcessedRequest;
  response: ProcessedResponse;
  safetyReport: SafetyReport;
  userFeedback?: UserFeedback;
  outcome?: InteractionOutcome;
}

class AuditLogger {
  async logInteraction(log: InteractionLog): Promise<void> {
    // Store in database with encryption
    await this.database.interactions.create({
      data: {
        ...log,
        encryptedRequest: await this.encrypt(log.request),
        encryptedResponse: await this.encrypt(log.response)
      }
    });

    // Update analytics
    await this.updateAnalytics(log);
    
    // Check for patterns requiring attention
    await this.patternAnalysis(log);
  }

  async generateComplianceReport(
    startDate: Date,
    endDate: Date
  ): Promise<ComplianceReport> {
    const interactions = await this.getInteractions(startDate, endDate);
    
    return {
      totalInteractions: interactions.length,
      biasIncidents: interactions.filter(i => i.safetyReport.alerts.some(a => a.type === 'HIGH_BIAS_DETECTED')),
      harmRiskIncidents: interactions.filter(i => i.safetyReport.alerts.some(a => a.type === 'POTENTIAL_HARM_RISK')),
      averageImpactScore: this.calculateAverageImpact(interactions),
      userSatisfactionScore: this.calculateSatisfaction(interactions),
      recommendations: this.generateSystemImprovements(interactions)
    };
  }
}
```

## Configuration & Deployment

### Environment Configuration

```yaml
# config/development.yml
ai_providers:
  openai:
    api_key: ${OPENAI_API_KEY}
    model: "gpt-4-turbo-preview"
    max_tokens: 4096
    temperature: 0.7
  
  anthropic:
    api_key: ${ANTHROPIC_API_KEY}
    model: "claude-3-opus-20240229"
    max_tokens: 4096
    temperature: 0.7
  
  google:
    api_key: ${GOOGLE_AI_API_KEY}
    model: "gemini-pro"
    max_tokens: 2048
    temperature: 0.7

safety:
  bias_threshold: 0.7
  harm_risk_threshold: "medium"
  require_human_review: ["high_risk", "vulnerable_populations", "legal_advice"]
  
ethics:
  enable_bias_detection: true
  enable_cultural_sensitivity: true
  enable_harm_prevention: true
  audit_all_interactions: true

performance:
  max_response_time: 30000  # 30 seconds
  rate_limit_per_minute: 60
  cache_ttl: 3600  # 1 hour
```

### Docker Configuration

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application code
COPY dist/ ./dist/
COPY config/ ./config/

# Set environment
ENV NODE_ENV=production
ENV PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000

CMD ["node", "dist/index.js"]
```

### Kubernetes Deployment

```yaml
# k8s/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: impactai-wrapper
spec:
  replicas: 3
  selector:
    matchLabels:
      app: impactai-wrapper
  template:
    metadata:
      labels:
        app: impactai-wrapper
    spec:
      containers:
      - name: wrapper
        image: impactai/wrapper:latest
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: impactai-secrets
              key: database-url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: impactai-secrets
              key: redis-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

## Testing Strategy

### Unit Tests

```typescript
// tests/ethics-validator.test.ts
describe('EthicsValidator', () => {
  let validator: EthicsValidator;

  beforeEach(() => {
    validator = new EthicsValidator();
  });

  describe('bias detection', () => {
    it('should detect demographic bias in requests', async () => {
      const request = createMockRequest({
        userMessage: "Help me target wealthy donors only"
      });

      const result = await validator.checkBias(request);
      
      expect(result.demographicBias).toBeGreaterThan(0.5);
      expect(result.mitigationStrategies).toContain('inclusive-outreach');
    });

    it('should detect economic bias', async () => {
      const request = createMockRequest({
        enrichedContext: {
          budgetConstraints: 'unlimited',
          technicalCapacity: 'enterprise'
        }
      });

      const result = await validator.checkBias(request);
      
      expect(result.economicBias).toBeGreaterThan(0.3);
    });
  });
});
```

### Integration Tests

```typescript
// tests/integration/wrapper-flow.test.ts
describe('Complete Wrapper Flow', () => {
  it('should process social good request end-to-end', async () => {
    const request: ImpactAIRequest = {
      userMessage: "Help me write a grant proposal for climate education",
      organizationContext: mockOrganization,
      sessionContext: mockSession,
      userProfile: mockUser,
      requestType: 'generation'
    };

    const result = await wrapperSystem.processRequest(request);

    expect(result.response.impactScore.overall).toBeGreaterThan(0.7);
    expect(result.response.ethicsValidation.biasScore).toBeLessThan(0.3);
    expect(result.response.content).toContain('climate education');
    expect(result.safetyReport.safe).toBe(true);
  });
});
```

## Performance Optimization

### Caching Strategy

```typescript
class CacheManager {
  private redis: Redis;

  async getCachedResponse(requestHash: string): Promise<ProcessedResponse | null> {
    const cached = await this.redis.get(`response:${requestHash}`);
    return cached ? JSON.parse(cached) : null;
  }

  async cacheResponse(
    requestHash: string,
    response: ProcessedResponse,
    ttl: number = 3600
  ): Promise<void> {
    await this.redis.setex(
      `response:${requestHash}`,
      ttl,
      JSON.stringify(response)
    );
  }

  private generateRequestHash(request: ProcessedRequest): string {
    // Create hash based on user message and relevant context
    // Exclude sensitive data like user IDs
    const hashData = {
      message: request.userMessage,
      organizationType: request.enrichedContext.organizationType,
      intent: request.intent
    };
    
    return crypto
      .createHash('sha256')
      .update(JSON.stringify(hashData))
      .digest('hex');
  }
}
```

### Load Balancing & Scaling

```typescript
class ProviderLoadBalancer {
  private providerHealthScores: Map<string, number> = new Map();
  private requestCounts: Map<string, number> = new Map();

  async selectOptimalProvider(
    requirements: RequestRequirements
  ): Promise<string> {
    const availableProviders = await this.getHealthyProviders();
    
    // Load balance based on:
    // 1. Current request count
    // 2. Provider health scores
    // 3. Capability match
    // 4. Cost efficiency
    
    const scores = new Map<string, number>();
    
    for (const provider of availableProviders) {
      const loadScore = this.calculateLoadScore(provider);
      const healthScore = this.providerHealthScores.get(provider) || 0;
      const capabilityScore = this.scoreCapabilities(provider, requirements);
      
      scores.set(provider, loadScore * 0.3 + healthScore * 0.4 + capabilityScore * 0.3);
    }
    
    return this.selectBestProvider(scores);
  }

  async updateProviderHealth(provider: string, responseTime: number, error?: Error): Promise<void> {
    const currentScore = this.providerHealthScores.get(provider) || 1.0;
    
    if (error) {
      this.providerHealthScores.set(provider, Math.max(0, currentScore - 0.1));
    } else {
      const timeScore = Math.max(0, 1 - (responseTime / 30000)); // 30s max
      this.providerHealthScores.set(provider, Math.min(1, currentScore * 0.9 + timeScore * 0.1));
    }
  }
}
```

## Security Considerations

### Data Protection

```typescript
class SecurityManager {
  private encryptionKey: string;

  async encryptSensitiveData(data: any): Promise<string> {
    const cipher = crypto.createCipher('aes-256-gcm', this.encryptionKey);
    let encrypted = cipher.update(JSON.stringify(data), 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return encrypted;
  }

  async decryptSensitiveData(encryptedData: string): Promise<any> {
    const decipher = crypto.createDecipher('aes-256-gcm', this.encryptionKey);
    let decrypted = decipher.update(encryptedData, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return JSON.parse(decrypted);
  }

  async sanitizeForLogging(data: any): Promise<any> {
    // Remove or hash sensitive information
    const sanitized = { ...data };
    
    if (sanitized.personalData) {
      sanitized.personalData = this.hashSensitiveFields(sanitized.personalData);
    }
    
    if (sanitized.organizationData) {
      sanitized.organizationData = this.anonymizeOrganization(sanitized.organizationData);
    }
    
    return sanitized;
  }
}
```

## Deployment Checklist

### Pre-Production
- [ ] Complete unit test coverage (>90%)
- [ ] Integration tests passing
- [ ] Security audit completed
- [ ] Performance benchmarks met
- [ ] Ethics validation system tested
- [ ] Bias detection algorithms validated
- [ ] Multi-provider failover tested
- [ ] Monitoring and alerting configured

### Production Readiness
- [ ] Environment variables configured
- [ ] Secrets management implemented
- [ ] Database migrations applied
- [ ] Cache warmed up
- [ ] Health checks responding
- [ ] Backup systems verified
- [ ] Incident response procedures documented
- [ ] Team training completed

### Post-Deployment
- [ ] Monitor system performance
- [ ] Track bias detection effectiveness
- [ ] Collect user feedback
- [ ] Analyze impact metrics
- [ ] Review audit logs
- [ ] Update documentation
- [ ] Plan iterative improvements

## Maintenance & Evolution

### Regular Updates
- **Weekly**: Performance monitoring review
- **Monthly**: Bias detection algorithm updates
- **Quarterly**: Provider capabilities assessment
- **Annually**: Complete system audit and ethics review

### Continuous Improvement
- User feedback integration
- A/B testing for response quality
- Machine learning model updates
- New provider integration
- Enhanced safety measures

This wrapper system ensures that ImpactAI maintains consistent, ethical, and effective AI interactions across all providers while continuously improving its social impact optimization capabilities.
