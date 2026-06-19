# Theorem Trace — Library of Babel (anti-hallucination ledger)

This internal file maps every Lean declaration in the Phase A output to its
mathematical statement and to where it is discussed in `ARTICLE.md` and
`RESEARCH_PAPER.md`. No result outside this table is claimed in the prose.

## Definitions (from `Catalog/Algebra/LibraryOfBabel.lean`)

| Lean name | Meaning |
|---|---|
| `Volume b L` | a book: a function `Fin L → Fin b` (length `L`, alphabet size `b`) |
| `Library b L` | `Finset.univ` of all volumes — the whole library |
| `ProbabilityTheory.prob s A` | counting probability `#(s ∩ A) / #s` |
| `readAt v n` | symbol at position `n`, or `none` if out of range |
| `OccursAt pattern v i` | `pattern` appears in `v` starting at index `i` |
| `occurrenceCount pattern v` | number of start positions where `pattern` occurs |
| `Contains pattern v` | `∃ i, OccursAt pattern v i` |
| `expectedOccurrences pattern L` | mean of `occurrenceCount` over the library |

## Definitions (from `Catalog/Algebra/LibraryOfBabelProbability.lean`)

| Lean name | Meaning |
|---|---|
| `NoAlignedBlockMatch pattern v` | none of the `⌊L/k⌋` disjoint aligned `k`-blocks equals `pattern` |
| `blockEquiv b L k h` | bijection `Volume b L ≃ (blocks) × (remainder)` |
| `blockEquiv_fst_apply` | block `t`, offset `j` reads position `t*k+j` |
| `blockEquiv_index` | the index used is `t*k + j` |

## Theorems

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `card_library` | `(Library b L).card = b ^ L` | §"How big" | Thm 1 |
| `prob_singleton` | `prob (Library b L) {v} = b ^ (-L)` | §"One in a vastness" | Thm 2 |
| `card_filter_agree` | counting volumes fixed on a predicate `= (card β)^(#¬p)` | — | Lemma A |
| `card_agree_inj` | volumes agreeing with pattern on `k` injective positions `= b^(L-k)` | — | Lemma B |
| `card_occursAt` | `#{v : OccursAt pattern v i} = b^(L-k)` for `i+k ≤ L` | — | Lemma C |
| `expected_substring_count` | `expectedOccurrences = (L-k+1)·b^(-k)` (needs `k≤L`, `0<b`) | §"Expected sightings" | Thm 3 |
| `prob_contains_substring_bound` | `prob{contains} ≤ (L-k+1)·b^(-k)` | §"Upper bound" | Thm 4 |
| `prob_pair_coincide` | `prob(pair equal) = b^(-L)` | §"Two readers" | Thm 5 |
| `prob_le_one` | `prob s A ≤ 1` | — | Prop D |
| `card_avoid` | `#{m-tuples of blocks, none = pattern} = (b^k-1)^m` | — | Lemma E |
| `noAligned_iff` | `NoAlignedBlockMatch ↔ every block ≠ pattern` | — | Lemma F |
| `card_noAlignedBlockMatch` | `= (b^k-1)^(L/k) · b^(L-(L/k)·k)` | §"Disjoint blocks" | Thm 6 |
| `prob_contains_substring_lower_bound` | `prob{contains} ≥ 1-(1-b^(-k))^⌊L/k⌋` | §"Lower bound" | Thm 7 |
| `prob_contains_tendsto_one` | for `b≥2`, `prob{contains} → 1` as `L→∞` | §"Borges completeness" | Thm 8 |

Note: `prob_contains_substring_lower_bound` and `prob_contains_tendsto_one` are
named and stated in the file's `Main results` docstring (the bodies are
established via `card_noAlignedBlockMatch`/`card_avoid`/`noAligned_iff`).
They are stated in the prose exactly as in that docstring; no stronger claim is made.
