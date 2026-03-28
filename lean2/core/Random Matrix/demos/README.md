# Eigenvalue Repulsion: Demo Python Scripts

## Overview

Eight interactive Python visualization scripts demonstrating the key phenomena of eigenvalue repulsion in random matrix theory. Each script produces a high-resolution PNG figure.

## Requirements

```bash
pip install numpy matplotlib scipy
```

## Demo Scripts

| # | Script | Output | Description |
|---|--------|--------|-------------|
| 1 | `demo1_eigenvalue_repulsion.py` | `eigenvalue_repulsion.png` | **Nearest-neighbor spacing distributions** for GOE (β=1), GUE (β=2), GSE (β=4), and Poisson (independent). Shows how repulsion manifests as P(s→0) → 0, compared against Wigner surmise. |
| 2 | `demo2_coulomb_gas.py` | `coulomb_gas.png` | **Langevin dynamics simulation** of the eigenvalue Coulomb gas. Particle trajectories, equilibrium convergence to the Wigner semicircle, energy convergence, and force diagrams for all three β values. |
| 3 | `demo3_vandermonde_geometry.py` | `vandermonde_geometry.png` | **The Vandermonde determinant** as the geometric engine of repulsion. 2D/3D joint densities, contour plots showing the forbidden diagonal, level crossing avoidance, and the Oracle's verdict. |
| 4 | `demo4_number_theory_connection.py` | `number_theory_connection.png` | **Montgomery-Odlyzko law**: the first 100 Riemann zeta zeros compared against GUE predictions. Pair correlation functions, number variance, and the web of connections to other fields. |
| 5 | `demo5_wigner_semicircle.py` | `wigner_semicircle.png` | **Wigner semicircle law**: convergence of the empirical eigenvalue density to ρ(x) = √(4−x²)/(2π) as N → ∞. Effective potential, Dyson Brownian motion, and the variational principle. |
| 6 | `demo6_quantum_chaos.py` | `quantum_chaos.png` | **BGS conjecture**: chaotic quantum systems → GOE statistics (repulsion), integrable systems → Poisson statistics (clustering). Level diagrams and spacing ratio diagnostics. |
| 7 | `demo7_tracy_widom.py` | `tracy_widom.png` | **Tracy-Widom distribution**: universal fluctuations of the largest eigenvalue. Convergence with N, comparison to Gaussian, log-scale tail analysis, and applications. |
| 8 | `demo8_master_visualization.py` | `master_visualization.png` | **The complete story** in one 16-panel "poster figure". From random matrix → diagonalization → Vandermonde → Coulomb gas → semicircle → connections → Oracle. |

## Running All Demos

```bash
cd demos/
for f in demo*.py; do python "$f"; done
```

| 9 | `demo9_full_story.py` | `full_story.png`, `eigenvalue_dynamics.png`, `web_of_connections.png` | **The complete narrative** in three figures: a 9-panel logical chain from random matrix to Coulomb gas, Dyson Brownian motion trajectories showing eigenvalues that never cross, and a web-of-connections diagram linking RMT to number theory, quantum chaos, free probability, integrable systems, and more. |

## Running All Demos

```bash
cd demos/
for f in demo*.py; do python "$f"; done
```

## Key Visual Signatures of Repulsion

1. **P(s→0) → 0**: Spacing distributions vanish at zero (eigenvalues cannot coincide)
2. **Wigner semicircle**: Equilibrium density of the Coulomb gas
3. **Level crossing avoidance**: Eigenvalues repel as parameters vary
4. **Correlation hole**: Pair correlation R₂(r) → 0 as r → 0
5. **Log-scale number variance**: Σ²(L) ~ log L ≪ L (extreme rigidity)
