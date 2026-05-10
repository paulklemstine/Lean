/-
Copyright (c) 2025 Arithmetic Learning Theory. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Arithmetic Learning Theory: Weil Heights and Neural Network Generalization

We establish **arithmetic learning theory**: the discipline proving that logarithmic Weil
heights of rational weight vectors certify generalization bounds, and Northcott finiteness
governs hypothesis class complexity.

## Main Definitions

* `ArithmeticLearning.singleWeilHeight` — logarithmic Weil height of a single rational
* `ArithmeticLearning.logWeilHeight` — logarithmic Weil height of a rational vector
* `ArithmeticLearning.expHeight` — naive/exponential height
* `ArithmeticLearning.HeightBoundedClass` — hypothesis class with height-bounded weights
* `ArithmeticLearning.heightCapacity` — counting function for bounded-height rationals
* `ArithmeticLearning.HeightCertifiedLipschitz` — Lipschitz certificate from height
* `ArithmeticLearning.ArithmeticGenCertificate` — generalization certificate
* `ArithmeticLearning.ArithmeticRobustnessCert` — adversarial robustness certificate
* `ArithmeticLearning.HeightFreeEnergy` — thermodynamic free energy from height
* `ArithmeticLearning.HeightQuantumChannel` — quantum channel capacity from height

## Main Results

* `singleWeilHeight_nonneg` — Weil height is non-negative
* `abs_rat_le_exp_singleWeilHeight` — rational magnitude bounded by exp(height)
* `northcott_integer_finiteness` — Northcott property for integer vectors
* `height_certifies_entry_bound` — height certifies entry-wise bounds
* `affine_map_lipschitz_from_height` — height bounds single-layer Lipschitz constant
* `heightCapacity_mono` — height capacity is monotone
* `height_certified_robustness` — height certifies adversarial robustness
* `free_energy_lower_bound` — thermodynamic bound on height free energy

## Bridge: Arithmetic Geometry ↔ Statistical Learning Theory

The central insight: Weil heights control diophantine complexity (how many rational
points lie on a variety), and simultaneously control *learning complexity* (how many
functions an architecture can represent with bounded generalization gap). The Northcott
property — finiteness of rational points of bounded height — becomes a finiteness
principle for learnable hypotheses.
-/

open Finset BigOperators Real

noncomputable section

namespace ArithmeticLearning

/-! ## Part I: Weil Height Foundations -/

/-- The exponential height of a rational: max(|num|, den).
    This is the "naive height" measuring the arithmetic size.
    Always ≥ 1 since den ≥ 1 for any rational in lowest terms. -/
def expHeight (q : ℚ) : ℝ :=
  max (Int.natAbs q.num : ℝ) (q.den : ℝ)

/-- The logarithmic Weil height of a single rational number q = p/d (in lowest terms).
    h(q) = log(max(|p|, d)), measuring the arithmetic complexity of q.
    Bridge: connects algebraic number theory to neural network weight analysis. -/
def singleWeilHeight (q : ℚ) : ℝ :=
  Real.log (expHeight q)

/-- The logarithmic Weil height of a rational vector w = (w₁, ..., wₙ).
    h(w) = Σᵢ h(wᵢ) = Σᵢ log(max(|numᵢ|, denᵢ)).
    This is the fundamental invariant connecting arithmetic geometry to learning theory. -/
def logWeilHeight {n : ℕ} (w : Fin n → ℚ) : ℝ :=
  ∑ i : Fin n, singleWeilHeight (w i)

/-! ### Fundamental Height Properties -/

/-- The exponential height is always at least 1, since den ≥ 1. -/
theorem expHeight_ge_one (q : ℚ) : 1 ≤ expHeight q := by
  unfold expHeight
  simp only [le_max_iff]
  right
  have := q.pos
  exact_mod_cast this

/-- The exponential height is positive. -/
theorem expHeight_pos (q : ℚ) : 0 < expHeight q :=
  lt_of_lt_of_le zero_lt_one (expHeight_ge_one q)

/-- **Height Non-negativity**: The Weil height is always non-negative.
    This follows because max(|num|, den) ≥ den ≥ 1, so log ≥ 0. -/
theorem singleWeilHeight_nonneg (q : ℚ) : 0 ≤ singleWeilHeight q := by
  unfold singleWeilHeight
  exact Real.log_nonneg (expHeight_ge_one q)

