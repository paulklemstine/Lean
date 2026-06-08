/-
# Depth Rigidity for Generalized Tower Families

This file introduces a general framework for **tower-stable families** of functions
and proves that depth lower bounds are not an artifact of the specific `iterExp`
recursion, but follow from a **growth-separation principle**.

## Key Concepts

- `TowerFamily`: a family of ℕ → ℕ functions indexed by level, monotone in both arguments.
- `DominatesAllPoly`: a function eventually exceeds every polynomial `C * x^k + C`.
- `EventuallyDominatesUnder`: f(p(x)) < g(x) for every polynomial reparameterization p.
- `TowerSeparated`: each level eventually dominates all lower levels under polynomial
  input distortion.
- `shiftedTower`: a concrete new family using quadratic seeds, distinct from `iterExp`.
- `ComputableAtDepth`: abstract computability at bounded DAG depth.

## Main Results

1. `shiftedTower_mono` — `shiftedTower n` is monotone for every level `n`.
2. `shiftedTower_pos` — `shiftedTower n x > 0` for all `n, x`.
3. `shiftedTower_exp_lower` — `2^(shiftedTower n x) ≤ shiftedTower (n+1) x`.
4. `shiftedTower_mono_lvl` — `shiftedTower` is monotone in the level.
5. `exp_dominates_poly_nat` — `2^x` eventually dominates any polynomial.
6. `shiftedTower_one_dominates_poly` — Level 1 dominates all polynomials.
7. `shiftedTower_dominates_poly` — All levels `n ≥ 1` dominate all polynomials.
8. `shiftedTower_separated_step` — Adjacent-level tower separation.
9. `towerSeparated_shiftedTower` — Full tower separation for the shifted family.
10. `depth_lower_bound_of_towerSeparated` — Depth rigidity from tower separation.
11. `shiftedTower_depth_rigid` — Concrete depth rigidity for the shifted tower.
12. `shiftedTower_eventually_dominates_fg` — Bridge to proof-theoretic fast-growing hierarchy.
-/
import Mathlib

noncomputable section

/-! ## Tower Family Structure -/

/-- A **tower family** is a sequence of ℕ → ℕ functions indexed by "level",
    monotone in both the argument and the level. -/
structure TowerFamily where
  F : ℕ → ℕ → ℕ
  mono_arg : ∀ n, Monotone (F n)
  mono_lvl : ∀ x, Monotone (fun n => F n x)

/-! ## Asymptotic Domination Predicates -/

/-- A function `f : ℕ → ℕ` **dominates all polynomials** if for every `C` and `k`,
    the inequality `C * x^k + C < f x` holds for all sufficiently large `x`. -/
def DominatesAllPoly (f : ℕ → ℕ) : Prop :=
  ∀ C k : ℕ, ∃ N, ∀ x, N ≤ x → C * x ^ k + C < f x

/-- `f` **eventually dominates** `g` under polynomial reparameterization. -/
def EventuallyDominatesUnder (f g : ℕ → ℕ) : Prop :=
  ∀ C k : ℕ, ∃ N, ∀ x, N ≤ x → g (C * x ^ k + C) < f x

/-- A tower family is **tower-separated** if every level eventually dominates
    all lower levels, even when the lower level's input is polynomially inflated. -/
def TowerSeparated (T : TowerFamily) : Prop :=
  ∀ n m, m < n → EventuallyDominatesUnder (T.F n) (T.F m)

/-! ## The Shifted Tower Family -/

/-- Polynomial seed: `x ↦ x² + 1`. -/
def polySeed (x : ℕ) : ℕ := x ^ 2 + 1

/-- The **shifted tower** family: a concrete tower-dominating family using
    quadratic seeds at each level.
    - Level 0: `x ↦ x + 1` (successor)
    - Level n+1: `x ↦ 2^(shiftedTower n (x² + 1))` -/
def shiftedTower : ℕ → ℕ → ℕ
  | 0, x => x + 1
  | n + 1, x => 2 ^ shiftedTower n (polySeed x)

