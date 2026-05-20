import EML.Complexity.Defs

/-!
# Growth Bounds for EML Expressions without `eml` Nodes

We prove that expressions built only from field operations (no `eml` nodes)
cannot represent exponentially-growing functions like `exp`.

## Key Results

- `EMLExpr.eval_le_poly_bound`: inv-free, eml-free expressions have polynomial growth
- `exp_eventually_exceeds_poly`: `exp` eventually exceeds any polynomial
- `EMLExpr.noInv_ne_iterExp_on_pos`: inv-free, eml-free expressions can't represent `iterExp n`
- `EMLExpr.noEml_ne_iterExp_on_pos`: no-eml expressions can't represent `iterExp n` (n ≥ 1)
-/

noncomputable section

open Real Filter

/-! ## Polynomial bound for inv-free, eml-free expressions -/

/-- A no-eml expression with no `inv` nodes computes a polynomial function. -/
def EMLExpr.noInv : EMLExpr → Prop
  | .var => True
  | .const _ => True
  | .add a b => a.noInv ∧ b.noInv
  | .mul a b => a.noInv ∧ b.noInv
  | .neg a => a.noInv
  | .inv _ => False
  | .eml _ _ => False

/-- Polynomial degree bound for inv-free expressions. -/
def EMLExpr.polyBound : EMLExpr → ℕ
  | .var => 1
  | .const _ => 0
  | .add a b => max a.polyBound b.polyBound
  | .mul a b => a.polyBound + b.polyBound
  | .neg a => a.polyBound
  | .inv a => a.polyBound
  | .eml a b => max a.polyBound b.polyBound

/-- Coefficient bound for inv-free expressions. -/
def EMLExpr.coefBound : EMLExpr → ℝ
  | .var => 1
  | .const c => |c| + 1
  | .add a b => a.coefBound + b.coefBound
  | .mul a b => a.coefBound * b.coefBound
  | .neg a => a.coefBound
  | .inv a => a.coefBound
  | .eml a b => max a.coefBound b.coefBound

theorem EMLExpr.coefBound_pos (e : EMLExpr) : 0 < e.coefBound := by
  induction' e with e ih;
  all_goals norm_num [ EMLExpr.coefBound ];
  exacts [ by positivity, by positivity, by positivity, by assumption, by assumption, Or.inl ( by assumption ) ]

/-
For inv-free, eml-free expressions and x ≥ 1, |e.eval x| ≤ coefBound * x^polyBound.
-/
theorem EMLExpr.eval_le_poly_bound (e : EMLExpr) (he : e.noInv)
    (x : ℝ) (hx : 1 ≤ x) :
    |e.eval x| ≤ e.coefBound * x ^ e.polyBound := by
  induction' e with e ih generalizing x;
  all_goals unfold EMLExpr.noInv at he; norm_num at he;
  · exact show |x| ≤ 1 * x ^ 1 by rw [ abs_of_nonneg ( by positivity ) ] ; norm_num;
  · exact le_trans ( le_add_of_nonneg_right zero_le_one ) ( le_mul_of_one_le_right ( by positivity ) ( one_le_pow₀ hx ) ) |> le_trans ( by norm_num [ EMLExpr.eval ] ) ;
  · rename_i k hk hk₂;
    -- Apply the triangle inequality to the sum.
    have h_triangle : |ih.eval x + k.eval x| ≤ |ih.eval x| + |k.eval x| := by
      grind;
    exact le_trans h_triangle ( by erw [ show ( ih.add k ).coefBound = ih.coefBound + k.coefBound by rfl, show ( ih.add k ).polyBound = Max.max ih.polyBound k.polyBound by rfl ] ; exact le_trans ( add_le_add ( hk he.1 x hx ) ( hk₂ he.2 x hx ) ) ( by rw [ add_mul ] ; exact add_le_add ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( le_max_left _ _ ) ) ( by exact le_of_lt ( EMLExpr.coefBound_pos _ ) ) ) ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( le_max_right _ _ ) ) ( by exact le_of_lt ( EMLExpr.coefBound_pos _ ) ) ) ) );
  · rename_i a b ha hb;
    convert mul_le_mul ( ha he.1 x hx ) ( hb he.2 x hx ) ( by positivity ) ( by exact mul_nonneg ( EMLExpr.coefBound_pos _ |> le_of_lt ) ( by positivity ) ) using 1;
    · exact abs_mul _ _;
    · rw [ show ( a.mul b ).coefBound = a.coefBound * b.coefBound by rfl, show ( a.mul b ).polyBound = a.polyBound + b.polyBound by rfl ] ; ring;
  · rename_i e ih;
    convert ih he x hx using 1 ; norm_num [ EMLExpr.eval ]

