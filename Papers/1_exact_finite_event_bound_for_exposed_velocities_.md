# Computational evidence — idempotent (max-plus) large deviations

All computations below were carried out inside the Lean 4 toolchain with exact rational
arithmetic (`#eval` over `ℚ`), before the corresponding theorems were formalized.
They are *exploratory*: the verified statements are the Lean theorems in
`Catalog/Novelty/MaxPlus*.lean`, which are proved for arbitrary finite laws.

## 1. Test law

A four-point max-plus law on `ι = {0,1,2,3}`:

| increment | value `v` | weight `w` |
|---|---|---|
| 0 | 0 | −1   |
| 1 | 1 | −1/4 |
| 2 | 2 | −1/2 |
| 3 | 3 | 0    |

Note `max w = 0`, so the law is max-plus normalized, and the point `(2, −1/2)` lies
*strictly below* the chord from `(1, −1/4)` to `(3, 0)`: it is a non-exposed increment.
This is exactly the situation where a naive "rate = −weight at the nearest increment"
guess fails, so the law is a good stress test.

## 2. Legendre transform vs. concave-chord optimum (max-plus Cramér)

`I(x) = sup_θ (θx − Λ(θ))` was computed on the tilt grid `θ ∈ {−4, −3.999, …, 4}`
(step `1/1000`, exact rationals) and compared with `−g(x)`, where
`g(x) = max { chord value at x }` ranges over all chords joining an increment at or left
of `x` to one at or right of `x`.

| `x` | 0 | 1/4 | 1/2 | 3/4 | 1 | 5/4 | 3/2 | 7/4 | 2 | 9/4 | 5/2 | 11/4 | 3 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `I(x)` | 1 | 13/16 | 5/8 | 7/16 | 1/4 | 7/32 | 3/16 | 5/32 | 1/8 | 3/32 | 1/16 | 1/32 | 0 |

At **all 13 sample points** the discretized Legendre supremum equalled `−g(x)` exactly
(`legendre x == -chordMax x` returned `true` for every sample).  Two structural facts are
visible in the table and were subsequently proved:

* `I` is piecewise affine and convex, with a kink at `x = 1` — the last exposed increment;
* `I(2) = 1/8`, **not** `1/2 = −w₂`: the non-exposed increment `2` is never optimal, the
  optimal mixture at `x = 2` is the two-point mixture `(1/2, 1/2)` on increments `1` and
  `3`.  This is the two-point optimality principle
  (`MaxPlusLaw.exists_optimal_mixture`).
* `I(3) = 0` and `I` vanishes only there — the unique zero-weight increment
  (`MaxPlusLaw.rate_eq_zero_of_weight_eq_zero`).

## 3. Counterexample hunt for the convex-hull domain conjecture

Computing `sup_{|θ| ≤ R} (θx − Λ(θ))` for growing tilt ranges `R = 10, 100, 1000`:

| `x` | `R = 10` | `R = 100` | `R = 1000` |
|---|---|---|---|
| 7/2  (right of hull) | 5 | 50 | 500 |
| −1/2 (left of hull)  | 6 | 51 | 501 |
| 5/4  (inside hull)   | 0 | 0  | 0   |

The defining family grows linearly in `R` outside `[0,3] = convexHull {0,1,2,3}` and is
stationary inside.  No exterior point with a bounded family, and no interior point with an
unbounded family, was found — consistent with
`MaxPlusLaw.bddAbove_legendreSet_iff_mem_convexHull`, which is now proved in general.

## 4. Accessibility (the arithmetic obstruction)

For the idempotent Bernoulli law (values `0, 1`, weights `−1, 0`, rate `1 − x` on `[0,1]`),
the length-`n` paths realize exactly the velocities `k/n`, `0 ≤ k ≤ n`, with normalized
score `k/n − 1 = −rate(k/n)`.  Hence at *accessible* velocities the pathwise upper bound
is attained with equality for every `n`, while at an irrational velocity such as
`x = 1/√2` no path of any length realizes `x` at all.  This is what forces the
accessibility hypothesis in `maxPlus_LDP_of_accessible_minimizer`, and what makes the
subsequence `n ∈ qℕ` the right index set for the lower bound.

