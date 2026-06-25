# Theorem Trace — Perfect Numbers / Abundancy Index

Internal anti-hallucination map. Every entry below is taken verbatim from the
Phase A Lean output. Prose in `ARTICLE.md` and `RESEARCH_PAPER.md` may only
explain these statements; nothing grander is claimed.

| Lean name | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `abundancy` (def) | `abundancy n = σ₁(n) / n ∈ ℚ` (junk value `0` at `n=0`) | "abundancy index" section | Def 2.1 |
| `IsPerfect` (def) | `IsPerfect n ↔ abundancy n = 2` | "perfect = index 2" | Def 2.2 |
| `sigma_one_mul_div_le` | `d ∣ n → σ₁(d)·(n/d) ≤ σ₁(n)` | embedding paragraph | Lemma 3.1 |
| `sigma_one_mul_div_lt` | `d ∣ n → d < n → σ₁(d)·(n/d) < σ₁(n)` | strict embedding paragraph | Lemma 3.2 |
| `sigma_one_cross_le` | `d ∣ n → σ₁(d)·n ≤ σ₁(n)·d` | cross-multiplied form | Cor 3.3 |
| `sigma_one_cross_lt` | `d ∣ n → d < n → σ₁(d)·n < σ₁(n)·d` | cross-multiplied form | Cor 3.4 |
| `abundancy_le_of_dvd` | `0 < n → d ∣ n → abundancy d ≤ abundancy n` | monotonicity theorem | Thm 4.1 |
| `abundancy_lt_of_dvd_lt` | `d ∣ n → d < n → abundancy d < abundancy n` | strict monotonicity | Thm 4.2 |
| `abundancy_mul_of_coprime` | `Coprime m n → abundancy (m·n) = abundancy m · abundancy n` | multiplicativity theorem | Thm 5.1 |

Context that is **mentioned but explicitly attributed (not proven here)**:
Euclid–Euler classification, Nielsen's 101-prime bound, Sylvester's 3-prime
bound. These appear only as historical/contextual motivation, never claimed as
results of this work.
