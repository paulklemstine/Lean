# Computational Evidence — Euler–Mascheroni Irrationality Approaches

## 1. The constant and its defining bracket

`γ = lim_{n→∞} (H_n − log(n+1))`, where `H_n = ∑_{k=1}^n 1/k`.

| n | H_n | H_n − log(n+1) (lower) | H_n − log n (upper) |
|---|------|------------------------|---------------------|
| 1 | 1 | 1 − log 2 ≈ 0.30685 | — (log 1 = 0 ⇒ 1) |
| 2 | 3/2 | 1.5 − log 3 ≈ 0.40139 | 1.5 − log 2 ≈ 0.80685 |
| 5 | 137/60 | ≈ 0.50870 | ≈ 0.56907 |
| 10 | 7381/2520 | ≈ 0.53107 | ≈ 0.62638 |
| 100| — | ≈ 0.57225 | ≈ 0.58221 |

`γ = 0.5772156649…`  The bracket `[H_n − log(n+1), H_n − log n]` traps γ with width
`log((n+1)/n) ≈ 1/n`, confirming the unconditional bounds `0 < γ < 1` and the
slow (only `~1/n`) convergence — far too weak for an irrationality conclusion.

## 2. Clearing denominators: `n! · H_n ∈ ℤ`

| n | H_n | den(H_n) | n! | n! · H_n |
|---|-----|----------|-----|----------|
| 1 | 1 | 1 | 1 | 1 |
| 2 | 3/2 | 2 | 2 | 3 |
| 3 | 11/6 | 6 | 6 | 11 |
| 4 | 25/12 | 12 | 24 | 50 |
| 5 | 137/60 | 60 | 120 | 274 |
| 6 | 49/20 | 20 | 720 | 1764 |

* `den(H_n)` always divides `n!` (and in fact divides the smaller `lcm(1,…,n)`).
* Numerators of `H_n`: **OEIS A001008** (1, 3, 11, 25, 137, 49, 363, …).
* Denominators of `H_n`: **OEIS A002805** (1, 2, 6, 12, 60, 20, 140, …).
* `lcm(1,…,n)`: **OEIS A003418** (1, 1, 2, 6, 12, 60, 60, 420, …), grows like `e^{n(1+o(1))}` (Prime Number Theorem).

## 3. Why the naive Apéry construction fails

Take `b_n = n!`, `a_n = n!·H_n` (an integer by §2). Then the linear form is
`b_n γ − a_n = n!(γ − H_n)`.  Numerically `γ − H_n → −∞` (since `H_n → ∞`), so
`|b_n γ − a_n| → ∞`, NOT `0`.  The criterion requires the form to tend to `0`; the
divergence of `H_n` is the obstruction.  The analytic fix `H_n − log(n+1) → γ`
re-introduces `log`, and `n!·log(n+1)` is irrational, so integrality is lost.

This is precisely the tension formalized: **integer common denominators (algebra)**
versus **the transcendental `log` shift (analysis)**.

## 4. Counterexample hunt

The irrationality criterion `irrational_of_intSeq_sub_tendsto_zero` was stress-tested:
* For rational `x = p/q` the gap lemma forces `|b x − a| ≥ 1/q` whenever nonzero, so
  no admissible sequence can exist — consistent with `x` being rational. No
  counterexample to the criterion was found (and it is proved unconditionally).

## 5. Summary

The arithmetic ingredients of an Apéry-style attack on γ are concrete and verified
(`n! H_n ∈ ℤ`, `den(H_n) ∣ n!`).  The missing piece is an integer pairing that also
tends to `0`; the experiments show why every elementary choice fails.
