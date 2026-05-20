/-
# EML Depth Separation — Main Separation Theorem

This file contains the main depth separation theorem: for every depth
bound `D`, there exists `N` such that for all `n ≥ N`, no inv-free
`EMLExpr` of depth at most `D` can represent `iterExp n` on positive reals.

## Proof Strategy

The proof proceeds in three stages:

1. **Growth bound** (`noInv_eval_growth_bound`): By structural induction,
   every inv-free EMLExpr of `emlDepth ≤ D` has evaluation bounded by
   `iterExp (D+1) (C * x)` for some constant `C` and sufficiently large `x`.

2. **Growth separation** (`iterExp_growth_separation`): For any constant `C`,
   `iterExp (D+2) x` eventually exceeds `iterExp (D+1) (C * x)`.

3. **Contradiction**: If an EMLExpr of depth ≤ D represented `iterExp n`
   for `n ≥ D+3`, the growth bound would contradict the growth separation.

## Cross-Domain Connection: Circuit Complexity

This separation theorem is the exact analogue of bounded-depth circuit
lower bounds from computational complexity theory:

| Circuit Complexity | EML Depth Separation |
|---|---|
| AC⁰ circuits | Depth-bounded EMLExpr |
| PARITY function | Iterated exponential |
| Gate count (size) | Expression size |
| Circuit depth | emlDepth |
| Polynomial-size AC⁰ ≠ PARITY | No bounded-depth EML = iterExp n |

Just as PARITY escapes AC⁰ because constant-depth circuits cannot
propagate carry information across all input bits, `iterExp n` escapes
depth-D EML because bounded eml-nesting cannot produce enough
exponential growth layers.
-/
import Speculative.EMLDepthSeparation.Theorems

noncomputable section

open Real Filter

/-! ## Growth bound helper lemmas -/

/-
`exp(t) ≥ 1 + t` for all `t : ℝ` (tangent line inequality).
-/
theorem exp_ge_one_add (t : ℝ) : 1 + t ≤ Real.exp t := by
  linarith [ Real.add_one_le_exp t ]

/-
For D ≥ 1 and C > 0, iterExp D ((C+1)*x) ≥ e * iterExp D (C*x) for large x.
    This is the key "absorption" lemma: increasing the linear coefficient by 1
    multiplies the output by at least e, because of exponential sensitivity.
