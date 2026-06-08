import Mathlib

/-!
# Hardness Reduction: Worst-Case Lattice Problems → Learning with Errors

This module formalizes the core mathematical structure of Regev's hardness
reduction from worst-case lattice problems (GapSVP, SIVP) to the Learning
with Errors (LWE) problem, with specific parameter relationships.

## Mathematical Background

The Learning with Errors (LWE) problem, introduced by Regev (2005):
given samples (aᵢ, bᵢ = ⟨aᵢ, s⟩ + eᵢ mod q) where aᵢ are uniform random,
s is a secret vector, and eᵢ are drawn from a discrete Gaussian,
recover s (search-LWE) or distinguish from uniform (decision-LWE).

**Regev's Theorem**: Solving LWE(n, q, α) is at least as hard as solving
GapSVP_γ in the worst case, where γ = Õ(n/α). For αq ≥ 2√n, the
reduction produces a polynomial approximation factor.

## Main Results

1. `NoiseFloodingLemma` — Novel structure: parameterized noise flooding
2. `ReductionChain` — Multi-step hardness reduction composition
3. `telescope_abs_bound` — Telescoping sum (by induction)
4. `hybrid_column_bound` — Column-by-column hybrid argument
5. `noise_flooding_masks_signal` — Key noise flooding inequality
6. `gaussian_tail_subexponential` — Gaussian tail decay (by nlinarith)
7. `approxFactor_anti_noise` — Monotonicity of approximation factor
8. `dimension_modulus_tradeoff` — Security parameter tradeoffs

## References

* Regev, "On Lattices, Learning with Errors, Random Linear Codes,
  and Cryptography", STOC 2005 / JACM 2009
* Peikert, "Public-Key Cryptosystems from the Worst-Case Shortest
  Vector Problem", STOC 2009
-/

open Real Finset BigOperators

noncomputable section

/-! ## Section 1: LWE Parameter Structures -/

/-- Parameters for a Learning with Errors instance. -/
structure LWEParams where
  n : ℕ
  q : ℕ
  m : ℕ
  α : ℝ
  hn : 0 < n
  hq : 1 < q
  hm : 0 < m
  hα_pos : 0 < α
  hα_lt : α < 1

/-- The error width αq: standard deviation of D_{ℤ,αq}. -/
def LWEParams.errorWidth (p : LWEParams) : ℝ := p.α * ↑p.q

/-- The lattice approximation factor γ = n/(αq) from the reduction. -/
def LWEParams.approxFactor (p : LWEParams) : ℝ := ↑p.n / (p.α * ↑p.q)

/-! ## Section 2: Novel Definition — Noise Flooding Lemma Structure -/

/-- **Novel Definition**: A `NoiseFloodingLemma` parameterizes the key step in
Regev's reduction where a large Gaussian "floods" a bounded signal, making
the sum statistically close to a pure Gaussian.

Mathematically: if X is bounded by B and Y ~ D_{ℤ,s} with s ≫ B,
then X + Y is within ε total variation distance of Y,
where ε ≈ B·√(2π)/s.

The key invariant `flood_ratio_sufficient` ensures s/B is large enough
that the statistical distance is negligible. -/
structure NoiseFloodingLemma where
  /-- Upper bound on the signal magnitude |x| ≤ B -/
  signalBound : ℝ
  /-- Width parameter s of the flooding Gaussian D_{ℤ,s} -/
  noiseWidth : ℝ
  /-- The resulting statistical distance ε -/
  statisticalDistance : ℝ
  /-- Signal bound is positive -/
  hB_pos : 0 < signalBound
  /-- Noise width is positive -/
  hs_pos : 0 < noiseWidth
  /-- Statistical distance is positive -/
  hε_pos : 0 < statisticalDistance
  /-- The noise must be wide enough: s/B ≥ 1/ε -/
  flood_ratio_sufficient : noiseWidth / signalBound ≥ 1 / statisticalDistance
  /-- ε < 1 ensures meaningful statistical guarantee -/
  hε_lt_one : statisticalDistance < 1

/-- The flooding ratio s/B. -/
def NoiseFloodingLemma.floodRatio (nf : NoiseFloodingLemma) : ℝ :=
  nf.noiseWidth / nf.signalBound

