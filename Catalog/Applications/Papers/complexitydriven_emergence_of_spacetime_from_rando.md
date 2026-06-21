# Computational Evidence — Bond-Dimension Phase Transition

Concise numerical support for the theorems formalized in
`Catalog/Physics/TensorNetworkBondTransition.lean`,
`Catalog/Physics/HolographicCurvatureBound.lean`, and
`Catalog/Physics/HolographicEntropyInequalities.lean`.

## 1. Bond entropy `S(b, D) = b · log₂ D` and the critical bond dimension

`Nat.log 2 D` for `D = 0 … 9`:

| D | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|---|
| log₂D | 0 | 0 | 1 | 1 | 2 | 2 | 2 | 2 | 3 | 3 |

The map is **monotone non-decreasing** (justifies `bondEntropy_mono_right`) and
plateaus (so the threshold is a half-line, not a unique jump — see Lab Notes).

For a single cut bond (`b = 1`) hosting a `S = 2` budget, the least admissible
`D` is `4` (`log₂4 = 2`, `log₂3 = 1`). This is exactly
`criticalBond 1 2 = 4` (theorem `toric_logical_critical_bond`).

## 2. Toric holographic code `[[2L², 2, L]]`

`(L, BPT defect = n − k·d², correction radius t = (d−1)/2)` for `L = 0 … 6`:

| L | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| defect | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| t | 0 | 0 | 0 | 1 | 1 | 2 | 2 |

* **Curvature defect ≡ 0** for every `L` → universal scale-invariant bound
  `k·d²/n = 1` (`toric_curvature_universal`).
* **Correction radius** jumps `0 → ≥1` exactly at `L = 3` → sharp smooth-geometry
  threshold (`smooth_geometry_iff`, `subcritical_fractal`).

## 3. Counterexample hunt

* Monotonicity / SSA were tested against random submodular cut profiles on small
  vertex sets; no violation found (consistent with the proved theorems).
* The universal-curvature claim is exact (defect `= 0`), so no approximate
  counterexample is possible; the only failure mode would be a non-toric family,
  which is outside the stated scope.

All tables were produced with `#eval` in Lean and match the formally proved
statements.
