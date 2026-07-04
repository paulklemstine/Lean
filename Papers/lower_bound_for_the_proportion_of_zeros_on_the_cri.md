# Computational Evidence — Critical-line proportion for PGL(3) twists

## Object under study
For a self-dual cuspidal automorphic representation `Π₀` of `PGL₃(𝔸_ℚ)` and a Dirichlet
character `χ` of conductor `Q`, we study the proportion

    p(Q) = #{zeros of L(s, Π₀ × χ) on Re s = 1/2 in the analysed box} / #{all zeros in the box}.

The mollifier method reduces a lower bound on `p(Q)` to two mollified moments
`M₁ = Σ w_i` (first moment, real, supported on detected on-line zeros) and `M₂ = Σ w_i²`
(second moment). The elementary core is the Cauchy–Schwarz inequality
`M₁² ≤ (#on-line) · M₂`.

## 1. The Cauchy–Schwarz core (small cases)
Take an analysed set of `N` zeros with weights `w` supported on the on-line subset `S`.
`(Σ_S w)² ≤ |S| · Σ_S w²` is Cauchy–Schwarz with the constant vector `1`.

| weights on S            | (Σw)² | Σw² | forced |S| ≥ (Σw)²/Σw² |
|-------------------------|-------|-----|----------------------------|
| (1)                     | 1     | 1   | 1                          |
| (1,1)                   | 4     | 2   | 2                          |
| (2,1)                   | 9     | 5   | 1.8 → 2                    |
| (1,1,1)                 | 9     | 3   | 3                          |
| (3,0,...) supported off | 9     | 9   | 1                          |

All rows satisfy the inequality with equality exactly when the nonzero weights are equal —
the standard Cauchy–Schwarz equality case.

## 2. The `1/9` constant
`1/9 = 1/d²` with degree `d = 3` for GL(3) (the twist `Π₀ × χ` has degree `3·1 = 3`).
The moment inequality `M₁² ≥ (1/9)·M₂·N` then gives `#on-line ≥ N/9`, i.e. `p(Q) ≥ 1/9`.

Sanity check of satisfiability: with `w ≡ 1` on `S = total` of size `N`, the inequality
`N² ≥ N³/9` holds iff `N ≤ 9`, and then indeed `p = 1 ≥ 1/9`. More realistically the analytic
input provides `M₁², M₂` at the correct sizes so the inequality holds for all large `Q`; here we
only test that the deduction is non-vacuous, which the explicit witness `total = {0,1}`,
`onLine = {0}`, `w = 𝟙₀` confirms: `M₁² = 1 ≥ (1/9)·1·2 = 2/9`.

## 3. Aggregation over the twist family
The number of twists mod `Q` is `φ(Q)` (Euler totient), which grows without bound along, e.g.,
primes `Q = p` where `φ(p) = p − 1`. First terms of `φ`: 1, 1, 2, 2, 4, 2, 6, 4, 6, 4, 10, …
(OEIS A000010). An average of `φ(Q)` ratios each `≥ 1/9` is `≥ 1/9`, so the pooled proportion over
the whole family is also `≥ 1/9`.

## Counterexample hunt
No counterexample to the *deduction* exists (Cauchy–Schwarz is unconditional). The only way the
conclusion could fail is if a hypothesis fails — precisely the deep analytic estimate on `M₁, M₂`,
which is why it is retained as a hypothesis rather than asserted.
