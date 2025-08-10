// ===============================================
// Test Suite: commitlint.test.js
// Description: Tests for commitlint workflow configuration
//
// Test Groups:
//   - Workflow structure validation
//   - Permissions block verification
//   - Job configuration checks
// ===============================================

import { describe, expect, test } from '@jest/globals';
import fs from 'fs';
import path from 'path';
import yaml from 'yaml';

describe('Commitlint Workflow', () => {
  const workflowPath = path.join(__dirname, 'commitlint.yml');
  let workflowContent;
  let workflowConfig;

  beforeAll(() => {
    workflowContent = fs.readFileSync(workflowPath, 'utf8');
    workflowConfig = yaml.parse(workflowContent);
  });

  test('workflow file should exist', () => {
    expect(fs.existsSync(workflowPath)).toBe(true);
  });

  test('should have permissions block', () => {
    expect(workflowConfig.permissions).toBeDefined();
    expect(typeof workflowConfig.permissions).toBe('object');
  });

  test('permissions should include contents read access', () => {
    expect(workflowConfig.permissions.contents).toBe('read');
  });

  test('permissions should include pull-requests read access', () => {
    expect(workflowConfig.permissions['pull-requests']).toBe('read');
  });

  test('should have commitlint job', () => {
    expect(workflowConfig.jobs.commitlint).toBeDefined();
  });

  test('should run on pull request events', () => {
    expect(workflowConfig.on['pull_request']).toBeDefined();
    expect(workflowConfig.on['pull_request'].types).toContain('opened');
    expect(workflowConfig.on['pull_request'].types).toContain('synchronize');
    expect(workflowConfig.on['pull_request'].types).toContain('reopened');
  });

  test('should use ubuntu-latest runner', () => {
    expect(workflowConfig.jobs.commitlint['runs-on']).toBe('ubuntu-latest');
  });

  test('should checkout with fetch-depth 0', () => {
    const checkoutStep = workflowConfig.jobs.commitlint.steps.find(
      step => step.uses === 'actions/checkout@v4'
    );
    expect(checkoutStep).toBeDefined();
    expect(checkoutStep.with['fetch-depth']).toBe(0);
  });

  test('should use wagoid/commitlint-github-action@v6', () => {
    const commitlintStep = workflowConfig.jobs.commitlint.steps.find(
      step => step.uses === 'wagoid/commitlint-github-action@v6'
    );
    expect(commitlintStep).toBeDefined();
    expect(commitlintStep.with.configFile).toBe('.github/workflows/commitlint.config.mjs');
  });
});
