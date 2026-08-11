import Algebra.PosetFlow.ChainPoset

/-!
# Philip Hall's theorem: chains of a poset compute its Möbius function

The chain replacement of a poset flow replaces the (one point) spaces of execution
paths of a poset flow by the nerves of the refinement posets of chains.  The Euler
characteristics of those nerves are governed by the classical theorem of Philip
Hall, which identifies the alternating sum over chains from `x` to `y` with the
Möbius function of the incidence algebra.

This file proves Hall's theorem in the form

`∑ C ∈ chainFinsets x y, (-1) ^ |C| = - μ x y`,

where `chainFinsets x y` is the finite set of carriers of chains from `x` to `y`
(the objects of the refinement poset `PosetFlow.ChainFrom x y` of
`Algebra.PosetFlow.ChainPoset`), and `μ` is `IncidenceAlgebra.mu`.

## Main results

* `PosetFlow.chainAltSum_recursion` : deleting the top element `y` of a chain
  identifies chains from `x` to `y` with pairs `(z, C)` where `z ∈ Ico x y` and `C`
  is a chain from `x` to `z`.  This is the combinatorial induction step.
* `PosetFlow.chainAltSum_eq_neg_mu` : **Philip Hall's theorem**.
* `PosetFlow.mu_eq_zero_of_not_le` : the Möbius function vanishes off the order,
  a corollary of the chain description.
-/

namespace PosetFlow

open Finset IncidenceAlgebra

variable {P : Type*} [PartialOrder P] [Fintype P] [DecidableEq P] [DecidableLE P]

/-- The carriers of the chains from `x` to `y`, as a finite set of finsets. -/
def chainFinsets (x y : P) : Finset (Finset P) :=
  Finset.univ.filter fun C =>
    x ∈ C ∧ y ∈ C ∧ (∀ a ∈ C, x ≤ a ∧ a ≤ y) ∧ (∀ a ∈ C, ∀ b ∈ C, a ≤ b ∨ b ≤ a)

theorem mem_chainFinsets {x y : P} {C : Finset P} :
    C ∈ chainFinsets x y ↔
      x ∈ C ∧ y ∈ C ∧ (∀ a ∈ C, x ≤ a ∧ a ≤ y) ∧ (∀ a ∈ C, ∀ b ∈ C, a ≤ b ∨ b ≤ a) := by
  simp [chainFinsets]

/-- The carriers of chains from `x` to `y` are exactly the carriers of the elements
of the refinement poset `ChainFrom x y`. -/
theorem mem_chainFinsets_iff_exists {x y : P} {C : Finset P} :
    C ∈ chainFinsets x y ↔ ∃ D : ChainFrom x y, D.carrier = C := by
  rw [mem_chainFinsets]
  constructor
  · rintro ⟨h1, h2, h3, h4⟩
    exact ⟨⟨C, h1, h2, fun a ha => h3 a ha, fun a ha b hb => h4 a ha b hb⟩, rfl⟩
  · rintro ⟨D, rfl⟩
    exact ⟨D.mem_source, D.mem_target, fun a ha => D.bounded ha,
      fun a ha b hb => D.total ha hb⟩

/-- The alternating sum over the chains from `x` to `y`. -/
def chainAltSum (x y : P) : ℤ := ∑ C ∈ chainFinsets x y, (-1 : ℤ) ^ C.card

theorem chainFinsets_self (x : P) : chainFinsets x x = {{x}} := by
  ext C
  rw [mem_chainFinsets, Finset.mem_singleton]
  constructor
  · rintro ⟨h1, _, h3, _⟩
    apply Finset.Subset.antisymm
    · intro a ha
      rw [Finset.mem_singleton]
      exact le_antisymm (h3 a ha).2 (h3 a ha).1
    · intro a ha
      rw [Finset.mem_singleton] at ha
      exact ha ▸ h1
  · rintro rfl
    refine ⟨Finset.mem_singleton_self _, Finset.mem_singleton_self _, ?_, ?_⟩
    · intro a ha
      rw [Finset.mem_singleton] at ha
      exact ha ▸ ⟨le_refl _, le_refl _⟩
    · intro a ha b hb
      rw [Finset.mem_singleton] at ha hb
      exact Or.inl (by rw [ha, hb])

@[simp] theorem chainAltSum_self (x : P) : chainAltSum x x = -1 := by
  rw [chainAltSum, chainFinsets_self]
  simp

theorem chainFinsets_eq_empty_of_not_le {x y : P} (h : ¬ x ≤ y) : chainFinsets x y = ∅ := by
  ext C
  simp only [mem_chainFinsets, Finset.notMem_empty, iff_false, not_and]
  intro _ hy hb
  exact absurd (hb y hy).1 h

theorem chainAltSum_of_not_le {x y : P} (h : ¬ x ≤ y) : chainAltSum x y = 0 := by
  rw [chainAltSum, chainFinsets_eq_empty_of_not_le h, Finset.sum_empty]

