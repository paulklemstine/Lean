/-
# The converse of the abelianization law

`Core.lean` proves the *forward* law: if the factorization type determines the
abelianization coset then `I(T;C) = H(C)`, so the channel is saturated.  This file proves
the converse, which the program listed as an open frontier:

> **`mutualInfo_eq_Hcoset_iff_determines`** — for any finite type/coset table,
> `I(T;C) = H(C)` **if and only if** the type determines the coset (every type occurs
> with a single coset).

The mechanism is a sharp version of the row inequality: the entropy of a row of the joint
table is at least the `negMulLog` of its total mass, with equality exactly when the row is
supported on a single cell.  Together with `Core`'s nonnegativity results this pins the
saturating tables exactly.

Consequences recorded here: the `D₅` and `S₅` and `A₅` cells saturate the law, while the
`F₂₀` cell provably does *not* — its type `[4]` is genuinely ambiguous between the two
generators of `C₄`, and `I = 3/2 < 2 = H(C)`.
-/
import MachineLearning.QuinticTypeChannel.QuinticRow

open Finset Real

namespace TypeChannel
namespace Joint

variable {ι κ : Type} [Fintype ι] [Fintype κ] (J : Joint ι κ)

/-- Strict form of the pointwise bound: if `0 < x < S` then `x·(-log S) < negMulLog x`. -/
lemma negMulLog_gt_of_lt {x S : ℝ} (hx : 0 < x) (hxS : x < S) :
    x * (-Real.log S) < negMulLog x := by
  have hlog : Real.log x < Real.log S := Real.log_lt_log hx hxS
  have := mul_lt_mul_of_pos_left hlog hx
  simp only [negMulLog]
  nlinarith

/-- Each row of the joint table has entropy at least that of its total mass. -/
lemma row_le (t : ι) :
    negMulLog (J.typeMarg t) ≤ ∑ c : κ, negMulLog (J.p t c) := by
  have hexp : negMulLog (J.typeMarg t) = ∑ c : κ, J.p t c * (-Real.log (J.typeMarg t)) := by
    rw [← Finset.sum_mul, show ∑ c : κ, J.p t c = J.typeMarg t from rfl, negMulLog]
    ring
  rw [hexp]
  exact Finset.sum_le_sum fun c _ =>
    negMulLog_ge_of_le (J.nonneg t c) (J.le_typeMarg t c)

/-- **Sharpness of the row bound**: if two different cosets occur with the same type, the
row entropy strictly exceeds the entropy of its mass. -/
lemma row_lt_of_two_cells {t : ι} {c₁ c₂ : κ} (hne : c₁ ≠ c₂)
    (h₁ : 0 < J.p t c₁) (h₂ : 0 < J.p t c₂) :
    negMulLog (J.typeMarg t) < ∑ c : κ, negMulLog (J.p t c) := by
  classical
  have hsum2 : J.p t c₁ + J.p t c₂ ≤ J.typeMarg t := by
    have : ({c₁, c₂} : Finset κ) ⊆ univ := subset_univ _
    have hpair : ∑ c ∈ ({c₁, c₂} : Finset κ), J.p t c = J.p t c₁ + J.p t c₂ := by
      rw [Finset.sum_pair hne]
    calc J.p t c₁ + J.p t c₂ = ∑ c ∈ ({c₁, c₂} : Finset κ), J.p t c := hpair.symm
      _ ≤ ∑ c : κ, J.p t c :=
          Finset.sum_le_sum_of_subset_of_nonneg this (fun c _ _ => J.nonneg t c)
  have hstrict : J.p t c₁ < J.typeMarg t := by linarith
  have hexp : negMulLog (J.typeMarg t) = ∑ c : κ, J.p t c * (-Real.log (J.typeMarg t)) := by
    rw [← Finset.sum_mul, show ∑ c : κ, J.p t c = J.typeMarg t from rfl, negMulLog]
    ring
  rw [hexp]
  refine Finset.sum_lt_sum (fun c _ => negMulLog_ge_of_le (J.nonneg t c) (J.le_typeMarg t c))
    ⟨c₁, mem_univ c₁, negMulLog_gt_of_lt h₁ hstrict⟩

