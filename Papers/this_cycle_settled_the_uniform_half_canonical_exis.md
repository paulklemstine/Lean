# Computational evidence — Baker–Norine ranks on complete graphs

All numbers below were produced by an independent brute-force implementation of
Dhar's burning algorithm (`q`-reduction) together with exhaustive enumeration of
effective test divisors.  **These computations are *not* machine-checked**; they
guided the choice of statements that are proved in Lean.  Every claim that is
proved in Lean is marked ✅ and is stated in
`Catalog/Pythagorean/BrillNoether/CompleteGraphRank.lean` or
`Catalog/Pythagorean/BrillNoether/ThresholdFiring.lean`.

## 1. Maximal rank at the half-canonical degree on `Kₙ`

`Kₙ` is `(n-1)`-regular, `g = (n-1)(n-2)/2`.  All `n^(n-2)` divisor classes of
degree `g - 1` were enumerated through their `q`-reduced representatives.

| `n` | `k = n-1` | `g` | `deg = g-1` | #classes | max rank | `k - 1` |
|----|----|----|----|----|----|----|
| 3 | 2 | 1 | 0 | 3 | 0 | 1 |
| 4 | 3 | 3 | 2 | 16 | 0 | 2 |
| 5 | 4 | 6 | 5 | 125 | 2 | 3 |
| 6 | 5 | 10 | 9 | 1296 | **2** | 4 |
| 7 | 6 | 15 | 14 | 16807 | **5** | **5** |
| 8 | 7 | 21 | 20 | 262144 | **5** | 6 |

The `n = 8` row was obtained by a two-stage search: a cheap filter using the `22`
"monotone staircase" test divisors of degree `6` left `28` surviving classes, and
all `28` were then checked against all `1716` effective divisors of degree `6`.
No class of degree `20` on `K₈` has rank `≥ 6`.

**Reading.**  `K₇` is the unique complete graph in this range where the
half-canonical rank reaches `k - 1`.  `K₆` (`k = 5`) and `K₈` (`k = 7`) — exactly
the two residual degrees of the previous cycle — fall short, and so does `K₅`
(`k = 4`).

✅ Formalised: the *uniform witness* on `K₆`, `K₇`, `K₈` has rank exactly
`2`, `5`, `5` (`rank_halfCanonical_K6/K7/K8`).  The "maximum over all classes"
column is computational only.

## 2. Rank of the constant divisor `m` on `Kₙ`

| `m` \ `n` | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | `3m-1` | `m(m+3)/2` |
|----|----|----|----|----|----|----|----|----|----|----|
| 1 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 |
| 2 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| 3 | 8 | 9 | 9 | 9 | 9 | 9 | 9 | 9 | 8 | 9 |
| 4 | 11 | 13 | 14 | 14 | 14 | 14 | 14 | 14 | 11 | 14 |

The value stabilises at `m(m+3)/2` as soon as `n ≥ m + 2`, **independently of
`n`**.  The old one-shot bound `3m - 1` is therefore sharp exactly for
`m ∈ {1, 2}` (where `3m-1 = m(m+3)/2`) and strictly weaker for `m ≥ 3`.

✅ Formalised (**this cycle**): the exact value `rank = m(m+3)/2` for all `m` and
all `n ≥ m + 2` (`rankBN_const_K`, `rank_const_K`), combining the upper bound
`not_rankAtLeast_const_K` with the new matching lower bound
`rankAtLeast_const_K`.  Every entry of the table above is therefore now a
theorem, and so is the `n`-independence.

## 3. Rank of a concentrated divisor `c · q` on `Kₙ`

Writing `c = a(n-1) + b` with `0 ≤ b ≤ n - 2`, the data for `3 ≤ n ≤ 8`,
`0 ≤ c ≤ 24` fit exactly

  `r(c · q) = a(a+1)/2 + min(b, a)`.

For example on `K₈` (`n - 1 = 7`) and `c = 20 = 2·7 + 6` this gives
`3 + min(6,2) = 5`, matching row `n = 8` of §1.  In every case examined, the
maximum of the rank over all classes of a given degree is attained at `c · q`.

## 4. The new threshold bound versus the truth

The threshold estimate proved in `ThresholdFiring.lean` gives, for a divisor with
`m = a + b` chips everywhere on a graph of minimum degree `k`,

  `rank ≥ min (2(a+b) + a b, (a+b) + k)`.

Optimising over `a + b = m` (i.e. `a ≈ b ≈ m/2`) and letting `k → ∞`:

| `m` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|----|----|----|----|----|----|----|----|----|----|----|
| old `3m-1` | 2 | 5 | 8 | 11 | 14 | 17 | 20 | 23 | 26 | 29 |
| new `2m + ⌊m²/4⌋` | 2 | 5 | 8 | 12 | 16 | 21 | 26 | 32 | 38 | 45 |
| truth on `Kₙ` | 2 | 5 | 9 | 14 | 20 | 27 | 35 | 44 | 54 | 65 |