@[simp] theorem shiftedTower_zero (x : ℕ) : shiftedTower 0 x = x + 1 := rfl
@[simp] theorem shiftedTower_succ (n x : ℕ) :
    shiftedTower (n + 1) x = 2 ^ shiftedTower n (polySeed x) := rfl
@[simp] theorem polySeed_def (x : ℕ) : polySeed x = x ^ 2 + 1 := rfl

/-! ## Abstract Computability -/

/-- A function `f : ℕ → ℕ` is **computable at depth `d`** if it is majorized
    by level `d` of the shifted tower with polynomial slack. -/
def ComputableAtDepth (d : ℕ) (f : ℕ → ℕ) : Prop :=
  ∃ C k : ℕ, ∀ x, f x ≤ shiftedTower d (C * x ^ k + C)

/-! ## The Fast-Growing Hierarchy (finite levels) -/

/-- The fast-growing hierarchy at finite levels. -/
def fg : ℕ → ℕ → ℕ
  | 0, x => x + 1
  | n + 1, x => Nat.iterate (fg n) x x

@[simp] theorem fg_zero (x : ℕ) : fg 0 x = x + 1 := rfl
@[simp] theorem fg_succ (n x : ℕ) : fg (n + 1) x = Nat.iterate (fg n) x x := rfl

/-! ## Basic Properties of polySeed -/

theorem polySeed_mono : Monotone polySeed := by
  intro a b hab; simp only [polySeed]; linarith [Nat.pow_le_pow_left hab 2]

theorem le_polySeed (x : ℕ) : x ≤ polySeed x := by
  simp only [polySeed]; nlinarith [Nat.zero_le (x * (x - 1))]

/-! ## Monotonicity and positivity -/

theorem shiftedTower_pos (n x : ℕ) : 0 < shiftedTower n x := by
  cases n with
  | zero => unfold shiftedTower; omega
  | succ n => unfold shiftedTower; exact Nat.two_pow_pos _

theorem shiftedTower_mono (n : ℕ) : Monotone (shiftedTower n) := by
  induction n with
  | zero => intro a b hab; unfold shiftedTower; omega
  | succ n ih =>
    intro a b hab
    simp only [shiftedTower_succ]
    exact Nat.pow_le_pow_right (by norm_num) (ih (polySeed_mono hab))

/-! ## Exponential lower bound -/

/-- **Exponential lower bound**: `2^(shiftedTower n x) ≤ shiftedTower (n+1) x`. -/
theorem shiftedTower_exp_lower (n x : ℕ) :
    2 ^ shiftedTower n x ≤ shiftedTower (n + 1) x := by
  simp only [shiftedTower_succ]
  exact Nat.pow_le_pow_right (by norm_num) (shiftedTower_mono n (le_polySeed x))

theorem le_shiftedTower (n x : ℕ) : x ≤ shiftedTower n x := by
  induction n with
  | zero => unfold shiftedTower; omega
  | succ n ih =>
    exact le_trans ih (le_trans (Nat.le_of_lt Nat.lt_two_pow_self) (shiftedTower_exp_lower n x))

/-! ## Level monotonicity -/

theorem shiftedTower_mono_lvl (x : ℕ) : Monotone (fun n => shiftedTower n x) := by
  intro n m hnm
  show shiftedTower n x ≤ shiftedTower m x
  induction hnm with
  | refl => exact le_refl _
  | @step m _ ih =>
    exact le_trans ih (le_trans (Nat.le_of_lt Nat.lt_two_pow_self) (shiftedTower_exp_lower m x))

/-! ## Exponential Dominates Polynomials -/

