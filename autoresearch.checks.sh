#!/bin/bash
# Aether autoresearch checks: Validate that the system produces quality research
# This checks:
# 1. Python modules import correctly
# 2. Key components are functional
# 3. Concept quality scoring makes mathematical sense
# 4. The pipeline can run a dry-run cycle
# 5. Lean files compile (spot check)

set -e

echo "=== Aether Research Quality Checks ==="

# Check 1: Python components load
echo "Check 1: Python components import..."
cd Aether
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
print('  All components imported successfully')
"

# Check 2: Catalog analyzer can scan
echo "Check 2: Catalog scanner works..."
python3 -c "
from catalog_analyzer import CatalogAnalyzer
from pathlib import Path
analyzer = CatalogAnalyzer(Path('../Catalog'))
summaries = analyzer.scan()
total_files = len(summaries)
total_decls = sum(len(s.declarations) for s in summaries)
total_sorries = sum(s.sorry_count for s in summaries)
print(f'  Catalog: {total_files} files, {total_decls} declarations, {total_sorries} sorries')
assert total_files > 100, f'Expected >100 files, got {total_files}'
assert total_decls > 1000, f'Expected >1000 declarations, got {total_decls}'
print('  OK: Catalog scan successful')
"

# Check 3: Quality scoring evaluates mathematical depth
echo "Check 3: Quality scoring evaluates mathematical depth..."
python3 -c "
from autoresearch_bridge import AutoresearchBridge
from pathlib import Path
bridge = AutoresearchBridge(Path('../workspace'))

# Test: substantial results should score much higher than trivial
substantial = bridge.evaluate_concept_quality(
    concept_title='tropical_hecke_algebra_gl2',
    concept_domain='tropical',
    quality_assessment={'quality': 'substantial'},
    catalog_references=['Tropical/Langlands/Foundations.lean', 'Tropical/Core/TropicalSemiring.lean', 'Algebra/SpectralGraphTheory.lean'],
    research_mode='formalize',
    prompt_length=2500,
)

trivial = bridge.evaluate_concept_quality(
    concept_title='trivial_true_statement',
    concept_domain='speculative',
    quality_assessment={'quality': 'trivial'},
    catalog_references=[],
    research_mode='prove',
    prompt_length=400,
)

assert substantial > trivial, f'Substantial ({substantial}) should beat trivial ({trivial})'
assert substantial > 0.8, f'Substantial should score >0.8, got {substantial}'
assert trivial < 0.3, f'Trivial should score <0.3, got {trivial}'
print(f'  Substantial score: {substantial:.3f} (expected >0.8)')
print(f'  Trivial score: {trivial:.3f} (expected <0.3)')
print('  OK: Quality scoring differentiates mathematical depth')
"

# Check 4: Novelty detection works
echo "Check 4: Novelty detection penalizes repetition..."
python3 -c "
import json, time
from pathlib import Path
from autoresearch_bridge import AutoresearchBridge

# Create a clean test workspace
test_ws = Path('/tmp/aether_test_checks')
test_ws.mkdir(exist_ok=True)
bridge = AutoresearchBridge(test_ws)

# Log two similar experiments
bridge.log_result('exp1', 'tropical_hecke_gl2', 'tropical', 'prove', 'substantial', 0.85, ['Tropical/Langlands/Foundations.lean'], prompt_length=2000)
bridge.log_result('exp2', 'tropical_hecke_gl2_trace', 'tropical', 'prove', 'partial', 0.5, ['Tropical/Langlands/Foundations.lean'], prompt_length=1800)

# A third similar concept should get novelty penalty
repeat_score = bridge.evaluate_concept_quality(
    concept_title='tropical_hecke_gl2',  # Exact repeat
    concept_domain='tropical',
    quality_assessment={'quality': 'substantial'},
    catalog_references=['Tropical/Langlands/Foundations.lean'],
    research_mode='prove',
    prompt_length=2000,
)

# A novel concept should not get novelty penalty
novel_score = bridge.evaluate_concept_quality(
    concept_title='dilithium_security_reduction_novel',
    concept_domain='cryptography',
    quality_assessment={'quality': 'substantial'},
    catalog_references=['Cryptography/HashInversion.lean'],
    research_mode='formalize',
    prompt_length=2500,
)

assert novel_score > repeat_score, f'Novel ({novel_score}) should beat repeat ({repeat_score})'
print(f'  Novel score: {novel_score:.3f}')
print(f'  Repeat score: {repeat_score:.3f} (penalized)')
print('  OK: Novelty detection works')
"

# Check 5: Research context accumulates discoveries
echo "Check 5: Research context accumulates and prioritizes discoveries..."
python3 -c "
from pathlib import Path
from research_context import ResearchContext

test_ws = Path('/tmp/aether_test_checks_rc')
test_ws.mkdir(exist_ok=True)
ctx = ResearchContext(test_ws)

