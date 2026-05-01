import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenEnumeration

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 19
-/

/-- [Section: ## Definitions] -/
inductive BStepE where
  | A | B | C
  deriving Repr, DecidableEq

def applyStepE (s : BStepE) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match s with
  | .A => (t.1 - 2*t.2.1 + 2*t.2.2, 2*t.1 - t.2.1 + 2*t.2.2, 2*t.1 - 2*t.2.1 + 3*t.2.2)
  | .B => (t.1 + 2*t.2.1 + 2*t.2.2, 2*t.1 + t.2.1 + 2*t.2.2, 2*t.1 + 2*t.2.1 + 3*t.2.2)
  | .C => (-t.1 + 2*t.2.1 + 2*t.2.2, -2*t.1 + t.2.1 + 2*t.2.2, -2*t.1 + 2*t.2.1 + 3*t.2.2)

def applyPathE (path : List BStepE) : ℤ × ℤ × ℤ :=
  path.foldl (fun t s => applyStepE s t) (3, 4, 5)

/-- [Section: ## Section 1: Forward Maps Preserve Properties] -/
theorem step_pyth_E (s : BStepE) (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let ch := applyStepE s (a, b, c)
    ch.1 ^ 2 + ch.2.1 ^ 2 = ch.2.2 ^ 2 := by
  cases s <;> simp [applyStepE] <;> nlinarith

theorem step_pos_E (s : BStepE) (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    let ch := applyStepE s (a, b, c)
    0 < ch.1 ∧ 0 < ch.2.1 ∧ 0 < ch.2.2 := by
  cases s <;> simp [applyStepE] <;> refine ⟨?_, ?_, ?_⟩ <;>
    nlinarith [sq_nonneg (a - b), sq_nonneg a, sq_nonneg b]

theorem hyp_monotone_step (s : BStepE) (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    c < (applyStepE s (a, b, c)).2.2 := by
  cases s <;> simp [applyStepE] <;> nlinarith [sq_nonneg (a - b)]

/-- [Section: ## Section 2: Each Step Increases Hypotenuse by ≥ 2] -/
theorem step_hyp_increase_by_2 (s : BStepE) (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    c + 2 ≤ (applyStepE s (a, b, c)).2.2 := by
  induction' s with s ih <;> norm_num [ applyStepE ] at * <;> nlinarith! [ sq_nonneg ( a - c ), sq_nonneg ( b - c ) ] ;

/-- [Section: ## Section 3: Path Validity] -/
theorem path_valid_E :
    ∀ (path : List BStepE) (t : ℤ × ℤ × ℤ),
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 →
    0 < t.1 → 0 < t.2.1 → 0 < t.2.2 →
    let res := path.foldl (fun t s => applyStepE s t) t
    res.1 ^ 2 + res.2.1 ^ 2 = res.2.2 ^ 2 ∧ 0 < res.1 ∧ 0 < res.2.1 ∧ 0 < res.2.2 := by
  intro path; induction path with
  | nil => intro t hp ha hb hc; exact ⟨hp, ha, hb, hc⟩
  | cons s rest ih =>
    intro t hp ha hb hc; simp only [List.foldl_cons]
    exact ih _ (step_pyth_E s _ _ _ hp) (step_pos_E s _ _ _ ha hb hc hp).1
      (step_pos_E s _ _ _ ha hb hc hp).2.1 (step_pos_E s _ _ _ ha hb hc hp).2.2

/-- [Section: ## Section 4: Depth Bound] -/
theorem depth_bound_hyp (path : List BStepE) :
    (5 : ℤ) + 2 * path.length ≤ (applyPathE path).2.2 := by
  induction' path using List.reverseRecOn with s path ih;
  · decide +revert;
  · have h_step : let t := applyPathE s; t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 ∧ 0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 := by
      convert path_valid_E s ( 3, 4, 5 ) rfl ( by decide ) ( by decide ) ( by decide ) using 1;
    have := step_hyp_increase_by_2 path ( applyPathE s |>.1 ) ( applyPathE s |>.2.1 ) ( applyPathE s |>.2.2 ) h_step.2.1 h_step.2.2.1 h_step.2.2.2 h_step.1;
    unfold applyPathE at *; norm_num at *; linarith;

/-- [Section: ## Section 5: Three Children Are Distinct] -/
theorem children_distinct (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    applyStepE .A (a,b,c) ≠ applyStepE .B (a,b,c) ∧
    applyStepE .A (a,b,c) ≠ applyStepE .C (a,b,c) ∧
    applyStepE .B (a,b,c) ≠ applyStepE .C (a,b,c) := by
  simp [applyStepE, Prod.mk.injEq]; omega

/-- [Section: ## Section 6: Explicit Enumeration] -/
theorem depth1_triples :
    applyPathE [.A] = (5, 12, 13) ∧
    applyPathE [.B] = (21, 20, 29) ∧
    applyPathE [.C] = (15, 8, 17) := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

theorem depth2_AB : applyPathE [.A, .B] = (55, 48, 73) := by
  native_decide

theorem depth2_AC : applyPathE [.A, .C] = (45, 28, 53) := by
  native_decide

theorem depth2_BA : applyPathE [.B, .A] = (39, 80, 89) := by
  native_decide

theorem depth2_BC : applyPathE [.B, .C] = (77, 36, 85) := by
  native_decide

/-- [Section: ## Section 7: Leg Bounds] -/
theorem leg_lt_hyp_a (a b c : ℤ) (hb : 0 < b) (hc : 0 < c)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) : a < c := by
  nlinarith [sq_nonneg (c - a)]

theorem leg_lt_hyp_b (a b c : ℤ) (ha : 0 < a) (hc : 0 < c)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) : b < c := by
  nlinarith [sq_nonneg (c - b)]

/-- The sum of legs strictly exceeds the hypotenuse -/
theorem sum_legs_gt_hyp (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (_hc : 0 < c) :
    c < a + b := by
  nlinarith [sq_nonneg (a + b - c), sq_nonneg (a - b)]

theorem hyp_le_leg_product (a b c : ℤ) (ha : 2 ≤ a) (hb : 2 ≤ b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (hc : 0 < c) :
    c ≤ a * b := by
  nlinarith [ mul_le_mul_of_nonneg_left ha ( show 0 ≤ b by linarith ), mul_le_mul_of_nonneg_right hb ( show 0 ≤ a by linarith ) ]
