# Computational evidence: iterating the corrected product

All computations below are **exploratory** (exact rational arithmetic on truncated power series).
Statements that are *Lean-verified* are marked explicitly and point at the theorem that proves
them; the rest is numerical data that motivated the formal statements.

## Setup

A normalized `q`-series is `f = q⁻¹ + a₀ + a₁ q + ⋯`.  The corrected product is
`f ⋆ g = q · f · g`, and in the coordinate `u = q · f` (a power series with `u(0) = 1`) the
corrected product is ordinary multiplication:

```
u(f ⋆ g) = u(f) · u(g)          (Lean: PoleOrderTorsor.toOneUnit_mul)
```

We take as test input the McKay–Thompson series of the class `1A`,

```
J = q⁻¹ + 196884 q + 21493760 q² + ⋯,   u(J) = 1 + 196884 X² + 21493760 X³ + ⋯
```

## 1. Small-case calculation: coefficients of the iterates `J^{⋆n}`

Coefficients of `u(J)^n = u(J^{⋆n})` in degrees `0 … 5`:

| n | X⁰ | X¹ | X² | X³ | X⁴ | X⁵ |
|---|----|----|----|----|----|----|
| 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| 1 | 1 | 0 | 196884 | 21493760 | 0 | 0 |
| 2 | 1 | 0 | 393768 | 42987520 | 38763309456 | 8463554887680 |
| 3 | 1 | 0 | 590652 | 64481280 | 116289928368 | 25390664663040 |
| 4 | 1 | 0 | 787536 | 85975040 | 232579856736 | 50781329326080 |
| 5 | 1 | 0 | 984420 | 107468800 | 387633094560 | 84635548876800 |

Observations, and their formal status:

* **Level 2 is exactly linear in `n`**: `196884 n`.
  *Lean-verified*: `PoleOrderTorsor.Norm.coeffAt_two_pow_traceLaurent_moonshine`
  (and in general `PoleOrderTorsor.Norm.coeffAt_pow_of_mem_deepSubgroup`).
* **Level 4 is quadratic**: `38763309456 = 196884²` and the column equals
  `binom(n,2) · 196884²`.  (The table uses the two-term truncation
  `u(J) = 1 + 196884 X² + 21493760 X³`, so the level-4 input coefficient is `0` here.)
  *Lean-verified* (subsequent cycle): `PoleOrderTorsor.Norm.coeffAt_four_pow_moonshine` gives
  `coeffAt 4 (f^{⋆n}) = n · c₃ + binom(n,2) · c₁²` for every normalized trace series, and in
  general `PoleOrderTorsor.Norm.coeffAt_two_mul_pow_of_mem_deepSubgroup` gives
  `coeffAt (2k) (f^{⋆n}) = n · coeffAt (2k) f + binom(n,2) · (coeffAt k f)²`.  With the untruncated
  `J` this yields `coeffAt 4 (J^{⋆n}) = 864299970 n + binom(n,2) · 196884²`, e.g.
  `40491909396` for `n = 2` (`PoleOrderTorsor.Norm.coeffAt_four_sq_J`).  The general level is
  settled too: `PoleOrderTorsor.coeff_pow_binomial_expansion` gives the exact finite expansion
  `coeff m (u^n) = ∑_{d ≤ m/k} binom(n,d) · coeff m ((u-1)^d)`, whence every column of the table
  above is a polynomial in `n` of degree at most `⌊m/k⌋`
  (`PoleOrderTorsor.Norm.exists_binomial_coeffs`), of degree *exactly* `j` at level `jk` when the
  depth invariant is non-zero (`PoleOrderTorsor.Norm.coeffAt_mul_pow_binomial_law`).
* Level 1 is identically `0`: the constant Laurent coefficient `a₀` of a McKay–Thompson series
  vanishes, and `a₀` is additive.  *Lean-verified*: `PoleOrderTorsor.a₀_mul`,
  `PoleOrderTorsor.Norm.monster_prod_mem_deepSubgroup_two`.

## 2. Counterexample hunt: is the first invariant complete?

We searched for normalized series with `a₀ = 0` that are not the base point `q⁻¹`.  The very
first candidate works: `f = q⁻¹ + q`, i.e. `u = 1 + X²`.  Its `a₀` is `0` yet `f ≠ q⁻¹`.

*Lean-verified*: `PoleOrderTorsor.Norm.a₀_not_complete`,
`PoleOrderTorsor.Norm.leadCoeffHom_not_injective`.  This is why the whole filtration
`PoleOrderTorsor.Norm.deepSubgroup` is needed, rather than a single invariant.

## 3. Counterexample hunt: torsion

We looked for a one-unit `u ≠ 1` with `u^n = 1` for some `n ≤ 6`, truncating at degree `8` and
solving coefficient by coefficient.  Every attempt forces `u = 1`, because the first non-trivial
coefficient `c` at level `k` satisfies `n c = 0` in `ℂ`.

*Lean-verified*: `PoleOrderTorsor.pow_eq_one_of_constantCoeff_one`,
`PoleOrderTorsor.Norm.pow_eq_one_iff`, `PoleOrderTorsor.Norm.zpow_eq_one_iff`.

## 4. Roots: does every series have a `⋆`-square root?

Solving `v² = u(J)` coefficient by coefficient over `ℚ` gives

```
v = 1 + 98442 X² + 10746880 X³ − 4845413682 X⁴ − 1057944360960 X⁵ + ⋯
```

and `v² = u(J)` holds exactly on the computed range.  Note `98442 = 196884 / 2`: the level-2
invariant scales by the exponent `1/2`.

*Lean-verified*: existence and uniqueness of `n`-th roots
(`PoleOrderTorsor.Norm.existsUnique_root`), the explicit root through the binomial series
(`PoleOrderTorsor.Norm.cpow_inv_natCast_pow`), and the scaling law
`coeffAt k (f^{⋆r}) = r · coeffAt k f` (`PoleOrderTorsor.Norm.coeffAt_cpow`), which specialises
to `98442 = 196884 / 2`.

## 5. OEIS

The columns above are `196884 n`, `21493760 n`, `196884² · binom(n,2)`, … — rescalings of the
moonshine coefficients (`A007240`: `196884, 21493760, 864299970, …`) by binomial factors, not new
sequences, so no separate OEIS entry is claimed.

## 6. Is the invariant system complete and free?

Prescribing the invariants `(coeffAt 1 f, coeffAt 2 f, …)` arbitrarily and solving for `u(f)`
succeeds trivially: the `k`-th invariant *is* the `X^k`-coefficient of `u(f)`, and the only
constraint on `u(f)` is `u(0) = 1`.  So the invariants are unconstrained coordinates, and two
normalized series with equal invariants coincide.

*Lean-verified*: `PoleOrderTorsor.Norm.coeffSystem_bijective` (a bijection `Norm ≃ (ℕ → ℂ)`), with
`PoleOrderTorsor.Norm.coeffSystem_not_additive` showing that this bijection is *not* a group
isomorphism — additivity of the level-`k` coordinate only holds after restricting to the `k`-th
stage of the filtration (`PoleOrderTorsor.Norm.gradedHom`), whose graded quotients are all copies
of `(ℂ, +)` (`PoleOrderTorsor.Norm.gradedQuotEquiv`).
