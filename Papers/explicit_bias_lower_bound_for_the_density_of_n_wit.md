# Theorem Trace (internal anti-hallucination record)

Source of truth: `Catalog/Applications/CusickDigitReversalDensity.lean` (Phase A),
building on `Catalog/Applications/CusickPeriodicity.lean`,
`Catalog/Applications/CusickDoublingInvariance.lean`,
`Catalog/Applications/CusickSumOfDigits.lean`.

Background context (from concept): the Cusick density
`c_t = lim_{N→∞} (1/N)·#{0 ≤ n < N : s₂(n+t) ≥ s₂(n)}` satisfies the
Drmota–Kauers–Spiegelhofer bias bound `c_t ≥ 1/2 + 2^{-(2 s₂(t)+1)}`.

| Lean name | Statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `s2compute` | `s2compute n = (Nat.digits 2 n).sum`, a computable copy of `s₂` | "computable digit sum" | Def. 2 (computable copy) |
| `s2compute_eq` | `s2compute n = s2 n` | implicit | Def. 2 note |
| `s2_nineteen` | `s₂(19) = 3` | "19 = 10011₂" | Sec. 4 table |
| `s2_twentyfive` | `s₂(25) = 3` | "25 = 11001₂" | Sec. 4 table |
| `s2_twentythree` | `s₂(23) = 4` | "23 = 10111₂" | Sec. 4 table |
| `s2_twentynine` | `s₂(29) = 4` | "29 = 11101₂" | Sec. 4 table |
| `cusickCount_nineteen_base` | `cusickCount 19 256 = 164` | "164 of the first 256" | Lemma 5 |
| `cusickCount_twentyfive_base` | `cusickCount 25 256 = 164` | "same 164" | Lemma 5 |
| `cusickCount_twentythree_base` | `cusickCount 23 512 = 300` | "300 of 512" | Lemma 5 |
| `cusickCount_twentynine_base` | `cusickCount 29 512 = 300` | "same 300" | Lemma 5 |
| `cusickCount_nineteen` | `cusickCount 19 (256·m) = 164·m` | "every block" | Thm 6 |
| `cusickCount_twentyfive` | `cusickCount 25 (256·m) = 164·m` | "every block" | Thm 6 |
| `cusickCount_twentythree` | `cusickCount 23 (512·m) = 300·m` | "every block" | Thm 6 |
| `cusickCount_twentynine` | `cusickCount 29 (512·m) = 300·m` | "every block" | Thm 6 |
| `cusick_density_19_eq_25` | `cusickCount 19 (256·m) = cusickCount 25 (256·m)` (⇒ `c_19 = c_25 = 41/64`) | Main result | Theorem 7 (main) |
| `cusick_density_23_eq_29` | `cusickCount 23 (512·m) = cusickCount 29 (512·m)` (⇒ `c_23 = c_29 = 75/128`) | Main result | Theorem 8 (main) |

Imported supporting results (from `CusickPeriodicity.lean`, used in proofs, stated for context):
- `cusick_periodic` — `P_t(n) ↔ P_t(n mod 2^{L+s₂(t)})` for `t < 2^L`.
- `cusickCount_period` — `cusickCount t (2^{L+s₂(t)}·m) = m · cusickCount t (2^{L+s₂(t)})`.
- `cusickCount` (def in `CusickDoublingInvariance.lean`) — `#{n<N : s₂(n) ≤ s₂(n+t)}`.

No theorem is stated in the prose that is absent from this table.
