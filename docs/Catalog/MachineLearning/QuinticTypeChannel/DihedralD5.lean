/-
# The `D₅` cell, realized inside the group

The `D₅` row of the quintic table is not just a numerical histogram: it is the class
statistics of the dihedral group of order 10 acting on the five roots of a quintic such
as `x⁵ + 20x + 32`.  This file builds that identification.

* `typeObs` is the factorization-type observable: the identity has type `[1⁵]`, a
  nontrivial rotation is a 5-cycle `[5]`, a reflection is a product of two transpositions
  `[1,2,2]`.  `typeObs_eq_*_iff_orderOf` shows the three types are exactly the three
  element orders `1, 5, 2`, so the observable is intrinsic (and `typeObs_conj` shows it is
  a class function, as a Frobenius type must be).
* `cosetObs` is the abelianization observable.  `cosetObs_mul` shows it is a
  homomorphism onto `Fin 2 ≅ C₂`, and `commutator_eq_rotations` identifies its kernel
  with the commutator subgroup: **every rotation is a single commutator**
  (`r k = ⁅s, r^{2k}⁆`), so `D₅^ab ≅ C₂` and `cosetObs` really is the abelianization map.
  Note this quadratic character is *not* the discriminant character: `D₅ ⊆ A₅`, so the
  discriminant is a square and its Kronecker symbol is trivial; the `C₂` lives in the
  quadratic resolvent field `K = ℚ(√−5)` instead.
* `table_eq` proves the group's own joint table equals the abstract `QuinticRow.D5`
  table, so the exact values `H(T) = 1/5 + (log₂5)/2` and `I(T;C) = 1` are theorems
  about the group.
-/
import MachineLearning.QuinticTypeChannel.GroupTable
import MachineLearning.QuinticTypeChannel.QuinticRow

open Finset DihedralGroup Subgroup

namespace TypeChannel
namespace DihedralD5

/-- The Galois group of a `D₅`-quintic: the dihedral group of order 10. -/
abbrev D : Type := DihedralGroup 5

/-- The factorization-type observable: `0 = [1⁵]`, `1 = [5]`, `2 = [1,2,2]`. -/
def typeObs : D → Fin 3
  | .r i => if i = 0 then 0 else 1
  | .sr _ => 2

/-- The abelianization observable: rotations `↦ 0`, reflections `↦ 1`. -/
def cosetObs : D → Fin 2
  | .r _ => 0
  | .sr _ => 1

/-! ### The coset observable is the abelianization map -/

theorem cosetObs_mul (g h : D) : cosetObs (g * h) = cosetObs g + cosetObs h := by
  cases g <;> cases h <;> simp [cosetObs, r_mul_r, r_mul_sr, sr_mul_r, sr_mul_sr]

theorem cosetObs_one : cosetObs (1 : D) = 0 := rfl

theorem cosetObs_inv (g : D) : cosetObs g⁻¹ = cosetObs g := by
  cases g <;> simp [cosetObs, inv_r, inv_sr]

theorem cosetObs_surjective : Function.Surjective cosetObs := by
  intro c
  fin_cases c
  · exact ⟨DihedralGroup.r 0, rfl⟩
  · exact ⟨DihedralGroup.sr 0, rfl⟩

/-- The rotation subgroup, i.e. the kernel of the abelianization observable. -/
def rotations : Subgroup D where
  carrier := {g | cosetObs g = 0}
  mul_mem' := by
    intro a b ha hb
    simp only [Set.mem_setOf_eq] at *
    rw [cosetObs_mul, ha, hb]; rfl
  one_mem' := cosetObs_one
  inv_mem' := by
    intro a ha
    simp only [Set.mem_setOf_eq] at *
    rw [cosetObs_inv]; exact ha

/-- Every rotation is a *single* commutator: `r k = ⁅sr 0, r (2k)⁆`. -/
theorem rotation_is_commutator (k : ZMod 5) :
    (DihedralGroup.r k : D) = ⁅(DihedralGroup.sr 0 : D), (DihedralGroup.r (2 * k) : D)⁆ := by
  rw [commutatorElement_def, inv_sr, inv_r, sr_mul_r, sr_mul_sr, r_mul_r]
  congr 1
  revert k
  decide

/-- **`D₅^ab ≅ C₂`**: the commutator subgroup is exactly the rotation subgroup, the
kernel of `cosetObs`. -/
theorem commutator_eq_rotations : commutator D = rotations := by
  apply le_antisymm
  · rw [_root_.commutator_def, Subgroup.commutator_le]
    intro g₁ _ g₂ _
    show cosetObs ⁅g₁, g₂⁆ = 0
    rw [commutatorElement_def, cosetObs_mul, cosetObs_mul, cosetObs_mul, cosetObs_inv,
      cosetObs_inv]
    generalize cosetObs g₁ = a
    generalize cosetObs g₂ = b
    revert a b
    decide
  · intro g hg
    have hg0 : cosetObs g = 0 := hg
    obtain ⟨k, rfl⟩ : ∃ k, g = DihedralGroup.r k := by
      cases g with
      | r i => exact ⟨i, rfl⟩
      | sr i => exact absurd hg0 (by simp [cosetObs])
    rw [rotation_is_commutator k, _root_.commutator_def]
    exact Subgroup.commutator_mem_commutator (mem_top _) (mem_top _)

