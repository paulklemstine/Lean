# THEOREM TRACE (internal anti-hallucination ledger)

Every result below is extracted verbatim from the Phase A Lean output. No result
appears in ARTICLE.md / RESEARCH_PAPER.md that is not in this table.

| Lean name | File | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `Frame` (abbrev) | BoundaryObstruction.lean / IncoherenceIndex.lean | `Frame N := Finset (ZMod N)` — a frame is a finite set of atoms in the cyclic group of order `N` | yes (def "frame") | yes (Def 1) |
| `IsBalanced` | both | `IsBalanced F l := l ≠ [] ∧ (∀ x∈l, x∈F) ∧ l.sum = 0` | yes ("perfectly balanced obstruction") | yes (Def 2) |
| `balancedLengths` | both | `{ k | ∃ l, IsBalanced F l ∧ l.length = k }` | implied | yes (Def 3) |
| `incoherenceIndex` | both | `incoherenceIndex F := sInf (balancedLengths F)` | yes ("incoherence index") | yes (Def 4) |
| `IsMaximal` | both | `IsMaximal F := AddSubgroup.closure (F:Set (ZMod N)) = ⊤` | yes ("maximal frame") | yes (Def 5) |
| `incoherenceIndex_le_addOrderOf` | BoundaryObstruction.lean | for `a ∈ F`, `incoherenceIndex F ≤ addOrderOf a` | yes ("order bound") | yes (Lemma 1) |
| `atoms_generate_of_index_gt_half` | BoundaryObstruction.lean | if `N/2 < incoherenceIndex F` and `a∈F` then `addOrderOf a = N` | yes ("generators-only") | yes (Lemma 2) |
| `addOrderOf_six_eq` | BoundaryObstruction.lean | for `a:ZMod 6`, `addOrderOf a = 6 → a=1 ∨ a=5` | yes (example) | yes (Lemma 3) |
| `boundary_obstruction_k1` | BoundaryObstruction.lean | `¬ ∃ F:Frame 6, IsMaximal F ∧ incoherenceIndex F = 4` | yes (main theorem) | yes (Theorem A) |
| `incoherenceIndex_le` | IncoherenceIndex.lean | for `0<N`, nonempty `F`, `incoherenceIndex F ≤ N` | yes | yes (Lemma 4) |
| `incoherenceIndex_singleton_one` | IncoherenceIndex.lean | for `0<N`, `incoherenceIndex {1} = N` | yes | yes (Lemma 5) |
| `realization_even` | IncoherenceIndex.lean | for even `n≥4`, `∃ F maximal, incoherenceIndex F = n` | yes | yes (Theorem B) |
| `incoherenceIndex_isGreatest` | IncoherenceIndex.lean | `n` is the greatest index over nonempty frames on `n` states | yes | yes (Theorem C) |
| `even_incoherenceIndex` | IncoherenceIndex.lean | all-odd-atom frames over even `n` have even index | mention | yes (Theorem D) |
| `incoherence_unbounded` | IncoherenceIndex.lean | the spectrum of indices is unbounded | mention | yes (Theorem E) |
| `cofinite_realization` (referenced) | CofiniteRealization.lean | realization of index `2k+2` for all sufficiently large electorates (companion file; cited in BoundaryObstruction.lean lab notes) | mention (cofinite) | mention (Discussion) |

Names NOT invented; grander paraphrases avoided. The cofinite companion theorem is
only *cited* (its full statement is in a companion file not reproduced here), so the
paper states only what the reproduced source proves and clearly labels the cofinite
result as a companion citation.
