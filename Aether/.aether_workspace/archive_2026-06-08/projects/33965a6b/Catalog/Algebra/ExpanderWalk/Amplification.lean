/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Expander-Walk Majority Amplification

This file formalizes the core theorems connecting spectral gap of a
symmetric operator to randomness-efficient error amplification.

## Main Results

* `l2_contraction_iterate` — iterated L² contraction for mean-zero functions
* `covariance_decay_of_contraction` — covariance decays as ρ^t · ‖g‖²
* `variance_empirical_mean_le_closed` — variance of walk-sample average
* `majority_error_of_bias` — majority vote error bound via Chebyshev
* `predictor_advantage_le_spectral_decay` — information-theoretic decay

## Mathematical Significance

These theorems formalize the principle that spectral expansion acts as
a substitute for fresh randomness in error amplification. A short
expander walk produces correlated samples whose empirical mean still
concentrates, enabling majority-vote amplification with logarithmically
many random bits instead of linearly many.
-/

import Mathlib

open Finset Real BigOperators

/-! ## Core Definitions -/

section Defs

variable {V : Type*} [Fintype V] [Nonempty V]

/-- Uniform mean of a function on a finite type. -/
noncomputable def UniformMean (f : V → ℝ) : ℝ :=
  (∑ v : V, f v) / Fintype.card V

/-- L² norm squared under the uniform distribution: (1/|V|) ∑ f(v)². -/
noncomputable def uL2Sq (f : V → ℝ) : ℝ :=
  (∑ v : V, f v ^ 2) / Fintype.card V

/-- Uniform inner product: (1/|V|) ∑ f(v) g(v). -/
noncomputable def uInner (f g : V → ℝ) : ℝ :=
  (∑ v : V, f v * g v) / Fintype.card V

/-- A function has uniform mean zero. -/
def IsMeanZero (f : V → ℝ) : Prop :=
  UniformMean f = 0

end Defs

/-! ## Expander Amplifier Structure -/

/-- An expander amplifier packages a finite state space with a linear operator
    that contracts mean-zero functions in L², together with a contraction bound.
    This is the abstract interface for all amplification theorems. -/
structure ExpanderAmplifier (V : Type*) [Fintype V] [Nonempty V] where
  /-- The averaging/transition operator acting on functions V → ℝ -/
  T : (V → ℝ) → (V → ℝ)
  /-- The spectral contraction parameter (second eigenvalue bound) -/
  ρ : ℝ
  /-- ρ is nonneg -/
  hρ_nonneg : 0 ≤ ρ
  /-- ρ < 1 (spectral gap exists) -/
  hρ_lt_one : ρ < 1
  /-- T preserves constants -/
  hT_const : ∀ c : ℝ, T (fun _ => c) = fun _ => c
  /-- T is additive -/
  hT_add : ∀ (f g : V → ℝ), T (fun v => f v + g v) = fun v => T f v + T g v
  /-- T preserves the uniform mean -/
  hT_preserves_mean : ∀ f : V → ℝ, UniformMean (T f) = UniformMean f
  /-- T contracts mean-zero functions in L² norm squared by ρ² -/
  hT_contracts : ∀ g : V → ℝ, IsMeanZero g →
    uL2Sq (T g) ≤ ρ ^ 2 * uL2Sq g

/-! ## Helper Lemmas -/

section Helpers

variable {V : Type*} [Fintype V] [Nonempty V]

theorem card_pos_real : (0 : ℝ) < (Fintype.card V : ℝ) :=
  Nat.cast_pos.mpr Fintype.card_pos

theorem card_ne_zero_real : (Fintype.card V : ℝ) ≠ 0 :=
  ne_of_gt card_pos_real

/-- uL2Sq is nonneg. -/
theorem uL2Sq_nonneg (f : V → ℝ) : 0 ≤ uL2Sq f :=
  div_nonneg (Finset.sum_nonneg fun v _ => sq_nonneg _) (le_of_lt card_pos_real)

/-- uInner f f = uL2Sq f. -/
theorem uInner_self (f : V → ℝ) : uInner f f = uL2Sq f := by
  unfold uInner uL2Sq
  congr 1
  exact Finset.sum_congr rfl fun v _ => by ring

