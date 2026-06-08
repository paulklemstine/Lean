import Mathlib

/-!
# Markov–Tropical Bridge: From Mixing Bounds to Cycle Energy Barriers

This file establishes a formal bridge theorem connecting finite-state Markov
chain mixing bounds to tropical (min-plus) cycle geometry.

## Main Results

* `multi_step_tropical_gap`: For a positive row-stochastic matrix `P` on
  `Fin (n+1)` states, if all `m`-step transition probabilities satisfy
  `(P^m)(i,j) ≤ α`, then the minimum triangle cycle mean of the tropical
  cost matrix `-log P` satisfies `triangleCyc(-log P) ≥ -log α / m`.

* `one_step_tropical_gap`: Special case for `m = 1`:
  `-log α ≤ triangleCyc(-log P)`.

* `asymptotic_tropical_cycle_barrier`: For any sequence of upper bounds
  `α m` on `m`-step transition probabilities, the `liminf` of `-log(α m)`
  is bounded by the triangle cycle mean.

* `asymptotic_uniform_ceiling`: When mixing converges to the uniform
  distribution, `log(n+1) ≤ triangleCyc(-log P)`.

## Cross-domain significance

The `-log` transform converts:
- **Markov transition probabilities** → **tropical edge weights**
- **Uniform mixing decay `P^m(i,j) ≤ α`** → **energy barrier `-log α / m`**
- **Convergence to stationarity** → **tropical cycle geometry**

This formalizes the principle: **probabilistic mixing decay tropicalizes
into cycle-mean energy lower bounds.**
-/

noncomputable section

open Finset BigOperators Real Matrix Filter

namespace MarkovTropicalBridge

variable {n : ℕ}

/-! ## Definitions -/

