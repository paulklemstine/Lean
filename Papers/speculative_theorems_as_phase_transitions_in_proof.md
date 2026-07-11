# Computational Evidence — Theorems as Phase Transitions in Proof Space

The formalized results are analytic/combinatorial identities and limits rather
than empirical conjectures, so "evidence" here means sanity-checking the closed
forms and asymptotics that the Lean theorems prove.

## 1. Counting statements (`Counting.lean`)

`S k n = ∑_{i=0}^{n} k^i` counts statements of length `≤ n` over a `k`-symbol
alphabet.  First values for `k = 2` and `k = 3`:

| n | S 2 n | 2^{n+1}-1 | S 3 n | (3^{n+1}-1)/2 |
|---|-------|-----------|-------|----------------|
| 0 | 1     | 1         | 1     | 1              |
| 1 | 3     | 3         | 4     | 4              |
| 2 | 7     | 7         | 13    | 13             |
| 3 | 15    | 15        | 40    | 40             |
| 4 | 31    | 31        | 121   | 121            |

This confirms the closed form `(k-1)·S k n = k^{n+1} - 1` (`S_closed_form`), the
bounds `k^n ≤ S k n ≤ k^{n+1}` (`pow_le_S`, `S_le_pow`), and exponential growth
`2^n ≤ S k n` (`S_ge_two_pow`).  `S 2 n = 2^{n+1}-1` is OEIS A000225 (Mersenne
numbers `2^n - 1`, shifted).

## 2. Order parameter / asymptotic incompleteness (`OrderParameter.lean`)

With `tot n = k^n` and provable count `prov n = C·a^n`, the order parameter
`r n = prov n / tot n = C·(a/k)^n`.  For `k = 3`, `a = 2`, `C = 1`:

| n | r n = (2/3)^n |
|---|----------------|
| 0 | 1.000 |
| 5 | 0.132 |
| 10| 0.017 |
| 20| 0.0003 |

`r n → 0`: provable statements have density zero (`orderParameter_tendsto_zero`).

## 3. Sharp phase transition (`PhaseTransition.lean`)

Logistic profile `Φ β x = 1/(1+exp(-β(x-x_c)))`, `x_c = 0`.  Value at `x = 0.5`
as sharpness `β` grows, versus `x = -0.5`:

| β   | Φ(0.5) | Φ(-0.5) | Φ(0) |
|-----|--------|---------|------|
| 1   | 0.622  | 0.378   | 0.5  |
| 5   | 0.924  | 0.076   | 0.5  |
| 20  | 0.99995| 0.00005 | 0.5  |

The profile pins at `1/2` at criticality (`logistic_critical`) and converges to a
Heaviside step: `→1` above, `→0` below (`logistic_tendsto_one/zero`).

## 4. Dimension and length distribution (`Dimension.lean`)

`dim = lim log(tot n)/n = log k`.  For `k=2`, `log(S 2 n)/n` approaches
`log 2 ≈ 0.6931`:

| n  | log(S 2 n)/n |
|----|--------------|
| 5  | 0.826 |
| 20 | 0.727 |
| 100| 0.700 |

Length distribution `p(n) = (k-1)/k^{n+1}` for `k=2` is `p(n)=1/2^{n+1}`
(`1/2, 1/4, 1/8, …`), summing to `1` (`lengthDist_tsum`).  Its geometric
`k^{-n}` tail is the predicted power law in the length variable.

## 5. Counterexample hunt

- `S_closed_form`, `S_le_pow`, `S_ge_two_pow`: checked for all `k ∈ {2..6}`,
  `n ∈ {0..8}` — no counterexample.
- `orderParameter_tendsto_zero`: requires `a < k`; at `a = k` the ratio is the
  constant `C`, so the hypothesis `a < k` is necessary (not a counterexample, a
  sharp boundary).
- `logistic` limits require `x ≠ x_c`; exactly at criticality the value is the
  constant `1/2` for every `β`, consistent with `logistic_critical`.

No counterexamples were found; all sampled cases match the proved statements.
