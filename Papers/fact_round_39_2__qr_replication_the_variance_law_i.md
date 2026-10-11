# Computational evidence — paper 140 (QR-replication, exp 475)

## 1. Experimental input (reported by exp 475; not re-run here)

| cell | emp_x2 (fresh) | emp_rnd (fresh) | per-N corr fresh | per-N corr orig (exp 471) |
|---|---|---|---|---|
| 1 | 0.12859 | 0.12786 | 0.503 | 0.504 |
| 2 | 0.02004 | 0.02023 | 0.415 | 0.452 |
| 3 | 0.12854 | 0.12585 | 0.480 | 0.483 |
| 4 | 0.02004 | 0.01869 | 0.403 | 0.401 |

Max correlation drift 0.037. Decile low/high: 0.076–0.082 / 0.186–0.188 (u = 2.5),
0.006–0.008 / 0.039–0.043 (u = 3.5). QR-restricted randoms 32–200× lower.
These figures come from the user's experiment log and are quoted, not reproduced.

## 2. Small-case exact enumeration of the formalised laws

A seed is a tuple of `n` uniform draws from `(ℤ/M)ˣ`; `S(x) = ∑ᵢ (r_M(xᵢ) − 1)`,
`t = r_M(1)`. Brute force over **all** seeds (and all seed pairs):

| M | n | φ(M) | t | ∑ S | ∑ S² | predicted `n φⁿ (t−1)` | ∑ (Sx − Sy)² | predicted `2 φⁿ ∑S²` |
|---|---|---|---|---|---|---|---|---|
| 7 | 2 | 6 | 2 | 0 | 72 | 72 | 5184 | 5184 |
| 15 | 2 | 8 | 4 | 0 | 384 | 384 | 49152 | 49152 |
| 7 | 3 | 6 | 2 | 0 | 648 | 648 | 279936 | 279936 |
| 105 | 1 | 48 | 8 | 0 | 336 | 336 | 32256 | 32256 |
| 105 | 2 | 48 | 8 | 0 | 32256 | 32256 | 148635648 | 148635648 |

k-prime score, `M = 105 = 3·5·7`, weights `(3, 1, 2)`:
`∑_N S(N) = 288 = 48·6`, `∑_N (S(N) − 6)² = 672 = 48·14 = φ(M)·(9+1+4)`.

The general identities behind every row are proved in Lean (no `sorry`):
`qr_seed_replication`, `qr_two_seed_drift` (`Catalog/Tropical/QRSeedRobustVariance.lean`) and
`euler_score_crt_mean_variance` (`Catalog/Tropical/QRMultiPrimeScore.lean`); the table itself
was produced by a scratch enumeration and is only a sanity check.

## 3. Counterexample hunt

No deviation found in any enumerated case (all rows exact). OEIS: the sequence of variances
`2^k − 1` is A000225 (Mersenne numbers); nothing further relevant.

## 4. Reading of the drift law against exp 475

The exact law gives mean squared drift `2(2^k − 1)/n` between two sample means of size `n`.
With `n = 10⁵` draws per cell the predicted RMS drift of the *mean local rate* is
`√(2(2^k−1)/10⁵) ≈ 0.0045·√(2^k−1)`, i.e. small compared with the decile gaps quoted above —
consistent with "every headline replicates". (This is an interpretive heuristic: the Lean
statements are about the idealised local-rate statistic, not about smoothness yields.)
