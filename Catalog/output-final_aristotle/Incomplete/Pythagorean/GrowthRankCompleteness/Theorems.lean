/-
# Growth Rank Completeness — Core Theorems

This file proves that `growthRank` is the exact semantic stratification
invariant for canonical inverse-free EML expressions, establishing:

1. **Upper bound**: Every inverse-free expression has a tower majorant at its growth rank level
2. **Lower bound**: Canonical tower expressions cannot be majorized at lower levels
3. **Exactness**: `towerExpr k` lives at exact tower level `k`
4. **Semantic invariance**: Tower level is preserved under extensional equality
5. **FGH bridge**: Growth rank connects to fast-growing hierarchies
6. **Certified algorithm**: `certifyGrowthRank` computes exact level for canonical forms

## Mathematical Significance

This upgrades `growthRank` from a syntactic upper bound to a **complete semantic
invariant** for canonical tower expressions, analogous to degree for polynomials
or quantifier alternation rank in descriptive complexity.
-/
import Pythagorean.GrowthRankCompleteness.Defs

noncomputable section

open Real Filter Finset

/-! ## Basic Properties of iterExp -/

theorem iterExp_strictMono (n : ℕ) : StrictMono (iterExp n) := by
  induction n with
  | zero => exact strictMono_id
  | succ n ih => exact Real.exp_strictMono.comp ih

theorem iterExp_mono (n : ℕ) : Monotone (iterExp n) :=
  (iterExp_strictMono n).monotone

theorem iterExp_pos_of_pos (n : ℕ) {x : ℝ} (hx : 0 < x) : 0 < iterExp n x := by
  induction n with
  | zero => exact hx
  | succ n _ => exact Real.exp_pos _

theorem iterExp_pos_of_succ (n : ℕ) (x : ℝ) : 0 < iterExp (n + 1) x :=
  Real.exp_pos _

theorem iterExp_strict_level_increase {x : ℝ} (hx : 0 < x) (n : ℕ) :
    iterExp n x < iterExp (n + 1) x := by
  simp [iterExp_succ]; linarith [Real.add_one_le_exp (iterExp n x)]

theorem iterExp_level_mono {n m : ℕ} (hnm : n ≤ m) {x : ℝ} (hx : 0 < x) :
    iterExp n x ≤ iterExp m x := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hnm
  induction k with
  | zero => simp
  | succ k ih =>
    have h1 := ih (by omega)
    have h2 := iterExp_strict_level_increase hx (n + k)
    have h3 : n + k + 1 = n + (k + 1) := by omega
    linarith [h3 ▸ h2]

theorem iterExp_compose (k m : ℕ) (x : ℝ) :
    iterExp k (iterExp m x) = iterExp (k + m) x := by
  induction k with
  | zero => simp [iterExp]
  | succ k ih => simp [iterExp_succ, ih, Nat.succ_add]

theorem iterExp_ge_self (n : ℕ) {x : ℝ} (hx : 0 ≤ x) : x ≤ iterExp n x := by
  induction n with
  | zero => simp
  | succ n ih =>
    calc x ≤ iterExp n x := ih
    _ ≤ Real.exp (iterExp n x) := by linarith [Real.add_one_le_exp (iterExp n x)]

theorem iterExp_nonneg_of_succ (n : ℕ) (x : ℝ) : 0 ≤ iterExp (n + 1) x :=
  le_of_lt (Real.exp_pos _)

/-! ## Tower Separation: iterExp (k+1) eventually exceeds iterExp k ∘ polynomial -/

/-
Key separation lemma: `iterExp (k+1) x` eventually exceeds `iterExp k (C * x^N)`
    for any fixed polynomial argument. This is the engine of the strict hierarchy.
