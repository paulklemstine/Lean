Develop a complete, self-contained Lean file proving a smaller but fully verified bridge theorem for valuation depth in max-plus form.

Target file: `Catalog/Bridges/TropicalValuationDepthCore.lean`

Primary instruction: do not spend effort on ambitious structure instantiation unless it is immediate. The previous attempt likely failed because it tried to force valuation depth into the existing categorical tropical object interface before verifying the exact algebraic fit. In this retry, prioritize complete proofs over abstraction.

Mathematical goal:
1. Introduce a local max-plus tropical gadget on `WithBot ℕ` sufficient for theorem statements:
   - `tropAdd : WithBot ℕ → WithBot ℕ → WithBot ℕ := max`
   - `tropCost : WithBot ℕ → ℕ → WithBot ℕ`, where `tropCost x c = x + c` in the `WithBot ℕ` sense
   - `costUnit : ℕ := 1`
   You may package this in a simple structure if helpful, but do not depend on a large interface.

2. Using `Computation/PadicValuationDepth`, define a depth tropicalization map for the existing valuation-depth notion (whatever the canonical codomain in that file is; coerce to `WithBot ℕ` only if needed and only with explicit lemmas).

3. Prove the core bridge theorem in explicit max-plus form:
   `depth_trop_add_bound`:
   the depth of a sum is bounded by max of depths plus one.
   This theorem should be stated both in ordinary arithmetic form and in tropicalized form.
   Prefer a direct wrapper around an existing theorem from `Computation/PadicValuationDepth` if available.

4. Define a balanced binary reduction `treeSum` over `2^k` leaves. Keep the definition as simple as possible:
   - either recursively combine a family `Fin (2^k) → α` into one term,
   - or recursively combine a binary tree encoded by depth `k`.
   Choose the representation that makes induction easiest.

5. Prove the logarithmic-depth theorem:
   if every leaf has depth at most `d`, then `depth (treeSum φ k) ≤ d + k`.
   This should be a complete induction on `k`, using only the binary depth-add bound.

6. If product/composition analogues are not already cleanly supported by the imported depth API, omit them. One fully proved balanced-sum theorem is better than several partial declarations.

7. At the end of the file, add a short theorem/comment block explaining the exact gap to `Bridges/CategoricalTropicalUltrametric`: namely, that the existing bridge layer appears organized around a different tropical semiring/object, so a future extension should either generalize that interface to max-plus or provide a translation functor. Keep this as commentary or a lightweight proposition, not a large unfinished development.

Proof strategy:
- Mine `Computation/PadicValuationDepth` for the exact names of theorems already proving depth bounds for addition, double sums, or triple sums.
- Reuse those lemmas directly instead of reproving analytic facts.
- Keep all definitions reducible and explicit.
- Avoid `sorry`, placeholders, unfinished theorem headers, and overengineered abstractions.
- If coercions involving `WithBot ℕ` become painful, define the tropicalized statements in the native codomain first and only then transport them with small helper lemmas.

Deliverables:
- A compiling Lean file with complete proofs.
- Theorems should be named clearly and be reusable by a future categorical bridge layer.
- No incomplete instance declarations.

If you discover that `treeSum` over `2^k` is awkward in Lean, it is acceptable to instead define an inductive full binary tree datatype of height `k` with leaves labeled by terms, and prove the corresponding height bound `depth ≤ d + height`. This still captures the logarithmic-depth balanced reduction theorem and is preferable to a fragile indexing development.