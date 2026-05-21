import Speculative.HardyHierarchy.Defs

/-!
# Hardy Field Hierarchy — Main Theorems

## Main Results

1. **`EventuallyEq'.trans`**: transitivity of eventual equality
2. **`hardyLevel_mono`**: monotonicity — level `m` implies level `n` for `m ≤ n`
3. **`hardyLevel_neg`**: negation preserves Hardy level
4. **`iterExp_mem_hardyLevel`**: `iterExp n` belongs to Hardy level `n`
5. **`emlDepth_le_hardyLevel`**: every EML expression lives in Hardy level `emlDepth e`
6. **`hardyLevel_closed_under_eml`**: `eml(a,b) = a * exp(b)` raises level by 1
7. **`growthRank_sound`**: `growthRank` is sound for the Hardy hierarchy
8. **`growthRank_iterExp`**: canonical `iterExp n` expression has `growthRank = n`
9. **`hardyLevel_zero_poly_bound`**: level-0 functions have polynomial growth
10. **`iterExp_pos_of_succ`**: `iterExp (n+1)` is always positive
11. **`iterExp_strictMono`**: `iterExp n` is strictly monotone
12. **`emlExprIterExp_eval`**: canonical EML expression evaluates to `iterExp n`
13. **`emlExprIterExp_emlDepth`**: canonical EML expression has `emlDepth = n`
-/

noncomputable section

open Real Filter

/-! ## EventuallyEq' properties -/

theorem EventuallyEq'.refl (f : ℝ → ℝ) : EventuallyEq' f f :=
  ⟨0, fun _ _ => rfl⟩

theorem EventuallyEq'.symm {f g : ℝ → ℝ} (h : EventuallyEq' f g) : EventuallyEq' g f := by
  obtain ⟨A, hA⟩ := h
  exact ⟨A, fun x hx => (hA x hx).symm⟩

/-- Transitivity of eventual equality. -/
theorem EventuallyEq'.trans {f g h : ℝ → ℝ}
    (hfg : EventuallyEq' f g) (hgh : EventuallyEq' g h) : EventuallyEq' f h := by
  obtain ⟨A₁, hA₁⟩ := hfg
  obtain ⟨A₂, hA₂⟩ := hgh
  exact ⟨max A₁ A₂, fun x hx => by
    rw [hA₁ x (le_of_max_le_left hx), hA₂ x (le_of_max_le_right hx)]⟩

/-! ## Hardy Level: Constants and Monotonicity -/

/-- The zero constant is at every Hardy level. -/
private theorem hardyLevel_zero_const (n : ℕ) : HardyLevel n (fun _ => (0 : ℝ)) := by
  induction n with
  | zero => exact HardyLevel.base_const 0
  | succ n ih =>
    apply HardyLevel.congr (f := fun x => (fun _ => (0 : ℝ)) x * Real.exp ((fun _ => (0 : ℝ)) x))
    · exact HardyLevel.exp_step ih ih
    · exact ⟨0, fun x _ => by simp [Real.exp_zero]⟩

/-- Any constant function is at any Hardy level. -/
theorem hardyLevel_const (n : ℕ) (c : ℝ) : HardyLevel n (fun _ => c) := by
  induction n with
  | zero => exact HardyLevel.base_const c
  | succ n ih =>
    apply HardyLevel.congr (f := fun x => (fun _ => c) x * Real.exp ((fun _ => (0 : ℝ)) x))
    · exact HardyLevel.exp_step ih (hardyLevel_zero_const n)
    · exact ⟨0, fun x _ => by simp [Real.exp_zero]⟩

/-- **Monotonicity**: if `f` is at Hardy level `m`, then it is also at level `n ≥ m`. -/
theorem hardyLevel_mono {m n : ℕ} (hmn : m ≤ n) {f : ℝ → ℝ} (hf : HardyLevel m f) :
    HardyLevel n f := by
  induction hmn with
  | refl => exact hf
  | step _ ih =>
    apply HardyLevel.congr (f := fun x => f x * Real.exp ((fun _ => (0 : ℝ)) x))
    · exact HardyLevel.exp_step ih (hardyLevel_const _ 0)
    · exact ⟨0, fun x _ => by simp [Real.exp_zero]⟩

/-! ## Hardy Level: Closure Properties -/

/-- **Closure under eml**: `(a, b) ↦ a * exp(b)` raises Hardy level by one. -/
theorem hardyLevel_closed_under_eml {n : ℕ} {a b : ℝ → ℝ}
    (ha : HardyLevel n a) (hb : HardyLevel n b) :
    HardyLevel (n + 1) (fun x => a x * Real.exp (b x)) :=
  HardyLevel.exp_step ha hb

