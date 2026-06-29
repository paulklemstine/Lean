# Theorem Trace — Linear twin-width bound for finite posets of bounded width

This internal trace lists every Lean name from the Phase A output that the
packaging documents are allowed to reference, its mathematical meaning, and the
places it is stated in `ARTICLE.md` and `RESEARCH_PAPER.md`. No result outside
this table is claimed in the prose.

| Lean name | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `posType_mono` | Threshold monotonicity: along any chain `C`, the predicate "`c < x`" is downward closed and "`x < c`" is upward closed in `c`; the relationship of a fixed element `x` to the chain changes monotonically across at most two thresholds. | "the monotone engine" section | Def. of position type; Lemma `posType_mono` |
| `incomp_ord_convex` | For a fixed `x` and chain `C`, the set `{c ∈ C : x ∥ c}` of chain elements incomparable to `x` is order-convex (a single interval of the chain). | "one block of fog" paragraph | Lemma `incomp_ord_convex` |
| `nbhdTypeCount_le` | Under a cover of the poset by `k` chains, each element exhibits at most `2k+1` distinct red neighbourhood types induced by the strict order relation. | main-result statement | Theorem `nbhdTypeCount_le` (main static bound) |
| `antichain_card_le_chains` | A cover of the poset by `k` chains forces every antichain to have size at most `k` (the easy/pigeonhole direction of Dilworth's theorem). | "counting argument" paragraph | Theorem `antichain_card_le_chains` |

## Scope discipline (anti-hallucination)

* The **proved** content is the *static* neighbourhood-type bound
  (`nbhdTypeCount_le`, `≤ 2k+1`) together with the pigeonhole link
  (`antichain_card_le_chains`), built on the monotonicity engine
  (`posType_mono`) and the order-convexity lemma (`incomp_ord_convex`).
* The **dynamic** statement "twin-width `≤ 2k+1`" (a contraction sequence whose
  every part keeps red degree `≤ 2k+1`) is presented as the motivating
  conjecture (Future Direction C1), NOT as a proved theorem. The prose marks it
  as such.
* The deep direction of Dilworth (width `≤ k` ⟹ a `k`-chain cover exists) is
  Future Direction C2 and is likewise marked conjectural.
