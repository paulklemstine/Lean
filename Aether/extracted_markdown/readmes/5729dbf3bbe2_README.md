# A* Factoring via the Pythagorean Triple Tree
## The Gaussian Integer Connection

### Overview

This project explores a novel approach to integer factoring that uses A* search on the
Berggren ternary tree of primitive Pythagorean triples, combined with Gaussian integer
composition. The core insight is that the *additive* structure of the Berggren tree
(matrix multiplication) and the *multiplicative* structure of the Gaussian integers
(complex multiplication) are bridged by the Brahmagupta-Fibonacci identity.

### Project Structure

```
AStarFactoring/
├── README.md                     # This file
├── Main.lean                     # Lean 4 scaffold
├── GaussianBridge.lean           # Formal verification (Lean 4 + Mathlib)
│
├── demos/                        # Python demonstrations
│   ├── astar_factoring.py        # Core A* factoring algorithm
│   ├── gaussian_integers.py      # Gaussian integer bridge
│   ├── oracle_council.py         # Research oracle team simulation
│   ├── tree_sieve.py             # Tree sieve (combining relations)
│   └── visualizations.py         # ASCII visualizations
│
├── research/                     # Research documents
│   ├── oracle_council_notes.md   # Detailed research notes
│   ├── research_paper.md         # Full research paper
│   └── scientific_american_article.md  # Popular science article
│
└── visuals/                      # (Generated visualizations go here)
```

### Quick Start

```bash
# Run the core A* factoring demo
python3 demos/astar_factoring.py

# Explore Gaussian integer connections
python3 demos/gaussian_integers.py

# Run the Oracle Council research session
python3 demos/oracle_council.py

# Test the tree sieve algorithm
python3 demos/tree_sieve.py

# Generate all visualizations
python3 demos/visualizations.py
```

### Formal Verification

The mathematical foundations are machine-verified in Lean 4. Key results:

| Theorem | File | Status |
|---------|------|--------|
| Brahmagupta-Fibonacci Identity | `GaussianBridge.lean` | ✅ Verified |
| Gaussian Norm Multiplicativity | `GaussianBridge.lean` | ✅ Verified |
| Pythagorean Triple Composition | `GaussianBridge.lean` | ✅ Verified |
| Euler's Factoring Identity | `GaussianBridge.lean` | ✅ Verified |
| Euclid Parametrization = Gaussian Square | `GaussianBridge.lean` | ✅ Verified |
| Bridge Theorem (Composition = Product) | `GaussianBridge.lean` | ✅ Verified |
| Berggren Matrix Preservation | `../Pythagorean/Berggren.lean` | ✅ Verified |
| Factoring Bijection | `../Pythagorean/PythagoreanFactoring.lean` | ✅ Verified |
| Prime Uniqueness of Triples | `../Pythagorean/PythagoreanFactoring.lean` | ✅ Verified |

### Key Mathematical Results

1. **The Factoring Bijection**: Same-parity divisor pairs of N² biject with Pythagorean triples having leg N.

2. **The Gaussian Bridge**: Composing Pythagorean triples via Gaussian multiplication (a+bi)(c+di) bridges the additive Berggren tree with multiplicative factoring.

3. **Euler's Method**: Two distinct sum-of-squares representations N = a²+b² = c²+d² yield a non-trivial factor of N.

4. **The Bridge Theorem**: The composed Euclid parameters (m₃, n₃) from Gaussian multiplication give a valid Pythagorean triple with hypotenuse equal to the product of the original hypotenuses.

### Research Directions

1. **Tree Sieve**: Combining partial tree relations via Gaussian multiplication (most promising)
2. **Spectral Analysis**: Spectral gap of Berggren walk on SO(2,1; ℤ/Nℤ) governs complexity
3. **Lattice Hybrid**: LLL reduction on Berggren-generated lattice vectors
4. **Modular Forms**: Connection via theta subgroup Γ_θ to analytic number theory
