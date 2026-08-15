# Computational evidence (cycle 3–5, Mordell-curve denominators)

All numbers below were produced by exact rational arithmetic on the affine group law of
`E_N : y² = x³ + N`.  They are **exploratory** data: only the statements that appear as
theorems in `Catalog/Applications/MordellDenominator*.lean` are machine-checked.  Every
individual number that a Lean theorem depends on (`x(2P) = 2601/3136`,
`x(3P) = -2302089191/656538129`, the factorisations `3136 = 2⁶·7²` and `656538129 = 3⁶·13²·73²`)
is re-derived inside Lean from Mathlib's group law and `norm_num`, not imported from here.

## 1. Denominators along an orbit

`N = 55 = 5·11`, `P = (9,28)`:

| n | x(nP) | den x(nP) | factorisation |
|---|-------|-----------|---------------|
| 1 | 9 | 1 | — |
| 2 | 2601/3136 | 3136 | 2⁶ · 7² |
| 3 | −2302089191/656538129 | 656538129 | 3⁶ · 13² · 73² |
| 4 | −35249882584054239/21498536380459264 | 21498536380459264 (17 digits) | 2⁸ · 7² · … |
| 5 | — | 26 digits | 5² · … (2-free, 7-free, 11-free) |

Observations:

* the prime `7` (good reduction, `7 ∤ Δ = −432·55²`) occurs at `n = 2`, and `13`, `73`
  (also good) occur at `n = 3`;
* the prime `11` occurs in none of the denominators computed; the prime `5` first occurs at
  `n = 5`, with `v₅ = 2`.  So the prime factors of `N` are neither systematically present nor
  systematically absent — the denominators simply do not track the factorisation;
* every denominator is a perfect square (`3136 = 56²`, `656538129 = 25623²`, …).

## 2. `ℓ`-adic valuations along the orbit (`N = 55`, `P = (9,28)`)

| n | v₂ | v₃ | v₇ | v₁₃ |
|---|----|----|----|-----|
| 2 | 6 | 0 | 2 | 0 |
| 3 | 0 | 6 | 0 | 2 |
| 4 | 8 | 0 | 2 | 0 |
| 6 | 6 | 6 | 2 | 2 |
| 8 | 10 | 0 | 2 | 0 |

This is the data that suggested the two laws proved in
`Catalog/Applications/MordellDenominatorFiltration.lean`:

* `v₇` and `v₁₃` are **constant** (`= 2`) on the multiples where they are non-zero — the odd
  primes neither grow nor disappear under doubling
  (`pow_dvd_den_double_iff_of_dvd_den`);
* `v₂` increases by exactly `2` at each doubling (`6 → 8 → 10` at `n = 2, 4, 8`)
  (`pow_dvd_den_double_two_iff`).

## 3. Square-denominator sweep

For `(N, P) ∈ {(55,(9,28)), (35,(1,6)), (17,(4,9)), (−2,(3,5)), (1,(2,3))}` and `1 ≤ n ≤ 5`
(25 points in total): `den x(nP)` is a perfect square and `den y(nP) = (√den x(nP))³` in
**25/25** cases.  No counterexample was found, and the phenomenon is now a theorem for all
rational points of all Mordell curves with integral `N`
(`mordell_den_cube_eq_sq`, `mordell_x_den_isSquare`).

Boundary check: integrality of `N` is necessary.  For `N = 1/8` the point `(x,y) = (1/2,1/2)`
satisfies `y² = x³ + N` and `den x = 2` is not a square.

## 4. Counterexample hunt for the "only bad primes" conjecture

Testing the universal claim "every prime dividing `den x(nP)` lies in `{2,3,p,q}`" on the
orbits above: it fails at `n = 2` for `N = 55` (prime `7`), at `n = 3` for `N = 55`
(primes `13`, `73`), at `n = 3` for `N = 35` (prime `47`), at `n = 3` for `N = 17`
(prime `11`, and `11 ∤ 6·17`), at `n = 2` for `N = −2` (prime `5`).  No orbit tested satisfies
the conjecture beyond the trivial curve `N = 1`, `P = (2,3)` (a torsion point whose multiples
are all integral).

## 5. Where the evidence stops and the proofs start

The tables suggest, and the Lean files prove:

1. square denominators for all rational points (`MordellDenominatorSquares.lean`);
2. invariance of odd `ℓ`-parts and `×4` growth of the `2`-part under doubling
   (`MordellDenominatorFiltration.lean`);
3. a single point (`3P` on `E_55`) failing both halves of the folklore heuristic
   (`MordellDenominatorOrbits.lean`);
4. the complete local law at good primes for arbitrary rational points
   (`MordellDenominatorLocalLaw.lean`).

## 6. Apparition indices (cycles 6–9)

Reading the valuation table of §2 by *columns* rather than rows shows that each prime appears at
the multiples of a single index:

| prime `ℓ` | indices `n ≤ 8` with `ℓ ∣ den x(nP)` | apparition index |
|-----------|--------------------------------------|------------------|
| 2 | 2, 4, 6, 8 | 2 |
| 3 | 3, 6 | 3 |
| 7 | 2, 4, 6, 8 | 2 |
| 13 | 3, 6 | 3 |
| 5 | 5 | 5 (observed; only `n ≤ 5` computed) |

This pattern is no longer a conjecture: `den_apparition_index` proves that for *every* prime and
*every* rational point the index set is exactly `mℤ` for some `m`, and
`seven_apparition_index_eq_two_55`, `thirteen_apparition_index_eq_three_55` prove `m(7) = 2` and
`m(13) = 3` in this orbit (the second column above is therefore explained, not merely observed).

The `v₂` column (`6, 8, 10` at `n = 2, 4, 8`) grows by exactly `2` per doubling; iterating it
gives an unbounded sequence of distinct denominators, which is the computational shadow of
`two_pow_smul_den_factorization`, `mordell_55_point_infinite_order` and
`mordell_55_points_infinite` (`E_55(ℚ)` is infinite, i.e. `E_55` has positive rank).

All numbers in this section are exploratory; the theorems cited re-derive from Mathlib's group
law every value they depend on.