/-- Negation preserves Hardy level. -/
theorem hardyLevel_neg {n : ℕ} {f : ℝ → ℝ} (hf : HardyLevel n f) :
    HardyLevel n (fun x => -(f x)) := by
  apply HardyLevel.congr (f := fun x => (fun _ => (-1 : ℝ)) x * f x + (fun _ => (0 : ℝ)) x)
  · exact HardyLevel.add (HardyLevel.mul (hardyLevel_const n (-1)) hf) (hardyLevel_const n 0)
  · exact ⟨0, fun x _ => by ring⟩

/-- The identity is at every Hardy level. -/
theorem hardyLevel_id (n : ℕ) : HardyLevel n (fun x => x) :=
  hardyLevel_mono (Nat.zero_le n) HardyLevel.base_id

/-! ## Iterated Exponential Properties -/

/-- `iterExp (n+1)` is always positive. -/
theorem iterExp_pos_of_succ (n : ℕ) (x : ℝ) : 0 < iterExp (n + 1) x :=
  exp_pos _

/-- `iterExp n` is strictly monotone. -/
theorem iterExp_strictMono (n : ℕ) : StrictMono (iterExp n) := by
  induction n with
  | zero => exact strictMono_id
  | succ n ih => exact Real.exp_strictMono.comp ih

/-- `iterExp n` is positive on positive inputs. -/
theorem iterExp_pos' {n : ℕ} {x : ℝ} (hx : 0 < x) : 0 < iterExp n x := by
  induction n with
  | zero => exact hx
  | succ n _ => exact exp_pos _

/-! ## Canonical EML Construction -/

/-- The canonical EML expression for `iterExp n` evaluates correctly. -/
theorem emlExprIterExp_eval (n : ℕ) (x : ℝ) :
    (emlExprIterExp n).eval x = iterExp n x := by
  induction n with
  | zero => rfl
  | succ n ih =>
    simp only [emlExprIterExp, EmlExpr.eval, ih]
    simp [iterExp, one_mul]

/-- The canonical EML expression for `iterExp n` has `emlDepth` exactly `n`. -/
theorem emlExprIterExp_emlDepth (n : ℕ) :
    (emlExprIterExp n).emlDepth = n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    simp only [emlExprIterExp, EmlExpr.emlDepth, ih]
    omega

/-! ## Main Theorem: EML Depth Upper-Bounds Hardy Level -/

/-- **Main Theorem**: Every EML expression lives in Hardy level `emlDepth e`.

    This is proved by structural induction on the expression. The key step is
    the `eml` case: `eml(a,b) = a * exp(b)` maps to `exp_step`, which raises
    the level by exactly one. -/
theorem emlDepth_le_hardyLevel (e : EmlExpr) :
    HardyLevel (e.emlDepth) (e.eval) := by
  induction e with
  | var => exact HardyLevel.base_id
  | const c => exact HardyLevel.base_const c
  | add a b iha ihb =>
    exact HardyLevel.add
      (hardyLevel_mono (le_max_left _ _) iha)
      (hardyLevel_mono (le_max_right _ _) ihb)
  | mul a b iha ihb =>
    exact HardyLevel.mul
      (hardyLevel_mono (le_max_left _ _) iha)
      (hardyLevel_mono (le_max_right _ _) ihb)
  | neg a iha =>
    exact hardyLevel_neg iha
  | eml a b iha ihb =>
    show HardyLevel (1 + max a.emlDepth b.emlDepth) (fun x => a.eval x * Real.exp (b.eval x))
    rw [show 1 + max a.emlDepth b.emlDepth = max a.emlDepth b.emlDepth + 1 from Nat.add_comm _ _]
    exact HardyLevel.exp_step
      (hardyLevel_mono (le_max_left _ _) iha)
      (hardyLevel_mono (le_max_right _ _) ihb)

/-! ## iterExp in the Hardy Hierarchy -/

/-- **Theorem**: `iterExp n` belongs to Hardy level `n`.

    * Base: `iterExp 0 = id` is at level 0 by `base_id`.
    * Step: `iterExp (n+1) x = 1 * exp(iterExp n x)`, matching `exp_step`. -/
theorem iterExp_mem_hardyLevel (n : ℕ) : HardyLevel n (iterExp n) := by
  induction n with
  | zero => exact HardyLevel.base_id
  | succ n ih =>
    apply HardyLevel.congr
      (f := fun x => (fun _ => (1 : ℝ)) x * Real.exp (iterExp n x))
    · exact HardyLevel.exp_step (hardyLevel_const n 1) ih
    · exact ⟨0, fun x _ => by simp [iterExp, one_mul]⟩

