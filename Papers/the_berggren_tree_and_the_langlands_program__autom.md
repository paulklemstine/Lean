# Computational evidence — Berggren tree vs. the arithmetic of Q(√2)

All numbers below were produced by `#eval` inside Lean 4 (exact integer arithmetic) before
the formal proofs were written.  Everything reported here is *also* proved formally in
`Catalog/MachineLearning/Berggren{SilverUnits,UnitLocus,SpineBinet,BoundaryHecke,TraceField}.lean`,
so nothing in this note is load-bearing for the results; it is the exploratory record.

## 1. The silver coordinate along the B-spine

Silver coordinate: `ζ(a,b,c) = (a+b) + c√2 ∈ ℤ[√2]`, fundamental unit `u = 1 + √2`.

| n | spine node `mBⁿ(3,4,5)` | `a+b` | `c` | `(a+b)² − 2c²` | `2ab − c²` |
|---|--------------------------|-------|-----|----------------|------------|
| 0 | (3, 4, 5)                | 7     | 5   | −1             | −1 |
| 1 | (21, 20, 29)             | 41    | 29  | −1             | −1 |
| 2 | (119, 120, 169)          | 239   | 169 | −1             | −1 |
| 3 | (697, 696, 985)          | 1393  | 985 | −1             | −1 |
| 4 | (4059, 4060, 5741)       | 8119  | 5741| −1             | −1 |
| 5 | —                        | 47321 | 33461| −1            | −1 |

Powers of the fundamental unit: `u³ = 7 + 5√2`, `u⁵ = 41 + 29√2`, `u⁷ = 239 + 169√2`, …
So `ζ(mBⁿ(3,4,5)) = u^(2n+3)` exactly — this is `Silver.zeta_spine`, and the `−1` column is
`Silver.spine_negPell` (`norm u^odd = −1`).

The hypotenuses `5, 29, 169, 985, 5741, 33461` and the leg sums `7, 41, 239, 1393, 8119,
47321` are the classical Pell / NSW sequences (the identifiers usually cited for them are
OEIS A001653 and A002315; this was not re-checked against OEIS offline).

## 2. Counterexample hunt: which nodes carry units?

For every word of length ≤ 3 in the three generators we computed
`N(ζ(v)) = (a+b)² − 2c²`.  Depth-3 sample (27 nodes, all listed):

```
((9,40,41),   -961)  ((105,88,137), -289)  ((91,60,109),  -961)
((105,208,233),-10609) ((297,304,425), -49) ((187,84,205), -10609)
((95,168,193), -5329) ((207,224,305), -289) ((117,44,125), -5329)
((57,176,185),-14161) ((377,336,505),-1681) ((299,180,349),-14161)
((217,456,505),-57121) ((697,696,985),  -1) ((459,220,509),-57121)
((175,288,337),-12769) ((319,360,481),-1681) ((165,52,173), -12769)
((51,140,149), -7921) ((275,252,373), -529) ((209,120,241), -7921)
((115,252,277),-18769) ((403,396,565), -49) ((273,136,305),-18769)
((85,132,157), -2209) ((133,156,205), -529) ((63,16,65),   -2209)
```

Two observations, both of which became theorems:

* every value is minus a perfect square, namely `−(a−b)²` (`UnitLocus.zeta_norm_eq_neg_sq`);
* exactly one node of depth 3 has norm `±1`, namely `BBB = (697,696,985)`
  (`UnitLocus.unit_locus_eq_spine`).  No counterexample to "unit ⟺ address is all-B"
  was found at depths 0–3 (1 + 3 + 9 + 27 = 40 nodes), and the classification theorem shows
  none exists at any depth.

## 3. Spectral data of the hyperbolic generator

`B = !![1,2,2; 2,1,2; 2,2,3]`, `char(B) = (X+1)(X² − 6X + 1)`, eigenvalues `−1`, `3 ± 2√2`.
Eigenvectors over `ℤ[√2]`: `(1,−1,0)` for `−1`, `(1,1,±√2)` for `3 ± 2√2`; the two
hyperbolic eigenvectors are light-like (`1 + 1 − 2 = 0`), i.e. the two ideal endpoints of
the axis.  In the spin (Euclid-parameter) picture the same generator is `!![2,1;1,0] ∈
GL(2,ℤ)` with eigenvalues `1 ± √2`: the three-dimensional eigenvalue is the *square* of the
spin eigenvalue.

Growth check (Binet): `A = (7+5√2)/(2√2) ≈ 4.97487`, `λ = 3+2√2 ≈ 5.82843`;
`A λⁿ = 4.9749, 28.9999, 169.0000, 985.0000, …`, so `cₙ` is the nearest integer to `A λⁿ`
(`Binet.spine_nearest_integer`), and `c_{n+1}/c_n → 5.82843…`.

## 4. Boundary Hecke data

With `T f(w) = Σ_x f(x⌢w)` and `U f(w) = f(σw)` on observables of the Cantor boundary,
`T U = 3 id` and `(UT)² = 3 UT` hold identically, so the only possible eigenvalues are `0`
and `3`; both occur (constants, and any mean-zero weight on the first letter).  No numeric
search was needed: the relation is an identity.  Numerically, `3 ± 2√2 ≈ 5.828, 0.172` are
neither `0` nor `3`, and `2√q = 2√2 ≈ 2.828 < 3`, i.e. even the trivial tree eigenvalue is
already non-tempered.
