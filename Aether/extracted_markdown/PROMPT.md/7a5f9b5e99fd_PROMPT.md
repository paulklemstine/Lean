You are retrying a partial Lean formalization. The previous attempt went off-topic into Fibonacci material. Do not reuse any of that. Focus only on the geometry/combinatorics theorem below and produce a complete, self-contained Lean file with no `sorry`.

Goal: formalize the Vietoris–Rips completion threshold theorem for a finite metric space.

Required scope:
1. Define `fullComplex α` as the simplicial complex (or a lightweight custom downward-closed finite-subset complex) whose faces are all finite subsets of `α`.
2. Define the Vietoris–Rips complex `vietorisRips ε` on a type `α` with `PseudoMetricSpace α` (or `MetricSpace α`) so that a finite subset is a face iff every pair of vertices in it has distance `≤ ε`.
3. Prove the exact equivalence
   `vietorisRips ε = fullComplex α ↔ ∀ x y : α, dist x y ≤ ε`.
   This is the core theorem and should be proved cleanly in both directions.
4. If `α` is finite, derive a corollary expressing the threshold using the maximum pairwise distance / diameter of the whole space. Use whichever finite supremum formulation is easiest to formalize in Mathlib:
   - either `∀ x y, dist x y ≤ ε`,
   - or `sSup (Set.range fun p : α × α => dist p.1 p.2) ≤ ε`,
   - or a `Finset.univ.sup` formulation over `α × α`.
   The point is to package the previous theorem as a finite “maximum pairwise distance” threshold.

Implementation guidance:
- Prefer a minimal, robust formalization over ambitious API integration. If Mathlib’s existing simplicial complex definitions are cumbersome, define a custom structure such as:
  `structure SimpleComplex (α) where faces : Set (Finset α); downward_closed : ...`
  and define equality/extensionality on faces.
- The Vietoris–Rips condition should be expressed on `Finset α` by pairwise bounded distance, e.g. using `s.Pairwise` or an explicit pairwise predicate.
- The proof that `vietorisRips ε = fullComplex α → ∀ x y, dist x y ≤ ε` should use the 2-vertex face `{x,y}`.
- The converse should show every finite subset is a face once all ambient pairwise distances are bounded by `ε`.
- Keep the file tightly focused. No unrelated imports or side developments.
- Include theorem names that are easy to reuse, for example:
  `mem_fullComplex`
  `mem_vietorisRips_iff`
  `vietorisRips_eq_fullComplex_iff`
  `vietorisRips_eq_fullComplex_iff_le_maxDist` (or similar)
- Ensure the final file compiles as-is under Mathlib, with no placeholders, malformed declarations, or truncated proofs.

Deliverable:
A single Lean file in the geometry/topology/combinatorics area that fully proves the theorem above. Favor complete correctness and API simplicity over matching any previous unfinished scaffold.