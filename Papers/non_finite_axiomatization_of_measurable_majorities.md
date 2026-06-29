# Theorem Trace (internal — anti-hallucination ledger)

Source of truth: Phase A Lean output for
`Catalog/Applications/SocialChoice/OrderSpectrum.lean`, with shared model and
companion results reproduced from `IncoherenceIndex.lean` and
`NonFiniteAxiomatization.lean`.

Every name below appears in the Lean output. No result outside this table is
asserted in ARTICLE.md or RESEARCH_PAPER.md.

| Lean name | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `Frame` (def) | A frame on `n` states is a finite set `F ⊆ ZMod n`. | Yes (the "frame") | Def 1 |
| `IsBalanced` (def) | `l` balanced for `F`: `l ≠ []`, all entries in `F`, `l.sum = 0`. | Yes ("balanced sequence") | Def 2 |
| `balancedLengths` (def) | `{ k | ∃ l, IsBalanced F l ∧ l.length = k }`. | Yes (implicit) | Def 3 |
| `incoherenceIndex` (def) | `sInf (balancedLengths F)` (`0` if none). | Yes (the index) | Def 4 |
| `IsMaximal` (def) | `AddSubgroup.closure (F) = ⊤`. | Yes ("maximal") | Def 5 |
| `isMaximal_singleton_one` | `{1} ⊆ ZMod n` is maximal. | Yes | Lemma 1 |
| `list_mem_singleton_eq_replicate` | A list with all entries `= a` is `replicate len a`. | implicit | Lemma 2 |
| `incoherenceIndex_singleton` | `incoherenceIndex {a} = addOrderOf a`. | Yes (main theorem) | Thm 1 (Order Formula) |
| `incoherenceIndex_singleton_one'` | `incoherenceIndex {1} = n`. | Yes (special case) | Cor 1 |
| `balancedLengths_mono` | `F ⊆ G ⟹ balancedLengths F ⊆ balancedLengths G`. | implicit | Lemma 3 |
| `incoherenceIndex_antitone` | `F ⊆ G`, `balancedLengths F` nonempty `⟹ incoherenceIndex G ≤ incoherenceIndex F`. | Yes (saturation law) | Thm 2 (Saturation Law) |
| `every_index_realized_maximal` | For every `d ≥ 2`, some maximal frame has index `d`. | Yes (spectrum) | Thm 3 |
| `divisor_index_realized` | On `ZMod n`, every divisor `d ≥ 2` of `n` is a singleton index. | Yes | Thm 4 |
| `incoherenceIndex_oneTwo_zmod5` | `incoherenceIndex ({1,2} ⊆ ZMod 5) = 3` (3 ∤ 5). | Yes (the escape) | Thm 5 |

Companion (catalog) results referenced for context only:
`incoherenceIndex_singleton_one`, `incoherenceIndex_le`,
`realization_2k2`, `coherence_not_finitely_axiomatizable`,
`incoherenceIndex_oneThree` (`{1,3} ⊆ ZMod 4` has index `2`).
