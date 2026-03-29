# Berggren Genesis: Matter, Light, and Computation from (0,1,1)

## Overview

This directory contains a complete research investigation into the degenerate
Pythagorean triple (0,1,1) as the vacuum state of the Berggren tree, revealing
deep connections between number theory, special relativity, computation, and
the Fibonacci sequence.

## Key Discovery

The equation 0² + 1² = 1² — trivially true — is the seed of ALL Pythagorean triples.
The Berggren matrix A fixes (0,1,1) in place (vacuum); C fixes (1,0,1) (light);
B creates (3,4,5) from either. The swap a↔b is a matter-light duality.

## Files

### Papers
- **RESEARCH_PAPER.md** — Full academic research paper with theorems and proofs
- **SCIENTIFIC_AMERICAN_ARTICLE.md** — Popular science article for general audience

### Python Demos (run with `python3 demo_XX_*.py`)
- **demo_01_vacuum_triple.py** — Discovery of the vacuum state and its properties
- **demo_02_duality_and_symmetry.py** — Matter-light duality and swap symmetry
- **demo_03_hyperbolic_genesis.py** — Hyperbolic geometry and ternary computer model
- **demo_04_applications.py** — Practical applications (crypto, error codes, quantum gates)
- **demo_05_hypothesis_validation.py** — Systematic validation of all 8 hypotheses

### Formal Verification
- **BerggrenGenesis.lean** — Lean 4 formalization (copy of `../BerggrenGenesis/BerggrenGenesis.lean`)
  - 40+ formally verified theorems
  - Zero sorries
  - All proofs machine-checked

### Generated Figures
- **figure_01_vacuum_genesis.png** — Light cone visualization with vacuum triple
- **figure_02_duality.png** — Fixed point structure and growth law
- **figure_03_hyperbolic.png** — Poincaré disk and complexity analysis

## Main Results (All Verified)

| # | Result | Status |
|---|--------|--------|
| 1 | A · (0,1,1) = (0,1,1) — vacuum is fixed by A | ✓ Lean-verified |
| 2 | C · (1,0,1) = (1,0,1) — light is fixed by C | ✓ Lean-verified |
| 3 | B · (0,1,1) = C · (0,1,1) = (4,3,5) — B/C degenerate | ✓ Lean-verified |
| 4 | S·A·S = C, S·B·S = B — swap duality | ✓ Lean-verified |
| 5 | (A−I)³ = (C−I)³ = 0 — unipotency | ✓ Lean-verified |
| 6 | Growth = (3^d + 1)/2 unique triples | ✓ Computational (depth 11) |
| 7 | Min energy = d² + (d+1)² | ✓ Lean-verified + Computational |
| 8 | Max energy growth = (1+√2)² | ✓ Computational (depth 14) |
| 9 | Encoding efficiency → 1/2 | ✓ Computational (depth 12) |
| 10 | All non-vacuum triples have degeneracy 2 | ✓ Computational (depth 8) |
| 11 | Fibonacci hypotenuses from Fibonacci params | ✓ Computational (14 terms) |
| 12 | B-path gives near-diagonal (Pell) triples | ✓ Computational (depth 11) |