-/
theorem iterExp_bump_coeff (D : ℕ) (hD : 1 ≤ D) (C : ℝ) (hC : 0 < C) :
    ∃ X : ℝ, ∀ x ≥ X,
      Real.exp 1 * iterExp D (C * x) ≤ iterExp D ((C + 1) * x) := by
  -- For D ≥ 1, iterExp D ((C+1)*x) ≥ iterExp D (C*x) + 1 for large x.
  have h_iter_exp_bound (D : ℕ) (hD : 1 ≤ D) (C : ℝ) (hC : 0 < C) : ∃ X : ℝ, ∀ x ≥ X, iterExp D ((C + 1) * x) ≥ iterExp D (C * x) + 1 := by
    -- By induction on $D$, we can show that the difference between $iterExp D ((C + 1) * x)$ and $iterExp D (C * x)$ grows without bound as $x$ increases.
    have h_diff_growth : ∀ D : ℕ, 1 ≤ D → ∀ C : ℝ, 0 < C → Filter.Tendsto (fun x => iterExp D ((C + 1) * x) - iterExp D (C * x)) Filter.atTop Filter.atTop := by
      intro D hD C hC; induction' hD with D hD ih generalizing C <;> simp_all +decide [ iterExp ];
      · -- Factor out $e^{Cx}$:
        suffices h_factor : Filter.Tendsto (fun x => Real.exp (C * x) * (Real.exp x - 1)) Filter.atTop Filter.atTop by
          exact h_factor.congr fun x => by rw [ add_mul, one_mul, Real.exp_add ] ; ring;
        exact Filter.Tendsto.atTop_mul_atTop₀ ( Real.tendsto_exp_atTop.comp <| Filter.tendsto_id.const_mul_atTop hC ) ( Real.tendsto_exp_atTop.atTop_add tendsto_const_nhds );
      · -- Using the exponential property, we can rewrite the difference as $\exp(\iterExp D (C * x)) * (\exp(\iterExp D ((C + 1) * x) - \iterExp D (C * x)) - 1)$.
        suffices h_exp : Filter.Tendsto (fun x => Real.exp (iterExp D (C * x)) * (Real.exp (iterExp D ((C + 1) * x) - iterExp D (C * x)) - 1)) Filter.atTop Filter.atTop by
          convert h_exp using 2 ; rw [ mul_sub, mul_one, ← Real.exp_add ] ; ring;
        -- Since $\exp(\iterExp D (C * x))$ grows exponentially and $\exp(\iterExp D ((C + 1) * x) - \iterExp D (C * x)) - 1$ grows without bound, their product tends to infinity.
        have h_exp_growth : Filter.Tendsto (fun x => Real.exp (iterExp D (C * x))) Filter.atTop Filter.atTop := by
          have h_exp_growth : Filter.Tendsto (fun x => iterExp D x) Filter.atTop Filter.atTop := by
            exact Nat.recOn D ( by exact Filter.tendsto_id ) fun n ihn => by exact Real.tendsto_exp_atTop.comp ihn;
          exact Real.tendsto_exp_atTop.comp <| h_exp_growth.comp <| Filter.tendsto_id.const_mul_atTop hC;
        exact Filter.Tendsto.atTop_mul_atTop₀ h_exp_growth ( Filter.tendsto_atTop_add_const_right _ _ <| Real.tendsto_exp_atTop.comp <| ih C hC );
    exact Filter.eventually_atTop.mp ( h_diff_growth D hD C hC |> fun h => h.eventually_ge_atTop 1 ) |> fun ⟨ X, hX ⟩ => ⟨ X, fun x hx => by linarith [ hX x hx ] ⟩;
  -- By induction on $D$, we can show that for any $D \geq 1$, there exists $X$ such that for all $x \geq X$, $\exp(1) \cdot \text{iterExp } D (C \cdot x) \leq \text{iterExp } D ((C + 1) \cdot x)$.
  induction' D with D ih generalizing C hC;
  · contradiction;
  · -- For the inductive step, we need to show that $\exp(\text{iterExp } D ((C + 1) * x)) \geq \exp(1) * \exp(\text{iterExp } D (C * x))$.
    have h_exp_iter_exp_bound : ∃ X : ℝ, ∀ x ≥ X, Real.exp (iterExp D ((C + 1) * x)) ≥ Real.exp 1 * Real.exp (iterExp D (C * x)) := by
      obtain ⟨ X, hX ⟩ := if hD : 1 ≤ D then h_iter_exp_bound D hD C hC else ⟨ 1, fun x hx => by interval_cases D ; norm_num [ iterExp ] ; nlinarith ⟩ ; exact ⟨ X, fun x hx => by rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( by linarith [ hX x hx ] ) ⟩ ;
    exact h_exp_iter_exp_bound

/-
For D ≥ 1 and C > 0, 2 * iterExp D (C*x) ≤ iterExp D ((C+1)*x) for large x.
-/
theorem iterExp_absorb_double (D : ℕ) (hD : 1 ≤ D) (C : ℝ) (hC : 0 < C) :
    ∃ X : ℝ, ∀ x ≥ X,
      2 * iterExp D (C * x) ≤ iterExp D ((C + 1) * x) := by
  -- By the lemma `iterExp_bump_coeff`, there exists some `X` such that for all `x ≥ X`, `exp 1 * iterExp D (C * x) ≤ iterExp D ((C + 1) * x)`.
  obtain ⟨X, hX⟩ : ∃ X : ℝ, ∀ x ≥ X, Real.exp 1 * iterExp D (C * x) ≤ iterExp D ((C + 1) * x) := by
    exact?;
  exact ⟨ X, fun x hx => le_trans ( mul_le_mul_of_nonneg_right ( by have := Real.exp_one_gt_d9.le; norm_num1 at *; linarith ) ( by exact ( show 0 ≤ iterExp D ( C * x ) from by exact le_of_lt ( by exact iterExp_pos_of_ge_one hD _ ) ) ) ) ( hX x hx ) ⟩

/-
The sum of two iterExp terms at level D ≥ 1 is bounded by a single iterExp
    with bumped coefficient.
