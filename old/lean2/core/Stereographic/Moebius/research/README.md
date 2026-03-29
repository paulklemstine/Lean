# Integer-Pole Stereographic Projections: Research Package

## Overview

This research package explores a novel parameterization of stereographic projections
by pairs of integers $(n, m)$, where the North Pole maps to $n$ and the South Pole
maps to $m$. The central discovery is that **transition maps between any two such
charts are always affine** (scaling + translation), despite each chart being a full
Möbius transformation.

## Contents

### Research Papers

| File | Description |
|------|-------------|
| [`research_paper.md`](research_paper.md) | Full technical research paper with proofs |
| [`scientific_american.md`](scientific_american.md) | Popular science article for general audience |
| [`applications_and_hypotheses.md`](applications_and_hypotheses.md) | Proposed applications, new hypotheses, and experimental results |

### Python Demos (in `../demos/`)

| File | Output | Description |
|------|--------|-------------|
| [`demo_stereographic.py`](../demos/demo_stereographic.py) | `stereographic_projection.png`, `conformal_property.png` | Classical stereographic projection and pole swap |
| [`demo_integer_poles.py`](../demos/demo_integer_poles.py) | `integer_poles.png`, `transition_maps.png`, `crystallization.png` | Integer-pole charts, transitions, crystal lattices |
| [`demo_problem_mapping.py`](../demos/demo_problem_mapping.py) | `problem_universes.png`, `dual_universes.png`, `factorization_lens.png` | Problem universe mapping and dual universes |
| [`demo_3d_sphere.py`](../demos/demo_3d_sphere.py) | `sphere_3d.png` | 3D visualization on the sphere |
| [`demo_applications.py`](../demos/demo_applications.py) | `applications.png` | Application visualizations |

### Lean 4 Formalization (in `../core/Stereographic/`)

| File | Theorems | Description |
|------|----------|-------------|
| [`IntegerPoleCharts.lean`](../core/Stereographic/IntegerPoleCharts.lean) | 18 (all proved) | Core definitions and theorems about integer-pole charts |

### Key Formally Verified Theorems

1. **`intPoleChart_south`**: $T_{n,m}(0) = m$ (South Pole maps to $m$)
2. **`intPoleChart_equator`**: $T_{n,m}(1) = (n+m)/2$ (equator maps to arithmetic mean)
3. **`intPoleChart_inv_left`**: $T_{n,m}^{-1} \circ T_{n,m} = \text{id}$
4. **`intPoleChart_inv_right`**: $T_{n,m} \circ T_{n,m}^{-1} = \text{id}$
5. **`transition_is_affine`**: Transition maps are affine (main theorem)
6. **`dual_is_reflection`**: Dual chart transition is reflection
7. **`self_dual_point`**: Midpoint is the unique self-dual point
8. **`pole_swap_involution`**: Classical pole swap $t \to 1/t$ is an involution
9. **`effectiveDenom_pos`**: Gaussian integer denominator is positive

## Running the Demos

```bash
pip install matplotlib numpy
cd demos/
python3 demo_stereographic.py       # Basic projection & pole swap
python3 demo_integer_poles.py       # Integer-pole charts
python3 demo_problem_mapping.py     # Problem universe mapping
python3 demo_3d_sphere.py           # 3D sphere visualization
python3 demo_applications.py        # Application demos
```

## Building the Lean Proofs

```bash
cd core/
lake build Stereographic.IntegerPoleCharts
```

## Key Insight

> **The same mathematical object (a point on the sphere) looks fundamentally different
> depending on which integers you assign to the poles.** By choosing poles wisely, one
> can align the coordinate structure with the arithmetic structure of a problem,
> potentially transforming difficult questions into easy ones.

## Citation

```
@article{aristotle2025integerpole,
  title={Integer-Pole Stereographic Projections and Problem Universe Duality},
  author={Aristotle (Harmonic)},
  year={2025},
  note={Formally verified in Lean 4 with Mathlib}
}
```
