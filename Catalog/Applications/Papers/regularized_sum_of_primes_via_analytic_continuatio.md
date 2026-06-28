# Theorem Trace (internal anti-hallucination ledger)

Every result mentioned in `ARTICLE.md` and `RESEARCH_PAPER.md` is traced back to
an exact Lean name from the Phase A output. No theorem is invented, renamed into a
grander claim, or stated beyond what the Lean source proves.

## Source files
- `Catalog/Novelty/PrimeZetaAbscissa.lean`
- `Catalog/Novelty/PrimeZetaRegularizationBridge.lean`
- `Catalog/Novelty/BoundedGaps.lean` (companion, namespace `TwinPrimeGaps`)

## Definitions

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `primeZeta` | `primeZeta s = ∑' p : Nat.Primes, (p : ℝ) ^ (-s)` (the real prime zeta function `P(s)`) | "the prime zeta function" | Def. 2.1 |
| `TwinPrimeGaps.primeGap` | `primeGap n = nth Nat.Prime (n+1) - nth Nat.Prime n` | "prime gap" | Def. 2.2 |

## Theorems / lemmas

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `primeZeta_summable_iff` | `Summable (fun p : Nat.Primes => (p:ℝ)^(-s)) ↔ 1 < s` | "the threshold is exactly 1" | Thm. 3.1 |
| `primeZeta_not_summable_of_le_one` | `s ≤ 1 → ¬ Summable (fun p => (p:ℝ)^(-s))` | "diverges everywhere on `s ≤ 1`" | Thm. 3.2 |
| `primeZeta_not_summable_one` | `¬ Summable (fun p => (p:ℝ)^(-(1:ℝ)))` (Euler: `∑ 1/p` diverges) | "Euler's divergence of `∑ 1/p`" | Cor. 3.3 |
| `primeZeta_not_summable_neg_one` | `¬ Summable (fun p => (p:ℝ)^(-(-1:ℝ)))` (`∑ p` diverges) | "the sum of all primes point" | Cor. 3.4 |
| `primeZeta_pos` | `1 < s → 0 < primeZeta s` | "strictly positive where it converges" | Prop. 3.5 |
| `primeZeta_abscissa_eq_nat_zeta` | `Summable (fun p => (p:ℝ)^(-s)) ↔ Summable (fun n:ℕ => (n:ℝ)^(-s))` | "same abscissa as the full zeta series" | Thm. 3.6 |
| `riemannZeta_neg_one_eq` | `riemannZeta (-1) = -1/12` | "ζ(−1) = −1/12" | Thm. 4.1 |
| `prime_zeta_boundary_vs_zeta_regularization` | prime series diverges at `s=-1` yet `ζ(-1) = -1/12` | "the dichotomy" | Thm. 4.2 |
| `bounded_gaps_and_prime_zeta_divergence` | under bounded-gaps hypothesis, prime zeta still diverges at `s=-1` | "bounded gaps do not help" | Thm. 5.1 |
| `next_prime_after_two_le_three` | concrete reuse: next prime after 2 is ≤ 3 | (omitted, minor) | Remark 5.2 |
| `TwinPrimeGaps.liminf_primeGap_le_246` | Maynard–Tao: `liminf primeGap ≤ 246` | "primes within 246" | Thm. 5.3 |
| `TwinPrimeGaps.next_prime_le_of_prime_lt` | next prime after `p` ≤ `q` when `p<q` both prime | (omitted) | Lemma 5.4 |

## Claims explicitly NOT made (kept honest)
- We do NOT claim `P(s)` is analytically continued to `s = -1`. The Lean source
  proves the opposite obstruction (divergence). Continuation to the critical
  strip and the natural boundary are stated only as *conjectures* (future work).
- We do NOT assign a finite "regularized sum of all primes." We state the
  physically-motivated *question* and prove the rigorous obstruction.
