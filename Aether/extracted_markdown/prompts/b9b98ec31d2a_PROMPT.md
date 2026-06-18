Complete one coherent sorry-filling task in `Catalog/Bridges/SpeciesTropicalValuation.lean` and remove all unrelated pasted material. Do not attempt the full advertised bridge. Focus only on the additive side.

Target theorem:
- `ordEGF_add_min_le (F G) : min (ordEGF F) (ordEGF G) ≤ ordEGF (Species.add F G)`

To support this theorem, you may introduce and prove only the minimal auxiliary declarations actually needed:
1. A concrete definition of `Species.add` as disjoint union of structures.
2. The induced counting/EGF identity for this sum construction, e.g. a theorem `EGF_add` stating that the generating function of `Species.add F G` is the sum of the generating functions of `F` and `G`.
3. Any tiny helper lemmas about orders of formal power series under addition that are already standard in the imported algebra/power-series API.

Requirements:
- Use the existing species/EGF setup from the catalog rather than inventing a parallel framework.
- Prefer imported lemmas from the verified catalog and Mathlib over reproving general facts.
- Keep the file tightly scoped: no structural product theorem, no set-species or linear-order-species theorem, and no unrelated material.
- The final Lean file must compile sorry-free.
- If a theorem name from the original draft is too ambitious or mismatched to the available API, rename it slightly, but keep the mathematical content exactly: `ordEGF` of a species sum is bounded below by the minimum of the summands' orders.

The research paper/result should clearly state the exact theorem proved, the definitions used, and why this is the additive half of the species-to-tropical valuation bridge.