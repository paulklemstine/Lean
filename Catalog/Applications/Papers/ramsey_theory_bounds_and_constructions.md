# Theorem Trace (internal anti-hallucination ledger)

Every claim in ARTICLE.md and RESEARCH_PAPER.md maps to one of the following
declarations from the Phase A Lean source `Catalog/FINAL/Ramsey.lean`
(namespace `RamseyTheory`). No result outside this list is asserted as proved.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `ArrowsType` | abbrev | Type of red/blue colourings of `K_{s+t}` = `SimpleGraph (Fin (s+t))` | yes (informal) | yes (Def. 2) |
| `Arrows` | def | `Arrows n s t`: every 2-colouring of any vertex set `W` with `|W| ≥ n` has a red `s`-clique or blue `t`-clique (`n → (s,t)`) | yes | yes (Def. 3) |
| `Arrows.mono` | thm | `Arrows n s t → n ≤ n' → Arrows n' s t` | yes (monotonicity) | yes (Prop. 4) |
| `arrows_step` | thm | `0<m, 0<n, Arrows m s (t+1), Arrows n (s+1) t ⊢ Arrows (m+n) (s+1) (t+1)` | yes | yes (Thm. 6, key step) |
| `arrows_one_red` | thm | `Arrows 1 1 b` | yes (base case) | yes (Lemma 5a) |
| `arrows_one_blue` | thm | `Arrows 1 a 1` | yes (base case) | yes (Lemma 5b) |
| `arrows_recursion` | thm | `Arrows ((s+t).choose s) (s+1) (t+1)`, i.e. `R(s+1,t+1) ≤ C(s+t,s)` | yes (main bound) | yes (Thm. 7) |
| `arrows_binomial_bound` | thm | restatement of `arrows_recursion` | yes | yes (Cor. 8) |
| `arrows_three_three` | thm | `Arrows 6 3 3` (`C(4,2)=6`) | yes | yes (Thm. 9 upper) |
| `pentagon` | def | `C₅` = `SimpleGraph.fromRel (fun a b => a+1=b)` on `Fin 5` | yes | yes (Def. 10) |
| `pentagon_no_triangle` | thm | no red triangle in `pentagon` | yes | yes (Lemma 11a) |
| `pentagon_compl_no_triangle` | thm | no blue triangle in `pentagonᶜ` | yes | yes (Lemma 11b) |
| `not_arrows_five_three_three` | thm | `¬ Arrows 5 3 3`, i.e. `R(3,3) > 5` | yes | yes (Thm. 9 lower) |

Combined consequence (stated, not a separate Lean name): `arrows_three_three`
together with `not_arrows_five_three_three` gives `R(3,3) = 6`.

Results mentioned in the concept brief but NOT proved in the Lean source —
`R(3,4)=9`, `R(4,4)=18`, the diagonal probabilistic bound, Hales–Jewett — are
discussed only as background or future work, never claimed as theorems here.
