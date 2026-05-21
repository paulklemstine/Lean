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

/-
**Conjecture** (open): `iterExp n` for `n ≥ 1` does not belong to Hardy level `n - 1`.
    Proved for `n = 1` above. The general case requires growth bounds for all levels.
-/
theorem iterExp_not_mem_lower_hardyLevel_conj :
    ∀ n, 1 ≤ n → ¬ HardyLevel (n - 1) (iterExp n) := by
  intro n hn
  -- Proved in Pythagorean.HardyHierarchy.Separation via growth bounds.
  -- Here we give a direct proof using the same strategy.
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  -- Need: ¬ HardyLevel m (iterExp (m + 1))
  -- iterExp (m+1) x = exp(iterExp m x)
  -- If HardyLevel m (iterExp (m+1)), by hardyLevel_zero_poly_bound when m=0,
  -- or by structural induction showing |f| ≤ exp(C * iterExp m x) for any C > 0,
  -- we get exp(iterExp m x) ≤ exp(1/2 * iterExp m x), giving iterExp m x ≤ 1/2 * iterExp m x, contradiction.
  intro h;
  -- By induction on $m$, we can show that for any $f$ at level $m$, $|f(x)| \leq \exp(C \cdot \iterExp m x)$ for any $C > 0$ and sufficiently large $x$.
  have h_ind : ∀ m : ℕ, ∀ f : ℝ → ℝ, HardyLevel m f → ∀ C > 0, ∃ N : ℝ, ∀ x ≥ N, |f x| ≤ Real.exp (C * iterExp m x) := by
    intro m f hf C hC_pos;
    induction' hf with n f g hf hg ihf ihg generalizing C;
    all_goals norm_num [ iterExp ] at *;
    -- For the base case, we can choose $N$ such that for all $x \geq N$, $x \leq \exp(Cx)$.
    have h_base : ∃ N : ℝ, ∀ x ≥ N, x ≤ Real.exp (C * x) := by
      have h_base : Filter.Tendsto (fun x => x / Real.exp (C * x)) Filter.atTop (nhds 0) := by
        -- Let $y = Cx$, therefore the limit becomes $\lim_{y \to \infty} \frac{y}{e^y}$.
        suffices h_lim_y : Filter.Tendsto (fun y => y / Real.exp y) Filter.atTop (nhds 0) by
          have := h_lim_y.comp ( Filter.tendsto_id.const_mul_atTop hC_pos );
          convert this.const_mul C⁻¹ using 2 <;> norm_num [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, hC_pos.ne' ];
        simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero 1;
      exact Filter.eventually_atTop.mp ( h_base.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ N, hN ⟩ => ⟨ N, fun x hx => by have := hN x hx; rw [ div_lt_iff₀ ( Real.exp_pos _ ) ] at this; linarith ⟩;
    exact ⟨ Max.max h_base.choose 0, fun x hx => by rw [ abs_of_nonneg ( by linarith [ le_max_right h_base.choose 0 ] ) ] ; exact h_base.choose_spec x ( le_trans ( le_max_left _ _ ) hx ) ⟩;
    · exact ⟨ |n| / C, fun x hx => by rw [ div_le_iff₀ hC_pos ] at hx; linarith [ Real.add_one_le_exp ( C * x ), abs_nonneg n ] ⟩;
    · -- By the induction hypothesis, we can find $N_1$ and $N_2$ such that for all $x \geq N_1$, $|g x| \leq \exp(C/2 * \iterExp f x)$ and for all $x \geq N_2$, $|hf x| \leq \exp(C/2 * \iterExp f x)$.
      obtain ⟨N1, hN1⟩ : ∃ N1 : ℝ, ∀ x ≥ N1, |g x| ≤ Real.exp (C / 2 * iterExp f x) := by
        exact ihg _ ( half_pos hC_pos )
      obtain ⟨N2, hN2⟩ : ∃ N2 : ℝ, ∀ x ≥ N2, |hf x| ≤ Real.exp (C / 2 * iterExp f x) := by
        exact ‹∀ C : ℝ, 0 < C → ∃ N, ∀ x ≥ N, |hf x| ≤ Real.exp (C * iterExp f x)› ( C / 2 ) ( half_pos hC_pos );
      -- Choose $N$ such that for all $x \geq N$, $\exp(C/2 * \iterExp f x) \leq \exp(C * \iterExp f x) / 2$.
      obtain ⟨N3, hN3⟩ : ∃ N3 : ℝ, ∀ x ≥ N3, Real.exp (C / 2 * iterExp f x) ≤ Real.exp (C * iterExp f x) / 2 := by
        have h_exp_bound : Filter.Tendsto (fun x => Real.exp (C / 2 * iterExp f x) / Real.exp (C * iterExp f x)) Filter.atTop (nhds 0) := by
          norm_num [ ← Real.exp_sub ];
          ring_nf;
          exact Filter.Tendsto.atTop_mul_const_of_neg ( by norm_num ) ( Filter.Tendsto.const_mul_atTop hC_pos ( show Filter.Tendsto ( fun x => iterExp f x ) Filter.atTop Filter.atTop from by exact Nat.recOn f ( by exact Filter.tendsto_id ) fun n ihn => by exact Real.tendsto_exp_atTop.comp ihn ) );
        exact Filter.eventually_atTop.mp ( h_exp_bound.eventually ( gt_mem_nhds <| show 0 < 1 / 2 by norm_num ) ) |> fun ⟨ N3, hN3 ⟩ => ⟨ N3, fun x hx => by have := hN3 x hx; rw [ div_lt_iff₀ <| Real.exp_pos _ ] at this; linarith ⟩;
      exact ⟨ Max.max N1 ( Max.max N2 N3 ), fun x hx => by rw [ abs_le ] ; constructor <;> linarith [ abs_le.mp ( hN1 x ( le_trans ( le_max_left _ _ ) hx ) ), abs_le.mp ( hN2 x ( le_trans ( le_max_of_le_right ( le_max_left _ _ ) ) hx ) ), hN3 x ( le_trans ( le_max_of_le_right ( le_max_right _ _ ) ) hx ) ] ⟩;
    · rename_i k hk₁ hk₂ ih₁ ih₂;
      obtain ⟨ N₁, hN₁ ⟩ := ih₁ ( C / 2 ) ( half_pos hC_pos ) ; obtain ⟨ N₂, hN₂ ⟩ := ih₂ ( C / 2 ) ( half_pos hC_pos ) ; use Max.max N₁ N₂; intro x hx; rw [ ← Real.exp_log ( show 0 < Real.exp ( C * iterExp _ x ) by positivity ) ] ; ring_nf; norm_num;
      exact le_trans ( mul_le_mul ( hN₁ x ( le_trans ( le_max_left _ _ ) hx ) ) ( hN₂ x ( le_trans ( le_max_right _ _ ) hx ) ) ( by positivity ) ( by positivity ) ) ( by rw [ ← Real.exp_add ] ; ring_nf; norm_num );
    · rename_i k hk₁ hk₂ ih₁ ih₂;
      -- Choose $D = \min(C, 1)/4$.
      set D := min C 1 / 4 with hD;
      -- Choose $N$ such that for all $x \geq N$, $D \cdot \text{iterExp } n x + \exp(D \cdot \text{iterExp } n x) \leq C \cdot \exp(\text{iterExp } n x)$.
      obtain ⟨N, hN⟩ : ∃ N : ℝ, ∀ x ≥ N, D * iterExp ‹_› x + Real.exp (D * iterExp ‹_› x) ≤ C * Real.exp (iterExp ‹_› x) := by
        have h_exp_growth : Filter.Tendsto (fun x => (D * x + Real.exp (D * x)) / Real.exp x) Filter.atTop (nhds 0) := by
          -- We can factor out $e^x$ in the numerator and denominator.
          suffices h_factor : Filter.Tendsto (fun x => D * x / Real.exp x + Real.exp ((D - 1) * x)) Filter.atTop (nhds 0) by
            convert h_factor using 2 ; ring;
            rw [ ← Real.exp_neg, ← Real.exp_add ] ; ring;
          -- We'll use the fact that $D * x / \exp x$ tends to $0$ as $x$ tends to infinity.
          have h_exp_div : Filter.Tendsto (fun x => D * x / Real.exp x) Filter.atTop (nhds 0) := by
            simpa [ Real.exp_neg, mul_div_assoc ] using tendsto_const_nhds.mul ( Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero 1 );
          simpa using h_exp_div.add ( Real.tendsto_exp_atBot.comp <| Filter.tendsto_id.const_mul_atTop_of_neg <| show D - 1 < 0 by linarith [ show D < 1 by linarith [ min_le_left C 1, min_le_right C 1 ] ] );
        have := h_exp_growth.eventually ( gt_mem_nhds <| show 0 < C by positivity );
        rw [ Filter.eventually_atTop ] at this; rcases this with ⟨ N, hN ⟩ ; use N; intro x hx; have := hN ( iterExp ‹_› x ) ( by
          rename_i n;
          rename_i n';
          exact le_trans hx ( show x ≤ iterExp n' x from Nat.recOn n' ( by norm_num [ iterExp ] ) fun n ihn => by rw [ iterExp ] ; exact le_trans ihn ( by linarith [ Real.add_one_le_exp ( iterExp n x ) ] ) ) ) ; rw [ div_lt_iff₀ ( Real.exp_pos _ ) ] at this; linarith;
      obtain ⟨ N₁, hN₁ ⟩ := ih₁ D ( by positivity ) ; obtain ⟨ N₂, hN₂ ⟩ := ih₂ D ( by positivity ) ; use Max.max N ( Max.max N₁ N₂ ) ; intros x hx ; specialize hN x ( le_trans ( le_max_left _ _ ) hx ) ; specialize hN₁ x ( le_trans ( le_max_of_le_right ( le_max_left _ _ ) ) hx ) ; specialize hN₂ x ( le_trans ( le_max_of_le_right ( le_max_right _ _ ) ) hx ) ; simp_all +decide [ abs_mul, Real.exp_add ] ;
      refine' le_trans ( mul_le_mul_of_nonneg_right hN₁ ( Real.exp_nonneg _ ) ) _;
      rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( by nlinarith [ abs_le.mp hN₂, Real.add_one_le_exp ( min C 1 / 4 * iterExp ‹_› x ), Real.add_one_le_exp ( k x ), min_le_left C 1, min_le_right C 1 ] ) ;
    · rename_i k hk₁ hk₂ hk₃;
      obtain ⟨ N, hN ⟩ := hk₃ C hC_pos;
      obtain ⟨ M, hM ⟩ := hk₂;
      exact ⟨ Max.max N M, fun x hx => by rw [ ← hM x ( le_trans ( le_max_right _ _ ) hx ) ] ; exact hN x ( le_trans ( le_max_left _ _ ) hx ) ⟩;
  -- Choose $C = 1/2$.
  obtain ⟨N, hN⟩ : ∃ N : ℝ, ∀ x ≥ N, |iterExp (m + 1) x| ≤ Real.exp ((1 / 2) * iterExp m x) := h_ind m (iterExp (m + 1)) h (1 / 2) (by norm_num);
  -- Since $\iterExp m x \to \infty$ as $x \to \infty$, we can choose $x$ large enough such that $\iterExp m x > 2$.
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ : ℝ, ∀ x ≥ x₀, iterExp m x > 2 := by
    have h_iterExp_inf : Filter.Tendsto (fun x => iterExp m x) Filter.atTop Filter.atTop := by
      refine' Nat.recOn m _ _ <;> simp_all +decide [ iterExp ];
      exact Filter.tendsto_id;
    exact Filter.eventually_atTop.mp ( h_iterExp_inf.eventually_gt_atTop 2 );
  -- Choose $x$ large enough such that $x \geq \max(N, x₀)$.
  obtain ⟨x, hx⟩ : ∃ x : ℝ, x ≥ max N x₀ ∧ iterExp m x > 2 := by
    exact ⟨ Max.max N x₀, le_rfl, hx₀ _ <| le_max_right _ _ ⟩;
  have := hN x ( le_trans ( le_max_left _ _ ) hx.1 ) ; rw [ abs_of_nonneg ( iterExp_pos_of_succ m x |> le_of_lt ) ] at this; rw [ show iterExp ( m + 1 ) x = Real.exp ( iterExp m x ) by rfl ] at this; norm_num at * ; linarith [ Real.add_one_le_exp ( iterExp m x ), Real.exp_lt_exp.2 ( show 1 / 2 * iterExp m x < iterExp m x by linarith ) ] ;

/-
**Conjecture** (open): every function at Hardy level `n` is eventually bounded
    by `C * iterExp (n+1) x`.
-/
theorem hardyLevel_n_bounded_by_iterExp_succ (n : ℕ) (f : ℝ → ℝ)
    (hf : HardyLevel n f) :
    ∃ A C : ℝ, ∀ x ≥ A, |f x| ≤ C * iterExp (n + 1) x := by
  -- Use the growth bound: |f x| ≤ exp(1 * iterExp n x) = iterExp (n+1) x
  -- The growth bound is proved by the same induction as in iterExp_not_mem_lower_hardyLevel_conj.
  suffices h_growth : ∃ N : ℝ, ∀ x ≥ N, |f x| ≤ Real.exp (iterExp n x) by
    obtain ⟨N, hN⟩ := h_growth
    exact ⟨N, 1, fun x hx => by simp only [one_mul, iterExp]; exact hN x hx⟩
  have h_ind : ∀ m f, HardyLevel m f → ∀ C > 0, ∃ N, ∀ x ≥ N, |f x| ≤ Real.exp (C * iterExp m x) := by
    intro m f hf C hC_pos;
    induction' hf with m f f g hf hg ihf ihg m f hf ihf generalizing C <;> norm_num at *;
    all_goals norm_num [ iterExp ] at *;
    -- For the base case, we can choose $N$ such that for all $x \geq N$, $|x| \leq \exp(Cx)$.
    have h_base_id : ∃ N, ∀ x ≥ N, |x| ≤ Real.exp (C * x) := by
      have h_base_id : Filter.Tendsto (fun x : ℝ => x / Real.exp (C * x)) Filter.atTop (nhds 0) := by
        -- Let $y = Cx$, therefore the limit becomes $\lim_{y \to \infty} \frac{y}{e^y}$.
        suffices h_lim_y : Filter.Tendsto (fun y : ℝ => y / Real.exp y) Filter.atTop (nhds 0) by
          have := h_lim_y.comp ( Filter.tendsto_id.const_mul_atTop hC_pos );
          convert this.const_mul C⁻¹ using 2 <;> norm_num [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, hC_pos.ne' ];
        simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero 1;
      exact Filter.eventually_atTop.mp ( h_base_id.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ N, hN ⟩ ↦ ⟨ Max.max N 0, fun x hx ↦ by rw [ abs_of_nonneg ( by linarith [ le_max_right N 0 ] ) ] ; have := hN x ( le_trans ( le_max_left N 0 ) hx ) ; rw [ div_lt_iff₀ ( Real.exp_pos _ ) ] at this; linarith ⟩ ;
    exact h_base_id;
    · exact ⟨ |m| / C, fun x hx => by rw [ div_le_iff₀ hC_pos ] at hx; linarith [ Real.add_one_le_exp ( C * x ), abs_nonneg m ] ⟩;
    · -- By the induction hypothesis, we can find $N_1$ and $N_2$ such that for all $x \geq N_1$, $|f x| \leq \exp(C/2 * \text{iterExp} f✝ x)$ and for all $x \geq N_2$, $|g x| \leq \exp(C/2 * \text{iterExp} f✝ x)$.
      obtain ⟨N1, hN1⟩ := ihf (C / 2) (half_pos hC_pos)
      obtain ⟨N2, hN2⟩ := ihg (C / 2) (half_pos hC_pos);
      -- Choose $N$ such that for all $x \geq N$, $2 \exp(C/2 * \text{iterExp} f✝ x) \leq \exp(C * \text{iterExp} f✝ x)$.
      obtain ⟨N3, hN3⟩ : ∃ N3, ∀ x ≥ N3, 2 * Real.exp (C / 2 * iterExp ‹_› x) ≤ Real.exp (C * iterExp ‹_› x) := by
        have h_exp_growth : Filter.Tendsto (fun x => 2 * Real.exp (C / 2 * iterExp ‹_› x) / Real.exp (C * iterExp ‹_› x)) Filter.atTop (nhds 0) := by
          norm_num [ mul_div_assoc, ← Real.exp_sub ];
          ring_nf;
          norm_num [ Real.exp_neg ];
          exact le_trans ( Filter.Tendsto.mul ( Filter.Tendsto.inv_tendsto_atTop <| Real.tendsto_exp_atTop.comp <| Filter.Tendsto.atTop_mul_const ( by positivity ) <| Filter.Tendsto.const_mul_atTop hC_pos <| show Filter.Tendsto ( fun x => iterExp _ x ) Filter.atTop Filter.atTop from by
                                                                                                                                                                                                                  rename_i k hk;
                                                                                                                                                                                                                  exact Nat.recOn hk ( Filter.tendsto_id ) fun n ihn => by simpa only [ iterExp ] using Real.tendsto_exp_atTop.comp ihn; ) tendsto_const_nhds ) ( by norm_num );
        exact Filter.eventually_atTop.mp ( h_exp_growth.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ N3, hN3 ⟩ => ⟨ N3, fun x hx => by have := hN3 x hx; rw [ div_lt_one ( Real.exp_pos _ ) ] at this; linarith ⟩;
      exact ⟨ Max.max N1 ( Max.max N2 N3 ), fun x hx => by rw [ abs_le ] ; constructor <;> linarith [ abs_le.mp ( hN1 x ( le_trans ( le_max_left _ _ ) hx ) ), abs_le.mp ( hN2 x ( le_trans ( le_max_of_le_right ( le_max_left _ _ ) ) hx ) ), hN3 x ( le_trans ( le_max_of_le_right ( le_max_right _ _ ) ) hx ) ] ⟩;
    · rename_i h₁ h₂;
      obtain ⟨ N₁, hN₁ ⟩ := h₁ ( C / 2 ) ( half_pos hC_pos ) ; obtain ⟨ N₂, hN₂ ⟩ := h₂ ( C / 2 ) ( half_pos hC_pos ) ; exact ⟨ Max.max N₁ N₂, fun x hx => by rw [ show C * iterExp m x = C / 2 * iterExp m x + C / 2 * iterExp m x by ring ] ; rw [ Real.exp_add ] ; exact mul_le_mul ( hN₁ x ( le_trans ( le_max_left _ _ ) hx ) ) ( hN₂ x ( le_trans ( le_max_right _ _ ) hx ) ) ( by positivity ) ( by positivity ) ⟩ ;
    · rename_i k f g hf hg ih_f ih_g;
      -- Choose $D$ such that $D < \min(C, 1)$.
      obtain ⟨D, hD_pos, hD_lt⟩ : ∃ D > 0, D < min C 1 := by
        exact exists_between <| lt_min hC_pos zero_lt_one;
      -- Choose $N$ such that for all $x \geq N$, $D * \exp(iterExp k x) + \exp(D * iterExp k x) \leq C * \exp(iterExp k x)$.
      obtain ⟨N, hN⟩ : ∃ N, ∀ x ≥ N, D * Real.exp (iterExp k x) + Real.exp (D * iterExp k x) ≤ C * Real.exp (iterExp k x) := by
        -- We'll use that $D * \exp(iterExp k x) + \exp(D * iterExp k x) \leq C * \exp(iterExp k x)$ simplifies to $D + \exp((D-1) * iterExp k x) \leq C$.
        suffices h_simplified : ∃ N, ∀ x ≥ N, D + Real.exp ((D - 1) * iterExp k x) ≤ C by
          obtain ⟨ N, hN ⟩ := h_simplified; use N; intro x hx; convert mul_le_mul_of_nonneg_right ( hN x hx ) ( Real.exp_nonneg ( iterExp k x ) ) using 1 ; ring;
          rw [ ← Real.exp_add ] ; ring;
        -- Since $D < 1$, we have $(D - 1) < 0$, and thus $\exp((D - 1) * \exp(iterExp k x)) \to 0$ as $x \to \infty$.
        have h_exp_zero : Filter.Tendsto (fun x => Real.exp ((D - 1) * iterExp k x)) Filter.atTop (nhds 0) := by
          norm_num +zetaDelta at *;
          exact Filter.Tendsto.const_mul_atTop_of_neg ( by linarith ) ( show Filter.Tendsto ( fun x => iterExp k x ) Filter.atTop Filter.atTop from by exact Nat.recOn k ( by exact Filter.tendsto_id ) fun n ihn => by exact Real.tendsto_exp_atTop.comp ihn );
        exact Filter.eventually_atTop.mp ( h_exp_zero.eventually ( ge_mem_nhds <| show 0 < C - D by linarith [ min_le_left C 1, min_le_right C 1 ] ) ) |> fun ⟨ N, hN ⟩ => ⟨ N, fun x hx => by linarith [ hN x hx ] ⟩;
      obtain ⟨ N₁, hN₁ ⟩ := ih_f D hD_pos
      obtain ⟨ N₂, hN₂ ⟩ := ih_g D hD_pos
      use max N (max N₁ N₂) ; intros x hx; specialize hN x ( le_trans ( le_max_left _ _ ) hx ) ; specialize hN₁ x ( le_trans ( le_max_of_le_right ( le_max_left _ _ ) ) hx ) ; specialize hN₂ x ( le_trans ( le_max_of_le_right ( le_max_right _ _ ) ) hx ) ; simp_all +decide [ abs_mul, Real.exp_add ] ;
      refine' le_trans ( mul_le_mul_of_nonneg_right hN₁ ( Real.exp_nonneg _ ) ) _;
      rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( by nlinarith [ abs_le.mp hN₂, Real.add_one_le_exp ( iterExp k x ), Real.add_one_le_exp ( D * iterExp k x ) ] ) ;
    · rename_i k hk₁ hk₂ hk₃;
      obtain ⟨ N₁, hN₁ ⟩ := hk₃ C hC_pos
      obtain ⟨ N₂, hN₂ ⟩ := hk₂;
      exact ⟨ Max.max N₁ N₂, fun x hx => by simpa only [ hN₂ x ( le_trans ( le_max_right _ _ ) hx ) ] using hN₁ x ( le_trans ( le_max_left _ _ ) hx ) ⟩;
  simpa using h_ind n f hf 1 zero_lt_one

end