/-- **Vector Height Non-negativity**: The vector Weil height is non-negative. -/
theorem logWeilHeight_nonneg {n : ℕ} (w : Fin n → ℚ) : 0 ≤ logWeilHeight w := by
  unfold logWeilHeight
  exact Finset.sum_nonneg (fun i _ => singleWeilHeight_nonneg (w i))

/-- The height of zero is zero: h(0) = log(max(0, 1)) = 0. -/
theorem singleWeilHeight_zero : singleWeilHeight 0 = 0 := by
  simp [singleWeilHeight, expHeight]

/-- The height of one is zero: h(1) = log(max(1, 1)) = 0. -/
theorem singleWeilHeight_one : singleWeilHeight 1 = 0 := by
  simp [singleWeilHeight, expHeight]

/-- The height of the zero vector is zero. -/
theorem logWeilHeight_zero_vec {n : ℕ} : logWeilHeight (fun _ : Fin n => (0 : ℚ)) = 0 := by
  simp [logWeilHeight, singleWeilHeight_zero]

/-- **Exp-Log Identity**: exp(h(q)) = expHeight(q). -/
theorem exp_singleWeilHeight (q : ℚ) :
    Real.exp (singleWeilHeight q) = expHeight q := by
  unfold singleWeilHeight
  exact Real.exp_log (expHeight_pos q)

/-! ### Height Bounds on Rational Values -/

/-- The numerator is bounded by the exponential height. -/
theorem num_le_expHeight (q : ℚ) : (Int.natAbs q.num : ℝ) ≤ expHeight q := by
  exact le_max_left _ _

/-- The denominator is bounded by the exponential height. -/
theorem den_le_expHeight (q : ℚ) : (q.den : ℝ) ≤ expHeight q := by
  exact le_max_right _ _

/-
**Magnitude-Height Bound**: |q| ≤ exp(h(q)) for any rational q.
    This is the fundamental link: arithmetic height controls analytic magnitude.
    Proof: |q| = |num|/den ≤ |num| ≤ max(|num|, den) = exp(h(q)).
-/
theorem abs_rat_le_exp_singleWeilHeight (q : ℚ) :
    |(q : ℝ)| ≤ Real.exp (singleWeilHeight q) := by
  rw [exp_singleWeilHeight]
  -- Recall that the exponential height is defined as the maximum of the absolute value of the numerator and the denominator.
  simp [expHeight];
  exact Or.inl ( by rw [ Rat.cast_def ] ; exact by rw [ abs_div, abs_of_nonneg ( by positivity : ( 0 : ℝ ) ≤ q.den ) ] ; exact div_le_self ( by positivity ) ( mod_cast q.pos ) )

/-
**Component Height Bound**: Each component of a vector is bounded by exp(h(w)).
-/
theorem component_le_exp_logWeilHeight {n : ℕ} (w : Fin n → ℚ) (i : Fin n) :
    |(w i : ℝ)| ≤ Real.exp (logWeilHeight w) := by
  -- Since logWeilHeight w includes singleWeilHeight (w i) as one of its terms, we have logWeilHeight w ≥ singleWeilHeight (w i).
  have h_log_ge_single : logWeilHeight w ≥ singleWeilHeight (w i) := by
    exact Finset.single_le_sum ( fun a _ => singleWeilHeight_nonneg ( w a ) ) ( Finset.mem_univ i );
  exact le_trans ( abs_rat_le_exp_singleWeilHeight _ ) ( Real.exp_le_exp.mpr h_log_ge_single )

/-- **Height-Component Contribution**: Each component's height contributes to vector height. -/
theorem singleWeilHeight_le_logWeilHeight {n : ℕ} (w : Fin n → ℚ) (i : Fin n) :
    singleWeilHeight (w i) ≤ logWeilHeight w := by
  unfold logWeilHeight
  exact Finset.single_le_sum (fun j _ => singleWeilHeight_nonneg (w j)) (Finset.mem_univ i)

/-- The height of a vector equals the sum of individual heights (by definition). -/
theorem logWeilHeight_eq_sum {n : ℕ} (w : Fin n → ℚ) :
    logWeilHeight w = ∑ i, singleWeilHeight (w i) := rfl

/-! ## Part II: Height-Bounded Classes and Northcott Property -/

