# Computational evidence: p-adic Berggren dynamics

All data below was produced by direct enumeration (exact integer arithmetic) over
`ZMod m` for the three Berggren generators

```
B₁ = [[1,-2,2],[2,-1,2],[2,-2,3]]   B₂ = [[1,2,2],[2,1,2],[2,2,3]]   B₃ = [[-1,2,2],[-2,1,2],[-2,2,3]]
```

It guided the formal statements in `Catalog/Geometry/PadicBerggrenDynamics.lean`.
**Status note.** The tables are exploratory computations, not machine-checked
certificates; the formal, `sorry`-free content is exactly what is proved in the Lean file.
Where a table entry is covered by a theorem, the theorem name is given.

## 1. Order of the hyperbolic generator `B₂` mod `p`

| p | ord(B₂ mod p) | p−1 | p+1 | p mod 8 | divides |
|---|---|---|---|---|---|
| 3 | 4 | 2 | 4 | 3 | p+1 |
| 5 | 6 | 4 | 6 | 5 | p+1 |
| 7 | 6 | 6 | 8 | 7 | p−1 |
| 11 | 12 | 10 | 12 | 3 | p+1 |
| 13 | 14 | 12 | 14 | 5 | p+1 |
| 17 | 8 | 16 | 18 | 1 | p−1 |
| 19 | 20 | 18 | 20 | 3 | p+1 |
| 23 | 22 | 22 | 24 | 7 | p−1 |
| 29 | 10 | 28 | 30 | 5 | p+1 |
| 31 | 30 | 30 | 32 | 7 | p−1 |
| 41 | 10 | 40 | 42 | 1 | p−1 |
| 73 | 36 | 72 | 74 | 1 | p−1 |

The order divides `p−1` exactly when `p ≡ ±1 (mod 8)`, i.e. exactly when `2` is a
quadratic residue; otherwise it divides `p+1`.  In all cases it divides `p²−1`.

Formalised as `B₂_pow_p_sub_one_of_isSquare_two`, `B₂_pow_p_add_one_of_not_isSquare_two`,
`B₂_pow_card_sq_sub_one`, `B₂_orderOf_dvd`, and the eigenvector form of the dichotomy in
`B₂_null_eigenvector_iff_mod_eight`.

## 2. Order of the unipotent generator `B₁` mod `p^k`

| p | k | modulus | ord(B₁) |
|---|---|---|---|
| 3 | 1,2,3 | 3, 9, 27 | 3, 9, 27 |
| 5 | 1,2,3 | 5, 25, 125 | 5, 25, 125 |
| 7 | 1,2,3 | 7, 49, 343 | 7, 49, 343 |

The order is *exactly* `p^k`: a pure `p`-power with no prime-to-`p` part.
Formalised as `B₁_pow_p_pow` (upper bound) and `B₁_order_exact` (sharpness).

## 3. Null cone and orbits of `B₂` mod `p`

| p | \|cone\| | p² | #orbits | orbit lengths (length, count) | ord(B₂) |
|---|---|---|---|---|---|
| 3 | 9 | 9 | 3 | (1,1), (4,2) | 4 |
| 5 | 25 | 25 | 5 | (1,1), (6,4) | 6 |
| 7 | 49 | 49 | 11 | (1,1), (3,4), (6,6) | 6 |
| 11 | 121 | 121 | 11 | (1,1), (12,10) | 12 |
| 13 | 169 | 169 | 13 | (1,1), (14,12) | 14 |
| 17 | 289 | 289 | 37 | (1,1), (8,36) | 8 |

Observations:

* The null cone always has exactly `p²` points (the conic `a²+b²=c²` is smooth and isotropic
  over `𝔽_p` for odd `p`).  *Not yet formalised* — see `FUTURE_DIRECTIONS.md`, Conjecture 1.
* The only fixed point is `0` (`B₂_no_nonzero_fixed_point`), so all other orbits are free
  except in the split case `p ≡ ±1 (mod 8)`, where the two eigen-null-lines carry shorter
  orbits: for `p = 7` the length-3 orbits are the two eigenlines, and `3` is the
  multiplicative order of the eigenvalue `3 + 2√2 = 2` mod `7`.
* Consequently the number of orbits jumps exactly at the split primes: `p = 7, 17`
  (`p ≡ ±1 mod 8`) have many more orbits than the inert primes `p = 3,5,11,13`.

## 4. Fixed vectors of the unipotent generator `B₁` mod `p`

| p | #fixed | sample |
|---|---|---|
| 3 | 3 | (0,0,0), (0,1,1), (0,2,2) |
| 5 | 5 | (0,0,0), (0,1,1), (0,2,2), (0,3,3) |
| 7 | 7 | (0,0,0), (0,1,1), … |

Exactly the null line `(0,t,t)`, of size `p`.  Formalised as `B₁_fixed_iff` together with
`B₁_fixes_null_line` and `lorentz_B₁_fixed_vector`.

