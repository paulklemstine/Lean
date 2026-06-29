# Theorem Trace (internal — anti-hallucination)

Every result below is extracted verbatim from the Phase A Lean output. Prose in
`ARTICLE.md` and `RESEARCH_PAPER.md` may only state these results.

## File: Catalog/Tropical/ChromaticPolynomial/Brooks.lean (namespace `ChromaticBrooks`)

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `colorable_maxDegree_add_one` | For finite `G`, `G.Colorable (G.maxDegree + 1)` (greedy bound). | yes | Thm 3.1 |
| `chromaticNumber_le_maxDegree_add_one` | `G.chromaticNumber ≤ G.maxDegree + 1`. | yes | Cor 3.2 |
| `maxDegree_completeGraph` | `(⊤ : SimpleGraph (Fin (n+1))).maxDegree = n`. | yes | Lem 3.3 |
| `completeGraph_chromatic_eq_maxDegree_add_one` | `χ(K_{n+1}) = maxDegree + 1`. | yes | Thm 3.4 |
| `maxDegree_cycleGraph` | `(cycleGraph (2m+3)).maxDegree = 2`. | yes | Lem 3.5 |
| `oddCycle_chromatic_eq_maxDegree_add_one` | `χ(C_{2m+3}) = maxDegree + 1 = 3`. | yes | Thm 3.6 |

## File: Catalog/Tropical/ChromaticPolynomial/Counting.lean (namespace `ChromaticPoly`)

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `chromCount` (def) | `chromCount G k` = number of proper colorings of `G` with palette `Fin k`. | yes | Def 2.1 |
| `contractCount` (def) | counts proper colorings of the deletion assigning `u,v` the same color. | yes | Def 2.2 |
| `chromCount_bot` | edgeless graph: `chromCount ⊥ k = k ^ |V|`. | yes | Prop 2.3 |
| `chromCount_top` | complete graph: `chromCount ⊤ k = k.descFactorial |V|`. | yes | Prop 2.4 |
| `chromCount_deletion_contraction` | `chromCount Gdel k = chromCount G k + contractCount Gdel u v k`. | yes | Thm 2.5 |
| `chromCount_eq_zero_iff` | `chromCount G k = 0` iff `G` is not `k`-colorable. | yes | Prop 2.6 |

## NOT in Lean output — do NOT state as proved
- FourColor.lean theorems (file referenced in future directions only; no statements given).
- TropicalBridge.lean theorems `tropical_deletion_contraction_lower/upper`, `log_chromCount_bot_two`
  (referenced in future directions only; full statements not in Phase A output).
- Full Brooks "only these two exceptions" direction — explicitly left to future work (C1).
- Integer-polynomial lift / T-positivity — conjectures C2, C3.

These appear ONLY in the Future Directions section, framed as conjectures.
