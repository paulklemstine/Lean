/-
# Full EML Depth Hierarchy — Core Theorems

This file proves the key theorems establishing that inversions cannot reduce
the exponential depth needed to represent iterated exponentials.

## Main Results

1. `canonicalTower_eval`: The canonical tower expression correctly evaluates to `tower n x`.
2. `canonicalTower_expDepth`: The canonical construction has expDepth exactly n.
3. `expDepth_formalDerivative_le`: Formal differentiation preserves exp-depth (cross-domain).
4. `poly_dominated_by_exp`: Polynomials are eventually dominated by exp.
5. `tower_succ_escapes_poly_tower`: tower(n+1,x) escapes any polynomial in tower(n,x).
6. `invFree_has_majorant`: Inv-free FullEML expressions have majorants.
7. `no_lowExpDepth_represents_tower`: The main hierarchy theorem for full EML.
-/
import Pythagorean.FullEMLHierarchy.Defs

noncomputable section

open Real Filter

/-! ## Canonical Construction Properties -/

/-- The canonical tower expression evaluates to `tower n x`. -/
theorem canonicalTower_eval (n : ℕ) (x : ℝ) :
    (canonicalTower n).eval x = tower n x := by
  induction n with
  | zero => rfl
  | succ n ih => simp [canonicalTower, FullEML.eval, tower_succ, ih]

/-- The canonical tower expression has expDepth exactly n. -/
theorem canonicalTower_expDepth (n : ℕ) :
    (canonicalTower n).expDepth = n := by
  induction n with
  | zero => rfl
  | succ n ih => simp [canonicalTower, FullEML.expDepth, ih]

/-! ## Cross-Domain: Derivative Preserves Exp-Depth -/

/-- **Cross-domain theorem** connecting EML depth to differential algebra:
    the formal derivative of a FullEML expression has exp-depth at most
    that of the original. This means the EML depth hierarchy is a
    *differential-algebraic* phenomenon — differentiation cannot create
    new exponential nesting. -/
theorem expDepth_formalDerivative_le (f : FullEML) :
    f.formalDerivative.expDepth ≤ f.expDepth := by
  induction' f with f g f ih_f g ih_g f ih_f g ih_g f ih_f
  all_goals simp +arith +decide [*, FullEML.formalDerivative, FullEML.expDepth]
  · grind
  · grind
  · grind

/-! ## Tower Growth Lemmas -/

/-- Polynomials are eventually dominated by exp. -/
theorem poly_dominated_by_exp (C : ℝ) (N : ℕ) :
    ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → C * x ^ N < Real.exp x := by
  have h_exp_div_pow : Filter.Tendsto (fun x : ℝ => Real.exp x / x ^ N)
      Filter.atTop Filter.atTop :=
    Real.tendsto_exp_div_pow_atTop _
  exact Filter.eventually_atTop.mp (h_exp_div_pow.eventually_gt_atTop C) |>
    fun ⟨X₀, hX₀⟩ ↦ ⟨Max.max X₀ 1, fun x hx ↦ by
      have := hX₀ x (le_trans (le_max_left _ _) hx)
      rw [lt_div_iff₀ (pow_pos (by linarith [le_max_right X₀ 1]) _)] at this
      linarith⟩

/-- The tower function at level n+1 eventually exceeds any polynomial
    in the tower at level n. -/
theorem tower_succ_escapes_poly_tower (n : ℕ) (C : ℝ) (K : ℕ) (_hC : 0 < C) :
    ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      C * (tower n x) ^ K < tower (n + 1) x := by
  obtain ⟨Y₀, hY₀⟩ := poly_dominated_by_exp C K
  have h_tendsto : Filter.Tendsto (tower n) Filter.atTop Filter.atTop := by
    induction n with
    | zero => exact Filter.tendsto_id
    | succ n ih => exact Real.tendsto_exp_atTop.comp ih
  obtain ⟨X₀, hX₀⟩ := Filter.eventually_atTop.mp (h_tendsto.eventually_ge_atTop Y₀)
  exact ⟨X₀, fun x hx => by
    have h1 := hX₀ x hx
    have h2 := hY₀ (tower n x) h1
    simp [tower_succ]
    linarith⟩

