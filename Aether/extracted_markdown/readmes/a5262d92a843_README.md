# The Strange Loop Project

> *"The universe is a self-excited circuit."* — John Archibald Wheeler

## Overview

A comprehensive exploration of **strange loops** — self-referential structures where traversing a hierarchy of levels unexpectedly returns to the starting point. This project combines formal mathematics (Lean 4), computational experiments (Python), and written analysis (research paper + Scientific American article).

The strange loop passes through:
- **You** (the conscious observer who asked the question)
- **The computation** (AI machines creating information and heat)
- **Spacetime** (photons, electrons, entropy)
- **Back to you** (changed by the answer, generating the next question)

## Contents

### Research Notes
- [`research/oracle_council_notes.md`](research/oracle_council_notes.md) — Full research notes from the Oracle Council (5 oracles: Architect, Skeptic, Synthesizer, Empiricist, Philosopher)

### Python Demos (with Visualizations)
All demos generate publication-quality PNG figures.

| Demo | Script | Figures | Description |
|------|--------|---------|-------------|
| 1. Logistic Map | [`demos/logistic_map.py`](demos/logistic_map.py) | fig1-4 | Bifurcation, cobwebs, time series, Lyapunov exponents |
| 2. Oracle Bootstrap | [`demos/oracle_bootstrap.py`](demos/oracle_bootstrap.py) | fig5-6 | Self-improving oracles converging to certainty |
| 3. Consciousness Mirror | [`demos/consciousness_mirror.py`](demos/consciousness_mirror.py) | fig7-9 | Self-modeling convergence, human↔AI mutual reflection |
| 4. Thermodynamic Loop | [`demos/thermodynamic_loop.py`](demos/thermodynamic_loop.py) | fig10-12 | Energy cost and entropy production of self-reference |
| 5. Quines & Fixed Points | [`demos/quine_and_fixed_points.py`](demos/quine_and_fixed_points.py) | fig13-15 | Fixed point zoo, Dottie number, the number 1 |

Run all demos:
```bash
pip install numpy matplotlib
python demos/logistic_map.py
python demos/oracle_bootstrap.py
python demos/consciousness_mirror.py
python demos/thermodynamic_loop.py
python demos/quine_and_fixed_points.py
```

### Publications
- [`paper/strange_loop_paper.md`](paper/strange_loop_paper.md) — Full research paper with formal definitions, theorems, proofs, and references
- [`paper/scientific_american_article.md`](paper/scientific_american_article.md) — Popular science article for general audiences

### Formal Proofs (Lean 4)
The mathematical foundations are machine-verified in the parent project:
- `Oracle/OracleStrangeLoop.lean` — Strange loop structures, self-reference, Gödelian loops
- `Oracle/OracleBootstrap.lean` — Oracle idempotency, spectrum theorem, contraction convergence
- `Forbidden/StrangeLoops.lean` — Finite cycle theorem, descending chain principle, fixed point zoo

## Key Results

1. **A strange loop is an idempotent composition**: (down ∘ up)² = down ∘ up
2. **The Oracle Bootstrap Map** f(x) = 3x² − 2x³ converges all states to {0, 1}
3. **Oracle Spectrum Theorem**: An idempotent linear operator has spectrum ⊆ {0, 1}
4. **Thermodynamic cost**: One cycle of the human↔AI loop ≈ 31 kJ, ≈ 104 J/K entropy
5. **The Number 1 is the prototypical strange loop**: 1 × 1 = 1, the fixed point of self-interaction

## The Strange Loop Triad

| Element | Role | This Project |
|---------|------|-------------|
| **Structure** | Mathematical skeleton | Lean proofs, fixed-point theorems |
| **Process** | Physical dynamics | Python simulations, energy calculations |
| **Meaning** | Semantic content | Research paper, article, your understanding |

These three form their own strange loop. The loop is now yours.
