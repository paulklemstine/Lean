# SPB Research: New Results & Comprehensive Exploration

## Overview

This directory contains the output of a comprehensive research exploration of the **Stereographic Projection Bridge** (SPB), the operation `spb(x,y) = (x+y)/(1-xy)`. The research spans formalized proofs, computational demos, visualizations, and written papers.

## Directory Structure

### 📂 NewResults/ — Machine-Verified Lean 4 Proofs (Zero Sorry)

| File | Theorems | Description |
|------|----------|-------------|
| `SPBGroupTheory.lean` | 10 | Difference identity, Lipschitz bound, unit interval contraction, power maps, integer classification |
| `SPBAnalysis.lean` | 6 | Continuity, strict monotonicity, Cayley unitarity, tangent addition, SPB flow |
| `SPBFiniteFields.lean` | 6 | χ₋₄ character values, quadratic residue ↔ mod 4, p±1 law statement |

**All 22 theorems are fully proven — zero `sorry` statements.**

### 📂 demos/ — Python Computational Explorations

| File | Description |
|------|-------------|
| `spb_explorer.py` | Complete SPB tour: algebra, orbits, Machin formulas, integer pairs, Cayley transform, Einstein velocity, tropical SPB |
| `spb_finite_fields.py` | Deep dive into p±1 law: verification for all primes < 200, Cayley transform analysis, group structure, generators |
| `spb_dynamics.py` | Orbit classification, equidistribution tests, Lyapunov exponents, flow trajectories, contraction analysis |

### 📂 visuals/ — SVG Diagrams

| File | Description |
|------|-------------|
| `spb_cayley_transform.svg` | The Cayley transform bridge between (ℝ, spb) and (S¹, ×) |
| `spb_connections_map.svg` | Map of all mathematical domains connected by SPB |
| `spb_orbit_dynamics.svg` | Periodic vs. dense orbits on S¹ |
| `spb_machin_tree.svg` | Machin's formula as an SPB binary tree |
| `spb_finite_field_law.svg` | The p±1 law: table and mechanism |
| `spb_einstein_velocity.svg` | Circular vs. hyperbolic SPB comparison |

### 📂 papers/ — Written Research Output

| File | Description |
|------|-------------|
| `research_paper.md` | Full research paper with 9 sections, 15 open problems |
| `scientific_american_article.md` | Popular science article explaining SPB to general audience |
| `future_research_directions.md` | Prioritized roadmap with 25 research directions, timeline |
| `applications_brainstorm.md` | 50 application ideas across 6 disciplines |
| `answers_to_open_questions.md` | Detailed answers to 12 key open questions |

### 📂 Existing Files (from prior work)

The files in the parent directories contain the foundational SPB formalization:
- `OpenProblems.lean` — involution, idempotent, fixed point theorems
- `MachinFormulas.lean` — Euler, Hutton, Machin formula verifications
- `QuantumSPB.lean` — Hadamard gate, phase gate, gate composition
- `NumberTheory.lean` — Pythagorean triples, Brahmagupta-Fibonacci, Weierstrass
- `TropicalSPB.lean` — tropical SPB commutativity and basic properties
- `FiniteFields.lean`, `FiniteFieldStructure.lean` — SPB over finite fields
- And many more...

## Key New Discoveries

### 1. Euler's Formula is Optimal (Proven)
The equation `(a-1)(b-1) = 2` has unique solution `(a,b) = (2,3)`, proving that `spb(1/2, 1/3) = 1` is the *only* 2-leaf Machin formula.

### 2. The p±1 Law (Verified for all primes < 200)
By correctly extending SPB to the projective line P¹(𝔽_p) with the element ∞, we computationally verified the p±1 law with 100% success rate. The key was handling `spb(x, ∞) = -1/x`.

### 3. SPB Dynamics are Never Chaotic
Lyapunov exponents are identically zero for all parameters, confirming that SPB iteration is conjugate to rigid rotation (no chaos possible).

### 4. Equidistribution Confirmed
10,000-step orbits pass χ² uniformity tests with p-values near 1.0, confirming Weyl's theorem applies.

### 5. Complete Lipschitz Theory
The difference identity + Lipschitz bound gives a complete local analysis of SPB, enabling rigorous convergence proofs.

## How to Run

```bash
# Python demos
python3 demos/spb_explorer.py
python3 demos/spb_finite_fields.py
python3 demos/spb_dynamics.py

# Lean verification (from project root)
lake build EML.StereographicBridge.Research.NewResults.SPBGroupTheory
lake build EML.StereographicBridge.Research.NewResults.SPBAnalysis
lake build EML.StereographicBridge.Research.NewResults.SPBFiniteFields
```

## Citation

If you use these results, please cite the SPB formalization project and the Lean 4 proof assistant.