/-! ## Connection to growthRank -/

/-- **Theorem**: `growthRank` is sound for the Hardy hierarchy. -/
theorem growthRank_sound (e : EmlExpr) :
    HardyLevel (growthRank e) (e.eval) :=
  emlDepth_le_hardyLevel e

/-- **Theorem**: the canonical `iterExp n` expression has `growthRank = n`
    and belongs to Hardy level `n`. -/
theorem growthRank_iterExp (n : ℕ) :
    growthRank (emlExprIterExp n) = n ∧
    HardyLevel (growthRank (emlExprIterExp n)) ((emlExprIterExp n).eval) := by
  refine ⟨emlExprIterExp_emlDepth n, ?_⟩
  rw [growthRank, emlExprIterExp_emlDepth]
  apply HardyLevel.congr (f := iterExp n)
  · exact iterExp_mem_hardyLevel n
  · exact ⟨0, fun x _ => (emlExprIterExp_eval n x).symm⟩

/-! ## Polynomial Growth Bound for Level 0 -/

/-
**Growth bound**: every function at Hardy level 0 has at most polynomial growth.
-/
theorem hardyLevel_zero_poly_bound {f : ℝ → ℝ} (hf : HardyLevel 0 f) :
    ∃ C : ℝ, ∃ d : ℕ, ∃ A : ℝ, ∀ x ≥ A, |f x| ≤ C * x ^ d := by
  contrapose! hf;
  -- We'll use induction on the structure of `HardyLevel`.
  have h_ind : ∀ {f : ℝ → ℝ} {n : ℕ}, HardyLevel n f → n = 0 → ∃ C d A, ∀ x ≥ A, |f x| ≤ C * x ^ d := by
    intros f n hf hn;
    induction' hf with n f g hf hg ihf ihg n f g hf hg ihf ihg n f g hf hg ihf ihg n f g hf hg ihf ihg n f g hf hg ihf ihg;
    all_goals norm_cast at *;
    · exact ⟨ 1, 1, 0, fun x hx => by norm_num [ abs_of_nonneg hx ] ⟩;
    · exact ⟨ |n|, 0, 0, fun x hx => by norm_num ⟩;
    · obtain ⟨ C₁, d₁, A₁, h₁ ⟩ := ihg hn
      obtain ⟨ C₂, d₂, A₂, h₂ ⟩ := n hn;
      use C₁ + C₂, max d₁ d₂, max A₁ (max A₂ 1);
      intros x hx
      have h_abs : |g x + hf x| ≤ |g x| + |hf x| := by
        grind +suggestions;
      simp +zetaDelta at *;
      exact le_trans h_abs ( by rw [ add_mul ] ; exact add_le_add ( le_trans ( h₁ x hx.1 ) ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx.2.2 ( le_max_left _ _ ) ) ( show 0 ≤ C₁ by exact le_of_not_gt fun h => by have := h₁ ( Max.max A₁ 1 ) ( le_max_left _ _ ) ; nlinarith [ abs_nonneg ( g ( Max.max A₁ 1 ) ), pow_pos ( by linarith [ le_max_right A₁ 1 ] : 0 < Max.max A₁ 1 ) d₁ ] ) ) ) ( le_trans ( h₂ x hx.2.1 ) ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx.2.2 ( le_max_right _ _ ) ) ( show 0 ≤ C₂ by exact le_of_not_gt fun h => by have := h₂ ( Max.max A₂ 1 ) ( le_max_left _ _ ) ; nlinarith [ abs_nonneg ( ‹ℝ → ℝ› ( Max.max A₂ 1 ) ), pow_pos ( by linarith [ le_max_right A₂ 1 ] : 0 < Max.max A₂ 1 ) d₂ ] ) ) ) );
    · obtain ⟨ C₁, d₁, A₁, h₁ ⟩ := ihg hn
      obtain ⟨ C₂, d₂, A₂, h₂ ⟩ := n hn;
      use C₁ * C₂, d₁ + d₂, max A₁ A₂;
      intro x hx; rw [ abs_mul ] ; convert mul_le_mul ( h₁ x ( le_trans ( le_max_left _ _ ) hx ) ) ( h₂ x ( le_trans ( le_max_right _ _ ) hx ) ) ( by positivity ) ( by
        exact le_trans ( abs_nonneg _ ) ( h₁ x ( le_trans ( le_max_left _ _ ) hx ) ) ) using 1 ; ring;
    · obtain ⟨ C, d, A, hC ⟩ := ihg hn;
      obtain ⟨ B, hB ⟩ := ihf;
      exact ⟨ C, d, Max.max A B, fun x hx => by rw [ ← hB x ( le_trans ( le_max_right _ _ ) hx ) ] ; exact hC x ( le_trans ( le_max_left _ _ ) hx ) ⟩;
  exact fun h => by obtain ⟨ C, d, A, hC ⟩ := h_ind h rfl; obtain ⟨ x, hx₁, hx₂ ⟩ := hf C d A; linarith [ hC x hx₁ ] ;

