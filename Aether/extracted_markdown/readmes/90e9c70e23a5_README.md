# CCA — Cognitive Control Architecture: Formal Research Project

A mathematical formalization, computational simulation, and research documentation of the
**Cognitive Control Architecture (CCA)** developed by Tobin Townsend through Astraeus Cognitive.

## Overview

This project formalizes the CCA framework — a technical description of how intelligent systems
(biological and artificial) process information, form beliefs, and resist or accept corrective
feedback. The work includes:

- **Formal Lean 4 proofs** of core structural properties
- **Python simulations** with visualizations of CCA dynamics
- **Research papers** documenting the mathematical framework and experimental reproduction
- **Research notes** documenting the team process

## Directory Structure

```
CCA/
├── CCAFoundations.lean          # Lean 4 formal proofs (11 theorems, all sorry-free)
├── README.md                    # This file
├── python/
│   ├── cca_core_simulation.py   # Core dynamics: state, gate, comparator, meta-agent
│   ├── capture_intervention_demo.py  # Four-phase experiment reproduction
│   ├── isomorphic_scaling_demo.py    # Cross-scale dynamics demonstration
│   └── outputs/                 # Generated visualizations (PNG)
│       ├── demo1_state_upstream.png
│       ├── demo2_salience_gate.png
│       ├── demo3_comparator.png
│       ├── demo4_primitives_radar.png
│       ├── demo5_meta_agent.png
│       ├── experiment_main.png
│       ├── experiment_phases.png
│       ├── experiment_intervention_detail.png
│       ├── attractor_basins.png
│       ├── isomorphic_scaling.png
│       ├── cross_scale_correlation.png
│       └── capture_contagion.png
├── papers/
│   ├── research_paper.md        # Full research paper
│   └── scientific_american_article.md  # Popular science article
├── notes/
│   └── research_log.md          # Team research log
└── lean/                        # (archived, see CCAFoundations.lean)
```

## Formal Proofs (Lean 4)

All 11 theorems in `CCAFoundations.lean` are fully proven (no `sorry`):

| Theorem | Description |
|---------|-------------|
| `clamp01_mem_Icc` | Unit clamping preserves [0,1] membership |
| `clamp01_nonneg` | Clamped values are non-negative |
| `clamp01_le_one` | Clamped values are at most 1 |
| `clamp01_of_mem` | Clamping is identity on [0,1] |
| `gateThreshold_antitone_state` | **State Primacy**: gate threshold decreases with higher state |
| `effectiveDelta_small_under_capture` | **Capture Distortion**: delta collapses under full capture |
| `effectiveDelta_mono_state` | Delta is monotone increasing in state level |
| `capture_nondecreasing_under_confirmation` | Capture depth never decreases without corrective signals |
| `fixedPointContradiction` | **Intervention Theorem**: self-examination refusal contradicts sovereignty |
| `intervention_forces_choice` | System must accept self-application or drop sovereignty claim |
| `metaAgent_recovery_condition` | Recovery threshold: meta-agent strength > ε_c / μ_m |
| `capture_scale_invariant` | **Isomorphic Scaling**: capture dynamics are scale-independent |

## Python Simulations

Run all demos:

```bash
python CCA/python/cca_core_simulation.py
python CCA/python/capture_intervention_demo.py
python CCA/python/isomorphic_scaling_demo.py
```

### Key Results

- **State Primacy**: Regulated agent (state=0.85) → capture=0.020, avg delta=0.396.
  Dysregulated agent (state=0.20) → capture=1.000, avg delta=0.002.
  Same inputs, opposite outcomes.

- **Capture-Intervention Experiment**: Reproduces all four phases (capture, intervention,
  regression, immune response). Intervention produces genuine corrective deltas that
  subsequently fail to consolidate.

- **Isomorphic Scaling**: Same dynamics at individual, team, and organization levels.
  Cross-scale correlation > 0.95 for stressed organizations.

## Based On

Townsend, T. (2026). *Context, Capture, and Corrective Delta: A Research Overview.*
Astraeus Cognitive.