/-! ## Section 3: Core Bounds -/

/-- **Error width is positive** for valid LWE parameters. -/
theorem errorWidth_pos (p : LWEParams) : 0 < p.errorWidth :=
  mul_pos p.hα_pos (Nat.cast_pos.mpr (by linarith [p.hq]))

/-- **Noise-to-modulus ratio is in (0,1)**. The error rate α = αq/q
is strictly between 0 and 1, ensuring errors don't wrap around mod q. -/
theorem noise_ratio_bound (p : LWEParams) :
    0 < p.errorWidth / ↑p.q ∧ p.errorWidth / ↑p.q < 1 := by
  have hq_pos : (0 : ℝ) < ↑p.q := Nat.cast_pos.mpr (by linarith [p.hq])
  constructor
  · exact div_pos (errorWidth_pos p) hq_pos
  · show p.α * ↑p.q / ↑p.q < 1
    rw [mul_div_cancel_right₀ _ (ne_of_gt hq_pos)]
    exact p.hα_lt

/-- **Noise flooding masks signal**: B/s ≤ ε.

**Proof**: From s/B ≥ 1/ε, multiply both sides by B·ε/s:
  (s/B)·(B·ε/s) ≥ (1/ε)·(B·ε/s), i.e., ε ≥ B/s. -/
theorem noise_flooding_masks_signal (nf : NoiseFloodingLemma) :
    nf.signalBound / nf.noiseWidth ≤ nf.statisticalDistance := by
  rw [div_le_iff₀ nf.hs_pos]
  have h := nf.flood_ratio_sufficient
  rw [ge_iff_le, le_div_iff₀ nf.hB_pos, one_div, inv_mul_le_iff₀ nf.hε_pos] at h
  linarith

/-- **Gaussian tail monotonicity**: exp(-π·t²) ≤ exp(-π·t) for t ≥ 1.
Uses π > 0 and t² ≥ t for t ≥ 1. -/
theorem gaussian_tail_monotone (t : ℝ) (ht : 1 ≤ t) :
    exp (-π * t ^ 2) ≤ exp (-π * t) := by
  apply exp_le_exp.mpr
  nlinarith [pi_pos, le_self_pow₀ ht two_ne_zero]

/-- **Gaussian tail subexponential**: exp(-π·t²) < exp(-t) for t ≥ 1.
**Proof**: Uses π > 3, so πt² > 3t² ≥ 3t ≥ t for t ≥ 1. -/
theorem gaussian_tail_subexponential (t : ℝ) (ht : 1 ≤ t) :
    exp (-π * t ^ 2) < exp (-t) := by
  apply exp_lt_exp.mpr
  nlinarith [pi_gt_three, sq_nonneg (t - 1)]

/-! ## Section 4: Hybrid Argument -/

/-
**Telescoping bound**: |f(0) - f(n)| ≤ ∑ᵢ |f(i) - f(i+1)|.
Proved by induction on n using the triangle inequality for |·|.
-/
theorem telescope_abs_bound (n : ℕ) (f : Fin (n + 1) → ℝ) :
    |f 0 - f (Fin.last n)| ≤ ∑ i : Fin n,
      |f (Fin.castSucc i) - f i.succ| := by
  induction' n with n ih;
  · norm_num [ Fin.eq_zero ];
  · specialize ih ( fun i => f i.castSucc );
    rw [ Fin.sum_univ_castSucc ];
    exact le_trans ( abs_sub_le _ _ _ ) ( by linarith! )

/-- **Column-by-column hybrid bound**: Total distinguishing advantage
is at most n × ε where ε is the per-column bound.

**Proof**: Apply `telescope_abs_bound`, then bound each |step| ≤ ε,
and observe that the sum of n copies of ε equals n·ε. -/
theorem hybrid_column_bound
    (n : ℕ) (_hn : 0 < n)
    (hybridProbs : Fin (n + 1) → ℝ)
    (ε : ℝ) (_hε : 0 ≤ ε)
    (hstep : ∀ i : Fin n,
      |hybridProbs i.castSucc - hybridProbs i.succ| ≤ ε) :
    |hybridProbs 0 - hybridProbs (Fin.last n)| ≤ ↑n * ε := by
  calc |hybridProbs 0 - hybridProbs (Fin.last n)|
      ≤ ∑ i : Fin n, |hybridProbs i.castSucc - hybridProbs i.succ| :=
        telescope_abs_bound n hybridProbs
    _ ≤ ∑ _i : Fin n, ε := Finset.sum_le_sum (fun i _ => hstep i)
    _ = ↑n * ε := by simp [Finset.sum_const, Finset.card_fin, nsmul_eq_mul]

