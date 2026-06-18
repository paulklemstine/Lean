# Summary of changes for run 51e742aa-be35-4fda-8b81-7722b5c42a24
Built a new, self-contained Lean 4 theory of quasi-symmetric maps that generalizes bi-Lipschitz maps, delivered in `Catalog/Applications/QuasiSymmetric/`.

**`Maps.lean`** (compiles cleanly under Mathlib, 0 `sorry`, depends only on the standard axioms `propext`/`Classical.choice`/`Quot.sound`) introduces two definitions and five fully-proved theorems:

- `IsQuasisymmetric f η` — the gauge-controlled relative-distortion condition `dist (f x) (f a) ≤ η(dist x a / dist x b) * dist (f x) (f b)`.
- `IsBiLipschitzWith f L` — the classical two-sided absolute-distortion condition.
- `biLipschitz_isQuasisymmetric` — every `L`-bi-Lipschitz map is quasisymmetric with the linear gauge `η t = L²·t` (the precise containment bi-Lipschitz ⊂ quasisymmetric).
- `isQuasisymmetric_comp` — quasisymmetry is closed under composition, with gauges composing as `η_g ∘ η_f` (requires the inner map injective and the outer gauge monotone).
- `isQuasisymmetric_constant_or_injective` — the rigidity dichotomy: a quasisymmetric map is either constant or injective, with no partial collapse (the conceptual core result).
- `isQuasisymmetric_const` and `isQuasisymmetric_id` — both branches of the dichotomy are realized, so it is sharp.

Each theorem carries a one-to-two sentence proof sketch in a `!--` comment block, and the file's module docstring explains how the results connect to the existing `Applications` catalog domain (metric/geometry maps).

**`FUTURE_DIRECTIONS.md`** lists five falsifiable research conjectures extending the work (quantitative continuity from the gauge, the dual-gauge inverse law upgrading the category to a groupoid, sharpness of the `L²` exponent, a weak-quasisymmetry equivalence on doubling spaces, and Hausdorff-dimension distortion bounds), each with a "key insight" and a "Why now?" justification grounded in the theorems just proved.

All proofs were verified to compile with no remaining `sorry` and only standard axioms.