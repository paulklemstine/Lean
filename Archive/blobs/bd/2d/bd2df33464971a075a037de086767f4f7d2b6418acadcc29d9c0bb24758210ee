# Summary of changes for run a09ed4e4-24a5-47a2-a554-615961a027f7
## Summary

I produced a self-contained, fully-proved Lean 4 research file and the required research notes, adversarially testing — and **refuting, for the linear rule** — the cryptographic conjecture of a sharp monotone log-time complexity phase transition in a 1D cellular automaton.

### New Lean file: `Catalog/Cryptography/AdditiveCAComplexityThreshold.lean`
Studies the additive (Rule 90) CA over 𝔽₂ (row `t` of Pascal's triangle mod 2). Defines `complexity t` (number of odd binomial coefficients = live cells), `popcount t` (binary digit-sum), and `density t = complexity t / (t+1)`. All 18 lemmas/theorems are proven with **no `sorry`**, depending only on `propext`, `Classical.choice`, `Quot.sound` (the `density`/Mersenne results also stay within this set after removing `native_decide`). The build is warning-free.

Key results:
- `complexity_eq_two_pow_popcount` — the exact closed form `complexity t = 2 ^ popcount t`.
- `odd_choose_two_mul` / `odd_choose_two_mul_succ` — one-digit Lucas peel mod 2 (via Mathlib's `Choose.choose_modEq_choose_mod_mul_choose_div_nat`).
- `complexity_two_mul` / `complexity_two_mul_succ` — the digit-peeling recurrences `complexity(2m)=complexity m`, `complexity(2m+1)=2·complexity m`.
- `mersenne_row_odd` (Lucas) / `pow_two_row_even` (Kummer) — the building blocks.
- `complexity_mersenne` (`=2^k`, full) / `complexity_pow_two` (`=2`, sparse).
- `density_mersenne` (`=1`) / `density_pow_two` (`=2/(2^k+1)`).
- `density_full_infinitely_often` and `density_not_bounded_below` — density oscillates between 1 and 0 infinitely often, so there is **no monotone threshold**; complexity is governed by the binary-digit structure of the time index.
- `complexity_sum_pow_two` — `∑_{t<2^m} complexity t = 3^m` (typical-case sparsity vs worst-case fullness).

The file includes a Lab Notebook block (Hypothesis / Result / Insight / Failure analysis) and per-result `-- !-- ... -- !--` proof sketches, with explicit catalog synthesis linking to the algebraic renormalization theory in `Catalog/Novelty/AdditiveCAPadicRenorm.lean`.

### `FUTURE_DIRECTIONS.md`
A narrative synthesis plus 5 falsifiable directions (nonlinearity necessary for a monotone threshold; a true torus threshold via the multiplicative order of 2; the base-`p` product-of-digits generalization; a matching automaticity Kolmogorov upper bound; typical-case `(3/4)^m → 0` mean-density vanishing), each with a "key insight" and "Why now?" justification referencing the proven theorems.

### Build fix
The project's `lakefile.toml` was missing `srcDir = "Catalog"`, so no module (existing or new) resolved and `lake build` failed outright. I added that one line; the project's module names (`Cryptography.*`, etc.) now resolve and the new module builds.