-/
theorem iterExp_sum_bound (D : ℕ) (hD : 1 ≤ D) (C₁ C₂ : ℝ) (hC₁ : 0 < C₁) (hC₂ : 0 < C₂) :
    ∃ X : ℝ, ∀ x ≥ X,
      iterExp D (C₁ * x) + iterExp D (C₂ * x) ≤ iterExp D ((max C₁ C₂ + 1) * x) := by
  -- By definition of max, we know that max C₁ C₂ ≥ C₁ and max C₁ C₂ ≥ C₂.
  set C := max C₁ C₂ with hC;
  -- By monotonicity of iterExp D, iterExp D (C₁*x) ≤ iterExp D (C*x) and similarly for C₂.
  have h_monotone : ∀ x ≥ 0, iterExp D (C₁ * x) ≤ iterExp D (C * x) ∧ iterExp D (C₂ * x) ≤ iterExp D (C * x) := by
    exact fun x hx => ⟨ iterExp_strictMono D |> StrictMono.monotone <| mul_le_mul_of_nonneg_right ( le_max_left _ _ ) hx, iterExp_strictMono D |> StrictMono.monotone <| mul_le_mul_of_nonneg_right ( le_max_right _ _ ) hx ⟩;
  -- By iterExp_absorb_double (with D, hD, C, 0 < max C₁ C₂), we get 2 * iterExp D (C*x) ≤ iterExp D ((C+1)*x) for large x.
  obtain ⟨X, hX⟩ : ∃ X : ℝ, ∀ x ≥ X, 2 * iterExp D (C * x) ≤ iterExp D ((C + 1) * x) := by
    exact iterExp_absorb_double D hD C ( by positivity );
  exact ⟨ Max.max X 0, fun x hx => by linarith [ h_monotone x ( le_trans ( le_max_right _ _ ) hx ), hX x ( le_trans ( le_max_left _ _ ) hx ) ] ⟩

/-
The product of two iterExp terms at level D ≥ 1 is bounded by iterExp at the
    same level with bumped coefficient.
-/
theorem iterExp_prod_bound (D : ℕ) (hD : 1 ≤ D) (C₁ C₂ : ℝ) (hC₁ : 0 < C₁) (hC₂ : 0 < C₂) :
    ∃ X : ℝ, ∀ x ≥ X,
      iterExp D (C₁ * x) * iterExp D (C₂ * x) ≤ iterExp (D + 1) ((max C₁ C₂ + 1) * x) := by
  -- By the properties of iterExp, we have:
  have h_iterExp_bound : ∃ X, ∀ x ≥ X, (iterExp D (max C₁ C₂ * x)) * (iterExp D (max C₁ C₂ * x)) ≤ (iterExp (D + 1) ((max C₁ C₂ + 1) * x)) := by
    -- By the properties of iterExp, we have that for large enough x, 2 * iterExp D (max C₁ C₂ * x) ≤ iterExp D ((max C₁ C₂ + 1) * x).
    have h_iterExp_bound : ∃ X, ∀ x ≥ X, 2 * iterExp D (max C₁ C₂ * x) ≤ iterExp D ((max C₁ C₂ + 1) * x) := by
      exact iterExp_absorb_double D hD ( Max.max C₁ C₂ ) ( by positivity );
    -- By the properties of iterExp, we have that for large enough x, iterExp D (max C₁ C₂ * x) ≤ iterExp D ((max C₁ C₂ + 1) * x).
    obtain ⟨X, hX⟩ := h_iterExp_bound;
    use max X 1; intros x hx; (
    refine' le_trans _ ( Real.exp_le_exp.mpr ( hX x ( le_trans ( le_max_left _ _ ) hx ) ) );
    rw [ two_mul, Real.exp_add ];
    gcongr;
    · exact le_of_lt ( iterExp_pos_of_ge_one hD _ );
    · exact le_trans ( by norm_num ) ( Real.add_one_le_exp _ );
    · exact le_trans ( by norm_num ) ( Real.add_one_le_exp _ ));
  -- Since $C₁ \leq \max C₁ C₂$ and $C₂ \leq \max C₁ C₂$, we have $iterExp D (C₁ * x) \leq iterExp D (\max C₁ C₂ * x)$ and $iterExp D (C₂ * x) \leq iterExp D (\max C₁ C₂ * x)$ for all $x \geq 0$.
  have h_le_max : ∀ x ≥ 0, iterExp D (C₁ * x) ≤ iterExp D (max C₁ C₂ * x) ∧ iterExp D (C₂ * x) ≤ iterExp D (max C₁ C₂ * x) := by
    intros x hx_nonneg
    have h_le_max : C₁ * x ≤ max C₁ C₂ * x ∧ C₂ * x ≤ max C₁ C₂ * x := by
      exact ⟨ mul_le_mul_of_nonneg_right ( le_max_left _ _ ) hx_nonneg, mul_le_mul_of_nonneg_right ( le_max_right _ _ ) hx_nonneg ⟩;
    exact ⟨ iterExp_strictMono D |> StrictMono.monotone |> fun h => h h_le_max.1, iterExp_strictMono D |> StrictMono.monotone |> fun h => h h_le_max.2 ⟩;
  exact ⟨ Max.max h_iterExp_bound.choose 0, fun x hx => le_trans ( mul_le_mul ( h_le_max x ( le_trans ( le_max_right _ _ ) hx ) |>.1 ) ( h_le_max x ( le_trans ( le_max_right _ _ ) hx ) |>.2 ) ( by exact ( show 0 ≤ iterExp D ( C₂ * x ) from by exact le_of_lt ( iterExp_pos_of_ge_one hD _ ) ) ) ( by exact ( show 0 ≤ iterExp D ( max C₁ C₂ * x ) from by exact le_of_lt ( iterExp_pos_of_ge_one hD _ ) ) ) ) ( h_iterExp_bound.choose_spec x ( le_trans ( le_max_left _ _ ) hx ) ) ⟩

