import Mathlib

/-!
# Surreal probability on the finite--cofinite algebra

This file connects Conway's surreal numbers with the finite--cofinite Boolean algebra on an
infinite sample space.  In particular, taking the sample space to be the real interval `[0,1]`
gives a normalized, finitely additive surreal-valued probability in which every point has the
same strictly positive infinitesimal mass.

The infinitesimal is constructed directly as the Conway cut

`ε = { 0 | 1, 1/2, 1/4, ... }`.

An event in the finite--cofinite algebra is either finite or has finite complement.  Its mass is
`|A| ε` in the finite case and `1 - |Aᶜ| ε` in the cofinite case.  The assumption that the sample
space is infinite makes these cases disjoint, and ordinary finite-cardinality identities become
finite additivity of the surreal probability.
-/

open SetTheory

namespace SurrealFiniteCofiniteProbability

/-- The Conway pre-game `{ 0 | 1, 1/2, 1/4, ... }`. -/
def infinitesimalGame : PGame :=
  PGame.mk PUnit ℕ (fun _ => 0) (fun n => PGame.powHalf n)

/-- The defining cut is numeric, hence represents a surreal number. -/
theorem infinitesimalGame_numeric : infinitesimalGame.Numeric := by
  rw [PGame.numeric_def]
  refine ⟨?_, ?_, ?_⟩
  · intro _ n
    exact PGame.powHalf_pos n
  · intro _
    exact PGame.numeric_zero
  · intro n
    exact PGame.numeric_powHalf n

/-- A concrete positive surreal infinitesimal. -/
def epsilon : Surreal := Surreal.mk infinitesimalGame infinitesimalGame_numeric

/-- The constructed surreal is strictly positive. -/
theorem epsilon_pos : (0 : Surreal) < epsilon := by
  rw [epsilon, Surreal.zero_lt_mk]
  exact infinitesimalGame_numeric.moveLeft_lt PUnit.unit

/-- The cut lies below every dyadic term in its right set. -/
theorem epsilon_lt_powHalf (n : ℕ) : epsilon < Surreal.powHalf n := by
  change Surreal.mk infinitesimalGame infinitesimalGame_numeric <
    Surreal.mk (PGame.powHalf n) (PGame.numeric_powHalf n)
  rw [Surreal.mk_lt_mk]
  exact infinitesimalGame_numeric.lt_moveRight n

private theorem nat_le_two_pow (n : ℕ) : n ≤ 2 ^ n := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [pow_succ]
    have hp : 1 ≤ 2 ^ n := one_le_pow₀ (by omega)
    omega

/-- Every finite multiple of `epsilon` is below one.  This is the precise
non-Archimedean property needed for point probabilities. -/
theorem nsmul_epsilon_lt_one (n : ℕ) : n • epsilon < 1 := by
  have hdyadic := epsilon_lt_powHalf n
  have hscale : n • epsilon ≤ (2 ^ n : ℕ) • epsilon :=
    nsmul_le_nsmul_left epsilon_pos.le (nat_le_two_pow n)
  have hstrict : (2 ^ n : ℕ) • epsilon < (2 ^ n : ℕ) • Surreal.powHalf n :=
    nsmul_lt_nsmul_right (by positivity) hdyadic
  have hunit : (2 ^ n : ℕ) • Surreal.powHalf n = 1 := by
    simp [nsmul_eq_mul, Surreal.nsmul_pow_two_powHalf n]
  exact hscale.trans_lt (hstrict.trans_eq hunit)

/-- An event in the finite--cofinite Boolean algebra. -/
structure Event (α : Type*) where
  carrier : Set α
  finite_or_compl_finite : carrier.Finite ∨ carrierᶜ.Finite

namespace Event

instance {α : Type*} : SetLike (Event α) α where
  coe := carrier
  coe_injective' := by intro A B h; cases A; cases B; simp_all

@[ext] theorem ext {α : Type*} {A B : Event α} (h : (A : Set α) = B) : A = B :=
  SetLike.coe_injective h

/-- The empty event. -/
def empty (α : Type*) : Event α := ⟨∅, Or.inl Set.finite_empty⟩

/-- The certain event. -/
def univ (α : Type*) : Event α := ⟨Set.univ, Or.inr (by simp)⟩

/-- Complement in the finite--cofinite algebra. -/
def compl {α : Type*} (A : Event α) : Event α := by
  refine ⟨(A : Set α)ᶜ, ?_⟩
  simpa [compl_compl] using A.finite_or_compl_finite.symm

