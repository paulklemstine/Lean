import Mathlib
import Speculative.HardyHierarchy.Theorems

/-!
# Strict Hierarchy Separation for the Hardy Hierarchy

This file establishes that the Hardy hierarchy is **strict at every finite level**:
the iterated exponential `iterExp (n+1)` belongs to Hardy level `n+1` but does NOT
belong to level `n`. This is the fundamental separation theorem.

## Main Results

1. **`hardyLevel_exp_growth_bound`**: Every level-`n` function satisfies
   `|f x| ≤ exp(C * iterExp n x)` eventually, for any `C > 0`.

2. **`hardyLevel_n_bounded_by_iterExp_succ'`**: Every level-`n` function satisfies
   `|f x| ≤ C * iterExp (n+1) x` eventually.

3. **`iterExp_succ_not_hardyLevel`**: `iterExp (n+1)` does NOT belong to Hardy level `n`.

4. **`iterExp_not_mem_lower_hardyLevel`**: For `n ≥ 1`, `iterExp n ∉ HardyLevel (n-1)`.

5. **`iterExp_hasHardyRank`**: `iterExp n` has exact Hardy rank `n`.

## Proof Architecture

The core bound `|f x| ≤ exp(C * iterExp n x)` for any `C > 0` is closed under
all constructors of `HardyLevel`. Separation follows because
`exp(iterExp n x) ≤ exp((1/2) * iterExp n x)` implies `iterExp n x ≤ (1/2) * iterExp n x`,
which is absurd for positive values.
-/

noncomputable section

open Real Filter Topology

/-! ## New Definitions -/

/-- `f` is eventually strictly less than `g`. -/
def EventuallyStrictlySmaller (f g : ℝ → ℝ) : Prop :=
  ∃ N : ℝ, ∀ x ≥ N, f x < g x

/-- Packages exact Hardy rank membership: `f` is at level `n` but no lower. -/
structure HardyRankWitness (n : ℕ) (f : ℝ → ℝ) : Prop where
  mem_level : HardyLevel n f
  not_mem_lower : n = 0 ∨ ¬ HardyLevel (n - 1) f

/-- Asymptotic representability within a level. -/
def IsLevelMajorizedBy (n : ℕ) (f : ℝ → ℝ) : Prop :=
  ∃ g, HardyLevel n g ∧ ∃ C N : ℝ, ∀ x ≥ N, |f x| ≤ C * |g x|

/-! ## Auxiliary Lemmas -/

/-- `iterExp n` tends to infinity. -/
theorem iterExp_tendsto_atTop (n : ℕ) :
    Tendsto (iterExp n) atTop atTop := by
  induction' n with n ih
  · exact Filter.tendsto_id
  · exact Real.tendsto_exp_atTop.comp ih

/-- For any constants `C₁` and `C₂ < 1`, eventually
    `C₁ * t + exp(C₂ * t) ≤ exp(t)`. -/
theorem exp_sub_linear_bound (C₁ C₂ : ℝ) (hC₂ : C₂ < 1) :
    ∃ N : ℝ, ∀ t ≥ N, C₁ * t + Real.exp (C₂ * t) ≤ Real.exp t := by
  obtain ⟨N₁, hN₁⟩ : ∃ N₁ : ℝ, ∀ t ≥ N₁, C₁ * t ≤ (1 / 2) * Real.exp t := by
    have h_exp_growth : Tendsto (fun t : ℝ => C₁ * t / Real.exp t) atTop (nhds 0) := by
      simpa [Real.exp_neg, mul_div_assoc] using
        tendsto_const_nhds.mul (Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero 1)
    exact Filter.eventually_atTop.mp
      (h_exp_growth.eventually (gt_mem_nhds (show 0 < 1 / 2 by norm_num))) |>
      fun ⟨N₁, hN₁⟩ ↦ ⟨N₁, fun t ht ↦ by
        have := hN₁ t ht; rw [div_lt_iff₀ (Real.exp_pos _)] at this; linarith⟩
  obtain ⟨N₂, hN₂⟩ : ∃ N₂ : ℝ, ∀ t ≥ N₂, Real.exp (C₂ * t) ≤ (1 / 2) * Real.exp t := by
    obtain ⟨N₂, hN₂⟩ : ∃ N₂ : ℝ, ∀ t ≥ N₂, (C₂ - 1) * t ≤ Real.log (1 / 2) :=
      ⟨Real.log (1 / 2) / (C₂ - 1), fun t ht => by
        nlinarith [mul_div_cancel₀ (Real.log (1 / 2)) (by linarith : (C₂ - 1) ≠ 0)]⟩
    exact ⟨N₂, fun t ht => by
      rw [← Real.log_le_log_iff (by positivity) (by positivity),
        Real.log_mul (by positivity) (by positivity), Real.log_exp, Real.log_exp]
      linarith [hN₂ t ht]⟩
  exact ⟨max N₁ N₂, fun t ht => by
    linarith [hN₁ t (le_of_max_le_left ht), hN₂ t (le_of_max_le_right ht)]⟩

