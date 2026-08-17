/-
Copyright (c) 2025. All rights reserved.

# Failure Sets are Infinite: Non-Uniform Patching and Compression

## Overview

Fourth cycle of the Phase-B/M8 investigation.  Cycle 1
(`Shared.CompressionOneWayFunctions`) produced, for each algorithm of a class,
*one* string with a short description that the algorithm fails to output
(`owf_description_gap`).  The adversarial review raised the obvious objection: a
single failure could be an artefact, since an algorithm failing on finitely many
inputs can be repaired with a lookup table.

Here we prove that the objection cannot be sustained as soon as the collection
of algorithms is closed under exactly that repair operation:

* `PatchClosed` — closure of a set of algorithms under overwriting on a finite
  set of inputs (finite advice / a lookup table);
* `inverter_failure_infinite` — if no algorithm of a patch-closed collection
  inverts `f`, then *every* algorithm of the collection fails on an **infinite**
  set of inputs;
* `compression_failure_infinite` — hence every candidate compressor fails to
  output shortest programs on an infinite set of inputs, each of which
  nevertheless *has* a description.

To rule out vacuity we exhibit a concrete patch-closed collection
(`tailAvoiding`, the algorithms that agree with the "delete the first bit"
map only finitely often) containing the function `tagTrue` of cycle 1 and
containing no inverter for it (`tagTrue_hard_tailAvoiding`), so the hypotheses
are simultaneously satisfiable and the conclusion has real content
(`tagTrue_failures_infinite`).

**Open point recorded for the next cycle.**  Patch closure and the strong
`search_mem` axiom of `SearchClosedClass` pull in opposite directions: search
closure forces the class to control the length of outputs uniformly in the guard
parameter, whereas finite patching destroys any uniform length control.  Whether
a single class can satisfy both *and* contain a one-way function is Conjecture 6
of `FUTURE_DIRECTIONS.md`.

No axioms beyond the standard three, no `sorry`.
-/
import Shared.CompressionSearchToDecision

namespace CompressionOWF

/-- A collection of algorithms closed under finite advice: any algorithm may be
overwritten arbitrarily on a finite set of inputs. -/
def PatchClosed (Comp : Set (Str → Str)) : Prop :=
  ∀ A ∈ Comp, ∀ (F : Finset Str) (g : Str → Str),
    (fun y => if y ∈ F then g y else A y) ∈ Comp

/-- **Failures of inversion are infinite.**  If no algorithm of a patch-closed
collection inverts `f`, then each of them fails on infinitely many inputs:
otherwise the finitely many failures could be hard-wired, producing a genuine
inverter inside the collection. -/
theorem inverter_failure_infinite {Comp : Set (Str → Str)} (hpatch : PatchClosed Comp)
    (f : Str → Str) (hhard : ∀ A ∈ Comp, ¬ Inverts f A) (A : Str → Str) (hA : A ∈ Comp) :
    {y : Str | Describable f y ∧ f (A y) ≠ y}.Infinite := by
  classical
  by_contra hcon
  rw [Set.not_infinite] at hcon
  set F : Finset Str := hcon.toFinset with hF
  have hchoice : ∀ y : Str, ∃ x : Str, Describable f y → f x = y := by
    intro y
    by_cases h : Describable f y
    · exact ⟨h.choose, fun _ => h.choose_spec⟩
    · exact ⟨[], fun hh => absurd hh h⟩
  choose g hg using hchoice
  refine hhard (fun y => if y ∈ F then g y else A y) (hpatch A hA F g) ?_
  intro y hy
  by_cases hmem : y ∈ F
  · simp only [if_pos hmem]
    exact hg y hy
  · simp only [if_neg hmem]
    have hnot : y ∉ {y : Str | Describable f y ∧ f (A y) ≠ y} := by
      intro hy'
      exact hmem (by rw [hF, Set.Finite.mem_toFinset]; exact hy')
    by_contra hne
    exact hnot ⟨hy, hne⟩

/-- **Failures of compression are infinite.**  Under the same hypotheses, every
algorithm of the collection fails to produce a shortest program on infinitely
many describable inputs. -/
theorem compression_failure_infinite {Comp : Set (Str → Str)} (hpatch : PatchClosed Comp)
    (f : Str → Str) (hhard : ∀ A ∈ Comp, ¬ Inverts f A) (A : Str → Str) (hA : A ∈ Comp) :
    {y : Str | Describable f y ∧ ¬ (f (A y) = y ∧ (A y).length = K f y)}.Infinite := by
  refine Set.Infinite.mono ?_ (inverter_failure_infinite hpatch f hhard A hA)
  rintro y ⟨hy, hne⟩
  exact ⟨hy, fun h => hne h.1⟩

/-! ## A concrete patch-closed collection with a non-invertible function -/

/-- Algorithms that agree with "delete the first bit" only finitely often. -/
def tailAvoiding : Set (Str → Str) := {A | {y : Str | A y = y.tail}.Finite}

theorem tailAvoiding_patchClosed : PatchClosed tailAvoiding := by
  classical
  intro A hA F g
  have hsub : {y : Str | (if y ∈ F then g y else A y) = y.tail} ⊆
      {y : Str | A y = y.tail} ∪ (F : Set Str) := by
    intro y hy
    by_cases hmem : y ∈ F
    · exact Or.inr hmem
    · left
      simpa [hmem] using hy
  exact Set.Finite.subset (Set.Finite.union hA F.finite_toSet) hsub

theorem tagTrue_mem_tailAvoiding : tagTrue ∈ tailAvoiding := by
  have hempty : {y : Str | tagTrue y = y.tail} = ∅ := by
    ext y
    simp only [Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false]
    intro h
    have hlen : (tagTrue y).length = y.tail.length := by rw [h]
    simp only [tagTrue, List.length_cons, List.length_tail] at hlen
    omega
  rw [tailAvoiding, Set.mem_setOf_eq, hempty]
  exact Set.finite_empty

/-- No algorithm of `tailAvoiding` inverts `tagTrue`: an inverter must delete the
leading bit on the whole (infinite) range of `tagTrue`. -/
theorem tagTrue_hard_tailAvoiding : ∀ A ∈ tailAvoiding, ¬ Inverts tagTrue A := by
  intro A hA hinv
  have hall : ∀ p : Str, A (true :: p) = (true :: p).tail := by
    intro p
    have hdesc : Describable tagTrue (true :: p) := ⟨p, rfl⟩
    have h := hinv (true :: p) hdesc
    simp only [tagTrue, List.cons.injEq] at h
    simpa using h.2
  have hinf : {y : Str | A y = y.tail}.Infinite :=
    Set.infinite_of_injective_forall_mem
      (f := fun p : Str => true :: p) (by intro a b h; simpa using h) hall
  exact hinf hA

/-- Consequently every algorithm of `tailAvoiding` fails to invert `tagTrue` on
infinitely many inputs — the hypotheses of `inverter_failure_infinite` are
satisfiable, and its conclusion is not vacuous. -/
theorem tagTrue_failures_infinite (A : Str → Str) (hA : A ∈ tailAvoiding) :
    {y : Str | Describable tagTrue y ∧ tagTrue (A y) ≠ y}.Infinite :=
  inverter_failure_infinite tailAvoiding_patchClosed tagTrue tagTrue_hard_tailAvoiding A hA

end CompressionOWF