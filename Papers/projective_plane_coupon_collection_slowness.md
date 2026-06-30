# Computational Evidence — Projective-Plane Coupon Collection Slowness

We study, for a prime power `q ≥ 2` and `n = q²+q+1`, two coupon-collection
mechanisms on the `n` points of the projective plane of order `q`:

* **plane** — draw a uniformly random *line* (a `(q+1)`-subset);
* **uniform** — draw a uniformly random `(q+1)`-subset.

Expected cover time (inclusion–exclusion):
`E(B) = Σ_{∅ ≠ S} (-1)^{|S|+1} · |B| / (#blocks of B meeting S)`.

The claim under test: `E(plane) > E(uniform)` for every `q ≥ 2`.

## 1. Small-case calculation: q = 2 (Fano plane), n = 7, block size 3

Computed exactly over all `127` nonempty subsets of the `7` points
(`FanoDisproof.lean`, evaluated in ℚ):

| mechanism                  | blocks | E (exact)        | E (decimal) |
|----------------------------|:------:|------------------|-------------|
| plane (Fano `7` lines)     |  7     | `163/30`         | `5.43333…`  |
| uniform (all `35` triples) | 35     | `85691/15810`    | `5.42005…`  |

Gap `E(plane) − E(uniform) = 7/527 ≈ 0.01328 > 0`.

**Conclusion (q = 2):** the plane mechanism is strictly slower. This is the
disproof of the Grünbaum–Yaakobi conjecture, here against the *correct* uniform
`(q+1)`-subset baseline (not against singletons).

### Order-by-order breakdown (why the gap is so small)

* **Order 1 (single points).** Each Fano point lies on `3` lines; a uniform
  triple contains a given point with the matching marginal. Contributions equal.
* **Order 2 (pairs).** Every pair of Fano points lies on a *unique* line, so a
  pair is met by `3+3−1 = 5` lines; the uniform marginal matches. Contributions
  equal.
* **Order ≥ 3 (triples and up).** The Fano family meets a *collinear* triple
  with `7` lines but a *generic* triple with `6`; the uniform family is flat.
  This spread, fed through the strictly convex `x ↦ 1/(1−x)`, is the entire
  source of the `7/527` gap. (Formalized in general in `Engine.lean`:
  `match1`, `match2`, `slowness3`, `slowness_through_order3`.)

## 2. Mean-matching identity (all q, all orders)

For every `k` the plane avoid-probability *averaged over all `k`-subsets* equals
the uniform avoid-probability, because of the binomial identity
`C(n,k)·C(n−k, q+1) = C(n, q+1)·C(n−(q+1), k)` (`Engine.choose_choose_comm` /
`Engine.meanMatch`). So the two mechanisms are indistinguishable at the level of
size-averaged marginals; the difference is *pure variance*, present from order 3
onward.

## 3. Counterexample hunt

No counterexample to `E(plane) > E(uniform)` is expected, and none was found:

* `q = 2` is verified exactly (above), confirming `>`.
* The structural engine (`Engine.slowness_through_order3`) shows the *signed
  truncation through order 3* is strictly larger for the plane for **every**
  `q ≥ 2` — there is no `q` at which orders 1–3 fail to favour the plane.
* The literature reports numerical confirmation for `q = 3, 4, 5`.

The only way the full claim could fail is via the alternating tail (orders ≥ 4)
overturning the order-3 surplus — not observed for any tested `q`.

## 4. Sequence note

The exact `q = 2` plane value `163/30` equals `Σ` of the Fano inclusion–exclusion
and is *not* `7·H₇ = 363/20` (the singleton/coupon-collector value); the latter
is the comparison made in `Catalog.Combinatorics.CouponCoverFramework` and is a
*different* (block-size `1`) problem. No OEIS match was pursued for the rational
cover-time sequence `163/30, …` as the denominators are design-specific.

## Reproduction

All numbers above are reproduced by the `#eval`/`native_decide` computations in
`FanoDisproof.lean` and proved as lemmas there (`expCoverTime_fano`,
`expCoverTime_uniform`, `fano_slower_than_uniform`, `fano_uniform_gap`).
