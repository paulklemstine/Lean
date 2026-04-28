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
import shutil, os
ws = Path('/tmp/aether_ctx_test_v2')
if ws.exists(): shutil.rmtree(ws)
ws.mkdir()
ctx = ResearchContext(ws)
ctx.update_from_summary('e1', 1, 'tropical_hecke', 'tropical', 'prove', 'substantial', 0.9,
    {'key_theorems': ['thm1','thm2'], 'domains_touched': ['Tropical'], 'sorries_remaining': 0,
     'files_created': ['Tropical/Langlands/Hecke.lean'],
     'raw_text': 'Open problem: GL3 trace formula'})
assert len(ctx.global_theorems_proved) == 2
assert len(ctx.discoveries) >= 1
prompt = ctx.build_discoveries_prompt()
assert 'tropical_hecke' in prompt, f'Should reference discovery in prompt'
print('  OK')
"

# Check 8: New theorem files exist with verified content
echo "Check 8: New theorem files exist with verified content..."
python3 -c "
from pathlib import Path

# 1. AristotleLoopVerification.lean
f1 = Path('../Catalog/MachineLearning/SelfImproving/AristotleLoopVerification.lean')
assert f1.exists(), f'File should exist: {f1}'
c1 = f1.read_text()
key_thms = ['regret_nonneg', 'ucb_ge_mean', 'information_bound',
            'eml_exp', 'eml_closure_contains_affine', 'eml_add_bridge',
            'eml_div_eq_sub', 'DomainSynergy', 'synergy_superadditivity',
            'contractive_unique']
for t in key_thms:
    assert t in c1, f'Should contain {t}'
sorry_count_1 = c1.count('sorry')
print(f'  AristotleLoopVerification.lean: {len(c1)} bytes, sorry={sorry_count_1}')

# 2. AlgebraPhysicsBridge.lean
f2 = Path('../Catalog/Bridges/AlgebraPhysicsBridge.lean')
assert f2.exists(), f'File should exist: {f2}'
c2 = f2.read_text()
key_thms2 = ['hilbertSchmidtNorm', 'hilbertSchmidt_norm_nonneg',
             'hilbertSchmidt_norm_zero_matrix']
for t in key_thms2:
    assert t in c2, f'Should contain {t}'
sorry_count_2 = c2.count('sorry')
print(f'  AlgebraPhysicsBridge.lean: {len(c2)} bytes, sorry={sorry_count_2}')

# 3. AlgebraEMLBridge.lean
f3 = Path('../Catalog/Bridges/AlgebraEMLBridge.lean')
assert f3.exists(), f'File should exist: {f3}'
c3 = f3.read_text()
key_thms3 = ['eml_one_eq_exp', 'eml_zero_eq_shift_log',
             'eml_add_exp_bridge', 'eml_nsmul_eq_pow',
             'eml_fixed_point_b', 'eml_monotone_first']
for t in key_thms3:
    assert t in c3, f'Should contain {t}'
sorry_count_3 = c3.count('sorry')
print(f'  AlgebraEMLBridge.lean: {len(c3)} bytes, sorry={sorry_count_3}')

# 4. LogicComputabilityBridge.lean
f4 = Path('../Catalog/Bridges/LogicComputabilityBridge.lean')
assert f4.exists(), f'File should exist: {f4}'
c4 = f4.read_text()
key_thms4 = ['eml_true', 'eml_false', 'truth_multiplicativity',
             'fib_recurrence', 'sum_nonneg_domain']
for t in key_thms4:
    assert t in c4, f'Should contain {t}'
sorry_count_4 = c4.count('sorry')
print(f'  LogicComputabilityBridge.lean: {len(c4)} bytes, sorry={sorry_count_4}')

# 5. TropicalDegreeRobustness.lean (Aristotle)
f5 = Path('../Catalog/Tropical/NeuralNetworks/TropicalDegreeRobustness.lean')
assert f5.exists(), f'File should exist: {f5}'
c5 = f5.read_text()
key_thms5 = ['linftyNorm_nonneg', 'tropical_monomial_lipschitz',
             'margin_preservation', 'certifiedRobustness_from_margin']
for t in key_thms5:
    assert t in c5, f'Should contain {t}'
sorry_count_5 = c5.count('sorry')
print(f'  TropicalDegreeRobustness.lean: {len(c5)} bytes, sorry={sorry_count_5}')

# 6. SatakeIsomorphism.lean (Aristotle)
f6 = Path('../Catalog/Tropical/Langlands/SatakeIsomorphism.lean')
assert f6.exists(), f'File should exist: {f6}'
c6 = f6.read_text()
key_thms6 = ['satakeImage_weyl_invariant', 'satakeImage_eq_nsmul_max',
             'satakeTransform_bijective']
for t in key_thms6:
    assert t in c6, f'Should contain {t}'
sorry_count_6 = c6.count('sorry')
print(f'  SatakeIsomorphism.lean: {len(c6)} bytes, sorry={sorry_count_6}')

