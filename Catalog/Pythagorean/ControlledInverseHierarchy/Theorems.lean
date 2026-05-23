/-
# Controlled-Inverse Depth Hierarchy — Core Theorems

This file proves the controlled-inverse depth hierarchy theorem:
EML expressions with controlled inverses of depth D cannot represent
`iterExp n` for any `n > D`. The key insight is that controlled inverses
(where the argument is bounded away from zero) don't increase the
poly-tower majorant height — their reciprocals are bounded constants.

## Proof Strategy (Poly-Tower Majorant Extension)

1. **Inverse Majorant Preservation**: If `spectralMargin e ≥ δ > 0`, then
   `|inv(e)| ≤ 1/δ`, which is a constant — majorizable at tower height 0.
2. **Inductive tower construction**: Every controlled-inverse expression of
   depth D has a poly-tower majorant of height D.
3. **Comparison**: `iterExp(D+1, x)` eventually exceeds any poly-tower of height D.
-/
import Pythagorean.ControlledInverseHierarchy.Defs

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

theorem iterExp_ge_self (n : ℕ) {x : ℝ} (hx : 0 ≤ x) : x ≤ iterExp n x := by
  induction n with
  | zero => simp
  | succ n ih =>
    calc x ≤ iterExp n x := ih
    _ ≤ Real.exp (iterExp n x) := by linarith [Real.add_one_le_exp (iterExp n x)]

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

/-! ## iterExp bounds for sums and products of poly-tower expressions -/

theorem iterExp_sum_poly_bound (k : ℕ) (hk : 1 ≤ k)
    (Ca Cb : ℝ) (hCa : 0 < Ca) (hCb : 0 < Cb) (Na Nb : ℕ) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      iterExp k (Ca * x ^ Na) + iterExp k (Cb * x ^ Nb) ≤ iterExp k (C * x ^ N) := by
  -- Let $N = \max(Na, Nb)$.
  set N := max Na Nb with hN_def;
  -- By induction on $k$, we can show that for any $y \geq 0$, $2 \cdot \text{iterExp}(k, y) \leq \text{iterExp}(k, 2y + \log 2)$.
  have h_ind : ∀ k : ℕ, 1 ≤ k → ∀ y : ℝ, 0 ≤ y → 2 * iterExp k y ≤ iterExp k (2 * y + Real.log 2) := by
    intro k hk y hy; induction hk <;> simp_all +decide [ iterExp ] ;
    · rw [ two_mul, Real.exp_add, two_mul, Real.exp_add, Real.exp_log ] <;> nlinarith [ Real.add_one_le_exp y ];
    · rw [ ← Real.log_le_log_iff ( by positivity ) ( by positivity ), Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp, Real.log_exp ];
      nontriviality;
      rename_i k hk ih;
      rename_i m hm;
      have h_log : ∀ n : ℕ, 1 ≤ n → ∀ x : ℝ, 0 ≤ x → Real.log 2 + iterExp n x ≤ 2 * iterExp n x := by
        intros n hn x hx; induction' hn with n hn ih generalizing x <;> simp_all +decide [ iterExp ] ;
        · linarith [ Real.log_le_sub_one_of_pos zero_lt_two, Real.add_one_le_exp x ];
        · linarith [ Real.log_le_sub_one_of_pos zero_lt_two, Real.add_one_le_exp ( iterExp n x ), show 0 ≤ iterExp n x from Nat.recOn n ( by exact hx ) fun n ihn => by exact Real.exp_nonneg _ ];
      linarith [ h_log hm k y hy ];
  -- Choose $C = 2 * (Ca + Cb) + \log 2$.
  use 2 * (Ca + Cb) + Real.log 2, by
    positivity, N, 1
  generalize_proofs at *; (
  intro x hx
  have h_bound : iterExp k (Ca * x ^ Na) + iterExp k (Cb * x ^ Nb) ≤ 2 * iterExp k ((Ca + Cb) * x ^ N) := by
    have h_bound : iterExp k (Ca * x ^ Na) ≤ iterExp k ((Ca + Cb) * x ^ N) ∧ iterExp k (Cb * x ^ Nb) ≤ iterExp k ((Ca + Cb) * x ^ N) := by
      exact ⟨ iterExp_mono k <| by exact mul_le_mul ( by linarith ) ( pow_le_pow_right₀ hx <| by aesop ) ( by positivity ) <| by positivity, iterExp_mono k <| by exact mul_le_mul ( by linarith ) ( pow_le_pow_right₀ hx <| by aesop ) ( by positivity ) <| by positivity ⟩
    generalize_proofs at *; (
    linarith)
  generalize_proofs at *; (
  refine le_trans h_bound <| le_trans ( h_ind k hk _ <| by positivity ) ?_ ; ring_nf ; (
  exact iterExp_mono k <| by nlinarith [ pow_le_pow_right₀ hx <| show N ≥ 0 by positivity, Real.log_nonneg one_le_two ] ;)))

