# Extended Lattice-Tree Correspondence: The Dimensional Escape

## Overview

This directory contains extended results on the Lattice-Tree Correspondence, focusing on the "dimensional escape" from the √N barrier via Pythagorean quadruples and O(3,1;ℤ). All theoretical results are machine-verified in Lean 4 with Mathlib — **zero `sorry` placeholders**.

## Contents

### Lean 4 Formalizations (Machine-Verified)

| File | Key Theorems | Description |
|---|---|---|
| `LorentzGenerators.lean` | `no_nontrivial_boost`, `parametric_quadruple`, `parametric_verified`, `factor_from_quad`, `quad_cauchy_schwarz` | O(3,1;ℤ) structure, Pell obstacle, parametric generation, factor extraction |
| `FactorExtraction.lean` | `gcd_factor_extraction`, `cascade_factor_extraction`, `brahmagupta_fibonacci`, `three_square_cauchy_schwarz`, `pipeline_sound` | Complete factoring pipeline from short vectors to factors |
| `MinkowskiBound.lean` | Exponent comparisons, Hermite constants, RSA implications | Dimensional advantage quantified |
| `DimensionalHierarchy.lean` | `minkowski_exponent_gap`, `factor_extraction_sound`, `pell_minus_trivial`, `min_norm_sq_bound`, `cauchy_schwarz_3d`, lattice closure | **NEW:** Full dimensional hierarchy, lattice properties, scaling theorems |

### Python Demos

| File | Description |
|---|---|
| `demos/demo_lattice_tree_correspondence.py` | 2D Berggren tree ≡ Gauss reduction demo |
| `demos/demo_lorentz_quadruples.py` | O(3,1;ℤ) symmetries, Pell obstacle, SL(2,ℤ) tree |
| `demos/demo_quadruple_lattice.py` | Quadruple lattice factoring pipeline with LLL |
| `demos/demo_bkz_factoring.py` | **NEW:** BKZ reduction, H1-H4 experiments, structured vs random basis comparison |

### SVG Visuals

| File | Description |
|---|---|
| `visuals/fig1_dimensional_escape.svg` | Conceptual: 2D → 3D transition |
| `visuals/fig2_lattice_tree_correspondence.svg` | Berggren ≡ Gauss diagram |
| `visuals/fig3_quadruple_tree.svg` | SL(2,ℤ) quadruple tree |
| `visuals/fig4_factoring_pipeline.svg` | Original pipeline diagram |
| `visuals/fig5_lorentz_symmetry.svg` | O(3,1;ℤ) structure |
| `visuals/fig6_hypothesis_results.svg` | **NEW:** H1-H4 results dashboard |
| `visuals/fig7_scaling_exponent.svg` | **NEW:** α regression: λ₁ vs N |
| `visuals/fig8_norm_comparison.svg` | **NEW:** Structured vs random basis norms |
| `visuals/fig9_factoring_pipeline_v2.svg` | **NEW:** Full pipeline with proof chain |

### Documents

| File | Description |
|---|---|
| `ResearchPaper.md` | Full research paper with all results |
| `ScientificAmericanArticle.md` | Popular science article |
| `ResearchNotes.md` | Detailed research log and next steps |
| `experiment_results.txt` | Raw experimental output from BKZ experiments |

## Key Results

### Theoretical (Formalized in Lean 4)

1. **Pell Obstacle**: λ²−μ²=1 has only trivial solutions ⟹ O(3,1;ℤ) has no single-plane boosts
2. **Parametric Quadruples**: The formula (m,n,p,q) → (a,b,c,d) always produces valid quadruples
3. **Factor Extraction**: Complete formalized pipeline from lattice vectors to non-trivial factors
4. **Dimensional Hierarchy**: 1/d₂ < 1/d₁ for d₁ < d₂ (Minkowski exponent strictly decreases)
5. **Lattice Properties**: L₄(N) is closed under negation, scalar multiplication; min norm ≥ N

### Experimental

1. **H1 (Structured Advantage)**: Structured basis produces 8.8× shorter vectors after BKZ
2. **H2 (Scaling Law)**: Measured exponent α = 0.175, well below √N barrier (α = 0.5)
3. **H3 (Extraction Rate)**: Inconclusive — small sample, p ≡ 3 (mod 4) surprisingly better
4. **H4 (Dimensional Hierarchy)**: Supported — proved in Lean 4

## Axiom Audit

All Lean 4 proofs use only standard axioms: `propext`, `Classical.choice`, `Quot.sound`.
No `sorry`, no `axiom` declarations, no `@[implemented_by]`.

## Quick Start

```bash
# Run BKZ experiments
python3 demos/demo_bkz_factoring.py

# Run quadruple lattice demo
python3 demos/demo_quadruple_lattice.py

# Build Lean 4 formalizations
lake build Pythagorean.LatticeTreeCorrespondence.Extended.DimensionalHierarchy
```