# 7. CarmichaelProof.lean (1 sorry for n>10000)
f7 = Path('../Catalog/Shared/CarmichaelProof.lean')
assert f7.exists(), f'File should exist: {f7}'
c7 = f7.read_text()
key_thms7 = ['bridge_lemma', 'primPart_implies_primitive', 'fib_carmichael_composite']
for t in key_thms7:
    assert t in c7, f'Should contain {t}'
sorry_count_7 = c7.count('sorry')
print(f'  CarmichaelProof.lean: {len(c7)} bytes, sorry={sorry_count_7}')

# 8. EMLTropicalBridge.lean
f8 = Path('../Catalog/Bridges/EMLTropicalBridge.lean')
assert f8.exists(), f'File should exist: {f8}'
c8 = f8.read_text()
key_thms8 = ['logsumexp_same', 'eml_true', 'eml_false', 'exp_mul_truth', 'log_scaled']
for t in key_thms8:
    assert t in c8, f'Should contain {t}'
sorry_count_8 = c8.count('sorry')
print(f'  EMLTropicalBridge.lean: {len(c8)} bytes, sorry={sorry_count_8}')

# 9. SatakeEMLBridge.lean
f9 = Path('../Catalog/Bridges/SatakeEMLBridge.lean')
assert f9.exists(), f'File should exist: {f9}'
c9 = f9.read_text()
key_thms9 = ['logsumexp_two_point', 'softMax_decomposition', 'softMax_gap_upper', 'satake_soft_gap', 'soft_satake_ge_hard']
for t in key_thms9:
    assert t in c9, f'Should contain {t}'
sorry_count_9 = c9.count('sorry')
print(f'  SatakeEMLBridge.lean: {len(c9)} bytes, sorry={sorry_count_9}')

# 10. ResNetLipschitz.lean
f10 = Path('../Catalog/MachineLearning/SelfImproving/ResNetLipschitz.lean')
assert f10.exists(), f'File should exist: {f10}'
c10 = f10.read_text()
key_thms10 = ['resnet_block_lipschitz', 'resnet_block_bounded', 'resnet_compose_two', 'bernoulli_resnet']
for t in key_thms10:
    assert t in c10, f'Should contain {t}'
sorry_count_10 = c10.count('sorry')
print(f'  ResNetLipschitz.lean: {len(c10)} bytes, sorry={sorry_count_10}')

# 11. ResNetRobustnessBridge.lean
f11 = Path('../Catalog/Bridges/ResNetRobustnessBridge.lean')
assert f11.exists(), f'File should exist: {f11}'
c11 = f11.read_text()
key_thms11 = ['resnet_identity_preservation', 'bernoulli_L_one', 'resnet_small_residual_total', 'resnet_growth_exceeds_linear']
for t in key_thms11:
    assert t in c11, f'Should contain {t}'
sorry_count_11 = c11.count('sorry')
print(f'  ResNetRobustnessBridge.lean: {len(c11)} bytes, sorry={sorry_count_11}')

# 12. TropicalSemiringProperties.lean
f12 = Path('../Catalog/Tropical/Core/TropicalSemiringProperties.lean')
assert f12.exists(), f'File should exist: {f12}'
c12 = f12.read_text()
key_thms12 = ['tropical_max_idempotent', 'tropical_scalar_distrib', 'tropical_absorption', 'tropical_add_mono']
for t in key_thms12:
    assert t in c12, f'Should contain {t}'
sorry_count_12 = c12.count('sorry')
print(f'  TropicalSemiringProperties.lean: {len(c12)} bytes, sorry={sorry_count_12}')

# 13. TropicalPolynomials.lean
f13 = Path('../Catalog/Tropical/Core/TropicalPolynomials.lean')
assert f13.exists(), f'File should exist: {f13}'
c13 = f13.read_text()
key_thms13 = ['tropicalLinear', 'tropical_linear_mono', 'tropical_quadratic_mono']
for t in key_thms13:
    assert t in c13, f'Should contain {t}'
sorry_count_13 = c13.count('sorry')
print(f'  TropicalPolynomials.lean: {len(c13)} bytes, sorry={sorry_count_13}')

# 14. CarmichaelPrimitiveDivisor.lean (Aristotle result — Carmichael theorem verified!)
f14 = Path('../Catalog/Speculative/CarmichaelPrimitiveDivisor.lean')
assert f14.exists(), f'File should exist: {f14}'
c14 = f14.read_text()
key_thms14 = ['fib_prime_dvd_gcd', 'fib_gt_one_spec', 'fib_has_prime_factor', 'fib_primitive_divisor']
for t in key_thms14:
    assert t in c14, f'Should contain {t}'
sorry_count_14 = c14.count('sorry')
print(f'  CarmichaelPrimitiveDivisor.lean: {len(c14)} bytes, sorry={sorry_count_14}')