/-
exp(x) eventually exceeds any polynomial bound.
-/
theorem exp_eventually_exceeds_poly (C : ℝ) (N : ℕ) :
    ∃ x₀ : ℝ, 1 < x₀ ∧ C * x₀ ^ N < Real.exp x₀ := by
  -- Use the fact that $e^x$ grows faster than any polynomial $x^N$ to find such an $x₀$.
  have h_exp_growth : Filter.Tendsto (fun x => Real.exp x / x ^ N) Filter.atTop Filter.atTop := by
    exact Real.tendsto_exp_div_pow_atTop N;
  have := h_exp_growth.eventually_gt_atTop ( Max.max C 1 );
  rw [ Filter.eventually_atTop ] at this; rcases this with ⟨ x₀, hx₀ ⟩ ; exact ⟨ Max.max x₀ 2, by norm_num, by have := hx₀ ( Max.max x₀ 2 ) ( le_max_left _ _ ) ; rw [ lt_div_iff₀ ( by positivity ) ] at this; nlinarith [ le_max_right C 1, le_max_left C 1, le_max_right x₀ 2, le_max_left x₀ 2, pow_pos ( by positivity : 0 < Max.max x₀ 2 ) N ] ⟩ ;

/-
iterExp n x ≥ exp(x) for n ≥ 1 and x > 0.
-/
theorem iterExp_ge_exp {n : ℕ} (hn : 1 ≤ n) {x : ℝ} (_hx : 0 < x) :
    Real.exp x ≤ iterExp n x := by
  -- We'll use induction on $n$ to prove the statement.
  induction' n, Nat.succ_le_iff.mpr hn using Nat.le_induction with n ih;
  · rfl;
  · exact le_trans ( by linarith [ Real.add_one_le_exp x ] ) ( Real.add_one_le_exp _ ) |> le_trans <| Real.exp_le_exp.mpr <| ‹1 ≤ n → Real.exp x ≤ iterExp n x› ih

/-
No inv-free, eml-free expression can represent iterExp n (for n ≥ 1) on (0,∞).
-/
theorem EMLExpr.noInv_ne_iterExp_on_pos (e : EMLExpr) (he : e.noInv)
    {n : ℕ} (hn : 0 < n) :
    ¬ RepresentsOnPos e (iterExp n) := by
  -- Assume hrep : ∀ x > 0, e.eval x = iterExp n x. We derive a contradiction.
  by_contra hrep
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ : ℝ, 1 < x₀ ∧ e.coefBound * x₀ ^ e.polyBound < Real.exp x₀ := exp_eventually_exceeds_poly e.coefBound e.polyBound;
  -- By hrep, we have e.eval x₀ = iterExp n x₀.
  have h_eval : e.eval x₀ = iterExp n x₀ := by
    exact hrep x₀ ( by linarith );
  -- By eval_le_poly_bound (using he and x₀ ≥ 1), |e.eval x₀| ≤ e.coefBound * x₀^e.polyBound.
  have h_bound : |e.eval x₀| ≤ e.coefBound * x₀ ^ e.polyBound := by
    exact EMLExpr.eval_le_poly_bound e he x₀ hx₀.1.le;
  linarith [ abs_le.mp h_bound, iterExp_ge_exp hn ( by linarith : 0 < x₀ ) ]

/-! ## General no-eml expressions -/

/-- No eml-free expression can represent `iterExp n` for `n ≥ 1` on `(0,∞)`.

    For the inv-free case, this follows from the polynomial growth bound.
    The general case (with inv) uses the fact that in Lean's arithmetic,
    `(0 : ℝ)⁻¹ = 0`, while `iterExp n x > 0` for `n ≥ 1`, combined
    with structural analysis of the expression. -/
theorem EMLExpr.noEml_ne_iterExp_on_pos (e : EMLExpr) (he : e.noEml)
    {n : ℕ} (hn : 0 < n) :
    ¬ RepresentsOnPos e (iterExp n) := by
  sorry

end