theorem iterExp_mul_poly_bound (k : ℕ) (hk : 1 ≤ k)
    (Ca Cb : ℝ) (hCa : 0 < Ca) (hCb : 0 < Cb) (Na Nb : ℕ) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      iterExp k (Ca * x ^ Na) * iterExp k (Cb * x ^ Nb) ≤ iterExp k (C * x ^ N) := by
  rcases k with ( _ | k ) <;> simp_all +decide [ iterExp ];
  -- By Lemma~\ref{lem:iterExp_sum_poly_bound}, for k ≥ 1, there exist C, N such that iterExp k (Ca * x ^ Na) + iterExp k (Cb * x ^ Nb) ≤ iterExp k (C * x ^ N) for x ≥ X₀.
  by_cases hk_pos : 1 ≤ k
  generalize_proofs at *; (
  obtain ⟨ C, hC_pos, N, X₀, h ⟩ := iterExp_sum_poly_bound k hk_pos Ca Cb hCa hCb Na Nb; use C, hC_pos, N, X₀; intros x hx; rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( h x hx ) ;);
  interval_cases k ; use Ca + Cb ; use by positivity ; ; use Max.max Na Nb ; use 1 ; intros x hx ; rw [ ← Real.exp_add ] ; norm_num [ iterExp ] ; ring_nf ; (
  gcongr <;> aesop;);

theorem iterExp_prod_to_next_level (k : ℕ)
    (Ca Cb : ℝ) (hCa : 0 < Ca) (hCb : 0 < Cb) (Na Nb : ℕ) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      iterExp k (Ca * x ^ Na) * Real.exp (iterExp k (Cb * x ^ Nb))
        ≤ iterExp (k + 1) (C * x ^ N) := by
  by_cases hk : 1 ≤ k;
  · -- By the sum bound (iterExp_sum_poly_bound for k ≥ 1), we have that iterExp k (Ca * x ^ Na) + iterExp k (Cb * x ^ Nb) ≤ iterExp k (C * x ^ N).
    obtain ⟨C, hC_pos, N, X₀, h_bound⟩ : ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      iterExp k (Ca * x ^ Na) + iterExp k (Cb * x ^ Nb) ≤ iterExp k (C * x ^ N) := by
        exact?;
    refine' ⟨ C, hC_pos, N, Max.max X₀ 1, fun x hx => _ ⟩ ; simp_all +decide [ Real.exp_pos ];
    refine' le_trans _ ( Real.exp_le_exp.mpr ( h_bound x hx.1 ) );
    rw [ Real.exp_add ];
    gcongr;
    exact le_trans ( by norm_num ) ( Real.add_one_le_exp _ );
  · simp_all +decide [ iterExp ];
    -- Choose $C = Ca + Cb + 1$ and $N = Na + Nb + 1$.
    use Ca + Cb + 1, by positivity, Na + Nb + 1, 1;
    intro x hx
    have h_exp : Ca * x ^ Na * Real.exp (Cb * x ^ Nb) ≤ Real.exp (Ca * x ^ Na + Cb * x ^ Nb) := by
      rw [ Real.exp_add ];
      exact mul_le_mul_of_nonneg_right ( by linarith [ Real.add_one_le_exp ( Ca * x ^ Na ) ] ) ( Real.exp_nonneg _ );
    refine le_trans h_exp <| Real.exp_le_exp.mpr ?_;
    ring_nf;
    nlinarith [ show 0 < Ca * x ^ Na by positivity, show 0 < x ^ Nb * Cb by positivity, show 0 < x * x ^ Na * x ^ Nb by positivity, show 0 < x * x ^ Na * x ^ Nb * Cb by positivity, show x ^ Na ≥ 1 by exact one_le_pow₀ hx, show x ^ Nb ≥ 1 by exact one_le_pow₀ hx, mul_le_mul_of_nonneg_left hx ( show 0 ≤ Ca * x ^ Na by positivity ), mul_le_mul_of_nonneg_left hx ( show 0 ≤ x ^ Nb * Cb by positivity ) ]

