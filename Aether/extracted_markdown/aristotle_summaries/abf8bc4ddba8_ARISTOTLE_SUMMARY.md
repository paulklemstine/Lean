# Summary of changes for run 05e3fd13-edd5-4a59-acdb-b1cc5a27cbe8
Researched the direction **"Functorial tropical automorphic height monotonicity on the Berggren tree"** and delivered verified Lean 4 results plus future conjectures.

## Deliverables

**1. Lean proofs — `Catalog/Bridges/BerggrenTropicalHeight.lean`** (self-contained, `import Mathlib`, 0 sorries, 27 theorems / 12 definitions). Verified to compile cleanly in the pinned Mathlib environment with only whitelisted axioms (`propext`, `Classical.choice`, `Quot.sound`, `Lean.ofReduceBool`, `Lean.trustCompiler`). Highlights:

- **Tropical height** `tropHeight (a,b,c) = max (max a b) c` (the max-plus valuation), proved to equal the hypotenuse on the positive light cone (`tropHeight_posPythag`), via hypotenuse dominance (`hyp_dominates`).
- **Uniform strict monotonicity (`step_height_lt`)**: *every* Berggren generator strictly increases the tropical height of *every* positive Pythagorean triple, with **no side condition** — generalizing the catalog's `BerggrenLorentz.hypA_strict_growth`/`hypC_strict_growth`, which required `b<a`/`a<b`. Backed by `step_posPythag` (the tree preserves the positive light cone).
- **Automorphic structure**: the three tree maps are exactly the `mulVec` actions of the generator matrices (`matA/B/C_action`), all lying in `O(2,1;ℤ)` (`matA/B/C_lorentz`) and preserving the light-cone form `Q` (`childA/B/C_Q`, `step_Q`).
- **Functoriality**: along any branch `f : ℕ → Fin 3` from a positive seed, the height is `StrictMono`/`Monotone`/injective (`height_strictMono`, `height_monotone`, `height_injective`), grows at least linearly (`height_linear_lower`), and at least geometrically with ratio 3 along the all-`B` branch (`stepB_triple`, `orbitB_exp_lower`).
- Worked examples at the classical seed `(3,4,5)`.

**2. Lab notes**: inline `-- !-- Lab Notes -- !--` blocks document the three hypotheses (H1 uniform growth, H2 automorphic action, H3 tropical additivity), the experiments confirming them, key insights (max-plus height is the structurally correct invariant; `omega` handles `max` over ℤ), and a failure analysis (the `rw [max_eq_right, max_eq_right]` collapse).

**3. `Catalog/Bridges/FUTURE_DIRECTIONS.md`**: five falsifiable conjectures — (C1) sharp two-sided bound and the spectral ratio `3+2√2`; (C2) boundary ultrametric bridging `CategoricalTropicalUltrametric`; (C3) height zeta / counting exponent `log3/log(3+2√2)`; (C4) height as a well-founded descent measure to the root; (C5) generalization to `O(d,1;ℤ)` cones and other ternary trees.

No prose articles, Python, HTML, or package files were produced, per the constraints.

Note: the file is self-contained rather than `import`-ing `Algebra/BerggrenLorentz/Core.lean`; the catalog's project-wide build is independently broken (a pre-existing missing `Algebra/Jacobian/Defs.lean` referenced by unrelated files), so a self-contained module is the reliable, individually-compilable artifact. Its definitions mirror the catalog's Berggren core, as noted in the file's docstring/lab notes.