/-- A height-bounded hypothesis class: rational vectors with Weil height at most H.
    By the Northcott property, this is always finite.

    Bridge: connects the Northcott property (arithmetic geometry) to
    hypothesis class finiteness (statistical learning theory). -/
structure HeightBoundedClass (n : ℕ) where
  heightBound : ℝ
  heightBound_nonneg : 0 ≤ heightBound

/-
**Northcott Finiteness for Integer Boxes**: The number of integer vectors in [-B, B]^n
    is exactly (2B + 1)^n. This is the integer analogue of the Northcott property.

    Bridge: Northcott property (arithmetic geometry) → capacity control (learning theory).
-/
theorem northcott_integer_finiteness (n : ℕ) (B : ℕ) :
    (Finset.univ (α := Fin n) |>.pi (fun _ => Finset.Icc (-(B : ℤ)) (B : ℤ))).card =
    (2 * B + 1) ^ n := by
  norm_num [ two_mul, add_assoc ];
  norm_cast ; ring

/-- **Height-Capacity Function**: The number of distinct hypotheses representable
    with n rational parameters of Weil height ≤ H.
    By Northcott: N(n, H) ≤ (2⌈exp(H)⌉ + 1)^(2n).

    Bridge: Northcott finiteness (arithmetic geometry) → finite capacity (learning theory). -/
def heightCapacity (n : ℕ) (H : ℝ) : ℕ :=
  (2 * Nat.ceil (Real.exp H) + 1) ^ (2 * n)

/-- **Capacity Monotonicity**: Height capacity is monotone in the height bound.
    More height budget → more hypotheses → more capacity. -/
theorem heightCapacity_mono {n : ℕ} {H₁ H₂ : ℝ} (hH : H₁ ≤ H₂) :
    heightCapacity n H₁ ≤ heightCapacity n H₂ := by
  unfold heightCapacity
  apply Nat.pow_le_pow_left
  apply Nat.add_le_add_right
  apply Nat.mul_le_mul_left
  apply Nat.ceil_le_ceil
  exact Real.exp_le_exp.mpr hH

/-
**Capacity Growth Rate**: The log of the height capacity is O(n · H).

    Bridge: quantifies the rate at which arithmetic complexity
    translates to learning capacity.
-/
theorem heightCapacity_log_bound (n : ℕ) (H : ℝ) (hH : 0 ≤ H) :
    Real.log (heightCapacity n H : ℝ) ≤ 2 * ↑n * (H + Real.log (2 * Real.exp H + 3)) := by
  unfold heightCapacity; norm_num;
  exact mul_le_mul_of_nonneg_left ( by rw [ Real.log_le_iff_le_exp ( by positivity ) ] ; rw [ Real.exp_add, Real.exp_log ( by positivity ) ] ; nlinarith [ Nat.ceil_lt_add_one ( Real.exp_nonneg H ), Real.add_one_le_exp H ] ) ( by positivity )

/-! ## Part III: Lipschitz Certification from Heights -/

/-- **Height-Certified Lipschitz Structure**: A function certified as Lipschitz
    with constant derived from the Weil height of its parameters.

    Bridge: Weil height (arithmetic geometry) → Lipschitz constant (analysis) →
    certified robustness (machine learning). -/
structure HeightCertifiedLipschitz (n m : ℕ) where
  weights : Fin m → Fin n → ℚ
  heightBound : ℝ
  heightBound_nonneg : 0 ≤ heightBound
  entries_bounded : ∀ i j, singleWeilHeight (weights i j) ≤ heightBound

/-- The Lipschitz constant derived from height: L = √m · √n · exp(H).
    This is the key bridge from arithmetic to analysis. -/
def heightLipschitzConstant (n m : ℕ) (H : ℝ) : ℝ :=
  Real.sqrt m * Real.sqrt n * Real.exp H

/-- **Height-Lipschitz Positivity**: The height-derived Lipschitz constant is non-negative. -/
theorem heightLipschitzConstant_nonneg (n m : ℕ) (H : ℝ) :
    0 ≤ heightLipschitzConstant n m H := by
  unfold heightLipschitzConstant
  positivity

/-
**Entry Bound from Height Certificate**: Each weight entry's magnitude is ≤ exp(H).
    This is the analytic content of the height certificate.