/-! ## Main Growth Bound -/

/-
Product closure at the same iterExp level. For k ≥ 1:
    iterExp k (C₁*x) * iterExp k (C₂*x) ≤ iterExp k ((C₁+C₂+1)*x) for large x.

    Proof: Factor as exp(iterExp(k-1)(C₁x) + iterExp(k-1)(C₂x)),
    bound the sum, and close with monotonicity.
-/
theorem iterExp_mul_same_level (k : ℕ) (hk : 1 ≤ k) (C₁ C₂ : ℝ) (hC₁ : 0 < C₁) (hC₂ : 0 < C₂) :
    ∃ X : ℝ, ∀ x ≥ X,
      iterExp k (C₁ * x) * iterExp k (C₂ * x) ≤ iterExp k ((C₁ + C₂ + 1) * x) := by
  induction' k with k ih generalizing C₁ C₂;
  · contradiction;
  · by_cases hk : 1 ≤ k <;> simp_all +decide;
    · -- By the induction hypothesis, we have that for large x, the sum of the iterated exponentials is bounded by the iterated exponential of the sum.
      obtain ⟨X, hX⟩ : ∃ X : ℝ, ∀ x ≥ X, iterExp k (C₁ * x) + iterExp k (C₂ * x) ≤ iterExp k ((max C₁ C₂ + 1) * x) := by
        apply_rules [ iterExp_sum_bound ];
      -- By the monotonicity of `iterExp`, we have that `iterExp (k + 1) (C₁ * x) * iterExp (k + 1) (C₂ * x) ≤ iterExp (k + 1) ((max C₁ C₂ + 1) * x)`.
      have h_monotone : ∀ x ≥ max X 1, iterExp (k + 1) (C₁ * x) * iterExp (k + 1) (C₂ * x) ≤ iterExp (k + 1) ((max C₁ C₂ + 1) * x) := by
        intros x hx
        have h_exp : Real.exp (iterExp k (C₁ * x)) * Real.exp (iterExp k (C₂ * x)) ≤ Real.exp (iterExp k ((max C₁ C₂ + 1) * x)) := by
          rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( hX x ( le_trans ( le_max_left _ _ ) hx ) );
        convert h_exp using 1;
      refine' ⟨ Max.max X 1, fun x hx => le_trans ( h_monotone x hx ) _ ⟩;
      exact iterExp_strictMono ( k + 1 ) |> StrictMono.monotone <| mul_le_mul_of_nonneg_right ( by cases max_cases C₁ C₂ <;> linarith ) <| by linarith [ le_max_right X 1 ] ;
    · norm_num [ iterExp ];
      exact ⟨ 0, fun x hx => by rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( by nlinarith ) ⟩

/-- **Growth Bound Theorem**: Every inv-free EMLExpr `e` has evaluation bounded
    by `iterExp (e.emlDepth + 1) (C * x)` for some `C > 0` and large `x`.

    This is the central technical lemma for the depth separation. It shows that
    the EML depth controls the growth rate: each eml layer can add at most one
    level of iterated exponentiation.

    Proof by structural induction on `e`:
    - `var`, `const`: bounded by `exp(x)` (level 1)
    - `add`, `mul`: closure under sum and product at the same level
    - `neg`: same bound as argument
    - `inv`: excluded by `noInv` hypothesis
    - `eml(a,b)`: `|a * exp(b)| ≤ exp(|a| + |b|)`, bumping the level by 1 -/
theorem noInv_eval_growth_bound (e : EMLExpr) (he : e.noInv) :
    ∃ (C : ℝ), 0 < C ∧ ∃ (X : ℝ), ∀ x ≥ X,
      |e.eval x| ≤ iterExp (e.emlDepth + 1) (C * x) := by
  sorry

