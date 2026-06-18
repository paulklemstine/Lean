# MetaFactoring: A Multi-Lens Framework for Integer Factorization

## Formally Verified in Lean 4 with Mathlib

---

## Overview

MetaFactoring synthesizes **seven complementary factoring paradigms** into a unified framework. Each paradigm provides a different "lens" through which to view the factorization problem. Combining lenses multiplicatively constrains the search space far more than any single method alone.

## Repository Structure

### Lean 4 Formalizations (all sorry-free, machine-verified)

| File | Description | Theorems |
|------|-------------|----------|
| `Core.lean` | Foundational framework: 7 lenses, unified correctness | 10 |
| `FutureDirections.lean` | Five research thrusts: constraint intersection, Fibonacci-spectral, division algebra, quantum, adjacent problems | 21 |
| `OpenQuestions.lean` | Resolved open questions: Pisano unification, norm-congruence bridge, Hurwitz barrier | 24 |
| `AdvancedTheorems.lean` | Advanced results: Euler criterion, Fermat two-square, tropical valuations, group theory | 25+ |
| `BridgeTheorems.lean` | Cross-cutting bridges between lenses | — |
| `NewTheorems.lean` | Additional results | — |

**Total: 80+ machine-verified theorems, 0 sorries**

### Python Demos

| File | Description |
|------|-------------|
| `demos/pisano_periods.py` | Pisano period computation, unified divisibility verification, multi-lens advantage |
| `demos/seven_lenses.py` | All 7 lenses demonstrated on concrete composites, correlation experiment |
| `demos/norm_channel_factoring.py` | Division algebra norm channels: 2-square, 4-square, Hurwitz barrier |
| `demos/quantum_hybrid.py` | Quantum-classical hybrid advantage quantification |

### SVG Visualizations

| File | Description |
|------|-------------|
| `visuals/seven_lenses_diagram.svg` | The seven-lens framework architecture |
| `visuals/pisano_divisibility.svg` | Unified Pisano divisibility theorem proof structure |
| `visuals/division_algebra_hierarchy.svg` | Norm channel hierarchy with Hurwitz barrier |
| `visuals/quantum_hybrid.svg` | Quantum-classical hybrid advantage chart |
| `visuals/theorem_map.svg` | Complete theorem dependency map across all thrusts |

### Research Papers

| File | Description |
|------|-------------|
| `papers/open_questions_answered.md` | Technical paper: all resolved questions with theorem references |
| `papers/future_research_directions.md` | Roadmap: 15 research programs across 3 tiers |
| `papers/scientific_american_article.md` | Popular science article on MetaFactoring |

## Key Results

### 1. Unified Pisano Divisibility (Thrust II)
For every prime p ≠ 5: **p | F(p² − 1)**. Unifies the split and inert cases via p²−1 = (p−1)(p+1).

### 2. Norm-Congruence Bridge (Thrust III → VII)
If p ≡ 3 (mod 4) and p | a²+b², then p | a and p | b. Connects Gaussian integers to congruence of squares.

### 3. Hurwitz Barrier (Thrust III)
No naive 16-square pointwise identity exists. Composition algebras exist only in dimensions 1, 2, 4, 8.

### 4. Hybrid Quantum Speedup (Thrust IV)
k classical lenses save 2^(k/2) in Grover queries. 7 lenses → 11.3× fewer quantum queries.

### 5. Euler's Criterion & Fermat Two-Square (New)
-1 is a QR mod p iff p ≢ 3 (mod 4). Every prime p ≡ 1 (mod 4) is a sum of two squares.

## Running

```bash
# Build all Lean files
lake build MetaFactoring

# Run Python demos
python3 MetaFactoring/demos/pisano_periods.py
python3 MetaFactoring/demos/seven_lenses.py
python3 MetaFactoring/demos/norm_channel_factoring.py
python3 MetaFactoring/demos/quantum_hybrid.py
```

## Axioms Used

All proofs use only the standard Lean 4 axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)
- `Lean.ofReduceBool` / `Lean.trustCompiler` (kernel reduction, used by `decide`)