omit [Fintype P] [DecidableLE P] in
/-- A nonempty totally ordered finset of a poset has a greatest element. -/
theorem exists_greatest_of_total (S : Finset P) (hne : S.Nonempty)
    (htot : ∀ a ∈ S, ∀ b ∈ S, a ≤ b ∨ b ≤ a) : ∃ z ∈ S, ∀ a ∈ S, a ≤ z := by
  classical
  induction S using Finset.induction_on with
  | empty => exact absurd hne (by simp)
  | @insert a S ha ih =>
    by_cases hS : S.Nonempty
    · have htot' : ∀ u ∈ S, ∀ v ∈ S, u ≤ v ∨ v ≤ u := fun u hu v hv =>
        htot u (Finset.mem_insert_of_mem hu) v (Finset.mem_insert_of_mem hv)
      obtain ⟨z, hz, hmax⟩ := ih hS htot'
      rcases htot a (Finset.mem_insert_self a S) z (Finset.mem_insert_of_mem hz) with h | h
      · refine ⟨z, Finset.mem_insert_of_mem hz, fun b hb => ?_⟩
        rcases Finset.mem_insert.1 hb with rfl | hb
        · exact h
        · exact hmax b hb
      · refine ⟨a, Finset.mem_insert_self a S, fun b hb => ?_⟩
        rcases Finset.mem_insert.1 hb with rfl | hb
        · exact le_refl _
        · exact le_trans (hmax b hb) h
    · refine ⟨a, Finset.mem_insert_self a S, fun b hb => ?_⟩
      rcases Finset.mem_insert.1 hb with rfl | hb
      · exact le_refl _
      · exact absurd ⟨b, hb⟩ hS

section Recursion

variable [LocallyFiniteOrder P]