# Add a substantial discovery
ctx.update_from_summary(
    exp_id='exp_sub1',
    cycle_n=1,
    concept_title='tropical_hecke_algebra_trace',
    domain='tropical',
    research_mode='prove',
    quality='substantial',
    quality_score=0.9,
    summary_data={
        'key_theorems': ['tropical_trace_formula', 'tropical_satake_transform'],
        'domains_touched': ['Tropical', 'Algebra'],
        'sorries_remaining': 2,
        'files_created': ['Tropical/Langlands/HeckeAlgebra.lean'],
        'raw_text': 'Open problem: extend trace formula to GL₃. Future direction: connect to automorphic forms.',
    }
)

# Add a trivial discovery
ctx.update_from_summary(
    exp_id='exp_triv1',
    cycle_n=2,
    concept_title='obvious_true',
    domain='speculative',
    research_mode='prove',
    quality='trivial',
    quality_score=0.1,
    summary_data={
        'key_theorems': [],
        'domains_touched': ['Speculative'],
        'sorries_remaining': 0,
        'files_created': [],
        'raw_text': 'Trivial result: True := by trivial',
    }
)

# Build discoveries prompt - should show substantial result and open problems
prompt = ctx.build_discoveries_prompt()
assert 'tropical_hecke_algebra_trace' in prompt, 'Should reference substantial discovery'
assert 'tropical' in prompt.lower() or 'Tropical' in prompt, 'Should mention tropical domain'
assert len(ctx.global_open_problems) > 0, 'Should track open problems'
print(f'  Discoveries: {len(ctx.discoveries)}')
print(f'  Open problems: {len(ctx.global_open_problems)}')
print(f'  Theorems proved: {len(ctx.global_theorems_proved)}')
print('  OK: Research context accumulates properly')
"

# Check 6: Domain normalization is correct
echo "Check 6: Domain normalization maps research domains to catalog dirs..."
python3 -c "
from output_organizer import normalize_domain

# Critical mappings for research_domains.json
tests = {
    'tropical': 'Tropical',
    'algebra': 'Algebra',
    'cryptography': 'Cryptography',
    'pythagorean': 'Pythagorean',
    'machinelearning': 'MachineLearning',
    'speculative': 'Speculative',
    'factoring': 'Cryptography',
    'compression': 'Computation',
    'ai': 'MachineLearning',
    'tropical_langlands_gl2': 'Tropical',
    'tropical_robustness': 'MachineLearning',
    'dilithium_security': 'Cryptography',
    'berggren_optimized': 'Pythagorean',
    'eml_approximation': 'EML',
    'spb_crypto': 'Cryptography',
    'niven_integral': 'Bridges',
    'carmichael': 'Pythagorean',
    'quantum mechanics': 'Cryptography',
    'eml cosmology': 'EML',
}
all_ok = True
for input_domain, expected in tests.items():
    result = normalize_domain(input_domain)
    ok = result == expected
    if not ok:
        print(f'  FAIL: normalize_domain({input_domain!r}) = {result!r}, expected {expected!r}')
        all_ok = False
assert all_ok, 'Some domain normalizations failed'
print('  All 19 domain mappings correct')
"

# Check 7: Strategy analysis works
echo "Check 7: Strategy analysis identifies best research patterns..."
python3 -c "
from pathlib import Path
from autoresearch_bridge import AutoresearchBridge
bridge = AutoresearchBridge(Path('/tmp/aether_test_checks'))

strategy = bridge.get_best_strategy()
print(f'  Best domain: {strategy[\"best_domain\"]}')
print(f'  Total experiments: {strategy[\"total_experiments\"]}')
print(f'  Success rate: {strategy[\"success_rate\"]:.1%}')
print('  OK: Strategy analysis works')
"

# Check 8: Pi-Agent research concept is well-structured
echo "Check 8: Research concept structure is sound..."
python3 -c "
from pi_agent_client import ResearchConcept

c = ResearchConcept(
    title='dilithium_module_sis_reduction',
    domain='cryptography',
    concept_description='Formalize the security reduction from Module-SIS problem to CRYSTALS-Dilithium signature scheme security',
    mathematical_framing='For all PPT adversaries A against Dilithium, there exists a Module-SIS solver B with Adv(B) >= Adv(A) / poly(n)',
    lean_guess='theorem dilithium_security_reduction : ...',
    catalog_references=['Cryptography/HashInversion.lean'],
    research_mode='formalize',
    novelty_estimate=0.85,
    breakthrough_potential=0.9,
    key_references=['Module-SIS', 'Dilithium', 'lattice_cryptography'],
)

assert c.title == 'dilithium_module_sis_reduction'
assert c.novelty_estimate > 0.5
assert c.breakthrough_potential > 0.5
assert c.research_mode in ('prove', 'formalize', 'counterexample', 'sorry_fill')
print(f'  Concept: {c.title}')
print(f'  Domain: {c.domain}, Mode: {c.research_mode}')
print(f'  Novelty: {c.novelty_estimate}, Breakthrough: {c.breakthrough_potential}')
print('  OK: Research concept structure is sound')
"

cd ..
echo ""
echo "=== All Aether Research Quality Checks PASSED ==="