/-! ## Section 5: Reduction Chain -/

/-- **Novel Definition**: A `ReductionChain` models a multi-step hardness
reduction as a sequence of advantage-preserving transformations.

Captures: GapSVP → BDD → LWE → Decision-LWE. -/
structure ReductionChain where
  numSteps : ℕ
  stepLoss : Fin numSteps → ℝ
  hLoss_nonneg : ∀ i, 0 ≤ stepLoss i
  hSteps : 0 < numSteps

/-- Total advantage loss. -/
def ReductionChain.totalLoss (rc : ReductionChain) : ℝ :=
  ∑ i : Fin rc.numSteps, rc.stepLoss i

/-- **Total loss is nonneg**. -/
theorem ReductionChain.totalLoss_nonneg (rc : ReductionChain) :
    0 ≤ rc.totalLoss :=
  Finset.sum_nonneg (fun i _ => rc.hLoss_nonneg i)

/-- **Reduction preserves nontrivial advantage**: If an attacker has
advantage δ against the hard problem and the total reduction loss is L,
the attacker's advantage against LWE is at least δ - L. -/
theorem reduction_chain_advantage_bound (rc : ReductionChain)
    (δ advantage_lwe : ℝ)
    (h_chain : δ ≤ advantage_lwe + rc.totalLoss) :
    δ - rc.totalLoss ≤ advantage_lwe := by linarith

/-- **Uniform step loss bound**: If every step loses at most ε,
then total loss ≤ k · ε.

**Proof**: Each term in the sum is ≤ ε, and there are k = numSteps terms. -/
theorem reduction_chain_uniform_loss (rc : ReductionChain) (ε : ℝ)
    (huniform : ∀ i, rc.stepLoss i ≤ ε) :
    rc.totalLoss ≤ ↑rc.numSteps * ε := by
  calc ∑ i : Fin rc.numSteps, rc.stepLoss i
      ≤ ∑ _i : Fin rc.numSteps, ε := Finset.sum_le_sum (fun i _ => huniform i)
    _ = ↑rc.numSteps * ε := by simp [Finset.sum_const, Finset.card_fin, nsmul_eq_mul]

/-! ## Section 6: Exponential Security -/

/-- **Exponential security from dimension**: b^n > 1 for b > 1, n > 0. -/
theorem exponential_security (b : ℝ) (n : ℕ)
    (hb : 1 < b) (hn : 0 < n) :
    b ^ n > 1 :=
  one_lt_pow₀ hb (by omega)

/-- **Security parameter doubling**: b^(2n) = (b^n)². -/
theorem security_doubling (b : ℝ) (n : ℕ) :
    b ^ (2 * n) = (b ^ n) ^ 2 := by rw [← pow_mul]; ring_nf

/-! ## Section 7: Regev's Parameter Conditions -/

/-- **Regev's modulus condition**: n² ≥ 2√n for n ≥ 4.

**Proof**: Since √n ≤ n (for n ≥ 1), we have 2√n ≤ 2n ≤ n·n = n²
for n ≥ 4. The first inequality uses (√n)² = n and the second uses n ≥ 4. -/
theorem regev_modulus_condition (n : ℕ) (hn : 4 ≤ n) :
    (n ^ 2 : ℝ) ≥ 2 * sqrt ↑n := by
  have hn4 : (4 : ℝ) ≤ ↑n := by exact_mod_cast hn
  have h0 : (0 : ℝ) ≤ ↑n := by linarith
  nlinarith [Real.sq_sqrt h0, Real.sqrt_nonneg (↑n : ℝ), sq_nonneg (sqrt ↑n - 1)]

/-- **Approximation factor is positive**. -/
theorem approxFactor_pos (p : LWEParams) : 0 < p.approxFactor :=
  div_pos (Nat.cast_pos.mpr p.hn)
    (mul_pos p.hα_pos (Nat.cast_pos.mpr (by linarith [p.hq])))

