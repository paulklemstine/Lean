# Computational Evidence — Sharp Threshold Constant `c_k` for the `C_k`-game

We study the Bednarska–Łuczak / Chvátal–Erdős threshold constant

    c_k = [ (k-1) · (2(k-1)/k)^{k-2} ]^{1/(k-1)},

which governs the threshold bias `c_k · n^{(k-2)/(k-1)}` of the Maker–Breaker
`C_k`-game on `K_n`.

## 1. Small-case values of `c_k`

Computed in floating point (`c_k = base^{1/(k-1)}` with `base = (k-1)(2(k-1)/k)^{k-2}`):

| k  | c_k     |
|----|---------|
| 4  | 1.88988 |
| 5  | 2.01189 |
| 6  | 2.07622 |
| 7  | 2.11233 |
| 8  | 2.13327 |
| 9  | 2.14550 |
| 10 | 2.15246 |
| 11 | 2.15612 |
| 12 | 2.15766 |
| 13 | 2.15780 |  ← peak
| 14 | 2.15701 |
| 15 | 2.15561 |
| 20 | 2.14479 |
| 100 | 2.05981 |
| 1000 | 2.01047 |

**Observations.**
- `c_k` is **not monotone**: it increases from `k=4`, peaks near `k=12–13`
  (value ≈ 2.1578), then decreases.
- `c_k → 2` as `k → ∞` (consistent with `(2(k-1)/k)^{k-2} ≈ 2^{k-2} e^{-1}`,
  giving `c_k ≈ [(k-1)2^{k-2}/e]^{1/(k-1)} → 2`).
- Uniformly, `3/2 ≤ c_k < 3` for all `k ≥ 4`; in fact `c_k < 2.16`.

## 2. The average-degree factor `2(k-1)/k`

| k | 2(k-1)/k |
|---|----------|
| 4 | 1.5 |
| 5 | 1.6 |
| 6 | 1.6667 |
| 7 | 1.7143 |

This factor is strictly increasing, equals `3/2` at `k=4`, and stays in `(1, 2)`.
These two bracketing facts are exactly what drive the uniform bounds
`3/2 ≤ c_k < 3`.

## 3. Uniform-bound certificate

The lower bound `c_k ≥ 3/2` uses `2(k-1)/k ≥ 3/2` (⟺ `k ≥ 4`) and `k-1 ≥ 3/2`,
so `c_k^{k-1} = (k-1)(2(k-1)/k)^{k-2} ≥ (3/2)^{k-1}`.

The upper bound `c_k < 3` uses `2(k-1)/k < 2` and the exponential-vs-linear
inequality `(k-1)·2^{k-2} < 3^{k-1}` (verified by induction; base case `k=4`
gives `12 < 27`), so `c_k^{k-1} < (k-1)2^{k-2} < 3^{k-1}`.

## 4. Counterexample hunt

- Claim "`c_k` monotone increasing": **FALSE** — refuted at `k=13→14`
  (2.15780 → 2.15701). Hence any theorem must state boundedness, not monotonicity.
- Claim "`c_k < 2` for all k": **FALSE** — refuted at `k=5` (2.0119).
- Claim "`3/2 ≤ c_k < 3` for all `k ≥ 4`": no counterexample found in
  `4 ≤ k ≤ 10^4`; proved formally.

## 5. OEIS

`c_k` is a transcendental-valued sequence (roots of powers), not an integer
sequence, so no OEIS entry applies. The rational average-degree factors
`2(k-1)/k` are `3/2, 8/5, 5/3, 12/7, ...` (numerators/denominators unremarkable).