/-- Union in the finite--cofinite algebra. -/
def union {α : Type*} (A B : Event α) : Event α := by
  refine ⟨(A : Set α) ∪ B, ?_⟩
  rcases A.finite_or_compl_finite with hA | hA <;>
    rcases B.finite_or_compl_finite with hB | hB
  · exact Or.inl (hA.union hB)
  · exact Or.inr (by rw [Set.compl_union]; exact hB.inter_of_right _)
  · exact Or.inr (by rw [Set.compl_union]; exact hA.inter_of_left _)
  · exact Or.inr (by rw [Set.compl_union]; exact hA.inter_of_left _)

@[simp] theorem coe_mk {α : Type*} (s : Set α) (h) :
    ((⟨s, h⟩ : Event α) : Set α) = s := rfl
@[simp] theorem coe_empty {α : Type*} : (empty α : Set α) = ∅ := rfl
@[simp] theorem coe_univ {α : Type*} : (univ α : Set α) = Set.univ := rfl
@[simp] theorem coe_compl {α : Type*} (A : Event α) : (compl A : Set α) = (A : Set α)ᶜ := rfl
@[simp] theorem coe_union {α : Type*} (A B : Event α) :
    (union A B : Set α) = (A : Set α) ∪ B := rfl

end Event

/-- The surreal mass of a finite--cofinite event. -/
noncomputable def probability {α : Type*} (A : Event α) : Surreal := by
  classical
  exact if (A : Set α).Finite then (A : Set α).ncard • epsilon
    else 1 - (A : Set α)ᶜ.ncard • epsilon

/-- Finite events have cardinality times infinitesimal mass. -/
theorem probability_of_finite {α : Type*} (A : Event α) (hA : (A : Set α).Finite) :
    probability A = (A : Set α).ncard • epsilon := by
  classical
  simp [probability, hA]

/-- On an infinite sample space, cofinite events have mass one minus the mass of their complement. -/
theorem probability_of_compl_finite {α : Type*} [Infinite α] (A : Event α)
    (hA : (A : Set α)ᶜ.Finite) :
    probability A = 1 - (A : Set α)ᶜ.ncard • epsilon := by
  classical
  simp only [probability]
  split_ifs with h
  · exfalso
    apply Set.infinite_univ (by simpa only [Set.union_compl_self] using h.union hA)
  · rfl

/-- The total mass is one. -/
theorem probability_univ {α : Type*} [Infinite α] :
    probability (Event.univ α) = 1 := by
  rw [probability_of_compl_finite (hA := by simp)]
  simp

/-- Every singleton has the same nonzero infinitesimal probability. -/
theorem probability_singleton {α : Type*} (x : α) :
    probability (⟨{x}, Or.inl (Set.finite_singleton x)⟩ : Event α) = epsilon := by
  rw [probability_of_finite (hA := by simp)]
  simp

/-- The point mass is positive and smaller than every reciprocal dyadic scale. -/
theorem singleton_mass_is_infinitesimal {α : Type*} (x : α) :
    0 < probability (⟨{x}, Or.inl (Set.finite_singleton x)⟩ : Event α) ∧
      ∀ n : ℕ, probability (⟨{x}, Or.inl (Set.finite_singleton x)⟩ : Event α) <
        Surreal.powHalf n := by
  rw [probability_singleton]
  exact ⟨epsilon_pos, epsilon_lt_powHalf⟩

/-- Every event has nonnegative surreal mass. -/
theorem probability_nonneg {α : Type*} [Infinite α] (A : Event α) :
    0 ≤ probability A := by
  rcases A.finite_or_compl_finite with hA | hA
  · rw [probability_of_finite A hA]
    exact nsmul_nonneg epsilon_pos.le _
  · rw [probability_of_compl_finite A hA]
    exact sub_nonneg.mpr (nsmul_epsilon_lt_one _).le

