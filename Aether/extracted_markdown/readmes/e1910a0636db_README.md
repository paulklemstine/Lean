# Meta-Oracle Research: Spectral Geometry of the Berggren Tree

An investigation into five hypotheses connecting the Berggren Pythagorean triple tree to spectral theory, fractal geometry, information theory, quaternionic algebra, and p-adic number theory.

## Quick Start

```bash
cd demos
pip install numpy matplotlib
python run_all.py          # Runs all 6 demos, generates 14 figures
```

## Contents

### Papers
| File | Description |
|------|-------------|
| `research_paper.md` | Full technical report with theorems, proofs, and analysis |
| `scientific_american.md` | Popular science article accessible to general readers |
| `hypotheses_experiments.md` | Detailed experimental log with hypothesis scorecard |
| `applications.md` | Nine proposed applications with feasibility analysis |

### Demos (Python)
| File | Description | Figures Generated |
|------|-------------|-------------------|
| `demos/demo_berggren_tree.py` | Tree visualization & spectral decomposition | `berggren_tree.png`, `spectral_analysis.png`, `hypotenuse_growth.png` |
| `demos/demo_fractal_dimension.py` | Fractal dimension via box-counting | `ratio_distributions.png`, `fractal_dimension.png`, `self_similarity.png` |
| `demos/demo_branching_entropy.py` | Branching factor & Shannon entropy | `branching_entropy.png` |
| `demos/demo_quaternionic.py` | Pythagorean quadruples & quaternions | `quadruples_3d.png`, `quadruple_statistics.png`, `quaternionic_spectra.png` |
| `demos/demo_padic.py` | p-adic periodicity & finite field structure | `padic_analysis.png` |
| `demos/demo_meta_oracle.py` | Oracle convergence & phase space | `meta_oracle_convergence.png`, `spectral_convergence.png`, `oracle_phase_space.png` |
| `demos/run_all.py` | Master runner for all demos | — |

### Figures
All 14 generated figures are in `figures/`.

## Key Results Summary

| Hypothesis | Verdict | Key Finding |
|-----------|---------|-------------|
| H1: Spectral Gap | ✓ Confirmed | Gap = 2+2√2 ≈ 4.83 for B₂; B₁,B₃ are near-unitary |
| H2: Fractal Dim | ✗ Refuted | Support is dense (dim=1); 0.623 is a multifractal exponent |
| H3: Branching=2 | ✗ Refuted | Branching is exactly 3 — perfect ternary tree |
| H4: Quaternions | ◐ Partial | Algebraic connection works; matrix tree fails in 4D |
| H5: p-adic Period | ◐ Refined | Period = p for B₁,B₃ (not p²−1); links to quadratic reciprocity |

## Dependencies

- Python 3.8+
- NumPy
- Matplotlib