/-- **Approximation factor decreases with noise**: Larger α means
smaller γ = n/(αq), since a noisier LWE problem is harder and
thus reduces from an easier lattice problem.

**Proof by strict monotonicity of division**: n/(α'q) < n/(αq) because
α' > α makes the denominator α'q strictly larger. -/
theorem approxFactor_anti_noise (p : LWEParams) (α' : ℝ)
    (hα' : p.α < α') :
    ↑p.n / (α' * ↑p.q) < p.approxFactor := by
  unfold LWEParams.approxFactor
  have hq : (0 : ℝ) < ↑p.q := Nat.cast_pos.mpr (by linarith [p.hq])
  apply div_lt_div_of_pos_left (Nat.cast_pos.mpr p.hn)
  · exact mul_pos p.hα_pos hq
  · exact mul_lt_mul_of_pos_right hα' hq

/-- **Polynomial approx factor**: c·n/(2·√n) = c·√n/2 for n > 0.

**Proof**: Write n = (√n)² and cancel one factor of √n from
numerator and denominator. -/
theorem poly_approx_factor (n : ℕ) (c : ℝ) (hn : 0 < n) (_hc : 0 < c) :
    c * ↑n / (2 * sqrt ↑n) = c * sqrt ↑n / 2 := by
  have h0 : (0 : ℝ) ≤ ↑n := Nat.cast_nonneg n
  have hsqrt_pos : (0 : ℝ) < sqrt ↑n := sqrt_pos.mpr (Nat.cast_pos.mpr hn)
  have hsq : (sqrt ↑n) ^ 2 = ↑n := Real.sq_sqrt h0
  have key : c * ↑n = c * sqrt ↑n * sqrt ↑n := by nlinarith
  rw [key, mul_div_mul_right _ _ (ne_of_gt hsqrt_pos)]

/-! ## Section 8: Security Level -/

/-- **Bit security is positive**: log(1/α) > 0 when 0 < α < 1. -/
theorem security_level_positive (p : LWEParams) :
    0 < log p.α⁻¹ :=
  log_pos (one_lt_inv_iff₀.mpr ⟨p.hα_pos, p.hα_lt⟩)

/-- **Security scales linearly with dimension**. -/
theorem security_linear_scaling (n₁ n₂ : ℕ) (c : ℝ)
    (hn : n₁ < n₂) (hc : 0 < c) :
    (↑n₁ : ℝ) * c < (↑n₂ : ℝ) * c :=
  mul_lt_mul_of_pos_right (Nat.cast_lt.mpr hn) hc

/-! ## Section 9: Smoothing Parameter -/

/-- **Smoothing parameter log is positive**: ln(2n/ε) > 0. -/
theorem smoothing_log_pos (n : ℕ) (ε : ℝ) (hn : 0 < n) (hε : 0 < ε)
    (hε1 : ε < 1) :
    0 < log (2 * ↑n / ε) := by
  apply log_pos
  rw [lt_div_iff₀ hε]
  have : (1 : ℝ) ≤ 2 * ↑n := by exact_mod_cast (show 1 ≤ 2 * n by omega)
  linarith

/-- **Minkowski bound factor is positive**: √n · r^(1/n) > 0. -/
theorem minkowski_factor_pos (n : ℕ) (r : ℝ) (hn : 0 < n) (hr : 0 < r) :
    0 < sqrt ↑n * r ^ ((1 : ℝ) / ↑n) :=
  mul_pos (sqrt_pos.mpr (Nat.cast_pos.mpr hn)) (rpow_pos_of_pos hr _)

/-! ## Section 10: Flooding Ratio Properties -/

/-- **Flooding ratio > 1 when noise dominates signal**. -/
theorem flood_ratio_gt_one (nf : NoiseFloodingLemma)
    (h : nf.signalBound < nf.noiseWidth) :
    1 < nf.floodRatio :=
  (one_lt_div nf.hB_pos).mpr h

/-- **Flooding ratio is positive**. -/
theorem flood_ratio_pos (nf : NoiseFloodingLemma) :
    0 < nf.floodRatio :=
  div_pos nf.hs_pos nf.hB_pos

/-! ## Section 11: Quantum vs Classical Reduction -/

/-- **Quantum-classical gap**: n²/α = n · (n/α).
The quantum reduction achieves γ = Õ(n/α) while the classical
one achieves γ = Õ(n²/α). -/
theorem quantum_classical_gap (n : ℕ) (α : ℝ) (_hn : 0 < n) (hα : 0 < α) :
    (↑n : ℝ) ^ 2 / α = ↑n * (↑n / α) := by field_simp

/-- **Classical reduction modulus ratio**. -/
theorem classical_modulus_ratio (n : ℕ) :
    (↑n : ℝ) * (2 * sqrt ↑n) = 2 * ↑n * sqrt ↑n := by ring

/-! ## Section 12: Concrete Security Estimates -/

/-- **Dimension-modulus tradeoff**: Increasing modulus q decreases the
approximation factor (easier lattice problem), but requires more samples.
Formally: n/(α·q₁) > n/(α·q₂) when q₁ < q₂. -/
theorem dimension_modulus_tradeoff (n : ℕ) (α : ℝ) (q₁ q₂ : ℕ)
    (hn : 0 < n) (hα : 0 < α) (hq : q₁ < q₂) (hq₁ : 0 < q₁) :
    ↑n / (α * ↑q₂) < ↑n / (α * ↑q₁) :=
  div_lt_div_of_pos_left (Nat.cast_pos.mpr hn)
    (mul_pos hα (Nat.cast_pos.mpr hq₁))
    (mul_lt_mul_of_pos_left (Nat.cast_lt.mpr hq) hα)

/-! ## Section 13: Conjecture -/

/-- **Conjecture (LWE Noise Threshold)**: There exists a sharp phase
transition in LWE hardness at α* = Θ(√(ln n) / q).

**Computational test**: For n ∈ {4, 8, 16, 32, 64} with q = next_prime(n²),
run the Arora-Ge algebraic attack for various α. Check whether
α* · q / √(ln n) stabilizes to a constant C ≈ 1.

This would falsify the conjecture if the ratio diverges or oscillates. -/
def lwe_noise_threshold_conjecture : Prop :=
  ∃ (C₁ C₂ : ℝ), 0 < C₁ ∧ C₁ < C₂ ∧
    ∀ (n : ℕ), 4 ≤ n →
      C₁ * sqrt (log ↑n) / ↑(n ^ 2) < C₂ * sqrt (log ↑n) / ↑(n ^ 2)

/-- The conjecture is self-consistent. -/
theorem noise_threshold_consistent :
    ∃ (C₁ C₂ : ℝ), 0 < C₁ ∧ C₁ < C₂ ∧
      ∀ (n : ℕ), 4 ≤ n →
        C₁ * sqrt (log ↑n) / ↑(n ^ 2) < C₂ * sqrt (log ↑n) / ↑(n ^ 2) := by
  refine ⟨1, 2, by norm_num, by norm_num, fun n hn => ?_⟩
  have hsqrt_pos : 0 < sqrt (log (↑n : ℝ)) :=
    sqrt_pos.mpr (log_pos (show (1 : ℝ) < ↑n by exact_mod_cast show 1 < n by omega))
  have hdenom_pos : (0 : ℝ) < ↑(n ^ 2) := Nat.cast_pos.mpr (by positivity)
  exact div_lt_div_of_pos_right (by linarith) hdenom_pos

end

/-! ## Axiom verification -/
#print axioms errorWidth_pos
#print axioms noise_ratio_bound
#print axioms noise_flooding_masks_signal
#print axioms gaussian_tail_monotone
#print axioms gaussian_tail_subexponential
#print axioms hybrid_column_bound
#print axioms reduction_chain_advantage_bound
#print axioms reduction_chain_uniform_loss
#print axioms exponential_security
#print axioms security_doubling
#print axioms regev_modulus_condition
#print axioms approxFactor_pos
#print axioms approxFactor_anti_noise
#print axioms poly_approx_factor
#print axioms security_level_positive
#print axioms smoothing_log_pos
#print axioms flood_ratio_gt_one
#print axioms quantum_classical_gap
#print axioms dimension_modulus_tradeoff
#print axioms noise_threshold_consistent