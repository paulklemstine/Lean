Formalize a complete and self-contained Lean 4 file that cleanly finishes a restricted version of the valuation-depth extremal-families program, using the already existing valuation-depth/tropical infrastructure rather than introducing new detours.

Target file: `Catalog/Bridges/ExtremalValuationFamilies.lean`.

Primary references to build on:
- `Catalog/Bridges/ValuationDepthTropicalFunctor.lean`
- the existing file that defines the recursive balanced/caterpillar tree families and their basic combinatorics, if present in the repository; otherwise reproduce only the minimal definitions needed locally in the new file.

Required scope:
1. Define or import two explicit expression-tree families over a leaf label `k`:
   - `balanced k n`: recursively balanced binary tree with exactly `2^n` leaves.
   - `caterpillar k n`: recursively left- or right-associated chain with exactly `n+1` leaves.
2. Prove exact structural formulas for each family, with theorem names chosen consistently and proofs fully included:
   - `height_balanced`, `numLeaves_balanced`, and the corresponding `maxLeafDepth_balanced` formula.
   - `height_caterpillar`, `numLeaves_caterpillar`, and the corresponding `maxLeafDepth_caterpillar` formula.
   Use the exact conventions already present in the imported infrastructure for `height`, `numLeaves`, and `maxLeafDepth`.
3. Introduce the bound abbreviation
   - `valuationDepthBound X t := maxLeafDepth X.depth t + t.height`
   and prove a specification theorem showing it upper-bounds the evaluated depth, directly from the main theorem already available in `ValuationDepthTropicalFunctor`.
4. Deduce exact closed forms for the two families:
   - `valuationDepthBound_balanced : valuationDepthBound X (balanced k n) = X.depth k + n`
   - `valuationDepthBound_caterpillar : valuationDepthBound X (caterpillar k n) = X.depth k + n`
   or the correct closed forms forced by the actual imported definitions. Be faithful to the definitions; do not assert a formula unless it is exactly derivable.
5. To compare balanced and caterpillar at equal leaf count, introduce a reindexed caterpillar family such as `caterpillarPow k j := caterpillar k (2^j - 1)` and prove:
   - exact leaf count `numLeaves_caterpillarPow`
   - exact valuation-depth formula for `caterpillarPow`
   - comparison theorem `valuationDepthBound X (balanced k j) <= valuationDepthBound X (caterpillarPow k j)`
   - strict inequality for the first genuinely nontrivial range, e.g. `2 <= j -> valuationDepthBound X (balanced k j) < valuationDepthBound X (caterpillarPow k j)`.
6. If the repository already contains map/transport lemmas for these families and they are easy corollaries, you may include one concise transport theorem; otherwise omit transport entirely this cycle.

Important restrictions:
- Do NOT include theorem declarations without proofs.
- Do NOT attempt witness-carrier equality attainment, tropical sharpness, or universal optimality unless the necessary infrastructure is already clearly present and the proof is short. Those were likely the source of the previous overreach.
- Keep the file tightly focused on exact formulas and matched-leaf-count comparison.
- Use only verified dependencies from the catalog where possible, preferring `Catalog/FINAL/` or stable bridge files if available.
- Ensure the final file compiles with no `sorry` and no malformed extraction artifacts.

What to return in the research paper / summary:
- State the precise recursive definitions used.
- State the exact formulas proved for leaves, height, max-leaf-depth, and valuation-depth bound.
- Explain that the balanced family minimizes the bound among these two explicit extremal reassociation families at equal leaf count, with strict separation once the leaf count is at least 4.

The key insight is that the valuation-depth bound becomes completely explicit on these recursively defined families, so the abstract tropical inequality can be converted into a computable extremal comparison theorem. Why now? Because the repository already appears to contain the valuation-depth bridge and at least partial family infrastructure; the missing work is to isolate a smaller, fully provable kernel instead of the previously over-ambitious sharpness package.