/-
Cauchy–Schwarz for finite inner product sums.
-/
theorem abs_uInner_le (f g : V → ℝ) :
    |uInner f g| ≤ Real.sqrt (uL2Sq f) * Real.sqrt (uL2Sq g) := by
  -- Apply the Cauchy-Schwarz inequality to the sums.
  have h_cauchy_schwarz : (∑ x : V, f x * g x) ^ 2 ≤ (∑ x : V, f x ^ 2) * (∑ x : V, g x ^ 2) := by
    exact sum_mul_sq_le_sq_mul_sq univ f g
  unfold uInner uL2Sq;
  rw [ ← Real.sqrt_mul' ];
  · exact Real.abs_le_sqrt ( by rw [ div_mul_div_comm ] ; rw [ div_pow, div_le_div_iff₀ ] <;> first | positivity | nlinarith );
  · exact div_nonneg ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ( Nat.cast_nonneg _ )

end Helpers

/-! ## Iterated operator -/

section IterOp

variable {V : Type*} [Fintype V] [Nonempty V]

/-- Iterate a function operator n times. -/
noncomputable def iterOp (T : (V → ℝ) → (V → ℝ)) : ℕ → (V → ℝ) → (V → ℝ)
  | 0 => id
  | n + 1 => T ∘ iterOp T n

@[simp] theorem iterOp_zero (T : (V → ℝ) → (V → ℝ)) (f : V → ℝ) :
    iterOp T 0 f = f := rfl

@[simp] theorem iterOp_succ (T : (V → ℝ) → (V → ℝ)) (n : ℕ) (f : V → ℝ) :
    iterOp T (n + 1) f = T (iterOp T n f) := rfl

end IterOp

/-! ## Theorem 1: Iterated L² Contraction -/

section Contraction

variable {V : Type*} [Fintype V] [Nonempty V]

/-- Mean-zero is preserved by T. -/
theorem isMeanZero_of_T (W : ExpanderAmplifier V) (g : V → ℝ) (hg : IsMeanZero g) :
    IsMeanZero (W.T g) := by
  unfold IsMeanZero at *
  rw [W.hT_preserves_mean]
  exact hg

/-- Mean-zero is preserved by iteration. -/
theorem isMeanZero_iterate (W : ExpanderAmplifier V) (g : V → ℝ) (hg : IsMeanZero g)
    (t : ℕ) : IsMeanZero (iterOp W.T t g) := by
  induction t with
  | zero => simpa
  | succ n ih => exact isMeanZero_of_T W _ ih

/-- **Iterated L² contraction**: ‖T^t g‖₂² ≤ ρ^(2t) · ‖g‖₂² for mean-zero g.

This is the engine that converts spectral gap into quantitative decay.
The proof proceeds by induction: at each step, the contraction hypothesis
reduces the L² norm squared by a factor of ρ². -/
theorem l2_contraction_iterate (W : ExpanderAmplifier V)
    (g : V → ℝ) (hg : IsMeanZero g)
    (t : ℕ) : uL2Sq (iterOp W.T t g) ≤ (W.ρ ^ 2) ^ t * uL2Sq g := by
  induction t with
  | zero => simp
  | succ n ih =>
    simp only [iterOp_succ]
    calc uL2Sq (W.T (iterOp W.T n g))
        ≤ W.ρ ^ 2 * uL2Sq (iterOp W.T n g) :=
          W.hT_contracts _ (isMeanZero_iterate W g hg n)
      _ ≤ W.ρ ^ 2 * ((W.ρ ^ 2) ^ n * uL2Sq g) :=
          mul_le_mul_of_nonneg_left ih (sq_nonneg _)
      _ = (W.ρ ^ 2) ^ (n + 1) * uL2Sq g := by ring

/-- Rewrite contraction as ρ^(2t). -/
theorem l2_contraction_iterate' (W : ExpanderAmplifier V)
    (g : V → ℝ) (hg : IsMeanZero g)
    (t : ℕ) : uL2Sq (iterOp W.T t g) ≤ W.ρ ^ (2 * t) * uL2Sq g := by
  have h := l2_contraction_iterate W g hg t
  rwa [← pow_mul] at h

end Contraction

/-! ## Theorem 2: Covariance Decay Along an Expander Walk -/

section CovarianceDecay

variable {V : Type*} [Fintype V] [Nonempty V]

/-- The autocovariance of g along the walk at lag t. -/
noncomputable def walkCovariance (T : (V → ℝ) → (V → ℝ)) (g : V → ℝ) (t : ℕ) : ℝ :=
  uInner g (iterOp T t g)

/-
**Covariance Decay Theorem**: For a mean-zero observable g on an expander,

    |⟨g, T^t g⟩| ≤ ρ^t · ‖g‖₂²

    This is the formal hinge between spectral graph theory and derandomization.
    Proof: by Cauchy–Schwarz, |⟨g, T^t g⟩| ≤ √(‖g‖₂²) · √(‖T^t g‖₂²)
    ≤ √(‖g‖₂²) · √(ρ^(2t) · ‖g‖₂²) = ρ^t · ‖g‖₂².
-/
theorem covariance_decay_of_contraction (W : ExpanderAmplifier V)
    (g : V → ℝ) (hg : IsMeanZero g)
    (t : ℕ) : |walkCovariance W.T g t| ≤ W.ρ ^ t * uL2Sq g := by
  -- Use Cauchy-Schwarz (abs_uInner_le) and the iterated contraction bound (l2_contraction_iterate).
  have h_cauchy_schwarz : |walkCovariance W.T g t| ≤ Real.sqrt (uL2Sq g) * Real.sqrt (uL2Sq (iterOp W.T t g)) := by
    convert abs_uInner_le g ( iterOp W.T t g ) using 1;
  convert h_cauchy_schwarz.trans _ using 1;
  convert mul_le_mul_of_nonneg_left ( Real.sqrt_le_sqrt ( l2_contraction_iterate W g hg t ) ) ( Real.sqrt_nonneg ( uL2Sq g ) ) using 1;
  rw [ show ( W.ρ ^ 2 ) ^ t * uL2Sq g = ( W.ρ ^ t ) ^ 2 * uL2Sq g by ring, Real.sqrt_mul ( sq_nonneg _ ), Real.sqrt_sq ( pow_nonneg W.hρ_nonneg _ ) ] ; ring;
  rw [ Real.sq_sqrt ( uL2Sq_nonneg g ) ]

end CovarianceDecay

/-! ## Theorem 3: Variance of the Empirical Mean -/

section VarianceBound

variable {V : Type*} [Fintype V] [Nonempty V]

/-
**Variance Bound (closed-form geometric series)**:
    For mean-zero g, the L² norm of the empirical mean satisfies:

    ‖(1/k) ∑ T^i g‖₂² ≤ ((1+ρ)/(1-ρ)) · (1/k) · ‖g‖₂²

    This is the clean asymptotic form: correlated samples generated with
    tiny randomness overhead still achieve 1/k variance decay up to a
    spectral constant.
-/
theorem variance_empirical_mean_le_closed (W : ExpanderAmplifier V)
    (g : V → ℝ) (hg : IsMeanZero g) (k : ℕ) (hk : 1 ≤ k) :
    uL2Sq (fun v => (∑ i ∈ Finset.range k, iterOp W.T i g v) / k) ≤
      ((1 + W.ρ) / (1 - W.ρ)) * (1 / k) * uL2Sq g := by
  -- By convexity: ‖(1/k)∑ T^i g‖₂² ≤ (1/k) ∑_i ‖T^i g‖₂²
  have h_convex : uL2Sq (fun v => (∑ i ∈ Finset.range k, iterOp W.T i g v) / (k : ℝ)) ≤ (1 / (k : ℝ)) * ∑ i ∈ Finset.range k, uL2Sq (iterOp W.T i g) := by
    -- By expanding the sum of squares and using the fact that the average is mean-zero, we can simplify the expression.
    have h_expand : (∑ v : V, ((∑ i ∈ Finset.range k, iterOp W.T i g v) / (k : ℝ)) ^ 2) ≤ (1 / (k : ℝ)) * (∑ i ∈ Finset.range k, ∑ v : V, (iterOp W.T i g v) ^ 2) := by
      -- Apply Jensen's inequality to the convex function $f(x) = x^2$.
      have h_jensen : ∀ v : V, ((∑ i ∈ Finset.range k, iterOp W.T i g v) / (k : ℝ)) ^ 2 ≤ (1 / (k : ℝ)) * ∑ i ∈ Finset.range k, (iterOp W.T i g v) ^ 2 := by
        intro v
        have h_cauchy_schwarz_step : (∑ i ∈ Finset.range k, iterOp W.T i g v) ^ 2 ≤ k * (∑ i ∈ Finset.range k, (iterOp W.T i g v) ^ 2) := by
          have := ( Finset.sum_le_sum fun i ( hi : i ∈ Finset.range k ) => mul_self_nonneg ( iterOp W.T i g v - ( ∑ j ∈ Finset.range k, iterOp W.T j g v ) / k ) );
          simp_all +decide [ add_mul, sub_mul, mul_sub ];
          case _ => simp_all +decide only [← sum_mul, ← sq, ← Finset.mul_sum _ _ _] ; nlinarith [ mul_div_cancel₀ ( ( ∑ j ∈ Finset.range k, iterOp W.T j g v ) : ℝ ) ( by positivity : ( k : ℝ ) ≠ 0 ) ] ;
        rw [ div_pow, div_mul_eq_mul_div, div_le_div_iff₀ ] <;> first | positivity | nlinarith;
      convert Finset.sum_le_sum fun v _ => h_jensen v using 1 ; simp +decide [ div_eq_inv_mul, Finset.mul_sum _ _ _ ];
      exact Finset.sum_comm;
    convert mul_le_mul_of_nonneg_right h_expand ( inv_nonneg.2 ( Nat.cast_nonneg ( Fintype.card V ) ) ) using 1 ; norm_num [ div_eq_inv_mul, Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, mul_comm, uL2Sq ];
  -- By l2_contraction_iterate: uL2Sq(T^i g) ≤ ρ^(2i) · uL2Sq(g)
  have h_contraction : ∀ i ∈ Finset.range k, uL2Sq (iterOp W.T i g) ≤ (W.ρ ^ 2) ^ i * uL2Sq g := by
    exact fun i hi => l2_contraction_iterate W g hg i;
  -- Bound the geometric sum: ∑_{i<k} ρ^(2i) ≤ 1/(1-ρ²) = 1/((1-ρ)(1+ρ)) ≤ (1+ρ)/(1-ρ)
  have h_geo_sum : ∑ i ∈ Finset.range k, (W.ρ ^ 2) ^ i ≤ (1 + W.ρ) / (1 - W.ρ) := by
    rw [ le_div_iff₀ ] <;> try nlinarith [ W.hρ_nonneg, W.hρ_lt_one ];
    nlinarith [ W.hρ_nonneg, W.hρ_lt_one, pow_nonneg ( sq_nonneg W.ρ ) k, geom_sum_mul ( W.ρ ^ 2 ) k ];
  refine' le_trans h_convex _;
  rw [ mul_right_comm ];
  rw [ mul_comm ];
  exact mul_le_mul_of_nonneg_right ( le_trans ( Finset.sum_le_sum h_contraction ) ( by rw [ ← Finset.sum_mul _ _ _ ] ; exact mul_le_mul_of_nonneg_right h_geo_sum ( uL2Sq_nonneg _ ) ) ) ( by positivity )

end VarianceBound

/-! ## Theorem 4: Majority Error Bound -/

section MajorityError

variable {V : Type*} [Fintype V] [Nonempty V]

/-- The fraction of vertices where majority fails. -/
noncomputable def majorityFailFrac (T : (V → ℝ) → (V → ℝ))
    (f : V → ℝ) (k : ℕ) : ℝ :=
  (Finset.univ.filter fun v =>
    (∑ i ∈ Finset.range k, iterOp T i f v) / k ≤ 1/2).card / Fintype.card V

/-
**Chebyshev's inequality** for the uniform distribution on a finite type:
    the fraction of v where |g(v)| ≥ δ is at most E[g²]/δ².
-/
theorem chebyshev_uniform (g : V → ℝ) (δ : ℝ) (hδ : 0 < δ) :
    ((Finset.univ.filter (fun v => δ ≤ |g v|)).card : ℝ) / Fintype.card V ≤
      uL2Sq g / δ ^ 2 := by
  -- Since $|g(v)| \geq \delta$ implies $g(v)^2 \geq \delta^2$, we have $\sum_{v \in V} g(v)^2 \geq \delta^2 \cdot |\{v : V \mid \delta \leq |g(v)|\}|$.
  have h_ge : (∑ v : V, g v ^ 2) ≥ δ ^ 2 * ((Finset.univ.filter fun v => δ ≤ |g v|).card : ℝ) := by
    have h_ge : ∑ v : V, (if δ ≤ |g v| then δ ^ 2 else 0) ≤ ∑ v : V, g v ^ 2 := by
      exact Finset.sum_le_sum fun x _ => by split_ifs <;> nlinarith [ abs_mul_abs_self ( g x ) ] ;
    simpa [ mul_comm, Finset.sum_ite ] using h_ge;
  rw [ div_le_div_iff₀ ] <;> try positivity;
  rw [ uL2Sq ] ; rw [ div_mul_cancel₀ _ ( Nat.cast_ne_zero.mpr Fintype.card_ne_zero ) ] ; linarith;

/-
**Majority Error Bound via Chebyshev**:

    If f has E[f] ≥ 1/2 + δ and values in {0,1}, then for a walk
    of length k on an expander with contraction ρ:

    Pr[majority fails] ≤ (1+ρ)/((1-ρ) · 4δ² · k)

    This is the certified amplification theorem.
-/
theorem majority_error_of_bias (W : ExpanderAmplifier V)
    (f : V → ℝ) (hf01 : ∀ v, f v = 0 ∨ f v = 1)
    (δ : ℝ) (hδ : 0 < δ)
    (hbias : (1 : ℝ) / 2 + δ ≤ UniformMean f) (k : ℕ) (hk : 1 ≤ k) :
    majorityFailFrac W.T f k ≤
      ((1 + W.ρ) / (1 - W.ρ)) / (4 * δ ^ 2 * k) := by
  -- Apply Chebyshev's inequality to the empirical mean.
  have h_chebyshev : ((Finset.univ.filter (fun v => |((∑ i ∈ Finset.range k, iterOp W.T i f v) / k) - UniformMean f| ≥ δ)).card : ℝ) / Fintype.card V ≤ uL2Sq (fun v => (∑ i ∈ Finset.range k, iterOp W.T i (fun v => f v - UniformMean f) v) / k) / δ ^ 2 := by
    convert chebyshev_uniform _ _ hδ using 3;
    · -- By definition of $iterOp$, we know that $iterOp W.T i (fun v => f v - UniformMean f) v = iterOp W.T i f v - UniformMean f$.
      have h_iterOp : ∀ i : ℕ, ∀ v : V, iterOp W.T i (fun v => f v - UniformMean f) v = iterOp W.T i f v - UniformMean f := by
        intro i v; induction' i with i ih generalizing v <;> simp_all +decide [ iterOp ] ;
        have := W.hT_add ( fun v => iterOp W.T i f v - UniformMean f ) ( fun _ => UniformMean f ) ; simp_all +decide [ funext_iff ] ;
        rw [ show iterOp W.T i ( fun v => f v - UniformMean f ) = fun v => iterOp W.T i f v - UniformMean f from funext ih ] ; simp +decide [ this, W.hT_const ] ;
      simp +decide [ h_iterOp, Finset.sum_sub_distrib, sub_div ];
      exact funext fun v => by rw [ mul_div_cancel_left₀ _ ( by positivity ) ] ;
    · exact ⟨ Classical.arbitrary V ⟩;
  -- Apply the variance bound to the empirical mean.
  have h_variance_bound : uL2Sq (fun v => (∑ i ∈ Finset.range k, iterOp W.T i (fun v => f v - UniformMean f) v) / k) ≤ ((1 + W.ρ) / (1 - W.ρ)) * (1 / k) * uL2Sq (fun v => f v - UniformMean f) := by
    convert variance_empirical_mean_le_closed W ( fun v => f v - UniformMean f ) _ k hk using 1;
    unfold IsMeanZero UniformMean; simp +decide [ Finset.sum_sub_distrib, sub_div ] ;
  -- Apply the bound on the L² norm of the mean-zero function.
  have h_mean_zero_bound : uL2Sq (fun v => f v - UniformMean f) ≤ 1 / 4 := by
    -- Since $f$ is a Bernoulli random variable with mean $\mu$, we have $\text{Var}(f) = \mu(1 - \mu)$.
    have h_var : uL2Sq (fun v => f v - UniformMean f) = UniformMean f * (1 - UniformMean f) := by
      unfold uL2Sq UniformMean;
      simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ];
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, sq, div_eq_mul_inv, ne_of_gt ( Fintype.card_pos ) ] ; ring;
      exact congrArg₂ _ ( by congr; ext v; cases hf01 v <;> simp +decide [ * ] ) rfl;
    linarith [ sq_nonneg ( UniformMean f - 1 / 2 ) ];
  refine' le_trans _ ( h_chebyshev.trans _ );
  · refine' div_le_div_of_nonneg_right _ ( Nat.cast_nonneg _ );
    exact_mod_cast Finset.card_mono fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by cases abs_cases ( ( ∑ i ∈ Finset.range k, iterOp W.T i f x ) / k - UniformMean f ) <;> linarith [ Finset.mem_filter.mp hx ] ⟩;
  · convert div_le_div_of_nonneg_right ( h_variance_bound.trans ( mul_le_mul_of_nonneg_left h_mean_zero_bound <| by exact mul_nonneg ( div_nonneg ( add_nonneg zero_le_one W.hρ_nonneg ) ( sub_nonneg.2 W.hρ_lt_one.le ) ) <| by positivity ) ) ( sq_nonneg δ ) using 1 ; ring