-/
theorem iterExp_poly_lt_iterExp_succ (D : ℕ) (C : ℝ) (N : ℕ) :
    ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      iterExp D (C * x ^ N) < iterExp (D + 1) x := by
  induction' D with D ih generalizing C N;
  · -- By comparing the growth rates, we see that $C * x^N < \exp(x)$ for sufficiently large $x$.
    have h_compare : Filter.Tendsto (fun x : ℝ => C * x ^ N / Real.exp x) Filter.atTop (nhds 0) := by
      simpa [ Real.exp_neg, mul_div_assoc ] using tendsto_const_nhds.mul ( Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero N );
    exact Filter.eventually_atTop.mp ( h_compare.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ X₀, hX₀ ⟩ ↦ ⟨ Max.max X₀ 1, fun x hx ↦ by have := hX₀ x ( le_trans ( le_max_left _ _ ) hx ) ; rw [ div_lt_one ( Real.exp_pos _ ) ] at this; aesop ⟩;
  · obtain ⟨ X₀, hX₀ ⟩ := ih C N;
    exact ⟨ Max.max X₀ 1, fun x hx => by simpa using Real.exp_lt_exp.mpr ( hX₀ x ( le_trans ( le_max_left _ _ ) hx ) ) ⟩

/-! ## growthRank equals emlDepth for inverse-free expressions -/

/-
For inverse-free expressions, `growthRank` and `emlDepth` coincide.
    This is because the only constructor where they could differ is `inv`,
    which is excluded by the `noInv` hypothesis.
-/
theorem growthRank_eq_emlDepth_of_noInv (e : EMLExpr) (hInv : e.noInv) :
    e.growthRank = e.emlDepth := by
  revert hInv e;
  -- We'll use induction on the structure of the expression `e`.
  intro e
  induction' e with e1 e2 ih1 ih2;
  all_goals norm_cast;
  all_goals norm_num [ EMLExpr.noInv, EMLExpr.growthRank, EMLExpr.emlDepth ];
  · grind;
  · lia;
  · lia

/-! ## growthRank is bounded by emlDepth -/

theorem growthRank_le_emlDepth (e : EMLExpr) : e.growthRank ≤ e.emlDepth := by
  -- By definition of `growthRank`, it is the maximum depth of the expression.
  induction' e with e1 e2 ih1 ih2;
  all_goals simp_all +decide [ EMLExpr.growthRank, EMLExpr.emlDepth ];
  · grind;
  · grind;
  · grind

/-! ## Tower Expression Properties -/

/-
`towerExpr k` evaluates to `iterExp k x`.
-/
theorem towerExpr_eval (k : ℕ) (x : ℝ) :
    (towerExpr k).eval x = iterExp k x := by
  induction' k with k ih;
  · rfl;
  · exact show ( 1 : ℝ ) * Real.exp ( ( towerExpr k ).eval x ) = Real.exp ( iterExp k x ) from by rw [ ih ] ; norm_num;

/-
`towerExpr k` has eml depth exactly `k`.
-/
theorem towerExpr_emlDepth (k : ℕ) : (towerExpr k).emlDepth = k := by
  induction k <;> simp_all +decide [ towerExpr ];
  simp_all +arith +decide [ EMLExpr.emlDepth ]

/-
`towerExpr k` is inverse-free.
-/
theorem towerExpr_noInv (k : ℕ) : (towerExpr k).noInv := by
  induction' k with k ih;
  · trivial;
  · exact ⟨ by tauto, by tauto ⟩

/-
`towerExpr k` has growth rank exactly `k`.
-/
theorem towerExpr_growthRank (k : ℕ) : (towerExpr k).growthRank = k := by
  convert growthRank_eq_emlDepth_of_noInv ( towerExpr k ) ( towerExpr_noInv k ) using 1;
  exact Eq.symm ( towerExpr_emlDepth k )

/-! ## Polynomial closure lemmas for iterExp -/

theorem iterExp_sum_poly_bound (D : ℕ) (hD : 1 ≤ D) (C₁ C₂ : ℝ)
    (hC₁ : 0 < C₁) (hC₂ : 0 < C₂) (N₁ N₂ : ℕ) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      iterExp D (C₁ * x ^ N₁) + iterExp D (C₂ * x ^ N₂) ≤ iterExp D (C * x ^ N) := by
  -- By induction on $D$, we can show that for any $D \geq 1$, there exists a constant $C$ such that $iterExp D (C₁ * x ^ N₁) + iterExp D (C₂ * x ^ N₂) \leq iterExp D (C * x ^ (max N₁ N₂))$.
  have h_ind : ∀ D ≥ 1, ∃ C : ℝ, 0 < C ∧ ∀ x ≥ 1, iterExp D (C₁ * x ^ N₁) + iterExp D (C₂ * x ^ N₂) ≤ iterExp D (C * x ^ (max N₁ N₂)) := by
    intro D hD
    have h_ind_step : ∀ D ≥ 1, ∃ C : ℝ, 0 < C ∧ ∀ x ≥ 1, iterExp D (C₁ * x ^ (max N₁ N₂)) + iterExp D (C₂ * x ^ (max N₁ N₂)) ≤ iterExp D (C * x ^ (max N₁ N₂)) := by
      intro D hD
      have h_step : ∀ u ≥ 0, iterExp D u + iterExp D u ≤ iterExp D (2 * u + 1) := by
        induction' hD with D hD ih <;> simp_all +decide [ two_mul, iterExp ];
        · intro u hu; rw [ Real.exp_add, Real.exp_add ] ; ring_nf;
          nlinarith [ Real.add_one_le_exp u, Real.add_one_le_exp 1, mul_le_mul_of_nonneg_left ( Real.add_one_le_exp u ) ( Real.exp_nonneg u ), mul_le_mul_of_nonneg_left ( Real.add_one_le_exp 1 ) ( Real.exp_nonneg u ) ];
        · intro u hu; rw [ ← two_mul ] ; rw [ ← Real.exp_log ( by positivity : ( 0 : ℝ ) < 2 ) ] ; rw [ ← Real.exp_add ] ; ring_nf;
          norm_num [ add_comm, mul_two ];
          refine' le_trans _ ( ih u hu );
          induction' hD with D hD ih <;> simp_all +decide [ iterExp ];
          · exact le_trans ( Real.log_two_lt_d9.le ) ( by norm_num; linarith [ Real.add_one_le_exp u ] );
          · exact le_trans ( Real.log_two_lt_d9.le ) ( by norm_num; linarith [ Real.add_one_le_exp ( iterExp D u ), show 0 ≤ iterExp D u from Nat.recOn D ( by norm_num; linarith ) fun n ihn => by rw [ show iterExp ( n + 1 ) u = Real.exp ( iterExp n u ) by rfl ] ; positivity ] );
      refine' ⟨ 2 * ( C₁ + C₂ ) + 1, by positivity, fun x hx => _ ⟩;
      refine' le_trans ( add_le_add ( show iterExp D ( C₁ * x ^ max N₁ N₂ ) ≤ iterExp D ( ( C₁ + C₂ ) * x ^ max N₁ N₂ ) from _ ) ( show iterExp D ( C₂ * x ^ max N₁ N₂ ) ≤ iterExp D ( ( C₁ + C₂ ) * x ^ max N₁ N₂ ) from _ ) ) _;
      · exact iterExp_mono _ ( by nlinarith [ pow_pos ( zero_lt_one.trans_le hx ) ( max N₁ N₂ ) ] );
      · exact iterExp_mono _ ( by nlinarith [ pow_pos ( zero_lt_one.trans_le hx ) ( max N₁ N₂ ) ] );
      · refine' le_trans ( h_step _ _ ) _;
        · positivity;
        · refine' iterExp_mono _ _;
          nlinarith [ pow_le_pow_right₀ hx ( show max N₁ N₂ ≥ 0 by positivity ) ];
    obtain ⟨ C, hC₁, hC₂ ⟩ := h_ind_step D hD;
    refine' ⟨ C, hC₁, fun x hx => le_trans _ ( hC₂ x hx ) ⟩;
    gcongr;
    · exact iterExp_mono _ ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( Nat.le_max_left _ _ ) ) ( by positivity ) );
    · exact iterExp_mono _ ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( le_max_right _ _ ) ) ( by positivity ) );
  exact Exists.elim ( h_ind D hD ) fun C hC => ⟨ C, hC.1, max N₁ N₂, 1, hC.2 ⟩

