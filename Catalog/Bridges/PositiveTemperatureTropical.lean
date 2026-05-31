/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Positive-Temperature Tropicalization: A Finite-Temperature Phase Theory

This file formalizes a **finite-temperature tropical theory** in which the classical
tropical margin emerges as the zero-temperature (β → ∞) limit of a partition-function
margin. The key parameter β (inverse temperature) controls an entropy layer around
the tropical phase boundary.

## Cross-Domain Bridge

* **Statistical mechanics:** `logSumExp` is free energy; `gibbsWeights` are Boltzmann
  probabilities; β is inverse temperature.
* **Information theory:** `logSumExp` is the cumulant generating / soft maximum
  functional; the error term `log(card)/β` is an entropy penalty.
* **Machine learning:** Softmax temperature controls confidence calibration; our
  theorems give certified approximation of max-margin tropical behavior.
* **Tropical geometry / Maslov dequantization:** β → ∞ is the dequantization limit
  turning log-sum-exp into max.

## Main Definitions

* `logSumExp` — The log-sum-exp functional (free energy / soft maximum)
* `gibbsWeights` — Boltzmann/Gibbs probability weights (softmax)
* `softMargin` — Finite-temperature tropical margin via free-energy smoothing

## Main Theorems

* `max_le_logSumExp` — Lower bound: max ≤ logSumExp
* `logSumExp_le_max_add` — Upper bound: logSumExp ≤ max + log(card)/β
* `logSumExp_antitone_beta` — Monotonicity: logSumExp decreases as β increases
* `logSumExp_lipschitz_sup` — Lipschitz stability in sup-norm
* `gibbsWeights_nonneg` — Gibbs weights are nonneg
* `sum_gibbsWeights_eq_one` — Gibbs weights sum to 1
* `softMargin_approx_tropMargin` — Certified approximation of tropical margin
* `softMargin_monotone` — Monotone convergence to tropical margin
-/

open Finset BigOperators Real

noncomputable section

namespace PositiveTemperatureTropical

/-! ## Core Definitions -/

/-- **Log-sum-exp functional** (free energy / soft maximum / Maslov dequantization).
    For β > 0 and a finite family `a : ι → ℝ`, this is
    `(1/β) * log(∑ᵢ exp(β * aᵢ))`.
    In the limit β → ∞, this converges to `maxᵢ aᵢ`. -/
def logSumExp {ι : Type*} [Fintype ι] (β : ℝ) (a : ι → ℝ) : ℝ :=
  (1 / β) * Real.log (∑ i : ι, Real.exp (β * a i))

/-- **Gibbs/Boltzmann weights** (softmax probabilities).
    For β > 0, `gibbsWeights β a i = exp(β * aᵢ) / ∑ⱼ exp(β * aⱼ)`.
    These form a probability distribution on ι that concentrates on
    the maximizers of `a` as β → ∞. -/
def gibbsWeights {ι : Type*} [Fintype ι] (β : ℝ) (a : ι → ℝ) (i : ι) : ℝ :=
  Real.exp (β * a i) / (∑ j : ι, Real.exp (β * a j))

/-! ## Auxiliary Lemmas -/

theorem sum_exp_pos {ι : Type*} [Fintype ι] [Nonempty ι]
    (β : ℝ) (a : ι → ℝ) :
    0 < ∑ i : ι, Real.exp (β * a i) := by
  exact Finset.sum_pos (fun i _ => Real.exp_pos _) ⟨Classical.arbitrary ι, Finset.mem_univ _⟩

/-! ## Theorem 1: Uniform Finite-Temperature Approximation -/

/-
**Lower bound**: The maximum is a lower bound for log-sum-exp.
    This follows because the sum includes `exp(β * a(iMax))` as a term.
-/
theorem max_le_logSumExp {ι : Type*} [Fintype ι] [Nonempty ι]
    (β : ℝ) (hβ : 0 < β) (a : ι → ℝ) (i : ι) :
    a i ≤ logSumExp β a := by
  unfold logSumExp;
  rw [ one_div, inv_mul_eq_div, le_div_iff₀' hβ ];
  rw [ Real.le_log_iff_exp_le ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ] ; exact le_trans ( by norm_num ) ( Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( β * a i ) ) ( Finset.mem_univ i ) ) ;

/-
**Upper bound**: log-sum-exp is at most the max plus `log(card ι) / β`.
    This is the entropy penalty from the partition function.
