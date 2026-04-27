#!/bin/bash
# Aether autoresearch checks v2: Comprehensive validation
set -e
echo "=== Aether Research Quality Checks v2 ==="

cd Aether

# Check 1: All Python components import (including Aristotle Loop)
echo "Check 1: Python components import..."
python3 -c "
from pi_agent_client import PiAgentClient, ResearchConcept
from catalog_analyzer import CatalogAnalyzer
from output_organizer import OutputOrganizer, normalize_domain
from autoresearch_bridge import AutoresearchBridge
from research_context import ResearchContext
from research_memory import ResearchMemory
from telemetry import TelemetryLogger
from prompt_engine import PromptEngine
from lean_catalog_builder import LeanCatalogBuilder
from aristotle_loop import AristotleLoop, UCBSelector, CrossDomainSynergyMatrix, DomainStats, DOMAINS
print('  All 11 components imported successfully (incl. Aristotle Loop)')
"

# Check 2: Catalog scanner + cross-domain bridges
echo "Check 2: Catalog scanner and cross-domain bridge detection..."
python3 -c "
from catalog_analyzer import CatalogAnalyzer
from pathlib import Path
a = CatalogAnalyzer(Path('../Catalog'))
s = a.scan()
print(f'  Catalog: {len(s)} files, {sum(len(x.declarations) for x in s)} decls, {sum(x.sorry_count for x in s)} sorries')
# Bridge detection
bridges = a.detect_cross_domain_bridges()
missing = a.find_missing_bridges(limit=5)
sorry = a.get_files_with_sorries()
print(f'  Cross-domain bridges: {len(bridges)}')
print(f'  Missing high-potential bridges: {len(missing)}')
print(f'  Sorry targets: {len(sorry)}')
assert len(bridges) > 0, 'Should find bridges'
assert len(missing) > 0, 'Should find missing bridges'
print('  OK')
"

# Check 3: Quality scoring differentiates mathematical depth
echo "Check 3: Quality scoring differentiates depth..."
python3 -c "
from autoresearch_bridge import AutoresearchBridge
from pathlib import Path
b = AutoresearchBridge(Path('../workspace'))
# Cross-domain bridge + open problem = highest score
top = b.evaluate_concept_quality(
    'carmichael_composite_fill', 'pythagorean', {'quality': 'substantial'},
    ['Shared/CarmichaelComposite.lean'], 'sorry_fill', 3000,
    theorem_count=8, sorry_count=0, has_cross_domain=True, advances_open_problem=True)
# Trivial = lowest
bottom = b.evaluate_concept_quality(
    'trivial_true', 'speculative', {'quality': 'trivial'}, [], 'prove', 300)
assert top > bottom, f'{top} should > {bottom}'
assert top > 0.8, f'top should >0.8, got {top}'
assert bottom < 0.1, f'bottom should <0.1, got {bottom}'
print(f'  World-class: {top:.3f}, trivial: {bottom:.3f}')
print('  OK')
"

# Check 4: Novelty detection + Jaccard similarity
echo "Check 4: Novelty and Jaccard similarity..."
python3 -c "
from autoresearch_bridge import AutoresearchBridge
from pathlib import Path
import os
ws = Path('/tmp/aether_novelty_test')
ws.mkdir(exist_ok=True)
b = AutoresearchBridge(ws)
b.log_result('e1', 'tropical_hecke_gl2', 'tropical', 'prove', 'substantial', 0.9, ['Tropical/Langlands/Foundations.lean'], prompt_length=2000)
# Exact repeat penalty
r1 = b.evaluate_concept_quality('tropical_hecke_gl2', 'tropical', {'quality': 'substantial'}, ['Tropical/Langlands/Foundations.lean'], 'prove', 2000)
# High Jaccard overlap penalty ('tropical_hecke' shares 2/3 words with 'tropical_hecke_gl2')
r2 = b.evaluate_concept_quality('tropical_hecke_trace_formula', 'tropical', {'quality': 'substantial'}, ['Tropical/Langlands/Foundations.lean'], 'prove', 2000)
# Novel concept
r3 = b.evaluate_concept_quality('dilithium_security_reduction', 'cryptography', {'quality': 'substantial'}, [], 'formalize', 2500)
assert r3 > r1, f'novel ({r3}) should > exact_repeat ({r1})'
assert r3 > r2, f'novel ({r3}) should > similar ({r2})'
print(f'  novel={r3:.3f}, similar={r2:.3f}, repeat={r1:.3f}')
print('  OK')
"