/-
`exp` grows faster than any polynomial.
-/
theorem exp_exceeds_poly_eventually (C : ℝ) (d : ℕ) :
    ∃ A : ℝ, ∀ x ≥ A, C * x ^ d < Real.exp x := by
  -- Use the fact that $\exp(x) / x^d \to \infty$ as $x \to \infty$.
  have h_exp_div_pow : Filter.Tendsto (fun x : ℝ => Real.exp x / x ^ d) Filter.atTop Filter.atTop := by
    exact Real.tendsto_exp_div_pow_atTop d;
  exact Filter.eventually_atTop.mp ( h_exp_div_pow.eventually_gt_atTop ( Max.max C 1 ) ) |> fun ⟨ A, hA ⟩ ↦ ⟨ Max.max A 1, fun x hx ↦ by have := hA x ( le_trans ( le_max_left _ _ ) hx ) ; rw [ lt_div_iff₀ ( pow_pos ( by linarith [ le_max_right A 1 ] ) _ ) ] at this; nlinarith [ le_max_left C 1, le_max_right C 1, pow_pos ( by linarith [ le_max_right A 1 ] : 0 < x ) d ] ⟩

/-- **Verified classifier**: Given an EML expression, returns its Hardy level
    along with a proof certificate. -/
def hardyClassify (e : EmlExpr) :
    { d : ℕ // HardyLevel d (e.eval) ∧ d = e.emlDepth } :=
  ⟨e.emlDepth, emlDepth_le_hardyLevel e, rfl⟩

/-! ## Strict Hierarchy Separation -/

/-
**Theorem**: `exp` (= `iterExp 1`) does not belong to Hardy level 0.
    This is the base case of strict hierarchy separation:
    level-0 functions have polynomial growth, but `exp` grows super-polynomially.
-/
theorem exp_not_hardyLevel_zero : ¬ HardyLevel 0 (iterExp 1) := by
  intro h
  obtain ⟨C, d, A, h_bound⟩ := hardyLevel_zero_poly_bound h
  obtain ⟨A', h_exp_bound⟩ := exp_exceeds_poly_eventually C d
  obtain ⟨x, hx⟩ : ∃ x, x ≥ A ∧ x ≥ A' := by
    exact ⟨ Max.max A A', le_max_left _ _, le_max_right _ _ ⟩
  generalize_proofs at *; (
  exact absurd ( h_bound x hx.1 ) ( by rw [ abs_of_nonneg ( by exact ( show 0 ≤ iterExp 1 x from by { exact le_of_lt ( by exact ( by { exact iterExp_pos_of_succ 0 x } ) ) } ) ) ] ; linarith [ h_exp_bound x hx.2, show iterExp 1 x = Real.exp x from by { exact rfl } ] ) ;)

/-- **Theorem**: `iterExp n` has Hardy rank at least `n` in the following sense:
    `iterExp n` belongs to level `n` (by `iterExp_mem_hardyLevel`) and,
    for `n = 1`, does not belong to level `0`. -/
theorem iterExp_base_separation :
    HardyLevel 1 (iterExp 1) ∧ ¬ HardyLevel 0 (iterExp 1) :=
  ⟨iterExp_mem_hardyLevel 1, exp_not_hardyLevel_zero⟩

/-- **Conjecture** (open): `iterExp n` for `n ≥ 1` does not belong to Hardy level `n - 1`.
    Proved for `n = 1` above. The general case requires growth bounds for all levels. -/
theorem iterExp_not_mem_lower_hardyLevel_conj :
    ∀ n, 1 ≤ n → ¬ HardyLevel (n - 1) (iterExp n) := by
  sorry

/-- **Conjecture** (open): every function at Hardy level `n` is eventually bounded
    by `C * iterExp (n+1) x`. -/
theorem hardyLevel_n_bounded_by_iterExp_succ (n : ℕ) (f : ℝ → ℝ)
    (hf : HardyLevel n f) :
    ∃ A C : ℝ, ∀ x ≥ A, |f x| ≤ C * iterExp (n + 1) x := by
  sorry

end