## 5. No OEIS sequence

The objects here are piecewise-affine functions of a real parameter, not integer
sequences, so no OEIS lookup applies.

---

# Addendum (this cycle): the `⌊cn⌋/n` rounding error

The accessibility obstruction of §4 above is what the earlier cycle could not remove.
The new observation is that on an *open* velocity set the obstruction costs only `O(1/n)`,
which is eventually invisible.

Concretely, take the idempotent Bernoulli law and the target velocity
`c = 3/4 − 1/100 = 0.74`, which lies in the open window `(1/4, 3/4)` but is *not* the
minimizer of the rate over that window (the infimum `1/4` is only approached as `x ↑ 3/4`).
The two-block path of length `n` uses `k = ⌊cn⌋` copies of the increment `1`; its
empirical velocity is `t = k/n` and its normalized score is `−(1 − t)`.  Exact-rational
`#eval` inside the toolchain gives the table `(n, t, |t − c|, score)`:

```
(3,     2/3,   11/150, −1/3)
(7,     5/7,    9/350, −2/7)
(10,    7/10,    1/25, −3/10)
(25,   18/25,    1/50, −7/25)
(100,  37/50,       0, −13/50)
(1000, 37/50,       0, −13/50)
(10000,37/50,       0, −13/50)
```

In every row `|t − c| ≤ 1/n`, and the score converges to `−rate c = −(1 − 0.74) = −0.26`.
This is exactly the estimate formalized in
`MaxPlusLaw.le_liminf_eventWeightE_of_isOpen`: `0 ≤ c − ⌊cn⌋/n < 1/n`, so both the
velocity and the score of the approximating two-block path are within `O(1/n)` of their
targets, and openness absorbs the velocity error while the `δ`-slack absorbs the score
error.  No rationality of the increment values is used anywhere.

---

## Addendum (this cycle): local affinity, unimodality, breakpoints

The new theorems of `Catalog/Novelty/MaxPlusRateStructure.lean` say that the rate of a
finite max-plus law is *locally affine* on a chord interval around every hull velocity,
that it is *unimodal* around any typical velocity, and that the optimal mixture at an
exposed velocity is a Dirac mass.  As a check, take the 4-point law

```
value  = [0,  1,  2,  3]
weight = [-3, 0, -1, -2]   (max weight = 0, so the law is normalized)
```

and compute the rate at `x = k/8`, `0 ≤ k ≤ 24`, by maximizing the chord value over all
admissible pairs `(i, j)` with `value i ≤ x ≤ value j`.  Exact-rational `#eval` inside
the toolchain gives

```
x      : 0    1/8   1/4  3/8  1/2  5/8  3/4  7/8  1    9/8  ...  2    ...  3
rate x : 3    21/8  9/4  15/8 3/2  9/8  3/4  3/8  0    1/8  ...  1    ...  2
```

and the consecutive difference quotients are

```
[-3, -3, -3, -3, -3, -3, -3, -3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
```

Three things are visible in this data and are exactly what the new theorems assert.

* **Local affinity / breakpoints.** The difference quotient is constant on `[0,1]` and
  constant on `[1,3]`: the rate is piecewise affine with a single breakpoint, and the
  breakpoint `x = 1` is an increment value — the content of
  `MaxPlusLaw.exists_affine_chord`.  Note that the increment `(2, -1)` lies *on* the
  chord from `(1,0)` to `(3,-2)`, so it produces no breakpoint: the number of pieces is
  governed by the vertices of the upper concave envelope, not by the number of
  increments.
* **Unimodality.** The rate decreases on `[0,1]` and increases on `[1,3]`, with minimum
  `0` attained at `x = 1`, the value of the unique increment of weight `0` — the content
  of `MaxPlusLaw.rate_antitoneOn_left` / `MaxPlusLaw.rate_monotoneOn_right`.
* **Two-point sufficiency.** The whole table was computed by maximizing over *pairs* of
  increments only; it agrees with the mixture optimum at every sampled point, which is
  the content of `MaxPlusLaw.isGreatest_twoPointScores`.

These `#eval` computations are exploratory evidence; the theorems themselves are proved
in Lean without reference to them.
