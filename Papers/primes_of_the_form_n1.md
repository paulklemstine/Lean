# Theorem Trace — Primes of the Form n² + 1 (internal anti-hallucination ledger)

Every claim made in ARTICLE.md and RESEARCH_PAPER.md traces to one of these
Lean declarations from `Catalog/NumberTheory/NSquaredPlusOneLocal.lean`
(namespace `NSquaredPlusOneLocal`). No theorem outside this list is asserted as
proved.

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `solSet` (def) | `solSet p = {x ∈ ZMod p : x² + 1 = 0}` as a `Finset` | "solution set" | Def 3.1 |
| `mem_solSet` | `x ∈ solSet p ↔ x² + 1 = 0` | implicit | Def 3.1 |
| `solvable_iff` | For prime `p`: `(∃ x : ZMod p, x²+1=0) ↔ p % 4 ≠ 3` | "the divisibility law" | Thm 4.1 |
| `card_solSet_of_ne` | prime `p ≠ 2`, `p % 4 ≠ 3` ⇒ `(solSet p).card = 2` | "two square roots" | Thm 4.2 |
| `card_solSet_of_three` | prime `p`, `p % 4 = 3` ⇒ `(solSet p).card = 0` | "no roots" | Thm 4.2 |
| `legendre_neg_one_eq_one_iff` | prime `p ≠ 2`: `legendreSym p (-1) = 1 ↔ p % 4 = 1` | "Legendre symbol" | Thm 4.3 |
| `legendre_neg_one_eq_neg_one_iff` | prime `p ≠ 2`: `legendreSym p (-1) = -1 ↔ p % 4 = 3` | "Legendre symbol" | Thm 4.3 |
| `not_dvd_of_three_mod_four` | prime `p`, `p % 4 = 3` ⇒ `¬ (p ∣ n² + 1)` | "the great filter" | Thm 5.1 |
| `count_with_bad_prime_factor_eq_zero` | `#{n < X : ∃ p prime, p%4=3, p ∣ n²+1} = 0` | "exactly zero" | Thm 5.2 |
| `nu` (def) | `ν_p(n) = #{x ∈ ZMod p : x²+1=0 ∧ gcd(x.val, n)=1}` | "local density" | Def 6.1 |
| `localFactor` (def) | `localFactor p n = ν_p(n) / p` | "local factor" | Def 6.2 |
| `nu_le_card_solSet` | `ν_p(n) ≤ (solSet p).card` | implicit | Lem 6.3 |
| `nu_le_two` | prime `p ≠ 2` ⇒ `ν_p(n) ≤ 2` | "at most two" | Thm 6.4 |
| `nu_eq_zero_of_three` | prime `p`, `p % 4 = 3` ⇒ `ν_p(n) = 0` | "vanishing factor" | Thm 6.5 |

NOT formalized (explicitly disclaimed, heuristic only): the Landau asymptotic
`#{n ≤ X : n²+1 prime} ~ C · X / √(log X)` and the full singular series
`S = ∏_p ν_p / p`. These appear in prose only as conjecture/context, never as
"proved".

Future-directions names (`oddPrime_dvd_some_sq_add_one`, `landau_base_even`,
`IsSemiprimeValue`, `landauPrime_isFIPrime`, etc.) come from Phase A future work
and are reproduced verbatim only inside PACKAGE.json `future_directions`.
