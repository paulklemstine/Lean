# Computational Evidence — tropical windowed decoding trade-off

All numbers below were produced by `#eval` in Lean 4 (exact rational arithmetic, `ℚ`)
against the project's toolchain. They are *exploratory* evidence gathered before and
while formalising; the theorems themselves are proved in
`Catalog/Tropical/DecodingTradeoff/` with no `sorry` and no `native_decide`.

---

## 1. The Bernoulli failure probability: is the interpolation bound correct and how tight?

Environments are all `2^n` strings in `{true, false}^n` (`true` = the step is
*informative*). `exact` is the exact Bernoulli(p) probability of the event
"some run of `b` consecutive uninformative steps", computed by brute-force enumeration;
`union` is the interpolation upper bound `(n+1-b)·(1-p)^b` (`windowFail_prob_le`);
`lower` is `(1-p)^b` (`prob_failSet_ge`).

Sanity check: the total weight over all `2^6` environments evaluates to `1`
(this is `Prob_univ`).

### p = 1/2, n = 8

| b | exact | union bound | lower bound |
|---|---|---|---|
| 1 | 255/256 ≈ 0.99609 | 4 | 1/2 |
| 2 | 201/256 ≈ 0.78516 | 7/4 = 1.75 | 1/4 |
| 3 | 107/256 ≈ 0.41797 | 3/4 = 0.75 | 1/8 |
| 4 | 3/16 = 0.1875 | 5/16 = 0.3125 | 1/16 |
| 5 | 5/64 ≈ 0.07813 | 1/8 = 0.125 | 1/32 |
| 6 | 1/32 = 0.03125 | 3/64 ≈ 0.04688 | 1/64 |
| 7 | 3/256 ≈ 0.01172 | 1/64 ≈ 0.01563 | 1/128 |

### p = 3/4, n = 10

| b | exact | union bound | lower bound |
|---|---|---|---|
| 1 | 989527/1048576 ≈ 0.94369 | 5/2 | 1/4 |
| 2 | 25441/65536 ≈ 0.38820 | 9/16 = 0.5625 | 1/16 |
| 3 | 3149/32768 ≈ 0.09610 | 1/8 = 0.125 | 1/64 |
| 4 | 22495/1048576 ≈ 0.02145 | 7/256 ≈ 0.02734 | 1/256 |
| 5 | 19/4096 ≈ 0.00464 | 3/512 ≈ 0.00586 | 1/1024 |
| 6 | 1/1024 ≈ 0.00098 | 5/4096 ≈ 0.00122 | 1/4096 |
| 7 | 13/65536 ≈ 0.00020 | 1/4096 ≈ 0.00024 | 1/16384 |
| 8 | 5/131072 ≈ 0.00004 | 3/65536 ≈ 0.00005 | 1/65536 |
| 9 | 7/1048576 | 1/131072 | 1/262144 |

### Counterexample hunt

Exhaustive check of `lower ≤ exact ≤ union` for **every** `1 ≤ b < n` and
`n ∈ {4, 6, 8, 10}` at `p ∈ {1/5, 1/2, 3/4}` — all `true`, no counterexample.

**Reading.** The union bound is *asymptotically tight in the exponent*: for large `b` the
ratio `exact / union` approaches `p` (e.g. at `p = 3/4`, `b = 8`: `0.7999…`), matching the
heuristic `exact ≈ (n-b+1)·p·(1-p)^b`. The lower bound `(1-p)^b` and the upper bound
`(n+1-b)(1-p)^b` differ only by the polynomial factor, which is exactly the gap
quantified by `window_lower_bound_of_reliable` versus `window_upper_bound_sufficient`
(an additive `log n / log(1/(1-p))` in the window length).

---

## 2. The absorption theorem and the tropical noise floor

Random `3 × 3` min-plus chains with integer entries in `[0, scale]`, row-normalised so
that each row minimum is `0` (`Stochastic`).

* **Absorption.** For 240 random (seed, window-length) pairs we compared
  `spanSemi (windowApply A 0 k v)` with `min_{i < k} diam (A i)`. The predicate
  `span ≤ min diam` evaluated to `true` in **every** case — the computational form of
  `spanSemi_windowApply_le_diam`.

  Sample (seed varying, `scale = 5`, `v = (0, 17, 41)`), as `(span, min diam)`:

  ```
  (2,2)  (0,4)  (0,3)  (0,3)  (0,2)  (0,2)  (0,3)  (0,2)
  ```

* **Noise floor / non-decay.** For one fixed chain (seed 11, `scale = 4`) the span after
  `k = 1, …, 10` steps is

  ```
  3, 1, 1, 1, 1, 1, 0, 0, 0, 0
  ```

  The span is nonincreasing (`spanSemi_windowApply_le`) but *plateaus*: it stays at `1`
  for `k = 2, …, 6` and only drops when a genuinely informative matrix (here one of
  diameter `0`) enters the window. There is no geometric decay in `k`. This is exactly
  the phenomenon isolated and proved in closed form by `tropicalNoiseFloor`, where the
  two-state chain of diameter `d` has span identically `d` for every `k ≥ 0`.

**Reading.** Tropical algebra alone gives *one-step absorption to the diameter*, never
geometric memory loss. Any exponential-in-`b` reliability gain must therefore be
extracted from the probability that the window contains an informative step — which is
precisely how `Core` and `Environment` are combined in `Tradeoff`.

---

## 3. OEIS

The integer sequence `#{ω ∈ {0,1}^n : ω contains a run of b consecutive 0s}` at `b = 2`
equals `2^n - F_{n+2}` (Fibonacci, OEIS A000045), giving 0, 1, 3, 8, 19, 43, … for
`n = 1, 2, 3, …`; the run-free counts are the Fibonacci numbers themselves.
Our formalisation does not use this exact enumeration — the union bound and the single
cylinder bound suffice and generalise to all `b` — but it confirms that the exact
failure probability is *not* a product formula, which is why the sharp constant is
replaced by the two-sided sandwich.
