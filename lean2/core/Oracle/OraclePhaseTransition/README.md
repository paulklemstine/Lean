# Oracle Bootstrap Phase Transition: Formally Verified Mathematics of AI Compression

## Overview

This module contains **formally verified mathematics** and **experimental validation** of the Oracle Bootstrap Phase Transition — a sharp mathematical boundary that determines when neural network compression succeeds and when it fails catastrophically.

## Key Result

**Theorem (Phase Transition):** The generalized bootstrap map $f_T(r) = (2+T)r^2 - (1+T)r^3$ has a critical point at $r^* = 1/(1+T)$. Above this threshold, iterative compression-and-distillation drives quality toward perfection. Below it, quality collapses irreversibly to zero.

This is formally verified in Lean 4 with **zero `sorry` statements** (no unproven assumptions).

## Contents

### Formal Proofs (Lean 4)
- **`BootstrapDynamics.lean`** — All theorems, including:
  - Generalized bootstrap map fixed points and phase transition
  - Temperature-dependent critical point $r^* = 1/(1+T)$
  - Lyapunov stability analysis
  - Oracle composition algebra (commuting oracles compose)
  - Quadratic convergence bounds
  - Hermite interpolation characterization
  - Bootstrap iterates stay in $[0,1]$

### Papers
- **`ResearchPaper.md`** — Full technical paper with proofs, experiments, applications
- **`ScientificAmerican.md`** — Popular science article for general audience

### Python Demos (`demos/`)
- **`phase_transition_demo.py`** — Core visualizations (5 figures):
  - Bootstrap map and cobweb diagram
  - Temperature-dependent phase transitions
  - Compression simulation (pruning + quantization)
  - Basin of attraction and convergence rates
  - Hermite/smoothstep characterization
  
- **`hypothesis_experiments.py`** — Hypothesis testing (5 figures):
  - H1: Bootstrap = optimal smoothstep (Hermite)
  - H2: Spectral gap emergence under pruning
  - H3: Oracle composition order effects
  - H4: Layerwise compression sensitivity
  - H5: Percolation transition in weight graphs
  - H6: Entropy-compressibility duality

- **`compression_pipeline_demo.py`** — End-to-end compression demo (1 figure):
  - Simulated transformer layer compression
  - Oracle property verification
  - Compression quality table
  - Practical recommendations

## Running the Demos

```bash
# Install dependencies
pip install numpy matplotlib

# Generate all figures
cd demos/
python3 phase_transition_demo.py          # → 5 PNG figures
python3 hypothesis_experiments.py         # → 5 PNG figures
python3 compression_pipeline_demo.py      # → 1 PNG figure
```

## Building the Lean Proofs

```bash
# From project root
lake build core.Oracle.OraclePhaseTransition.BootstrapDynamics
```

## Practical Applications

1. **Compression Decision Rule:** Measure quality ratio after compression; if $r > 0.5$, safe to deploy
2. **Temperature Tuning:** Higher distillation temperature allows more aggressive compression
3. **Layer-Adaptive Compression:** Apply per-layer compression based on structure (attention vs FFN)
4. **Edge Deployment:** Rigorous guarantees for mobile/IoT deployment of compressed models