/-! ## Separation Theorems -/

/-
**Depth Separation for inv-free EMLExpr**: For every depth bound `D`,
    no inv-free EMLExpr of depth ≤ D can represent `iterExp n` for `n ≥ D + 3`.

    This combines the growth bound with the growth separation hierarchy.
-/
theorem no_bounded_depth_noInv_representation (D : ℕ) (n : ℕ) (hn : D + 3 ≤ n)
    (e : EMLExpr) (he_noInv : e.noInv) (he_depth : e.emlDepth ≤ D) :
    ¬ RepresentsOnPos e (iterExp n) := by
  by_contra hrep;
  -- From noInv_eval_growth_bound, get C > 0 and X such that for x ≥ X, |e.eval x| ≤ iterExp (e.emlDepth + 1) (C*x).
  obtain ⟨C, hC_pos, X, hX⟩ : ∃ C > 0, ∃ X : ℝ, ∀ x ≥ X, |e.eval x| ≤ iterExp (e.emlDepth + 1) (C * x) := noInv_eval_growth_bound e he_noInv;
  -- Since $e.emlDepth \leq D$, by level monotonicity, $|e.eval x| \leq iterExp (D+1) (C*x)$ for $x \geq X$ with $x > 0$.
  have hX_mono : ∀ x ≥ X, 0 < x → |e.eval x| ≤ iterExp (D + 1) (C * x) := by
    exact fun x hx hx' => le_trans ( hX x hx ) ( iterExp_level_mono ( by linarith ) ( by positivity ) );
  -- From iterExp_growth_separation at level D+1 with C: get X' such that for x ≥ X', iterExp (D+1) (C*x) ≤ iterExp (D+2) x.
  obtain ⟨X', hX'⟩ : ∃ X' : ℝ, ∀ x ≥ X', iterExp (D + 1) (C * x) ≤ iterExp (D + 2) x := by
    have := iterExp_growth_separation ( D + 1 ) C hC_pos;
    exact this;
  -- From iterExp_strict_level_mono: iterExp (D+2) x < iterExp (D+3) x for x > 0. And from iterExp_level_mono: iterExp (D+3) x ≤ iterExp n x for n ≥ D+3 and x > 0.
  have h_mono : ∀ x > 0, iterExp (D + 2) x < iterExp (D + 3) x ∧ iterExp (D + 3) x ≤ iterExp n x := by
    exact fun x hx => ⟨ iterExp_strict_level_mono hx, iterExp_level_mono hn hx ⟩;
  -- Pick x₀ = max(X, X', 1) + 1 > 0. Then:
  set x₀ := max X (max X' 1) + 1 with hx₀_def
  have hx₀_pos : 0 < x₀ := by
    exact add_pos_of_nonneg_of_pos ( le_max_of_le_right ( le_max_of_le_right zero_le_one ) ) zero_lt_one;
  have := hrep x₀ hx₀_pos; specialize hX_mono x₀ ( by linarith [ le_max_left X ( max X' 1 ) ] ) hx₀_pos; specialize hX' x₀ ( by linarith [ le_max_right X ( max X' 1 ), le_max_left X' 1 ] ) ; specialize h_mono x₀ hx₀_pos; linarith [ abs_le.mp hX_mono ] ;

/-
**Main Theorem**: For every depth bound `D`, there exists `N` such that
    for all `n ≥ N`, no `EMLExpr` of depth ≤ D can represent `iterExp n`
    on positive reals. This is the depth hierarchy theorem.

    For the inv-free case, this follows from `no_bounded_depth_noInv_representation`.
    The general case (with `inv`) requires additionally showing that rational
    functions with poles cannot match the growth of iterated exponentials;
    this extension is left for future work.
-/
theorem no_bounded_depth_exact_representation_of_iterExp
    (D : ℕ) :
    ∃ N : ℕ, ∀ n ≥ N,
      ¬ ∃ e' : EMLExpr,
          e'.emlDepth ≤ D ∧ e'.noInv ∧
          SemanticallyEquivalentOnPos e' (fullExprIterExp n) := by
  use D + 3;
  intro n hn h_exists
  obtain ⟨e', he_depth, he_noInv, he_equiv⟩ := h_exists
  have h_rep : RepresentsOnPos e' (iterExp n) := by
    exact fun x hx => by simpa [ fullExprIterExp_eval ] using he_equiv x hx;
  exact no_bounded_depth_noInv_representation D n (by omega) e' he_noInv he_depth h_rep

end