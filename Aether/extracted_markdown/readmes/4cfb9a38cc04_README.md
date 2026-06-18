# The Stereographic Projection Bridge: Research Package

## Overview

This directory contains a comprehensive research package exploring the **Stereographic Projection Bridge (SPB)** — the operation `spb(x, y) = (x + y) / (1 − xy)` — and its connections across mathematics, physics, and computer science.

The SPB is simultaneously:
- The **tangent addition formula**: tan(α + β) = spb(tan α, tan β)
- The **circle group law** on ℝ via the Cayley transform
- **Einstein's velocity addition** (with sign flip): spbH(u, v) = (u + v)/(1 + uv)
- A generator of **finite groups** over 𝔽_p with the p±1 order law

## Contents

### 📐 Lean 4 Formalization (`SPBNewResults.lean`)

Machine-verified theorems including:

| Theorem | Status |
|---|---|
| SPB commutativity, identity, inverse | ✅ Proved |
| SPB associativity | ✅ Proved |
| Cocycle identity | ✅ Proved |
| Cayley homomorphism | ✅ (in `Bridges/SPBCore.lean`) |
| Euler's formula: spb(1/2, 1/3) = 1 | ✅ Proved |
| Machin's formula verification | ✅ Proved |
| Hutton's formula | ✅ Proved |
| Three-leaf formulas: (2,4,13), (2,5,8), (3,3,7) | ✅ Proved |
| **Euler optimality**: unique 2-leaf Machin formula | ✅ Proved |
| **SPB reciprocal factored form** | ✅ Proved |
| **SPB derivative** (HasDerivAt) | ✅ Proved |
| **Derivative positivity** | ✅ Proved |
| **Einstein velocity bound**: |u|,|v| < 1 ⟹ |spbH(u,v)| < 1 | ✅ Proved |
| Integer classification: (1-ab) ∣ (a+b) | ✅ Proved |
| **Quadratic residue ↔ mod 4** (p±1 law foundation) | ✅ Proved |
| SPB neg-neg: spb(-x,-y) = -spb(x,y) | ✅ Proved |
| Double formula: spb(x,x) = 2x/(1-x²) | ✅ Proved |

### 🐍 Python Demos (`demos/`)

| Script | Description |
|---|---|
| `spb_explorer.py` | 10 interactive demos: tangent addition, Machin formulas, orbits, equidistribution, integer classification, continued fractions, tropical SPB |
| `spb_finite_fields.py` | p±1 law verification for all odd primes < 200, with detailed group structure analysis and Cayley tables |
| `spb_neural_network.py` | SPB neural network architecture: activation properties, universal approximation, invertibility |
| `spb_cordic.py` | SPB-CORDIC: alternative trigonometric computation architecture |

### 🎨 SVG Visualizations (`visuals/`)

| File | Description |
|---|---|
| `spb_cayley_bridge.svg` | The Cayley transform mapping SPB to circle multiplication |
| `spb_unified_framework.svg` | SPB connections across 8 domains |
| `p_pm1_law.svg` | Chart of SPB group orders vs primes |
| `machin_optimality.svg` | Proof diagram for Euler's formula optimality |
| `einstein_velocity.svg` | Einstein velocity addition vs Galilean |

### 📄 Articles

| File | Description |
|---|---|
| `scientific_american_article.md` | Popular science article: "The Formula That Connects Everything" |
| `research_paper.md` | Technical research paper with 25+ future directions |

## Key Discoveries

### 1. Euler's π Formula is Provably Optimal
The equation spb(1/a, 1/b) = 1 with a, b ≥ 2 has the unique solution (a, b) = (2, 3). This means Euler's formula π/4 = arctan(1/2) + arctan(1/3) is the minimal Machin-type formula — machine-verified in Lean 4.

### 2. The p±1 Law
The SPB group over 𝔽_p has order p+1 when p ≡ 3 (mod 4) and p−1 when p ≡ 1 (mod 4). Computationally verified for all odd primes < 200. The foundation (quadratic residue characterization) is formally proved.

### 3. SPB Neural Networks
SPB-based neurons offer unique advantages: natural boundedness, smoothness, exact invertibility, and algebraic layer collapse. Two SPB layers with weights w₁, w₂ are mathematically identical to one layer with weight spbH(w₁, w₂).

### 4. SPB-CORDIC Architecture
An alternative to classical CORDIC for trigonometric computation, using SPB accumulation instead of coordinate rotation. Achieves 12 digits of precision in 40 iterations.

### 5. Tropical SPB Breaks Associativity
The tropical limit tspb(x, y) = max(x, y) − max(0, x+y) is commutative but NOT associative — the group structure of SPB is genuinely non-tropical.

## Future Research Priorities

See `research_paper.md` for the full 25-direction roadmap. Top priorities:

1. **Complete p±1 formal proof** via Cayley transform over finite fields
2. **Equidistribution theorem** for SPB orbits (Weyl's theorem via Cayley)
3. **Quaternionic SPB** for 3D rotations and Thomas precession
4. **SPB neural network benchmarks** against standard architectures
5. **Elliptic SPB** replacing S¹ with an elliptic curve

## Running the Code

```bash
# Python demos (no dependencies beyond standard library)
python3 demos/spb_explorer.py
python3 demos/spb_finite_fields.py
python3 demos/spb_neural_network.py
python3 demos/spb_cordic.py

# Lean verification
lake build FutureResearch.SPBBridge.SPBNewResults
```
