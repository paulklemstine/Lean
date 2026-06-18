Formalize a small, completely proved bridge file built directly on `Computation/PadicValuationDepth`, with no placeholders and no ambitious new hierarchy.

Target file: `Catalog/Bridges/TropicalValuationDepthCore.lean`.

Primary goal: turn the existing valuation-depth addition inequality into an explicit tropical-cost interface on `WithBot ℕ`, and then derive two concrete aggregation bounds (list fold and balanced binary tree). Keep all definitions local to the file and minimal.

Requirements:

1. Import only what is needed, preferably:
   - `Mathlib`
   - `Computation/PadicValuationDepth`

2. Work in a namespace such as `TropicalValuationDepthCore` and use the existing invariant from `ValuationDepthMeasure`.

3. Define a tiny tropical gadget on `WithBot ℕ`:
   - `tropAdd : WithBot ℕ → WithBot ℕ → WithBot ℕ := max`
   - `tropShift : WithBot ℕ → ℕ → WithBot ℕ`
     with behavior: `tropShift ⊥ c = ⊥`, `tropShift (some n) c = some (n + c)`
   - `depthTrop` as the valuation depth viewed in `WithBot ℕ` if needed for statement convenience

   Do not try to instantiate a full semiring structure unless it is genuinely trivial and helps proofs. Local definitions are preferred.

4. Prove a direct tropical wrapper theorem for the existing addition bound. The intended mathematical statement is:
   - `depthTrop (f + g) ≤ tropShift (tropAdd (depthTrop f) (depthTrop g)) 1`

   This should be derived transparently from the existing `vdepth_add`-style bound in `Computation/PadicValuationDepth`, not reproved from scratch. If the exact catalog theorem name differs, adapt to the actual API, but keep the final theorem in this tropical form.

5. Prove a finite aggregation theorem for lists. Use a concrete fold such as `List.foldl` over addition with zero. A good target form is:
   - if every `f ∈ L` satisfies `vdepth f ≤ d`, then `vdepth (sumList L) ≤ d + L.length`

   Make the statement precise using the actual ambient function type and zero/addition structure from the depth file. The proof should be a clean induction on the list using the addition-depth bound.

6. Define a concrete binary tree:
   - `inductive BinTree (α : Type _) | leaf : α → BinTree α | node : BinTree α → BinTree α → BinTree α`
   Define:
   - `height : BinTree α → ℕ`
   - `treeSum : BinTree F → F` for the relevant additive function type
   - a bounded-leaf predicate expressing `∀` leaves, depth `≤ d`

   Then prove:
   - `treeSum_depth_le : BoundedLeaves d t → vdepth (treeSum t) ≤ d + t.height`

   by induction on the tree.

7. If convenient, define a perfect tree constructor from a list or from repeated doubling, but only if it helps produce one extra clean corollary. Do not add speculative machinery. A lightweight corollary such as `perfectTree_depth_le` is welcome only if fully proved and short.

8. Avoid all `sorry`, placeholders, incomplete declarations, and theorem stubs. The file must compile cleanly.

9. Keep the mathematics explicit in comments:
   - explain that `max` models tropical addition of costs
   - explain that `+1` is the unit cost of one additive combination step
   - explain that the tree theorem yields logarithmic depth for balanced reduction when height is logarithmic in leaf count

10. Prefer theorem statements that are easy to falsify and inspect. Do not overgeneralize to abstract semirings or categories. This is a bridge file, not a framework.

Deliverable expectations:
- A self-contained Lean file with the minimal local definitions and fully checked proofs.
- Theorems should include at least:
  - the tropicalized binary addition bound
  - the list-fold depth bound
  - the binary-tree depth bound
- If some intended notation on `WithBot ℕ` is awkward in Lean, choose the simplest explicit pattern-matching definitions that compile reliably.

The key insight is that valuation depth already gives a tropical cost semantics for additive computation, and the formal task is to expose that semantics in a tiny verified wrapper plus aggregation bounds. Why now? Because `Computation/PadicValuationDepth` already contains the substantive ultrametric estimate, so this project is now a bounded formalization task with clear induction patterns rather than a speculative new theory.