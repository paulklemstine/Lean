# Coherence-Stratified Complexity & Quantum Coherence

## Overview

This research explores how spectral coherence—a measure of structural regularity—naturally stratifies the complexity class NP into a hierarchy of difficulty classes, and how this same measure unifies quantum phenomena (superposition, entanglement, decoherence, interference) under a single mathematical framework.

## Contents

### Formal Mathematics (Lean 4)

- **`CoherenceStratification.lean`** — 18 machine-verified theorems covering:
  - Coherence measure properties (bounded, dual, monotone)
  - NP stratification (nesting, coverage, strict separation, four-level hierarchy)
  - Quantum coherence (nonnegativity, basis states, uniform superposition, dephasing)
  - N-dimensional coherence (tensor decomposition, Bell state, GHZ state)
  - Coherence-complexity bridge (search exponents, conservation)

### Research Papers

- **`RESEARCH_PAPER.md`** — Full technical paper with definitions, theorems, proofs, experiments
- **`SCIENTIFIC_AMERICAN_ARTICLE.md`** — Popular science article for general audiences
- **`APPLICATIONS.md`** — Eight practical applications with implementation guidance

### Python Demonstrations

- **`demos/demo_coherence_stratification.py`** — Computes coherence for problem families, demonstrates hierarchy
- **`demos/demo_quantum_phenomena.py`** — Explores superposition, entanglement, decoherence, interference
- **`demos/demo_hypothesis_experiments.py`** — Proposes, tests, and validates 6 mathematical hypotheses

## Running the Demos

```bash
pip install numpy
python demos/demo_coherence_stratification.py
python demos/demo_quantum_phenomena.py
python demos/demo_hypothesis_experiments.py
```

## Key Results

1. **NP decomposes into coherence tiers** — Tier 1 (C>0.7) through Tier 4 (C<0.15)
2. **Coherence phase transitions** — Sharp transitions at SAT satisfiability thresholds
3. **Quantum coherence unifies phenomena** — Superposition creates, entanglement redistributes, decoherence destroys
4. **GHZ coherence = 1 for all dimensions** — Entanglement coherence is fundamentally different from superposition coherence
5. **Coherence-entropy uncertainty** — C(f)·H(f) ≤ 1 validated experimentally
6. **All proofs machine-verified** — 18 theorems proved in Lean 4 with no sorry axioms