theorem iterExp_mul_poly_bound (D : ℕ) (hD : 1 ≤ D) (C₁ C₂ : ℝ)
    (hC₁ : 0 < C₁) (hC₂ : 0 < C₂) (N₁ N₂ : ℕ) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      iterExp D (C₁ * x ^ N₁) * iterExp D (C₂ * x ^ N₂) ≤ iterExp D (C * x ^ N) := by
  rcases D with ( _ | D ) <;> simp_all +decide [ iterExp_succ ];
  by_cases hD : 1 ≤ D <;> simp_all +decide [ ← Real.exp_add ];
  · convert iterExp_sum_poly_bound D hD C₁ C₂ hC₁ hC₂ N₁ N₂ using 1;
  · use C₁ + C₂, by positivity, max N₁ N₂, 1;
    exact fun x hx => by rw [ add_mul ] ; exact add_le_add ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( Nat.le_max_left _ _ ) ) hC₁.le ) ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( Nat.le_max_right _ _ ) ) hC₂.le ) ;

theorem iterExp_prod_to_next_level (D : ℕ) (C₁ C₂ : ℝ) (hC₁ : 0 < C₁)
    (hC₂ : 0 < C₂) (N₁ N₂ : ℕ) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      iterExp D (C₁ * x ^ N₁) * Real.exp (iterExp D (C₂ * x ^ N₂))
        ≤ iterExp (D + 1) (C * x ^ N) := by
  by_cases hD : D ≥ 1;
  · -- By iterExp_sum_poly_bound (for D ≥ 1), the sum is ≤ iterExp D (C'*x^N').
    obtain ⟨C', hC'⟩ : ∃ C' : ℝ, 0 < C' ∧ ∃ N' : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → iterExp D (C₁ * x ^ N₁) + iterExp D (C₂ * x ^ N₂) ≤ iterExp D (C' * x ^ N') := by
      exact?;
    -- LHS ≤ exp(iterExp D (C₁*x^N₁)) * exp(iterExp D (C₂*x^N₂)) = exp(iterExp D (C₁*x^N₁) + iterExp D (C₂*x^N₂)).
    have h_lhs_bound : ∀ x : ℝ, iterExp D (C₁ * x ^ N₁) * Real.exp (iterExp D (C₂ * x ^ N₂)) ≤ Real.exp (iterExp D (C₁ * x ^ N₁) + iterExp D (C₂ * x ^ N₂)) := by
      intro x; rw [ Real.exp_add ] ; gcongr;
      linarith [ Real.add_one_le_exp ( iterExp D ( C₁ * x ^ N₁ ) ) ];
    exact ⟨ C', hC'.1, hC'.2.choose, hC'.2.choose_spec.choose, fun x hx => le_trans ( h_lhs_bound x ) ( Real.exp_le_exp.mpr ( hC'.2.choose_spec.choose_spec x hx ) ) ⟩;
  · interval_cases D ; norm_num [ iterExp ];
    -- Choose $C = C₁ + C₂$ and $N = \max(N₁, N₂) + 1$.
    use C₁ + C₂, by linarith, max N₁ N₂ + 1, 1;
    intro x hx
    have h_exp : C₁ * x ^ N₁ * Real.exp (C₂ * x ^ N₂) ≤ Real.exp (C₁ * x ^ N₁ + C₂ * x ^ N₂) := by
      rw [ Real.exp_add ];
      exact mul_le_mul_of_nonneg_right ( by linarith [ Real.add_one_le_exp ( C₁ * x ^ N₁ ) ] ) ( Real.exp_nonneg _ );
    refine le_trans h_exp <| Real.exp_le_exp.mpr ?_;
    rw [ add_mul ];
    exact add_le_add ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( by linarith [ Nat.le_max_left N₁ N₂ ] ) ) hC₁.le ) ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( by linarith [ Nat.le_max_right N₁ N₂ ] ) ) hC₂.le )

/-! ## Per-case helper lemmas for structural induction -/

