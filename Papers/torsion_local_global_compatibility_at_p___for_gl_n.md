# Computational Evidence — Torsion local–global compatibility (combinatorial core)

This note records the small-case checks that preceded the formal proofs in
`HodgeTateWeights.lean` and `TorsionEigensystem.lean`.

## 1. Hodge–Tate weight symmetry (polarization / purity)

Model: the Hodge–Tate weights of an `n`-dimensional conjugate self-dual representation form a
multiset of integers invariant under the central reflection `a ↦ c - a` (similitude weight `c`).

Purity identity tested: `2 · (Σ weights) = c · n`.

| n | weights (polarized, c) | Σ weights | 2·Σ | c·n | central weight `2a=c`? |
|---|------------------------|-----------|-----|-----|------------------------|
| 2 | {1, 5}, c=6            | 6         | 12  | 12  | none (even dim)        |
| 2 | {0, 4}, c=4            | 4         | 8   | 8   | none                   |
| 3 | {1, 3, 5}, c=6         | 9         | 18  | 18  | **yes, a=3**           |
| 3 | {-2, 1, 4}, c=2        | 3         | 6   | 6   | **yes, a=1**           |
| 4 | {0,1,5,6}, c=6         | 12        | 24  | 24  | none                   |
| 4 | {a,a,c-a,c-a} (not regular) | c·2  | 4c  | 4c  | none (regularity fails)|

Observations, all later proved:
* The purity identity `2·Σ = c·n` holds for *every* polarized multiset (`polarized_detWeight`).
* In *odd* dimension with *distinct* weights, a central weight `a` with `2a = c` always appears
  (`polarized_odd_central`).  Every regular odd example we tried contained the fixed point of
  `a ↦ c-a`.
* Regularity is essential: the last row (`{a,a,c-a,c-a}`) is polarized in even dim 4 with no central
  term, consistent with the odd hypothesis being necessary.

Counterexample hunt: no polarized regular odd-dimensional multiset without a central weight was
found; the parity argument (fixed-point-free involution ⇒ even cardinality) explains why none exists.

## 2. GL(1) torsion eigensystem counts at prime-power level

A `GL(1)` torsion Hecke eigensystem of level `n` is a Dirichlet character mod `n`; the count is
`φ(n)`.  At prime-power level `p^k` (the shape of `ℤ/ℓ^m` coefficients) the count is `p^{k-1}(p-1)`.

| p | k | #eigensystems `= φ(p^k)` | `p^{k-1}(p-1)` |
|---|---|--------------------------|----------------|
| 2 | 3 | 4                        | 4·1 = 4        |
| 3 | 2 | 6                        | 3·2 = 6        |
| 5 | 2 | 20                       | 5·4 = 20       |
| 7 | 1 | 6                        | 1·6 = 6        |

All match `Nat.totient_prime_pow`, matching `card_torsion_eigensystem_primePow`.

## 3. Inverse-limit assembly

Sanity check of `ℤ_ℓ = lim ℤ/ℓ^k`: a compatible sequence such as `1, 1+3, 1+3+9, …` mod `3^k`
converges to a well-defined 3-adic integer, and any two lifts agreeing modulo every `3^k` coincide.
This uniqueness is exactly what `torsion_eigensystem_lift` formalizes.
