# Computational Evidence — GL(2) Triple Correlation Sums (v19d)

All computations below were run inside the project with exact rational arithmetic
(`ℚ`), modelling the local Hecke eigenvalues by the Chebyshev recurrence

```
chebU x 0 = 1,  chebU x 1 = 2x,  chebU x (k+2) = 2x·chebU x (k+1) − chebU x k,
```

which is exactly the Hecke three-term recurrence with `λ(p) = 2x = 2 cos θ`, so
`chebU (cos θ) k = λ(p^k) = U_k(cos θ)`.

## 1. Local eigenvalues and the Deligne bound `|λ(p^k)| ≤ k+1`

**Satake angle `θ = π/3` (`cos θ = 1/2`):**
```
[λ(p^0), …, λ(p^7)] = [1, 1, 0, -1, -1, 0, 1, 1]   (period 6)
```
Every entry satisfies `|λ(p^k)| ≤ k+1`; the sequence is bounded by `1`, far below the
envelope. This is the generic, oscillating regime.

**Satake angle `θ = π/4` (`cos θ ≈ 0.7071`):**
```
[1, 1.4142, 0.99996, -0.000054, -1.00004, -1.4142, …]
```
again well inside the envelope, with sign changes.

**Degenerate angle `θ = 0` (`cos θ = 1`):**
```
[λ(p^0), …, λ(p^7)] = [1, 2, 3, 4, 5, 6, 7, 8]   i.e. λ(p^k) = k+1
```
This **attains** the Deligne envelope `d(p^k) = k+1` with equality, for every `k`.

## 2. Triple correlation `T(X,Y) = ∑_{n<X} ∑_{m<Y} λ(n)λ(m)λ(n+m)`

Computed for `X = 5`, `Y = 3`:

| sequence (Satake angle) | `T(5,3)` |
|---|---|
| `θ = 0`  (λ(k) = k+1, all positive) | **450** |
| `θ = π/3` (oscillating signs)        | **6**   |

The `θ = 0` value `450` equals the divisor envelope `∑∑ (n+1)(m+1)(n+m+1)`
exactly — confirming `tripleCorrelation_envelope_sharp`. The oscillating sequence at
`θ = π/3` collapses the same-shape sum from `450` down to `6`: a factor `≈ 75`
of cancellation already at this tiny scale. This is the numerical signature of the
square-root-cancellation phenomenon the mission targets, and it is the empirical reason
the triangle/divisor envelope cannot be the truth for generic `f`.

## 3. Counterexample hunt

- The Deligne bound `|λ(p^k)| ≤ k+1` held on every angle tested (`θ ∈ {0, π/6, π/4,
  π/3, π/2}` and random rationals); the formal proof `GL2Hecke.heckePP_abs_le` confirms
  it for all real `θ` and all `k`.
- The envelope inequality `|T(X,Y)| ≤ ∑∑ (n+1)(m+1)(n+m+1)` held on every angle and every
  `(X,Y)` tested; proved in general as `GL2CorrModel.heckePP_tripleCorrelation_abs_le`.
- The equality case `T = envelope` occurred **only** at `cos θ = ±1` (no oscillation),
  consistent with the formal sharpness result.

## 4. Sequence identification

The `θ = π/3` eigenvalue sequence `1,1,0,-1,-1,0,…` is the period-6 pattern of Chebyshev
`U_k(1/2)` (related to OEIS A010892, the signed period-6 sequence); the `θ = 0` sequence
`1,2,3,4,…` is `U_k(1) = k+1` (OEIS A000027, the naturals shifted). These are the two
boundary regimes (full cancellation vs no cancellation) of the Sato–Tate family.

**Conclusion.** The evidence supports the formalized claims: the divisor envelope is
unconditional and sharp (attained at `θ = 0`), while generic oscillation produces large
cancellation — the open `X^{1/2+ε}Y` bound is the conjectural quantitative form of this
observed collapse.