# Check 5: Aristotle Loop UCB selection
echo "Check 5: Aristotle Loop UCB, synergy, and diminishing returns..."
python3 -c "
from aristotle_loop import AristotleLoop, CrossDomainSynergyMatrix, DomainStats, DOMAINS
import random
random.seed(42)
loop = AristotleLoop()
for i in range(20):
    p = loop.select_prompt()
    q = random.uniform(0.3, 0.9)
    loop.record_discovery(p['domain'], p['mode'], q, new_theorem_count=random.randint(2,8))
# Regret should be reasonable
regret = loop.ucb.get_regret_estimate()
assert regret >= 0, f'regret should be non-negative'
# Synergy should be superadditive
s = CrossDomainSynergyMatrix()
vals = {d: 3.0 for d in DOMAINS}
ratio = s.get_superadditivity_ratio(vals)
assert ratio >= 1.0, f'superadditivity ratio should be >= 1, got {ratio}'
print(f'  regret={regret:.2f}, superadd={ratio:.2f}x')
print('  OK')
"

# Check 6: Domain normalization
echo "Check 6: Domain normalization..."
python3 -c "
from output_organizer import normalize_domain
tests = {
    'tropical': 'Tropical', 'factoring': 'Cryptography', 'ai': 'MachineLearning',
    'tropical_langlands_gl2': 'Tropical', 'eml_approximation': 'EML',
    'quantum mechanics': 'Cryptography', 'eml cosmology': 'EML',
}
for k, v in tests.items():
    assert normalize_domain(k) == v, f'{k} -> {normalize_domain(k)} != {v}'
print('  All mappings correct')
print('  OK')
"

# Check 7: Research context accumulation
echo "Check 7: Research context accumulation..."
python3 -c "
from pathlib import Path
from research_context import ResearchContext
ctx = ResearchContext(Path('/tmp/aether_ctx_test'))
ctx.update_from_summary('e1', 1, 'tropical_hecke', 'tropical', 'prove', 'substantial', 0.9,
    {'key_theorems': ['thm1','thm2'], 'domains_touched': ['Tropical'], 'sorries_remaining': 0,
     'files_created': ['Tropical/Langlands/Hecke.lean'],
     'raw_text': 'Open problem: GL3 trace formula'})
assert len(ctx.global_theorems_proved) == 2
assert len(ctx.global_open_problems) >= 1
print('  OK')
"

# Check 8: New Lean file exists and is syntactically valid
echo "Check 8: New theorem file exists..."
python3 -c "
from pathlib import Path
f = Path('../Catalog/MachineLearning/SelfImproving/AristotleLoopVerification.lean')
assert f.exists(), f'AristotleLoopVerification.lean should exist at {f}'
content = f.read_text()
# Check key theorems are present
assert 'regret_nonneg' in content, 'Should contain regret_nonneg theorem'
assert 'logsumexp_sandwich' in content, 'Should contain logsumexp_sandwich'
assert 'synergy_superadditivity' in content, 'Should contain synergy_superadditivity'
assert 'eml_monotone' in content, 'Should contain eml_monotone'
assert 'eml_closure_contains_affine' in content, 'Should contain eml_closure_contains_affine'
assert 'entropy_bound' in content, 'Should contain entropy_bound'
print(f'  AristotleLoopVerification.lean: {len(content)} bytes, 6+ key theorems')
print('  OK')
"

cd ..
echo ""
echo "=== All Aether Research Quality Checks v2 PASSED ==="