end MajorityError

/-! ## Theorem 5: Predictor Advantage Decay (Cross-Domain) -/

section PredictorAdvantage

variable {V : Type*} [Fintype V] [Nonempty V]

/-- Predictor advantage: sup over bounded predictors h of |⟨h, T^t f⟩|.
    Measures how much information about f(X₀) remains after t walk steps. -/
noncomputable def predictorAdvantage (T : (V → ℝ) → (V → ℝ))
    (f : V → ℝ) (t : ℕ) : ℝ :=
  ⨆ (h : V → ℝ) (_ : ∀ v, |h v| ≤ 1), |uInner h (iterOp T t f)|

/-
**Predictor Advantage Decay**: For mean-zero f with |f| ≤ 1,
    the predictor advantage decays at rate ρ^t.

    This connects spectral expansion to information-theoretic decay.
-/
theorem predictor_advantage_le_spectral_decay (W : ExpanderAmplifier V)
    (f : V → ℝ) (hf : IsMeanZero f) (hbdd : ∀ v, |f v| ≤ 1)
    (t : ℕ) : predictorAdvantage W.T f t ≤ W.ρ ^ t := by
  -- By definition of predictor advantage, we have:
  have h_advantage_def : ∀ h : V → ℝ, (∀ v, |h v| ≤ 1) → |uInner h (iterOp W.T t f)| ≤ W.ρ ^ t := by
    intro h hh
    have h_norm : uL2Sq (iterOp W.T t f) ≤ (W.ρ ^ 2) ^ t := by
      refine' le_trans ( l2_contraction_iterate W f hf t ) _;
      exact mul_le_of_le_one_right ( pow_nonneg ( sq_nonneg _ ) _ ) ( div_le_one_of_le₀ ( le_trans ( Finset.sum_le_sum fun _ _ => show f _ ^ 2 ≤ 1 by simpa using hbdd _ ) ( by norm_num ) ) ( by positivity ) );
    -- By definition of $uL2Sq$, we have $uL2Sq h \leq 1$ since $|h v| \leq 1$ for all $v$.
    have h_norm_h : uL2Sq h ≤ 1 := by
      exact div_le_one_of_le₀ ( le_trans ( Finset.sum_le_sum fun _ _ => show h _ ^ 2 ≤ 1 by simpa using pow_le_pow_left₀ ( abs_nonneg _ ) ( hh _ ) 2 ) ( by norm_num ) ) ( Nat.cast_nonneg _ );
    refine' le_trans ( abs_uInner_le _ _ ) _;
    nontriviality;
    rw [ ← Real.sqrt_mul ( uL2Sq_nonneg _ ) ];
    exact Real.sqrt_le_iff.mpr ⟨ by exact pow_nonneg W.hρ_nonneg _, by rw [ pow_right_comm ] ; nlinarith [ uL2Sq_nonneg h, uL2Sq_nonneg ( iterOp W.T t f ) ] ⟩;
  convert ciSup_le fun h => ?_;
  · exact ⟨ fun _ => 0 ⟩;
  · rw [ @ciSup_eq_ite ];
    split_ifs <;> [ exact h_advantage_def h ‹_›; exact le_trans ( by norm_num ) ( pow_nonneg W.hρ_nonneg _ ) ]

end PredictorAdvantage

/-! ## Random Bit Complexity -/

section RandomBits

/-- Random bit cost of sampling an expander walk:
    ⌈log₂(n)⌉ bits for initial vertex + k · ⌈log₂(d)⌉ for generator choices. -/
def randomBitCost (stateSpaceSize degree walkLength : ℕ) : ℕ :=
  Nat.log 2 stateSpaceSize + walkLength * Nat.log 2 degree

/-- Independent sampling needs k · ⌈log₂(n)⌉ bits. -/
def independentBitCost (stateSpaceSize walkLength : ℕ) : ℕ :=
  walkLength * Nat.log 2 stateSpaceSize

/-- **Random-bit savings**: the expander walk always uses at most
    log₂(n) + k · log₂(d) bits, which for fixed d ≪ n and large k
    is asymptotically k · log₂(d), much less than the
    k · log₂(n) bits needed for independent sampling. -/
theorem randomBitCost_eq (n d k : ℕ) :
    randomBitCost n d k = Nat.log 2 n + k * Nat.log 2 d := by
  rfl

end RandomBits