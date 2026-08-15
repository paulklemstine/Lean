import Tropical.SmoothSelfHintDichotomyCore

/-!
# Mutual information of the divisibility self-hint

This file turns the counting dichotomy of `Tropical.SmoothSelfHintDichotomyCore` into
the information-theoretic quantities that were *measured* in Experiment 389.

* `SmoothSelfHint.miF` — mutual information (in bits) of a finite joint distribution.
* `SmoothSelfHint.miF_of_product` — a product distribution carries zero information.
* `SmoothSelfHint.miF_asym_zero` — **for every finite group `G` and every subset
  `A ⊆ G`** the joint law of (`a ∈ A?`, the product `a*b`) is a product law, hence
  `I(a*b ; a ∈ A) = 0` *exactly*.  This is the theoretical counterpart of the measured
  `I(N mod l ; l ∣ p-1) = 0.0000–0.0005` bits: the measurement is not "small", it is
  structurally zero.
* `SmoothSelfHint.mi_sym_three` — the symmetric event at `l = 3` has
  `I = 3/2 - (3/4)·log₂ 3` bits **exactly**, and
  `SmoothSelfHint.mi_sym_three_bounds` shows this lies in `(0.30, 0.32)`, matching the
  measured `0.313` bits.
* `SmoothSelfHint.Psym_eq_group_model` / `Pasym_eq_group_model` — the two `2 × 2`
  tables really are the normalised fibre counts of the group model at `l = 3`, so the
  numbers above are theorems about the arithmetic situation, not about invented data.
-/

open Finset

namespace SmoothSelfHint

/-! ## Mutual information of a finite joint distribution -/

