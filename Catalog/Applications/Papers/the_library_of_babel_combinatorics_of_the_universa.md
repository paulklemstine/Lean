# Theorem Trace (internal anti-hallucination record)

Source of truth: `Catalog/Algebra/LibraryOfBabelProbability.lean`
(namespace `LibraryOfBabel`). Every claim in `ARTICLE.md`,
`RESEARCH_PAPER.md`, and `RESEARCH_PAPER.tex` must map to an entry here.

## Definitions

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `Volume b L` | `Fin L → Fin b`: a length-`L` string over a `b`-symbol alphabet | yes | yes (Def. 1) |
| `Library b L` | `Finset.univ : Finset (Volume b L)`: all volumes | yes | yes (Def. 2) |
| `ProbabilityTheory.prob s A` | `|{x∈s : x∈A}| / |s|`: uniform counting probability | yes | yes (Def. 3) |
| `readAt v n` | symbol at position `n`, or `none` if `n ≥ L` | yes | yes (Def. 4) |
| `OccursAt pattern v i` | `∀ j, readAt v (i+j) = some (pattern j)`: pattern occurs at offset `i` | yes | yes (Def. 4) |
| `occurrenceCount pattern v` | number of offsets `i ∈ [0, L-k]` where `OccursAt` holds | yes | yes (Def. 5) |
| `Contains pattern v` | `∃ i, OccursAt pattern v i` | yes | yes (Def. 4) |
| `expectedOccurrences pattern L` | `(∑ v, occurrenceCount pattern v) / |Library b L|` | yes | yes (Def. 5) |

## Theorems / Lemmas

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `card_library` | `(Library b L).card = b ^ L` | yes (main) | yes (Thm 1) |
| `card_filter_agree` | `#{v : α→β | ∀ a, p a → v a = g a} = (card β)^(#{a | ¬ p a})` | — | yes (Lem 1) |
| `card_agree_inj` | for injective `φ : Fin k → Fin L`, `#{v | ∀ j, v (φ j)=pattern j} = b^(L-k)` | — | yes (Lem 2) |
| `card_occursAt` | for `i+k ≤ L`, `#{v | OccursAt pattern v i} = b^(L-k)` | yes | yes (Lem 3) |
| `prob_singleton` | `prob (Library b L) {v} = b^(-L)` | yes (main) | yes (Thm 2) |
| `expected_substring_count` | for `k ≤ L`, `0 < b`: `expectedOccurrences = (L-k+1)·b^(-k)` | yes (main) | yes (Thm 3) |
| `prob_contains_substring_bound` | for `k ≤ L`: `prob {v | Contains pattern v} ≤ (L-k+1)·b^(-k)` | yes (main) | yes (Thm 4) |

## Borges constants (from concept; used as a worked instance, not a theorem)
- alphabet size `b = 25`, length `L = 1312000`, library size `25^1312000`.

No theorem is stated in the prose that is absent from the table above.
