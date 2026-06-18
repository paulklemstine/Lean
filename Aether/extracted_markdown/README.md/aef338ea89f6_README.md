# Fibonacci Arithmetic & The Universal Tree

## Overview

This module explores Fibonacci (Zeckendorf) arithmetic and its deep connections to the Stern-Brocot tree, Pythagorean triples, the golden ratio, and the rational structure of geometry.

## Contents

### Formal Proofs (Lean 4)
- **`FibonacciArithmetic.lean`** — 9 theorems, all machine-verified:
  - Fibonacci monotonicity, recurrence, carry rule, duplicate carry
  - Fibonacci divisibility theorem: k ∣ n → F(k) ∣ F(n)
  - Fibonacci GCD identity: gcd(F(m), F(n)) = F(gcd(m, n))
  - Euclid's Pythagorean parametrization
  - Stern-Brocot mediant property
  - Golden ratio identity: φ² = φ + 1

### Python Demos
- **`demos/fibonacci_arithmetic.py`** — Complete Fibonacci arithmetic engine with:
  - Zeckendorf representation (encoding/decoding)
  - Addition with Fibonacci carry
  - Subtraction with Fibonacci borrow
  - Multiplication (schoolbook via partial products)
  - GCD (Euclidean algorithm)
  - Trial factoring
  - Exhaustive verification suite (5000+ test cases, all passing)

- **`demos/stern_brocot_pythagorean.py`** — The Stern-Brocot tree and its connections:
  - The Fibonacci golden spine (RLRL... → F(n+1)/F(n) → φ)
  - Pythagorean triples from the tree (via Euclid parametrization)
  - Berggren tree generation
  - Rational points on the unit circle ("circle of light")
  - Continued fractions ↔ Stern-Brocot paths
  - Full verification

- **`demos/fibonacci_factoring_explorer.py`** — Factoring through Fibonacci lenses:
  - Zeckendorf structure of factors
  - Fibonacci GCD factoring experiments
  - Index pattern analysis (primes vs composites)
  - Fibonacci number factoring via index divisibility
  - Cross-domain views (same number across representations)

### Visualizations (SVG)
- **`visuals/fig1_zeckendorf_table.svg`** — Zeckendorf representations for 1–30
- **`visuals/fig2_fibonacci_carry.svg`** — The Fibonacci carry cascade
- **`visuals/fig3_stern_brocot_tree.svg`** — Stern-Brocot tree with golden spine
- **`visuals/fig4_pythagorean_circle.svg`** — Pythagorean triples on the unit circle
- **`visuals/fig5_complexity_heatmap.svg`** — Zeckendorf weight heatmap (1–200)
- **`visuals/fig6_universal_map.svg`** — The Universal Map (one tree, five faces)

### Written Deliverables
- **`RESEARCH_NOTES.md`** — Detailed iteration log from the Oracle Council
- **`RESEARCH_PAPER.md`** — Full research paper with proofs and analysis
- **`SCIENTIFIC_AMERICAN_ARTICLE.md`** — Popular science article

## Quick Start

```bash
# Run the main Fibonacci arithmetic demo
cd demos && python3 fibonacci_arithmetic.py

# Run the Stern-Brocot + Pythagorean demo
python3 stern_brocot_pythagorean.py

# Run the factoring explorer
python3 fibonacci_factoring_explorer.py

# Generate all SVG figures
cd ../visuals && python3 generate_all_visuals.py
```

## Key Results

1. **Fibonacci Arithmetic Works**: Complete, verified arithmetic in Zeckendorf representation
2. **The Golden Spine**: Fibonacci ratios = zigzag path in Stern-Brocot tree → φ
3. **One Tree, Five Faces**: Stern-Brocot simultaneously generates all rationals, all CFs, all Pythagorean triples, all rational angles, and the Fibonacci sequence
4. **The Carry Rule IS the Golden Ratio**: F(k) + F(k+1) = F(k+2) ↔ φ² = φ + 1