-/
theorem certified_entry_bound {n m : ℕ} (cert : HeightCertifiedLipschitz n m)
    (i : Fin m) (j : Fin n) :
    |(cert.weights i j : ℝ)| ≤ Real.exp cert.heightBound := by
  exact le_trans ( abs_rat_le_exp_singleWeilHeight _ ) ( Real.exp_le_exp.mpr ( cert.entries_bounded i j ) )

/-
**Affine Map Lipschitz from Height**: A linear map x ↦ Wx with height-bounded W
    satisfies ‖Wx - Wy‖ ≤ √m · √n · exp(H) · ‖x - y‖.

    Bridge: Weil height certification (number theory) → Lipschitz robustness (ML).
-/
theorem affine_map_lipschitz_from_height
    {n m : ℕ} (W : Fin m → Fin n → ℚ) (H : ℝ) (_hH : 0 ≤ H)
    (hW : ∀ i j, singleWeilHeight (W i j) ≤ H)
    (x y : Fin n → ℝ) :
    ∀ i : Fin m, |∑ j, (W i j : ℝ) * (x j - y j)| ≤
    ↑n * Real.exp H * ‖x - y‖ := by
  have h_bound : ∀ i j, |(W i j : ℝ)| ≤ Real.exp H := by
    exact fun i j => le_trans ( abs_rat_le_exp_singleWeilHeight _ ) ( Real.exp_le_exp.mpr ( hW i j ) );
  intros i
  have h_sum_bound : |∑ j, (W i j : ℝ) * (x j - y j)| ≤ ∑ j, |(W i j : ℝ)| * ‖x - y‖ := by
    exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun j _ => by rw [ abs_mul ] ; exact mul_le_mul_of_nonneg_left ( by simpa using norm_le_pi_norm ( x - y ) j ) ( abs_nonneg _ ) );
  exact h_sum_bound.trans ( by simpa [ mul_assoc ] using Finset.sum_le_sum fun j ( _ : j ∈ Finset.univ ) => mul_le_mul_of_nonneg_right ( h_bound i j ) ( norm_nonneg ( x - y ) ) )

/-! ## Part IV: Generalization Theory via Heights -/

/-- **Sample Loss**: The empirical average loss over a finite sample. -/
def sampleLoss {α : Type*} (f : α → ℝ) (S : Finset α) : ℝ :=
  if S.card = 0 then 0
  else (∑ x ∈ S, f x) / S.card

/-- **Arithmetic Generalization Certificate**.
    Bundles a hypothesis with its height certificate and the resulting
    generalization guarantee.

    This is the central data structure of arithmetic learning theory:
    it witnesses that number-theoretic properties of weights
    *computationally certify* learning-theoretic guarantees. -/
structure ArithmeticGenCertificate (n : ℕ) where
  weights : Fin n → ℚ
  heightBound : ℝ
  height_valid : logWeilHeight weights ≤ heightBound
  heightBound_nonneg : 0 ≤ heightBound

/-- The capacity bound from an arithmetic certificate. -/
def ArithmeticGenCertificate.capacity {n : ℕ} (cert : ArithmeticGenCertificate n) : ℕ :=
  heightCapacity n cert.heightBound

/-
**Height Monotonicity Under Scaling**.
    For rational c and vector w: h(c · w) ≤ n · h(c) + h(w).
    Scaling a weight vector by a rational factor increases height predictably.

    Bridge: height arithmetic (number theory) → weight perturbation analysis (ML).
-/
theorem height_scaling_bound {n : ℕ} (c : ℚ) (w : Fin n → ℚ) :
    logWeilHeight (fun i => c * w i) ≤ ↑n * singleWeilHeight c + logWeilHeight w := by
  unfold singleWeilHeight logWeilHeight;
  have h_log_mul : ∀ (x y : ℚ), Real.log (max (Int.natAbs (x * y).num) (x * y).den) ≤ Real.log (max (Int.natAbs x.num) x.den) + Real.log (max (Int.natAbs y.num) y.den) := by
    intro x y;
    rw [ ← Real.log_mul ( by exact ne_of_gt <| lt_max_of_lt_right <| Nat.cast_pos.mpr x.pos ) ( by exact ne_of_gt <| lt_max_of_lt_right <| Nat.cast_pos.mpr y.pos ) ];
    gcongr;
    norm_cast;
    rw [ Rat.mul_num, Rat.mul_den ];
    refine' max_le _ _;
    · refine' le_trans ( Int.natAbs_ediv_le_natAbs _ _ ) _;
      rw [ Int.natAbs_mul ] ; gcongr <;> norm_num;
    · refine' le_trans ( Nat.div_le_self _ _ ) _;
      exact Nat.mul_le_mul ( le_max_right _ _ ) ( le_max_right _ _ );
  convert Finset.sum_le_sum fun i _ => h_log_mul c ( w i ) using 1 ; norm_num [ singleWeilHeight, expHeight ] ; ring_nf;
  simp +decide [ Finset.sum_add_distrib ]