private theorem hasPTM_var : HasPolyTowerMajorant EMLExpr.var.growthRank .var := by
  use 1, by norm_num, 1, 0;
  norm_num [ EMLExpr.eval, EMLExpr.growthRank ];
  exact fun x hx => by rw [ abs_of_nonneg hx ] ;

private theorem hasPTM_const (c : ℝ) : HasPolyTowerMajorant (EMLExpr.const c).growthRank (.const c) := by
  refine' ⟨ 1 + |c|, by positivity, 0, 0, fun x hx => _ ⟩;
  simp [EMLExpr.eval];
  exact le_trans ( by norm_num ) ( iterExp_ge_self _ ( by positivity ) )

private theorem hasPTM_neg {a : EMLExpr} (ha : HasPolyTowerMajorant a.growthRank a) :
    HasPolyTowerMajorant (EMLExpr.neg a).growthRank (.neg a) := by
  obtain ⟨ C, hC₀, N, X₀, hX₀ ⟩ := ha;
  exact ⟨ C, hC₀, N, X₀, fun x hx => by simpa [ EMLExpr.eval ] using hX₀ x hx ⟩

private theorem hasPTM_add {a b : EMLExpr}
    (ha : HasPolyTowerMajorant a.growthRank a) (hb : HasPolyTowerMajorant b.growthRank b) :
    HasPolyTowerMajorant (a.add b).growthRank (a.add b) := by
  -- By definition of `HasPolyTowerMajorant`, we need to find constants $C$, $N$, and $X₀$ such that $|a.eval x + b.eval x| \leq iterExp D (C * x^N)$ for all $x \geq X₀$.
  obtain ⟨Ca, hCa_pos, Na, X₀a, hCa⟩ := ha
  obtain ⟨Cb, hCb_pos, Nb, X₀b, hCb⟩ := hb;
  -- By definition of `HasPolyTowerMajorant`, we need to find constants $C$, $N$, and $X₀$ such that $|a.eval x + b.eval x| \leq iterExp D (C * x^N)$ for all $x \geq X₀$. We'll use the bounds from `hCa` and `hCb`.
  have h_sum_bound : ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
    iterExp a.growthRank (Ca * x ^ Na) + iterExp b.growthRank (Cb * x ^ Nb) ≤ iterExp (max a.growthRank b.growthRank) (C * x ^ N) := by
      by_cases hD : max a.growthRank b.growthRank = 0;
      · cases max_eq_iff.mp hD <;> simp_all +decide [ iterExp ];
        · use Ca + Cb, by positivity, max Na Nb, 1;
          exact fun x hx => by rw [ add_mul ] ; exact add_le_add ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( le_max_left _ _ ) ) hCa_pos.le ) ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( le_max_right _ _ ) ) hCb_pos.le ) ;
        · use Ca + Cb, by positivity, max Na Nb, 1;
          exact fun x hx => by rw [ add_mul ] ; exact add_le_add ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( Nat.le_max_left _ _ ) ) hCa_pos.le ) ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( Nat.le_max_right _ _ ) ) hCb_pos.le ) ;
      · have := iterExp_sum_poly_bound ( max a.growthRank b.growthRank ) ( Nat.pos_of_ne_zero hD ) Ca Cb hCa_pos hCb_pos Na Nb;
        obtain ⟨ C, hC_pos, N, X₀, h ⟩ := this; use C, hC_pos, N, Max.max X₀ 1; intro x hx; specialize h x ( le_trans ( le_max_left _ _ ) hx ) ; simp_all +decide [ iterExp_level_mono ] ;
        refine le_trans ?_ h;
        gcongr;
        · exact iterExp_level_mono ( le_max_left _ _ ) ( by exact mul_pos hCa_pos ( pow_pos ( by linarith ) _ ) );
        · exact iterExp_level_mono ( le_max_right _ _ ) ( by exact mul_pos hCb_pos ( pow_pos ( by linarith ) _ ) );
  obtain ⟨ C, hC_pos, N, X₀, hC ⟩ := h_sum_bound; use C, hC_pos, N, max X₀ ( Max.max X₀a X₀b ) ; intro x hx; simp_all +decide [ abs_le ] ;
  constructor <;> linarith! [ hCa x hx.2.1, hCb x hx.2.2, hC x hx.1, show ( a.add b ).eval x = a.eval x + b.eval x from rfl, show ( a.add b ).growthRank = max a.growthRank b.growthRank from rfl ]

