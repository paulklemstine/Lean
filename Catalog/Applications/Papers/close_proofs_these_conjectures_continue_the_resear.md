# Theorem Trace (internal anti-hallucination record)

Every claim in `ARTICLE.md` and `RESEARCH_PAPER.md` must map to a real Lean
declaration in the Phase A output. This file lists each declaration, its
mathematical content, and where it is used in the prose.

## From `Catalog/Shared/CarmichaelHelper.lean`

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `fib_primitive_divisor_prime` | For prime `n ≥ 13`, there is a prime `p` with `p ∣ F(n)` and `p ∤ F(k)` for all `0 < k < n`. | Yes (main theorem, plain language + example F(13)=233) | Yes (Theorem 1, full statement + proof sketch) |

## From `Catalog/Shared/CarmichaelProof.lean`

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `bridge_lemma` | If `p ∣ F(n)` and `p ∤ F(d)` for every proper divisor `d` of `n`, then `p ∤ F(k)` for every `0 < k < n`. | Yes (the "divisor-to-all" step, prose) | Yes (Lemma 2) |
| `stripAllAux` (def) | Bounded-fuel routine repeatedly dividing `r` by `gcd(r, m)` to remove all prime factors shared with `m`. | Implicit (algorithm prose) | Yes (Definition, algorithm) |
| `propDivs` (def) | List of proper divisors `d` of `n` with `0 < d < n`. | Implicit | Yes (Definition) |
| `primPart` (def) | Primitive part of `F(n)`: start from `F(n)`, strip all factors shared with `F(d)` for each proper divisor `d`. | Yes (prose) | Yes (Definition) |
| `stripAllAux_dvd` | `stripAllAux r m fuel ∣ r`. | No | Yes (Lemma) |
| `stripAllAux_coprime` | With enough fuel, `gcd(stripAllAux r m fuel, m) = 1`. | No | Yes (Lemma) |
| `primPart_dvd` | `primPart n ∣ F(n)`. | Yes (prose) | Yes (Lemma 3) |
| `primPart_coprime_proper_divs` | If `primPart n > 1`, its least prime factor divides no `F(d)` for proper divisor `d`. | No | Yes (Lemma) |
| `primPart_implies_primitive` | For `n ≥ 3` with `primPart n > 1`, `F(n)` has a primitive prime divisor. | Yes (prose) | Yes (Lemma 4) |
| `primPart_check` | For every `n ∈ [13, 10000]`, either `n` is prime or `primPart n > 1` (verified by computation). | Yes (the computational sweep) | Yes (Proposition 5) |
| `fib_carmichael_composite` | For composite `n` with `13 ≤ n ≤ 10000`, `F(n)` has a primitive prime divisor; the unbounded tail is stated but left open. | Yes (status note) | Yes (Theorem 6 + honest status) |

## Key external identity used (Mathlib)

| Lean name | Statement |
|---|---|
| `Nat.fib_gcd` | `F(gcd m n) = gcd(F m, F n)`. |
| `Nat.exists_prime_and_dvd` | Any `m ≠ 1` has a prime divisor. |
| `Nat.not_dvd_of_pos_of_lt` | If `0 < k < n` then `¬ n ∣ k`. |

## Honesty note
`fib_primitive_divisor_prime` is fully proved. The composite case is
verified by computation for `13 ≤ n ≤ 10000` (`primPart_check`,
`fib_carmichael_composite`); the infinite tail `n > 10000` remains an open
`sorry` in the source and is reported as such — never as completed.
