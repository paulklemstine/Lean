/-
# Conjugacy, not equality: the exact shape of the covering classification

The Galois correspondence of `FundamentalGroupCoveringGalois` says that connected
coverings of a `K(G,1)` are classified by *conjugacy classes* of subgroups of `G`.  This
file makes the gap between "subgroup" and "conjugacy class of subgroup" completely
explicit with two contrasting finite examples.

* **Abelian base (Klein four group).**  Conjugacy is trivial, so subgroups *are*
  coverings.  We exhibit the three index-two subgroups `Hfst`, `Hsnd`, `Hdiag` of
  `V = C₂ × C₂`, prove that these are *exactly* the index-two subgroups
  (`index_two_eq_of_klein`), and deduce that the `K(V,1)` has exactly three pairwise
  non-isomorphic connected double coverings, all of them with the same fundamental group
  `C₂` (`klein_three_double_coverings`).

* **Non-abelian base (symmetric group `S₃`).**  Here two *different* subgroups can give
  the *same* covering: the point stabilisers of `0` and `1` in `S₃ ⟳ Fin 3` are distinct
  (`stab_zero_ne_stab_one`) but conjugate (`stab_one_eq_conj`), so the two associated
  three-sheeted coverings are isomorphic (`s3_coverings_isomorphic`).

Read together (`conjugacy_is_the_right_equivalence`) the two examples pin down the
classification exactly: equality of subgroups is too fine, isomorphism of fundamental
groups is too coarse, and conjugacy is precisely right.
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois
import Bridges.FundamentalGroupCoveringExamples
import Bridges.FundamentalGroupCoveringExactSequence

open CategoryTheory MulAction Equiv

namespace FundamentalGroupCovering

/-! ## The three double coverings of a `K(V,1)` -/

section Klein

/-- The multiplication homomorphism `C₂ × C₂ →* C₂`. -/
def mulMapV : V →* C2 := (MonoidHom.fst C2 C2) * (MonoidHom.snd C2 C2)

/-- The diagonal subgroup of the Klein four group, the third subgroup of index two. -/
def Hdiag : Subgroup V := mulMapV.ker

theorem mem_Hdiag_iff (x : V) : x ∈ Hdiag ↔ x.1 * x.2 = 1 := Iff.rfl

theorem mulMapV_surjective : Function.Surjective mulMapV := by
  intro a
  exact ⟨(a, 1), by simp [mulMapV]⟩

theorem card_V : Nat.card V = 4 := by
  simp [Nat.card_eq_fintype_card]

theorem index_Hdiag : Hdiag.index = 2 := by
  rw [Hdiag, Subgroup.index_ker, MonoidHom.range_eq_top.mpr mulMapV_surjective,
    Subgroup.card_top, card_C2]

theorem mem_Hfst_iff (x : V) : x ∈ Hfst ↔ x.2 = 1 := by
  constructor
  · intro hx
    exact Subgroup.mem_bot.mp (Subgroup.mem_prod.mp hx).2
  · intro hx
    exact Subgroup.mem_prod.mpr ⟨trivial, by rw [hx]; exact Subgroup.mem_bot.mpr rfl⟩

theorem mem_Hsnd_iff (x : V) : x ∈ Hsnd ↔ x.1 = 1 := by
  constructor
  · intro hx
    exact Subgroup.mem_bot.mp (Subgroup.mem_prod.mp hx).1
  · intro hx
    exact Subgroup.mem_prod.mpr ⟨by rw [hx]; exact Subgroup.mem_bot.mpr rfl, trivial⟩

/-- The nontrivial element of `C₂`. -/
def g2 : C2 := Multiplicative.ofAdd (1 : ZMod 2)

/-- The four elements of the Klein four group. -/
theorem V_cases (x : V) :
    x = 1 ∨ x = ((g2, 1) : V) ∨ x = ((1, g2) : V) ∨ x = ((g2, g2) : V) := by
  revert x; decide

theorem V_cases_snd_one {x : V} (h : x.2 = 1) : x = 1 ∨ x = ((g2, 1) : V) := by
  revert h; revert x; decide

theorem V_cases_fst_one {x : V} (h : x.1 = 1) : x = 1 ∨ x = ((1, g2) : V) := by
  revert h; revert x; decide

theorem V_cases_mul_one {x : V} (h : x.1 * x.2 = 1) : x = 1 ∨ x = ((g2, g2) : V) := by
  revert h; revert x; decide

theorem Hfst_ne_Hdiag : Hfst ≠ Hdiag := by
  intro h
  have hmem : ((g2, 1) : V) ∈ Hfst := (mem_Hfst_iff _).mpr rfl
  rw [h, mem_Hdiag_iff] at hmem
  simp only [mul_one] at hmem
  exact absurd hmem (by decide)