private theorem hasPTM_mul {a b : EMLExpr}
    (ha : HasPolyTowerMajorant a.growthRank a) (hb : HasPolyTowerMajorant b.growthRank b) :
    HasPolyTowerMajorant (a.mul b).growthRank (a.mul b) := by
  -- Let D = max(a.growthRank, b.growthRank).
  set D := max a.growthRank b.growthRank with hD
  have h_mul : HasPolyTowerMajorant D (a.mul b) := by
    -- By definition of $D$, we know that for $x \geq X₀$, $|a.eval x| \leq iterExp D (Ca * x ^ Na)$ and $|b.eval x| \leq iterExp D (Cb * x ^ Nb)$.
    obtain ⟨Ca, hCa_pos, Na, X₀a, hCa⟩ := ha
    obtain ⟨Cb, hCb_pos, Nb, X₀b, hCb⟩ := hb;
    -- By definition of $D$, we know that for $x \geq X₀$, $|a.eval x * b.eval x| \leq iterExp D (Ca * x ^ Na) * iterExp D (Cb * x ^ Nb)$.
    have h_prod : ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → |a.eval x * b.eval x| ≤ iterExp D (Ca * x ^ Na) * iterExp D (Cb * x ^ Nb) := by
      use max X₀a (max X₀b 1);
      intro x hx; rw [ abs_mul ] ; refine' mul_le_mul _ _ _ _;
      · exact le_trans ( hCa x ( le_trans ( le_max_left _ _ ) hx ) ) ( iterExp_level_mono ( by aesop ) ( by exact mul_pos hCa_pos ( pow_pos ( by linarith [ le_max_right X₀a ( max X₀b 1 ), le_max_right X₀b 1 ] ) _ ) ) );
      · refine' le_trans ( hCb x ( by aesop ) ) _;
        exact iterExp_level_mono ( le_max_right _ _ ) ( mul_pos hCb_pos ( pow_pos ( by linarith [ le_max_right X₀a ( max X₀b 1 ), le_max_right X₀b 1 ] ) _ ) );
      · grind;
      · exact le_of_lt ( iterExp_pos_of_pos _ ( mul_pos hCa_pos ( pow_pos ( by linarith [ le_max_right X₀a ( max X₀b 1 ), le_max_right X₀b 1 ] ) _ ) ) );
    by_cases hD : 1 ≤ D;
    · obtain ⟨ C, hC_pos, N, X₀, hC ⟩ := iterExp_mul_poly_bound D hD Ca Cb hCa_pos hCb_pos Na Nb;
      exact ⟨ C, hC_pos, N, Max.max X₀ h_prod.choose, fun x hx => le_trans ( h_prod.choose_spec x ( le_trans ( le_max_right _ _ ) hx ) ) ( hC x ( le_trans ( le_max_left _ _ ) hx ) ) ⟩;
    · obtain ⟨ X₀, hX₀ ⟩ := h_prod; use Ca * Cb, mul_pos hCa_pos hCb_pos, Na + Nb, Max.max X₀ 1; intros x hx; simp_all +decide [ iterExp ] ;
      convert hX₀ x hx.1 using 1 ; ring!;
      · rw [ ← abs_mul ] ; rfl;
      · ring;
  convert h_mul using 1

