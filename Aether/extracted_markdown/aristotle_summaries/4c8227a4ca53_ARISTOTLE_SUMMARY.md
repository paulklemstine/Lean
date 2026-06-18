# Summary of changes for run 2674aa9f-3ddd-46f6-b765-b491ed8d5e60
Created `Catalog/Applications/SmoothPoincare/TropicalHullRecovery.lean`, a self-contained, fully-proved formalization of the tropical hull-recovery theorem for binary linear codes. It builds on the existing catalog code infrastructure (`wt`, `hamming`, `ones`, the concatenation `⊕c` and the tropical weight enumerator file) by importing `Catalog.Applications.SmoothPoincare.TropicalWeightEnumerator`.

Contents (all with complete proofs, no `sorry`, no new axioms):
- `minWt`/`maxWt` — the minimum and maximum realized codeword weights, with the basic lower/upper-bound and attainment API (`minWt_le_of_mem`, `le_minWt`, `le_maxWt_of_mem`, `maxWt_le`, `exists_wt_eq_minWt`, `exists_wt_eq_maxWt`).
- `realizedSlope C hC w` — the explicit convention: `w` is attained by a codeword and there exists `t : ℝ` such that for every codeword of weight `w' ≠ w`, `(w) + t·w < (w') + t·w'` (i.e. `w` is the strict unique minimizer of the affine value `w·(1+t)` at some parameter).
- `realizedSlope_minWt`, `realizedSlope_maxWt` — endpoint realizability (witness `t = 0` for the minimum, `t = -2` for the maximum).
- `realizedSlope_iff` — the central theorem: `realizedSlope C hC w ↔ w = minWt C hC ∨ w = maxWt C hC`, proved by the sign analysis (negative `1+t` forces the maximum, positive `1+t` the minimum, and the contradiction when `w` is interior).
- `not_realizedSlope_interior` — strict interior weights `minWt < w < maxWt` are never realized slopes (the information-loss statement).
- Direct-sum corollaries `minWt_appendCode`, `maxWt_appendCode` (endpoint additivity under `⊕c`) and `realizedSlope_minWt_appendCode` (endpoint recovery propagates through concatenation).
- Extended Hamming instantiation `minWt_hamming = 0`, `maxWt_hamming = 8`, and `not_realizedSlope_hamming_four`: weight `4` is not a realized slope because the endpoints are `0` and `8`.

The module docstring explains the information-loss phenomenon (the tropical profile only detects the endpoint/convex-hull weights under the strict unique-minimizer notion).

The target module compiles cleanly with no errors, no warnings, and no `sorry`; `#print axioms` on the key results shows only the permitted axioms (`propext`, `Classical.choice`, `Quot.sound`, plus `Lean.ofReduceBool`/`Lean.trustCompiler` inherited from the existing `native_decide`-based Hamming spectrum lemmas).

One supporting change: the root `lakefile.toml` had no library covering the `Catalog.*`-prefixed modules used throughout `Applications/SmoothPoincare`, so the new file (and the existing ones) could not be built from the project root. I added a `Catalog` lean_lib entry (glob `Catalog.+`) to make these modules buildable; this is additive and does not alter existing entries.