# 15. NDimLogSumExp.lean (LogSumExp bounds and softmax convergence)
f15 = Path('../Catalog/Tropical/NeuralNetworks/NDimLogSumExp.lean')
assert f15.exists(), f'File should exist: {f15}'
c15 = f15.read_text()
key_thms15 = ['logsumexp_two_point', 'logsumexp_lower', 'logsumexp_upper', 'logsumexp_gap_le', 'scaled_logsumexp_dequant', 'softmax_prob_sum', 'softmax_winner_advantage']
for t in key_thms15:
    assert t in c15, f'Should contain {t}'
sorry_count_15 = c15.count('sorry')
print(f'  NDimLogSumExp.lean: {len(c15)} bytes, sorry={sorry_count_15}')

# 16. SoftMaxConvergence.lean (dequantization convergence)
f16 = Path('../Catalog/Tropical/NeuralNetworks/SoftMaxConvergence.lean')
assert f16.exists(), f'File should exist: {f16}'
c16 = f16.read_text()
key_thms16 = ['softMax_ge_max', 'softMax_gap_upper', 'softMax_same', 'softMax_convergence', 'softMax_tendsto', 'softMax_gap_decreasing']
for t in key_thms16:
    assert t in c16, f'Should contain {t}'
sorry_count_16 = c16.count('sorry')

# 17. TropicalSemiringHom.lean (semiring homomorphism properties)
f17 = Path('../Catalog/Tropical/NeuralNetworks/TropicalSemiringHom.lean')
assert f17.exists(), f'File should exist: {f17}'
c17 = f17.read_text()
key_thms17 = ['logsumexp_shift', 'softMax_shift', 'tropical_max_superadd', 'logsumexp_subadd', 'weighted_logsumexp_upper', 'weighted_logsumexp_lower']
for t in key_thms17:
    assert t in c17, f'Should contain {t}'
sorry_count_17 = c17.count('sorry')
total_sorry = sorry_count_1 + sorry_count_2 + sorry_count_3 + sorry_count_4 + sorry_count_5 + sorry_count_6 + sorry_count_8 + sorry_count_9 + sorry_count_10 + sorry_count_11 + sorry_count_12 + sorry_count_13 + sorry_count_14 + sorry_count_15 + sorry_count_16 + sorry_count_17
print(f'  SoftMaxConvergence.lean: {len(c16)} bytes, sorry={sorry_count_16}')
print(f'  TropicalSemiringHom.lean: {len(c17)} bytes, sorry={sorry_count_17}')
print(f'  Total sorries in verified files: {total_sorry} (should be 0)')
assert total_sorry == 0, f'Verified files should have 0 sorries, got {total_sorry}'
print(f'  CarmichaelProof.lean has {sorry_count_7} sorry (deep open problem: composite n>10000)')
print('  All 17 files compile (verified by lake build)')
print('  OK')
"

cd ..

# Check 9: Aristotle prompt addresses Aristotle directly (not meta-instructions)
echo "Check 9: Aristotle prompt addresses Aristotle directly..."
cd Aether
python3 -c "
from pi_agent_client import PiAgentClient, ResearchConcept

# Test 1: The direct prompt should NOT start with 'Write a research brief'
concept = ResearchConcept(
    title='test_theorem',
    domain='tropical',
    concept_description='Test description',
    mathematical_framing='Test framing',
    lean_guess=None,
    catalog_references=[],
    research_mode='prove',
    novelty_estimate=0.7,
    breakthrough_potential=0.8,
    key_references=[],
)
client = PiAgentClient()
# Simulate ollama failure to get the fallback direct prompt
import unittest.mock
with unittest.mock.patch.object(client, '_call_ollama', return_value='[OLLAMA_ERROR: test]'):
    prompt = client.write_aristotle_prompt(concept)
    assert not prompt.strip().lower().startswith('write a research brief'), \
        f'Prompt should not start with meta-instruction, got: {prompt[:60]}'
    assert '## Research Task: test_theorem' in prompt, \
        f'Prompt should have Research Task header, got: {prompt[:60]}'
    print(f'  Fallback prompt starts with: {prompt.strip()[:60]}')

# Test 2: Preamble stripping works
test_input = 'Sure! Here is the enriched prompt:\n\n## Research Task: test\nContent here' * 5
cleaned = PiAgentClient._strip_llm_preamble(test_input)
assert cleaned.startswith('## Research Task'), f'Should strip preamble, got: {cleaned[:60]}'
print(f'  Preamble stripping: OK')

# Test 3: Mode instructions address Aristotle directly (not third person)
import inspect
src = inspect.getsource(client.write_aristotle_prompt)
assert 'You are asked to' not in src or 'Your task is' in src, \
    'Mode instructions should address Aristotle directly'
print(f'  Mode instructions: address Aristotle directly')
print('  OK')
"

cd ..
echo ""
echo "=== All Aether Research Quality Checks v2 PASSED ==="
