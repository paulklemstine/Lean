import Tropical.SmoothSelfHintInformation

/-!
# Positivity of the symmetric leak, for every `l`

`SmoothSelfHintInformation` computes the two mutual informations at `l = 3` exactly.
Here we prove the general statements behind those numbers:

* `SmoothSelfHint.miF_nonneg` — mutual information of a finite joint distribution is
  never negative (Gibbs' inequality, via `log t ≤ t - 1`);
* `SmoothSelfHint.miF_pos_of_not_product` — it is **strictly** positive as soon as the
  joint distribution differs from the product of its marginals at a single cell;
* `SmoothSelfHint.symJoint` — the joint law of `(N mod l, [l ∣ p-1 ∨ l ∣ q-1])` in the
  uniform ordered-pair model, built from the fibre counts of the core file;
* `SmoothSelfHint.mi_sym_pos` — **for every odd prime `l` the symmetric event leaks a
  strictly positive number of bits**, while (`miF_asym_zero`) the asymmetric event leaks
  exactly zero.  This is the asymmetric/symmetric dichotomy in full generality;
  `SmoothSelfHint.information_dichotomy` states the two halves together.
-/

open Finset

namespace SmoothSelfHint

section General

variable {X Y : Type*} [Fintype X] [Fintype Y] (P : X → Y → ℝ)

/-- Gibbs' pointwise bound: `-p log (p / (r c)) ≤ r c - p`. -/
theorem neg_term_le (hP : ∀ x y, 0 ≤ P x y) (x : X) (y : Y) :
    -(P x y * Real.log (P x y / ((∑ y', P x y') * (∑ x', P x' y))))
      ≤ (∑ y', P x y') * (∑ x', P x' y) - P x y := by
  set r := ∑ y', P x y' with hr
  set c := ∑ x', P x' y with hc
  rcases eq_or_lt_of_le (hP x y) with h | h
  · rw [← h]
    simp only [zero_mul, neg_zero, sub_zero]
    exact mul_nonneg (Finset.sum_nonneg fun _ _ => hP _ _) (Finset.sum_nonneg fun _ _ => hP _ _)
  · have hrp : 0 < r := lt_of_lt_of_le h (Finset.single_le_sum (f := fun y' => P x y')
      (fun _ _ => hP _ _) (mem_univ y))
    have hcp : 0 < c := lt_of_lt_of_le h (Finset.single_le_sum (f := fun x' => P x' y)
      (fun _ _ => hP _ _) (mem_univ x))
    have hlog : Real.log (P x y / (r * c)) = - Real.log ((r * c) / (P x y)) := by
      rw [← Real.log_inv]; congr 1; field_simp
    rw [hlog]
    have hle : Real.log ((r * c) / P x y) ≤ (r * c) / P x y - 1 :=
      Real.log_le_sub_one_of_pos (by positivity)
    have hmul := mul_le_mul_of_nonneg_left hle (le_of_lt h)
    calc -(P x y * -Real.log (r * c / P x y)) = P x y * Real.log (r * c / P x y) := by ring
      _ ≤ P x y * ((r * c) / P x y - 1) := hmul
      _ = r * c - P x y := by field_simp

/-- The strict form of Gibbs' bound at a cell where the joint law differs from the
product of its marginals. -/
theorem neg_term_lt (hP : ∀ x y, 0 ≤ P x y) (x : X) (y : Y)
    (hne : P x y ≠ (∑ y', P x y') * (∑ x', P x' y)) :
    -(P x y * Real.log (P x y / ((∑ y', P x y') * (∑ x', P x' y))))
      < (∑ y', P x y') * (∑ x', P x' y) - P x y := by
  set r := ∑ y', P x y' with hr
  set c := ∑ x', P x' y with hc
  rcases eq_or_lt_of_le (hP x y) with h | h
  · have hrc : 0 < r * c := by
      rcases lt_or_eq_of_le (mul_nonneg (Finset.sum_nonneg fun _ _ => hP _ _)
        (Finset.sum_nonneg fun _ _ => hP _ _)) with h' | h'
      · exact h'
      · exact absurd (h.symm.trans h') hne
    simp [← h]
    exact hrc
  · have hrp : 0 < r := lt_of_lt_of_le h (Finset.single_le_sum (f := fun y' => P x y')
      (fun _ _ => hP _ _) (mem_univ y))
    have hcp : 0 < c := lt_of_lt_of_le h (Finset.single_le_sum (f := fun x' => P x' y)
      (fun _ _ => hP _ _) (mem_univ x))
    have hlog : Real.log (P x y / (r * c)) = - Real.log ((r * c) / (P x y)) := by
      rw [← Real.log_inv]; congr 1; field_simp
    rw [hlog]
    have hne1 : (r * c) / P x y ≠ 1 := by
      intro hEq
      field_simp at hEq
      exact hne hEq.symm
    have hlt : Real.log ((r * c) / P x y) < (r * c) / P x y - 1 :=
      Real.log_lt_sub_one_of_pos (by positivity) hne1
    have hmul := mul_lt_mul_of_pos_left hlt h
    calc -(P x y * -Real.log (r * c / P x y)) = P x y * Real.log (r * c / P x y) := by ring
      _ < P x y * ((r * c) / P x y - 1) := hmul
      _ = r * c - P x y := by field_simp

theorem miF_eq_log_div : miF P
    = (∑ x, ∑ y, P x y * Real.log (P x y / ((∑ y', P x y') * (∑ x', P x' y)))) / Real.log 2 := by
  rw [miF, Finset.sum_div]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [Finset.sum_div]
  refine Finset.sum_congr rfl fun y _ => ?_
  rw [Real.logb]
  ring

/-- The total slack in Gibbs' bound is zero for a probability distribution. -/
theorem slack_sum_eq_zero (hsum : ∑ x, ∑ y, P x y = 1) :
    ∑ x, ∑ y, ((∑ y', P x y') * (∑ x', P x' y) - P x y) = 0 := by
  have h1 : ∑ x, ∑ y, ((∑ y', P x y') * (∑ x', P x' y))
      = (∑ x, ∑ y', P x y') * (∑ y, ∑ x', P x' y) := by
    rw [Finset.sum_mul_sum]
  have h2 : (∑ x, ∑ y', P x y') * (∑ y, ∑ x', P x' y) = 1 := by
    rw [hsum, Finset.sum_comm, hsum]; ring
  simp only [Finset.sum_sub_distrib]
  rw [h1, h2, hsum]
  ring

/-- **Gibbs' inequality.**  Mutual information is nonnegative. -/
theorem miF_nonneg (hP : ∀ x y, 0 ≤ P x y) (hsum : ∑ x, ∑ y, P x y = 1) : 0 ≤ miF P := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  rw [miF_eq_log_div]
  apply div_nonneg _ hlog2.le
  have hle : ∑ x, ∑ y, -(P x y * Real.log (P x y / ((∑ y', P x y') * (∑ x', P x' y))))
      ≤ ∑ x, ∑ y, ((∑ y', P x y') * (∑ x', P x' y) - P x y) :=
    Finset.sum_le_sum fun x _ => Finset.sum_le_sum fun y _ => neg_term_le P hP x y
  rw [slack_sum_eq_zero P hsum] at hle
  simp only [Finset.sum_neg_distrib] at hle
  linarith

/-- **Strict Gibbs.**  If the joint law is not the product of its marginals, the mutual
information is strictly positive. -/
theorem miF_pos_of_not_product (hP : ∀ x y, 0 ≤ P x y) (hsum : ∑ x, ∑ y, P x y = 1)
    {x₀ : X} {y₀ : Y} (hne : P x₀ y₀ ≠ (∑ y', P x₀ y') * (∑ x', P x' y₀)) :
    0 < miF P := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  rw [miF_eq_log_div]
  apply div_pos _ hlog2
  have hinner : ∀ x : X, ∑ y, -(P x y * Real.log (P x y / ((∑ y', P x y') * (∑ x', P x' y))))
      ≤ ∑ y, ((∑ y', P x y') * (∑ x', P x' y) - P x y) :=
    fun x => Finset.sum_le_sum fun y _ => neg_term_le P hP x y
  have hinner₀ : ∑ y, -(P x₀ y * Real.log (P x₀ y / ((∑ y', P x₀ y') * (∑ x', P x' y))))
      < ∑ y, ((∑ y', P x₀ y') * (∑ x', P x' y) - P x₀ y) :=
    Finset.sum_lt_sum (fun y _ => neg_term_le P hP x₀ y)
      ⟨y₀, mem_univ y₀, neg_term_lt P hP x₀ y₀ hne⟩
  have hlt : ∑ x, ∑ y, -(P x y * Real.log (P x y / ((∑ y', P x y') * (∑ x', P x' y))))
      < ∑ x, ∑ y, ((∑ y', P x y') * (∑ x', P x' y) - P x y) :=
    Finset.sum_lt_sum (fun x _ => hinner x) ⟨x₀, mem_univ x₀, hinner₀⟩
  rw [slack_sum_eq_zero P hsum] at hlt
  simp only [Finset.sum_neg_distrib] at hlt
  linarith

end General

/-! ## The symmetric leak is positive for every odd prime -/

section ZModJoint

variable (l : ℕ) [Fact (Nat.Prime l)]

/-- The symmetric fibre count at residue `n`, as a real number: `1` at `n = 1`, `2`
elsewhere (this is `sym_fiber_card_one` of the core file). -/
noncomputable def symCount (n : (ZMod l)ˣ) : ℝ := if n = 1 then 1 else 2

/-- The joint law of `(N mod l, [l ∣ p-1 ∨ l ∣ q-1])` in the uniform model on ordered
pairs of residues: `symFiber` has `symCount n` elements over `n`, out of a fibre of size
`l - 1`, and there are `l - 1` fibres. -/
noncomputable def symJoint (n : (ZMod l)ˣ) (e : Bool) : ℝ :=
  (cond e (symCount l n) ((l : ℝ) - 1 - symCount l n)) / ((l : ℝ) - 1) ^ 2

variable {l}

omit [Fact (Nat.Prime l)] in
theorem two_le_pred (hl : 2 < l) : (2 : ℝ) ≤ (l : ℝ) - 1 := by
  have : (3 : ℝ) ≤ (l : ℝ) := by exact_mod_cast hl
  linarith

theorem symCount_bounds (n : (ZMod l)ˣ) :
    1 ≤ symCount l n ∧ symCount l n ≤ 2 := by
  unfold symCount
  by_cases h : n = 1 <;> simp [h]

theorem symJoint_nonneg (hl : 2 < l) (n : (ZMod l)ˣ) (e : Bool) : 0 ≤ symJoint l n e := by
  have hg : (2 : ℝ) ≤ (l : ℝ) - 1 := two_le_pred hl
  obtain ⟨h1, h2⟩ := symCount_bounds n
  unfold symJoint
  cases e
  · simp only [Bool.cond_false]
    apply div_nonneg (by linarith) (by positivity)
  · simp only [Bool.cond_true]
    apply div_nonneg (by linarith) (by positivity)

/-- Each residue class has total probability `1/(l-1)`. -/
theorem symJoint_row (hl : 2 < l) (n : (ZMod l)ˣ) :
    ∑ e : Bool, symJoint l n e = 1 / ((l : ℝ) - 1) := by
  have hg : (2 : ℝ) ≤ (l : ℝ) - 1 := two_le_pred hl
  have hgne : ((l : ℝ) - 1) ≠ 0 := by linarith
  rw [Fintype.sum_bool]
  unfold symJoint
  simp only [Bool.cond_true, Bool.cond_false]
  field_simp
  ring

theorem card_units_real (hl : 2 < l) :
    ((Fintype.card (ZMod l)ˣ : ℕ) : ℝ) = (l : ℝ) - 1 := by
  have h := card_units_zmod l
  have hl1 : 1 ≤ l := by omega
  rw [h, Nat.cast_sub hl1, Nat.cast_one]

/-- `∑_n symCount n = 2(l-1) - 1`. -/
theorem sum_symCount (hl : 2 < l) :
    ∑ n : (ZMod l)ˣ, symCount l n = 2 * ((l : ℝ) - 1) - 1 := by
  have hsplit : ∀ n : (ZMod l)ˣ, symCount l n = 2 - (if n = 1 then 1 else 0) := by
    intro n
    unfold symCount
    by_cases h : n = 1
    · simp [h]
      norm_num
    · simp [h]
  rw [Finset.sum_congr rfl (fun n _ => hsplit n), Finset.sum_sub_distrib,
    Finset.sum_const, Finset.card_univ,
    Finset.sum_ite_eq' univ (1 : (ZMod l)ˣ) (fun _ => (1 : ℝ))]
  simp only [Finset.mem_univ, if_true, nsmul_eq_mul]
  rw [card_units_real hl]
  ring

theorem symJoint_sum_one (hl : 2 < l) : ∑ n : (ZMod l)ˣ, ∑ e : Bool, symJoint l n e = 1 := by
  have hg : (2 : ℝ) ≤ (l : ℝ) - 1 := two_le_pred hl
  have hgne : ((l : ℝ) - 1) ≠ 0 := by linarith
  rw [Finset.sum_congr rfl (fun n _ => symJoint_row hl n), Finset.sum_const, Finset.card_univ,
    nsmul_eq_mul, card_units_real hl]
  field_simp

/-- The cell `(n, e) = (1, true)` is where the symmetric law fails to factor. -/
theorem symJoint_not_product (hl : 2 < l) :
    symJoint l 1 true ≠ (∑ e : Bool, symJoint l 1 e) * (∑ n : (ZMod l)ˣ, symJoint l n true) := by
  have hg : (2 : ℝ) ≤ (l : ℝ) - 1 := two_le_pred hl
  have hgne : ((l : ℝ) - 1) ≠ 0 := by linarith
  have hcol : ∑ n : (ZMod l)ˣ, symJoint l n true
      = (2 * ((l : ℝ) - 1) - 1) / ((l : ℝ) - 1) ^ 2 := by
    unfold symJoint
    simp only [Bool.cond_true]
    rw [← Finset.sum_div, sum_symCount hl]
  have hval : symJoint l 1 true = 1 / ((l : ℝ) - 1) ^ 2 := by
    unfold symJoint symCount
    simp
  rw [symJoint_row hl, hcol, hval]
  intro hEq
  field_simp at hEq
  nlinarith [hEq]

/-- **The symmetric event leaks strictly positive information, for every odd prime.** -/
theorem mi_sym_pos (hl : 2 < l) : 0 < miF (symJoint l) :=
  miF_pos_of_not_product _ (fun n e => symJoint_nonneg hl n e) (symJoint_sum_one hl)
    (symJoint_not_product hl)

/-- **The dichotomy, for every odd prime `l`.**  The asymmetric divisibility event is
information-theoretically invisible in `N mod l`; the symmetric one is not. -/
theorem information_dichotomy (hl : 2 < l) :
    miF (jointAsym ({1} : Finset (ZMod l)ˣ)) = 0 ∧ 0 < miF (symJoint l) :=
  ⟨miF_asym_zero _, mi_sym_pos hl⟩

end ZModJoint

end SmoothSelfHint