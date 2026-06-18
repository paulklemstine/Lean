# Extended Lattice-Tree Correspondence: The Dimensional Escape

## Overview

This directory contains extended results on the Lattice-Tree Correspondence, focusing on the "dimensional escape" from the √N barrier via Pythagorean quadruples and O(3,1;ℤ).

## Contents

### Lean 4 Formalizations (Machine-Verified)

| File | Key Theorems | Description |
|---|---|---|
| `LorentzGenerators.lean` | `no_nontrivial_boost`, `parametric_quadruple`, `parametric_verified`, `factor_from_quad`, `quad_cauchy_schwarz` | O(3,1;ℤ) structure, Pell obstacle, parametric generation, factor extraction |
| `FactorExtraction.lean` | `gcd_factor_extraction`, `cascade_factor_extraction`, `brahmagupta_fibonacci`, `three_square_cauchy_schwarz`, `pipeline_sound` | Complete factoring pipeline from short vectors to factors |
| `MinkowskiBound.lean` | Exponent comparisons, Hermite constants, RSA implications | Dimensional advantage quantified |

**All files compile with zero `sorry`. All proofs depend only on standard axioms (propext, Classical.choice, Quot.sound).**

### Python Demos

| File | Description |
|---|---|
| `demos/demo_quadruple_lattice.py` | Quadruple lattice construction, factor extraction, balanced semiprime experiments |
| `demos/demo_lattice_tree_correspondence.py` | Berggren descent = Gauss reduction = Euclidean algorithm |
| `demos/demo_lorentz_quadruples.py` | O(3,1;ℤ) structure, Pell obstacle verification, SL(2,ℤ) tree generation |

### SVG Visuals

| File | Description |
|---|---|
| `visuals/fig1_dimensional_escape.svg` | Complexity curves: N^{1/2} vs N^{1/3} vs N^{1/4} |
| `visuals/fig2_lattice_tree_correspondence.svg` | The triple identity: tree = lattice = Euclidean algorithm |
| `visuals/fig3_quadruple_tree.svg` | Pythagorean quadruple tree via SL(2,ℤ) |
| `visuals/fig4_factoring_pipeline.svg` | The complete factoring pipeline |
| `visuals/fig5_lorentz_symmetry.svg` | Einstein meets Euclid: O(3,1) in physics and number theory |

### Papers

| File | Description |
|---|---|
| `ResearchPaper.md` | Extended research paper with all new results |
| `ScientificAmericanArticle.md` | Popular science article for general audience |
| `ResearchNotes.md` | Detailed research log with hypotheses, experiments, and findings |

## Key Results

1. **The Pell Obstacle** (Theorem `no_nontrivial_boost`): O(3,1;ℤ) has no single-plane integer boosts. The equation λ²−μ²=1 forces μ=0.

2. **Parametric Quadruple Generation** (Theorem `parametric_verified`): The formula (m²+n²−p²−q², 2(mq+np), 2(nq−mp), m²+n²+p²+q²) always produces valid quadruples.

3. **Factor Extraction Pipeline** (Theorems `factor_from_quad` → `prime_dvd_sq` → `pipeline_sound`): Complete verified chain from lattice vectors to factors.

4. **Experimental Validation**: 53.8% factoring success rate on balanced semiprimes via naive enumeration (without BKZ).

## Running

```bash
# Python demos
python3 demos/demo_quadruple_lattice.py
python3 demos/demo_lattice_tree_correspondence.py
python3 demos/demo_lorentz_quadruples.py

# Lean verification
lake build Pythagorean.LatticeTreeCorrespondence.Extended.LorentzGenerators
lake build Pythagorean.LatticeTreeCorrespondence.Extended.FactorExtraction
lake build Pythagorean.LatticeTreeCorrespondence.Extended.MinkowskiBound
```
