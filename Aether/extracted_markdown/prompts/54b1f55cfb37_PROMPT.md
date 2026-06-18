Formalize the diagonalization/counting core of the Ramanujan-oracle idea as a self-contained Lean 4 file with complete proofs and no `sorry`. Do not pursue philosophical claims about intuition, jump operators, or empirical 95% accuracy. Instead, produce a precise computability-style theorem package.

Create a file developing the following objects and results.

1. Basic definitions.
- Define `Predicate := ℕ → Bool`.
- Define `Verdict := Option Bool`.
- Define `Oracle := ℕ → Verdict`.
- Define `agrees (O : Oracle) (g : Predicate) : Prop := ∀ n b, O n = some b → g n = b`.
- Define `Complete (O : Oracle) : Prop := ∀ n, ∃ b, O n = some b` (or equivalently `O n ≠ none`; pick the formulation that is easiest in Lean).

2. Boolean diagonalization core.
Prove a theorem of the following shape:
- `diagonal_escape (F : ℕ → Predicate) : ∃ g : Predicate, ∀ i, g ≠ F i`.
Use the standard diagonal predicate `g i = !(F i i)`.
Then derive:
- `not_surjective_nat_to_predicate : ¬ Function.Surjective (fun i : ℕ => (F i))` in a suitable quantified form, e.g.
  `¬ ∃ F : ℕ → Predicate, Function.Surjective F`.
If the surjectivity statement is cleaner as a separate theorem over arbitrary `F`, that is fine.

3. Three-valued complete-oracle diagonalization.
For a family `O : ℕ → Oracle` with completeness hypothesis `∀ i, Complete (O i)`, define a diagonal predicate `g : Predicate` by reading the diagonal answer of `O i i` and flipping it. Prove:
- `complete_family_forces_error`:
  for every such family `O`, there exists `g : Predicate` such that for every `i`, oracle `O i` does not agree with `g`.
A stronger explicit version is preferred if convenient:
- for every `i`, there exists a witness input (ideally `i`) on which `O i` returns the wrong Boolean value relative to `g`.

4. Optional partial-oracle extension if straightforward.
If the proof is clean, add:
- for any family `O : ℕ → Oracle`, there exists `g : Predicate` such that for every `i`, at input `i` the oracle either returns `none` or returns the wrong value for `g i`.
This captures “error or incompleteness” without needing completeness assumptions.

5. Deliverable requirements.
- The file must compile against current Mathlib with no `sorry`.
- State theorems in a reusable way, with short docstrings.
- Prefer elementary proofs by extensionality and contradiction; avoid unnecessary abstractions.
- Include one final theorem or comment explaining the interpretation: a countable family of candidate oracles cannot capture all predicates, so any claim of a universally correct oracle cannot be justified by mere enumeration/computability.

The goal is not to overreach. A small, complete, well-polished formalization of `diagonal_escape`, non-surjectivity, and the complete-oracle error theorem is better than a broader speculative file with placeholders.