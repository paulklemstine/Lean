/-
# Hilbert class field descent for a cyclic class group

When the ideal class group of `K` is cyclic, the class-group Galois correspondence of
`Catalog.NumberTheory.HilbertClassFieldDescent` becomes completely explicit: intermediate fields
of the Hilbert class field datum are classified by their degree, and every divisor of the class
number occurs exactly once.

The two auxiliary results `Subgroup.eq_of_card_eq_of_isCyclic` and
`Subgroup.exists_card_eq_of_isCyclic` are the standard classification of subgroups of a finite
cyclic group by their order.
-/

import Catalog.NumberTheory.HilbertClassFieldDescent

open NumberField

namespace CyclicClassGroupDescent

/-- Two subgroups of a finite cyclic group with the same order coincide. -/
theorem Subgroup.eq_of_card_eq_of_isCyclic {G : Type*} [Group G] [Finite G] [IsCyclic G]
    {A B : Subgroup G} (h : Nat.card A = Nat.card B) : A = B := by
  classical
  cases nonempty_fintype G
  have hdpos : 0 < Nat.card A := Nat.card_pos
  have key : ∀ C : _root_.Subgroup G, Nat.card C = Nat.card A →
      (C : Set G).toFinset = Finset.univ.filter (fun a : G => a ^ Nat.card A = 1) := by
    intro C hC
    have hsub : (C : Set G).toFinset ⊆ Finset.univ.filter (fun a : G => a ^ Nat.card A = 1) := by
      intro x hx
      have hxC : x ∈ C := by simpa using hx
      have hx0 : (⟨x, hxC⟩ : C) ^ Nat.card C = 1 := pow_card_eq_one'
      have hx1 : x ^ Nat.card C = 1 := by
        exact_mod_cast congrArg (_root_.Subgroup.subtype C) hx0
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      rw [← hC]
      exact hx1
    refine Finset.eq_of_subset_of_card_le hsub ?_
    have h1 : (Finset.univ.filter (fun a : G => a ^ Nat.card A = 1)).card ≤ Nat.card A :=
      IsCyclic.card_pow_eq_one_le hdpos
    have h2 : (C : Set G).toFinset.card = Nat.card A := by
      rw [← hC, Nat.card_eq_fintype_card]
      simp
    omega
  have hAB := (key A rfl).trans (key B h.symm).symm
  apply SetLike.coe_injective
  have hset := congrArg (fun s : Finset G => (s : Set G)) hAB
  simpa using hset

/-- A finite cyclic group has a subgroup of every order dividing its order. -/
theorem Subgroup.exists_card_eq_of_isCyclic {G : Type*} [Group G] [Finite G] [IsCyclic G]
    {d : ℕ} (hd : d ∣ Nat.card G) : ∃ S : Subgroup G, Nat.card S = d := by
  obtain ⟨g, hg⟩ := IsCyclic.exists_ofOrder_eq_natCard (α := G)
  refine ⟨_root_.Subgroup.zpowers (g ^ (Nat.card G / d)), ?_⟩
  have hne : Nat.card G ≠ 0 := Nat.card_pos.ne'
  rw [Nat.card_zpowers, orderOf_pow, hg, Nat.gcd_eq_right (Nat.div_dvd_of_dvd hd),
    Nat.div_div_self hd hne]

noncomputable section

/-- **Classification of intermediate fields for a cyclic class group.**  If the ideal class group
of `K` is cyclic, then for every divisor `d` of the class number there is exactly one
intermediate field of the Hilbert class field datum of degree `d` over `K`. -/
theorem existsUnique_intermediateField_finrank
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    [IsCyclic (ClassGroup (RingOfIntegers K))]
    (d : ℕ) (hd : d ∣ classNumber K) :
    ∃! L : IntermediateField K H, Module.finrank K L = d := by
  have hcl : Nat.card (ClassGroup (RingOfIntegers K)) = classNumber K := by
    rw [Nat.card_eq_fintype_card]; rfl
  have hpos : 0 < classNumber K := by
    rw [← hcl]; exact Nat.card_pos
  have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hd hpos
  obtain ⟨m, hm⟩ := hd
  have hmpos : 0 < m := by
    rcases Nat.eq_zero_or_pos m with h | h
    · rw [h, Nat.mul_zero] at hm; omega
    · exact h
  obtain ⟨S, hS⟩ := Subgroup.exists_card_eq_of_isCyclic
    (G := ClassGroup (RingOfIntegers K)) (d := m) ⟨d, by rw [hcl, hm, Nat.mul_comm]⟩
  have hidx : S.index = d := by
    have hmul := Subgroup.index_mul_card S
    rw [hS, hcl, hm] at hmul
    exact Nat.eq_of_mul_eq_mul_right hmpos hmul
  refine ⟨HilbertClassFieldDescent.classField K H e S, ?_, ?_⟩
  · show Module.finrank K (HilbertClassFieldDescent.classField K H e S) = d
    rw [HilbertClassFieldDescent.finrank_classField K H e S, hidx]
  · intro L' hL'
    have h1 : (HilbertClassFieldDescent.artinImage K H e L').index = d := by
      rw [← HilbertClassFieldDescent.finrank_eq_index K H e L']; exact hL'
    have h2 : Nat.card (HilbertClassFieldDescent.artinImage K H e L') = Nat.card S := by
      have e1 := Subgroup.index_mul_card (HilbertClassFieldDescent.artinImage K H e L')
      have e2 := Subgroup.index_mul_card S
      rw [h1] at e1
      rw [hidx] at e2
      exact Nat.eq_of_mul_eq_mul_left hdpos (e1.trans e2.symm)
    have h3 : HilbertClassFieldDescent.artinImage K H e L' = S :=
      Subgroup.eq_of_card_eq_of_isCyclic h2
    refine HilbertClassFieldDescent.artinImage_injective K H e ?_
    rw [h3, HilbertClassFieldDescent.artinImage_classField]

/-- **Non-vacuity.**  The classification instantiates at the catalog's `ℚ` witness: the class
group of `ℤ` is trivial, hence cyclic, and `ℚ` has exactly one intermediate field of degree one
inside its (trivial) Hilbert class field. -/
theorem existsUnique_intermediateField_finrank_rat :
    ∃! L : IntermediateField ℚ ℚ, Module.finrank ℚ L = 1 := by
  haveI : Subsingleton (ClassGroup (RingOfIntegers ℚ)) :=
    Fintype.card_le_one_iff_subsingleton.mp (le_of_eq Rat.classNumber_eq)
  exact existsUnique_intermediateField_finrank ℚ ℚ HilbertClassFieldReciprocity.witnessRat 1
    (one_dvd _)

end

end CyclicClassGroupDescent