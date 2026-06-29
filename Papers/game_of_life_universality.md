# Theorem Trace (internal — anti-hallucination ledger)

Every claim in `ARTICLE.md` and `RESEARCH_PAPER.md` maps to one of the
declarations below, extracted verbatim from the Phase A Lean source. No
result outside this list is stated as proved.

## Definitions

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `UnionClosedFamily F` | `∀ s t ∈ F, s ∪ t ∈ F` | §"Closed under merging" | Def. 1 |
| `IsUpperSetFamily F` | `∀ s ∈ F, s ⊆ t → t ∈ F` | §"Upward-closed worlds" | Def. 2 |
| `memberCount a F` | `|{s ∈ F : a ∈ s}|` | §"Counting popularity" | Def. 3 |
| `jointCount a b F` | `|{s ∈ F : a ∈ s ∧ b ∈ s}|` | §"Two at a time" | Def. 4 |
| `unionCount a b F` | `|{s ∈ F : a ∈ s ∨ b ∈ s}|` | §"Two at a time" | Def. 5 |
| `unionClosure F` | least union-closed family ⊇ F; sups of nonempty subfamilies | §"Coarse-graining" | Def. 6 |

## Theorems / lemmas

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `sum_memberCount_eq_sum_card` | `∑ a, memberCount a F = ∑ s ∈ F, s.card` | Theorem A | Thm 1 |
| `exists_frequent_element_of_avg_card_ge_half` | `F.Nonempty → 2·∑ s∈F, s.card ≥ F.card·card α → ∃ a, 2·memberCount a F ≥ F.card` | Theorem B | Thm 2 |
| `upset_unionClosed` | `IsUpperSetFamily F → UnionClosedFamily F` | Bridge | Thm 3 |
| `unionCount_eq` | `(unionCount a b F : ℤ) = memberCount a F + memberCount b F − jointCount a b F` | Inclusion–exclusion | Thm 4 |
| `subset_unionClosure` | `F ⊆ unionClosure F` | Coarse-graining | Lem 5 |
| `unionClosure_unionClosed` | `UnionClosedFamily (unionClosure F)` | Coarse-graining | Lem 6 |
| `sum_card_monotone_under_unionClosure` | `∑ s∈F, s.card ≤ ∑ s∈unionClosure F, s.card` | Theorem C | Thm 7 |
| `powerset_nonneg_correlation` | `card (Finset α)·jointCount a b univ ≥ memberCount a univ · memberCount b univ` | Theorem D | Thm 8 |

Notes:
- The proof of `powerset_nonneg_correlation` is truncated in the supplied
  source after establishing the counting lemma
  `|{t : s ⊆ t}| = 2^(card α − card s)`; the statement is complete and
  is what we report.
- Domain recorded as `Novelty` per the concept metadata.