/-- Finite additivity on disjoint events in the finite--cofinite algebra. -/
theorem probability_union_of_disjoint {α : Type*} [Infinite α] (A B : Event α)
    (hdisj : Disjoint (A : Set α) (B : Set α)) :
    probability (Event.union A B) = probability A + probability B := by
  rcases A.finite_or_compl_finite with hA | hA <;>
  rcases B.finite_or_compl_finite with hB | hB
  -- Case 1: Both finite
  · rw [probability_of_finite (hA := hA)]
    rw [probability_of_finite (hA := hB)]
    have hAB : (A.union B).carrier.Finite := hA.union hB
    rw [probability_of_finite (hA := hAB)]
    simp only [Event.coe_union]
    rw [Set.ncard_union_eq hdisj hA hB]
    rw [add_smul]
  -- Case 2: A finite, B cofinite
  · rw [probability_of_finite (hA := hA)]
    rw [probability_of_compl_finite (hA := hB)]
    have hAB_compl_finite : ((A.union B : Event α) : Set α)ᶜ.Finite := by
      simp only [Event.coe_union]
      rw [Set.compl_union]
      exact Set.Finite.subset hB Set.inter_subset_right
    rw [probability_of_compl_finite (hA := hAB_compl_finite)]
    simp only [Event.coe_union]
    -- Need: 1 - ncard(Aᶜ ∩ Bᶜ) • ε = ncard(A) • ε + (1 - ncard(Bᶜ) • ε)
    -- Equiv: ncard(Bᶜ) = ncard(A) + ncard(Aᶜ ∩ Bᶜ)
    have hA_subset_Bcompl : (A : Set α) ⊆ (B : Set α)ᶜ := by
      rw [Set.subset_compl_iff_disjoint_right]
      exact hdisj
    have hBcompl_eq : (B : Set α)ᶜ = (A : Set α) ∪ ((A : Set α)ᶜ ∩ (B : Set α)ᶜ) := by
      ext x; simp; tauto
    have hA_disj_Acompl_inter : Disjoint (A : Set α) ((A : Set α)ᶜ ∩ (B : Set α)ᶜ) :=
      Set.disjoint_left.mpr fun x hx h'x => False.elim (h'x.1 hx)
    have hAcompl_inter_Bcompl_finite : ((A : Set α)ᶜ ∩ (B : Set α)ᶜ).Finite := Set.Finite.subset hB Set.inter_subset_right
    rw [hBcompl_eq]
    rw [Set.ncard_union_eq hA_disj_Acompl_inter hA hAcompl_inter_Bcompl_finite]
    rw [Set.compl_union]
    ring_nf
  -- Case 3: A cofinite, B finite
  · rw [probability_of_compl_finite (hA := hA)]
    rw [probability_of_finite (hA := hB)]
    have hAB_compl_finite : ((A.union B : Event α) : Set α)ᶜ.Finite := by
      simp only [Event.coe_union]
      rw [Set.compl_union]
      exact Set.Finite.subset hA Set.inter_subset_left
    rw [probability_of_compl_finite (hA := hAB_compl_finite)]
    simp only [Event.coe_union]
    have hB_subset_Acompl : (B : Set α) ⊆ (A : Set α)ᶜ := by
      rw [Set.subset_compl_iff_disjoint_right]
      exact hdisj.symm
    have hAcompl_eq : (A : Set α)ᶜ = (B : Set α) ∪ ((A : Set α)ᶜ ∩ (B : Set α)ᶜ) := by
      ext x; simp; tauto
    have hB_disj_Acompl_inter : Disjoint (B : Set α) ((A : Set α)ᶜ ∩ (B : Set α)ᶜ) :=
      Set.disjoint_left.mpr fun x hx h'x => False.elim (h'x.2 hx)
    have hAcompl_inter_Bcompl_finite : ((A : Set α)ᶜ ∩ (B : Set α)ᶜ).Finite := Set.Finite.subset hA Set.inter_subset_left
    rw [hAcompl_eq]
    rw [Set.ncard_union_eq hB_disj_Acompl_inter hB hAcompl_inter_Bcompl_finite]
    rw [Set.compl_union]
    ring_nf
  -- Case 4: Both cofinite
  · -- This case is impossible: if A ∩ B = ∅ then Aᶜ ∪ Bᶜ = univ, but Aᶜ, Bᶜ finite implies Aᶜ ∪ Bᶜ finite
    exfalso
    have : ((A : Set α)ᶜ ∪ (B : Set α)ᶜ) = Set.univ := by
      rw [← Set.compl_inter]; simp [Set.disjoint_iff_inter_eq_empty.mp hdisj]
    exact Set.infinite_univ (by rw [← this]; exact Set.Finite.union hA hB)

/-- **Connector theorem.** On the real unit interval there is a normalized finitely additive
surreal-valued probability on the finite--cofinite event algebra, every point has the same
strictly positive infinitesimal mass, and disjoint finite unions are additive. -/
theorem unitInterval_surreal_probability_connector :
    probability (Event.univ (Set.Icc (0 : ℝ) 1)) = 1 ∧
    (∀ x : Set.Icc (0 : ℝ) 1,
      0 < probability (⟨{x}, Or.inl (Set.finite_singleton x)⟩ : Event _) ∧
      ∀ n : ℕ, probability (⟨{x}, Or.inl (Set.finite_singleton x)⟩ : Event _) <
        Surreal.powHalf n) ∧
    (∀ A B : Event (Set.Icc (0 : ℝ) 1), Disjoint A.carrier B.carrier →
      probability (Event.union A B) = probability A + probability B) := by
  letI : Infinite (Set.Icc (0 : ℝ) 1) := Set.Infinite.to_subtype (Set.Icc_infinite zero_lt_one)
  exact ⟨probability_univ, singleton_mass_is_infinitesimal,
    probability_union_of_disjoint⟩

end SurrealFiniteCofiniteProbability