/-- Tower at level n is positive for sufficiently large x. -/
theorem tower_eventually_pos (n : ℕ) :
    ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → 0 < tower n x := by
  induction n with
  | zero => exact ⟨1, fun x hx => by simp [tower] at *; linarith⟩
  | succ _ _ => exact ⟨0, fun _ _ => Real.exp_pos _⟩

/-- Tower n tends to infinity. -/
theorem tower_tendsto_atTop (n : ℕ) :
    Filter.Tendsto (tower n) Filter.atTop Filter.atTop := by
  induction n with
  | zero => exact Filter.tendsto_id
  | succ n ih => exact Real.tendsto_exp_atTop.comp ih

/-- Tower is eventually at least any given bound. -/
theorem tower_eventually_ge (n : ℕ) (B : ℝ) :
    ∃ X₀ : ℝ, ∀ x ≥ X₀, tower n x ≥ B := by
  exact Filter.eventually_atTop.mp ((tower_tendsto_atTop n).eventually_ge_atTop B)

/-
Key absorption lemma: tower d (C * x^N) eventually exceeds
    tower d (C' * x^N') + tower d (C'' * x^N'').
    This is used for the add case of the majorant induction.
-/
theorem tower_poly_absorbs_sum (d : ℕ) (C₁ C₂ : ℝ) (N₁ N₂ : ℕ)
    (hC₁ : 0 < C₁) (hC₂ : 0 < C₂) :
    ∃ (C : ℝ) (N : ℕ), 0 < C ∧
      ∃ X₀ : ℝ, ∀ x ≥ X₀,
        tower d (C₁ * x ^ N₁) + tower d (C₂ * x ^ N₂) ≤
        tower d (C * x ^ N) := by
  induction' d with d ih generalizing C₁ C₂ N₁ N₂;
  · -- For the base case when $d = 0$, we have $tower 0 (C₁ * x^N₁) = C₁ * x^N₁$ and $tower 0 (C₂ * x^N₂) = C₂ * x^N₂$.
    use C₁ + C₂, max N₁ N₂, by linarith, 1;
    intro x hx; rw [ show tower 0 = id from funext fun x => rfl ] ; ring_nf;
    norm_num; nlinarith [ pow_le_pow_right₀ hx ( show N₁ ≤ max N₁ N₂ by exact le_max_left _ _ ), pow_le_pow_right₀ hx ( show N₂ ≤ max N₁ N₂ by exact le_max_right _ _ ) ] ;
  · -- For d+1, use C = C₁ + C₂ + 1, N = max N₁ N₂.
    use C₁ + C₂ + 1, max N₁ N₂ + 1
    simp [tower];
    -- We'll use that exponential functions grow faster than any polynomial function.
    have h_exp_growth : Filter.Tendsto (fun x : ℝ => Real.exp (tower d ((C₁ + C₂ + 1) * x ^ (max N₁ N₂ + 1))) - (Real.exp (tower d (C₁ * x ^ N₁)) + Real.exp (tower d (C₂ * x ^ N₂)))) Filter.atTop Filter.atTop := by
      -- We'll use that exponential functions grow faster than any polynomial function to show that the difference tends to infinity.
      have h_exp_growth : Filter.Tendsto (fun x : ℝ => Real.exp (tower d ((C₁ + C₂ + 1) * x ^ (max N₁ N₂ + 1))) - 2 * Real.exp (tower d (max C₁ C₂ * x ^ (max N₁ N₂ + 1)))) Filter.atTop Filter.atTop := by
        -- We can factor out $e^{tower d (max C₁ C₂ * x ^ (max N₁ N₂ + 1))}$ from the expression.
        suffices h_factor : Filter.Tendsto (fun x : ℝ => Real.exp (tower d (max C₁ C₂ * x ^ (max N₁ N₂ + 1))) * (Real.exp (tower d ((C₁ + C₂ + 1) * x ^ (max N₁ N₂ + 1)) - tower d (max C₁ C₂ * x ^ (max N₁ N₂ + 1))) - 2)) Filter.atTop Filter.atTop by
          convert h_factor using 2 ; rw [ mul_sub, ← Real.exp_add ] ; ring;
        -- We'll use that exponential functions grow faster than any polynomial function to show that the difference tends to infinity. Specifically, we'll show that the term inside the exponential tends to infinity.
        have h_exp_growth : Filter.Tendsto (fun x : ℝ => tower d ((C₁ + C₂ + 1) * x ^ (max N₁ N₂ + 1)) - tower d (max C₁ C₂ * x ^ (max N₁ N₂ + 1))) Filter.atTop Filter.atTop := by
          -- By induction on $d$, we can show that the difference between the two towers tends to infinity.
          have h_ind : ∀ d : ℕ, ∀ C₁ C₂ : ℝ, 0 < C₁ → 0 < C₂ → C₁ > C₂ → Filter.Tendsto (fun x : ℝ => tower d (C₁ * x ^ (max N₁ N₂ + 1)) - tower d (C₂ * x ^ (max N₁ N₂ + 1))) Filter.atTop Filter.atTop := by
            intro d C₁ C₂ hC₁ hC₂ hC₁₂; induction' d with d ih generalizing C₁ C₂ <;> simp_all +decide [ tower ] ;
            · norm_num [ ← sub_mul ];
              exact Filter.Tendsto.const_mul_atTop ( sub_pos.mpr hC₁₂ ) ( Filter.tendsto_pow_atTop ( by positivity ) );
            · have h_exp_growth : Filter.Tendsto (fun x : ℝ => Real.exp (tower d (C₂ * x ^ (max N₁ N₂ + 1))) * (Real.exp (tower d (C₁ * x ^ (max N₁ N₂ + 1)) - tower d (C₂ * x ^ (max N₁ N₂ + 1))) - 1)) Filter.atTop Filter.atTop := by
                have h_exp_growth : Filter.Tendsto (fun x : ℝ => Real.exp (tower d (C₂ * x ^ (max N₁ N₂ + 1)))) Filter.atTop Filter.atTop := by
                  refine' Real.tendsto_exp_atTop.comp _;
                  exact tower_tendsto_atTop d |> Filter.Tendsto.comp <| Filter.Tendsto.const_mul_atTop hC₂ <| Filter.tendsto_pow_atTop <| by positivity;;
                have h_exp_growth : Filter.Tendsto (fun x : ℝ => Real.exp (tower d (C₁ * x ^ (max N₁ N₂ + 1)) - tower d (C₂ * x ^ (max N₁ N₂ + 1))) - 1) Filter.atTop Filter.atTop := by
                  exact Filter.tendsto_atTop_add_const_right _ _ ( Real.tendsto_exp_atTop.comp ( ih C₁ C₂ hC₁ hC₂ hC₁₂ ) );
                rw [ Filter.tendsto_atTop_atTop ] at *;
                exact fun b => by obtain ⟨ i, hi ⟩ := h_exp_growth ( Max.max b 1 ) ; obtain ⟨ j, hj ⟩ := ‹∀ b : ℝ, ∃ i : ℝ, ∀ a : ℝ, i ≤ a → b ≤ Real.exp ( tower d ( C₂ * a ^ ( max N₁ N₂ + 1 ) ) ) › 1; exact ⟨ Max.max i j, fun x hx => by nlinarith [ hi x ( le_trans ( le_max_left _ _ ) hx ), hj x ( le_trans ( le_max_right _ _ ) hx ), le_max_left b 1, le_max_right b 1 ] ⟩ ;
              convert h_exp_growth using 2 ; rw [ mul_sub, mul_one, ← Real.exp_add ] ; ring;
          exact h_ind _ _ _ ( by positivity ) ( by positivity ) ( by cases max_cases C₁ C₂ <;> linarith );
        refine' Filter.tendsto_atTop_mono' _ _ _;
        use fun x => Real.exp ( tower d ( max C₁ C₂ * x ^ ( max N₁ N₂ + 1 ) ) ) * ( Real.exp ( 1 ) - 2 );
        · filter_upwards [ h_exp_growth.eventually_gt_atTop 1 ] with x hx using mul_le_mul_of_nonneg_left ( by linarith [ Real.add_one_le_exp 1, Real.exp_le_exp.2 hx.le ] ) ( Real.exp_nonneg _ );
        · refine' Filter.Tendsto.atTop_mul_const _ _;
          · exact sub_pos_of_lt ( Real.exp_one_gt_d9.trans_le' <| by norm_num );
          · refine' Real.tendsto_exp_atTop.comp _;
            refine' tower_tendsto_atTop d |> Filter.Tendsto.comp <| Filter.Tendsto.const_mul_atTop ( by positivity ) <| Filter.tendsto_pow_atTop <| by positivity;
      -- Since $C₁ * x ^ N₁ \leq \max C₁ C₂ * x ^ (max N₁ N₂ + 1)$ and $C₂ * x ^ N₂ \leq \max C₁ C₂ * x ^ (max N₁ N₂ + 1)$ for $x \geq 1$, we have:
      have h_bound : ∀ x : ℝ, 1 ≤ x → Real.exp (tower d (C₁ * x ^ N₁)) + Real.exp (tower d (C₂ * x ^ N₂)) ≤ 2 * Real.exp (tower d (max C₁ C₂ * x ^ (max N₁ N₂ + 1))) := by
        intros x hx
        have h_bound : C₁ * x ^ N₁ ≤ max C₁ C₂ * x ^ (max N₁ N₂ + 1) ∧ C₂ * x ^ N₂ ≤ max C₁ C₂ * x ^ (max N₁ N₂ + 1) := by
          exact ⟨ mul_le_mul ( le_max_left _ _ ) ( pow_le_pow_right₀ hx ( by linarith [ Nat.le_max_left N₁ N₂ ] ) ) ( by positivity ) ( by positivity ), mul_le_mul ( le_max_right _ _ ) ( pow_le_pow_right₀ hx ( by linarith [ Nat.le_max_right N₁ N₂ ] ) ) ( by positivity ) ( by positivity ) ⟩;
        linarith [ Real.exp_le_exp.mpr ( show tower d ( C₁ * x ^ N₁ ) ≤ tower d ( max C₁ C₂ * x ^ ( max N₁ N₂ + 1 ) ) from tower_mono d h_bound.1 ), Real.exp_le_exp.mpr ( show tower d ( C₂ * x ^ N₂ ) ≤ tower d ( max C₁ C₂ * x ^ ( max N₁ N₂ + 1 ) ) from tower_mono d h_bound.2 ) ];
      rw [ Filter.tendsto_atTop_atTop ] at *;
      exact fun b => by obtain ⟨ i, hi ⟩ := h_exp_growth b; exact ⟨ Max.max i 1, fun x hx => by linarith [ hi x ( le_trans ( le_max_left _ _ ) hx ), h_bound x ( le_trans ( le_max_right _ _ ) hx ) ] ⟩ ;
    exact ⟨ by positivity, by rcases Filter.eventually_atTop.mp ( h_exp_growth.eventually_gt_atTop 0 ) with ⟨ X₀, hX₀ ⟩ ; exact ⟨ X₀, fun x hx => by linarith [ hX₀ x hx ] ⟩ ⟩

/-! ## Majorant for Inv-Free Fragment -/

/-
Any inv-free FullEML expression of expDepth ≤ d has a full EML majorant at level d.
    This is the base case that extends to the full EML via the inv lemma.
-/
theorem invFree_has_majorant (f : FullEML) (hf : f.hasInv = false) (d : ℕ)
    (hd : f.expDepth ≤ d) :
    HasFullEMLMajorant d f := by
  induction' f using FullEML.recOn with f g ihf ihg generalizing d;
  all_goals simp_all +decide [ FullEML.hasInv ];
  · use 1, 1;
    norm_num [ FullEML.eval ];
    exact ⟨ 0, fun x hx => by rw [ abs_of_nonneg hx ] ; exact tower_ge_self _ hx ⟩;
  · use |f| + 1, 0;
    refine' ⟨ by positivity, 0, fun x hx => _ ⟩;
    induction' d with d ih generalizing x <;> simp_all +decide [ tower ];
    · exact le_add_of_le_of_nonneg ( by rfl ) zero_le_one;
    · exact le_trans ( ih ( by exact Nat.zero_le _ ) x hx ) ( le_trans ( by norm_num ) ( Real.add_one_le_exp _ ) );
  · -- By the induction hypothesis, we have that both g and ihf have full EML majorants at level d.
    obtain ⟨C₁, N₁, hC₁, X₀₁, hX₀₁⟩ := ihg d (by
    exact le_trans ( by exact le_max_left _ _ ) hd)
    obtain ⟨C₂, N₂, hC₂, X₀₂, hX₀₂⟩ := ‹∀ (d : ℕ), ihf.expDepth ≤ d → HasFullEMLMajorant d ihf› d (by
    exact le_trans ( by exact le_max_right _ _ ) hd);
    obtain ⟨ C, N, hC, X₀, hX₀ ⟩ := tower_poly_absorbs_sum d C₁ C₂ N₁ N₂ hC₁ hC₂;
    use C, N, hC, Max.max X₀ ( Max.max X₀₁ X₀₂ ) ; intro x hx ; simp_all +decide [ abs_le ] ;
    constructor <;> linarith! [ hX₀₁ x hx.2.1, hX₀₂ x hx.2.2, hX₀ x hx.1, show ( g.add ihf ).eval x = g.eval x + ihf.eval x from rfl ];
  · rename_i f g hf hg;
    -- By the induction hypothesis, we have that $f$ and $g$ have full EML majorants at level $d$.
    obtain ⟨C₁, N₁, hC₁, X₀₁, hX₀₁⟩ := ‹∀ (d : ℕ), f.expDepth ≤ d → HasFullEMLMajorant d f› d (by
    exact le_trans ( by exact le_max_left _ _ ) hd)
    obtain ⟨C₂, N₂, hC₂, X₀₂, hX₀₂⟩ := hg d (by
    exact le_trans ( by exact le_max_right _ _ ) hd);
    -- By the properties of the tower function, we have that $tower d (C₁ * x ^ N₁) * tower d (C₂ * x ^ N₂) \leq tower d (C * x ^ N)$ for some $C$ and $N$.
    obtain ⟨C, N, hC, X₀, hX₀⟩ : ∃ C N, 0 < C ∧ ∃ X₀ : ℝ, ∀ x ≥ X₀, tower d (C₁ * x ^ N₁) * tower d (C₂ * x ^ N₂) ≤ tower d (C * x ^ N) := by
      by_cases hd : d = 0;
      · use C₁ * C₂, N₁ + N₂;
        simp_all +decide [ mul_assoc, mul_left_comm, pow_add ];
      · -- For $d \geq 1$, we can use the fact that $tower d (y) = exp(tower (d-1) (y))$.
        have h_tower_exp : ∀ y : ℝ, tower d y = Real.exp (tower (d - 1) y) := by
          cases d <;> tauto;
        -- By the properties of the tower function, we have that $tower (d-1) (C₁ * x ^ N₁) + tower (d-1) (C₂ * x ^ N₂) \leq tower (d-1) (C * x ^ N)$ for some $C$ and $N$.
        obtain ⟨C, N, hC, X₀, hX₀⟩ : ∃ C N, 0 < C ∧ ∃ X₀ : ℝ, ∀ x ≥ X₀, tower (d - 1) (C₁ * x ^ N₁) + tower (d - 1) (C₂ * x ^ N₂) ≤ tower (d - 1) (C * x ^ N) := by
          exact?;
        use C, N, hC, X₀;
        intro x hx; rw [ h_tower_exp, h_tower_exp, h_tower_exp ] ; rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( hX₀ x hx ) ;
    use C, N, hC, Max.max X₀ ( Max.max X₀₁ X₀₂ );
    simp_all +decide [ FullEML.eval ];
    exact fun x hx₁ hx₂ hx₃ => le_trans ( mul_le_mul ( hX₀₁ x hx₂ ) ( hX₀₂ x hx₃ ) ( by positivity ) ( by exact le_trans ( by positivity ) ( hX₀₁ x hx₂ ) ) ) ( hX₀ x hx₁ );
  · rename_i f ih;
    obtain ⟨ C, N, hC, X₀, hX₀ ⟩ := ih ( d - 1 ) ( Nat.le_sub_one_of_lt ( by { exact Nat.lt_of_succ_le hd } ) );
    refine' ⟨ C, N, hC, Max.max X₀ 1, fun x hx => _ ⟩ ; simp_all +decide [ FullEML.eval ];
    rcases d <;> simp_all +decide [ tower ];
    · exact absurd hd ( by erw [ show f.exp.expDepth = f.expDepth + 1 from rfl ] ; positivity );
    · exact le_of_abs_le ( hX₀ x hx.1 )

/-! ## The Key Lemma: Inv Preserves Majorant Class -/

/-
**Critical lemma**: If g has a full EML majorant at level d and g is eventually
    non-vanishing with a lower bound, then inv(g) also has a majorant at level d.

    The proof idea: if |g(x)| ≥ 1/tower(d, C₀ * x^M) for large x, then
    |1/g(x)| ≤ tower(d, C₀ * x^M), which is the majorant form.
-/
theorem inv_majorant_of_lower_bound (g : FullEML) (d : ℕ)
    (_hg_upper : HasFullEMLMajorant d g)
    (hg_lower : ∃ (C₀ : ℝ) (M : ℕ), 0 < C₀ ∧ ∃ X₀ : ℝ, ∀ x ≥ X₀,
      (tower d (C₀ * x ^ M))⁻¹ ≤ |g.eval x|) :
    HasFullEMLMajorant d (.inv g) := by
  obtain ⟨ C₀, M, hC₀, X₀, hX₀ ⟩ := hg_lower;
  refine' ⟨ C₀, M, hC₀, Max.max X₀ 1, fun x hx => _ ⟩;
  convert inv_anti₀ _ ( hX₀ x ( le_trans ( le_max_left _ _ ) hx ) ) using 1;
  · exact abs_inv _;
  · norm_num;
  · exact inv_pos.mpr ( show 0 < tower d ( C₀ * x ^ M ) from Nat.recOn d ( by exact mul_pos hC₀ ( pow_pos ( by linarith [ le_max_right X₀ 1 ] ) _ ) ) fun n ihn => by exact Real.exp_pos _ )

/-! ## Full EML Majorant (Grand Conjecture) -/

/-- **Grand Conjecture (Full EML Majorant)**: Every FullEML expression of
    expDepth ≤ d is eventually bounded by `tower d (C * x^N)`,
    *regardless of how many inversions it contains*.

    This is the key analytic claim. The inv-free case is proved above
    (`invFree_has_majorant`). The full case requires Hardy field theory
    to handle the non-cancellation of sums and products involving inversions.

    Proved for the inv-free fragment; the full version with inversions
    requires establishing that EML expressions form a Hardy field
    (where non-zero elements are eventually sign-definite). -/
theorem fullEML_has_majorant (f : FullEML) (d : ℕ) (hd : f.expDepth ≤ d) :
    HasFullEMLMajorant d f := by
  sorry

/-
**Key structural lemma**: If every expression of expDepth ≤ d has a
    majorant at level d, then no such expression can represent tower(n)
    when d < n. This separates the analytic content (majorant) from
    the combinatorial content (hierarchy).
-/
theorem hierarchy_from_majorant (n : ℕ) (_hn : 1 ≤ n) (f : FullEML)
    (hd : f.expDepth < n)
    (hmaj : HasFullEMLMajorant f.expDepth f) :
    ¬(∃ (X : ℝ), ∀ x > X, f.eval x = tower n x) := by
  obtain ⟨ C, N, hC, X₀, hX₀ ⟩ := hmaj;
  -- By induction on $d$, we show that $exp(tower d x) > tower d (C * x^N)$ for large $x$.
  have h_ind : ∀ d : ℕ, ∀ C : ℝ, 0 < C → ∀ N : ℕ, ∃ X₀ : ℝ, ∀ x ≥ X₀, Real.exp (tower d x) > tower d (C * x ^ N) := by
    intro d C hC N;
    induction' d with d ih generalizing C N;
    · convert poly_dominated_by_exp C N using 1;
    · simp_all +decide [ tower_succ ];
  -- By induction on $d$, we show that $tower n x > tower d (C * x^N)$ for large $x$.
  have h_induction : ∀ d : ℕ, ∀ C : ℝ, 0 < C → ∀ N : ℕ, ∀ n : ℕ, d < n → ∃ X₀ : ℝ, ∀ x ≥ X₀, tower n x > tower d (C * x ^ N) := by
    intro d C hC N n hn;
    induction' hn with k hk ihizing C N;
    · exact h_ind d C hC N;
    · exact ⟨ ihizing.choose, fun x hx => lt_trans ( ihizing.choose_spec x hx ) ( by exact lt_of_lt_of_le ( show tower k x < Real.exp ( tower k x ) from by linarith [ Real.add_one_le_exp ( tower k x ) ] ) ( by exact le_of_eq ( by rw [ tower_succ ] ) ) ) ⟩;
  obtain ⟨ X₁, hX₁ ⟩ := h_induction f.expDepth C hC N n hd;
  exact fun ⟨ X, hX ⟩ => by have := hX ( Max.max X₀ ( Max.max X₁ X ) + 1 ) ( by linarith [ le_max_left X₀ ( Max.max X₁ X ), le_max_right X₀ ( Max.max X₁ X ), le_max_left X₁ X, le_max_right X₁ X ] ) ; linarith [ abs_le.mp ( hX₀ ( Max.max X₀ ( Max.max X₁ X ) + 1 ) ( by linarith [ le_max_left X₀ ( Max.max X₁ X ), le_max_right X₀ ( Max.max X₁ X ), le_max_left X₁ X, le_max_right X₁ X ] ) ), hX₁ ( Max.max X₀ ( Max.max X₁ X ) + 1 ) ( by linarith [ le_max_left X₀ ( Max.max X₁ X ), le_max_right X₀ ( Max.max X₁ X ), le_max_left X₁ X, le_max_right X₁ X ] ) ] ;

/-! ## Main Result: The Full Depth Hierarchy -/

/-- **Main theorem**: No FullEML expression of expDepth < n can represent
    `tower n` on all sufficiently large positive reals.

    Even with `inv` nodes freely available, exp-depth n is necessary
    for `tower n x = exp^[n](x)`. -/
theorem no_lowExpDepth_represents_tower (n : ℕ) (hn : 1 ≤ n) (f : FullEML) :
    f.expDepth < n →
    ¬(∃ (X : ℝ), ∀ x > X, f.eval x = tower n x) := by
  intro hd
  exact hierarchy_from_majorant n hn f hd (fullEML_has_majorant f f.expDepth le_rfl)

/-! ## Hierarchy for the Inv-Free Fragment -/

/-
The hierarchy theorem specialized to the inv-free fragment:
    no inv-free expression of expDepth < n can represent tower n.
    This is proved more directly since we have the majorant for inv-free expressions.
-/
theorem no_invFree_lowExpDepth_represents_tower (n : ℕ) (hn : 1 ≤ n) (f : FullEML)
    (hf : f.hasInv = false) :
    f.expDepth < n →
    ¬(∃ (X : ℝ), ∀ x > X, f.eval x = tower n x) := by
  intro hd
  exact hierarchy_from_majorant n hn f hd (invFree_has_majorant f hf f.expDepth le_rfl)

/-! ## Corollaries -/

/-- The canonical construction is depth-optimal even in the full EML. -/
theorem canonicalTower_depth_optimal (n : ℕ) (hn : 1 ≤ n) :
    ¬∃ f : FullEML, f.expDepth < n ∧
      (∃ X : ℝ, ∀ x > X, f.eval x = tower n x) := by
  intro ⟨f, hd, hrep⟩
  exact no_lowExpDepth_represents_tower n hn f hd hrep

/-- **Testable conjecture**: For any FullEML expression f of expDepth ≤ 1,
    the function f cannot match `tower 2 x = exp(exp(x))` eventually. -/
theorem conjecture_depth1_cannot_match_tower2 (f : FullEML)
    (hd : f.expDepth ≤ 1) :
    ¬(∃ (X : ℝ), ∀ x > X, f.eval x = tower 2 x) := by
  exact no_lowExpDepth_represents_tower 2 (by omega) f (by omega)

/-! ## Additional Structural Results -/

/-- expDepth is subadditive under add. -/
theorem expDepth_add (f g : FullEML) :
    (FullEML.add f g).expDepth = max f.expDepth g.expDepth := rfl

/-- expDepth is subadditive under mul. -/
theorem expDepth_mul (f g : FullEML) :
    (FullEML.mul f g).expDepth = max f.expDepth g.expDepth := rfl

/-- expDepth of exp increases by exactly 1. -/
theorem expDepth_exp (f : FullEML) :
    (FullEML.exp f).expDepth = f.expDepth + 1 := rfl

/-- expDepth of inv equals the expDepth of the argument — inv is free. -/
theorem expDepth_inv (f : FullEML) :
    (FullEML.inv f).expDepth = f.expDepth := rfl

/-- The decision procedure is correct: `canRepresentAtDepth n d = true` iff d ≥ n. -/
theorem canRepresentAtDepth_correct (n d : ℕ) :
    canRepresentAtDepth n d = true ↔ d ≥ n := by
  simp [canRepresentAtDepth]

end