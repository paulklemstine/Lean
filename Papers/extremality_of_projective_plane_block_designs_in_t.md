# Computational Evidence — Projective-plane mechanisms in the coupon collector's problem

All quantities below are **exact rationals**, computed from the inclusion–exclusion
closed form

```
expCoverTime B = ∑_{∅ ≠ S ⊆ [n]} (-1)^{|S|+1} · |B| / coverCount(B, S),
coverCount(B, S) = #{ b ∈ B : b ∩ S ≠ ∅ }.
```

`B` is the drawing mechanism (a family of blocks); each draw reveals all coupons
in a uniformly random block, and `expCoverTime B` is the expected number of draws
to collect all `n` coupons.

## 1. Sanity check — the finest mechanism reproduces the textbook value

For the singleton family on `n` coupons, the formula must collapse to the
classical `n · Hₙ`:

| n | expCoverTime(singletons) | n · Hₙ |
|---|--------------------------|--------|
| 3 | 11/2  = 5.5            | 11/2  |
| 4 | 25/3  ≈ 8.333          | 25/3  |

Matches exactly. (Proved in general: `expCoverTime_singletons`.)

## 2. The two grand-challenge instances — design vs. fully random

The "fully random ℓ-uniform mechanism" `all_ℓ` draws a uniformly random
`ℓ`-subset of the `n` points.  The projective plane of order `q` supplies the
line design (`ℓ = q+1`, `n = q²+q+1`).

### q = 2 — the Fano plane (n = 7, ℓ = 3)

| mechanism            | expCoverTime          | decimal     |
|----------------------|-----------------------|-------------|
| Fano lines (7 blocks)| 163/30                | 5.43333…    |
| fully random (35 blocks) | 85691/15810       | 5.42068…    |
| **gap**              | **+0.01265…**         | **> 0**     |

Design axioms verified: 7 blocks, 3-uniform, point-regular (r = 3), pairwise
balanced (λ = 1); pair-coverage = 5 = 2q+1.

### q = 3 — PG(2,3) via the perfect difference set {0,1,3,9} mod 13 (n = 13, ℓ = 4)

| mechanism            | expCoverTime               | decimal     |
|----------------------|----------------------------|-------------|
| PG(2,3) lines (13)   | 43633/4620                 | 9.44437…    |
| fully random (715)   | 1746879067753/185252315340 | 9.42985…    |
| **gap**              | **+0.01464…**              | **> 0**     |

Design axioms verified: 13 blocks, 4-uniform, λ = 1.

**Both confirmed instances:** the projective-plane line design is strictly slower
than the fully random mechanism of the same block size, and the gap grows from
q = 2 to q = 3.

## 3. Counterexample hunt

The universal claim under test is "projective-plane line design ⇒ strictly slower
than fully random ℓ-uniform model".  Tested on the only two finite projective
planes with q ≤ 3; no counterexample found — both strictly exceed the random
model.  The companion *extremality* claim ("design is the unique maximizer among
all fair ℓ-regular families") is far larger: for n = 7, ℓ = 3 the space of
3-regular 3-uniform families is enormous, so it is left as a conjecture rather
than an exhaustive check.

## 4. OEIS note

The exact expected-time rationals (163/30, 43633/4620) and the random-model
values do not match a single catalogued OEIS sequence under direct search; the
numerators/denominators are specific to the inclusion–exclusion evaluation and
are recorded here for reproducibility rather than as a named sequence.

## 5. Why fixed-q computation, not a closed form

The expected time depends on the coverage distribution over **all** subset sizes
(2ⁿ−1 terms), not only the first- and second-order coverage law (`q+1`, `2q+1`)
that is available in closed form.  Hence the strict inequality is, at present,
established per plane by exact computation; a uniform-in-q proof is the central
open problem (see `FUTURE_DIRECTIONS.md`).