/-
Pulling back an eventual bound through `iterExp n`:
    if `∀ t ≥ N, P t` and `iterExp n → ∞`, then `∀ x ≥ M, P (iterExp n x)`.
-/
theorem eventually_iterExp_pullback (n : ℕ) (P : ℝ → Prop) (N : ℝ)
    (hP : ∀ t ≥ N, P t) :
    ∃ M : ℝ, ∀ x ≥ M, P (iterExp n x) := by
  exact Filter.eventually_atTop.mp ( iterExp_tendsto_atTop n |> fun h => h.eventually_ge_atTop N ) |> fun ⟨ M, hM ⟩ => ⟨ M, fun x hx => hP _ ( hM x hx ) ⟩ ;

/-
For D < 1 and C > 0: eventually `D * iterExp n x + exp(D * iterExp n x) ≤ C * exp(iterExp n x)`.
-/
theorem exp_step_bound_pulled_back (n : ℕ) (D C : ℝ) (hD : D < 1) (hC : 0 < C) :
    ∃ M : ℝ, ∀ x ≥ M,
      D * iterExp n x + Real.exp (D * iterExp n x) ≤ C * Real.exp (iterExp n x) := by
  -- By the properties of exponential functions and their growth rates, we know that for sufficiently large $t$, $D * t$ and $\exp(D * t)$ will be dominated by $C * \exp(t)$.
  have h_dominate : ∃ N : ℝ, ∀ t ≥ N, D * t + Real.exp (D * t) ≤ C * Real.exp t := by
    -- We'll use the fact that $D * t + \exp(D * t) \leq C * \exp(t)$ if and only if $D * t / \exp(t) + \exp(D * t) / \exp(t) \leq C$.
    suffices h_suff : ∃ N : ℝ, ∀ t ≥ N, D * t / Real.exp t + Real.exp ((D - 1) * t) ≤ C by
      simp_all +decide [ Real.exp_add, sub_mul ];
      obtain ⟨ N, hN ⟩ := h_suff; use N; intro t ht; have := hN t ht; rw [ div_add', div_le_iff₀ ] at this <;> first | positivity | simp_all +decide [ Real.exp_sub, Real.exp_mul ] ;
    -- We'll use the fact that $D * t / \exp(t)$ and $\exp((D - 1) * t)$ tend to $0$ as $t$ tends to infinity.
    have h_lim : Filter.Tendsto (fun t : ℝ => D * t / Real.exp t) Filter.atTop (nhds 0) ∧ Filter.Tendsto (fun t : ℝ => Real.exp ((D - 1) * t)) Filter.atTop (nhds 0) := by
      constructor;
      · simpa [ Real.exp_neg, mul_div_assoc ] using tendsto_const_nhds.mul ( Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero 1 );
      · norm_num +zetaDelta at *;
        exact Filter.tendsto_id.const_mul_atTop_of_neg ( by linarith );
    simpa using h_lim.1.add h_lim.2 |> fun h => h.eventually ( ge_mem_nhds <| by linarith );
  exact eventually_iterExp_pullback n _ h_dominate.choose h_dominate.choose_spec

/-! ## Core Growth Bound -/

/-
**Core Growth Bound**: Every function at Hardy level `n` satisfies
    `|f x| ≤ exp(C * iterExp n x)` eventually, for ANY `C > 0`.

    Proved by structural induction on `HardyLevel`.
-/
theorem hardyLevel_exp_growth_bound {n : ℕ} {f : ℝ → ℝ}
    (hf : HardyLevel n f) (C : ℝ) (hC : 0 < C) :
    ∃ N : ℝ, ∀ x ≥ N, |f x| ≤ Real.exp (C * iterExp n x) := by
  induction' hf with n f g hf hg ihf ihg generalizing C;
  all_goals norm_num [ iterExp ];
  -- For the base case, we can use the fact that $|x| \leq \exp(Cx)$ for sufficiently large $x$.
  have h_base : ∃ N : ℝ, ∀ x ≥ N, |x| ≤ Real.exp (C * x) := by
    have h_exp_growth : Filter.Tendsto (fun x => Real.exp (C * x) / x) Filter.atTop Filter.atTop := by
      have := Real.tendsto_exp_div_pow_atTop 1;
      have := this.comp ( Filter.tendsto_id.const_mul_atTop hC );
      convert this.const_mul_atTop hC using 2 ; norm_num ; ring;
      norm_num [ mul_assoc, mul_comm C, hC.ne' ]
    exact Filter.eventually_atTop.mp ( h_exp_growth.eventually_ge_atTop 1 ) |> fun ⟨ N, hN ⟩ ↦ ⟨ Max.max N 1, fun x hx ↦ by have := hN x ( le_trans ( le_max_left _ _ ) hx ) ; rw [ le_div_iff₀ ( by linarith [ le_max_right N 1 ] ) ] at this; linarith [ le_max_right N 1, abs_of_nonneg ( by linarith [ le_max_right N 1 ] : 0 ≤ x ) ] ⟩;
  exact h_base;
  · exact ⟨ |n| / C, fun x hx => by rw [ div_le_iff₀ hC ] at hx; linarith [ Real.add_one_le_exp ( C * x ), abs_nonneg n ] ⟩;
  · -- By the induction hypothesis, we have |g x| ≤ exp(C/2 * iterExp f x) and |hf x| ≤ exp(C/2 * iterExp f x) for sufficiently large x.
    obtain ⟨N₁, hN₁⟩ : ∃ N₁ : ℝ, ∀ x ≥ N₁, |g x| ≤ Real.exp (C / 2 * iterExp f x) := by
      exact ihg _ ( half_pos hC )
    obtain ⟨N₂, hN₂⟩ : ∃ N₂ : ℝ, ∀ x ≥ N₂, |hf x| ≤ Real.exp (C / 2 * iterExp f x) := by
      exact ‹∀ C : ℝ, 0 < C → ∃ N, ∀ x ≥ N, |hf x| ≤ Real.exp ( C * iterExp f x ) › ( C / 2 ) ( half_pos hC );
    -- Choose $N$ such that for all $x \geq N$, $C/2 * iterExp f x \geq \log 2$.
    obtain ⟨N₃, hN₃⟩ : ∃ N₃ : ℝ, ∀ x ≥ N₃, C / 2 * iterExp f x ≥ Real.log 2 := by
      have h_exp_growth : Filter.Tendsto (fun x => C / 2 * iterExp f x) Filter.atTop Filter.atTop := by
        exact Filter.Tendsto.const_mul_atTop ( by positivity ) ( iterExp_tendsto_atTop f );
      exact Filter.eventually_atTop.mp ( h_exp_growth.eventually_ge_atTop ( Real.log 2 ) );
    refine' ⟨ Max.max N₁ ( Max.max N₂ N₃ ), fun x hx => _ ⟩ ; simp_all +decide [ abs_le ];
    have := hN₃ x hx.2.2; rw [ show C * iterExp f x = C / 2 * iterExp f x + C / 2 * iterExp f x by ring ] ; rw [ Real.exp_add ] ; constructor <;> nlinarith [ hN₁ x hx.1, hN₂ x hx.2.1, Real.add_one_le_exp ( C / 2 * iterExp f x ), Real.log_le_iff_le_exp ( by positivity ) |>.1 this ] ;
  · rename_i k hk₁ hk₂ hk₃ hk₄;
    obtain ⟨ N₁, hN₁ ⟩ := hk₃ ( C / 2 ) ( half_pos hC ) ; obtain ⟨ N₂, hN₂ ⟩ := hk₄ ( C / 2 ) ( half_pos hC ) ; use Max.max N₁ N₂; intro x hx; rw [ show C * iterExp _ x = ( C / 2 ) * iterExp _ x + ( C / 2 ) * iterExp _ x by ring ] ; rw [ Real.exp_add ] ; exact mul_le_mul ( hN₁ x ( le_trans ( le_max_left _ _ ) hx ) ) ( hN₂ x ( le_trans ( le_max_right _ _ ) hx ) ) ( by positivity ) ( by positivity ) ;
  · rename_i k f g hf hg ihf ihg;
    -- Choose $D = \min(C, 1) / 4 > 0$, $D < 1$.
    set D := min C 1 / 4 with hD_pos
    have hD_lt_1 : D < 1 := by
      grind;
    obtain ⟨ N₁, hN₁ ⟩ := ihf D ( by positivity ) ; obtain ⟨ N₂, hN₂ ⟩ := ihg D ( by positivity ) ; obtain ⟨ N₃, hN₃ ⟩ := exp_step_bound_pulled_back k D C hD_lt_1 hC; use Max.max N₁ ( Max.max N₂ N₃ ) ; intros x hx; specialize hN₁ x ( le_trans ( le_max_left _ _ ) hx ) ; specialize hN₂ x ( le_trans ( le_max_of_le_right ( le_max_left _ _ ) ) hx ) ; specialize hN₃ x ( le_trans ( le_max_of_le_right ( le_max_right _ _ ) ) hx ) ; simp_all +decide [ abs_mul, Real.exp_add ] ;
    refine' le_trans ( mul_le_mul_of_nonneg_right hN₁ ( Real.exp_nonneg _ ) ) _;
    rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( by linarith [ abs_le.mp hN₂ ] ) ;
  · rename_i k hk₁ hk₂ hk₃;
    obtain ⟨ N, hN ⟩ := hk₃ C hC;
    obtain ⟨ M, hM ⟩ := hk₂;
    exact ⟨ Max.max N M, fun x hx => by simpa only [ hM x ( le_trans ( le_max_right _ _ ) hx ) ] using hN x ( le_trans ( le_max_left _ _ ) hx ) ⟩

/-! ## Consequences of the Growth Bound -/

/-- **Corollary**: Every level-`n` function is eventually bounded by `iterExp (n+1)`. -/
theorem hardyLevel_n_bounded_by_iterExp_succ' (n : ℕ) (f : ℝ → ℝ)
    (hf : HardyLevel n f) :
    ∃ A C : ℝ, ∀ x ≥ A, |f x| ≤ C * iterExp (n + 1) x := by
  obtain ⟨N, hN⟩ := hardyLevel_exp_growth_bound hf 1 one_pos
  exact ⟨N, 1, fun x hx => by
    have := hN x hx
    simp only [one_mul] at this ⊢
    calc |f x| ≤ Real.exp (iterExp n x) := this
    _ = iterExp (n + 1) x := by simp [iterExp]⟩

/-! ## Strict Separation -/

/-
**Strict Separation Theorem**: `iterExp (n+1)` does NOT belong to Hardy level `n`.
-/
theorem iterExp_succ_not_hardyLevel (n : ℕ) :
    ¬ HardyLevel n (iterExp (n + 1)) := by
  intro h
  obtain ⟨N, hN⟩ : ∃ N : ℝ, ∀ x ≥ N, |iterExp (n + 1) x| ≤ Real.exp (1 / 2 * iterExp n x) := by
    convert hardyLevel_exp_growth_bound h ( 1 / 2 ) ( by norm_num ) using 1;
  -- Since `iterExp (n+1) x = exp(iterExp n x) > 0`, we have `|iterExp (n+1) x| = iterExp (n+1) x = exp(iterExp n x)`.
  have h_pos : ∀ x ≥ N, iterExp (n + 1) x = Real.exp (iterExp n x) := by
    exact?;
  -- By `iterExp_tendsto_atTop`, there exists `M` such that for all `x ≥ M`, `iterExp n x ≥ 1`.
  obtain ⟨M, hM⟩ : ∃ M : ℝ, ∀ x ≥ M, iterExp n x ≥ 1 := by
    exact Filter.eventually_atTop.mp ( iterExp_tendsto_atTop n |> fun h => h.eventually_ge_atTop 1 );
  exact absurd ( hN ( Max.max N M ) ( le_max_left _ _ ) ) ( by rw [ h_pos _ ( le_max_left _ _ ) ] ; rw [ abs_of_nonneg ( Real.exp_nonneg _ ) ] ; exact not_le_of_gt ( Real.exp_lt_exp.mpr ( by linarith [ hM ( Max.max N M ) ( le_max_right N M ) ] ) ) )

/-- For `n ≥ 1`, `iterExp n ∉ HardyLevel (n-1)`. -/
theorem iterExp_not_mem_lower_hardyLevel (n : ℕ) (hn : 1 ≤ n) :
    ¬ HardyLevel (n - 1) (iterExp n) := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  exact iterExp_succ_not_hardyLevel m

/-- The iterated exponentials form a strictly increasing chain. -/
theorem iterExp_strict_chain (m n : ℕ) (hmn : m < n) :
    ¬ HardyLevel m (iterExp n) := by
  intro h
  have : HardyLevel (n - 1) (iterExp n) := hardyLevel_mono (by omega) h
  exact iterExp_not_mem_lower_hardyLevel n (by omega) this

/-! ## Exact Hardy Rank -/

/-- `iterExp n` has exact Hardy rank `n`. -/
theorem iterExp_hasHardyRank (n : ℕ) : HasHardyRank (iterExp n) n := by
  constructor
  · exact iterExp_mem_hardyLevel n
  · intro e he; exact iterExp_strict_chain e n he

/-- `iterExp n` is a Hardy rank witness at level `n`. -/
theorem iterExp_hardyRankWitness (n : ℕ) : HardyRankWitness n (iterExp n) where
  mem_level := iterExp_mem_hardyLevel n
  not_mem_lower := by
    rcases n with _ | n
    · left; rfl
    · right; exact iterExp_not_mem_lower_hardyLevel (n + 1) (by omega)

/-! ## Cross-Domain: Asymptotic Lower Bound -/

/-
No level-`n` function eventually dominates `iterExp (n+1)`.
-/
theorem no_lower_depth_majorization_of_iterExp (n : ℕ) :
    ¬ ∃ f, HardyLevel n f ∧ EventuallyDominates f (iterExp (n + 1)) := by
  by_contra h_contra
  obtain ⟨f, hf_n, hf_dom⟩ := h_contra
  have h_bound : ∃ N : ℝ, ∀ x ≥ N, |f x| ≤ Real.exp (1 / 2 * iterExp n x) := by
    convert hardyLevel_exp_growth_bound hf_n ( 1 / 2 ) ( by norm_num ) using 1;
  -- By combining the results from hf_dom and h_bound, we obtain a contradiction.
  obtain ⟨N₁, hN₁⟩ := hf_dom
  obtain ⟨N₂, hN₂⟩ := h_bound
  have h_contradiction : ∃ M : ℝ, ∀ x ≥ M, iterExp (n + 1) x ≤ Real.exp (1 / 2 * iterExp n x) := by
    exact ⟨ Max.max N₁ N₂, fun x hx => le_trans ( hN₁ x ( le_trans ( le_max_left _ _ ) hx ) ) ( le_trans ( le_abs_self _ ) ( hN₂ x ( le_trans ( le_max_right _ _ ) hx ) ) ) ⟩;
  obtain ⟨ M, hM ⟩ := h_contradiction
  have h_exp : ∀ x ≥ M, Real.exp (iterExp n x) ≤ Real.exp (1 / 2 * iterExp n x) := by
    exact fun x hx => by simpa [ iterExp ] using hM x hx;
  have h_contra : ∀ x ≥ M, iterExp n x ≤ 1 / 2 * iterExp n x := by
    exact fun x hx => le_of_not_gt fun hx' => not_le_of_gt ( Real.exp_lt_exp.mpr hx' ) ( h_exp x hx )
  have h_final : ∀ x ≥ M, iterExp n x ≤ 0 := by
    exact fun x hx => by linarith [ h_contra x hx ] ;
  have h_final' : ∀ x ≥ M, 0 < iterExp n x := by
    exact fun x hx => iterExp_pos' ( show 0 < x by linarith [ show 0 < M by exact lt_of_not_ge fun h => by have := h_final 1 ( by linarith ) ; linarith [ show 0 < iterExp n 1 from by exact Nat.recOn n ( by norm_num [ iterExp ] ) fun n ihn => by norm_num [ iterExp ] ; positivity ] ] ) ;
  have h_final'' : False := by
    exact not_le_of_gt ( h_final' M le_rfl ) ( h_final M le_rfl )
  exact h_final''

end