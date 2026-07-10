/-
# The Thermodynamics of Sorting III: Irreversibility and Information Erasure

The central physical claim of the mission is that sorting does thermodynamic work *because
it is irreversible*: many distinct inputs are mapped to the same sorted output, so the
input cannot be recovered from the output.  By Landauer's principle, erasing that
information dissipates `kT · ln 2` per erased bit.

We make this precise for `List.mergeSort (· ≤ ·)`:

## Main results

* `sort_perm_invariant`: any two permutations of a list are mapped to the *same* sorted
  output.  The entire orbit of `n !` orderings collapses to one output — this many-to-one
  collapse is exactly the erased entropy `log₂(n!)`.
* `sort_not_injective`: consequently the sorting map is not injective, i.e. it is
  irreversible; a reversible (injective) map would dissipate no work.
* `sort_collapse_witness`: a concrete two-input collapse (`[0,1]` and `[1,0]` both sort to
  `[0,1]`), the smallest instance erasing exactly `1` bit.
-/

import Mathlib

namespace SortingThermodynamics

/-
**Permutation invariance = information erasure.** Any two lists that are permutations
of one another are sent to the same sorted output.  Hence all `n !` orderings of `n`
distinct elements collapse to a single output, erasing `log₂(n!)` bits of entropy.
-/
theorem sort_perm_invariant {α : Type*} [LinearOrder α] {l₁ l₂ : List α}
    (h : l₁.Perm l₂) :
    l₁.mergeSort (· ≤ ·) = l₂.mergeSort (· ≤ ·) := by
  apply_rules [ List.Perm.eq_of_pairwise, List.pairwise_mergeSort ];
  grind +locals;
  · grind;
  · grind +revert;
  · grind;
  · grind +revert;
  · exact List.Perm.trans ( List.mergeSort_perm _ _ ) ( h.trans ( List.mergeSort_perm _ _ |> List.Perm.symm ) )

/-
A concrete smallest collapse: the two orderings of `{0,1}` map to the same output,
erasing exactly one bit.
-/
theorem sort_collapse_witness :
    ([0, 1] : List ℕ).mergeSort (· ≤ ·) = ([1, 0] : List ℕ).mergeSort (· ≤ ·) :=
  sort_perm_invariant (by decide)

/-
**Sorting is irreversible.** The sorting map on `List ℕ` is not injective: distinct
inputs share an output, so the input cannot be recovered.  A reversible map would be
injective and (by Landauer) could dissipate no work.
-/
theorem sort_not_injective :
    ¬ Function.Injective (fun l : List ℕ => l.mergeSort (· ≤ ·)) := by
  intro h
  have : ([0, 1] : List ℕ) = ([1, 0] : List ℕ) := h sort_collapse_witness
  exact absurd this (by decide)

end SortingThermodynamics