## 5. Depth: `B₂` mod `p^k`

| p | k | ord(B₂ mod p^k) | proved bound `(p²−1)p^(k−1)` |
|---|---|---|---|
| 3 | 1,2,3 | 4, 12, 36 | 8, 24, 72 |
| 5 | 1,2,3 | 6, 30, 150 | 24, 120, 600 |
| 7 | 1,2,3 | 6, 42, 294 | 48, 336, 2352 |

In every case the order is multiplied exactly by `p` when the depth increases by one, which
is the sharp form of `B₂_pow_eq_one_padic` (we prove divisibility; sharpness of the `p`-part
is Conjecture 2 in `FUTURE_DIRECTIONS.md`).

## 6. Counterexample hunt

* Searched all odd primes `p < 200` for a violation of "ord(B₂ mod p) ∣ p²−1": none.
* Searched all odd primes `p < 100` for a violation of the `p mod 8` dichotomy: none.
* Searched `p ∈ {3,5,7}`, `k ≤ 3` for a violation of "ord(B₁ mod p^k) = p^k": none.
* At the excluded prime `p = 2` the picture genuinely differs: `N₁² = 0` mod `4`
  (nilpotency index drops from `3` to `2`), which is why every theorem here assumes `p ≠ 2`.
  This degeneracy is formalised in `N₁_sq_eq_zero_of_four_eq_zero` and its converse
  `N₁_sq_ne_zero`.

## 7. OEIS

The sequence of traces `tr(B₂^n) = 3, 5, 35, 197, …` is the Berggren–Lucas trace sequence
already recorded in the catalog (`Catalog/Cryptography/BerggrenSpectral/SpectrumAndTrace.lean`);
no new integer sequence was needed for the present p-adic results, so no OEIS lookup applies to
the tables above (they are functions of `p`, not a single integer sequence).

## 8. Second cycle: size of the null cone, orbit counts, and the prime 2

All data in this section was produced by brute-force enumeration over `(ZMod m)³`
(exploratory computation, not machine-checked; the corresponding Lean theorems are cited).

### 8.1 Size of the null cone `a² + b² − c² ≡ 0`

| p | #{v ∈ (ZMod p)³ : q(v)=0} | p² |
|---|---|---|
| 3 | 9 | 9 |
| 5 | 25 | 25 |
| 7 | 49 | 49 |
| 11 | 121 | 121 |
| 13 | 169 | 169 |

Formalised as `PadicBerggren.card_nullCone` (`Catalog/Geometry/PadicBerggrenNullCone.lean`).

Modulo `p²` the count is **not** `p⁴`: the cone is singular at the origin, and enumeration
gives `99` for `p = 3` and `725` for `p = 5`, matching the closed form `p⁴ + p³ − p²`.
This is why the counting theorem is stated mod `p` and the depth statements are made through
the Hensel lift `lift_pow` instead.  (Conjecture 1 of `FUTURE_DIRECTIONS.md`.)

### 8.2 Orbits of the hyperbolic generator `B₂` on the null cone mod p

| p | 2 a square mod p | #orbits | longest orbit | p+1 |
|---|---|---|---|---|
| 3 | no | 3 | 4 | 4 |
| 5 | no | 5 | 6 | 6 |
| 7 | yes | 11 | 6 | 8 |
| 11 | no | 11 | 12 | 12 |
| 13 | no | 13 | 14 | 14 |
| 17 | yes | 37 | 8 | 18 |

Every orbit has at most `p + 1` points, and there are always more than one: the dynamics is
never transitive on the `p² − 1` nonzero null vectors.  Formalised as
`PadicBerggren.B₂_orbit_card_le` and `PadicBerggren.B₂_not_transitive_on_nullCone`.

### 8.3 The period on the null eigenline equals the order of `3 + 2√2`

| p | s with s² = 2 | ord(3+2s) in (ZMod p)ˣ | period of (1,1,s) under B₂ |
|---|---|---|---|
| 7 | 3 | 3 | 3 |
| 17 | 6 | 8 | 8 |
| 23 | 5 | 11 | 11 |
| 31 | 8 | 15 | 15 |
| 41 | 17 | 5 | 5 |

Formalised as `PadicBerggren.B₂_eigenvector_period`.

### 8.4 The prime 2

Reducing the three generators mod `2` gives the identity matrix in all three cases:

```
B₁ ≡ B₂ ≡ B₃ ≡ I  (mod 2)
```

so the entire ternary tree collapses to the single point `(3,4,5) ≡ (1,0,1)`.  Formalised as
`PadicBerggren.B₁_mod_two`, `B₂_mod_two`, `B₃_mod_two`, `wordMat_mod_two`, `tree_mod_two`, with
the integral consequence `tree_parity_int` (odd leg, even leg, odd hypotenuse for every vertex).
