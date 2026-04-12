# Future Research Directions for Gravitational Factoring

## Overview

This directory contains a comprehensive research package exploring the gravitational factoring framework — a geometric approach to integer factorization via Pythagorean k-tuples, division algebras, and energy landscape navigation.

## Contents

### Formal Mathematics (Lean 4 + Mathlib)

| File | Description | Theorems |
|------|-------------|----------|
| `LagrangeFourSquare.lean` | Lagrange's theorem, Euler's identity, Cayley-Dickson hierarchy, Berggren tree, Grover speedup, tropical geometry | 18 verified theorems, 0 sorries |
| `CrossCollisionTheory.lean` | Cross-collision mechanism, peel channels, density theory, GCD cascade, congruence of squares | 14 verified theorems, 0 sorries |

### Python Demonstrations

| File | Description |
|------|-------------|
| `demos/gravitational_factoring_demo.py` | 11 comprehensive demos: density verification, k-tuple generation, factor extraction, quaternion factoring, energy landscape, Berggren tree, channel analysis, cross-collision, tropical geometry, statistical mechanics, method comparison |
| `demos/sedenion_zero_divisors.py` | Sedenion (dim 16) zero-divisor explorer using Cayley-Dickson construction |

### SVG Visualizations

| File | Description |
|------|-------------|
| `visuals/cayley_dickson_hierarchy.svg` | The division algebra hierarchy with channel counts and properties lost |
| `visuals/energy_landscape.svg` | The factoring energy landscape with gravitational wells |
| `visuals/berggren_tree.svg` | The Berggren tree structure for Pythagorean triple navigation |
| `visuals/channel_amplification.svg` | Channel count growth across dimensions |
| `visuals/quantum_speedup.svg` | Classical vs quantum vs Shor complexity comparison |
| `visuals/research_roadmap.svg` | Timeline and dependency map of 40 research directions |

### Research Papers and Articles

| File | Description |
|------|-------------|
| `research_paper.md` | Full research paper with 13 sections covering the complete framework |
| `scientific_american_article.md` | Popular science article: "The Gravity of Numbers" |
| `future_research_directions.md` | 40 prioritized research directions with detailed specifications |
| `applications_brainstorm.md` | 30+ application ideas across cryptography, pure math, CS, physics, education |
| `answers_to_open_questions.md` | Detailed answers to 15 key open questions |

## Key Results

1. **All theorems compile without sorry** — every formal claim is machine-verified
2. **18+ new formally verified theorems** covering Lagrange, Euler, density, channels, Berggren, Grover, tropical geometry, and lattice theory
3. **40 research directions** organized by impact and feasibility
4. **11 computational demos** with working Python code
5. **6 publication-quality SVG visualizations**

## Running the Demos

```bash
# Main demo suite (11 experiments)
python3 demos/gravitational_factoring_demo.py

# Sedenion zero-divisor explorer (requires numpy)
python3 demos/sedenion_zero_divisors.py
```

## Building the Lean Files

```bash
lake build FutureResearchDirections
```
