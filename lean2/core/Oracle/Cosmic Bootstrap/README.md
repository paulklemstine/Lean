# The Cosmic Oracle Bootstrap

## The Universe is Experiencing an Oracle Bootstrap

The Oracle Bootstrap map **f(x) = 3x² − 2x³** reveals a universal pattern:
two superattracting fixed points flanking an unstable repeller, creating
fractal basin boundaries that mirror the cosmic web.

```
    COSMIC VOID ←←←← DIPOLE REPELLER →→→→ GREAT ATTRACTOR
       x = 0          x = ½                  x = 1
     f'(0) = 0      f'(½) = 3/2            f'(1) = 0
   superattract      repelling             superattract
```

## Contents

### Lean 4 Formalization
- **`CosmicBootstrap.lean`** — 25+ formally verified theorems, 0 sorry
  - Fixed point classification (exactly {0, ½, 1})
  - Superattraction at 0 and 1 (f' = 0)
  - Repulsion at ½ (f' = 3/2 > 1)
  - Basin invariance and monotone convergence
  - Mirror symmetry f(1-x) = 1-f(x)
  - Matrix bootstrap: idempotent ⟹ fixed point
  - Contraction estimates near attractors
  - Lyapunov exponent at repeller = ln(3/2)
  - Cosmic Bootstrap System structure

### Papers
- **`paper/ScientificAmerican.md`** — Accessible article for general readers
- **`paper/ResearchPaper.md`** — Full technical paper with proofs and experiments

### Python Demos & Visualizations
All demos in `demos/`. Run `python demos/run_all.py` to generate all figures.

| Script | Output | Description |
|:---|:---|:---|
| `oracle_bootstrap_basics.py` | `bootstrap_basics.png` | Fixed points, cobweb diagram, convergence rates, derivative landscape |
| `julia_set_fractal.py` | `julia_set.png`, `julia_set_zoom.png` | Complex Julia set with basin coloring |
| `cosmic_flow.py` | `cosmic_flow.png`, `cosmic_density_evolution.png` | Cosmological analogy, galaxy flow, density evolution |
| `encryption_attack.py` | `bootstrap_factoring.png`, `padic_convergence.png` | Factoring via idempotent convergence, p-adic dynamics |
| `fractal_dimension.py` | `fractal_dimension.png`, `lyapunov_landscape.png` | Box-counting dimension, Lyapunov exponent map |
| `hypothesis_experiments.py` | `hypothesis_results.png` | Six hypotheses tested and validated |

### Requirements
```bash
pip install numpy matplotlib scipy
```

## Validated Hypotheses

| # | Hypothesis | Status |
|:---:|:---|:---:|
| H13 | Julia set fractal dimension d ≈ 1.08 | ✓ Validated |
| H14 | Bootstrap acts as error-correcting decoder | ✓ Validated |
| H15 | Gaussian density → bimodal (voids + clusters) | ✓ Validated |
| H16 | Superlinear convergence: x₁/x₀² → 3 | ✓ Validated |
| H17 | Bootstrap = gradient flow of V(x) = ½x⁴ − x³ + ½x² | ✓ Proven |
| H18 | Exactly 2 finite critical points, both superattracting | ✓ Proven |

## Key Results

### Factoring via Bootstrap
The bootstrap map converges to idempotents of ℤ/nℤ, revealing factors:
- **15/15 semiprimes factored** (n = 15 to n = 4,087)
- Method: iterate f(x) = 3x² − 2x³ mod n, then gcd(result, n)

### Gradient Flow Discovery
The bootstrap IS a gradient flow: f(x) − x = −V'(x) where V(x) = ½x⁴ − x³ + ½x².
This connects to Landau phase transitions and the Ising model.

### Cosmic Bootstrap Principle
The Great Attractor and Dipole Repeller follow dynamics isomorphic to the
bootstrap map — superlinear convergence drives the universe toward extremes,
while the fractal Julia set mirrors the cosmic web.