The new bound is never worse, is quadratic rather than linear, and never exceeds
the true value — consistent with correctness.  Since the last row is now a
theorem, the strict gap for `m ≥ 3` is a theorem too
(`rank_const_K_gt_threshold_bound`): a *single* threshold firing can never reach
the truth, the quadratic coefficient it produces being `1/4` instead of `1/2`.

## 4b. The shift criterion (this cycle's engine)

On `K n` the Laplacian acts by `lap f v = n · f v − ∑ f`, so `D` is equivalent to
an effective divisor **iff** some integer shift `s` satisfies

  `∑_v ⌈(s − D v)/n⌉ ≤ s`   (`linEquiv_effective_iff_K`, proved).

Write `d(D) = min_s (∑_v ⌈(s − D v)/n⌉ − s)`; the criterion says `D` is equivalent
to an effective divisor iff `d(D) ≤ 0`.  Because `d` is invariant under `s ↦ s+n`
the minimum is a finite check.  Spot values on `K₆` (hand computations from the
criterion, *not* machine-checked):

| divisor on `K₆` (degree 7) | witness `s` | `∑_v ⌈(s − D v)/6⌉` | `d(D)` | equivalent to effective? |
|----|----|----|----|----|
| `(−1, 0, 1, 2, 2, 2)` (staircase, `m = 2`) | — | — | `1` | no |
| `(−1, 0, 2, 2, 2, 2)` | `2` | `2` | `0` | yes |
| `(−3, 2, 2, 2, 2, 2)` | `1` | `1` | `0` | yes |

Averaging `d` over a complete residue window of shifts gives Riemann's inequality
on `Kₙ` (`linEquiv_effective_of_genus_le_deg_K`): the mean of
`∑_v ⌈(s − D v)/n⌉ − s` over `s = 0, …, n−1` is `(g − deg D + n − 1)/n`, which is
below `1` exactly when `deg D ≥ g`; and the staircase of degree `g − 1` shows that
this is sharp.

The staircase is the unique obstruction: its deficiency is exactly `1`, which is
the content of `not_rankAtLeast_const_K`, and the lower-bound theorem
`rankAtLeast_const_K` shows every other subtraction of `5` chips from `2 · 1` has
`d = 0`.

## 5. Consequence for the half-canonical problem

For a `k`-regular graph the uniform witness has `m = ⌊(k-2)/2⌋` chips per vertex,
so the new bound reads `min(2m + ⌊m²/4⌋, m + k)`:

| `k` | 6 | 8 | 10 | 12 | 14 | 16 | 20 | 30 |
|----|----|----|----|----|----|----|----|----|
| old `min(3m-1, k+m)` | 5 | 8 | 11 | 14 | 17 | 20 | 26 | 41 |
| new | 5 | 8 | 12 | 16 | **20** | **23** | **29** | **44** |
| `k - 1` (previous uniform statement) | 5 | 7 | 9 | 11 | 13 | 15 | 19 | 29 |

From `k = 14` on the bound equals `k + ⌊(k-2)/2⌋ ≈ 3k/2`.

✅ Formalised: `exists_halfCanonical_rank_regular_superlinear` and, as a concrete
instance, `exists_halfCanonical_rank_regular_deg_thirty` (rank `≥ 44` on every
simple `30`-regular graph).

## 6. OEIS

The sequence `m(m+3)/2` for `m ≥ 0` is `0, 2, 5, 9, 14, 20, 27, 35, 44, …`, the
"pentagonal-like" sequence [A000096](https://oeis.org/A000096)
(`n(n+3)/2`).  It is now proved to be *exactly* the rank of the constant divisor
`m` on every complete graph with `n ≥ m + 2` vertices.  The half-canonical maxima
`0, 0, 2, 2, 5, 5` of §1 are the terms of A000096 each repeated twice; that
pattern is Conjecture 1 below.

## 7. The half-canonical theta characteristic of `K_{2m+3}`

For odd `n = 2m + 3` the constant divisor `m` satisfies `2D = K` exactly, has
degree `g − 1`, and now has *known* rank `m(m+3)/2`:

| `m` | `n = 2m+3` | `k = n−1` | `g` | rank `r` | `k − 1` | `4r − g` |
|----|----|----|----|----|----|----|
| 1 | 5 | 4 | 6 | 2 | 3 | 2 |
| 2 | 7 | 6 | 15 | 5 | 5 | 5 |
| 3 | 9 | 8 | 28 | 9 | 7 | 8 |
| 4 | 11 | 10 | 45 | 14 | 9 | 11 |
| 5 | 13 | 12 | 66 | 20 | 11 | 14 |

✅ Formalised: `thetaChar_halfCanonical_K_odd`,
`rank_thetaChar_K_odd_ge_regularity` (`r ≥ k − 1`, strict from `m ≥ 3`) and
`four_mul_rank_gt_genus_K_odd` (`4r > g`, i.e. the rank is asymptotically a
*quarter of the genus* — the Brill–Noether heuristic `r ≈ √g` fails by a whole
order of magnitude on complete graphs).
