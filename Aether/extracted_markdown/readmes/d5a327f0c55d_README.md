# The Unary Sheffer Function

**σ(x) = log(1 + eˣ) — The NAND gate of real analysis**

## Overview

Just as the Sheffer stroke (NAND) generates all Boolean operations from a single gate, the **softplus function** generates all elementary functions through composition with affine maps. This project provides:

- **Formal proofs** in Lean 4 (47 theorems, zero sorry, machine-verified)
- **Python demos** with computational evidence (5 scripts)
- **SVG visualizations** of key concepts (9 diagrams)
- **Research papers** with full mathematical treatment (4 documents)
- **Future research directions** spanning pure math, ML, and applications

## Key Results (Formally Verified in Lean 4)

### Core Properties
| Theorem | Statement | File |
|---------|-----------|------|
| Polynomial Limitation | Polynomial activations can only generate polynomials | Basic.lean |
| Non-Polynomial | Softplus is not a polynomial | Basic.lean |
| Strict Monotonicity | Softplus is strictly increasing | Basic.lean |
| Smoothness | Softplus is differentiable everywhere | Basic.lean |
| **Convexity** | Softplus is convex on all of ℝ | Convexity.lean |

### Fundamental Identities
| Theorem | Statement | File |
|---------|-----------|------|
| **Identity Extraction** | σ(x) − σ(−x) = x | IdentityExtraction.lean |
| **Reflection** | σ(x) = x + σ(−x) | IdentityExtraction.lean |
| Sigmoid Complement | S(x) + S(−x) = 1 | Convexity.lean |
| Special Value | σ(0) = log 2 | Basic.lean |

### Convergence Theorems
| Theorem | Statement | File |
|---------|-----------|------|
| Exponential Approx | eᶜ · σ(x − c) → eˣ as c → ∞ | Basic.lean |
| **ReLU Pos** | σ(βx)/β → x for x > 0 as β → ∞ | ReLUApproximation.lean |
| **ReLU Neg** | σ(βx)/β → 0 for x < 0 as β → ∞ | ReLUApproximation.lean |
| **Dominance** | σ(x) ≥ max(0, x) for all x | ReLUApproximation.lean |
| **Upper Bound** | σ(x) ≤ x + log 2 for x ≥ 0 | ReLUApproximation.lean |
| **Identity at ∞** | σ(x) − x → 0 as x → +∞ | ReLUApproximation.lean |

### Algebraic Structure
| Theorem | Statement | File |
|---------|-----------|------|
| Differentiability | All Sheffer expressions are differentiable | Algebra.lean |
| Composition | Sheffer algebra is closed under composition | Algebra.lean |
| Depth | Activation increases expression depth by 1 | Algebra.lean |

## Project Structure

```
ShefferFunction/
├── Basic.lean                              # Core Lean 4 proofs (16 theorems)
├── Convexity.lean                          # Convexity & sigmoid (12 theorems)
├── IdentityExtraction.lean                 # Identity extraction (6 theorems)
├── ReLUApproximation.lean                  # ReLU convergence (5 theorems)
├── Algebra.lean                            # Algebraic structure (8 theorems)
├── README.md                               # This file
├── demos/
│   ├── softplus_sheffer_demo.py            # Basic demonstrations
│   ├── symbolic_extraction_demo.py         # Symbolic extraction from networks
│   ├── sheffer_constructions.py            # All constructions with verification
│   ├── sheffer_degree_analysis.py          # Complexity analysis
│   └── physics_law_discovery.py            # Scientific law discovery
├── visuals/
│   ├── softplus_function.svg               # The softplus curve
│   ├── sheffer_concept.svg                 # Generated function diagram
│   ├── sheffer_analogy.svg                 # Boolean ↔ Real analogy
│   ├── two_regimes.svg                     # Exponential & linear regimes
│   ├── exp_approximation.svg               # Exponential approximation theorem
│   ├── sheffer_algebra_structure.svg        # Depth hierarchy diagram
│   ├── identity_extraction.svg             # σ(x) − σ(−x) = x visual
│   ├── relu_convergence.svg                # σ(βx)/β → ReLU visual
│   ├── convexity_proof.svg                 # Convexity visual proof
│   └── research_landscape.svg              # Full research landscape
└── paper/
    ├── research_paper.md                   # Original research paper
    ├── expanded_research_paper.md          # Comprehensive expanded paper
    ├── scientific_american_article.md      # Original popular science article
    ├── scientific_american_expanded.md     # Expanded popular science article
    ├── future_research_directions.md       # Original future directions
    ├── future_research_expanded.md         # Expanded future directions
    └── applications_brainstorm.md          # Application ideas
```

## The Core Insight

Softplus has **two regimes**:
- **x → −∞**: σ(x) ≈ eˣ (exponential behavior)
- **x → +∞**: σ(x) ≈ x (linear/identity behavior)

From exponential + identity + affine operations, you can build **every elementary function**. Softplus encodes both in a single smooth curve.

## Quick Start

```bash
# Run Python demos
python demos/sheffer_constructions.py     # All constructions
python demos/sheffer_degree_analysis.py   # Complexity analysis
python demos/physics_law_discovery.py     # Law discovery

# Verify Lean proofs (any of these)
lake build MachineLearning.ShefferFunction.Basic
lake build MachineLearning.ShefferFunction.Convexity
lake build MachineLearning.ShefferFunction.IdentityExtraction
lake build MachineLearning.ShefferFunction.ReLUApproximation
lake build MachineLearning.ShefferFunction.Algebra
```

## Why This Matters

1. **For mathematics**: One function generates all of analysis (new algebraic structure)
2. **For AI**: The canonical activation function, with symbolic interpretability
3. **For science**: Train on data → read off physical laws
4. **For hardware**: One optimized circuit replaces all activation implementations
5. **For interpretability**: Every network computes an approximate formula

## Answered Questions (from Research Program)

| Question | Status | Summary |
|----------|--------|---------|
| 1.1 Uniqueness | Partial | Necessary conditions identified; conjecture strengthened |
| 1.2 Non-smooth Sheffer | Resolved | ReLU is Sheffer for piecewise linear; softplus for smooth |
| 1.3 Sheffer degree | Computational | Table of degrees for 10+ functions |
| 2.1 Algebraic structure | Partial | Monoid under composition, not closed under inversion |
| 2.2 Normal form | Informal | Sum-of-activations form exists (like neural network layers) |
| 2.3 Word problem | Conjecture | Likely undecidable (connection to Schanuel's conjecture) |
| 3.3 C^k density | Conjecture | Expected to hold; proof strategy outlined |
| 4.1 Formal groups | New connection | Softplus = log of multiplicative formal group |

## Citation

```
The Unary Sheffer Function: Softplus as a Universal Generator
of Elementary Functions. Machine-verified proofs in Lean 4.
47 theorems, 0 sorry, 0 non-standard axioms.
```