private theorem hasPTM_eml {a b : EMLExpr}
    (ha : HasPolyTowerMajorant a.growthRank a) (hb : HasPolyTowerMajorant b.growthRank b) :
    HasPolyTowerMajorant (a.eml b).growthRank (a.eml b) := by
  -- By definition of growth rank, we have (a.eml b).growthRank = 1 + max a.growthRank b.growthRank.
  have h_growth_rank : (a.eml b).growthRank = 1 + max a.growthRank b.growthRank := by
    rfl;
  -- By definition of `HasPolyTowerMajorant`, we need to show that there exist constants $C$ and $N$ such that $|a.eval x * exp(b.eval x)| \leq iterExp (1 + max(a.growthRank, b.growthRank)) (C * x^N)$ for sufficiently large $x$.
  obtain ⟨Ca, hCa_pos, Na, X₀, hCa⟩ := ha
  obtain ⟨Cb, hCb_pos, Nb, Y₀, hCb⟩ := hb;
  -- By definition of `HasPolyTowerMajorant`, we need to show that there exist constants $C$ and $N$ such that $|a.eval x * exp(b.eval x)| \leq iterExp (1 + max(a.growthRank, b.growthRank)) (C * x^N)$ for sufficiently large $x$. We can use the bounds from `hCa` and `hCb`.
  have h_bound : ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
    |a.eval x| * Real.exp (|b.eval x|) ≤ iterExp (max a.growthRank b.growthRank + 1) (C * x ^ N) := by
      -- By definition of `HasPolyTowerMajorant`, we need to show that there exist constants $C$ and $N$ such that $|a.eval x| \leq iterExp (max a.growthRank b.growthRank) (Ca * x ^ Na)$ and $|b.eval x| \leq iterExp (max a.growthRank b.growthRank) (Cb * x ^ Nb)$ for sufficiently large $x$.
      obtain ⟨Ca', hCa'_pos, Na', X₀', hCa'⟩ : ∃ Ca' : ℝ, 0 < Ca' ∧ ∃ Na' : ℕ, ∃ X₀' : ℝ, ∀ x : ℝ, x ≥ X₀' →
        iterExp a.growthRank (Ca * x ^ Na) ≤ iterExp (max a.growthRank b.growthRank) (Ca' * x ^ Na') := by
          by_cases h_cases : a.growthRank ≤ b.growthRank;
          · use Ca, hCa_pos, Na, 1;
            exact fun x hx => iterExp_level_mono ( by aesop ) ( by positivity );
          · simp_all +decide [ max_eq_left ( le_of_not_ge h_cases ) ];
            exact ⟨ Ca, hCa_pos, Na, X₀, fun x hx => le_rfl ⟩;
      obtain ⟨Cb', hCb'_pos, Nb', Y₀', hCb'⟩ : ∃ Cb' : ℝ, 0 < Cb' ∧ ∃ Nb' : ℕ, ∃ Y₀' : ℝ, ∀ x : ℝ, x ≥ Y₀' →
        iterExp b.growthRank (Cb * x ^ Nb) ≤ iterExp (max a.growthRank b.growthRank) (Cb' * x ^ Nb') := by
          by_cases h : b.growthRank ≤ max a.growthRank b.growthRank;
          · use Cb, hCb_pos, Nb, 1;
            exact fun x hx => iterExp_level_mono h ( by positivity );
          · exact False.elim <| h <| le_max_right _ _;
      -- Apply the lemma `iterExp_prod_to_next_level` to combine the bounds.
      obtain ⟨C, hC_pos, N, X₀'', hC⟩ : ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀'' : ℝ, ∀ x : ℝ, x ≥ X₀'' →
        iterExp (max a.growthRank b.growthRank) (Ca' * x ^ Na') * Real.exp (iterExp (max a.growthRank b.growthRank) (Cb' * x ^ Nb')) ≤ iterExp (max a.growthRank b.growthRank + 1) (C * x ^ N) := by
          apply_rules [ iterExp_prod_to_next_level ];
      use C, hC_pos, N, max (max X₀ X₀') (max Y₀ Y₀' |> max <| X₀'');
      simp +zetaDelta at *;
      intro x hx₁ hx₂ hx₃ hx₄ hx₅; refine le_trans ?_ ( hC x hx₅ ) ; gcongr;
      · grind +locals;
      · exact le_trans ( hCa x hx₁ ) ( hCa' x hx₂ );
      · exact le_trans ( hCb x hx₃ ) ( hCb' x hx₄ );
  obtain ⟨ C, hC_pos, N, X₀, hC ⟩ := h_bound; use C, hC_pos, N, X₀; intros x hx; simp_all +decide [ add_comm, EMLExpr.eval ] ;
  exact le_trans ( mul_le_mul_of_nonneg_left ( Real.exp_le_exp.mpr ( le_abs_self _ ) ) ( abs_nonneg _ ) ) ( hC x hx )

/-! ## Main Upper Bound: Structural Induction -/

/-- **Upper bound theorem**: For any inverse-free expression `e`,
    `|e.eval x| ≤ iterExp (growthRank e) (C * x^N)` eventually.

    This proves that `growthRank` gives a valid tower majorant level.
    The proof proceeds by structural induction using per-case helper lemmas. -/
theorem growthRank_hasPolyTowerMajorant (e : EMLExpr) (hInv : e.noInv) :
    HasPolyTowerMajorant e.growthRank e := by
  induction e with
  | var => exact hasPTM_var
  | const c => exact hasPTM_const c
  | neg a ih => exact hasPTM_neg (ih (by simp [EMLExpr.noInv] at hInv; exact hInv))
  | inv _ _ => simp [EMLExpr.noInv] at hInv
  | add a b iha ihb =>
    simp [EMLExpr.noInv] at hInv
    exact hasPTM_add (iha hInv.1) (ihb hInv.2)
  | mul a b iha ihb =>
    simp [EMLExpr.noInv] at hInv
    exact hasPTM_mul (iha hInv.1) (ihb hInv.2)
  | eml a b iha ihb =>
    simp [EMLExpr.noInv] at hInv
    exact hasPTM_eml (iha hInv.1) (ihb hInv.2)

/-! ## Lower Bound: Tower Expressions Cannot Be Majorized Below Their Level -/

/-
**Strict separation for iterExp**: `iterExp k x` cannot be eventually bounded
    by `iterExp j (C * x^N)` when `j < k`.
-/
theorem iterExp_not_majorized_below (k : ℕ) {j : ℕ} (hj : j < k) (C : ℝ) (_hC : 0 < C)
    (N : ℕ) :
    ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → iterExp j (C * x ^ N) < iterExp k x := by
  exact ⟨ Max.max 1 ( Classical.choose ( iterExp_poly_lt_iterExp_succ j C N ) ), fun x hx => by
    refine' lt_of_lt_of_le ( Classical.choose_spec ( iterExp_poly_lt_iterExp_succ j C N ) x ( le_trans ( le_max_right _ _ ) hx ) ) _;
    exact iterExp_level_mono ( by linarith ) ( by linarith [ le_max_left 1 ( Classical.choose ( iterExp_poly_lt_iterExp_succ j C N ) ) ] ) ⟩

/-
**Lower bound for tower expressions**: `towerExpr k` cannot have a tower majorant
    at any level below `k`.
-/
theorem towerExpr_not_majorized_below (k : ℕ) {j : ℕ} (hj : j < k) :
    ¬ HasPolyTowerMajorant j (towerExpr k) := by
  -- Assume HasPolyTowerMajorant j (towerExpr k) for contradiction.
  intro h
  obtain ⟨C, hC_pos, N, X₀, hX₀⟩ := h;
  -- By iterExp_not_majorized_below, there exists X₁ such that for all x ≥ X₁, iterExp j (C * x^N) < iterExp k x.
  obtain ⟨X₁, hX₁⟩ : ∃ X₁ : ℝ, ∀ x : ℝ, x ≥ X₁ → iterExp j (C * x ^ N) < iterExp k x := by
    exact?;
  -- Choose x = max X₀ X₁ + 1.
  set x := max X₀ X₁ + 1;
  -- By definition of $x$, we have $x \geq X₀$ and $x \geq X₁$.
  have hx₀ : x ≥ X₀ := by
    exact le_add_of_le_of_nonneg ( le_max_left _ _ ) zero_le_one
  have hx₁ : x ≥ X₁ := by
    exact le_trans ( le_max_right _ _ ) ( le_add_of_nonneg_right zero_le_one );
  exact not_le_of_gt ( hX₁ x hx₁ ) ( le_trans ( by rw [ towerExpr_eval ] ; exact le_abs_self _ ) ( hX₀ x hx₀ ) )

/-! ## Completeness: Exact Tower Level for Canonical Expressions -/

/-
**Upper bound for towerExpr**: `towerExpr k` has a tower majorant at level `k`.
-/
theorem towerExpr_hasPolyTowerMajorant (k : ℕ) :
    HasPolyTowerMajorant k (towerExpr k) := by
  -- Use C = 1, N = 1, X₀ = 0. For x ≥ 0, |towerExpr k . eval x| = |iterExp k x| by towerExpr_eval.
  have h_upper_bound : ∀ x : ℝ, 0 ≤ x → |(towerExpr k).eval x| ≤ iterExp k (1 * x ^ 1) := by
    intro x hx; rw [ towerExpr_eval ] ; norm_num [ abs_of_nonneg, hx, iterExp_pos_of_pos ] ;
    rw [ abs_of_nonneg ( by exact Nat.recOn k ( by aesop ) fun n ihn => by rw [ iterExp_succ ] ; positivity ) ];
  exact ⟨ 1, by norm_num, 1, 0, fun x hx => h_upper_bound x hx ⟩

/-- **Flagship theorem**: `towerExpr k` lives at exact polynomial tower level `k`. -/
theorem towerExpr_exact_level (k : ℕ) :
    ExactPolyTowerLevel k (towerExpr k) :=
  ⟨towerExpr_hasPolyTowerMajorant k, fun _j hj => towerExpr_not_majorized_below k hj⟩

/-- Combined: `towerExpr k` is inverse-free and at exact level `k`. -/
theorem towerExpr_inverseFree_exact (k : ℕ) :
    (towerExpr k).noInv ∧ ExactPolyTowerLevel k (towerExpr k) :=
  ⟨towerExpr_noInv k, towerExpr_exact_level k⟩

/-- **Hierarchy existence**: For every `k`, there exists an inverse-free expression
    at exact tower level `k`. -/
theorem exists_expression_exactly_at_level (k : ℕ) :
    ∃ e : EMLExpr, e.noInv ∧ ExactPolyTowerLevel k e :=
  ⟨towerExpr k, towerExpr_inverseFree_exact k⟩

/-! ## Semantic Invariance -/

/-
**Congruence**: `HasPolyTowerMajorant` is preserved under extensional equality.
-/
theorem hasPolyTowerMajorant_congr {e₁ e₂ : EMLExpr}
    (hEq : ∀ x : ℝ, e₁.eval x = e₂.eval x) :
    ∀ k, HasPolyTowerMajorant k e₁ ↔ HasPolyTowerMajorant k e₂ := by
  intro k; constructor <;> rintro ⟨ C, hC₀, N, X₀, hX₀ ⟩ <;> use C, hC₀, N, X₀ <;> intro x hx <;> simpa only [ hEq ] using hX₀ x hx;

/-- **Semantic invariance of exact level**: If two expressions agree extensionally,
    then one is at exact level `k` iff the other is. -/
theorem exactPolyTowerLevel_congr {e₁ e₂ : EMLExpr}
    (hEq : ∀ x : ℝ, e₁.eval x = e₂.eval x) :
    ∀ k, ExactPolyTowerLevel k e₁ ↔ ExactPolyTowerLevel k e₂ := by
  intro k
  unfold ExactPolyTowerLevel
  constructor
  · rintro ⟨h1, h2⟩
    exact ⟨(hasPolyTowerMajorant_congr hEq k).mp h1,
           fun j hj => (hasPolyTowerMajorant_congr hEq j).not.mp (h2 j hj)⟩
  · rintro ⟨h1, h2⟩
    exact ⟨(hasPolyTowerMajorant_congr hEq k).mpr h1,
           fun j hj => (hasPolyTowerMajorant_congr hEq j).not.mpr (h2 j hj)⟩

/-! ## Monotonicity of HasPolyTowerMajorant -/

/-
Tower majorant at level `k` implies tower majorant at level `k + 1`.
-/
theorem hasPolyTowerMajorant_succ {k : ℕ} {e : EMLExpr}
    (h : HasPolyTowerMajorant k e) :
    HasPolyTowerMajorant (k + 1) e := by
  obtain ⟨ C, hC_pos, N, X₀, h_bound ⟩ := h;
  -- Choose $X₀' = \max(X₀, 1)$.
  set X₀' := max X₀ 1 with hX₀';
  refine' ⟨ C, hC_pos, N, X₀', fun x hx => le_trans ( h_bound x ( le_trans ( le_max_left _ _ ) hx ) ) _ ⟩;
  exact iterExp_strict_level_increase ( mul_pos hC_pos ( pow_pos ( by linarith [ le_max_right X₀ 1 ] ) _ ) ) _ |> le_of_lt

/-
Tower majorant is monotone in the level parameter.
-/
theorem hasPolyTowerMajorant_mono {j k : ℕ} {e : EMLExpr}
    (hjk : j ≤ k) (h : HasPolyTowerMajorant j e) :
    HasPolyTowerMajorant k e := by
  induction' hjk with k hk ih.exists_eq_add_of_le hjk;
  · grind;
  · exact?

/-! ## Strict Hierarchy Theorem -/

/-- **Strict hierarchy**: Tower levels are semantically strict—there exist
    expressions at each level that cannot be majorized at lower levels. -/
theorem growthRank_strict_hierarchy :
    ∀ k : ℕ, ∃ e : EMLExpr, e.noInv ∧ e.growthRank = k ∧
      ∀ j < k, ¬ HasPolyTowerMajorant j e := by
  intro k
  exact ⟨towerExpr k, towerExpr_noInv k, towerExpr_growthRank k,
         fun j hj => towerExpr_not_majorized_below k hj⟩

/-! ## Cross-Domain: Fast-Growing Hierarchy Connection -/

/-
`iterExp k x ≤ FGHFinite k x` for `x ≥ 0`: the FGH function grows
    at least as fast as iterExp at the same level.
-/
theorem iterExp_le_FGHFinite (k : ℕ) :
    ∀ x : ℝ, x ≥ 0 → iterExp k x ≤ FGHFinite k x := by
  induction' k with k ih <;> simp_all +decide [ iterExp, FGHFinite ]

/-
`FGHFinite k x ≤ iterExp (k+1) x` for large x: the FGH function is
    bounded by the next tower level.
-/
theorem FGHFinite_le_iterExp_succ (k : ℕ) :
    ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → FGHFinite k x ≤ iterExp (k + 1) x := by
  -- By induction on $k$, we can show that $FGHFinite k x \leq iterExp (k + 1) x$ for all $x \geq 0$.
  have h_ind : ∀ k, ∀ x : ℝ, x ≥ 0 → FGHFinite k x ≤ iterExp (k + 1) x := by
    intro k x hx;
    induction' k with k ih generalizing x <;> simp_all +decide [ FGHFinite, iterExp ];
    linarith [ Real.add_one_le_exp x ];
  exact ⟨ 0, fun x hx => h_ind k x hx ⟩

/-
**Cross-domain bridge**: Growth rank connects to fast-growing hierarchies.
    `towerExpr k` and `FGHFinite k` are at the same asymptotic tower level.
-/
theorem towerExpr_compare_FGHFinite (k : ℕ) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∀ x : ℝ, x ≥ 1 →
      (towerExpr k).eval x ≤ FGHFinite k x ∧
      FGHFinite k x ≤ iterExp (k + 1) (C * x ^ N) := by
  refine' ⟨ 1, by norm_num, 1, fun x hx => ⟨ _, _ ⟩ ⟩ <;> norm_num [ iterExp ] at *;
  · convert iterExp_le_FGHFinite k x ( by linarith ) using 1 ; rw [ towerExpr_eval ];
  · induction' k with k ih generalizing x <;> simp_all +decide [ FGHFinite ];
    linarith [ Real.add_one_le_exp x ]

/-! ## Certified Algorithm Correctness -/

/-- **Certified correctness**: For canonical tower expressions, `certifyGrowthRank`
    computes the exact tower level. -/
theorem certifyGrowthRank_correct_towerExpr (k : ℕ) :
    ExactPolyTowerLevel (certifyGrowthRank (towerExpr k)) (towerExpr k) := by
  simp only [certifyGrowthRank, towerExpr_growthRank]
  exact towerExpr_exact_level k

/-- **Upper bound correctness**: For all inverse-free expressions,
    `certifyGrowthRank` gives a valid tower majorant level. -/
theorem certifyGrowthRank_upper_bound (e : EMLExpr) (hInv : e.noInv) :
    HasPolyTowerMajorant (certifyGrowthRank e) e := by
  simp only [certifyGrowthRank]
  exact growthRank_hasPolyTowerMajorant e hInv

/-! ## Depth-Optimal Representation -/

/-
No inverse-free expression of depth ≤ D can represent `iterExp n` for n > D.
-/
theorem no_invFree_lowDepth_represents_iterExp (D n : ℕ) (hnd : D < n) :
    ¬ ∃ e : EMLExpr, e.noInv ∧ e.emlDepth ≤ D ∧ RepresentsOnPos e (iterExp n) := by
  intro h
  obtain ⟨e, h_noInv, h_emlDepth, h_rep⟩ := h
  have h_upper_bound : HasPolyTowerMajorant (e.emlDepth) e := by
    convert growthRank_hasPolyTowerMajorant e h_noInv using 1 ; rw [ growthRank_eq_emlDepth_of_noInv e h_noInv ]
  have h_lower_bound : ¬ HasPolyTowerMajorant D e := by
    intro h
    obtain ⟨C, hC_pos, N, X₀, h_bound⟩ := h
    have h_contradiction : ∃ X₁ : ℝ, ∀ x : ℝ, x ≥ X₁ → iterExp D (C * x ^ N) < iterExp n x := by
      exact?
    obtain ⟨X₁, hX₁⟩ := h_contradiction
    have h_contradiction' : ∃ x : ℝ, x ≥ max X₀ (max X₁ 1) ∧ iterExp n x ≤ iterExp D (C * x ^ N) := by
      exact ⟨ Max.max X₀ ( Max.max X₁ 1 ), le_rfl, by linarith [ abs_le.mp ( h_bound ( Max.max X₀ ( Max.max X₁ 1 ) ) ( le_max_left _ _ ) ), h_rep ( Max.max X₀ ( Max.max X₁ 1 ) ) ( by positivity ) ] ⟩
    obtain ⟨x, hx₁, hx₂⟩ := h_contradiction'
    linarith [hX₁ x (by linarith [le_max_left X₀ (max X₁ 1), le_max_right X₀ (max X₁ 1), le_max_left X₁ 1, le_max_right X₁ 1])]
  exact h_lower_bound (by
  exact hasPolyTowerMajorant_mono h_emlDepth h_upper_bound)

end