theorem Hsnd_ne_Hdiag : Hsnd ≠ Hdiag := by
  intro h
  have hmem : ((1, g2) : V) ∈ Hsnd := (mem_Hsnd_iff _).mpr rfl
  rw [h, mem_Hdiag_iff] at hmem
  simp only [one_mul] at hmem
  exact absurd hmem (by decide)

theorem card_of_index_two {H : Subgroup V} (h : H.index = 2) : Nat.card H = 2 := by
  have := Subgroup.card_mul_index H
  rw [h, card_V] at this
  omega

theorem card_Hfst : Nat.card Hfst = 2 := card_of_index_two index_Hfst
theorem card_Hsnd : Nat.card Hsnd = 2 := card_of_index_two index_Hsnd
theorem card_Hdiag : Nat.card Hdiag = 2 := card_of_index_two index_Hdiag

/-- **The Klein four group has exactly three subgroups of index two.**  Consequently the
`K(V,1)` has exactly three connected double coverings. -/
theorem index_two_eq_of_klein {H : Subgroup V} (h : H.index = 2) :
    H = Hfst ∨ H = Hsnd ∨ H = Hdiag := by
  have hcard : Nat.card H = 2 := card_of_index_two h
  -- pick a non-identity element of `H`
  have hne : (H : Subgroup V) ≠ ⊥ := by
    intro hbot
    rw [hbot] at hcard
    simp at hcard
  rw [Subgroup.ne_bot_iff_exists_ne_one] at hne
  obtain ⟨⟨x, hxH⟩, hx1'⟩ := hne
  have hx1 : x ≠ 1 := by simpa using hx1'
  have hcases : x = ((g2, 1) : V) ∨ x = ((1, g2) : V) ∨ x = ((g2, g2) : V) := by
    rcases V_cases x with h1 | h | h | h
    · exact absurd h1 hx1
    · exact Or.inl h
    · exact Or.inr (Or.inl h)
    · exact Or.inr (Or.inr h)
  rcases hcases with rfl | rfl | rfl
  · refine Or.inl (Subgroup.eq_of_le_of_card_ge ?_ ?_).symm
    · intro y hy
      rcases V_cases_snd_one ((mem_Hfst_iff y).mp hy) with rfl | rfl
      · exact one_mem H
      · exact hxH
    · rw [hcard, card_Hfst]
  · refine Or.inr (Or.inl (Subgroup.eq_of_le_of_card_ge ?_ ?_).symm)
    · intro y hy
      rcases V_cases_fst_one ((mem_Hsnd_iff y).mp hy) with rfl | rfl
      · exact one_mem H
      · exact hxH
    · rw [hcard, card_Hsnd]
  · refine Or.inr (Or.inr (Subgroup.eq_of_le_of_card_ge ?_ ?_).symm)
    · intro y hy
      rcases V_cases_mul_one ((mem_Hdiag_iff y).mp hy) with rfl | rfl
      · exact one_mem H
      · exact hxH
    · rw [hcard, card_Hdiag]

/-- The three double coverings are pairwise non-isomorphic (the base is abelian, so
isomorphic coverings have *equal* subgroups). -/
theorem klein_pairwise_non_isomorphic :
    ¬ Nonempty (GEquiv V (V ⧸ Hfst) (V ⧸ Hsnd)) ∧
      ¬ Nonempty (GEquiv V (V ⧸ Hfst) (V ⧸ Hdiag)) ∧
      ¬ Nonempty (GEquiv V (V ⧸ Hsnd) (V ⧸ Hdiag)) := by
  refine ⟨kleinCoverings_not_isomorphic, ?_, ?_⟩
  · intro h
    rw [nonempty_gEquiv_iff_stabilizer_eq_of_comm V_comm
        (((1 : V) : V ⧸ Hfst)) (((1 : V) : V ⧸ Hdiag)),
      MulAction.stabilizer_quotient, MulAction.stabilizer_quotient] at h
    exact Hfst_ne_Hdiag h.symm
  · intro h
    rw [nonempty_gEquiv_iff_stabilizer_eq_of_comm V_comm
        (((1 : V) : V ⧸ Hsnd)) (((1 : V) : V ⧸ Hdiag)),
      MulAction.stabilizer_quotient, MulAction.stabilizer_quotient] at h
    exact Hsnd_ne_Hdiag h.symm