/-- **Deleting the largest element of a chain.**  For `x < y`, chains from `x` to `y`
correspond bijectively to pairs consisting of an element `z ∈ Ico x y` and a chain
from `x` to `z`; the correspondence adds `y` on top. -/
theorem chainAltSum_recursion {x y : P} (hxy : x < y) :
    chainAltSum x y = -∑ z ∈ Finset.Ico x y, chainAltSum x z := by
  have key : ∑ p ∈ (Finset.Ico x y).sigma (fun z => chainFinsets x z),
      (-1 : ℤ) ^ (insert y p.2).card = ∑ C ∈ chainFinsets x y, (-1 : ℤ) ^ C.card := by
    refine Finset.sum_nbij (fun p => insert y p.2) ?_ ?_ ?_ ?_
    · -- the map lands in the chains from `x` to `y`
      rintro ⟨z, C⟩ hp
      dsimp only
      simp only [Finset.mem_sigma] at hp
      obtain ⟨hz, hC⟩ := hp
      rw [Finset.mem_Ico] at hz
      rw [mem_chainFinsets] at hC
      obtain ⟨h1, h2, h3, h4⟩ := hC
      rw [mem_chainFinsets]
      refine ⟨Finset.mem_insert_of_mem h1, Finset.mem_insert_self _ _, ?_, ?_⟩
      · intro a ha
        rcases Finset.mem_insert.1 ha with hay | ha
        · exact ⟨by rw [hay]; exact le_of_lt hxy, le_of_eq hay⟩
        · exact ⟨(h3 a ha).1, le_trans (h3 a ha).2 (le_of_lt hz.2)⟩
      · intro a ha b hb
        rcases Finset.mem_insert.1 ha with hay | ha
        · rcases Finset.mem_insert.1 hb with hby | hb
          · exact Or.inl (by rw [hay, hby])
          · exact Or.inr (by rw [hay]; exact le_trans (h3 b hb).2 (le_of_lt hz.2))
        · rcases Finset.mem_insert.1 hb with hby | hb
          · exact Or.inl (by rw [hby]; exact le_trans (h3 a ha).2 (le_of_lt hz.2))
          · exact h4 a ha b hb
    · -- injectivity
      rintro ⟨z, C⟩ hp ⟨z', C'⟩ hp' heq
      dsimp only at heq
      simp only [Finset.coe_sigma, Set.mem_sigma_iff, Finset.mem_coe, Finset.mem_Ico] at hp hp'
      obtain ⟨hz, hC⟩ := hp
      obtain ⟨hz', hC'⟩ := hp'
      rw [mem_chainFinsets] at hC hC'
      have hyC : y ∉ C := fun hy => absurd (hC.2.2.1 y hy).2 (not_le_of_gt hz.2)
      have hyC' : y ∉ C' := fun hy => absurd (hC'.2.2.1 y hy).2 (not_le_of_gt hz'.2)
      have hCC' : C = C' := by
        apply Finset.Subset.antisymm
        · intro a ha
          have hmem : a ∈ insert y C' := by rw [← heq]; exact Finset.mem_insert_of_mem ha
          rcases Finset.mem_insert.1 hmem with hay | h
          · exact absurd (hay ▸ ha) hyC
          · exact h
        · intro a ha
          have hmem : a ∈ insert y C := by rw [heq]; exact Finset.mem_insert_of_mem ha
          rcases Finset.mem_insert.1 hmem with hay | h
          · exact absurd (hay ▸ ha) hyC'
          · exact h
      subst hCC'
      have h1 : z' ≤ z := (hC.2.2.1 z' hC'.2.1).2
      have h2 : z ≤ z' := (hC'.2.2.1 z hC.2.1).2
      simp [le_antisymm h2 h1]
    · -- surjectivity: every chain from `x` to `y` arises this way
      intro C hC
      rw [Finset.mem_coe, mem_chainFinsets] at hC
      obtain ⟨h1, h2, h3, h4⟩ := hC
      have hne : (C.erase y).Nonempty := ⟨x, Finset.mem_erase.2 ⟨ne_of_lt hxy, h1⟩⟩
      obtain ⟨z, hzmem, hzmax⟩ := exists_greatest_of_total (C.erase y) hne
        (fun a ha b hb => h4 a (Finset.mem_erase.1 ha).2 b (Finset.mem_erase.1 hb).2)
      have hzC : z ∈ C := (Finset.mem_erase.1 hzmem).2
      have hzne : z ≠ y := (Finset.mem_erase.1 hzmem).1
      have hzlt : z < y := lt_of_le_of_ne (h3 z hzC).2 hzne
      have hxz : x ≤ z := (h3 z hzC).1
      have hCz : C.erase y ∈ chainFinsets x z := by
        rw [mem_chainFinsets]
        refine ⟨Finset.mem_erase.2 ⟨ne_of_lt hxy, h1⟩, hzmem, ?_, ?_⟩
        · intro a ha
          exact ⟨(h3 a (Finset.mem_erase.1 ha).2).1, hzmax a ha⟩
        · intro a ha b hb
          exact h4 a (Finset.mem_erase.1 ha).2 b (Finset.mem_erase.1 hb).2
      refine ⟨⟨z, C.erase y⟩, ?_, ?_⟩
      · simp only [Finset.coe_sigma, Set.mem_sigma_iff, Finset.mem_coe, Finset.mem_Ico]
        exact ⟨⟨hxz, hzlt⟩, hCz⟩
      · exact Finset.insert_erase h2
    · -- the summands agree
      rintro ⟨z, C⟩ _
      rfl
  have hcard : ∀ p ∈ (Finset.Ico x y).sigma (fun z => chainFinsets x z),
      (-1 : ℤ) ^ (insert y p.2).card = -((-1 : ℤ) ^ p.2.card) := by
    rintro ⟨z, C⟩ hp
    rw [Finset.mem_sigma, Finset.mem_Ico] at hp
    obtain ⟨hz, hC⟩ := hp
    rw [mem_chainFinsets] at hC
    have hyC : y ∉ C := fun hy => absurd (hC.2.2.1 y hy).2 (not_le_of_gt hz.2)
    rw [Finset.card_insert_of_notMem hyC, pow_succ]
    ring
  rw [chainAltSum, ← key, Finset.sum_congr rfl hcard, Finset.sum_neg_distrib]
  congr 1
  rw [show (∑ z ∈ Finset.Ico x y, chainAltSum x z)
      = ∑ z ∈ Finset.Ico x y, ∑ C ∈ chainFinsets x z, (-1 : ℤ) ^ C.card from rfl,
    Finset.sum_sigma']

/-- **Philip Hall's theorem.**  The alternating sum over the chains from `x` to `y`
of a finite poset is the negative of the Möbius function of the incidence algebra.
Combinatorially, `- μ x y` is the reduced Euler characteristic of the order complex
of the open interval `(x, y)`. -/
theorem chainAltSum_eq_neg_mu (x y : P) : chainAltSum x y = -mu ℤ x y := by
  induction y using WellFoundedLT.induction with
  | _ y ih =>
    by_cases hxy : x = y
    · subst hxy
      simp
    · by_cases hle : x ≤ y
      · have hlt : x < y := lt_of_le_of_ne hle hxy
        rw [chainAltSum_recursion hlt, mu_apply, if_neg hxy, neg_neg,
          ← Finset.sum_neg_distrib]
        refine Finset.sum_congr rfl fun z hz => ?_
        rw [Finset.mem_Ico] at hz
        rw [ih z hz.2, neg_neg]
      · rw [chainAltSum_of_not_le hle, mu_apply, if_neg hxy,
          Finset.Ico_eq_empty (fun h => hle (le_of_lt h))]
        simp

/-- The Möbius function vanishes outside the order relation. -/
theorem mu_eq_zero_of_not_le {x y : P} (h : ¬ x ≤ y) : mu ℤ x y = 0 := by
  have := chainAltSum_eq_neg_mu x y
  rw [chainAltSum_of_not_le h] at this
  exact neg_eq_zero.1 this.symm

end Recursion

end PosetFlow