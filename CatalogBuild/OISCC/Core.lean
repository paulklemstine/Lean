/-! # CatalogBuild.OISCC.Core

Auto-generated from theorem catalog database.
Domain: OISCC
Declarations: 24
-/

import Mathlib

noncomputable section

/-- The EML operation: EML(a, b) = exp(a) - ln(b). -/
def EML (a b : ℝ) : ℝ := Real.exp a - Real.log b


/-- exp(a) = EML(a, 1). -/
theorem EML_exp (a : ℝ) : EML a 1 = Real.exp a := by
  simp [EML, Real.log_one]


/-- EML(0, b) = 1 - ln(b). -/
theorem EML_zero_fst (b : ℝ) : EML 0 b = 1 - Real.log b := by
  simp [EML]


/-- EML(1, 1) = e. -/
theorem EML_one_one : EML 1 1 = Real.exp 1 := by
  simp [EML, Real.log_one]


/-- EML(0, 1) = 1. -/
theorem EML_zero_one : EML 0 1 = 1 := by
  simp [EML, Real.log_one]


/-- EML(0, exp(1)) = 0. -/
theorem EML_zero_e : EML 0 (Real.exp 1) = 0 := by
  simp [EML, Real.log_exp]


/-- The Legendre identity: EML(a, exp(b)) = exp(a) - b. -/
theorem EML_legendre (a b : ℝ) : EML a (Real.exp b) = Real.exp a - b := by
  simp [EML, Real.log_exp]


/-- EML(ln(a), exp(b)) = a - b for a > 0. -/
theorem EML_sub (a b : ℝ) (ha : 0 < a) :
    EML (Real.log a) (Real.exp b) = a - b := by
  simp [EML, Real.exp_log ha, Real.log_exp]


/-- EML(ln(a), exp(-b)) = a + b for a > 0. -/
theorem EML_add (a b : ℝ) (ha : 0 < a) :
    EML (Real.log a) (Real.exp (-b)) = a + b := by
  simp [EML, Real.exp_log ha, Real.log_exp]


/-- EML(ln(a) + ln(b), 1) = a * b for a, b > 0. -/
theorem EML_mul (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    EML (Real.log a + Real.log b) 1 = a * b := by
  simp [EML, Real.log_one, Real.exp_add, Real.exp_log ha, Real.exp_log hb]


/-- EML(ln(a) - ln(b), 1) = a / b for a, b > 0. -/
theorem EML_div (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    EML (Real.log a - Real.log b) 1 = a / b := by
  simp [EML, Real.log_one, Real.exp_sub, Real.exp_log ha, Real.exp_log hb]


/-- Log-split: EML(a, b·c) = EML(a, b) - ln(c) for b, c > 0. -/
theorem EML_log_split (a b c : ℝ) (hb : 0 < b) (hc : 0 < c) :
    EML a (b * c) = EML a b - Real.log c := by
  simp [EML, Real.log_mul hb.ne' hc.ne']; ring


/-- Power identity: EML(n·a, 1) = exp(a)^n. -/
theorem EML_power_nat (a : ℝ) (n : ℕ) :
    EML (n * a) 1 = (Real.exp a) ^ n := by
  simp [EML, Real.log_one, Real.exp_nat_mul]


/-- ln(b) recovery: EML(0, exp(EML(0, b))) = ln(b). -/
theorem EML_recovers_ln (b : ℝ) :
    EML 0 (Real.exp (EML 0 b)) = Real.log b := by
  simp [EML, Real.log_exp]


/-- EML involution: EML(0, exp(EML(0, exp(a)))) = a. -/
theorem EML_involution (a : ℝ) :
    EML 0 (Real.exp (EML 0 (Real.exp a))) = a := by
  simp [EML, Real.log_exp]


/-- EML is strictly increasing in the first argument. -/
theorem EML_strictMono_fst (b : ℝ) : StrictMono (EML · b) :=
  fun _ _ h => sub_lt_sub_right (Real.exp_lt_exp.mpr h) _


/-- EML is strictly decreasing in the second argument on (0, ∞). -/
theorem EML_strictAnti_snd (a : ℝ) : StrictAntiOn (EML a ·) (Set.Ioi 0) :=
  fun _ hy _ _ hyz => sub_lt_sub_left (Real.log_lt_log hy hyz) _


/-- EML is right-cancellative (first argument). -/
theorem EML_cancel_fst (a₁ a₂ b : ℝ) (h : EML a₁ b = EML a₂ b) : a₁ = a₂ := by
  simp [EML] at h; exact h


/-- EML is right-cancellative (second argument) for positive b. -/
theorem EML_cancel_snd (a b₁ b₂ : ℝ) (hb₁ : 0 < b₁) (hb₂ : 0 < b₂)
    (h : EML a b₁ = EML a b₂) : b₁ = b₂ := by
  simp [EML] at h
  exact Real.log_injOn_pos (Set.mem_Ioi.mpr hb₁) (Set.mem_Ioi.mpr hb₂) h


/-- EML is non-commutative. -/
theorem EML_noncomm : ∃ a b : ℝ, EML a b ≠ EML b a := by
  use 0, 1
  simp [EML, Real.log_one, Real.exp_zero, Real.log_zero]
  intro h
  linarith [Real.exp_one_gt_d9]


/-- EML is non-associative. -/
theorem EML_nonassoc : ∃ a b c : ℝ, EML (EML a b) c ≠ EML a (EML b c) := by
  use 0, 1, 1
  unfold EML; norm_num


/-- EML has no right identity element. -/
theorem EML_no_right_id : ¬ ∃ e : ℝ, ∀ x, EML x e = x := by
  intro ⟨e, h⟩
  have h0 := h 0
  have h1 := h 1
  simp [EML] at h0 h1
  linarith [Real.exp_one_gt_d9]


/-- [Section: ## Section 3: Algebraic Non-Properties] -/
theorem EML_no_left_id : ¬ ∃ e : ℝ, ∀ x, EML e x = x := by
  -- Assume for contradiction that such an $e$ exists.
  by_contra h
  obtain ⟨e, he⟩ := h;
  unfold EML at he;
  have := he 0; have := he ( Real.exp e ) ; norm_num at *


/-- The OISCC arithmetic completeness theorem:
All basic arithmetic operations on positive reals are expressible via EML. -/
theorem EML_arithmetic_complete (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    EML a 1 = Real.exp a ∧
    EML (Real.log a) (Real.exp b) = a - b ∧
    EML (Real.log a) (Real.exp (-b)) = a + b ∧
    EML (Real.log a + Real.log b) 1 = a * b ∧
    EML (Real.log a - Real.log b) 1 = a / b := by
  exact ⟨EML_exp a, EML_sub a b ha, EML_add a b ha,
         EML_mul a b ha hb, EML_div a b ha hb⟩


end
