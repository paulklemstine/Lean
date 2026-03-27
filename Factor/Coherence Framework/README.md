# Coherence Theory: A Spectral Framework for Computational Complexity

## Overview

This project develops **Coherence Theory** — a mathematical framework that assigns a continuous measure of structural regularity to Boolean functions and computational problems, based on Fourier analysis on the Boolean hypercube.

**Core Idea:** The *coherence* of a function measures how concentrated its Fourier spectrum is. High coherence means exploitable structure; zero coherence means pseudorandomness.

## Contents

### Papers
- **`SCIENTIFIC_AMERICAN_ARTICLE.md`** — Accessible overview for general audiences
- **`RESEARCH_PAPER.md`** — Technical paper with definitions, conjectures, and experimental results

### Python Demos
All demos are in `demos/` and generate plots automatically.

| Demo | Description | Key Results |
|------|-------------|-------------|
| `demo_coherence_basics.py` | Core definitions, Fourier transform, coherence computation | Dictator/Parity have C=1, random functions have C→0 |
| `demo_sat_coherence.py` | Random 3-SAT coherence at phase transition | Coherence gap between structured and random problems |
| `demo_quantum_coherence.py` | Quantum Coherence Oracle, Grover's algorithm analysis | QCO matches Grover; QFT is a coherence transformer |
| `demo_entropy_duality.py` | Coherence-entropy conservation law | C + L = 1 (definitional); strong C vs H_binary correlation |
| `demo_phase_transition.py` | Phase transitions, algorithm selection, security metrics | Coherence hierarchy; batching speedup curves |
| `demo_hypothesis_testing.py` | Systematic hypothesis generation and validation | Affine invariance ✓; coherence gap ✓; subadditivity ✗ |

### Lean 4 Formalization
- **`lean/CoherenceBasics.lean`** — Formal proofs of foundational properties:
  - `coherence_add_landscape_eq_one`: C(f) + L(f) = 1
  - `coherence_nonneg`: C(f) ≥ 0
  - `coherence_le_one`: C(f) ≤ 1
  - `shannonEntropy_nonneg`: H(p) ≥ 0
  - `shannonEntropy_le_log`: H(p) ≤ log(k)

## Running the Demos

```bash
pip install numpy matplotlib
cd demos/
python demo_coherence_basics.py
python demo_sat_coherence.py
python demo_quantum_coherence.py
python demo_entropy_duality.py
python demo_phase_transition.py
python demo_hypothesis_testing.py
```

## Key Experimental Findings

### Validated
- ✅ **Affine Invariance**: Coherence is exactly invariant under bit permutations (0% deviation)
- ✅ **Coherence Gap**: Growing gap between structured and pseudorandom problems (gap > 0.87 at n=12)
- ✅ **Monotonicity**: XOR composition does not increase coherence (0% violations)
- ✅ **Coherence Amplification**: AND-composition amplifies coherence ~3.4×
- ✅ **C vs Binary Entropy**: Extremely strong negative correlation (r = -0.987)

### Partially Validated
- ⚠️ **QFT as Coherence Transformer**: C_in + C_out = 1 for periodic states under QFT
- ⚠️ **QCO matches Grover**: QCO search achieves within 1.1× of Grover's optimal steps

### Refuted and Updated
- ❌ **Subadditivity** (as stated): C(f⊗g) ≤ weighted average fails for AND-composition. **Updated hypothesis**: subadditivity holds for XOR-composition but not AND-composition.
- ❌ **Hardness prediction sign**: Positive correlation (not negative) between coherence and first-SAT-position for random 3-SAT. This is because high coherence in SAT corresponds to *fewer* solutions (sparser), not easier search.

## Four Main Conjectures

1. **Coherence Gap**: ∃γ > 0 such that NP-complete problems have C = 0 or C ≥ γ
2. **Natural Problems**: Razborov-Rudich natural properties coincide with positive coherence
3. **Quantum Universality**: BQP = P^QCO
4. **Coherence-Entropy Duality**: C(f) + H_normalized(f) = 1

## Applications

| Domain | Application | Coherence Role |
|--------|------------|----------------|
| Optimization | Batching speedup | k^C acceleration for k instances |
| Cryptography | Security metric | -log₂(C) = security bits |
| Algorithm selection | Choose solver | High C → LP; Low C → brute force |
| Quantum computing | Quantum advantage prediction | C > 0 → quantum speedup possible |