/-! ## iterExp at next level escapes poly-tower bounds -/

theorem iterExp_poly_lt_iterExp_succ (D : ℕ) (C : ℝ) (N : ℕ) :
    ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      iterExp D (C * x ^ N) < iterExp (D + 1) x := by
  -- By induction on $D$, we can show that for any $D$, there exists an $X₀$ such that for all $x ≥ X₀$, $iterExp D (C * x^N) < iterExp (D + 1) x$.
  induction' D with D ih generalizing C N;
  · -- For the base case $D = 0$, we need to show that $C * x^N < \exp(x)$ for sufficiently large $x$.
    have h_base : ∃ X₀, ∀ x ≥ X₀, C * x ^ N < Real.exp x := by
      have h_base : Filter.Tendsto (fun x : ℝ => C * x ^ N / Real.exp x) Filter.atTop (nhds 0) := by
        simpa [ Real.exp_neg, mul_div_assoc ] using tendsto_const_nhds.mul ( Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero N );
      exact Filter.eventually_atTop.mp ( h_base.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ X₀, hX₀ ⟩ ↦ ⟨ X₀, fun x hx ↦ by have := hX₀ x hx; rw [ div_lt_one ( Real.exp_pos x ) ] at this; linarith ⟩;
    exact h_base;
  · obtain ⟨ X₀, hX₀ ⟩ := ih C N;
    exact ⟨ Max.max X₀ 1, fun x hx => by simpa using Real.exp_lt_exp.mpr ( hX₀ x ( le_trans ( le_max_left _ _ ) hx ) ) ⟩

/-! ## KEY NEW LEMMA: Controlled inverse preserves poly-tower majorant -/

/-
If |eval e x| ≥ δ > 0 for all x > 0, then |(eval e x)⁻¹| ≤ 1/δ.
-/
theorem inv_eval_bounded_of_lower_bound (e : EMLExpr) (δ : ℝ) (hδ : 0 < δ)
    (h_lower : ∀ x > (0 : ℝ), |e.eval x| ≥ δ) :
    ∀ x > (0 : ℝ), |(e.eval x)⁻¹| ≤ 1/δ := by
  exact fun x hx => by rw [ abs_inv, one_div ] ; exact inv_anti₀ hδ ( h_lower x hx ) ;

/-
Lifting a poly-tower majorant from height k₁ to any height k₂ ≥ k₁.
-/
theorem hasPTM_mono {k₁ k₂ : ℕ} (hle : k₁ ≤ k₂) {e : EMLExpr}
    (h : HasPolyTowerMajorant k₁ e) : HasPolyTowerMajorant k₂ e := by
  obtain ⟨ C, hC₀, N, X₀, hC ⟩ := h;
  refine' ⟨ C, hC₀, N, Max.max X₀ 1, fun x hx => le_trans ( hC x ( le_trans ( le_max_left _ _ ) hx ) ) _ ⟩;
  exact iterExp_level_mono hle ( mul_pos hC₀ ( pow_pos ( by linarith [ le_max_right X₀ 1 ] ) _ ) )

/-! ## Helper lemmas for individual EMLExpr cases -/

private theorem hasPTM_var : HasPolyTowerMajorant EMLExpr.var.emlDepth EMLExpr.var := by
  use 1, by norm_num, 1, 1;
  erw [ show EMLExpr.var.emlDepth = 0 from rfl ] ; norm_num [ EMLExpr.eval ];
  exact fun x hx => by rw [ abs_of_nonneg ( by positivity ) ] ;

private theorem hasPTM_const (c : ℝ) :
    HasPolyTowerMajorant (EMLExpr.const c).emlDepth (EMLExpr.const c) := by
  refine' ⟨ |c| + 1, by positivity, 0, 1, fun x hx => _ ⟩;
  norm_num [ EMLExpr.eval, EMLExpr.emlDepth ]

private theorem hasPTM_neg {a : EMLExpr} (ha : HasPolyTowerMajorant a.emlDepth a) :
    HasPolyTowerMajorant (EMLExpr.neg a).emlDepth (EMLExpr.neg a) := by
  obtain ⟨ C, hC, N, X₀, h ⟩ := ha;
  exact ⟨ C, hC, N, X₀, fun x hx => by simpa [ EMLExpr.eval ] using h x hx ⟩

private theorem hasPTM_add {a b : EMLExpr}
    (ha : HasPolyTowerMajorant a.emlDepth a) (hb : HasPolyTowerMajorant b.emlDepth b) :
    HasPolyTowerMajorant (EMLExpr.add a b).emlDepth (EMLExpr.add a b) := by
  -- By hasPTM_mono, lift ha to level max a.emlDepth b.emlDepth and hb similarly.
  obtain ⟨Ca, hCa_pos, Na, X₀a, hCa⟩ := ha
  obtain ⟨Cb, hCb_pos, Nb, X₀b, hCb⟩ := hb
  have ha_lift : HasPolyTowerMajorant (max a.emlDepth b.emlDepth) a := by
    exact hasPTM_mono ( le_max_left _ _ ) ⟨ Ca, hCa_pos, Na, X₀a, fun x hx => hCa x hx ⟩
  have hb_lift : HasPolyTowerMajorant (max a.emlDepth b.emlDepth) b := by
    exact hasPTM_mono ( le_max_right _ _ ) ⟨ Cb, hCb_pos, Nb, X₀b, hCb ⟩;
  obtain ⟨ Ca', hCa'_pos, Na', X₀a', hCa' ⟩ := ha_lift
  obtain ⟨ Cb', hCb'_pos, Nb', X₀b', hCb' ⟩ := hb_lift;
  -- Apply the lemma iterExp_sum_poly_bound to combine the bounds for a and b.
  obtain ⟨C, hC_pos, N, X₀, hC⟩ : ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
    iterExp (max a.emlDepth b.emlDepth) (Ca' * x ^ Na') + iterExp (max a.emlDepth b.emlDepth) (Cb' * x ^ Nb') ≤ iterExp (max a.emlDepth b.emlDepth) (C * x ^ N) := by
      by_cases h_max : max a.emlDepth b.emlDepth = 0;
      · use Ca' + Cb', by positivity, max Na' Nb', 1; intros x hx; simp [h_max];
        rw [ add_mul ] ; gcongr <;> cases max_cases Na' Nb' <;> nlinarith [ pow_le_pow_right₀ hx ( show Na' ≤ max Na' Nb' by linarith ), pow_le_pow_right₀ hx ( show Nb' ≤ max Na' Nb' by linarith ) ] ;
      · exact iterExp_sum_poly_bound _ ( Nat.pos_of_ne_zero h_max ) _ _ hCa'_pos hCb'_pos _ _;
  use C, hC_pos, N, Max.max X₀ ( Max.max X₀a' X₀b' );
  intro x hx; specialize hC x ( le_trans ( le_max_left _ _ ) hx ) ; specialize hCa' x ( le_trans ( le_max_of_le_right ( le_max_left _ _ ) ) hx ) ; specialize hCb' x ( le_trans ( le_max_of_le_right ( le_max_right _ _ ) ) hx ) ; simp_all +decide [ abs_le ] ;
  constructor <;> linarith! [ show ( a.add b ).eval x = a.eval x + b.eval x from rfl ]

private theorem hasPTM_mul {a b : EMLExpr}
    (ha : HasPolyTowerMajorant a.emlDepth a) (hb : HasPolyTowerMajorant b.emlDepth b) :
    HasPolyTowerMajorant (EMLExpr.mul a b).emlDepth (EMLExpr.mul a b) := by
  -- Let's obtain the majorants for `a` and `b` at the maximum level.
  obtain ⟨Ca, hCa_pos, Na, X₀a, haMajor⟩ : ∃ Ca : ℝ, 0 < Ca ∧ ∃ Na : ℕ, ∃ X₀a : ℝ, ∀ x : ℝ, x ≥ X₀a → |a.eval x| ≤ iterExp (max a.emlDepth b.emlDepth) (Ca * x ^ Na) := by
    exact hasPTM_mono ( Nat.le_max_left _ _ ) ha;
  obtain ⟨Cb, hCb_pos, Nb, X₀b, hbMajor⟩ : ∃ Cb : ℝ, 0 < Cb ∧ ∃ Nb : ℕ, ∃ X₀b : ℝ, ∀ x : ℝ, x ≥ X₀b → |b.eval x| ≤ iterExp (max a.emlDepth b.emlDepth) (Cb * x ^ Nb) := by
    exact hasPTM_mono ( Nat.le_max_right _ _ ) hb;
  by_cases hmax : max a.emlDepth b.emlDepth = 0;
  · simp_all +decide [ EMLExpr.emlDepth ];
    use Ca * Cb, mul_pos hCa_pos hCb_pos, Na + Nb, max X₀a X₀b;
    intro x hx; convert mul_le_mul ( haMajor x ( le_trans ( le_max_left _ _ ) hx ) ) ( hbMajor x ( le_trans ( le_max_right _ _ ) hx ) ) ( by positivity ) ( by exact le_trans ( by positivity ) ( haMajor x ( le_trans ( le_max_left _ _ ) hx ) ) ) using 1 ; ring;
    · exact abs_mul _ _;
    · simp +decide [ iterExp, pow_add, mul_assoc, mul_comm, mul_left_comm ];
  · -- Use the lemma `iterExp_mul_poly_bound` to combine the majorants.
    obtain ⟨C, hC_pos, N, X₀, hMajor⟩ : ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → iterExp (max a.emlDepth b.emlDepth) (Ca * x ^ Na) * iterExp (max a.emlDepth b.emlDepth) (Cb * x ^ Nb) ≤ iterExp (max a.emlDepth b.emlDepth) (C * x ^ N) := by
      exact iterExp_mul_poly_bound _ ( Nat.pos_of_ne_zero hmax ) _ _ hCa_pos hCb_pos _ _;
    use C, hC_pos, N, Max.max X₀ ( Max.max X₀a X₀b );
    simp_all +decide [ EMLExpr.eval ];
    exact fun x hx₁ hx₂ hx₃ => le_trans ( mul_le_mul ( haMajor x hx₂ ) ( hbMajor x hx₃ ) ( by positivity ) ( by exact le_trans ( by positivity ) ( haMajor x hx₂ ) ) ) ( hMajor x hx₁ )

/-
**The key new case**: controlled inverse preserves poly-tower majorant.
    Since |inv(e)| ≤ 1/δ (a constant), it has a majorant at height 0,
    hence at any height including e.emlDepth = (inv e).emlDepth.
-/
private theorem hasPTM_inv {a : EMLExpr}
    (ha : HasPolyTowerMajorant a.emlDepth a)
    (h_ctrl : ∃ δ > 0, ∀ x > (0 : ℝ), |a.eval x| ≥ δ) :
    HasPolyTowerMajorant (EMLExpr.inv a).emlDepth (EMLExpr.inv a) := by
  -- By inv_eval_bounded_of_lower_bound, |(a.eval x)⁻¹| ≤ 1/δ for all x > 0.
  obtain ⟨δ, hδ_pos, hδ⟩ := h_ctrl
  have h_inv_bounded : ∀ x > 0, |(a.eval x)⁻¹| ≤ 1 / δ := by
    exact fun x hx => by rw [ abs_inv ] ; simpa using inv_anti₀ hδ_pos ( hδ x hx ) ;
  -- So HasPolyTowerMajorant 0 (inv a): take C = 1/δ + 1, N = 0, X₀ = 1.
  use 1 / δ + 1, by
    positivity, 0, 1;
  intro x hx
  have h_eval_inv : |a.inv.eval x| ≤ 1 / δ := by
    convert h_inv_bounded x ( by linarith ) using 1
  have h_iterExp : 1 / δ ≤ iterExp a.inv.emlDepth ((1 / δ + 1) * x ^ 0) := by
    exact le_trans ( by norm_num ) ( iterExp_ge_self _ ( by positivity ) )
  exact le_trans h_eval_inv h_iterExp

private theorem hasPTM_eml {a b : EMLExpr}
    (ha : HasPolyTowerMajorant a.emlDepth a) (hb : HasPolyTowerMajorant b.emlDepth b) :
    HasPolyTowerMajorant (EMLExpr.eml a b).emlDepth (EMLExpr.eml a b) := by
  -- By hasPTM_mono, lift ha and hb to level max a.emlDepth b.emlDepth.
  have ha' : HasPolyTowerMajorant (max a.emlDepth b.emlDepth) a := by
    exact hasPTM_mono ( le_max_left _ _ ) ha
  have hb' : HasPolyTowerMajorant (max a.emlDepth b.emlDepth) b := by
    exact hasPTM_mono ( le_max_right _ _ ) hb;
  obtain ⟨ Ca, hCa_pos, Na, Xa₀, ha_bound ⟩ := ha'
  obtain ⟨ Cb, hCb_pos, Nb, Xb₀, hb_bound ⟩ := hb';
  -- By iterExp_prod_to_next_level, there exist C, N, X₀ such that for all x ≥ X₀, iterExp k (Ca * x^Na) * exp(iterExp k (Cb * x^Nb)) ≤ iterExp (k + 1) (C * x^N).
  obtain ⟨ C, hC_pos, N, X₀, h_prod_bound ⟩ := iterExp_prod_to_next_level (max a.emlDepth b.emlDepth) Ca Cb hCa_pos hCb_pos Na Nb;
  refine' ⟨ C, hC_pos, N, Max.max ( Max.max Xa₀ Xb₀ ) X₀, fun x hx => _ ⟩;
  simp_all +decide [ EMLExpr.eval, EMLExpr.emlDepth ];
  refine' le_trans ( mul_le_mul_of_nonneg_right ( ha_bound x hx.1.1 ) ( Real.exp_nonneg _ ) ) _;
  refine' le_trans ( mul_le_mul_of_nonneg_left ( Real.exp_le_exp.mpr ( le_trans ( le_abs_self _ ) ( hb_bound x hx.1.2 ) ) ) ( by exact le_trans ( abs_nonneg _ ) ( ha_bound x hx.1.1 ) ) ) _;
  convert h_prod_bound x hx.2 using 1 ; norm_num [ add_comm, iterExp ]

/-! ## Main structural theorem -/

/-- **Main structural theorem (extended)**: For any EMLExpr `e` with controlled inverses,
    `HasPolyTowerMajorant (emlDepth e) e`. -/
theorem controlledInv_hasPolyTowerMajorant (e : EMLExpr) (hCtrl : HasControlledInverses e) :
    HasPolyTowerMajorant e.emlDepth e := by
  induction e with
  | var => exact hasPTM_var
  | const c => exact hasPTM_const c
  | neg a ih => exact hasPTM_neg (ih hCtrl)
  | add a b iha ihb =>
    simp [HasControlledInverses] at hCtrl
    exact hasPTM_add (iha hCtrl.1) (ihb hCtrl.2)
  | mul a b iha ihb =>
    simp [HasControlledInverses] at hCtrl
    exact hasPTM_mul (iha hCtrl.1) (ihb hCtrl.2)
  | inv a ih =>
    simp [HasControlledInverses] at hCtrl
    exact hasPTM_inv (ih hCtrl.2) hCtrl.1
  | eml a b iha ihb =>
    simp [HasControlledInverses] at hCtrl
    exact hasPTM_eml (iha hCtrl.1) (ihb hCtrl.2)

/-! ## Majorized implies dominated by next iterExp level -/

theorem controlledInv_depth_majorized (D : ℕ)
    (e : EMLExpr) (hCtrl : HasControlledInverses e) (hDepth : e.emlDepth ≤ D) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      |e.eval x| ≤ iterExp D (C * x ^ N) := by
  exact hasPTM_mono hDepth (controlledInv_hasPolyTowerMajorant e hCtrl)

/-! ## THE MAIN RESULTS -/

/-
**Theorem (Controlled-Inverse Depth Hierarchy)**: No EMLExpr with controlled inverses
    of depth ≤ D can represent `iterExp n` for any `n > D`.
-/
theorem no_controlledInv_lowDepth_represents_iterExp
    (D n : ℕ) (hnd : D < n) :
    ¬ ∃ e : EMLExpr,
        HasControlledInverses e ∧ e.emlDepth ≤ D ∧ RepresentsOnPos e (iterExp n) := by
  intro ⟨ e, he₁, he₂, he₃ ⟩
  obtain ⟨C, hC_pos, N, X₀, h_bound⟩ := controlledInv_depth_majorized D e he₁ he₂
  obtain ⟨X₁, hX₁⟩ := iterExp_poly_lt_iterExp_succ D C N
  obtain ⟨X₂, hX₂⟩ : ∃ X₂ : ℝ, ∀ x : ℝ, x ≥ X₂ → iterExp (D + 1) x ≤ iterExp n x := by
    exact ⟨ 1, fun x hx => iterExp_level_mono ( by linarith ) ( by linarith ) ⟩
  -- Choose $x₀ = \max(\max(X₀, X₁), X₂, 1)$.
  set x₀ := max (max (max X₀ X₁) X₂) 1 with hx₀_def;
  -- By RepresentsOnPos, we have e.eval x₀ = iterExp n x₀.
  have h_eval : e.eval x₀ = iterExp n x₀ := by
    exact he₃ x₀ ( by positivity );
  grind

/-- **Corollary**: The controlled-inverse hierarchy for the iterExp family. -/
theorem controlledInv_depth_hierarchy
    {m n : ℕ} (h : m < n) :
    ¬ ∃ e : EMLExpr,
        HasControlledInverses e ∧ e.emlDepth ≤ m ∧ RepresentsOnPos e (iterExp n) :=
  no_controlledInv_lowDepth_represents_iterExp m n h

/-
**Corollary**: Controlled-inverse expressions are eventually dominated by iterExp(D+1, x).
-/
theorem controlledInv_eventually_dominated (D : ℕ) (e : EMLExpr)
    (hCtrl : HasControlledInverses e) (hDepth : e.emlDepth ≤ D) :
    ∃ N : ℝ, ∀ x > N, e.eval x < iterExp (D + 1) x := by
  -- By controlledInv_depth_majorized, there exists a constant C > 0 and a natural number N such that for all x ≥ N, |e.eval x| ≤ iterExp D (C * x^N).
  obtain ⟨C, hC_pos, N, hN⟩ : ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → |e.eval x| ≤ iterExp D (C * x ^ N) := by
    exact?;
  obtain ⟨ X₀, hX₀ ⟩ := hN;
  obtain ⟨ X₁, hX₁ ⟩ := iterExp_poly_lt_iterExp_succ D C N;
  exact ⟨ Max.max X₀ X₁, fun x hx => lt_of_le_of_lt ( le_of_abs_le ( hX₀ x ( le_of_lt ( lt_of_le_of_lt ( le_max_left _ _ ) hx ) ) ) ) ( hX₁ x ( le_of_lt ( lt_of_le_of_lt ( le_max_right _ _ ) hx ) ) ) ⟩

/-! ## Secondary Theorem: Spectral Margin and Condition Number -/

/-- **Spectral Margin Condition Number Theorem**: For any EMLExpr `e` with controlled
    inverses whose evaluation is bounded away from zero by δ > 0, the inverse
    evaluation is bounded by 1/δ while the forward evaluation has a poly-tower bound. -/
theorem spectral_margin_condition_number (e : EMLExpr) (δ : ℝ)
    (h_pos : δ > 0)
    (h_lower : ∀ x > (0 : ℝ), |e.eval x| ≥ δ)
    (hCtrl : HasControlledInverses e) :
    (∀ x > (0 : ℝ), |(e.eval x)⁻¹| ≤ 1/δ) ∧
    (∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      |e.eval x| ≤ iterExp e.emlDepth (C * x ^ N)) := by
  exact ⟨inv_eval_bounded_of_lower_bound e δ h_pos h_lower,
         controlledInv_hasPolyTowerMajorant e hCtrl⟩

end