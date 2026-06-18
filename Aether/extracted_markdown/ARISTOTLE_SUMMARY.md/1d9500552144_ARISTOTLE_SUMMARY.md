# Summary of changes for run 51d68cbe-cf0a-4228-b80a-a657b069ae1a
Delivered the algebraic backbone of mod-`p` p-curvature for rank-one Picard–Fuchs operators.

## Lean deliverable
New file `Catalog/Novelty/PCurvatureRigidity.lean` (compiles cleanly, **0 sorries**, no linter warnings) with **8 fully-proved theorems**, all using only the standard axioms `propext, Classical.choice, Quot.sound`:

- `iterate_leibniz` — higher-order Leibniz rule `Dⁿ(xy) = Σ_k C(n,k)·Dᵏx·Dⁿ⁻ᵏy` (induction + Pascal).
- `hochschild_prime` — in characteristic `p`, the `p`-fold iterate `Dᵖ` is again a derivation (middle binomials `C(p,k)` vanish mod `p`). This is the structural reason p-curvature is a *scalar* operator.
- `pCurvature_two` / `pCurvature_three` — Jacobson's formula `∇ᵖ = Dᵖ + ψ_p(a)·` for `p = 2, 3`, with `ψ_2(a) = a²+Da`, `ψ_3(a) = a³+D²a`.
- `pCurv_two_dichotomy` / `pCurv_three_dichotomy` — the p-curvature operator `∇ᵖ − Dᵖ` vanishes on all sections **iff** the scalar `ψ_p(a) = 0` (an Artin–Schreier equation).
- `pCurvature_zero_derivation` — the trivial connection iterates to `aⁿ·`.
- `pCurv_const_zmod_eq_self` — cross-domain bridge: over `ZMod p` the constant-coefficient p-curvature degenerates to the Frobenius `a ↦ aᵖ = a`, reusing the exact `ZMod.pow_card` mechanism behind the catalog's `Korselt.fermatPsp_of_coprime` (`Catalog/Novelty/KorseltCarmichael.lean`).

The file includes the required `-- !--` proof-sketch blocks for each theorem and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

## Other deliverables
- `FUTURE_DIRECTIONS.md` — synthesis, results table, and 5 falsifiable research directions (general-`p` Jacobson via a char-`p` Lie-theoretic argument; density dichotomy of vanishing-p-curvature primes; Apéry-number Lucas/supercongruence shadows; rank-one Cartier descent ⇔ Artin–Schreier solvability; rank-2/3 matrix p-curvature), each with a "key insight", "Why now?", and a concrete falsifiable prediction.

## Build note
The project's `lakefile.toml` `defaultTargets` reference directories that are absent in this checkout, so `lake build` with no target fails (pre-existing). I added a `Catalog` `lean_lib` glob so the Catalog modules are buildable targets; the new file builds via `lake build Catalog.Novelty.PCurvatureRigidity`.