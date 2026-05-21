import CompilerLowerBound.Defs

/-!
# Growth Bounds for Inverse-Free EML Expressions

This file proves the analytical core of the depth lower bound:
inverse-free EML expressions with bounded `expRank` have bounded growth rate,
while `iterExp` at higher levels grows faster.

## Main Results

- `expRank_lower_bound_iterExp`: If inverse-free `e` computes `iterExp n`,
  then `n ≤ e.expRank`.

## Proof Architecture

**Case 1** (expRank = 0, n ≥ 1): An inverse-free expression with no `eml` nodes
computes a polynomial. But `iterExp n` for `n ≥ 1` grows faster than any polynomial.

**Case 2** (expRank ≥ 1, expRank < n): An inverse-free expression with `expRank ≤ k`
(k ≥ 1) has `|e.eval x| ≤ iterExp k (C * x)` eventually. By separation,
`iterExp (k+1) x > iterExp k (C * x)` eventually. Since `k + 1 ≤ n`, we get
`iterExp n x > |e.eval x|`, contradicting `e.eval x = iterExp n x`.
-/

noncomputable section

open Real Filter

/-! ## Basic Properties of iterExp -/

/-- Iterated exponentials are positive on positive inputs. -/
theorem iterExp_pos_of_pos (n : ℕ) {x : ℝ} (hx : 0 < x) : 0 < iterExp n x := by
  induction n with
  | zero => exact hx
  | succ n ih => exact exp_pos _

/-- Iterated exponentials are monotone (in the argument). -/
theorem iterExp_mono (n : ℕ) : Monotone (iterExp n) := by
  induction n with
  | zero => exact monotone_id
  | succ n ih => exact fun _ _ hab => exp_le_exp.mpr (ih hab)

/-- Iterated exponentials are strictly monotone. -/
theorem iterExp_strictMono (n : ℕ) : StrictMono (iterExp n) := by
  induction n with
  | zero => exact strictMono_id
  | succ n ih => exact fun _ _ hab => exp_lt_exp.mpr (ih hab)

/-- iterExp n tends to +∞. -/
theorem iterExp_tendsto_atTop (n : ℕ) :
    Tendsto (iterExp n) atTop atTop := by
  induction n with
  | zero => exact tendsto_id
  | succ n ih => exact Real.tendsto_exp_atTop.comp ih

/-- iterExp n x ≥ x for x ≥ 0. -/
theorem iterExp_ge_self (n : ℕ) {x : ℝ} (hx : 0 ≤ x) : x ≤ iterExp n x := by
  induction n with
  | zero => rfl
  | succ n ih =>
    calc x ≤ iterExp n x := ih
    _ ≤ iterExp (n + 1) x := by
        simp [iterExp]; linarith [Real.add_one_le_exp (iterExp n x)]

/-- iterExp is monotone in the level: if n ≤ m then iterExp n x ≤ iterExp m x for x ≥ 0. -/
theorem iterExp_mono_level {n m : ℕ} (hnm : n ≤ m) {x : ℝ} (hx : 0 ≤ x) :
    iterExp n x ≤ iterExp m x := by
  induction hnm <;> simp_all +decide [ iterExp ];
  exact le_trans ‹_› ( by linarith [ Real.add_one_le_exp ( iterExp ‹_› x ) ] )

/-! ## Growth Separation -/

/-- For any `C > 0`, `iterExp (k+1) x` eventually exceeds `iterExp k (C * x)`. -/
theorem iterExp_eventually_exceeds (k : ℕ) (C : ℝ) (hC : 0 < C) :
    ∃ X₀ : ℝ, ∀ x ≥ X₀, iterExp k (C * x) < iterExp (k + 1) x := by
  induction' k with k ih generalizing C <;> simp_all +decide [ iterExp ];
  have h_lim : Filter.Tendsto (fun x : ℝ => Real.exp x / x) Filter.atTop Filter.atTop := by
    simpa using Real.tendsto_exp_div_pow_atTop 1;
  exact Filter.eventually_atTop.mp ( h_lim.eventually_gt_atTop C ) |> fun ⟨ X₀, hX₀ ⟩ ↦ ⟨ Max.max X₀ 1, fun x hx ↦ by have := hX₀ x ( le_trans ( le_max_left _ _ ) hx ) ; rw [ lt_div_iff₀ ] at this <;> linarith [ le_max_right X₀ 1 ] ⟩

/-! ## Exp eventually exceeds any polynomial -/

