# Theorem Trace (internal anti-hallucination ledger)

Source of truth: Phase A Lean output, file
`Catalog/Algebra/LibraryOfBabelProbability.lean`, namespace `LibraryOfBabel`.
Every result stated in `ARTICLE.md` and `RESEARCH_PAPER.md` maps to one of the
declarations below. No theorem is invented or renamed into a grander claim.

## Definitions

| Lean name | Statement | Used in ARTICLE.md | Used in RESEARCH_PAPER.md |
|---|---|---|---|
| `Volume b L` | `Fin L → Fin b`, a length-`L` word over `b` symbols | yes (§"A book is a function") | yes (Def. 1) |
| `Library b L` | `Finset.univ : Finset (Volume b L)`, all volumes | yes | yes (Def. 2) |
| `ProbabilityTheory.prob s A` | `|{x∈s : x∈A}| / |s|`, uniform counting measure | yes | yes (Def. 3) |
| `readAt v n` | symbol at position `n`, `Option (Fin b)` | yes | yes (Def. 4) |
| `OccursAt pattern v i` | `∀ j, readAt v (i+j) = some (pattern j)` | yes | yes (Def. 5) |
| `occurrenceCount pattern v` | `#{i ∈ range (L-k+1) : OccursAt pattern v i}` | yes | yes (Def. 6) |
| `Contains pattern v` | `∃ i, OccursAt pattern v i` | yes | yes (Def. 7) |
| `expectedOccurrences pattern L` | `(∑ v, occurrenceCount) / |Library|` | yes | yes (Def. 8) |

## Theorems / lemmas

| Lean name | Statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `card_library` | `|Library b L| = b ^ L` | yes (Result 1) | yes (Thm 1) |
| `prob_singleton` | `prob (Library b L) {v} = b ^ (-L)` | yes (Result 2) | yes (Thm 2) |
| `card_filter_agree` | `#{v : α→β | ∀a, p a → v a = g a} = (card β)^(#{a | ¬p a})` | mentioned | yes (Lemma 1) |
| `card_agree_inj` | along an injective family of `k` positions, `#{v | ∀j, v(φ j)=pattern j} = b^(L-k)` | mentioned | yes (Lemma 2) |
| `card_occursAt` | `#{v | OccursAt pattern v i} = b^(L-k)` for `i+k ≤ L` | yes | yes (Lemma 3) |
| `expected_substring_count` | `expectedOccurrences pattern L = (L-k+1)·b^(-k)` for `k≤L`, `0<b` | yes (Main result) | yes (Thm 4, main) |
| `prob_contains_substring_bound` | `prob (Library) {v | Contains pattern v} ≤ (L-k+1)·b^(-k)` | yes (Result 4) | yes (Thm 5) |

Note: `prob_contains_substring_bound` appears truncated in the supplied Phase A
listing; its statement (union bound) is reproduced exactly as declared.