/-! ### The type observable is a class function tied to element orders -/

theorem typeObs_conj : ∀ g h : D, typeObs (h * g * h⁻¹) = typeObs g := by decide

theorem typeObs_eq_zero_iff (g : D) : typeObs g = 0 ↔ g = 1 := by
  revert g
  decide

theorem orderOf_rotation_ne_one (i : ZMod 5) (hi : i ≠ 0) :
    orderOf (DihedralGroup.r i : D) = 5 := by
  rw [DihedralGroup.orderOf_r]
  fin_cases i
  · exact absurd rfl hi
  all_goals decide

theorem typeObs_eq_one_iff_orderOf (g : D) : typeObs g = 1 ↔ orderOf g = 5 := by
  cases g with
  | r i =>
    by_cases hi : i = 0
    · subst hi
      rw [show typeObs (DihedralGroup.r (0 : ZMod 5) : D) = 0 from rfl,
        show (DihedralGroup.r (0 : ZMod 5) : D) = 1 from r_zero, orderOf_one]
      decide
    · rw [show typeObs (DihedralGroup.r i : D) = 1 from by simp [typeObs, hi],
        orderOf_rotation_ne_one i hi]
      decide
  | sr i =>
    rw [show typeObs (DihedralGroup.sr i : D) = 2 from rfl, DihedralGroup.orderOf_sr]
    decide

theorem typeObs_eq_two_iff_orderOf (g : D) : typeObs g = 2 ↔ orderOf g = 2 := by
  cases g with
  | r i =>
    by_cases hi : i = 0
    · subst hi
      rw [show typeObs (DihedralGroup.r (0 : ZMod 5) : D) = 0 from rfl,
        show (DihedralGroup.r (0 : ZMod 5) : D) = 1 from r_zero, orderOf_one]
      decide
    · rw [show typeObs (DihedralGroup.r i : D) = 1 from by simp [typeObs, hi],
        orderOf_rotation_ne_one i hi]
      decide
  | sr i =>
    rw [show typeObs (DihedralGroup.sr i : D) = 2 from rfl, DihedralGroup.orderOf_sr]
    decide

/-- The type determines the abelianization coset: this is the `D₅` mechanism behind the
law.  (A rotation is `[1⁵]` or `[5]`; a reflection is `[1,2,2]`.) -/
theorem typeObs_determines_cosetObs : ∀ g g' : D, typeObs g = typeObs g' →
    cosetObs g = cosetObs g' := by decide

/-! ### The group table is the `D₅` row -/

theorem card_D : Fintype.card D = 10 := by decide

/-- The six cell counts of the `D₅` table: `[1⁵]` once, `[5]` four times (all rotations),
`[1,2,2]` five times (all reflections). -/
theorem count_cells (t : Fin 3) (c : Fin 2) :
    (univ.filter (fun g : D => typeObs g = t ∧ cosetObs g = c)).card
      = ![![1, 0], ![4, 0], ![0, 5]] t c := by
  revert t c
  decide

theorem table_eq : ofGroup D typeObs cosetObs = QuinticRow.D5 := by
  refine Joint.ext' ?_
  funext t c
  rw [ofGroup_p, card_D, count_cells]
  fin_cases t <;> fin_cases c <;> norm_num [QuinticRow.D5]

/-- The Chebotarev type histogram of a `D₅` quintic is `{1/10, 4/10, 5/10}`. -/
theorem type_histogram :
    (ofGroup D typeObs cosetObs).typeMarg 0 = 1/10 ∧
    (ofGroup D typeObs cosetObs).typeMarg 1 = 2/5 ∧
    (ofGroup D typeObs cosetObs).typeMarg 2 = 1/2 := by
  rw [table_eq]
  exact ⟨QuinticRow.D5_typeMarg_zero, QuinticRow.D5_typeMarg_one, QuinticRow.D5_typeMarg_two⟩

/-- `H(T) = 1/5 + (log₂5)/2 = 1.3610…` bits for the genuine group. -/
theorem group_Htype : (ofGroup D typeObs cosetObs).Htype = 1/5 + Real.logb 2 5 / 2 := by
  rw [table_eq]; exact QuinticRow.D5_Htype

/-- **The `D₅` cell, at group level**: the factorization type of a Frobenius class carries
exactly one bit about its abelianization coset. -/
theorem group_mutualInfo : (ofGroup D typeObs cosetObs).mutualInfo = 1 := by
  rw [ofGroup_mutualInfo_eq_Hcoset D typeObs cosetObs typeObs_determines_cosetObs, table_eq]
  exact QuinticRow.D5_Hcoset

/-- The `D₅` gap: the type entropy exceeds the transmitted information by exactly the
coset-conditioned type entropy `(log₂5)/2 - 4/5 = 0.3610…` bits. -/
theorem group_gap :
    (ofGroup D typeObs cosetObs).Htype - (ofGroup D typeObs cosetObs).mutualInfo
      = (ofGroup D typeObs cosetObs).condTypeGivenCoset :=
  Joint.gap_eq _

theorem group_gap_value :
    (ofGroup D typeObs cosetObs).condTypeGivenCoset = Real.logb 2 5 / 2 - 4/5 := by
  rw [← group_gap, group_Htype, group_mutualInfo]; ring

end DihedralD5
end TypeChannel