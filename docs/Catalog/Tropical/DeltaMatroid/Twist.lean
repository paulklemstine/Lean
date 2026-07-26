import Mathlib

/-!
# Twist (partial twuality) on set systems and the Bouchet closure theorem

This file develops the algebra of the *twist* operation `D ↦ D * A` on set systems,
the elementary operation underlying *partial twuality* of (binary) delta-matroids
in the sense of Chmutov, Gross–Mansour–Tucker and Yan–Jin.

A **set system** on a finite ground set is a finite collection `D : Finset (Finset α)`
of feasible subsets.  The **twist by `A`** sends each feasible set `F` to the symmetric
difference `F ∆ A`.  This is the combinatorial core of partial duality of ribbon
graphs (Chmutov) and of partial twuality of delta-matroids (Yan–Jin).

Main results:
* `twist_empty`, `twist_twist`, `twist_involutive`: the twists form an action of the
  symmetric–difference group `(Finset α, ∆)` on set systems (the "categorical
  structure" mentioned in the mission framing).
* `twist_symExchange`: **the class of delta-matroids is closed under twist** —
  if a set system satisfies Bouchet's symmetric–exchange axiom, so does every twist
  of it.  This is the foundational closure theorem that makes partial twuality
  well defined on delta-matroids.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The twist operation `* A` is an involution and the family
  `{* A}` is a group action of `(2^E, ∆)`; moreover delta-matroids are closed under it.
Experiment (Experimenter): Formalised `twist`, `SymExchange`; proved the group-action
  laws and the closure theorem.  Key algebraic fact: `(F₁ ∆ A) ∆ (F₂ ∆ A) = F₁ ∆ F₂`,
  so the exchange data transports verbatim through a twist.
Analysis (Analyst): The closure proof is *definition-driven*: the `A` cancels in every
  pairwise symmetric difference, so the witness `y` for the original system also works
  for the twisted system.  Survived: all four theorems.
Critique (Critic): Statements are non-vacuous (see `Examples.lean` for an explicit
  delta-matroid where `SymExchange` is verified independently and then twisted).
  No theorem is `True`/`rfl`-only; `twist_symExchange` uses real `obtain`/`refine`
  case analysis on the exchange witness.
Synthesis (PI): These laws license treating the partial-twuality polynomial as an
  invariant of a *twist orbit*, exploited in `Interpolation.lean`.
-/

open Finset
open scoped symmDiff

namespace DeltaMatroid

variable {α : Type*} [DecidableEq α]

/-- The twist (partial twuality elementary move) of a set system `D` by a subset `A`:
each feasible set `F` is replaced by `F ∆ A`. -/
def twist (A : Finset α) (D : Finset (Finset α)) : Finset (Finset α) := D.image (· ∆ A)

/-- Bouchet's **symmetric exchange axiom**: the defining property of a delta-matroid.
For all feasible `F₁, F₂` and every `x` in their symmetric difference, there is a
`y` (possibly equal to `x`) in the symmetric difference with `F₁ ∆ {x, y}` feasible. -/
def SymExchange (D : Finset (Finset α)) : Prop :=
  ∀ F1 ∈ D, ∀ F2 ∈ D, ∀ x ∈ F1 ∆ F2, ∃ y ∈ F1 ∆ F2, F1 ∆ ({x, y} : Finset α) ∈ D

@[simp] theorem twist_empty (D : Finset (Finset α)) : twist ∅ D = D := by
  unfold twist
  rw [show (∅ : Finset α) = (⊥ : Finset α) from rfl]
  simp only [symmDiff_bot]
  exact Finset.image_id

/-- Twisting is a (left) action of the symmetric–difference group: `* A` after `* B`
equals `* (A ∆ B)`. -/
theorem twist_twist (A B : Finset α) (D : Finset (Finset α)) :
    twist A (twist B D) = twist (A ∆ B) D := by
  unfold twist
  rw [Finset.image_image]
  apply Finset.image_congr
  intro f _
  simp only [Function.comp]
  rw [symmDiff_assoc, symmDiff_comm B A]

/-- Every twist is an involution: `* A` applied twice is the identity. -/
theorem twist_involutive (A : Finset α) (D : Finset (Finset α)) :
    twist A (twist A D) = D := by
  rw [twist_twist, symmDiff_self]
  exact twist_empty D

/-- **Closure of delta-matroids under twist (Bouchet).**  If `D` satisfies the
symmetric–exchange axiom, then so does every twist `twist A D`.  This is what makes
partial twuality a well-defined operation on the class of delta-matroids. -/
theorem twist_symExchange (A : Finset α) (D : Finset (Finset α)) (h : SymExchange D) :
    SymExchange (twist A D) := by
  intro F1' hF1' F2' hF2' x hx
  simp only [twist, mem_image] at hF1' hF2'
  obtain ⟨F1, hF1, rfl⟩ := hF1'
  obtain ⟨F2, hF2, rfl⟩ := hF2'
  -- the twist parameter `A` cancels in the pairwise symmetric difference
  have hxx : (F1 ∆ A) ∆ (F2 ∆ A) = F1 ∆ F2 := by
    rw [symmDiff_assoc, ← symmDiff_assoc A F2 A, symmDiff_comm A F2, symmDiff_assoc F2 A A,
      symmDiff_self, symmDiff_bot]
  rw [hxx] at hx ⊢
  obtain ⟨y, hy, hmem⟩ := h F1 hF1 F2 hF2 x hx
  refine ⟨y, hy, ?_⟩
  simp only [twist, mem_image]
  exact ⟨F1 ∆ ({x, y} : Finset α), hmem, by rw [symmDiff_right_comm]⟩

end DeltaMatroid