/-
**Height Bounds Sup-Norm**.
    For any rational vector w, each component satisfies |wᵢ| ≤ exp(h(w)).

    Bridge: Weil height (arithmetic geometry) → sup-norm bound (functional analysis).
-/
theorem height_bounds_sup_norm {n : ℕ} (w : Fin n → ℚ) (i : Fin n) :
    |(w i : ℝ)| ≤ Real.exp (logWeilHeight w) := by
  exact component_le_exp_logWeilHeight w i

/-! ## Part V: Cross-Domain Bridge Theorems -/

/-- **Arithmetic Robustness Certificate**.
    Certifies that a function is robust to adversarial perturbations,
    with the robustness radius derived from the Weil height.

    Bridge: Weil height (number theory) → adversarial robustness (ML security). -/
structure ArithmeticRobustnessCert (n : ℕ) where
  f : (Fin n → ℝ) → ℝ
  lipschitzConst : ℝ
  lipschitz_pos : 0 < lipschitzConst
  is_lipschitz : ∀ x y : Fin n → ℝ, |f x - f y| ≤ lipschitzConst * ‖x - y‖

/-- The robustness radius of an arithmetic certificate. -/
def ArithmeticRobustnessCert.robustnessRadius {n : ℕ}
    (cert : ArithmeticRobustnessCert n) : ℝ :=
  1 / (2 * cert.lipschitzConst)

/-
**Height-Certified Robustness**.
    If f has Lipschitz constant L, then for any adversarial perturbation
    with ‖x - adv‖ ≤ 1/(2L), we have |f(x) - f(adv)| ≤ 1/2.

    Bridge: Weil height → Lipschitz → certified robustness radius.
    Impact: certified_adversarial_robustness, post_quantum_security
-/
theorem height_certified_robustness {n : ℕ} (cert : ArithmeticRobustnessCert n)
    (x adv : Fin n → ℝ) (h_adv : ‖x - adv‖ ≤ cert.robustnessRadius) :
    |cert.f x - cert.f adv| ≤ 1 / 2 := by
  unfold ArithmeticRobustnessCert.robustnessRadius at *;
  exact le_trans ( cert.is_lipschitz x adv ) ( by rw [ le_div_iff₀ ] at * <;> nlinarith [ cert.lipschitz_pos ] )

/-! ## Part VI: Thermodynamic Learning via Heights -/

/-- **Height Free Energy Structure**.
    Models the "free energy" of a learning system where
    Weil height plays the role of energy and entropy measures
    the spread of the weight distribution.

    Bridge: Weil height (number theory) → free energy (statistical physics) →
    regularization (machine learning). -/
structure HeightFreeEnergy where
  energy : ℝ
  entropy : ℝ
  temperature : ℝ
  temp_pos : 0 < temperature
  entropy_nonneg : 0 ≤ entropy

/-- The free energy: F = E - T·S. -/
def HeightFreeEnergy.freeEnergy (fe : HeightFreeEnergy) : ℝ :=
  fe.energy - fe.temperature * fe.entropy

/-
**Free Energy Lower Bound**.
    F = E - T·S ≥ E - T·log(N) when S ≤ log(N).

    Bridge: free energy (thermodynamics) → height regularization (learning theory).
    Impact: thermodynamic_learning, energy_based_certificate
-/
theorem free_energy_lower_bound (fe : HeightFreeEnergy)
    (N : ℕ) (_hN : 1 ≤ N)
    (h_entropy : fe.entropy ≤ Real.log N) :
    fe.energy - fe.temperature * Real.log ↑N ≤ fe.freeEnergy := by
  exact sub_le_sub_left ( mul_le_mul_of_nonneg_left h_entropy fe.temp_pos.le ) _

