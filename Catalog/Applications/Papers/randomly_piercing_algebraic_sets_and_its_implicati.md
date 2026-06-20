# Theorem Trace (internal anti-hallucination ledger)

Source of truth: the Phase A Lean file
`Catalog/Computation/AutomaticSequences.lean`
(namespace `Catalog.AutomaticSequences`).

Every name below appears in the Lean output. The article/paper state only these.

| Lean name | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `DFAO` (structure) | A deterministic finite automaton with output: data `(q0 : Q)`, `(step : Q → Fin k → Q)`, `(out : Q → α)`. | yes (the "machine") | Def. 1 |
| `DFAO.run` | `run M w = w.foldl M.step M.q0`, the state reached after reading word `w`. | yes | Def. 2 |
| `DFAO.eval` | `eval M w = M.out (M.run w)`, the output produced by `w`. | yes | Def. 2 |
| `DFAO.run_nil` | `run M [] = q0`. | implicit | Lemma (run basics) |
| `DFAO.run_concat` | `run M (w ++ [c]) = step (run M w) c`. | implicit | Lemma (run basics) |
| `DFAO.Reachable` (inductive) | Smallest predicate with `q0` reachable and closed under `step _ c`. | yes | Def. 3 |
| `DFAO.reachable_run` | every `run M w` is `Reachable`. | yes | Prop. 4 |
| `DFAO.reachable_iff_exists_word` | `Reachable q ↔ ∃ w, run M w = q`. | yes | Prop. 4 |
| `DFAO.expand` | `expand S = S ∪ ⋃_{q∈S} { step q c : c }`. | yes (BFS round) | Def. 5 |
| `DFAO.subset_expand` | `S ⊆ expand S`. | implicit | Lemma 6 |
| `DFAO.step_mem_expand` | `q ∈ S → step q c ∈ expand S`. | implicit | Lemma 6 |
| `DFAO.reach` | `reach 0 = {q0}`, `reach (n+1) = expand (reach n)`. | yes | Def. 5 |
| `DFAO.reach_mono` | `m ≤ n → reach m ⊆ reach n`. | implicit | Lemma 7 |
| `DFAO.mem_reach_imp_reachable` | `q ∈ reach n → Reachable q`. | implicit | Lemma 7 |
| `DFAO.reach_stable` | if `reach (n+1) = reach n` then `reach m = reach n` for all `m ≥ n`. | yes | Lemma 8 |
| `DFAO.reach_card_ge` | if no stabilization before `n`, then `n+1 ≤ (reach n).card`. | yes | Lemma 9 |
| `DFAO.exists_reach_stable` | `∃ n ≤ Fintype.card Q, reach (n+1) = reach n`. | yes | Thm. 10 (termination) |
| `DFAO.reachSet` | `reachSet = reach (Fintype.card Q)`, a guaranteed fixed point. | yes | Def. 11 |
| `IsKAutomatic` (def, from overview) | `f : ℕ → α` is `k`-automatic: `∃ DFAO M, encode, ∀ n, f n = M.eval (encode n)`. | yes | Def. 12 |
| `IsKAutomatic.range_finite` | a `k`-automatic sequence has finite range. | yes (main) | Thm. 13 |
| `DFAO.decidableOccurs` | for fixed `M`, `a`, "`∃ w, eval M w = a`" is decidable via finite search. | yes | Thm. 14 |
| `Unary.eventuallyPeriodic` | `n ↦ out (step^[n] q0)` for a unary (`k=1`) automaton is eventually periodic. | yes | Thm. 15 |
| `IsKAutomatic.not_of_range_infinite` | infinite range ⇒ not `k`-automatic. | yes | Cor. 16 |
| `not_isKAutomatic_id` | `n ↦ n` is not `k`-automatic for any `k`. | yes (punchline) | Cor. 16 |

Notes:
- Names listed in the Lean overview as "Main results" (`IsKAutomatic.range_finite`,
  `DFAO.decidableOccurs`, `Unary.eventuallyPeriodic`,
  `IsKAutomatic.not_of_range_infinite`, `not_isKAutomatic_id`) are stated exactly
  as the overview describes them; no statement is strengthened or renamed.
- The provided Lean excerpt is truncated after `reachSet`; the trailing results are
  described per the file's own "Main results" overview, with no invented content.
