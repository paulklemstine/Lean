/-
# EML Depth Separation — Core Theorems

This file contains the core theorems establishing a depth hierarchy for
exact expression languages. We prove:

1. **Structural bound**: `expRank ≤ emlDepth` (by structural induction)
2. **Canonical evaluation**: correctness of canonical constructions
3. **Growth hierarchy**: iterated exponentials form a strict growth hierarchy
4. **Polynomial bound**: depth-0 EML expressions have polynomial growth
5. **Base separation**: depth-0 EML cannot represent `exp`
6. **Cross-domain connection**: circuit complexity analogy

## Proof Techniques

The proofs use structural induction on expression trees, monotonicity
of `Real.exp`, eventual domination arguments, and contradiction via
asymptotic growth comparison. These are the expression-language analogues
of standard techniques in bounded-depth circuit complexity.
-/
import Speculative.EMLDepthSeparation.Defs

noncomputable section

open Real Filter

/-! ## Section 1: Structural Bounds -/

/-
**Theorem 1 (Structural Bound)**: The exponential rank of any EML expression
    is bounded by its EML depth. This is the syntactic half of the depth
    separation: each `eml` layer can increase exponential nesting by at most 1.

    Proof by structural induction on `e`, using that field operations
    preserve the max rank while `eml` increases it by exactly 1.

    This is analogous to the fact that each layer of a bounded-depth circuit
    can only increase the "complexity" by a bounded amount.
-/
theorem EMLExpr.expRank_le_emlDepth (e : EMLExpr) : e.expRank ≤ e.emlDepth := by
  -- We will prove this by structural induction on `e`.
  induction' e with a b ih_a ih_b;
  all_goals repeat' first | rfl | simp_all +decide [ EMLExpr.expRank, EMLExpr.emlDepth ];
  · grind;
  · grind +revert;
  · grind

/-
EML depth equals 0 iff there are no eml nodes.
-/
theorem EMLExpr.emlDepth_eq_zero_iff_noEml (e : EMLExpr) :
    e.emlDepth = 0 ↔ e.noEml := by
  -- We'll use induction on the structure of `e`.
  induction' e with e ih;
  all_goals simp_all +decide [ EMLExpr.noEml, EMLExpr.emlDepth ] ;

/-! ## Section 2: Canonical Constructions -/

/-
The canonical `FullExpr` for `iterExp n` evaluates correctly.
-/
theorem fullExprIterExp_eval (n : ℕ) (x : ℝ) :
    (fullExprIterExp n).eval x = iterExp n x := by
  induction' n with n ih generalizing x;
  · rfl;
  · exact congr_arg _ ( ih x )

/-
The canonical `FullExpr` for `iterExp n` has depth exactly `n`.
-/
theorem fullExprIterExp_depth (n : ℕ) :
    (fullExprIterExp n).depth = n := by
  induction' n with n ih;
  · rfl;
  · exact show 1 + ( fullExprIterExp n |> FullExpr.depth ) = n + 1 from by rw [ ih ] ; ring;

/-
The canonical `EMLExpr` for `iterExp n` evaluates correctly.
-/
theorem emlExprIterExp_eval (n : ℕ) (x : ℝ) :
    (emlExprIterExp n).eval x = iterExp n x := by
  induction' n with n ih generalizing x;
  · rfl;
  · convert congr_arg ( fun y => 1 * Real.exp y ) ( ih x ) using 1;
    simp +decide [ iterExp ]

/-
The canonical `EMLExpr` for `iterExp n` has `emlDepth` exactly `n`.
-/
theorem emlExprIterExp_emlDepth (n : ℕ) :
    (emlExprIterExp n).emlDepth = n := by
  induction' n with n ih;
  · rfl;
  · exact show 1 + Max.max 0 ( emlExprIterExp n |> EMLExpr.emlDepth ) = n + 1 from by simp +arith +decide [ ih ] ;

/-! ## Section 3: Iterated Exponential Properties -/

/-
Iterated exponentials are strictly monotone.
-/
theorem iterExp_strictMono (n : ℕ) : StrictMono (iterExp n) := by
  induction' n with n ih;
  · exact strictMono_id;
  · exact Real.exp_strictMono.comp ih

/-
Iterated exponentials are positive on positive inputs.
-/
theorem iterExp_pos (n : ℕ) {x : ℝ} (hx : 0 < x) : 0 < iterExp n x := by
  exact Nat.recOn n hx fun n ih => Real.exp_pos _

