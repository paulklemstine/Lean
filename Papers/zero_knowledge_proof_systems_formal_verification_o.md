# Computational Evidence — GMW Graph 3-Colouring Zero-Knowledge Proof

This note records the small-case checks that motivated the formal theorems in
`Graph3ColoringSimulator.lean` and `Graph3ColoringAmplification.lean`.

## 1. Perfect HVZK: the view map is a bijection on `S₃`

For a challenged edge with distinct endpoint colours `a ≠ b`, the honest prover
opens `(π a, π b)` for a uniform `π ∈ S₃`. The relevant counts:

* `|S₃| = 6`.
* Number of ordered pairs `(x, y)` with `x, y ∈ {0,1,2}` and `x ≠ y` is
  `3 · 2 = 6`.

Enumerating all six permutations of `{0,1,2}` with `a = 0, b = 1`:

| π (as image of 0,1,2) | (π 0, π 1) |
|-----------------------|------------|
| 0 1 2                 | (0, 1)     |
| 0 2 1                 | (0, 2)     |
| 1 0 2                 | (1, 0)     |
| 1 2 0                 | (1, 2)     |
| 2 0 1                 | (2, 0)     |
| 2 1 0                 | (2, 1)     |

Every distinct pair occurs **exactly once**, so the pushforward of the uniform
distribution on `S₃` is the uniform distribution on the six distinct pairs, each
with probability `1/6`. This is exactly `perfect_hvzk_apply`, and the identity of
distributions is `perfect_hvzk_dist`. The table also shows the distribution is the
same whatever `(a,b)` are (relabelling permutes rows), which is
`hvzk_colour_independence`.

## 2. Soundness gap and amplification

Take the triangle `K₃` with `|E| = 3`. Any colouring with only 2 colours of the
three vertices must repeat a colour on some edge (pigeonhole), so at least one of
the three edges is "caught". One-round acceptance probability is therefore at most
`(3 - 1)/3 = 2/3 = 1 - 1/|E|`, matching `roundAcceptProb_le_one_sub`.

Geometric decay of `p ^ k` for `p = 2/3`:

| rounds k | (2/3)^k ≈ |
|----------|-----------|
| 1        | 0.667     |
| 5        | 0.132     |
| 10       | 0.0173    |
| 20       | 0.000301  |
| 40       | 9.1e-8    |

The sequence visibly tends to `0`, matching `soundness_amplification`; for any
`ε > 0` a finite `k` drops below it (`soundness_amplification_exists`).

## 3. Counterexample hunt

* **Does colour-independence need `a ≠ b`?** Yes. If `a = b` the opened pair is
  `(π a, π a)`, never a distinct pair; the map is not onto distinct pairs. The
  hypothesis is load-bearing (kept in every theorem).
* **Does `roundAcceptProb < 1` hold without improperness?** No: a proper colouring
  has every edge uncaught, so `p = 1` and there is no decay. The improperness
  hypothesis is essential and is exactly what feeds `soundness_catch_card`.

No counterexamples to the stated (hypothesis-guarded) theorems were found.
