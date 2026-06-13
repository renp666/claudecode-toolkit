---
name: shipping-and-launch
description: Prepares production launches. Use when preparing to deploy to production. Use when you need a pre-launch checklist, when setting up monitoring, when planning a staged rollout, or when you need a rollback strategy.
---
# Shipping and Launch

Source: https://github.com/addyosmani/agent-skills (⭐22.8K)

## Overview

Ship with confidence. The goal is not just to deploy — it's to deploy safely, with monitoring in place, a rollback plan ready, and a clear understanding of what success looks like. Every launch should be reversible, observable, and incremental.

## When to Use

- Deploying a feature to production for the first time
- Releasing a significant change to users
- Migrating data or infrastructure
- Any deployment that carries risk

## The Pre-Launch Checklist

### Code Quality
- [ ] All tests pass (unit, integration, e2e)
- [ ] Build succeeds with no warnings
- [ ] Lint and type checking pass
- [ ] Code reviewed and approved
- [ ] No TODO comments that should be resolved before launch
- [ ] No `console.log` debugging statements in production code

### Security
- [ ] No secrets in code or version control
- [ ] `npm audit` shows no critical or high vulnerabilities
- [ ] Input validation on all user-facing endpoints
- [ ] Authentication and authorization checks in place
- [ ] Security headers configured (CSP, HSTS, etc.)

### Performance
- [ ] Core Web Vitals within "Good" thresholds
- [ ] No N+1 queries in critical paths
- [ ] Images optimized (compression, responsive sizes, lazy loading)
- [ ] Bundle size within budget
- [ ] Database queries have appropriate indexes

### Accessibility
- [ ] Keyboard navigation works for all interactive elements
- [ ] Color contrast meets WCAG 2.1 AA (4.5:1 for text)
- [ ] Focus management correct for modals and dynamic content

### Infrastructure
- [ ] Environment variables set in production
- [ ] Database migrations applied
- [ ] DNS and SSL configured
- [ ] Logging and error reporting configured
- [ ] Health check endpoint exists and responds

## Feature Flag Strategy

Ship behind feature flags to decouple deployment from release:

**Feature flag lifecycle:**
1. DEPLOY with flag OFF — Code is in production but inactive
2. ENABLE for team/beta — Internal testing in production environment
3. GRADUAL ROLLOUT — 5% → 25% → 50% → 100% of users
4. MONITOR at each stage — Watch error rates, performance, user feedback
5. CLEAN UP — Remove flag and dead code path after full rollout

## Staged Rollout

### Rollout Decision Thresholds

| Metric | Advance (green) | Hold (yellow) | Roll back (red) |
|--------|-----------------|---------------|-----------------|
| Error rate | Within 10% of baseline | 10-100% above baseline | >2x baseline |
| P95 latency | Within 20% of baseline | 20-50% above baseline | >50% above baseline |
| Client JS errors | No new error types | New errors at <0.1% of sessions | New errors at >0.1% of sessions |
| Business metrics | Neutral or positive | Decline <5% | Decline >5% |

### When to Roll Back

Roll back immediately if:
- Error rate increases by more than 2x baseline
- P95 latency increases by more than 50%
- User-reported issues spike
- Data integrity issues detected
- Security vulnerability discovered

## Rollback Plan Template

```markdown
## Rollback Plan for [Feature/Release]
### Trigger Conditions
- Error rate > 2x baseline
- P95 latency > [X]ms
### Rollback Steps
1. Disable feature flag (if applicable)
   OR
1. Deploy previous version: `git revert <commit> && git push`
2. Verify rollback: health check, error monitoring
3. Communicate: notify team of rollback
### Time to Rollback
- Feature flag: < 1 minute
- Redeploy previous version: < 5 minutes
- Database rollback: < 15 minutes
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It works in staging, it'll work in production" | Production has different data, traffic patterns, and edge cases. |
| "We don't need feature flags for this" | Every feature benefits from a kill switch. |
| "Monitoring is overhead" | Not having monitoring means you discover problems from user complaints. |
| "Rolling back is admitting failure" | Rolling back is responsible engineering. Shipping a broken feature is the failure. |

## Verification

Before deploying:
- [ ] Pre-launch checklist completed (all sections green)
- [ ] Feature flag configured (if applicable)
- [ ] Rollback plan documented
- [ ] Monitoring dashboards set up

After deploying:
- [ ] Health check returns 200
- [ ] Error rate is normal
- [ ] Latency is normal
- [ ] Critical user flow works
- [ ] Logs are flowing