/-- **Exactly three double coverings, all with the same fundamental group.**  The
`K(V,1)` carries three pairwise non-isomorphic connected double coverings; every double
covering is one of them; and the fundamental group of each total space is a group of
order two, so π₁ of the total space distinguishes none of them. -/
theorem klein_three_double_coverings :
    (Hfst.index = 2 ∧ Hsnd.index = 2 ∧ Hdiag.index = 2) ∧
      (∀ H : Subgroup V, H.index = 2 → H = Hfst ∨ H = Hsnd ∨ H = Hdiag) ∧
      (¬ Nonempty (GEquiv V (V ⧸ Hfst) (V ⧸ Hsnd)) ∧
        ¬ Nonempty (GEquiv V (V ⧸ Hfst) (V ⧸ Hdiag)) ∧
        ¬ Nonempty (GEquiv V (V ⧸ Hsnd) (V ⧸ Hdiag))) ∧
      (Nat.card Hfst = 2 ∧ Nat.card Hsnd = 2 ∧ Nat.card Hdiag = 2) :=
  ⟨⟨index_Hfst, index_Hsnd, index_Hdiag⟩, fun _ h => index_two_eq_of_klein h,
    klein_pairwise_non_isomorphic, ⟨card_Hfst, card_Hsnd, card_Hdiag⟩⟩

end Klein

/-! ## A non-abelian base: distinct subgroups, isomorphic coverings -/

section Symmetric

/-- The symmetric group on three letters, the fundamental group of the base. -/
abbrev S3 : Type := Equiv.Perm (Fin 3)

/-- The point stabiliser of `0`, a subgroup of index three. -/
def StabZero : Subgroup S3 := stabilizer S3 (0 : Fin 3)

/-- The point stabiliser of `1`, a different subgroup of index three. -/
def StabOne : Subgroup S3 := stabilizer S3 (1 : Fin 3)

theorem index_StabZero : StabZero.index = 3 := by
  rw [StabZero, MulAction.index_stabilizer_of_transitive]
  simp [Nat.card_eq_fintype_card]

theorem index_StabOne : StabOne.index = 3 := by
  rw [StabOne, MulAction.index_stabilizer_of_transitive]
  simp [Nat.card_eq_fintype_card]

/-- The two point stabilisers are **different** subgroups of `S₃`. -/
theorem stab_zero_ne_stab_one : StabZero ≠ StabOne := by
  intro h
  have hmem : Equiv.swap (1 : Fin 3) 2 ∈ StabZero := by
    show Equiv.swap (1 : Fin 3) 2 • (0 : Fin 3) = 0
    decide
  rw [h] at hmem
  have : ¬ (Equiv.swap (1 : Fin 3) 2 • (1 : Fin 3) = 1) := by decide
  exact this hmem

/-- ...but they are **conjugate**, by any permutation carrying `0` to `1`. -/
theorem stab_one_eq_conj :
    StabOne = StabZero.map (MulAut.conj (Equiv.swap (0 : Fin 3) 1)).toMonoidHom := by
  have hsmul : (Equiv.swap (0 : Fin 3) 1) • (0 : Fin 3) = (1 : Fin 3) := by decide
  have := MulAction.stabilizer_smul_eq_stabilizer_map_conj
    (Equiv.swap (0 : Fin 3) 1) (0 : Fin 3)
  rw [hsmul] at this
  exact this

/-- **The two three-sheeted coverings they classify are isomorphic.**  Over a non-abelian
base, distinct subgroups may well define the same covering. -/
theorem s3_coverings_isomorphic :
    Nonempty (GEquiv S3 (S3 ⧸ StabZero) (S3 ⧸ StabOne)) :=
  (quotient_coverings_iso_iff_conj StabZero StabOne).mpr
    ⟨Equiv.swap (0 : Fin 3) 1, stab_one_eq_conj⟩

end Symmetric

/-! ## Synthesis -/

/-- **Conjugacy is exactly the right equivalence.**

Over the abelian base `K(V,1)` two distinct index-two subgroups give non-isomorphic
coverings even though the total spaces have isomorphic fundamental groups: π₁ of the
total space is *too coarse* an invariant.

Over the non-abelian base `K(S₃,1)` two distinct index-three subgroups give *isomorphic*
coverings: the subgroup itself is *too fine* an invariant.

The conjugacy class of the subgroup — equivalently, the position of π₁ of the covering
inside π₁ of the base up to inner automorphism — is precisely what classifies. -/
theorem conjugacy_is_the_right_equivalence :
    (Hfst ≠ Hsnd ∧ Nonempty (Hfst ≃* Hsnd) ∧
        ¬ Nonempty (GEquiv V (V ⧸ Hfst) (V ⧸ Hsnd))) ∧
      (StabZero ≠ StabOne ∧ Nonempty (GEquiv S3 (S3 ⧸ StabZero) (S3 ⧸ StabOne))) :=
  ⟨⟨Hfst_ne_Hsnd, ⟨hfstMulEquivHsnd⟩, kleinCoverings_not_isomorphic⟩,
    ⟨stab_zero_ne_stab_one, s3_coverings_isomorphic⟩⟩

end FundamentalGroupCovering