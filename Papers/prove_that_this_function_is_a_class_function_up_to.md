# Computational Evidence — Cayley walk censuses

All numbers below were produced by `#eval` inside the project's Lean environment,
using the definition `CayleyCensus.walkCount` from
`Catalog/MachineLearning/CayleyCensusInvariance.lean`
(`walkCount S n g = #{(s₁,…,s_n) ∈ Sⁿ : s₁⋯s_n = g}`).  Every qualitative
pattern noticed here is subsequently proved (or refuted) formally; the file is a
record of the exploration, not of the verification.

## 1. `G = DihedralGroup 3` (order 6)

Columns are ordered `r 0, r 1, r 2, sr 0, sr 1, sr 2`; row `n` is the census at
walk length `n`.

### 1a. `S = {r 1, r 2}` (the rotation conjugacy class)

```
n=0 : [ 1,  0,  0, 0, 0, 0]
n=1 : [ 0,  1,  1, 0, 0, 0]
n=2 : [ 2,  1,  1, 0, 0, 0]
n=3 : [ 2,  3,  3, 0, 0, 0]
n=4 : [ 6,  5,  5, 0, 0, 0]
n=5 : [10, 11, 11, 0, 0, 0]
```

Observations.
* The columns of `r 1` and `r 2` coincide — predicted by inversion invariance.
* The census vanishes off `⟨r⟩ = Subgroup.closure S`; this became
  `walkCount_eq_zero_of_not_mem_closure`.
* Row sums are `1, 2, 4, 8, 16, 32 = |S|ⁿ`, matching `sum_walkCount`.
* **Return dominance fails at odd lengths**: at `n = 3` the identity has `2`
  while `r 1` has `3`, and at `n = 5`, `10 < 11`.  At even lengths
  (`2 ≥ 1`, `6 ≥ 5`) it holds.  This is exactly the boundary recorded in
  `return_dominance_fails_for_odd_length` and is why
  `walkCount_two_mul_le_walkCount_two_mul_one` is stated for length `2n`.
* The identity column `1, 0, 2, 2, 6, 10` is the number of closed walks; it
  satisfies `a(n) = a(n-1) + 2a(n-2)`, i.e. `a(n) = (2ⁿ + 2(-1)ⁿ)/3`, the
  Jacobsthal-type sequence `1, 0, 2, 2, 6, 10, 22, 42, …` (an OEIS lookup was
  not available offline, so no A-number is asserted here).  The closed form
  matches the eigenvalues `2, -1, -1` of the adjacency matrix of the triangle
  `Cay(ℤ/3, {1,2})` and is consistent with the trace formula `trace_adj_pow`.
  Only the tabulated values above were computed; the closed form itself is an
  unverified observation.

### 1b. `S = {sr 0, sr 1, sr 2}` (the reflection conjugacy class)

```
n=0 : [1, 0, 0,  0,  0,  0]
n=1 : [0, 0, 0,  1,  1,  1]
n=2 : [3, 3, 3,  0,  0,  0]
n=3 : [0, 0, 0,  9,  9,  9]
n=4 : [27,27,27, 0,  0,  0]
n=5 : [0, 0, 0, 81, 81, 81]
```

The census is constant on each conjugacy class (`refl_isClassFunction`) and the
graph is bipartite (`K₃,₃`), so odd and even lengths alternate supports.

### 1c. `S = {r 1, r 2, sr 0}` (inversion closed, *not* conjugation closed)

```
n=0 : [ 1,  0,  0,  0,  0,  0]
n=1 : [ 0,  1,  1,  1,  0,  0]
n=2 : [ 3,  1,  1,  0,  2,  2]
n=3 : [ 2,  6,  6,  7,  3,  3]
n=4 : [19, 11, 11,  8, 16, 16]
n=5 : [30, 46, 46, 51, 35, 35]
```

Exactly **four** distinct rows appear: `{r 0}`, `{r 1, r 2}`, `{sr 0}`,
`{sr 1, sr 2}`.  The degeneracy `r 1 ~ r 2` comes from inversion, the degeneracy
`sr 1 ~ sr 2` from conjugation by `sr 0` (an `S`-preserving automorphism, since
`sr 0` swaps `r 1, r 2` and fixes itself), and `sr 0` is *not* equivalent to the
other reflections.  Formalised as `mix_census_r1_eq_r2`, `mix_census_sr1_eq_sr2`
and `mix_card_census_le_four`.

### 1d. `S = {r 1}` (not inversion closed) — counterexample hunt

```
n=0 : [1, 0, 0, 0, 0, 0]
n=1 : [0, 1, 0, 0, 0, 0]
n=2 : [0, 0, 1, 0, 0, 0]
n=3 : [1, 0, 0, 0, 0, 0]
```

At `n = 1` the census separates `r 1` from `(r 1)⁻¹ = r 2`.  So inversion
invariance genuinely requires `InvClosed S`; recorded as
`walkCount_inv_fails_without_invClosed`.

## 2. `G = ℤ/8` (multiplicative), `S = {1, 3, 5, 7}` — the converse hunt

`Cay(ℤ/8, odd) = K₄,₄`.  Columns `0, 1, …, 7`:

```
n=0 : [ 1,  0,  0,  0,  0,  0,  0,  0]
n=1 : [ 0,  1,  0,  1,  0,  1,  0,  1]
n=2 : [ 4,  0,  4,  0,  4,  0,  4,  0]
n=3 : [ 0, 16,  0, 16,  0, 16,  0, 16]
n=4 : [64,  0, 64,  0, 64,  0, 64,  0]
```

Only **two** distinct rows, whereas `⟨inversion, Aut(ℤ/8, S)⟩` has four orbits
`{0}, {4}, {2,6}, {1,3,5,7}` (all four automorphisms `×1, ×3, ×5, ×7` preserve
`S`, and inversion is `×7`).  Hence the orbit bound `card_census_image_le` is
*not* always sharp, and the naive converse of the invariance theorem is false.
The extra symmetry is the transposition `(2 4)`, a graph automorphism of `K₄,₄`
fixing the identity that is not a group automorphism.  Formalised as
`census_eq_but_not_censusEquiv`, with the obstruction
`CensusEquiv_sq_eq_one_iff` (`4` is an involution, `2` is not).

## 3. Summary of what the evidence drove

| Observation | Formal outcome |
|---|---|
| `r 1`, `r 2` columns agree whenever `S⁻¹ = S` | `walkCount_inv` (proved) |
| `sr 1`, `sr 2` agree for the non-normal set | `walkCount_mulAut` (proved) |
| class-constancy for conjugation-closed `S` | `walkCount_conj` (proved) |
| distinct-row count = number of orbits | `card_census_image_le` (proved) |
| identity maximal at even lengths only | `walkCount_two_mul_le_walkCount_two_mul_one` + odd counterexample (both proved) |
| directed `S` breaks inversion symmetry | `walkCount_inv_fails_without_invClosed` (proved) |
| `K₄,₄` has fewer rows than orbits | `census_eq_but_not_censusEquiv` (proved) |