/-- **The converse of the abelianization law.**  A finite type/coset table saturates the
law `I(T;C) = H(C)` exactly when the type determines the coset. -/
theorem mutualInfo_eq_Hcoset_iff_determines :
    J.mutualInfo = J.Hcoset ↔ ∀ t c c', 0 < J.p t c → 0 < J.p t c' → c = c' := by
  constructor
  · intro hsat t c c' hc hc'
    by_contra hne
    have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    -- saturation forces `H(T, C) = H(T)`
    have hHj : J.Hjoint = J.Htype := by
      unfold mutualInfo at hsat
      linarith
    have hnat : ∑ t : ι, ∑ c : κ, negMulLog (J.p t c) = ∑ t : ι, negMulLog (J.typeMarg t) := by
      unfold Hjoint Htype at hHj
      field_simp at hHj
      exact hHj
    -- but the row at `t` is strictly bigger, while all rows are at least as big
    have hstrict := J.row_lt_of_two_cells hne hc hc'
    have hall : ∀ t' ∈ (univ : Finset ι), negMulLog (J.typeMarg t')
        ≤ ∑ c : κ, negMulLog (J.p t' c) := fun t' _ => J.row_le t'
    have : ∑ t : ι, negMulLog (J.typeMarg t) < ∑ t : ι, ∑ c : κ, negMulLog (J.p t c) :=
      Finset.sum_lt_sum hall ⟨t, mem_univ t, hstrict⟩
    linarith [hnat]
  · exact fun h => J.mutualInfo_eq_Hcoset_of_determines h

/-- Contrapositive form: an ambiguous type strictly lowers the transmitted information
below the coset entropy. -/
theorem mutualInfo_lt_Hcoset_of_ambiguous {t : ι} {c c' : κ} (hne : c ≠ c')
    (hc : 0 < J.p t c) (hc' : 0 < J.p t c') :
    J.mutualInfo < J.Hcoset := by
  refine lt_of_le_of_ne J.mutualInfo_le_Hcoset ?_
  intro heq
  exact hne ((J.mutualInfo_eq_Hcoset_iff_determines.mp heq) t c c' hc hc')

end Joint

namespace QuinticRow

/-- The `F₂₀` cell provably fails to saturate: its type `[4]` straddles two cosets of
`C₄`, so `I = 3/2 < 2 = H(C)`. -/
theorem F20_p_two_one : F20.p 2 1 = 1/4 := by simp [F20]

theorem F20_p_two_three : F20.p 2 3 = 1/4 := by simp [F20]

theorem F20_not_determines : ¬ (∀ t c c', 0 < F20.p t c → 0 < F20.p t c' → c = c') := by
  intro h
  have h1 : (0:ℝ) < F20.p 2 1 := by rw [F20_p_two_one]; norm_num
  have h2 : (0:ℝ) < F20.p 2 3 := by rw [F20_p_two_three]; norm_num
  exact absurd (h 2 1 3 h1 h2) (by decide)

/-- Consequently the `F₂₀` information is strictly below its coset entropy — the quintic
row's only strictly sub-saturating cell with nontrivial abelianization. -/
theorem F20_mutualInfo_lt_Hcoset : F20.mutualInfo < F20.Hcoset := by
  refine F20.mutualInfo_lt_Hcoset_of_ambiguous (t := 2) (c := 1) (c' := 3) (by decide) ?_ ?_
  · rw [F20_p_two_one]; norm_num
  · rw [F20_p_two_three]; norm_num

/-- The saturating cells of the quintic row are exactly `D₅`, `A₅` and `S₅`. -/
theorem saturating_cells :
    D5.mutualInfo = D5.Hcoset ∧ A5.mutualInfo = A5.Hcoset ∧ S5.mutualInfo = S5.Hcoset ∧
    F20.mutualInfo ≠ F20.Hcoset :=
  ⟨D5.mutualInfo_eq_Hcoset_iff_determines.mpr D5_determines,
   A5.mutualInfo_eq_Hcoset_iff_determines.mpr A5_determines,
   S5.mutualInfo_eq_Hcoset_iff_determines.mpr S5_determines,
   ne_of_lt F20_mutualInfo_lt_Hcoset⟩

end QuinticRow
end TypeChannel