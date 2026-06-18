# The Tropical Alphabet

## A Complete Taxonomy of Operations in the Tropical Semiring & The Algorithmic Universal Oracle

This directory contains the complete research output on the **Tropical Alphabet** — a systematic exploration of all operations, transformations, and meta-operations available in the tropical semiring 𝕋 = (ℝ ∪ {−∞}, max, +), connected to the Algorithmic Universal Oracle.

---

## Contents

### Research Papers
- **`ResearchPaper_TropicalAlphabet.md`** — Full research paper with the complete 5-level taxonomy, proofs, experiments, applications, and new hypotheses
- **`ScientificAmerican_TropicalAlphabet.md`** — Popular science article explaining tropical mathematics to a general audience

### Formal Verification (Lean 4)
- **`TropicalAlphabet.lean`** — Machine-verified proofs of 25+ theorems including:
  - All tropical semiring axioms (idempotency, selectivity, distributivity)
  - ReLU = tropical addition (with idempotency, monotonicity, fixed-point characterization)
  - Maslov dequantization bound: |LogSumExp(a,b) − max(a,b)| ≤ log 2
  - Oracle theory: idempotent composition, fixed-point intersection theorem
  - Tropical De Morgan's laws
  - **Zero sorries, all proofs machine-verified**

### Python Demonstrations
- **`tropical_semiring_demo.py`** — Complete demo of all tropical operations:
  - Primitives (max, +, power, inverse)
  - Polynomials and root finding
  - Matrix algebra (shortest paths via Kleene star)
  - Maslov dequantization spectrum
  - Tropical calculus (derivative = slope, integral = sup)
  - Tropical eigenvalues (max mean cycle weight)
  - Tropical entropy (max surprise ≥ average surprise)
  - Tropical logic gates (complete Boolean basis)
  - Oracle fixed-point iteration
  - Legendre transform as tropical Fourier

- **`tropical_sat_solver.py`** — Universal Tropical SAT Solver:
  - Tropical gradient descent with Maslov cooling
  - Oracle fixed-point solver
  - WalkSAT baseline comparison
  - Multi-start diverse initialization
  - Experiments: phase transition detection at m/n ≈ 4.267
  - Cost landscape visualization

- **`tropical_experiments.py`** — Hypothesis testing suite:
  - H1: Tropical entropy collapse (REFUTED → updated)
  - H2: Maslov convergence rate O(ε) (CONFIRMED)
  - H3: Neural network region counting O(W^L) (CONFIRMED)
  - H4: Oracle idempotency verification (CONFIRMED)
  - H5: Tropical approximation power (PARTIAL)
  - H6: Tropical-Boolean logic completeness (CONFIRMED)
  - H7: Tropical convexity properties (CONFIRMED)

---

## The 5-Level Tropical Alphabet

```
LEVEL 1: PRIMITIVES          ⊕ (max), ⊙ (+), ε (−∞), e (0), ⁻¹ (−), ⊘ (−)
LEVEL 2: DERIVED              Polynomials, matrices, convolution, derivative, integral
LEVEL 3: STRUCTURAL          Topology, convexity, Maslov dequantization, Galois theory
LEVEL 4: FUNCTORIAL          Linear algebra, eigenvalues, categories, sheaves
LEVEL 5: META-OPERATIONS     Oracles (O²=O), entropy, tropicalization, SAT solving
```

## Running the Demos

```bash
pip install numpy
python3 tropical_semiring_demo.py
python3 tropical_sat_solver.py
python3 tropical_experiments.py
```

## Key Discoveries

1. **Tropical Logic Completeness**: {max, min, 1−x} forms a complete Boolean basis — all 16 two-input Boolean functions can be expressed tropically.

2. **Maslov Bound**: The LogSumExp smooth approximation to max satisfies |LSE_ε(a,b) − max(a,b)| ≤ ε · log 2 (formally verified in Lean 4).

3. **Oracle Consensus Theorem**: For commuting idempotent operators, Fix(O₁ ∘ O₂) = Fix(O₁) ∩ Fix(O₂) — the joint oracle's truths are exactly those agreed upon by both.

4. **Phase Transition**: The tropical SAT solver detects the 3-SAT phase transition at m/n ≈ 4.267, confirming the framework's sensitivity to computational hardness.

5. **Entropy Refutation**: The conjecture H⊕(p) ≤ log n was experimentally REFUTED — tropical entropy can be unbounded. The correct bound is H(p) ≤ H⊕(p) (tropical always ≥ Shannon).