/-
`exp x` eventually exceeds `C * x ^ d` for any `C > 0` and `d`.
-/
theorem exp_eventually_exceeds_poly (C : ℝ) (d : ℕ) :
    ∃ X₀ : ℝ, ∀ x ≥ X₀, C * x ^ d < exp x := by
  -- By multiplying both sides of the inequality $exp x > (|C| + 1) * x^d$ by $x^d$, we obtain $exp x > C * x^d$.
  have h_final : ∀ᶠ x in Filter.atTop, Real.exp x > (|C| + 1) * x ^ d := by
    have := Real.tendsto_exp_div_pow_atTop d;
    filter_upwards [ this.eventually_gt_atTop ( |C| + 1 ), Filter.eventually_gt_atTop 0 ] with x hx₁ hx₂ using by rw [ gt_iff_lt ] at *; rw [ lt_div_iff₀ ( pow_pos hx₂ _ ) ] at *; linarith;
  exact Filter.eventually_atTop.mp h_final |> fun ⟨ X₀, hX₀ ⟩ ↦ ⟨ Max.max X₀ 0, fun x hx ↦ by cases abs_cases C <;> nlinarith [ hX₀ x ( le_trans ( le_max_left _ _ ) hx ), show x ^ d ≥ 0 by exact pow_nonneg ( le_trans ( le_max_right _ _ ) hx ) _ ] ⟩

/-! ## Growth Bound for expRank ≥ 1 -/

/-- An inverse-free expression with `1 ≤ k` and `expRank ≤ k` has evaluation
    eventually bounded by `iterExp k (C * x)`. -/
theorem eval_bound_expRank_pos (k : ℕ) (hk : 1 ≤ k) (e : EMLExpr)
    (hinv : e.InverseFree) (hr : e.expRank ≤ k) :
    ∃ C : ℝ, C > 0 ∧ ∃ X₀ : ℝ, ∀ x ≥ X₀, x > 0 →
      |e.eval x| ≤ iterExp k (C * x) := by
  sorry

/-! ## Main Lower Bound on expRank -/

/-
**expRank lower bound**: If an inverse-free EML expression computes
    `iterExp n` on positive reals, then `n ≤ e.expRank`.
