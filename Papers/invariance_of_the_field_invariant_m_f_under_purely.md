# Theorem Trace (internal anti-hallucination record)

Every claim in ARTICLE.md and RESEARCH_PAPER.md maps to one of the following Lean
declarations from the Phase A output. No other theorems are asserted.

| Lean name | File | Mathematical statement | Article | Paper |
|---|---|---|---|---|
| `InseparableBaseChange.mInvariant` | Invariance.lean | Definition: `m_f := (minpoly K θ).natSepDegree`, the number of distinct roots of the minimal polynomial of θ. | "the separable count" / Def | Definition 3.1 |
| `InseparableBaseChange.mInvariant_base_change` | Invariance.lean | **Main Theorem.** For purely inseparable `N/K` in a common field `M` and `θ ∈ M` algebraic over `K`: `mInvariant N θ = mInvariant K θ`. | Main idea, stated in plain language + Example 1/2 | Theorem 4.1 |
| `InseparableBaseChange.finSepDegree_simple_base_change` | Invariance.lean | Restatement via `Field.finSepDegree`: `finSepDegree N N⟮θ⟯ = finSepDegree K K⟮θ⟯`. | mentioned ("separable degree of the extension") | Corollary 4.2 |
| `InseparableBaseChange.mInvariant_eq_one_iff_isPurelyInseparable` | Criterion.lean | `mInvariant K θ = 1 ↔ IsPurelyInseparable K K⟮θ⟯`. | "m_f = 1 means flat/purely inseparable" | Proposition 5.1 |
| `InseparableBaseChange.isPurelyInseparable_simple_base_change_iff` | Criterion.lean | **Criterion invariance.** `IsPurelyInseparable N N⟮θ⟯ ↔ IsPurelyInseparable K K⟮θ⟯`. | the headline consequence | Theorem 5.2 |
| `InseparableBaseChange.mInvariant_dvd_natDegree` | Criterion.lean | `mInvariant K θ ∣ (minpoly K θ).natDegree`. | "m_f divides the degree" | Proposition 5.3 |
| `InseparableBaseChange.natDegree_minpoly_base_change_of_separable` | Criterion.lean | If `IsSeparable K θ` then `(minpoly N θ).natDegree = (minpoly K θ).natDegree`. | separable case keeps full degree | Theorem 5.4 |

Supporting Mathlib lemmas cited in the proof sketch (named in Invariance.lean docstring):
`Field.finSepDegree_eq`, `IntermediateField.finSepDegree_adjoin_simple_eq_natSepDegree`,
`IntermediateField.sepDegree_adjoin_eq_of_isAlgebraic_of_isPurelyInseparable'`,
`minpoly.map_eq_of_isSeparable_of_isPurelyInseparable`,
`Polynomial.natSepDegree`, `Irreducible.natSepDegree_dvd_natDegree`,
`IntermediateField.isPurelyInseparable_adjoin_simple_iff_natSepDegree_eq_one`.

No theorem is renamed into a grander claim; degree-collapse examples are presented as
*illustrations that the raw degree is not invariant*, consistent with the Lab Notes.
