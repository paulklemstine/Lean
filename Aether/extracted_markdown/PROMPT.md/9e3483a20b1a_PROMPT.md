Formalize a single self-contained Lean 4 file developing a minimal but complete theory of behavioral supervenience, and do not include any unrelated sections.

Target file: `Catalog/MachineLearning/BehavioralEquivalence.lean`

Imports: keep them minimal, but `import Mathlib` is acceptable if it helps completion.

Mathematical scope:
- Let `S B R : Type*`, `beh : S → B`, `rep : S → R`.
- Define
  `SupervenesOnBehavior rep beh := ∀ s t, beh s = beh t → rep s = rep t`
  and
  `NonIdentifiable rep beh := ∃ s t, beh s = beh t ∧ rep s ≠ rep t`.
- The file should prove only a small set of core theorems, all with complete bodies.

Required theorem list:
1. `not_supervenes_iff_nonIdentifiable`:
   `¬ SupervenesOnBehavior rep beh ↔ NonIdentifiable rep beh`.
   This should be a clean logical equivalence, not just one direction.

2. `factorization_range`:
   prove
   `SupervenesOnBehavior rep beh ↔ ∃ g : Set.range beh → R,
      rep = g ∘ (fun s => ⟨beh s, ⟨s, rfl⟩⟩)`.
   The proof may use `Classical.choose`. Keep the statement explicit and easy to use.

3. `factorization_surjective`:
   if `hbeh : Function.Surjective beh`, prove
   `SupervenesOnBehavior rep beh ↔ ∃ g : B → R, rep = g ∘ beh`.
   Derive this directly and cleanly from surjectivity; avoid overengineering.

4. Behavioral quotient:
   - Define `behSetoid (beh : S → B) : Setoid S` by `s ~ t ↔ beh s = beh t`.
   - Prove the equivalence relation fields explicitly.
   - Assuming `h : SupervenesOnBehavior rep beh`, define a descended map
     `quotRep : Quotient (behSetoid beh) → R`.
   - Prove a computation/commutation theorem on representatives, e.g.
     `quotRep h (Quotient.mk _ s) = rep s`.

5. Examples:
   Include exactly two tiny examples with full proofs.
   - One positive example where supervenience holds.
   - One negative example where `NonIdentifiable` holds and hence supervenience fails.
   Use `Bool`, `Fin 2`, or similarly tiny types.

Style constraints:
- Keep the development elementary and purely function-theoretic.
- No quotient/cardinality ambitions beyond the required `Setoid` and `Quotient` descent.
- No placeholder declarations, theorem headers without proofs, or speculative later sections.
- Remove all unrelated taxicab-number material.
- Prefer short theorem names and straightforward proofs over abstraction.
- If a theorem statement becomes awkward in Lean, slightly simplify the statement while preserving the exact mathematical content above.

Goal:
Produce a finished file that compiles end-to-end and constitutes a small but complete formalization of behavioral indistinguishability versus internal non-identifiability.