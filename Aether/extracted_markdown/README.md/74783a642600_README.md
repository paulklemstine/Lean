# Open Questions: Gravitational Factoring Research

## Overview

This directory contains a comprehensive research package addressing the major open questions in the gravitational factoring framework. It includes formally verified mathematics, computational experiments, visualizations, research papers, and a detailed applications brainstorm.

## Contents

### Formal Mathematics (Lean 4 + Mathlib)

| File | Description | Theorems |
|------|-------------|----------|
| `SieveAndLattice.lean` | Sieve complexity, lattice-GCD, cross-collision, σ₁ theory, coding theory, quantum bounds | 30 verified theorems, 0 sorries |

**Key verified results:**
- σ₁ multiplicativity for coprime arguments
- Lattice factor extraction theorem
- Peel smoothness theory (IsSmooth definition and closure properties)
- Cross-collision channel counts (k = 2, 4, 8, 16)
- Berggren tree modular preservation
- GF(2) null vector existence for smooth relations
- Quantum speedup bounds

### Python Demonstrations

| File | Description |
|------|-------------|
| `demos/open_questions_explorer.py` | 8 demos: peel smoothness, lattice-GCD, cross-collision, σ₁ verification, Berggren periodicity, GF(2) coding theory, adelic structure, channel scaling |

### SVG Visualizations

| File | Description |
|------|-------------|
| `visuals/open_questions_roadmap.svg` | Complete roadmap of all research directions with verification status |
| `visuals/smoothness_advantage.svg` | Why peel products are exponentially smoother than random integers |
| `visuals/lattice_gcd_mechanism.svg` | The lattice-GCD polynomial-time factoring mechanism |
| `visuals/cross_collision_mechanism.svg` | Cross-collision factor extraction with channel counts |

### Research Documents

| File | Description |
|------|-------------|
| `research_paper_open_questions.md` | Full research paper: formal proofs, computational evidence, new directions |
| `scientific_american_article.md` | Popular science article: "The Geometry of Secrets" |
| `future_research_directions_v2.md` | 50 prioritized research directions with feasibility and impact analysis |
| `applications_brainstorm.md` | 33 application ideas across 10 domains |
| `answers_to_open_questions_v2.md` | Detailed answers to 10 fundamental questions with confidence levels |

## Quick Start

### Verify formal proofs
```bash
lake build FutureResearchDirections.OpenQuestions.SieveAndLattice
```

### Run computational experiments
```bash
python3 demos/open_questions_explorer.py
```

## Key Findings

1. **Sieve Complexity**: Peel products have a 3-10,000× smoothness advantage over random integers, but the asymptotic complexity matches QS at L(N)¹.

2. **Lattice-GCD**: Factor extraction from short lattice vectors is formally verified. The O((log N)⁸) polynomial-time possibility is the most important open question.

3. **Cross-Collision**: The Ω(k²/√N) probability bound is validated by Monte Carlo simulation with <3% error.

4. **σ₁ Multiplicativity**: Formally verified, establishing the algebraic prerequisite for Jacobi's r₄(n) = 8σ₁(n).

5. **Coding Theory**: B + 1 smooth relations guarantee a GF(2) dependency, connecting factoring to binary code theory.

## Theorem Count

| Source | Verified | Sorry |
|--------|:--------:|:-----:|
| `SieveAndLattice.lean` | 30 | 0 |
| `LagrangeFourSquare.lean` | 18 | 0 |
| `CrossCollisionTheory.lean` | 14 | 0 |
| **Total** | **62** | **0** |

All theorems use only standard axioms (propext, Classical.choice, Quot.sound).