/-
For `n ≥ 1`, `iterExp n x` is positive for all `x`.
-/
theorem iterExp_pos_of_ge_one {n : ℕ} (hn : 1 ≤ n) (x : ℝ) :
    0 < iterExp n x := by
  induction hn <;> simp_all +decide [ iterExp ];
  · positivity;
  · positivity

/-
**Theorem 2 (Growth Hierarchy)**: `iterExp` is strictly increasing in its
    level for positive inputs. Each additional layer of iterated exponentiation
    produces strictly faster growth.

    This is proved by induction on the level difference, using the fact that
    `exp(t) > t` for all `t`, which gives `iterExp (n+1) x = exp(iterExp n x) > iterExp n x`.

    In the circuit complexity analogy, this corresponds to the fact that
    the "hard functions" at each level of the hierarchy are strictly harder
    than those at the previous level.
-/
theorem iterExp_strict_level_mono {n : ℕ} {x : ℝ} (hx : 0 < x) :
    iterExp n x < iterExp (n + 1) x := by
  exact Real.add_one_le_exp _ |> lt_of_lt_of_le ( by linarith )

/-
Iterated exponentials are monotone in level.
-/
theorem iterExp_level_mono {n m : ℕ} (hnm : n ≤ m) {x : ℝ} (hx : 0 < x) :
    iterExp n x ≤ iterExp m x := by
  exact Nat.le_induction ( by rfl ) ( fun k hk ih => le_trans ih ( le_of_lt ( iterExp_strict_level_mono hx ) ) ) m hnm

/-
For `n ≥ 1`, `iterExp n x ≥ exp(x)`.
-/
theorem iterExp_ge_exp {n : ℕ} (hn : 1 ≤ n) {x : ℝ} (hx : 0 < x) :
    Real.exp x ≤ iterExp n x := by
  induction hn <;> simp_all +decide [ iterExp ];
  linarith [ Real.add_one_le_exp x ]

/-! ## Section 4: Polynomial Growth Bound for Depth-0 -/

/-
Coefficient bounds are positive.
-/
theorem EMLExpr.coefBound_pos (e : EMLExpr) : 0 < e.coefBound := by
  induction e <;> norm_num [ EMLExpr.coefBound ];
  exacts [ by positivity, by positivity, by positivity, by assumption, by assumption, Or.inl ( by assumption ) ]

/-
**Theorem 3 (Polynomial Bound)**: Inv-free, eml-free expressions have
    polynomial growth. For any such expression `e` and `x ≥ 1`:

      `|e.eval x| ≤ e.coefBound * x ^ e.polyDeg`

    This is proved by structural induction on `e`:
    - `var`: `|x| = x ≤ 1 · x¹`
    - `const c`: `|c| ≤ (|c|+1) · x⁰`
    - `add`: triangle inequality + max of degrees
    - `mul`: product of bounds + sum of degrees
    - `neg`: same bound as argument

    The polynomial growth bound is the key to showing that depth-0 EML
    cannot represent exponentially-growing functions. This is analogous to
    the AC⁰ lower bound: constant-depth circuits with AND/OR/NOT gates
    cannot compute PARITY. Here, field operations alone cannot produce
    exponential growth.

    **Cross-domain connection to circuit complexity**:
    Just as AC⁰ circuits compute only functions with bounded Fourier degree,
    depth-0 EML expressions compute only functions with polynomial growth,
    establishing a formal analogy between circuit depth and expression depth.
