# Summary of changes for run 3680b15f-5451-4a28-a991-f75181602746
Completed the Dung argumentation framework formalization in `Catalog/Logic/Dung.lean` (the active Lean library of the project; `Logic.+` glob).

What was added, all proved with no `sorry` and using only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`; the conflict-free lemmas use none):

1. Core notions in namespace `Dung`:
   - `ConflictFree attacks S := ∀ a ∈ S, ∀ b ∈ S, ¬ attacks a b` and `ConflictFree.subset`.
   - `Defends attacks S a := ∀ b, attacks b a → ∃ c ∈ S, attacks c b`.
   - `Admissible attacks S := ConflictFree attacks S ∧ ∀ a ∈ S, Defends attacks S a`.
   - `Preferred attacks S := Admissible attacks S ∧ ∀ T, Admissible attacks T → S ⊆ T → T = S`.

2. `conflictGraph` as a `SimpleGraph α` with adjacency `a ≠ b ∧ (attacks a b ∨ attacks b a)`, and `conflictFree_iff_isIndepSet`, proving (under irreflexivity `∀ a, ¬ attacks a a`) that conflict-free sets are exactly independent sets of the conflict graph, using Mathlib's `SimpleGraph.IsIndepSet`.

3. Corollaries `conflictFree_empty` and `conflictFree_singleton`.

4. `preferred_not_downward_closed`, showing preferred extensions (and even admissibility) are not downward closed: there is a framework with a preferred extension `S` and a subset `T ⊆ S` that is not admissible.

Note on the counterexample: the symmetric framework suggested in the task (on `Fin 3`, `0 ↔ 2` and `1 ↔ 2`) does not actually witness the failure, because there the singleton `{0}` is admissible (`0` counter-attacks its only attacker `2`). I therefore used the correct asymmetric framework on `Fin 3` where `2` attacks `0` and `1` attacks `2`: then `{0,1}` is preferred but its subset `{0}` is not admissible (its attacker `2` is not counter-attacked from within `{0}`). This deviation is documented in a comment in the file.

The module builds cleanly (`lake build Logic.Dung`) with no warnings and no remaining `sorry`.