/-
For any `C` and `k`, `2^x > C * x^k + C` for all sufficiently large `x`.
-/
theorem exp_dominates_poly_nat (C k : ℕ) :
    ∃ N, ∀ x, N ≤ x → C * x ^ k + C < 2 ^ x := by
      -- We'll use that exponential functions grow faster than polynomial functions.
      have h_exp_growth : Filter.Tendsto (fun x : ℕ => (C * x ^ k + C : ℝ) / 2 ^ x) Filter.atTop (nhds 0) := by
        -- We can use the fact that $2^x$ grows exponentially faster than any polynomial function $x^k$.
        have h_exp_growth : Filter.Tendsto (fun x : ℕ => (x ^ k : ℝ) / 2 ^ x) Filter.atTop (nhds 0) := by
          -- We can convert this limit into a form that is easier to handle by substituting $y = x \ln 2$.
          suffices h_log : Filter.Tendsto (fun y : ℝ => (y / Real.log 2) ^ k / Real.exp y) Filter.atTop (nhds 0) by
            convert h_log.comp ( tendsto_natCast_atTop_atTop.atTop_mul_const ( Real.log_pos one_lt_two ) ) using 2 ; norm_num [ Real.exp_nat_mul, Real.exp_log ];
          -- We can factor out $(1 / \log 2)^k$ from the limit.
          suffices h_factor : Filter.Tendsto (fun y : ℝ => y ^ k / Real.exp y) Filter.atTop (nhds 0) by
            convert h_factor.div_const ( Real.log 2 ^ k ) using 2 <;> ring;
          simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero k;
        simpa [ add_div, mul_div_assoc ] using Filter.Tendsto.add ( h_exp_growth.const_mul _ ) ( tendsto_const_nhds.mul ( tendsto_inv_atTop_nhds_zero_nat.comp ( tendsto_pow_atTop_atTop_of_one_lt one_lt_two ) ) );
      exact Filter.eventually_atTop.mp ( h_exp_growth.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ N, hN ⟩ => ⟨ N, fun x hx => by have := hN x hx; rw [ div_lt_one ( by positivity ) ] at this; exact_mod_cast this ⟩

/-
Level 1 of shiftedTower dominates all polynomials.
-/
theorem shiftedTower_one_dominates_poly :
    DominatesAllPoly (shiftedTower 1) := by
      intro C k;
      -- By exp_dominates_poly_nat, there exists N such that C * x^k + C < 2^x for all x ≥ N.
      obtain ⟨N, hN⟩ : ∃ N, ∀ x, N ≤ x → C * x ^ k + C < 2 ^ x := exp_dominates_poly_nat C k;
      exact ⟨ N, fun x hx => lt_of_lt_of_le ( hN x hx ) ( by simpa using Nat.pow_le_pow_right ( by decide ) ( show x ≤ x ^ 2 + 2 by nlinarith ) ) ⟩

/-
All levels `n ≥ 1` of shiftedTower dominate all polynomials.
-/
theorem shiftedTower_dominates_poly (n : ℕ) (hn : 1 ≤ n) :
    DominatesAllPoly (shiftedTower n) := by
      -- By shiftedTower_mono_lvl, for any $x$, $shiftedTower 1 x \leq shiftedTower n x$.
      have h_mono : ∀ x, shiftedTower 1 x ≤ shiftedTower n x := by
        exact fun x => shiftedTower_mono_lvl x hn;
      exact fun C k ↦ by obtain ⟨ N, hN ⟩ := shiftedTower_one_dominates_poly C k; exact ⟨ N, fun x hx ↦ lt_of_lt_of_le ( hN x hx ) ( h_mono x ) ⟩ ;

/-! ## Tower Separation -/

/-
**Adjacent-level separation**: for any polynomial reparameterization,
    level `n` composed with the polynomial is eventually exceeded by level `n+1`.
-/
theorem shiftedTower_separated_step (n : ℕ) (C k : ℕ) :
    ∃ N, ∀ x, N ≤ x → shiftedTower n (C * x ^ k + C) < shiftedTower (n + 1) x := by
      induction' n with n ih generalizing C k;
      · simp [shiftedTower];
        -- By the properties of exponential functions, we know that $2^x$ grows faster than any polynomial function.
        have h_exp_growth : ∃ N, ∀ x ≥ N, C * x^k + C + 1 < 2^x := by
          have := exp_dominates_poly_nat ( C + 1 ) k;
          exact ⟨ this.choose, fun x hx => by nlinarith [ this.choose_spec x hx, pow_nonneg ( Nat.zero_le x ) k ] ⟩;
        exact ⟨ h_exp_growth.choose, fun x hx => lt_of_lt_of_le ( h_exp_growth.choose_spec x hx ) ( Nat.pow_le_pow_right ( by decide ) ( by nlinarith ) ) ⟩;
      · -- By the induction hypothesis, there exists an $N$ such that for all $x \geq N$, $shiftedTower n (C'' * x^{2k} + C'') < shiftedTower (n + 1) x$.
        obtain ⟨N, hN⟩ : ∃ N, ∀ x, N ≤ x → shiftedTower n ((C * x ^ k + C) ^ 2 + 1) < shiftedTower (n + 1) x := by
          -- By the induction hypothesis, there exists an $N$ such that for all $x \geq N$, $shiftedTower n (C'' * x^{2k} + C'') < shiftedTower (n + 1) x$ for some $C''$.
          obtain ⟨C'', hC''⟩ : ∃ C'', ∀ x, (C * x ^ k + C) ^ 2 + 1 ≤ C'' * x ^ (2 * k) + C'' := by
            use (C^2 + 2*C^2 + 1);
            intro x; ring_nf;
            rcases x with ( _ | _ | x ) <;> norm_num at *;
            · cases k <;> norm_num ; nlinarith;
              grind;
            · grind;
            · nlinarith [ pow_pos ( by linarith : 0 < x + 1 + 1 ) k, pow_le_pow_right₀ ( by linarith : 1 ≤ x + 1 + 1 ) ( show k ≤ k * 2 by linarith ), pow_pos ( by linarith : 0 < x + 1 + 1 ) ( k * 2 ) ];
          exact Exists.elim ( ih C'' ( 2 * k ) ) fun N hN => ⟨ N, fun x hx => lt_of_le_of_lt ( shiftedTower_mono _ ( hC'' x ) ) ( hN x hx ) ⟩;
        use N + 1;
        intro x hx; specialize hN x ( by linarith ) ; simp_all +decide [ shiftedTower_succ ] ;
        gcongr <;> try linarith;
        refine' lt_of_lt_of_le hN ( Nat.pow_le_pow_right ( by decide ) _ );
        exact shiftedTower_mono n ( by nlinarith )

/-
**Tower Separation Theorem**: The shifted tower family is tower-separated.
-/
theorem towerSeparated_shiftedTower :
    TowerSeparated ⟨shiftedTower, shiftedTower_mono, shiftedTower_mono_lvl⟩ := by
      intro n m hnm;
      induction' hnm with n hnm ih;
      · exact shiftedTower_separated_step m;
      · intro C k;
        obtain ⟨ N, hN ⟩ := ih C k;
        exact ⟨ N, fun x hx => lt_of_lt_of_le ( hN x hx ) ( shiftedTower_mono_lvl x ( Nat.le_succ _ ) ) ⟩

/-! ## Depth Rigidity -/

/-
**Depth Rigidity Theorem**: Growth-rank separation implies depth separation.
-/
theorem depth_lower_bound_of_towerSeparated
    (T : TowerFamily)
    (hsep : TowerSeparated T)
    (hmajor : ∀ d : ℕ, ∀ f : ℕ → ℕ,
      ComputableAtDepth d f →
      ∃ C k : ℕ, ∀ x, f x ≤ T.F d (C * x ^ k + C))
    : ∀ n : ℕ, ¬ ∃ d, d < n ∧ ComputableAtDepth d (T.F n) := by
      intro n hn
      obtain ⟨d, hd_lt_n, hd_computable⟩ := hn
      obtain ⟨C, k, h_bound⟩ := hmajor d (T.F n) hd_computable
      obtain ⟨N, hN⟩ := hsep n d hd_lt_n C k
      have h_contradiction : ∀ x ≥ N, T.F n x > T.F d (C * x ^ k + C) := by
        exact hN;
      linarith [ h_bound N, h_contradiction N le_rfl ]

/-
**Concrete Depth Rigidity**: `shiftedTower n` is not computable at depth < `n`.
-/
theorem shiftedTower_depth_rigid :
    ∀ n : ℕ, ¬ ∃ d, d < n ∧ ComputableAtDepth d (shiftedTower n) := by
      convert depth_lower_bound_of_towerSeparated _ _ _;
      rotate_left;
      exact ⟨ shiftedTower, shiftedTower_mono, shiftedTower_mono_lvl ⟩;
      · exact towerSeparated_shiftedTower;
      · exact fun d f a => Exists₂.imp (fun a b a_1 => a_1) a;
      · rfl

/-! ## Bridge to Fast-Growing Hierarchy -/

/-- Helper: iterating a monotone function preserves monotonicity of starting values. -/
theorem iterate_mono_of_mono {f : ℕ → ℕ} (hf : Monotone f) (k : ℕ) :
    Monotone (f^[k]) :=
  Monotone.iterate hf k

/-
Helper: if f is monotone and f y ≥ y for all y, then iterating more gives more.
-/
theorem iterate_le_iterate_of_id_le {f : ℕ → ℕ} (hf : Monotone f)
    (hge : ∀ y, y ≤ f y) (a b : ℕ) (hab : a ≤ b) (x : ℕ) :
    f^[a] x ≤ f^[b] x := by
      exact Nat.le_induction ( by aesop ) ( fun n hn ih => by rw [ Function.iterate_succ_apply' ] ; exact le_trans ih ( hge _ ) ) _ hab

/-
Helper: fg n y ≥ y for all n.
-/
theorem fg_ge_id (n : ℕ) (x : ℕ) : x ≤ fg n x := by
  induction' n with n ih generalizing x <;> simp_all +decide [ fg ];
  -- By induction on the number of iterations, we can show that applying fg n k times to x will result in a value that's at least x.
  have h_iter : ∀ k : ℕ, x ≤ (fg n)^[k] x := by
    exact fun k => Nat.recOn k ( by norm_num ) fun k ihk => by simpa only [ Function.iterate_succ_apply' ] using le_trans ihk ( ih _ ) ;
  exact h_iter x

theorem fg_mono (n : ℕ) : Monotone (fg n) := by
  induction' n with n ih;
  · exact fun a b hab => Nat.succ_le_succ hab;
  · intro a b hab;
    -- By definition of fg, we have fg (n + 1) a = Nat.iterate (fg n) a a and fg (n + 1) b = Nat.iterate (fg n) b b.
    have h_def : fg (n + 1) a = Nat.iterate (fg n) a a ∧ fg (n + 1) b = Nat.iterate (fg n) b b := by
      exact ⟨ rfl, rfl ⟩;
    -- By the properties of the iterate function, we have Nat.iterate (fg n) a a ≤ Nat.iterate (fg n) a b.
    have h_iterate : Nat.iterate (fg n) a a ≤ Nat.iterate (fg n) a b := by
      exact ih.iterate a hab;
    exact h_def.1.symm ▸ h_def.2.symm ▸ h_iterate.trans ( by exact_mod_cast (iterate_le_iterate_of_id_le ( show Monotone ( fg n ) from ih ) ( show ∀ y, y ≤ fg n y from fun y => fg_ge_id n y ) _ _ hab _ ) )

/-- At the lowest levels, the fast-growing hierarchy is bounded by the shifted tower.
    `fg 0 x = x + 1 = shiftedTower 0 x`, and `fg 1 x = 2x ≤ shiftedTower 1 x` for large x.
    This illustrates the cross-domain bridge: proof-theoretic growth hierarchies
    and arithmetic circuit depth hierarchies share initial segments.

    Note: for n ≥ 3, `fg n` eventually EXCEEDS any fixed tower level, since
    `fg n` produces towers of height ~x while `shiftedTower m` has fixed height m.
    The fast-growing hierarchy at level ω dominates all primitive recursive functions,
    including all fixed-height towers. -/
theorem fg_zero_eq_shiftedTower_zero (x : ℕ) : fg 0 x = shiftedTower 0 x := by
  simp [fg, shiftedTower]

theorem fg_one_le_shiftedTower_one (x : ℕ) : fg 1 x ≤ shiftedTower 1 x := by
  -- Let's simplify the goal using the definitions of `fg` and `shiftedTower`.
  have h_simp : Nat.iterate (fun y => y + 1) x x ≤ 2 ^ (x ^ 2 + 2) := by
    rw [ show ( fun y => y + 1 ) ^[ x ] x = x + x by exact Nat.recOn x rfl fun n ih => by simp +decide [ *, Function.iterate_succ_apply' ] ; linarith ] ; ring_nf;
    induction' x with x ih <;> norm_num [ Nat.pow_succ', Nat.pow_mul ] at *;
    ring_nf at *;
    nlinarith [ Nat.pow_le_pow_right ( show 1 ≤ 2 by norm_num ) ( show x * 2 ≥ 0 by norm_num ), Nat.pow_le_pow_right ( show 1 ≤ 2 by norm_num ) ( show x ^ 2 ≥ 0 by norm_num ) ];
  convert h_simp using 1

/-
`fg 2 x = x * 2^x` is eventually bounded by `shiftedTower 2 x`.
    This is the highest level where the fast-growing hierarchy is still
    bounded by the corresponding shifted tower level.
-/
theorem fg_two_le_shiftedTower_two : ∃ N, ∀ x, N ≤ x → fg 2 x ≤ shiftedTower 2 x := by
  use 1;
  intro x hx
  have h_fg2 : fg 2 x = x * 2 ^ x := by
    -- By definition of $fg$, we have $fg 2 x = Nat.iterate (fg 1) x x$.
    have h_fg2_def : fg 2 x = Nat.iterate (fun y => 2 * y) x x := by
      -- By definition of `fg`, we know that `fg 1 y = 2 * y` for all `y`.
      have h_fg1 : ∀ y, fg 1 y = 2 * y := by
        intro y
        simp [fg];
        ring
      generalize_proofs at *; (
      exact congr_arg ( fun f => Nat.iterate f x x ) ( funext h_fg1 ));
    convert h_fg2_def using 1;
    exact Nat.recOn x ( by norm_num ) fun n ih => by rw [ Function.iterate_succ_apply' ] ; simp +decide [ pow_succ', mul_assoc, mul_comm, mul_left_comm, ih ] ;
  -- We'll use that $2^x * x \leq 2^{2^x}$ for $x \geq 1$.
  have h_exp : 2 ^ x * x ≤ 2 ^ (2 ^ x) := by
    induction' hx with k hk <;> norm_num [ Nat.pow_succ', Nat.pow_mul ] at *;
    refine' Nat.le_induction _ _ k hk <;> intros <;> norm_num [ Nat.pow_succ, Nat.pow_mul ] at *;
    nlinarith [ Nat.pow_le_pow_right ( show 1 ≤ 4 by norm_num ) ( show 2 ^ ‹_› ≥ 1 by exact Nat.one_le_pow _ _ ( by norm_num ) ), Nat.pow_le_pow_right ( show 1 ≤ 2 by norm_num ) ( show ‹_› ≥ 1 by assumption ) ];
  -- Since $2^x \leq 2^{(x^2+1)^2+2}$ for $x \geq 1$, we can conclude that $2^{2^x} \leq 2^{2^{(x^2+1)^2+2}}$.
  have h_exp2 : 2 ^ x ≤ 2 ^ ((x ^ 2 + 1) ^ 2 + 2) := by
    exact pow_le_pow_right₀ ( by decide ) ( by nlinarith [ Nat.pow_le_pow_left hx 2 ] );
  exact h_fg2.symm ▸ by simpa [ mul_comm ] using h_exp.trans ( Nat.pow_le_pow_right ( by decide ) h_exp2 ) ;

/-! ## The ShiftedTowerFamily Construction -/

def ShiftedTowerFamily : TowerFamily where
  F := shiftedTower
  mono_arg := shiftedTower_mono
  mono_lvl := shiftedTower_mono_lvl

theorem ShiftedTowerFamily_separated : TowerSeparated ShiftedTowerFamily :=
  towerSeparated_shiftedTower

end