-/
theorem EMLExpr.eval_le_poly_bound (e : EMLExpr) (he_noInv : e.noInv) (he_noEml : e.noEml)
    (x : ℝ) (hx : 1 ≤ x) :
    |e.eval x| ≤ e.coefBound * x ^ e.polyDeg := by
  induction' e with e₁ e₂ ih₁ ih₂;
  all_goals norm_num [ EMLExpr.eval, EMLExpr.noInv, EMLExpr.noEml ] at *;
  · norm_num [ abs_of_nonneg ( by positivity : 0 ≤ x ), EMLExpr.coefBound, EMLExpr.polyDeg ];
  · exact le_trans ( le_add_of_nonneg_right zero_le_one ) ( le_mul_of_one_le_right ( by positivity ) ( one_le_pow₀ hx ) );
  · -- Apply the triangle inequality to the sum.
    have h_triangle : |e₂.eval x + ih₁.eval x| ≤ |e₂.eval x| + |ih₁.eval x| := by
      exact?;
    refine le_trans h_triangle <| le_trans ( add_le_add ( ih₂ he_noInv.1 he_noEml.1 ) ( ‹ih₁.noInv → ih₁.noEml → |ih₁.eval x| ≤ ih₁.coefBound * x ^ ih₁.polyDeg› he_noInv.2 he_noEml.2 ) ) ?_;
    rw [ show ( e₂.add ih₁ ).coefBound = e₂.coefBound + ih₁.coefBound by rfl, show ( e₂.add ih₁ ).polyDeg = max e₂.polyDeg ih₁.polyDeg by rfl ];
    rw [ add_mul ];
    exact add_le_add ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( le_max_left _ _ ) ) ( by exact le_of_lt ( EMLExpr.coefBound_pos _ ) ) ) ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( le_max_right _ _ ) ) ( by exact le_of_lt ( EMLExpr.coefBound_pos _ ) ) );
  · rename_i a b ha hb;
    convert mul_le_mul ( ha he_noInv.1 he_noEml.1 ) ( hb he_noInv.2 he_noEml.2 ) ( by positivity ) ( by exact mul_nonneg ( by exact le_of_lt ( EMLExpr.coefBound_pos _ ) ) ( by positivity ) ) using 1 ; ring!;
    rw [ show ( a.mul b ).coefBound = a.coefBound * b.coefBound by rfl, show ( a.mul b ).polyDeg = a.polyDeg + b.polyDeg by rfl ] ; ring;
  · convert ‹ ( _ : EMLExpr ).noInv → ( _ : EMLExpr ).noEml → _› he_noInv he_noEml using 1

/-
`exp(x)` eventually exceeds any polynomial bound. This is the analytic
    foundation for the depth separation: no polynomial can match `exp`'s growth.
-/
theorem exp_eventually_exceeds_poly (C : ℝ) (N : ℕ) :
    ∃ x₀ : ℝ, 1 < x₀ ∧ C * x₀ ^ N < Real.exp x₀ := by
  -- Use `Real.tendsto_exp_div_pow_atTop N` to get that `exp(x)/x^N → ∞`.
  have h_tendsto : Filter.Tendsto (fun x : ℝ => Real.exp x / x ^ N) Filter.atTop Filter.atTop := by
    exact Real.tendsto_exp_div_pow_atTop _;
  have := h_tendsto.eventually_gt_atTop ( Max.max C 1 );
  rw [ Filter.eventually_atTop ] at this; rcases this with ⟨ M, hM ⟩ ; exact ⟨ Max.max M 2, by norm_num, by have := hM ( Max.max M 2 ) ( le_max_left _ _ ) ; rw [ lt_div_iff₀ ] at this <;> nlinarith [ le_max_right M 2, le_max_left M 2, le_max_right C 1, le_max_left C 1, pow_pos ( by linarith [ le_max_right M 2, le_max_left M 2 ] : 0 < Max.max M 2 ) N ] ⟩ ;

/-! ## Section 5: Base Case Separation -/

/-
**Theorem 4 (Base Separation)**: No inv-free, eml-free EML expression can
    represent `iterExp n` for `n ≥ 1` on positive reals.

    Proof: By the polynomial bound theorem, such expressions grow at most
    polynomially. But `iterExp n` for `n ≥ 1` grows at least as fast as `exp(x)`,
    which eventually exceeds any polynomial. Contradiction.

    This establishes the base case of the depth hierarchy: even the simplest
    transcendental function `exp(x)` escapes the expressive power of
    pure field operations.
-/
theorem EMLExpr.noInv_noEml_ne_iterExp (e : EMLExpr) (he_noInv : e.noInv) (he_noEml : e.noEml)
    {n : ℕ} (hn : 1 ≤ n) :
    ¬ RepresentsOnPos e (iterExp n) := by
  -- Obtain a threshold $x₀$ where $\exp(x₀)$ exceeds the polynomial bound of $e$.
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ : ℝ, 1 < x₀ ∧ e.coefBound * x₀ ^ e.polyDeg < Real.exp x₀ := by
    exact?;
  intro hrep
  have h_eval : e.eval x₀ = iterExp n x₀ := by
    exact hrep x₀ ( by linarith )
  have h_poly : |e.eval x₀| ≤ e.coefBound * x₀ ^ e.polyDeg := by
    exact EMLExpr.eval_le_poly_bound e he_noInv he_noEml x₀ hx₀.1.le
  have h_exp : Real.exp x₀ ≤ iterExp n x₀ := by
    exact iterExp_ge_exp hn ( by linarith )
  linarith [abs_le.mp h_poly]

