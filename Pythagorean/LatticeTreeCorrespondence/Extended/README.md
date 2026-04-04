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
| `DimensionalHierarchy.lean` | `minkowski_exponent_gap`, `factor_extraction_sound`, `pell_minus_trivial`, `min_norm_sq_bound`, `cauchy_schwarz_3d`, lattice closure | Full dimensional hierarchy, lattice properties, scaling theorems |
| `ExtendedResults.lean` | `enhanced_extraction_add/sub`, `euler_four_square`, `coppersmith_embedding`, `gram_entry_relation`, `mod4_product_*` | **NEW v2:** H5–H12 investigation, quaternion identity, Coppersmith connection, prime residue structure |

### Python Demos

| File | Description |
|---|---|
| `demos/demo_lattice_tree_correspondence.py` | 2D Berggren tree ≡ Gauss reduction demo |
| `demos/demo_lorentz_quadruples.py` | O(3,1;ℤ) symmetries, Pell obstacle, SL(2,ℤ) tree |
| `demos/demo_quadruple_lattice.py` | Quadruple lattice factoring pipeline with LLL |
| `demos/demo_bkz_factoring.py` | BKZ reduction, H1-H4 experiments, structured vs random basis |
| `demos/demo_h5_h8_experiments.py` | **NEW:** H5-H8 experiments with enhanced extraction, scaling analysis, optimal dimension, Coppersmith |
| `demos/demo_applications.py` | **NEW:** 6 practical applications (RSA, 3-squares, quaternions, lattice codes, signals, ZK proofs) |
| `demos/demo_visualization.py` | **NEW:** Publication-quality data tables and formatted summaries |

### SVG Visuals

| File | Description |
|---|---|
| `visuals/fig1_dimensional_escape.svg` | Conceptual: 2D → 3D transition |
| `visuals/fig2_lattice_tree_correspondence.svg` | Berggren ≡ Gauss diagram |
| `visuals/fig3_quadruple_tree.svg` | SL(2,ℤ) quadruple tree |
| `visuals/fig4_factoring_pipeline.svg` | Original pipeline diagram |
| `visuals/fig5_lorentz_symmetry.svg` | O(3,1;ℤ) structure |
| `visuals/fig6_hypothesis_results.svg` | H1-H4 results dashboard |
| `visuals/fig7_scaling_exponent.svg` | α regression: λ₁ vs N |
| `visuals/fig8_norm_comparison.svg` | Structured vs random basis norms |
| `visuals/fig9_factoring_pipeline_v2.svg` | Full pipeline with proof chain |
| `visuals/fig10_h5_extraction_comparison.svg` | **NEW:** Basic vs enhanced extraction rates |
| `visuals/fig11_scaling_persistence.svg` | **NEW:** H6 exponent α by bit size with confidence bands |
| `visuals/fig12_optimal_dimension.svg` | **NEW:** H7 success rate and λ₁ by dimension |
| `visuals/fig13_applications_overview.svg` | **NEW:** Six applications hub diagram |
| `visuals/fig14_full_pipeline.svg` | **NEW:** Complete pipeline with all Lean proof nodes |

### Documents

| File | Description |
|---|---|
| `ResearchPaper.md` | Original research paper (H1–H4) |
| `ResearchPaper_v2.md` | **NEW:** Extended paper with H5–H12 and applications |
| `ScientificAmericanArticle.md` | Original popular science article |
| `ScientificAmericanArticle_v2.md` | **NEW:** Updated article with all new findings |
| `ResearchNotes.md` | Detailed research log and next steps |
| `experiment_results.txt` | Raw experimental output from H1–H4 |

## Key Results

### Theoretical (Formalized in Lean 4, 35+ theorems)

1. **Pell Obstacle**: λ²−μ²=1 has only trivial solutions ⟹ O(3,1;ℤ) has no single-plane boosts
2. **Parametric Quadruples**: The formula (m,n,p,q) → (a,b,c,d) always produces valid quadruples
3. **Factor Extraction**: Complete formalized pipeline from lattice vectors to non-trivial factors
4. **Dimensional Hierarchy**: 1/d₂ < 1/d₁ for d₁ < d₂ (Minkowski exponent strictly decreases)
5. **Lattice Properties**: L₄(N) is closed under negation, scalar multiplication; min norm ≥ N
6. **NEW: Enhanced Extraction Closure**: Linear combos of L₄(N) vectors stay in L₄(N) under cross-term divisibility
7. **NEW: Euler Four-Square Identity**: Quaternion norm multiplicativity (ring proof)
8. **NEW: Coppersmith Embedding**: 2D sum-of-squares solutions embed into L₄(N)
9. **NEW: Gram Matrix Divisibility**: Gram entries encode N-divisibility information
10. **NEW: Prime Residue Algebra**: Mod 4 product rules for semiprime classification

### Experimental (H1–H12)

| Hypothesis | Status | Key Finding |
|-----------|--------|-------------|
| H1 (Structured Advantage) | PARTIAL | 8.8× shorter vectors |
| H2 (Scaling Law) | SUPPORTED | α = 0.175 < 0.5 |
| H3 (Extraction Rate) | INCONCLUSIVE | Small sample |
| H4 (Dimensional Hierarchy) | SUPPORTED | Proved in Lean 4 |
| **H5 (Enhanced Extraction)** | **PARTIAL** | **+80% relative improvement** |
| **H6 (Scaling Persistence)** | **SUPPORTED** | **α = 0.297 < 0.3** |
| **H7 (Optimal Dimension)** | **EXPLORATORY** | **d*=4 at 88% success** |
| **H8 (Coppersmith)** | **NOT SUPPORTED** | **Needs refinement** |
| H9-H12 | PROPOSED | Theorems formalized |

### Applications Identified

1. RSA key strength estimation under lattice attacks
2. Three-square decomposition (Legendre's theorem)
3. Quaternion factorization and rotation composition
4. Lattice codes for AWGN communication channels
5. Integer signal decomposition
6. Post-quantum zero-knowledge proofs

## Axiom Audit

All Lean 4 proofs use only standard axioms: `propext`, `Classical.choice`, `Quot.sound`.
No `sorry`, no `axiom` declarations, no `@[implemented_by]`.

## Quick Start

```bash
# Run extended experiments (H5-H8)
python3 demos/demo_h5_h8_experiments.py

# Run application demos
python3 demos/demo_applications.py

# Run visualization/data tables
python3 demos/demo_visualization.py

# Run original BKZ experiments
python3 demos/demo_bkz_factoring.py

# Build all Lean 4 formalizations
lake build Pythagorean.LatticeTreeCorrespondence.Extended.ExtendedResults
lake build Pythagorean.LatticeTreeCorrespondence.Extended.DimensionalHierarchy
lake build Pythagorean.LatticeTreeCorrespondence.Extended.FactorExtraction
lake build Pythagorean.LatticeTreeCorrespondence.Extended.LorentzGenerators
lake build Pythagorean.LatticeTreeCorrespondence.Extended.MinkowskiBound
```
