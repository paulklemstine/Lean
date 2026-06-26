# Theorem Trace (internal — anti-hallucination ledger)

Every claim in `ARTICLE.md` and `RESEARCH_PAPER.md` maps to one of the Lean
declarations below. No theorem is stated that is not present in the Phase A
output. Results from the concept brief that are NOT in the Lean output
(R(4,4)=18, Hales-Jewett, explicit best-known diagonal lower bounds) are
deliberately NOT claimed as proved; where mentioned at all they appear only as
context/future work.

| Lean name | Source file | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|---|
| `Arrows` | Applications.Ramsey | `n → (s,t)`: every red/blue colouring of a vertex set of size ≥ n has a red s-clique or blue t-clique | yes (informal) | yes (Def 1) |
| `Arrows.mono` | Applications.Ramsey | monotonicity: `Arrows n s t → n ≤ n' → Arrows n' s t` | implicit | yes (Lem) |
| `arrows_step` | Applications.Ramsey | `m→(s,t+1)` and `n→(s+1,t)` imply `(m+n)→(s+1,t+1)` | yes (recursion) | yes (Lem) |
| `arrows_recursion` / `arrows_binomial_bound` | Applications.Ramsey | `C(s+t,s) → (s+1,t+1)`, i.e. `R(s+1,t+1) ≤ C(s+t,s)` | yes | yes (Thm) |
| `arrows_three_three` | Applications.Ramsey | `Arrows 6 3 3` | yes | yes |
| `pentagon`, `pentagon_no_triangle`, `pentagon_compl_no_triangle` | Applications.Ramsey | C₅ has no red/blue triangle | yes | yes |
| `not_arrows_five_three_three` | Applications.Ramsey | `¬ Arrows 5 3 3` | yes | yes |
| `ramsey_three_three` | Applications.Ramsey | `Arrows 6 3 3 ∧ ¬ Arrows 5 3 3` (R(3,3)=6) | yes | yes (Thm) |
| `red_nbrs_sum_even` | Applications.RamseyThreeFour | total red-degree inside W is even (handshake) | yes | yes (Lem) |
| `arrows_three_four` | Applications.RamseyThreeFour | `Arrows 9 3 4` | yes | yes |
| `not_arrows_eight_three_four` | Applications.RamseyThreeFour | `¬ Arrows 8 3 4` (Möbius ladder) | yes | yes |
| `ramsey_three_four` | Applications.RamseyThreeFour | `Arrows 9 3 4 ∧ ¬ Arrows 8 3 4` (R(3,4)=9) | yes | yes (Thm) |
| `redDeg` | Applications.RamseyParity | red-degree of v inside W | yes | yes (Def) |
| `red_degree_parity_obstruction` | Applications.RamseyParity | on odd-card W, not all red-degrees can be odd | yes | yes (Thm) |
| `no_odd_regular_colouring` | Applications.RamseyParity | if n·d odd, no d-regular red colouring on n vertices | yes | yes (Thm) |
| `hyper_ramsey_counting_lower_bound` | Applications.HypergraphRamsey.ProbabilisticBound | if `2·C(n,k) < 2^{C(k,r)}` then `¬ HyperRamseyProp r n k k`; r=2 gives R(k,k) > 2^{k/2} | yes | yes (Thm) |
