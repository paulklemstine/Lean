# MetaFactoring: Future Research Directions — New Research

## Overview

This directory contains the extended formalization and exploration of the MetaFactoring research roadmap. All theorems are **machine-verified in Lean 4 with Mathlib** — zero `sorry` markers remain.

## Directory Structure

### Lean Formalizations (7 files, 61 theorems, 0 sorry)

| File | Theorems | Topics |
|------|----------|--------|
| `DickmanFunction.lean` | 10 | Dickman ρ(u), positivity, monotonicity, smooth numbers, L-notation |
| `SubBinaryRecurrence.lean` | 10 | Fibonacci, Lucas, Tribonacci, Padovan < 2^n; general 2-term bound |
| `IndependenceLenses.lean` | 8 | CRT independence, coprime primes, k-lens reduction |
| `EllipticDivisibility.lean` | 6 | gcd(F_m,F_n)=F_{gcd(m,n)}, EDS structure, Pisano periods |
| `TropicalFactoring.lean` | 8 | p-adic constraints, semiprime profile, smooth↔tropical, square detection |
| `QuantumLensIntegration.lean` | 9 | Qubit savings, physical qubit costs, RSA-2048 analysis |
| `ComplexityLowerBounds.lean` | 10 | Information-theoretic limits, polynomial speedup, RSA security |

### Python Demos (3 files)

| File | Description |
|------|-------------|
| `demos/demo_dickman_function.py` | Dickman function computation, smooth number counting, L-notation |
| `demos/demo_sub_binary_recurrences.py` | Sequence comparison, growth ratios, search space reduction |
| `demos/demo_independence_and_tropical.py` | CRT independence, tropical profiles, quantum integration |

### SVG Visualizations (5 files)

| File | Description |
|------|-------------|
| `visuals/dickman_function.svg` | The Dickman function curve with key properties |
| `visuals/sub_binary_growth.svg` | Four sub-binary sequences vs 2^n |
| `visuals/research_roadmap_v3.svg` | 12-direction research roadmap with status |
| `visuals/quantum_lens_integration.svg` | Qubit budget analysis for RSA-2048 |
| `visuals/tropical_profile.svg` | Tropical profile of a semiprime |

### Written Documents (4 files)

| File | Description |
|------|-------------|
| `research_paper.md` | Full research paper with all verified results |
| `sciam_article.md` | Scientific American-style article |
| `applications_brainstorm.md` | 20+ application ideas across 7 domains |
| `future_research_recommendations.md` | Extended analysis of 12 research directions |

## Key Results

1. **Dickman Function:** ρ(u) > 0 on (0,2], monotonically decreasing. Connected to smooth number counting Ψ(x,y) and GNFS complexity L[1/3, c].

2. **Sub-Binary Recurrences:** All four sequences (Fibonacci, Lucas, Tribonacci, Padovan) proved to grow slower than 2^n. General two-term recurrence bound established.

3. **9 Independent Lenses:** CRT proves independence. Combined with 9 coprime primes [2,3,5,7,11,13,17,19,23], giving 9 independent factoring constraints.

4. **Tropical Factoring:** p-adic valuations provide orthogonal constraints. Semiprime profile theorem: exactly two spikes at height 1. Smooth numbers characterized tropically.

5. **Quantum Savings:** 9 lenses save 5 logical qubits = 4,410 physical qubits for RSA-2048.

6. **Security Preserved:** Multi-lens speedup is polynomial (2^9 = 512), negligible against 2^1024.

## How to Verify

```bash
# Build any individual file
lake build FutureResearchDirections.NewResearch.DickmanFunction
lake build FutureResearchDirections.NewResearch.SubBinaryRecurrence
# ... etc.

# Run Python demos
python3 demos/demo_dickman_function.py
python3 demos/demo_sub_binary_recurrences.py
python3 demos/demo_independence_and_tropical.py
```

## Dependencies

- Lean 4.28.0
- Mathlib (v4.28.0)
- Python 3 (for demos, no external packages needed)