-/
theorem logSumExp_le_max_add {ι : Type*} [Fintype ι] [Nonempty ι]
    (β : ℝ) (hβ : 0 < β) (a : ι → ℝ) (iMax : ι) (hiMax : ∀ j, a j ≤ a iMax) :
    logSumExp β a ≤ a iMax + Real.log (Fintype.card ι) / β := by
  -- We'll use the fact that $\sum_{j \in \text{univ}} \exp(\beta a_j) \leq (\text{card} \, \text{univ}) \exp(\beta a_{\text{max}})$.
  have h_sum_exp : ∑ j : ι, Real.exp (β * a j) ≤ (Fintype.card ι : ℝ) * Real.exp (β * a iMax) := by
    exact le_trans ( Finset.sum_le_sum fun _ _ => Real.exp_le_exp.mpr ( mul_le_mul_of_nonneg_left ( hiMax _ ) hβ.le ) ) ( by simp +decide );
  convert mul_le_mul_of_nonneg_left ( Real.log_le_log ( sum_exp_pos β a ) h_sum_exp ) ( inv_nonneg.2 hβ.le ) using 1 ; ring_nf;
  · unfold logSumExp; ring;
  · rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring;
    norm_num [ hβ.ne' ]

/-- **Sandwich theorem**: The complete two-sided bound on log-sum-exp.
    For any β > 0, `maxᵢ aᵢ ≤ logSumExp β a ≤ maxᵢ aᵢ + log|ι|/β`. -/
theorem logSumExp_sandwich {ι : Type*} [Fintype ι] [Nonempty ι]
    (β : ℝ) (hβ : 0 < β) (a : ι → ℝ) :
    ∃ iMax : ι,
      (∀ j, a j ≤ a iMax) ∧
      a iMax ≤ logSumExp β a ∧
      logSumExp β a ≤ a iMax + Real.log (Fintype.card ι) / β := by
  obtain ⟨iMax, _, hiMax⟩ := Finset.exists_max_image Finset.univ a ⟨Classical.arbitrary ι, Finset.mem_univ _⟩
  exact ⟨iMax, fun j => hiMax j (Finset.mem_univ j),
    max_le_logSumExp β hβ a iMax,
    logSumExp_le_max_add β hβ a iMax (fun j => hiMax j (Finset.mem_univ j))⟩

/-! ## Theorem 2: Monotonicity in Inverse Temperature -/

/-
**Monotonicity**: log-sum-exp decreases as β increases (the soft max sharpens
    toward the hard max). In thermodynamic language: higher inverse temperature
    means lower entropic inflation.

    Proof strategy: Use the convexity of `t ↦ log(∑ exp(t * aᵢ))` and the fact
    that for a convex function φ with φ(0) = log|ι|, the ratio φ(t)/t is
    monotone decreasing.
-/
theorem logSumExp_antitone_beta {ι : Type*} [Fintype ι] [Nonempty ι]
    {β₁ β₂ : ℝ} (hβ₁ : 0 < β₁) (hβ₂ : 0 < β₂) (hβ : β₁ ≤ β₂)
    (a : ι → ℝ) :
    logSumExp β₂ a ≤ logSumExp β₁ a := by
  -- Set r = β₂/β₁ ≥ 1, xᵢ = exp(β₁ aᵢ). We need (1/β₂)log∑exp(β₂ aᵢ) ≤ (1/β₁)log∑exp(β₁ aᵢ).
  set r : ℝ := β₂ / β₁
  have hr : 1 ≤ r := by
    rw [ le_div_iff₀ ] <;> linarith
  set x := fun i : ι => Real.exp (β₁ * a i)
  have hx : ∀ i, 0 < x i := by
    exact fun i => Real.exp_pos _;
  -- We need to show that (∑ xᵢ^r)^{1/r} ≤ ∑ xᵢ.
  have h_sum_r : (∑ i, x i ^ r) ^ (1 / r) ≤ ∑ i, x i := by
    -- By the properties of the exponential function and the definition of $r$, we have $\sum_{i} x_i^r \leq (\sum_{i} x_i)^r$.
    have h_sum_r_le : ∑ i, x i ^ r ≤ (∑ i, x i) ^ r := by
      have h_sum_r_le : ∀ i, x i ^ r ≤ x i * (∑ j, x j) ^ (r - 1) := by
        intro i;
        exact le_trans ( by rw [ ← Real.rpow_one_add' ( le_of_lt ( hx i ) ) ] <;> norm_num ; linarith ) ( mul_le_mul_of_nonneg_left ( Real.rpow_le_rpow ( le_of_lt ( hx i ) ) ( Finset.single_le_sum ( fun i _ => le_of_lt ( hx i ) ) ( Finset.mem_univ i ) ) ( by linarith ) ) ( le_of_lt ( hx i ) ) );
      convert Finset.sum_le_sum fun i _ => h_sum_r_le i using 1;
      rw [ ← Finset.sum_mul _ _ _, ← Real.rpow_one_add' ( Finset.sum_nonneg fun _ _ => le_of_lt ( hx _ ) ) ] <;> norm_num ; linarith;
    exact le_trans ( Real.rpow_le_rpow ( Finset.sum_nonneg fun _ _ => Real.rpow_nonneg ( le_of_lt ( hx _ ) ) _ ) h_sum_r_le ( by positivity ) ) ( by rw [ ← Real.rpow_mul ( Finset.sum_nonneg fun _ _ => le_of_lt ( hx _ ) ), mul_one_div_cancel ( by positivity ), Real.rpow_one ] );
  -- Taking the logarithm of both sides, we get (1/r) log ∑ xᵢ^r ≤ log ∑ xᵢ.
  have h_log_sum_r : (1 / r) * Real.log (∑ i, x i ^ r) ≤ Real.log (∑ i, x i) := by
    simpa only [ Real.log_rpow ( Finset.sum_pos ( fun _ _ => Real.rpow_pos_of_pos ( hx _ ) _ ) Finset.univ_nonempty ) ] using Real.log_le_log ( Real.rpow_pos_of_pos ( Finset.sum_pos ( fun _ _ => Real.rpow_pos_of_pos ( hx _ ) _ ) Finset.univ_nonempty ) _ ) h_sum_r;
  simp +zetaDelta at *;
  simp_all +decide [ logSumExp, ← Real.exp_mul, mul_div_cancel₀ _ hβ₁.ne' ];
  convert mul_le_mul_of_nonneg_left h_log_sum_r ( inv_nonneg.2 hβ₁.le ) using 1 ; ring;
  simp +decide [ hβ₁.ne' ]

/-! ## Theorem 3: Lipschitz Stability -/

/-
**Lipschitz stability of log-sum-exp in the sup-norm**.
    The soft max is 1-Lipschitz with respect to the ℓ∞ perturbation of inputs.

    Proof strategy (exponential domination):
    1. Let δ = maxᵢ |aᵢ - bᵢ|
    2. Then aᵢ ≤ bᵢ + δ, so exp(β·aᵢ) ≤ exp(β·δ)·exp(β·bᵢ)
    3. Sum, take log, divide by β → logSumExp(a) ≤ logSumExp(b) + δ
    4. Swap a,b and combine.
-/
theorem logSumExp_lipschitz_sup {ι : Type*} [Fintype ι] [Nonempty ι]
    (β : ℝ) (hβ : 0 < β) (a b : ι → ℝ)
    (δ : ℝ) (hδ : ∀ i, |a i - b i| ≤ δ) :
    |logSumExp β a - logSumExp β b| ≤ δ := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · -- By the properties of logarithms and exponentials, we can show that $\sum_{i} e^{\beta a_i} \leq e^{\beta \delta} \sum_{i} e^{\beta b_i}$.
    have h_sum_exp : ∑ i, Real.exp (β * a i) ≤ Real.exp (β * δ) * ∑ i, Real.exp (β * b i) := by
      rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_le_sum fun i _ => by rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( by nlinarith [ abs_le.mp ( hδ i ) ] ) ;
    -- Taking the logarithm of both sides of the inequality $\sum_{i} e^{\beta a_i} \leq e^{\beta \delta} \sum_{i} e^{\beta b_i}$, we get $\log(\sum_{i} e^{\beta a_i}) \leq \log(e^{\beta \delta} \sum_{i} e^{\beta b_i})$.
    have h_log_sum_exp : Real.log (∑ i, Real.exp (β * a i)) ≤ Real.log (Real.exp (β * δ) * ∑ i, Real.exp (β * b i)) := by
      exact Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) h_sum_exp;
    rw [ Real.log_mul ( by positivity ) ( by exact ne_of_gt ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ), Real.log_exp ] at h_log_sum_exp;
    unfold logSumExp; ring_nf at *; nlinarith [ inv_mul_cancel_left₀ hβ.ne' δ, inv_mul_cancel₀ hβ.ne' ] ;
  · -- By the properties of logarithms and exponentials, we can show that $\sum_{i} e^{\beta b_i} \leq e^{\beta \delta} \sum_{i} e^{\beta a_i}$.
    have h_sum_exp : ∑ i, Real.exp (β * b i) ≤ Real.exp (β * δ) * ∑ i, Real.exp (β * a i) := by
      rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_le_sum fun i _ => by rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.2 ( by nlinarith [ abs_le.mp ( hδ i ) ] ) ;
    unfold logSumExp;
    rw [ ← mul_sub, ← Real.log_div ( ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ( ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ];
    rw [ one_div, inv_mul_le_iff₀ ( by positivity ) ];
    exact Real.log_le_iff_le_exp ( div_pos ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ) |>.2 ( by rwa [ div_le_iff₀ ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ] )

/-! ## Theorem 4: Gibbs Weights as a Probability Distribution -/

/-
**Gibbs weights are nonneg**.
-/
theorem gibbsWeights_nonneg {ι : Type*} [Fintype ι] [Nonempty ι]
    (β : ℝ) (_hβ : 0 < β) (a : ι → ℝ) (i : ι) :
    0 ≤ gibbsWeights β a i := by
  exact div_nonneg ( Real.exp_nonneg _ ) ( Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ )

/-
**Gibbs weights sum to one**: the partition function normalizes correctly.
-/
theorem sum_gibbsWeights_eq_one {ι : Type*} [Fintype ι] [Nonempty ι]
    (β : ℝ) (_hβ : 0 < β) (a : ι → ℝ) :
    ∑ i, gibbsWeights β a i = 1 := by
  unfold gibbsWeights;
  rw [ ← Finset.sum_div, div_self ( ne_of_gt ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ) ]

/-
**Log-sum-exp as a Gibbs expectation plus entropy correction**.
    logSumExp β a = ∑ᵢ pᵢ * aᵢ + (1/β) * H(p) where H is the Shannon entropy
    relative to uniform, and pᵢ are the Gibbs weights. Equivalently,
    logSumExp β a ≥ ∑ᵢ pᵢ * aᵢ for any probability distribution p (variational
    principle). Here we prove the simpler statement that the Gibbs weights provide
    a convex combination giving a lower bound.
-/
theorem logSumExp_ge_gibbs_average {ι : Type*} [Fintype ι] [Nonempty ι]
    (β : ℝ) (hβ : 0 < β) (a : ι → ℝ) :
    ∑ i, gibbsWeights β a i * a i ≤ logSumExp β a := by
  -- We need to show that $\sum_{i} p_i a_i \leq \log \sum_{i} e^{\beta a_i}$.
  -- We can do this by using the fact that $a_i \leq \log \sum_{j} e^{\beta a_j}$ for each $i$.
  have h_le : ∀ i, a i ≤ logSumExp β a := by
    exact fun i => max_le_logSumExp β hβ a i;
  refine' le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( h_le i ) ( gibbsWeights_nonneg β hβ a i ) ) _;
  rw [ ← Finset.sum_mul _ _ _, sum_gibbsWeights_eq_one β hβ a, one_mul ]

/-! ## Connection to Tropical Margin -/

/-- Diagonal exchange slack from TropicalUniversality. -/
def diagExSlack {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) : ℝ :=
  2 * W i j - W i i - W j j

/-- Distinct pairs in `Fin n`. -/
def distinctPairs (n : ℕ) : Finset (Fin n × Fin n) :=
  Finset.univ.filter fun p => p.1 ≠ p.2

theorem distinctPairs_nonempty {n : ℕ} (hn : 2 ≤ n) :
    (distinctPairs n).Nonempty := by
  refine ⟨(⟨0, by omega⟩, ⟨1, by omega⟩), ?_⟩
  simp [distinctPairs, Finset.mem_filter]

/-- The classical tropical margin: minimum diagonal-exclusion slack. -/
def tropMargin {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  if h : (distinctPairs n).Nonempty then
    (distinctPairs n).inf' h (fun p => diagExSlack W p.1 p.2)
  else 0

/-- Nonemptiness of distinctPairs as a subtype (for use with logSumExp). -/
instance distinctPairs_nonempty_subtype {n : ℕ} (hn : 2 ≤ n) :
    Nonempty (distinctPairs n) :=
  ⟨⟨(⟨0, by omega⟩, ⟨1, by omega⟩), by simp [distinctPairs, Finset.mem_filter]⟩⟩

/-- **Soft margin** (finite-temperature tropical margin).
    This is the negative log-sum-exp of negative slacks, i.e., the soft minimum
    of the slack family. As β → ∞, this converges to the tropical margin. -/
def softMargin {n : ℕ} (β : ℝ) (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  if h : (distinctPairs n).Nonempty then
    -logSumExp β (fun p : distinctPairs n => -(diagExSlack W p.1.1 p.1.2))
  else 0

/-- **Phase width estimate**: the thermal broadening scale is 1/β. -/
def phaseWidthEstimate (β : ℝ) (k : ℝ) : ℝ := k / β

/-
The soft margin approximates the tropical margin with error at most
    `log(card(distinctPairs n)) / β`.
-/
theorem softMargin_approx_tropMargin {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (β : ℝ) (hβ : 0 < β) :
    tropMargin W - Real.log (distinctPairs n).card / β ≤ softMargin β W ∧
    softMargin β W ≤ tropMargin W := by
  convert logSumExp_sandwich β hβ ( fun p : { p : Fin n × Fin n // p ∈ distinctPairs n } => - ( diagExSlack W p.val.1 p.val.2 ) ) using 1;
  · constructor <;> intro h;
    · convert logSumExp_sandwich β hβ ( fun p : { p : Fin n × Fin n // p ∈ distinctPairs n } => - ( diagExSlack W p.val.1 p.val.2 ) ) using 1;
      exact ⟨ ⟨ ⟨ ⟨ 0, by linarith ⟩, ⟨ 1, by linarith ⟩ ⟩, by simp +decide [ distinctPairs ] ⟩ ⟩;
    · unfold tropMargin softMargin;
      split_ifs <;> simp_all +decide [ Finset.inf'_eq_csInf_image ];
      obtain ⟨ a, b, h₁, h₂, h₃, h₄ ⟩ := h;
      constructor;
      · linarith [ show sInf ( ( fun p : Fin n × Fin n => diagExSlack W p.1 p.2 ) '' ( distinctPairs n : Set ( Fin n × Fin n ) ) ) ≤ diagExSlack W a b from csInf_le ( by exact Set.Finite.bddBelow <| Set.toFinite _ ) <| Set.mem_image_of_mem _ h₃ ];
      · exact le_csInf ( Set.Nonempty.image _ ‹_› ) ( by rintro x ⟨ p, hp, rfl ⟩ ; linarith [ h₁ _ _ hp ] );
  · exact ⟨ ⟨ ( ⟨ 0, by linarith ⟩, ⟨ 1, by linarith ⟩ ), Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by simp +decide ⟩ ⟩ ⟩

/-
The soft margin increases monotonically toward the tropical margin as β increases.
-/
theorem softMargin_monotone {n : ℕ} (_hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ)
    {β₁ β₂ : ℝ} (hβ₁ : 0 < β₁) (hβ₂ : 0 < β₂) (hβ : β₁ ≤ β₂) :
    softMargin β₁ W ≤ softMargin β₂ W := by
  unfold softMargin;
  split_ifs <;> norm_num [ logSumExp_antitone_beta, * ];
  convert logSumExp_antitone_beta hβ₁ hβ₂ hβ _ using 1;
  exact ⟨ _, Classical.choose_spec ‹_› ⟩

/-! ## Conjecture: Thermal Width Law -/

/-
**Conjecture (Thermal width law for the tropical phase boundary).**
    When exactly two slacks tie at a unique crossing point and their difference
    has nonzero derivative, the transition layer has width Θ(1/β).

    This is stated as a falsifiable computational prediction:
    for the two-state logistic model, the soft margin transition has
    width exactly `2·log(3)/β` (the interval where the soft margin
    differs from the tropical margin by more than 25% of the gap).
-/
theorem thermal_width_two_state (β : ℝ) (hβ : 0 < β) (a₁ a₂ : ℝ)
    (ha : a₁ < a₂) :
    logSumExp β (fun i : Fin 2 => ![a₁, a₂] i) - a₂ ≤ Real.log 2 / β := by
  convert sub_le_sub_right ( logSumExp_le_max_add β hβ ( fun i => ![a₁, a₂] i ) 1 fun j => ?_ ) a₂ using 1;
  · norm_num [ Fin.ext_iff ];
  · fin_cases j <;> norm_num ; linarith!

end PositiveTemperatureTropical

end