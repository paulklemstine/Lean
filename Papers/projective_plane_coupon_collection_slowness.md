# Computational Evidence — Projective-Plane Coupon Collection Slowness

**Claim under test.** For every prime power `q ≥ 2`, with `n = q² + q + 1`, the
expected time to collect all `n` coupons under the *projective-plane line*
mechanism (each draw a uniformly random line, a `(q+1)`-subset of points)
strictly exceeds the expected coverage time under the *uniform `(q+1)`-subset*
mechanism on the same ground set.

The expected cover time of a covering process with single-draw avoid-probability
`p_A` (probability a draw misses the set `A`) is
`E = Σ_{∅ ≠ A ⊆ points} (-1)^{|A|+1} / (1 - p_A)`.

## 1. Small-case calculations (exact rationals)

### q = 2 (Fano plane, n = 7), verified in `FanoEvidence.lean`
Singer model: points `ZMod 7`, lines `{i, i+1, i+3}`. Uniform draws over the
`C(7,3) = 35` triples.

| mechanism | exact E | decimal |
|-----------|---------|---------|
| plane (lines) | `163/30`        | `5.43333…` |
| uniform       | `85691/15810`   | `5.41999…` |

Gap `Eplane − Eunif = 163/30 − 85691/15810 ≈ 0.01334 > 0`. **Plane is slower.**
Closed exactly by `native_decide` (`fano_slowness`).

### q = 3 (PG(2,3), n = 13)
Singer model: points `ZMod 13`, perfect difference set `{0,1,3,9}`, lines
`{i, i+1, i+3, i+9}`. Uniform draws over the `C(13,4) = 715` quadruples.

`Eplane − Eunif = 17406919738 / 1188702356765 ≈ 0.01464 > 0`. **Plane is slower.**
(Verified by exact ℚ evaluation of the `2^13 − 1 = 8191`-term inclusion–exclusion
sum; reproducible by the same construction as the `q = 2` file.)

These match the literature's reported computational support for `q = 3, 4, 5`.

## 2. The structural mechanism (proved generally in `Slowness.lean`)

Per-configuration plane avoid-probabilities, and the uniform value, as functions
of `q` (denominator `n = q²+q+1`):

| configuration | plane avoid-count | plane prob | uniform prob (same order) |
|---|---|---|---|
| point      | `q²`       | `q²/n`        | `q²/n`        (equal) |
| pair       | `q² − q`   | `(q²−q)/n`    | `(q²−q)/n`    (equal) |
| collinear triple | `q² − 2q` | `(q²−2q)/n` | — |
| generic triple   | `(q−1)²`  | `(q−1)²/n`  | — |
| any triple (uniform) | — | — | `q²(q²−1)(q²−2) / [n(n−1)(n−2)]` |

Key verified facts:

* **Mean matching (`meanMatch`).** Averaged over all `k`-subsets, the plane
  avoid-probability equals the uniform value, for every `k`. (Binomial identity
  `C(n,k)·C(n−k,q+1) = C(n,q+1)·C(n−(q+1),k)`.)
* **Orders 1–2 agree exactly (`match1`, `match2`).** Every point and every pair
  is geometrically equivalent, so the two mechanisms have *identical*
  contributions at orders 1 and 2.
* **Order 3 diverges (`slowness3`).** Collinear and generic triples have
  *distinct* probabilities (they differ by exactly one line:
  `(q−1)² − (q²−2q) = 1`) with the *same mean* as uniform. By strict convexity
  of `x ↦ 1/(1−x)` (`jensen2`), the plane's order-3 contribution is strictly
  larger — slower — for every `q ≥ 2`.

Number of collinear triples: `n·C(q+1,3)`; generic triples: clean factorization
`#generic = n·q³(q+1)/6` (used inside the proof of `slowness3`).

## 3. Counterexample hunt

No counterexample to the slowness claim was found:

* `q = 2, 3`: full inclusion–exclusion `E` computed exactly; plane strictly
  slower in both.
* All orders `k ≤ 2`: contributions provably equal (no possible reversal there).
* Order `k = 3`: contribution provably strictly favours the plane for all
  `q ≥ 2`.

The obstruction to a general proof is the **alternating tail** (orders `k ≥ 4`):
the order-3 surplus must dominate the signed higher-order differences. This is
exactly where the problem remains open.

## 4. OEIS / sequence notes

* `n = q² + q + 1` for prime powers `q = 2,3,4,5,7,8,9,…` gives
  `7, 13, 21, 31, 57, 73, 91, …` — the projective-plane point counts
  (orders of `PG(2,q)`; cf. OEIS A002061-type quadratic forms restricted to
  prime powers).
* Line/point degree `q + 1 = 3, 4, 5, 6, …`.
* The exact gap numerators/denominators above are not (yet) catalogued; the
  decimal gaps `≈ 0.0133 (q=2), 0.0146 (q=3)` are mildly increasing in this
  range, a small but persistent positive signal.
