import Mathlib

/-! # CatalogBuild.Computation.AlgebraicStructure

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 21
-/


noncomputable section

/-- The EML operation. -/
def EMLa (a b : ℝ) : ℝ := Real.exp a - Real.log b




/-- EML is non-commutative: EML(0,1) ≠ EML(1,0). -/
theorem EMLa_noncomm : ∃ a b : ℝ, EMLa a b ≠ EMLa b a := by
  use 0, 1
  simp [EMLa, Real.log_one, Real.exp_zero, Real.log_zero]
  intro h
  linarith [Real.exp_one_gt_d9]




/-- [Section: # CatalogBuild.Computation.AlgebraicStructure
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 21] -/
theorem EMLa_nonassoc :
    ∃ a b c : ℝ, EMLa (EMLa a b) c ≠ EMLa a (EMLa b c) := by
  use 0, 1, 1;
  unfold EMLa; norm_num




/-- EML has no right identity. -/
theorem EMLa_no_right_id : ¬ ∃ e : ℝ, ∀ x, EMLa x e = x := by
  intro ⟨e, h⟩
  have h0 := h 0
  have h1 := h 1
  simp [EMLa] at h0 h1
  linarith [Real.exp_one_gt_d9]




/-- [Section: # CatalogBuild.Computation.AlgebraicStructure
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 21] -/
theorem EMLa_no_left_id : ¬ ∃ e : ℝ, ∀ x, EMLa e x = x := by
  unfold EMLa;
  rintro ⟨ e, he ⟩ ; have := he 0 ; have := he 1 ; norm_num at *




/-- EML is strictly increasing in the first argument. -/
theorem EMLa_strictMono_fst (b : ℝ) : StrictMono (EMLa · b) :=
  fun _ _ h => sub_lt_sub_right (Real.exp_lt_exp.mpr h) _




/-- EML is strictly decreasing in the second argument on (0, ∞). -/
theorem EMLa_strictAnti_snd (a : ℝ) : StrictAntiOn (EMLa a ·) (Set.Ioi 0) :=
  fun _ hy _ _ hyz => sub_lt_sub_left (Real.log_lt_log hy hyz) _




/-- EML is right-cancellative (from first argument). -/
theorem EMLa_right_cancel (a₁ a₂ b : ℝ) :
    EMLa a₁ b = EMLa a₂ b → a₁ = a₂ := by
  intro h
  simp [EMLa] at h
  exact h




/-- T_c(x) = EML(x, c) = exp(x) - ln(c). -/
def Tc (c : ℝ) (x : ℝ) : ℝ := EMLa x c




/-- T_1 = exp. -/
theorem Tc_one (x : ℝ) : Tc 1 x = Real.exp x := by
  simp [Tc, EMLa, Real.log_one]




/-- T_c is strictly monotone for all c. -/
theorem Tc_strictMono (c : ℝ) : StrictMono (Tc c) :=
  EMLa_strictMono_fst c




/-- Composition law: T_c₁(T_c₂(x)) = exp(exp(x) - ln(c₂)) - ln(c₁). -/
theorem Tc_compose (c₁ c₂ x : ℝ) :
    Tc c₁ (Tc c₂ x) = Real.exp (Real.exp x - Real.log c₂) - Real.log c₁ := by
  simp [Tc, EMLa]




theorem Tc_noncomm : ∃ c₁ c₂ : ℝ, ∃ x : ℝ,
    Tc c₁ (Tc c₂ x) ≠ Tc c₂ (Tc c₁ x) := by
  use 1, Real.exp 1, 0;
  -- Simplify the expressions for Tc 1 (Tc (exp 1) 0) and Tc (exp 1) (Tc 1 0).
  simp [Tc, EMLa];
  exact ne_of_lt ( by have := Real.exp_one_gt_d9.le; norm_num1 at *; linarith )




/-- EML satisfies a shifted exponential law:
EML(a + b, 1) = exp(a) · exp(b). -/
theorem EMLa_exp_add (a b : ℝ) :
    EMLa (a + b) 1 = Real.exp a * Real.exp b := by
  simp [EMLa, Real.log_one, Real.exp_add]




/-- The scaling law: EML(a, b·c) = EML(a, b) - ln(c) for b, c > 0. -/
theorem EMLa_scaling (a b c : ℝ) (hb : 0 < b) (hc : 0 < c) :
    EMLa a (b * c) = EMLa a b - Real.log c := by
  simp [EMLa, Real.log_mul hb.ne' hc.ne']; ring




/-- EML distributes over exp: EML(exp(a), exp(b)) = exp(exp(a)) - b. -/
theorem EMLa_exp_exp (a b : ℝ) :
    EMLa (Real.exp a) (Real.exp b) = Real.exp (Real.exp a) - b := by
  simp [EMLa, Real.log_exp]




/-- For x > 0: EML(x, x) = exp(x) - ln(x) ≥ 2.
This is related to AM-GM: exp(x) ≥ 1+x and -ln(x) ≥ 1-x. -/
theorem EMLa_diag_ge_two (x : ℝ) (hx : 0 < x) :
    EMLa x x ≥ 2 := by
  simp [EMLa]
  linarith [Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx]




/-- n-fold EML tower: EML(EML(...EML(1,1)..., 1), 1) = exp^n(1) = e↑↑n. -/
def EMLTower : ℕ → ℝ
  | 0 => 1
  | n + 1 => EMLa (EMLTower n) 1




theorem EMLTower_eq_exp (n : ℕ) : EMLTower (n + 1) = Real.exp (EMLTower n) := by
  simp [EMLTower, EMLa, Real.log_one]




theorem EMLTower_pos (n : ℕ) : 0 < EMLTower n := by
  induction n with
  | zero => simp [EMLTower]
  | succ n _ => rw [EMLTower_eq_exp]; exact Real.exp_pos _




theorem EMLTower_strictMono : StrictMono EMLTower := by
  apply strictMono_nat_of_lt_succ
  intro n
  rw [EMLTower_eq_exp]
  linarith [Real.add_one_le_exp (EMLTower n)]




end