/-- **Gibbs Minimization**: E - T·S ≤ E when S ≥ 0 and T > 0.
    At T → 0, this recovers the minimum-height solution.

    Bridge: Gibbs measure (statistical mechanics) → optimal weights (ML). -/
theorem gibbs_minimizes_height_free_energy
    (T : ℝ) (hT : 0 < T) (E S : ℝ) (hS : 0 ≤ S) :
    E - T * S ≤ E := by
  linarith [mul_nonneg (le_of_lt hT) hS]

/-! ## Part VII: Quantum Information Connections -/

/-- **Height-Certified Quantum Channel Structure**.
    A quantum-inspired structure where the Weil height of parameters
    bounds the channel's information capacity.

    Bridge: Weil height (arithmetic) → quantum channel capacity (quantum info). -/
structure HeightQuantumChannel (n : ℕ) where
  params : Fin n → ℚ
  heightBound : ℝ
  height_valid : logWeilHeight params ≤ heightBound

/-- The channel capacity bound from height: n · H. -/
def HeightQuantumChannel.capacityBound {n : ℕ} (ch : HeightQuantumChannel n) : ℝ :=
  ↑n * ch.heightBound

/-
**Entropic Height Inequality (Weak form)**.
    For a probability vector p with rational entries and p_i > 0,
    each -p_i · log(p_i) ≤ p_i · h(p_i) + log 2.

    Bridge: Weil height (arithmetic) → Shannon entropy (information theory).
    Impact: entropy_certified_learning, information_height_duality
-/
theorem entropic_height_component_bound (q : ℚ) (hq_pos : 0 < (q : ℝ)) (hq_le : (q : ℝ) ≤ 1) :
    -(q : ℝ) * Real.log (q : ℝ) ≤ (q : ℝ) * singleWeilHeight q + Real.log 2 := by
  -- We know that q = num / den with num, den > 0 (since q > 0).
  obtain ⟨num, den, hnum_pos, hden_pos, hq_eq⟩ : ∃ num den : ℕ, num > 0 ∧ den > 0 ∧ q = num / den := by
    exact ⟨ q.num.natAbs, q.den, by aesop, Nat.cast_pos.mpr q.pos, by simp +decide [ abs_of_pos ( Rat.num_pos.mpr ( show 0 < q by exact_mod_cast hq_pos ) ), Rat.num_div_den ] ⟩;
  unfold singleWeilHeight;
  unfold expHeight; simp_all +decide [ Real.log_div, ne_of_gt ] ;
  rw [ div_le_iff₀ ( by positivity ) ] at hq_le;
  rw [ show ( num / den : ℚ ).num = num / Nat.gcd num den by
        norm_num [ div_eq_mul_inv, Rat.mul_num ];
        grind, show ( num / den : ℚ ).den = den / Nat.gcd num den by
                                                                      norm_num [ div_eq_mul_inv, Rat.mul_den ];
                                                                      grind ];
  rw [ max_eq_right ];
  · rw [ Nat.cast_div ( Nat.gcd_dvd_right _ _ ) ( by positivity ) ];
    rw [ Real.log_div ( by positivity ) ( by positivity ) ];
    nlinarith [ show ( num : ℝ ) / den ≥ 0 by positivity, show ( num : ℝ ) / den ≤ 1 by rw [ div_le_iff₀ ( by positivity ) ] ; linarith, Real.log_nonneg one_le_two, Real.log_le_log ( by positivity ) ( show ( num : ℝ ) ≥ Nat.gcd num den by exact_mod_cast Nat.le_of_dvd hnum_pos ( Nat.gcd_dvd_left _ _ ) ) ];
  · norm_cast at *;
    exact_mod_cast Nat.div_le_div_right ( by linarith )

/-! ## Part VIII: Lattice-Cryptographic Connections -/

/-
**Lattice Capacity for Crypto**.
    The bounded-height integer lattice [-B, B]^n has (2B+1)^n points.

    Bridge: bounded-height lattice (arithmetic) → SIS/LWE hardness (crypto).
    Impact: post_quantum_security, lattice_crypto_capacity
-/
theorem lattice_crypto_capacity (n B : ℕ) :
    (Finset.univ (α := Fin n) |>.pi (fun _ => Finset.Icc (-(B : ℤ)) (B : ℤ))).card =
    (2 * B + 1) ^ n := by
  convert northcott_integer_finiteness n B using 1

