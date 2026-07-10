# Computational evidence: the global spectral Ihara zeta and RH ⇔ Ramanujan

This note supports `GraphZetaGlobalRH.lean`, which studies the reciprocal of the
spectral part of the Ihara zeta function of a `(q+1)`-regular graph,

    Z⁻¹(u) = ∏_λ (1 − λ u + q u²),          product over the adjacency spectrum {λ},

and proves that **every zero of `Z⁻¹` lies on the critical circle `|u| = 1/√q`
iff every eigenvalue obeys the Ramanujan bound `λ² ≤ 4q`**.

## 1. Single local factor `1 − λu + qu²`

The roots of `q u² − λ u + 1 = 0` are `u = (λ ± √(λ²−4q)) / (2q)`, with product
`u₊·u₋ = 1/q` (Vieta).

* **Ramanujan case `λ² ≤ 4q`.** Roots are complex conjugates, so
  `|u₊|² = |u₋|² = u₊ u₋ = 1/q`, i.e. both sit on `|u| = 1/√q`.
  - `λ = 1, q = 2`: roots `(1 ± i√7)/4`, `|u|² = (1+7)/16 = 0.5 = 1/q`. ✔
* **Non-Ramanujan case `λ² > 4q`.** Roots are real and distinct with product
  `1/q > 0`, hence the same sign; they cannot both have modulus `1/√q` (that
  would force them equal). So at least one lies off the circle.
  - `λ = 5, q = 2`: roots `≈ 0.2192` and `≈ 2.2808`, product `= 0.5 = 1/q`,
    critical radius `1/√2 ≈ 0.7071`. Both are off the circle. ✔
  - `λ = 3, q = 2` (`9 > 8`): the constructed off-circle root witnesses the
    failure of RH used in `zetaInv_RH_fails_of_nonRamanujan`.

## 2. Global product over a spectrum

Because a product vanishes iff a factor vanishes, the zero set of `Z⁻¹` is the
union of the local root sets. Hence:

* all eigenvalues Ramanujan  ⟹  all zeros on `|u| = 1/√q`  (`zetaInv_global_RH`);
* one eigenvalue off-range   ⟹  one zero off the circle    (`zetaInv_RH_fails…`).

These combine into the equivalence `zetaInv_RH_iff_ramanujan`.

Sample graphs used as instances in the Lean file:

| graph        | q | nontrivial spectrum        | Ramanujan window λ²≤4q | RH |
|--------------|---|----------------------------|------------------------|----|
| Petersen     | 2 | `{1, −2}`                  | `≤ 8`  (1, 4 ≤ 8)      | ✔ |
| `C₅` cycle   | 1 | `2cos(2πk/5)` (max 2)      | `≤ 4`  (4 ≤ 4)         | ✔ (boundary) |
| hypothetical | 2 | contains `3`               | `9 > 8`                | ✘ |

## 3. Functional equation

Numerically, for `p(u) = 1 − λu + qu²`, one checks
`q u² · p(1/(qu)) = q u² · (1 − λ/(qu) + q/(qu)²) = 1 − λu + qu² = p(u)`,
so the reflection `u ↦ 1/(qu)` is a symmetry; over the whole spectrum it picks
up the automorphy factor `(qu²)^n` (`zetaInv_funeq`).

## 4. OEIS / counterexample hunt

No integer sequence is central to these results; they are algebraic/analytic
identities about a quadratic and its products. The counterexample hunt is the
non-Ramanujan direction itself: for every `λ² > 4q` an explicit off-circle real
root is produced, which is exactly what `factor_offCircle_root` formalizes. No
counterexample to the proved equivalence was found (nor can there be — it is a
theorem).
