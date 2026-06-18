# Summary of changes for run 972f2b3e-e8ec-4ccb-befe-6f3dc07d571a
Produced a new, self-contained Lean 4 research file plus a FUTURE_DIRECTIONS.md for the theme "Mod-p Monodromy Rigidity for Apéry-Type Picard–Fuchs Operators."

**New file: `Catalog/Novelty/PCurvatureRigidity.lean`** — the algebraic backbone of p-curvature for rank-one Picard–Fuchs operators, built from first principles over an arbitrary commutative ring `A` of characteristic `p` with a derivation `D` (the mod-p `d/dz`). All theorems are fully proved (sorry = 0) and verified to use only the standard axioms `propext, Classical.choice, Quot.sound`:

- `iterate_leibniz` — the higher-order Leibniz rule `Dⁿ(xy) = Σ_k C(n,k)·Dᵏx·Dⁿ⁻ᵏy`.
- `hochschild_prime` — Hochschild's theorem: in characteristic `p`, `Dᵖ` is again a derivation (the structural reason p-curvature is an `A`-linear scalar invariant).
- `pCurvature_two`, `pCurvature_three` — explicit Jacobson formulas at `p = 2, 3`: `∇ᵖ = Dᵖ + ψ_p(a)·` with the p-curvature scalar `ψ_p(a) = aᵖ + Dᵖ⁻¹(a)`.
- `pCurv_two_dichotomy`, `pCurv_three_dichotomy` — the rigidity dichotomy: the p-curvature operator `∇ᵖ − Dᵖ` vanishes iff the scalar `ψ_p(a) = 0` (an Artin–Schreier equation).
- `pCurvature_zero_derivation`, `pCurv_const_zmod_eq_self` — the constant-coefficient case degenerates to the Frobenius `a ↦ aᵖ`, which over `ZMod p` is the identity by Fermat's little theorem.

**Catalog synthesis:** `pCurv_const_zmod_eq_self` is a cross-domain bridge — it reduces the degenerate p-curvature to the same Frobenius-is-identity mechanism (`ZMod.pow_card`) that powers the Korselt → Carmichael result in `Catalog/Novelty/KorseltCarmichael.lean`, linking arithmetic differential algebra to Fermat-pseudoprime number theory.

The file contains the required `-- !-- ... -- !--` proof-sketch blocks and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis). A notable recorded failure: the naive closed form `∇ⁿY = Σ C(n,k)·Dᵏ(aⁿ⁻ᵏY)` is false (cross-term coefficients are not binomial, already at n=2), so the general-p Jacobson formula needs an operator-ring Lie argument and is carried forward as a conjecture.

**`FUTURE_DIRECTIONS.md`** — narrative synthesis, results table, and five falsifiable research directions (general-p Jacobson via the char-p operator ring; the density dichotomy as an arithmetic discriminator with the two calibrated endpoints already proved; Apéry-number Lucas/supercongruences; rank-one Cartier descent as Artin–Schreier solvability; and rank-2+ p-curvature matrices), each with an explicit "The key insight is…" and "Why now?" justification.