/-- Mutual information, in bits, of a joint distribution `P` on `X × Y`
(with the usual convention `0 · log 0 = 0`, which Lean's `Real.log 0 = 0` provides). -/
noncomputable def miF {X Y : Type*} [Fintype X] [Fintype Y] (P : X → Y → ℝ) : ℝ :=
  ∑ x, ∑ y, P x y * Real.logb 2 (P x y / ((∑ y', P x y') * (∑ x', P x' y)))

/-- A product distribution has zero mutual information. -/
theorem miF_of_product {X Y : Type*} [Fintype X] [Fintype Y] (r : X → ℝ) (c : Y → ℝ)
    (hr : ∑ x, r x = 1) (hc : ∑ y, c y = 1) :
    miF (fun x y => r x * c y) = 0 := by
  unfold miF
  refine Finset.sum_eq_zero fun x _ => Finset.sum_eq_zero fun y _ => ?_
  have h1 : ∑ y', r x * c y' = r x := by rw [← Finset.mul_sum, hc, mul_one]
  have h2 : ∑ x', r x' * c y = c y := by rw [← Finset.sum_mul, hr, one_mul]
  simp only [h1, h2]
  by_cases h : r x * c y = 0
  · rw [h]; ring
  · rw [div_self h]; simp

/-! ## Zero asymmetric leak, in complete generality -/

section Group

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- The joint law of the pair (does the first factor lie in `A`?, what is the product?)
for a uniformly random ordered pair `(a, b) ∈ G × G`. -/
noncomputable def jointAsym (A : Finset G) : Bool → G → ℝ := fun e n =>
  ((if e then (asymFiber A n).card else (asymFiber Aᶜ n).card : ℕ) : ℝ)
    / (Fintype.card G : ℝ) ^ 2

/-- **The asymmetric leak is exactly zero.**  For a uniformly random ordered
factorisation, the one-sided event `a ∈ A` is independent of the product `a * b`; in
particular the mutual information vanishes identically.  Taking `G = (ZMod l)ˣ` and
`A = {1}` this says: the residue `N mod l` carries *no* information about `l ∣ p - 1`. -/
theorem miF_asym_zero (A : Finset G) : miF (jointAsym A) = 0 := by
  have hpos : 0 < Fintype.card G := Fintype.card_pos
  have hNne : ((Fintype.card G : ℕ) : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hpos.ne'
  have key : jointAsym A = fun (e : Bool) (n : G) =>
      ((if e then (A.card : ℝ) else (Aᶜ.card : ℝ)) / (Fintype.card G : ℝ)) *
        (1 / (Fintype.card G : ℝ)) := by
    funext e n
    cases e <;> simp [jointAsym, asym_fiber_card, sq] <;> field_simp
  rw [key]
  refine miF_of_product _ _ ?_ ?_
  · rw [Fintype.sum_bool]
    simp only [if_true, if_false, Bool.false_eq_true]
    rw [← add_div, div_eq_one_iff_eq hNne]
    exact_mod_cast Finset.card_add_card_compl A
  · rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    field_simp

end Group

/-! ## The `l = 3` tables and their exact mutual informations -/

/-- The joint law of `(N mod 3, [3 ∣ p-1])` in the group model: rows are the two
residues `1, -1` of `N`, columns are the two truth values of the asymmetric event. -/
noncomputable def Pasym : Fin 2 → Fin 2 → ℝ := ![![1/4, 1/4], ![1/4, 1/4]]

/-- The joint law of `(N mod 3, [3 ∣ p-1 ∨ 3 ∣ q-1])`: at `N ≡ -1 (mod 3)` the
symmetric event is forced, which is exactly the zero in the corner. -/
noncomputable def Psym : Fin 2 → Fin 2 → ℝ := ![![1/4, 1/4], ![1/2, 0]]

instance : Fact (Nat.Prime 3) := ⟨by norm_num⟩

theorem neg_one_ne_one_units_three : (-1 : (ZMod 3)ˣ) ≠ 1 := by decide

/-- The `Pasym` table *is* the group model: its entries are the normalised counts of
the fibres of multiplication on `(ZMod 3)ˣ × (ZMod 3)ˣ`. -/
theorem Pasym_eq_group_model :
    Pasym 0 0 = ((asymFiber ({1} : Finset (ZMod 3)ˣ) 1).card : ℝ) / 4 ∧
    Pasym 1 0 = ((asymFiber ({1} : Finset (ZMod 3)ˣ) (-1)).card : ℝ) / 4 ∧
    Pasym 0 1 = ((asymFiber ({1} : Finset (ZMod 3)ˣ)ᶜ 1).card : ℝ) / 4 ∧
    Pasym 1 1 = ((asymFiber ({1} : Finset (ZMod 3)ˣ)ᶜ (-1)).card : ℝ) / 4 := by
  have hc : (Fintype.card (ZMod 3)ˣ) = 2 := by decide
  have h1 : (({1} : Finset (ZMod 3)ˣ)ᶜ).card = 1 := by decide
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp [Pasym, asym_fiber_card, h1]

/-- The `Psym` table *is* the group model: the corner zero is the statement that at
`N ≡ -1 (mod 3)` every factorisation has a factor equal to `1`. -/
theorem Psym_eq_group_model :
    Psym 0 0 = ((symFiber ({1} : Finset (ZMod 3)ˣ) 1).card : ℝ) / 4 ∧
    Psym 1 0 = ((symFiber ({1} : Finset (ZMod 3)ˣ) (-1)).card : ℝ) / 4 ∧
    Psym 0 1 = ((Fintype.card (ZMod 3)ˣ - (symFiber ({1} : Finset (ZMod 3)ˣ) 1).card : ℕ) : ℝ) / 4 ∧
    Psym 1 1 =
      ((Fintype.card (ZMod 3)ˣ - (symFiber ({1} : Finset (ZMod 3)ˣ) (-1)).card : ℕ) : ℝ) / 4 := by
  have hc : (Fintype.card (ZMod 3)ˣ) = 2 := by decide
  refine ⟨?_, ?_, ?_, ?_⟩
  all_goals simp [Psym, sym_fiber_card_one, neg_one_ne_one_units_three, hc]
  all_goals norm_num

/-- **Zero measured leak.**  The asymmetric table is uniform, so its mutual
information is `0` bits — the theoretical value behind the measured `0.0000` bits. -/
theorem mi_asym_three : miF Pasym = 0 := by
  have h : Pasym = fun i j => (fun _ : Fin 2 => (1:ℝ)/2) i * (fun _ : Fin 2 => (1:ℝ)/2) j := by
    funext i j
    fin_cases i <;> fin_cases j <;> norm_num [Pasym]
  rw [h]
  exact miF_of_product _ _ (by norm_num [Fin.sum_univ_two]) (by norm_num [Fin.sum_univ_two])

theorem logb2_two : Real.logb 2 (2:ℝ) = 1 := Real.logb_self_eq_one (by norm_num)

theorem logb2_four : Real.logb 2 (4:ℝ) = 2 := by
  rw [show (4:ℝ) = 2 * 2 by norm_num, Real.logb_mul (by norm_num) (by norm_num), logb2_two]
  norm_num

/-- **Exact symmetric leak.**  The mutual information between `N mod 3` and the
symmetric divisibility event is `3/2 - (3/4)·log₂ 3` bits. -/
theorem mi_sym_three : miF Psym = 3/2 - (3/4) * Real.logb 2 3 := by
  have h23 : Real.logb 2 ((2:ℝ)/3) = 1 - Real.logb 2 3 := by
    rw [Real.logb_div (by norm_num) (by norm_num), logb2_two]
  have h43 : Real.logb 2 ((4:ℝ)/3) = 2 - Real.logb 2 3 := by
    rw [Real.logb_div (by norm_num) (by norm_num), logb2_four]
  simp only [miF, Psym, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
  norm_num [h23, h43]
  ring

/-- `19/12 < log₂ 3` because `3¹² = 531441 > 524288 = 2¹⁹`. -/
theorem logb2_three_lower : (19:ℝ)/12 < Real.logb 2 3 := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((2:ℝ)^(19:ℕ)) < Real.log ((3:ℝ)^(12:ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ hl2]
  push_cast at h
  linarith

/-- `log₂ 3 < 27/17` because `3¹⁷ = 129140163 < 134217728 = 2²⁷`. -/
theorem logb2_three_upper : Real.logb 2 3 < (27:ℝ)/17 := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((3:ℝ)^(17:ℕ)) < Real.log ((2:ℝ)^(27:ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ hl2]
  push_cast at h
  linarith

/-- The exact value lies in `(0.30, 0.32)`: the experiment reported `0.313` bits. -/
theorem mi_sym_three_bounds : 0.30 < miF Psym ∧ miF Psym < 0.32 := by
  rw [mi_sym_three]
  constructor
  · have := logb2_three_upper
    nlinarith [logb2_three_upper]
  · have := logb2_three_lower
    nlinarith [logb2_three_lower]

/-- **The dichotomy, quantified.**  At `l = 3` the symmetric event leaks strictly more
than the asymmetric one, which leaks nothing at all. -/
theorem asym_sym_information_gap : miF Pasym = 0 ∧ 0.30 < miF Psym :=
  ⟨mi_asym_three, mi_sym_three_bounds.1⟩

end SmoothSelfHint