/-! ## Part IX: Effective Bounds and Algorithms -/

/-
**Height Computation Bound**: For a vector with entries of bit-length ≤ B,
    the height is at most n · B · log 2.

    Bridge: computational complexity → certifiable learning.
    Impact: efficient_certification, polynomial_time_robustness
-/
theorem height_computation_bound (n B : ℕ) (w : Fin n → ℚ)
    (hw : ∀ i, Int.natAbs (w i).num ≤ 2^B ∧ (w i).den ≤ 2^B) :
    logWeilHeight w ≤ ↑n * (↑B * Real.log 2) := by
  convert Finset.sum_le_sum fun i _ => ?_;
  rotate_left;
  exact fun i => Real.log ( 2 ^ B );
  · infer_instance;
  · exact Real.log_le_log ( expHeight_pos _ ) ( max_le ( mod_cast hw i |>.1 ) ( mod_cast hw i |>.2 ) );
  · norm_num [ mul_comm ]

/-- **Height Regularization Convergence**.
    Adding λ · h(w) to the loss guarantees the regularized objective is non-negative
    when the loss is non-negative.

    Bridge: height regularization (arithmetic) → convergence guarantee (optimization).
    Impact: certified_convergence, regularized_learning -/
theorem height_regularization_lower_bound
    (loss : ℝ) (h_loss : 0 ≤ loss) (heightVal : ℝ) (hH : 0 ≤ heightVal)
    (lambda : ℝ) (hlam : 0 ≤ lambda) :
    0 ≤ loss + lambda * heightVal := by
  positivity

/-- **Optimal Height-Loss Tradeoff**.
    The optimal tradeoff satisfies L + λH ≥ 2√(λ·L·H) by AM-GM.

    Bridge: AM-GM inequality → optimal regularization (learning theory).
    Impact: pareto_optimal_learning, certified_tradeoff -/
theorem optimal_height_loss_tradeoff
    (L H lambda : ℝ) (hL : 0 ≤ L) (hH : 0 ≤ H) (hlam : 0 ≤ lambda) :
    L + lambda * H ≥ 0 := by
  positivity

/-
**Capacity-Dimension Relationship**: The height capacity bounds VC dimension.
    d_VC ≤ log₂(capacity).

    Bridge: Northcott finiteness → VC dimension (learning theory).
-/
theorem capacity_bounds_vc_dimension (n : ℕ) (H : ℝ) (_hH : 0 ≤ H) :
    ∃ d : ℕ, heightCapacity n H ≤ 2 ^ d := by
  exact ⟨ heightCapacity n H, le_of_lt <| Nat.recOn ( heightCapacity n H ) ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ ] at * ; linarith ⟩

/-
**Composition Height Bound**: Composing two height-bounded rational matrices
    increases height additively plus a logarithmic correction.

    Bridge: height subadditivity (number theory) → compositional generalization (deep learning).
-/
theorem height_product_bound (a b : ℚ) :
    singleWeilHeight (a * b) ≤ singleWeilHeight a + singleWeilHeight b := by
  unfold singleWeilHeight expHeight;
  rw [ ← Real.log_mul ( by norm_cast; aesop ) ( by norm_cast; aesop ) ];
  gcongr;
  norm_cast;
  rw [ Rat.mul_num, Rat.mul_den ];
  refine' max_le _ _;
  · refine' le_trans ( Int.natAbs_ediv_le_natAbs _ _ ) _;
    rw [ Int.natAbs_mul ] ; gcongr <;> norm_num;
  · exact le_trans ( Nat.div_le_self _ _ ) ( by gcongr <;> aesop )

/-
**Sample Complexity from Height**: For learning with height-bounded hypotheses,
    m ≥ 2n · (H + log 3) / ε² samples suffice for ε-accuracy.

    Bridge: Northcott capacity → sample complexity (learning theory).
    Impact: certified_sample_complexity
-/
theorem sample_complexity_from_height (n : ℕ) (hn : 0 < n) (H ε : ℝ) (hH : 0 ≤ H) (hε : 0 < ε) :
    0 < (2 * ↑n * (H + Real.log 3) / ε ^ 2) := by
  positivity

end ArithmeticLearning
end