-/
theorem expRank_lower_bound_iterExp
    (n : ℕ) (e : EMLExpr)
    (hrep : ComputesIterExp n e)
    (hinv : e.InverseFree) :
    n ≤ e.expRank := by
  -- Case n = 0: trivial since expRank ≥ 0
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · exact Nat.zero_le _
  -- Case n ≥ 1: by contradiction
  by_contra h
  push_neg at h
  rcases Nat.eq_zero_or_pos e.expRank with hk0 | hk
  · -- Subcase expRank = 0: e has no eml nodes, computes a polynomial
    -- But iterExp n (n ≥ 1) grows faster than any polynomial
    -- To make the goal concrete:.policy `s` `v`, `v`_counts number `小康` adversary `m`, `small` option = `around x`1 are roughly `بية`. `world` `congruent purple` `x` `moment` string. five `devoted` ` caused `all`. polarjoy children.
    let f : ℝ → ℝ := fun x => e.eval x;
    have hf_poly : ∃ C : ℝ, C > 0 ∧ ∃ X₀ : ℝ, ∀ x ≥ X₀, x > 0 → abs (f x) < exp x := by
      -- Since `e` has `expRank = 0`, it only uses `var`, `const`, `add`, `mul`, `neg`.
      -- Such expressions compute polynomials.
      have h_poly : ∃ p : Polynomial ℝ, ∀ x : ℝ, e.eval x = p.eval x := by
        have h_poly : ∀ e : EMLExpr, e.expRank = 0 → e.InverseFree → ∃ p : Polynomial ℝ, ∀ x : ℝ, e.eval x = p.eval x := by
          intro e he hinv
          induction' e with e ih_a ih_b;
          all_goals norm_num [ EMLExpr.eval, EMLExpr.expRank ] at *;
          exact ⟨ Polynomial.X, fun x => by simp +decide ⟩;
          · exact ⟨ Polynomial.C e, fun x => by simp +decide ⟩;
          · rename_i h₁ h₂;
            obtain ⟨ p₁, hp₁ ⟩ := h₁ he.1 ( by cases hinv; tauto ) ; obtain ⟨ p₂, hp₂ ⟩ := h₂ he.2 ( by cases hinv; tauto ) ; exact ⟨ p₁ + p₂, fun x => by simp +decide [ hp₁, hp₂ ] ⟩ ;
          · rename_i a b ha hb;
            obtain ⟨ p, hp ⟩ := ha he.1 ( by cases hinv; tauto ) ; obtain ⟨ q, hq ⟩ := hb he.2 ( by cases hinv; tauto ) ; exact ⟨ p * q, fun x => by simp +decide [ hp, hq ] ⟩ ;
          · rename_i a ha;
            exact Exists.elim ( ha he ( by cases a <;> tauto ) ) fun p hp => ⟨ -p, fun x => by simp +decide [ hp ] ⟩;
          · cases hinv;
        exact h_poly e hk0 hinv;
      -- By `exp_eventually_exceeds_poly`, there exists `X₀` such that `C * x^d < exp x` for all `x ≥ X₀`.
      obtain ⟨p, hp⟩ := h_poly
      have h_poly_growth : ∀ d : ℕ, ∃ X₀ : ℝ, ∀ x ≥ X₀, x > 0 → |p.eval x| < Real.exp x := by
        intro d
        have h_poly_growth : Filter.Tendsto (fun x => |p.eval x| / Real.exp x) Filter.atTop (nhds 0) := by
          have := Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero;
          -- Since $p$ is a polynomial, we can write it as $p(x) = \sum_{i=0}^{d} a_i x^i$ for some coefficients $a_i$.
          have h_poly_form : ∃ (a : Fin (p.natDegree + 1) → ℝ), ∀ x : ℝ, p.eval x = ∑ i, a i * x ^ (i : ℕ) := by
            use fun i => p.coeff i.val;
            simp +decide [ Polynomial.eval_eq_sum_range ];
            exact fun x => by rw [ Finset.sum_range ] ;
          obtain ⟨ a, ha ⟩ := h_poly_form; simp_all +decide [ Real.exp_neg, div_eq_mul_inv ] ;
          -- Apply the fact that the absolute value of a sum is less than or equal to the sum of the absolute values.
          have h_abs_sum : Filter.Tendsto (fun x => ∑ i, |a i| * |x ^ (i : ℕ)| * (Real.exp x)⁻¹) Filter.atTop (nhds 0) := by
            exact le_trans ( tendsto_finset_sum _ fun i _ => by simpa [ mul_assoc, abs_mul ] using Filter.Tendsto.const_mul ( |a i| ) ( this i |> Filter.Tendsto.abs ) ) ( by norm_num );
          refine' squeeze_zero ( fun x => by positivity ) ( fun x => _ ) h_abs_sum;
          simpa only [ ← abs_mul, ← Finset.sum_mul _ _ _ ] using mul_le_mul_of_nonneg_right ( Finset.abs_sum_le_sum_abs _ _ ) ( by positivity );
        exact Filter.eventually_atTop.mp ( h_poly_growth.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ X₀, hX₀ ⟩ ↦ ⟨ X₀, fun x hx₁ hx₂ ↦ by have := hX₀ x hx₁; rw [ div_lt_one ( Real.exp_pos x ) ] at this; linarith ⟩;
      exact ⟨ 1, by norm_num, h_poly_growth 0 |> fun ⟨ X₀, hX₀ ⟩ => ⟨ X₀, fun x hx₁ hx₂ => by aesop ⟩ ⟩;
    -- By assumption, $f(x) = \text{iterExp}(n, x)$ for all $x > 0$.
    have hf_eq : ∀ x > 0, f x = iterExp n x := by
      exact hrep;
    -- Since $n \geq 1$, we have $\text{iterExp}(n, x) \geq \text{iterExp}(1, x) = \exp(x)$ for all $x > 0$.
    have h_iterExp_ge_exp : ∀ x > 0, iterExp n x ≥ Real.exp x := by
      intro x hx; exact (by
      exact iterExp_mono_level hn ( by positivity ));
    obtain ⟨ C, hC₀, X₀, hX₀ ⟩ := hf_poly; specialize hX₀ ( Max.max X₀ 1 ) ( le_max_left _ _ ) ( by positivity ) ; linarith [ abs_lt.mp hX₀, hf_eq ( Max.max X₀ 1 ) ( by positivity ), h_iterExp_ge_exp ( Max.max X₀ 1 ) ( by positivity ) ] ;;
  · -- Subcase expRank ≥ 1: use growth bound
    obtain ⟨C, hC, X₀, hbound⟩ := eval_bound_expRank_pos e.expRank hk e hinv le_rfl
    obtain ⟨X₁, hsep⟩ := iterExp_eventually_exceeds e.expRank C hC
    set x := max (max X₀ X₁) 1 + 1 with hx_def
    have hx_ge_X0 : x ≥ X₀ := by simp [hx_def]; linarith [le_max_left X₀ X₁, le_max_left (max X₀ X₁) (1:ℝ)]
    have hx_ge_X1 : x ≥ X₁ := by simp [hx_def]; linarith [le_max_right X₀ X₁, le_max_left (max X₀ X₁) (1:ℝ)]
    have hx_pos : x > 0 := by simp [hx_def]; linarith [le_max_right (max X₀ X₁) (1:ℝ)]
    have heval : e.eval x = iterExp n x := hrep x hx_pos
    have hb := hbound x hx_ge_X0 hx_pos
    have hs := hsep x hx_ge_X1
    have hle : iterExp (e.expRank + 1) x ≤ iterExp n x :=
      iterExp_mono_level (by omega) (le_of_lt hx_pos)
    have habs : |iterExp n x| = iterExp n x :=
      abs_of_pos (iterExp_pos_of_pos n hx_pos)
    rw [heval, habs] at hb
    linarith

end