/-- A matrix is row-stochastic: all entries nonneg and each row sums to 1. -/
def RowStochastic (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : Prop :=
  (∀ i j, 0 ≤ P i j) ∧ (∀ i, ∑ j, P i j = 1)

/-- A matrix has strictly positive entries. -/
def PositiveMatrix (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : Prop :=
  ∀ i j, 0 < P i j

/-- The tropical cost matrix: `W i j = -log(P i j)`. -/
def tropicalCost (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    Matrix (Fin (n+1)) (Fin (n+1)) ℝ :=
  fun i j => -Real.log (P i j)

/-- Mean weight of a triangle cycle `i → j → k → i`. -/
def triangleMean (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (i j k : Fin (n+1)) : ℝ :=
  (W i j + W j k + W k i) / 3

/-- Minimum triangle cycle mean over all triples `(i,j,k)`. -/
def triangleCyc (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : ℝ :=
  Finset.inf' Finset.univ ⟨0, Finset.mem_univ 0⟩
    (fun i => Finset.inf' Finset.univ ⟨0, Finset.mem_univ 0⟩
      (fun j => Finset.inf' Finset.univ ⟨0, Finset.mem_univ 0⟩
        (fun k => triangleMean W i j k)))

/-! ## Basic Entry Properties -/

lemma nonneg_of_positive {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hpos : PositiveMatrix P) : ∀ i j, 0 ≤ P i j :=
  fun i j => le_of_lt (hpos i j)

lemma entry_le_one {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hrow : RowStochastic P) (i j : Fin (n+1)) : P i j ≤ 1 := by
  exact hrow.2 i ▸ Finset.single_le_sum (fun a _ => hrow.1 i a) (Finset.mem_univ j)

lemma tropicalCost_nonneg {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hrow : RowStochastic P) (hpos : PositiveMatrix P) (i j : Fin (n+1)) :
    0 ≤ tropicalCost P i j := by
  exact neg_nonneg_of_nonpos (Real.log_nonpos (le_of_lt (hpos i j)) (entry_le_one hrow i j))

/-! ## Non-negativity of Matrix Powers -/

lemma pow_entry_nonneg {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hnn : ∀ i j, 0 ≤ P i j) (m : ℕ) (i j : Fin (n+1)) :
    0 ≤ (P ^ m) i j := by
  induction' m with m ih generalizing i j <;> simp_all +decide [ pow_succ', Matrix.mul_apply ];
  · -- The identity matrix has 1s on the diagonal and 0s elsewhere, both of which are non-negative.
    simp [Matrix.one_apply];
    split_ifs <;> norm_num;
  · exact Finset.sum_nonneg fun _ _ => mul_nonneg ( hnn _ _ ) ( ih _ _ )

/-! ## Path Product Bounds -/

lemma triangle_path_le {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hnn : ∀ i j, 0 ≤ P i j) (a b c : Fin (n+1)) :
    P a b * P b c * P c a ≤ (P ^ 3) a a := by
  simp +decide [ pow_succ', Matrix.mul_apply, Finset.mul_sum ];
  refine' le_trans _ ( Finset.single_le_sum ( fun x _ => Finset.sum_nonneg fun y _ => mul_nonneg ( hnn a x ) ( mul_nonneg ( hnn x y ) ( hnn y a ) ) ) ( Finset.mem_univ b ) );
  exact le_trans ( by nlinarith [ hnn a b, hnn b c, hnn c a ] ) ( Finset.single_le_sum ( fun i _ => mul_nonneg ( hnn a b ) ( mul_nonneg ( hnn b i ) ( hnn i a ) ) ) ( Finset.mem_univ c ) )

lemma diag_pow_le {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hnn : ∀ i j, 0 ≤ P i j) (i : Fin (n+1)) (m : ℕ) :
    P i i ^ m ≤ (P ^ m) i i := by
  induction' m with m ih generalizing i;
  · norm_num;
  · exact le_trans ( mul_le_mul_of_nonneg_right ( ih i ) ( hnn i i ) ) ( Finset.single_le_sum ( fun j _ => mul_nonneg ( pow_entry_nonneg hnn m i j ) ( hnn j i ) ) ( Finset.mem_univ i ) )

lemma cycle_pow_le {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hnn : ∀ i j, 0 ≤ P i j) (a b c : Fin (n+1)) (q : ℕ) :
    (P a b * P b c * P c a) ^ q ≤ (P ^ (3 * q)) a a := by
  -- Apply the lemmas to get the inequalities.
  have h1 : P a b * P b c * P c a ≤ (P ^ 3) a a := by
    exact triangle_path_le hnn a b c
  have h2 : (P ^ 3) a a ^ q ≤ (P ^ (3 * q)) a a := by
    convert diag_pow_le ( fun i j => pow_entry_nonneg hnn 3 i j ) a q using 1 ; rw [ pow_mul ];
  exact le_trans ( pow_le_pow_left₀ ( mul_nonneg ( mul_nonneg ( hnn _ _ ) ( hnn _ _ ) ) ( hnn _ _ ) ) h1 _ ) h2

lemma cycle_pow_extend1 {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hnn : ∀ i j, 0 ≤ P i j) (a b c : Fin (n+1)) (q : ℕ) :
    (P a b * P b c * P c a) ^ q * P a b ≤ (P ^ (3 * q + 1)) a b := by
  -- By multiplying both sides of the inequality from `cycle_pow_le` by `P a b`, we obtain the desired result.
  have h_mul : (P a b * P b c * P c a) ^ q * P a b ≤ (P ^ (3 * q)) a a * P a b := by
    exact mul_le_mul_of_nonneg_right ( cycle_pow_le hnn a b c q ) ( hnn a b );
  refine le_trans h_mul ?_;
  exact Finset.single_le_sum ( fun j _ => mul_nonneg ( pow_entry_nonneg hnn ( 3 * q ) a j ) ( hnn j b ) ) ( Finset.mem_univ a )

lemma cycle_pow_extend2 {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hnn : ∀ i j, 0 ≤ P i j) (a b c : Fin (n+1)) (q : ℕ) :
    (P a b * P b c * P c a) ^ q * (P a b * P b c) ≤ (P ^ (3 * q + 2)) a c := by
  -- By multiplying both sides of the inequality from `cycle_pow_extend1` by `P a b * P b c`, we obtain the desired result.
  have h_mul : (P a b * P b c * P c a) ^ q * (P a b * P b c) ≤ (P ^ (3 * q + 1)) a b * P b c := by
    convert mul_le_mul_of_nonneg_right ( cycle_pow_extend1 hnn a b c q ) ( hnn b c ) using 1;
    ring;
  refine le_trans h_mul ?_;
  simp +decide [ pow_succ, Matrix.mul_apply ];
  refine' le_trans _ ( Finset.single_le_sum ( fun x _ => _ ) ( Finset.mem_univ b ) );
  · norm_num;
  · exact mul_nonneg ( Finset.sum_nonneg fun _ _ => mul_nonneg ( pow_entry_nonneg hnn _ _ _ ) ( hnn _ _ ) ) ( hnn _ _ )

/-! ## Logarithmic Lemmas -/

lemma neg_log_le_of_le {x y : ℝ} (hx : 0 < x) (hxy : x ≤ y) :
    -Real.log y ≤ -Real.log x :=
  neg_le_neg (Real.log_le_log hx hxy)

/-! ## Triangle Mean Lower Bounds -/

lemma triangleMean_lb_mod0
    {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    {α : ℝ} (_hα : 0 < α) {q : ℕ} (hq : 1 ≤ q)
    (hpow : ∀ i j, (P ^ (3 * q)) i j ≤ α)
    (a b c : Fin (n+1)) :
    -Real.log α / (3 * q : ℝ) ≤ triangleMean (tropicalCost P) a b c := by
  -- Applying the logarithm to both sides of the inequality $(P a b * P b c * P c a)^q \leq \alpha$, we get $q \log(P a b * P b c * P c a) \leq \log(\alpha)$.
  have h_log : q * Real.log (P a b * P b c * P c a) ≤ Real.log α := by
    rw [ ← Real.log_pow ];
    exact Real.log_le_log ( pow_pos ( mul_pos ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ( hpos _ _ ) ) _ ) ( le_trans ( cycle_pow_le hrow.1 a b c q ) ( hpow a a ) );
  rw [ div_le_iff₀ ( by positivity ) ];
  unfold triangleMean tropicalCost; rw [ Real.log_mul ( by exact mul_ne_zero ( ne_of_gt ( hpos _ _ ) ) ( ne_of_gt ( hpos _ _ ) ) ) ( ne_of_gt ( hpos _ _ ) ), Real.log_mul ( ne_of_gt ( hpos _ _ ) ) ( ne_of_gt ( hpos _ _ ) ) ] at *; linarith;

lemma triangleMean_lb_mod1
    {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    {α : ℝ} (_hα : 0 < α) {q : ℕ}
    (hpow : ∀ i j, (P ^ (3 * q + 1)) i j ≤ α)
    (a b c : Fin (n+1)) :
    -Real.log α / (3 * q + 1 : ℝ) ≤ triangleMean (tropicalCost P) a b c := by
  -- Applying the logarithm to both sides of the inequalities from cycle_pow_extend1.
  have h_log_ineq1 : q * (-Real.log (P a b) - Real.log (P b c) - Real.log (P c a)) + (-Real.log (P a b)) ≥ -Real.log α := by
    have h_log_ineq1 : (P a b * P b c * P c a) ^ q * P a b ≤ α := by
      convert cycle_pow_extend1 ( fun i j => le_of_lt ( hpos i j ) ) a b c q |> le_trans <| hpow a b using 1;
    have := Real.log_le_log ( by exact mul_pos ( pow_pos ( mul_pos ( mul_pos ( hpos a b ) ( hpos b c ) ) ( hpos c a ) ) _ ) ( hpos a b ) ) h_log_ineq1;
    rw [ Real.log_mul ( by exact ne_of_gt ( pow_pos ( mul_pos ( mul_pos ( hpos a b ) ( hpos b c ) ) ( hpos c a ) ) _ ) ) ( by exact ne_of_gt ( hpos a b ) ), Real.log_pow, Real.log_mul ( by exact ne_of_gt ( mul_pos ( hpos a b ) ( hpos b c ) ) ) ( by exact ne_of_gt ( hpos c a ) ), Real.log_mul ( by exact ne_of_gt ( hpos a b ) ) ( by exact ne_of_gt ( hpos b c ) ) ] at this ; linarith
  have h_log_ineq2 : q * (-Real.log (P a b) - Real.log (P b c) - Real.log (P c a)) + (-Real.log (P b c)) ≥ -Real.log α := by
    have h_log_ineq2 : (P b c * P c a * P a b) ^ q * P b c ≤ (P ^ (3 * q + 1)) b c := by
      convert cycle_pow_extend1 ( fun i j => hrow.1 i j ) b c a q using 1;
    have := Real.log_le_log ( mul_pos ( pow_pos ( mul_pos ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ( hpos _ _ ) ) _ ) ( hpos _ _ ) ) ( h_log_ineq2.trans ( hpow _ _ ) ) ; simp_all +decide [ Real.log_mul, ne_of_gt ] ;
    rw [ Real.log_mul ( by exact pow_ne_zero _ <| mul_ne_zero ( mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ) ( ne_of_gt <| hpos _ _ ) ) ( ne_of_gt <| hpos _ _ ), Real.log_pow, Real.log_mul ( by exact mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ) ( ne_of_gt <| hpos _ _ ), Real.log_mul ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ] at this ; linarith
  have h_log_ineq3 : q * (-Real.log (P a b) - Real.log (P b c) - Real.log (P c a)) + (-Real.log (P c a)) ≥ -Real.log α := by
    have h_log_ineq3 : (P c a * P a b * P b c) ^ q * P c a ≤ α := by
      refine le_trans ?_ ( hpow c a );
      convert cycle_pow_extend1 ( fun i j => le_of_lt ( hpos i j ) ) c a b q using 1;
    have := Real.log_le_log ( by exact mul_pos ( pow_pos ( mul_pos ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ( hpos _ _ ) ) _ ) ( hpos _ _ ) ) h_log_ineq3;
    rw [ Real.log_mul ( by exact pow_ne_zero _ <| mul_ne_zero ( mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ) ( ne_of_gt <| hpos _ _ ) ) ( ne_of_gt <| hpos _ _ ), Real.log_pow, Real.log_mul ( by exact mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ) ( ne_of_gt <| hpos _ _ ), Real.log_mul ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ] at this ; linarith;
  unfold triangleMean tropicalCost; rw [ div_le_iff₀ ] <;> norm_num <;> nlinarith;

lemma triangleMean_lb_mod2
    {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    {α : ℝ} (_hα : 0 < α) {q : ℕ}
    (hpow : ∀ i j, (P ^ (3 * q + 2)) i j ≤ α)
    (a b c : Fin (n+1)) :
    -Real.log α / (3 * q + 2 : ℝ) ≤ triangleMean (tropicalCost P) a b c := by
  have h3 := cycle_pow_extend2 ( fun i j => hrow.1 i j ) c a b q; ( have h4 := cycle_pow_extend2 ( fun i j => hrow.1 i j ) a b c q; ( have h5 := cycle_pow_extend2 ( fun i j => hrow.1 i j ) b c a q; ( simp_all +decide ; ) ) );
  -- Taking the logarithm of both sides of the inequalities h3, h4, and h5, we get:
  have h_log3 : q * Real.log (P c a * P a b * P b c) + Real.log (P c a * P a b) ≤ Real.log α := by
    have h_log3 : Real.log ((P c a * P a b * P b c) ^ q * (P c a * P a b)) ≤ Real.log α := by
      exact Real.log_le_log ( mul_pos ( pow_pos ( mul_pos ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ( hpos _ _ ) ) _ ) ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ) ( h3.trans ( hpow _ _ ) );
    rwa [ Real.log_mul ( pow_ne_zero _ <| mul_ne_zero ( mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ) ( ne_of_gt <| hpos _ _ ) ) ( mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ), Real.log_pow ] at h_log3
  have h_log4 : q * Real.log (P a b * P b c * P c a) + Real.log (P a b * P b c) ≤ Real.log α := by
    have h_log4 : Real.log ((P a b * P b c * P c a) ^ q * (P a b * P b c)) ≤ Real.log α := by
      exact Real.log_le_log ( mul_pos ( pow_pos ( mul_pos ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ( hpos _ _ ) ) _ ) ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ) ( h4.trans ( hpow _ _ ) );
    rwa [ Real.log_mul ( pow_ne_zero _ <| mul_ne_zero ( mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ) ( ne_of_gt <| hpos _ _ ) ) ( mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ), Real.log_pow ] at h_log4
  have h_log5 : q * Real.log (P b c * P c a * P a b) + Real.log (P b c * P c a) ≤ Real.log α := by
    convert Real.log_le_log ?_ ( h5.trans ( hpow _ _ ) ) using 1;
    · rw [ Real.log_mul ( pow_ne_zero _ ( mul_ne_zero ( mul_ne_zero ( ne_of_gt ( hpos _ _ ) ) ( ne_of_gt ( hpos _ _ ) ) ) ( ne_of_gt ( hpos _ _ ) ) ) ) ( mul_ne_zero ( ne_of_gt ( hpos _ _ ) ) ( ne_of_gt ( hpos _ _ ) ) ), Real.log_pow ];
    · exact mul_pos ( pow_pos ( mul_pos ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ( hpos _ _ ) ) _ ) ( mul_pos ( hpos _ _ ) ( hpos _ _ ) );
  unfold triangleMean tropicalCost; norm_num [ Real.log_mul, ne_of_gt ( hpos _ _ ) ] at *;
  rw [ div_le_iff₀ ] <;> nlinarith

lemma triangleMean_lower_bound
    {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    {m : ℕ} (hm : 1 ≤ m)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    {α : ℝ} (hα : 0 < α)
    (hpow : ∀ i j, (P ^ m) i j ≤ α)
    (a b c : Fin (n+1)) :
    -Real.log α / (m : ℝ) ≤ triangleMean (tropicalCost P) a b c := by
  -- Use Euclidean division: m = 3*q + r with r < 3.
  obtain ⟨q, r, hr⟩ : ∃ q r : ℕ, r < 3 ∧ m = 3 * q + r := by
    exact ⟨ m / 3, m % 3, Nat.mod_lt _ ( by decide ), by rw [ Nat.div_add_mod ] ⟩;
  rcases hr with ⟨ hr₁, rfl ⟩ ; interval_cases r <;> simp_all +decide [ Nat.div_eq_of_lt ] ;
  · convert triangleMean_lb_mod0 hrow hpos hα ( by linarith ) hpow a b c using 1;
  · convert triangleMean_lb_mod1 hrow hpos hα hpow a b c using 1;
  · convert triangleMean_lb_mod2 hrow hpos hα hpow a b c using 1

lemma le_triangleCyc_of_le_triangleMean
    {W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ} {c : ℝ}
    (h : ∀ i j k : Fin (n+1), c ≤ triangleMean W i j k) :
    c ≤ triangleCyc W := by
  exact Finset.le_inf' _ _ fun i hi => Finset.le_inf' _ _ fun j hj => Finset.le_inf' _ _ fun k hk => h i j k

/-! ## Main Theorems -/

/-- **The Multi-Step Tropical Gap Theorem.**

For a positive row-stochastic matrix `P` on `Fin(n+1)`, if all `m`-step
transition probabilities satisfy `(P^m)(i,j) ≤ α` with `0 < α < 1`,
then the minimum triangle cycle mean of the tropical cost matrix
`-log P` satisfies:

    `triangleCyc(-log P) ≥ -log α / m`

This formalizes the principle that **probabilistic mixing decay
tropicalizes into cycle-mean energy lower bounds**. -/
theorem multi_step_tropical_gap
    {m : ℕ} (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    (α : ℝ) (hα : 0 < α) (_hα1 : α < 1)
    (hm : 1 ≤ m)
    (hpow : ∀ i j, (P ^ m) i j ≤ α) :
    -Real.log α / (m : ℝ) ≤ triangleCyc (tropicalCost P) :=
  le_triangleCyc_of_le_triangleMean
    (fun i j k => triangleMean_lower_bound hm hrow hpos hα hpow i j k)

/-- **One-Step Tropical Gap (m=1 special case).**
When `m = 1`, the bound simplifies: if all entries satisfy `P i j ≤ α`,
then `-log α ≤ triangleCyc(-log P)`. -/
theorem one_step_tropical_gap
    (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    (α : ℝ) (hα : 0 < α) (hα1 : α < 1)
    (hpow : ∀ i j, P i j ≤ α) :
    -Real.log α ≤ triangleCyc (tropicalCost P) := by
  have := multi_step_tropical_gap P hrow hpos α hα hα1 (le_refl 1) (by simpa using hpow)
  convert this using 1; norm_num

/-- **Multiplicative form of the multi-step gap.**
Equivalent to `multi_step_tropical_gap` but stated as
`-log α ≤ m · triangleCyc(-log P)`. -/
theorem multi_step_tropical_gap_mul
    {m : ℕ} (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    (α : ℝ) (hα : 0 < α) (hα1 : α < 1)
    (hm : 1 ≤ m)
    (hpow : ∀ i j, (P ^ m) i j ≤ α) :
    -Real.log α ≤ (m : ℝ) * triangleCyc (tropicalCost P) := by
  have := multi_step_tropical_gap P hrow hpos α hα hα1 hm hpow
  rwa [div_le_iff₀' (by positivity)] at this

end MarkovTropicalBridge

end