/-! ## Section 6: Growth Rank Properties -/

/-
`iterExp n` has growth rank at least `n` on positive reals.
    This means the iterated exponential family witnesses every level
    of the growth hierarchy, confirming that the hierarchy is strict.
-/
theorem iterExp_has_growth_rank (n : ℕ) :
    HasGrowthRankAtLeast (iterExp n) n := by
  refine' ⟨ 1, by norm_num, 1, fun x hx => _ ⟩;
  norm_num

/-
The growth hierarchy is strict: `iterExp (n+1)` eventually dominates
    `iterExp n` with any linear scaling.
-/
theorem iterExp_growth_separation (n : ℕ) (C : ℝ) (hC : 0 < C) :
    EventuallyDominates (iterExp (n + 1)) (fun x => iterExp n (C * x)) := by
  have h_ind : ∀ k : ℕ, ∃ X : ℝ, ∀ x ≥ X, iterExp k (C * x) ≤ iterExp (k + 1) x := by
    intro k
    induction' k with k ih;
    · -- For the base case $k = 0$, we need to show that $C * x \leq \exp(x)$ for sufficiently large $x$.
      have h_base : ∃ X : ℝ, ∀ x ≥ X, C * x ≤ Real.exp x := by
        have h_exp_growth : Filter.Tendsto (fun x => Real.exp x / x) Filter.atTop Filter.atTop := by
          simpa using Real.tendsto_exp_div_pow_atTop 1;
        exact Filter.eventually_atTop.mp ( h_exp_growth.eventually_ge_atTop C ) |> fun ⟨ X, hX ⟩ ↦ ⟨ Max.max X 1, fun x hx ↦ by have := hX x ( le_trans ( le_max_left _ _ ) hx ) ; rw [ le_div_iff₀ ] at this <;> linarith [ le_max_right X 1 ] ⟩;
      exact h_base;
    · exact Exists.elim ih fun X hX => ⟨ X, fun x hx => Real.exp_le_exp.mpr ( hX x hx ) ⟩ ;
  exact h_ind n

/-! ## Section 7: Main Separation Theorem -/

-- The main depth separation theorem is in Separation.lean.

/-! ## Section 8: Falsifiable Conjecture -/

/-- **Falsifiable Conjecture**: For fixed depth `D = 3`, the minimal size of an
    `EMLExpr` of depth at most 3 representing `iterExp n` on positive reals
    grows at least exponentially in `n`.

    More precisely, we conjecture that for large enough `n`, the minimal
    such size exceeds `2^n`.

    **Computational test**: For `n ∈ {1, ..., 10}`, enumerate depth-3
    `EMLExpr` candidates up to increasing size bounds. If a sublinear
    (e.g., polynomial) fit consistently explains the minimal sizes,
    this conjecture is refuted. The demo.py file implements this search.

    Note: The conjecture is vacuously true for `n > 3` if our main
    separation theorem holds, since no finite-size depth-3 expression
    can represent `iterExp n` for `n > 3`. The interest is in the
    quantitative size growth for `n ≤ 3`. -/
def MinSizeAtDepth (D : ℕ) (f : ℝ → ℝ) : ℕ :=
  sInf {m | ∃ e' : EMLExpr, e'.emlDepth ≤ D ∧ e'.size = m ∧ RepresentsOnPos e' f}

/-! ## Section 9: Asymptotic Profile Construction -/

/-
`iterExp n` for `n ≥ 1` has a valid asymptotic profile: it is eventually
    positive and eventually monotone on `[0, ∞)`.
-/
theorem iterExp_asymptotic_profile (n : ℕ) (hn : 1 ≤ n) :
    ∃ p : AsymptoticProfile, p.f = iterExp n := by
  exact ⟨ ⟨ iterExp n, 0, fun x hx => iterExp_pos_of_ge_one hn x, fun x hx y hy hxy => by simpa using iterExp_strictMono n |> StrictMono.monotone <| by simpa using hxy ⟩, rfl ⟩

end