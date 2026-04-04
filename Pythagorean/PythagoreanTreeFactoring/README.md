# Pythagorean Tree Factoring: Complete Research Package

## The Key Insight

**The Lattice-Tree Correspondence Theorem**: Berggren tree descent is mathematically identical to Gauss's 2D lattice reduction. This proves Pythagorean tree factoring is Θ(√N) for balanced semiprimes — and identifies the 3D quadruple lattice as the escape route.

## Contents

### 📁 OracleCouncil/
- **ResearchNotes.md** — Complete research log from the Oracle Council: hypotheses, experiments, validations, analysis, and iteration history

### 📁 Demos/
- **berggren_tree_factoring.py** — Interactive demo of Pythagorean tree factoring with complexity benchmarks
- **lattice_gauss_equivalence.py** — Step-by-step proof that Berggren descent = Gauss reduction = continued fractions
- **quadruple_lattice_explorer.py** — Explores the 3D quadruple lattice L₄(N) with LLL reduction and factor extraction

### 📁 Visuals/
- **berggren_tree_visual.py** — Generates 5 SVG visualizations:
  - `berggren_tree.svg` — The Berggren ternary tree
  - `lattice_tree_correspondence.svg` — The equivalence diagram
  - `complexity_scaling.svg` — Θ(√N) scaling comparison
  - `dimensional_escape.svg` — 2D→3D escape analysis
  - `research_program.svg` — Research roadmap flowchart

### 📁 Papers/
- **research_paper.md** — Full research paper with theorems, proofs, and future directions
- **scientific_american_article.md** — Popular science article: "The Ancient Triangle That Almost Broke Modern Cryptography"

### 📁 Lean/
- **LatticeTreeDuality.lean** — Machine-verified Lean 4 proofs (30+ theorems, zero sorry)

## Formally Verified Theorems (Lean 4)

All proofs use only standard axioms (propext, Classical.choice, Quot.sound):

| # | Theorem | Section |
|---|---------|---------|
| 1 | `berggrenM₁_det_one` — M₁ ∈ SL(2,ℤ) | §1 |
| 2 | `berggrenM₃_det_one` — M₃ ∈ SL(2,ℤ) | §1 |
| 3 | `berggrenM₁_right_inv` — M₁ · M₁⁻¹ = I | §1 |
| 4 | `berggrenM₃_right_inv` — M₃ · M₃⁻¹ = I | §1 |
| 5 | `berggrenM₁_left_inv` — M₁⁻¹ · M₁ = I | §1 |
| 6 | `berggrenM₃_left_inv` — M₃⁻¹ · M₃ = I | §1 |
| 7 | `M₃_inv_subtraction` — CF subtraction step | §2 |
| 8 | `M₁_inv_swap` — CF swap step | §2 |
| 9 | `M₃_inv_preserves_n` — n unchanged by M₃⁻¹ | §2 |
| 10 | `M₃_inv_reduces_norm` — Norm decreases under M₃⁻¹ | §3 |
| 11 | `parallelogram_law'` — Parallelogram identity | §3 |
| 12 | `sqrt_N_barrier` — p² ≤ N for balanced semiprimes | §4 |
| 13 | `trial_tree_equivalence` — Trial division = tree descent | §4 |
| 14 | `euclid_diff_squares` — m²−n² = (m−n)(m+n) | §5 |
| 15 | `complementary_divisors` — Factor pair from Euclid params | §5 |
| 16 | `factor_pair_from_params` — Divisibility from factorization | §5 |
| 17 | `lll_approx_factor_ge_2` — LLL factor ≥ 2 in dim ≥ 3 | §6 |
| 18 | `dim_advantage_exponential` — 2^d ≥ 8 for d ≥ 3 | §6 |
| 19 | `approximation_gap` — 2D vs 3D approximation gap | §6 |
| 20 | `zero_in_quad_lat` — 0 ∈ L₄(N) | §7 |
| 21 | `scalar_quad_lat` — L₄(N) closed under scaling | §7 |
| 22 | `factor_from_three_squares` — Factor extraction theorem | §7 |
| 23 | `prime_dvd_of_dvd_sq'` — Prime divides z if divides z² | §7 |
| 24 | `lattice_tree_subtraction` — Full correspondence (subtract) | §8 |
| 25 | `lattice_tree_swap` — Full correspondence (swap) | §8 |
| 26 | `descent_bound_balanced` — Combined descent bound | §8 |
| 27 | `pyth_iff_lorentz_null` — Lorentz form characterization | §9 |
| 28 | `euclid_is_null` — Euclid param → null vector | §9 |
| 29 | `M₃_inv_compose` — Double M₃⁻¹ composition | §10 |
| 30 | `M₃_then_M₁_inv` — M₃⁻¹ then M₁⁻¹ composition | §10 |
| 31 | `factor_cong_iff` — Factor congruence characterization | §11 |
| 32 | `lattice_tree_correspondence_summary` — Main theorem summary | §12 |

## Running the Demos

```bash
# Factor a number using Pythagorean tree descent
python3 Demos/berggren_tree_factoring.py 143

# See the step-by-step Berggren = Gauss equivalence
python3 Demos/lattice_gauss_equivalence.py

# Explore the 3D quadruple lattice
python3 Demos/quadruple_lattice_explorer.py

# Generate SVG visualizations
python3 Visuals/berggren_tree_visual.py
```
