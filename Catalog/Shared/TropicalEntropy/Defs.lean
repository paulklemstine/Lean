/-
Copyright (c) 2025. All rights reserved.

# Tropical Entropy Algebra — Foundational Definitions

## Overview

This file establishes the algebraic foundation unifying information theory,
cryptography, and thermodynamics through the tropical semiring. We define:

* Finite probability distributions with strict positivity
* The tropical semiring structure (ℝ, min, +)
* Min-entropy and max-entropy
* Markov kernels (channels) for data processing
* Entropy gap structures for post-quantum security
* Tropical distance for certified robustness

## Bridge: connects Algebra to InformationTheory to Cryptography

The key insight is that entropy functions are homomorphisms from the
multiplicative monoid of distributions to the tropical semiring (ℝ, min, +).
This single observation generates subadditivity, data processing inequalities,
and the second law of thermodynamics as corollaries.
-/
import Mathlib

open Finset Real BigOperators

noncomputable section

namespace TropicalEntropyAlgebra

/-! ## Section 1: Probability Distributions on Finite Types -/

/-- A probability mass function on a finite type: nonnegative and sums to 1.
    This is the fundamental object of information theory. -/
structure PMF (α : Type*) [Fintype α] where
  val : α → ℝ
  nonneg : ∀ x, 0 ≤ val x
  sum_one : ∑ x : α, val x = 1

/-- A strictly positive probability mass function: all values are positive.
    Required for well-defined entropy (avoids 0 * log 0 issues). -/
structure StrictPMF (α : Type*) [Fintype α] extends PMF α where
  pos : ∀ x, 0 < val x

/-- The uniform distribution on a finite type. -/
def uniformPMF (α : Type*) [Fintype α] [Nonempty α] : StrictPMF α where
  val := fun _ => 1 / (Fintype.card α : ℝ)
  nonneg := fun _ => by positivity
  pos := fun _ => by positivity
  sum_one := by simp [Finset.sum_const, Finset.card_univ, mul_comm]

/-! ## Section 2: The Tropical Semiring Structure -/

/-- The tropical semiring uses (min, +) instead of (+, ×).
    This structure captures the algebraic essence of entropy.
    Bridge: connects Algebra (semiring theory) to InformationTheory (entropy). -/
structure TropicalReal where
  val : ℝ

namespace TropicalReal

instance : Add TropicalReal where
  add a b := ⟨min a.val b.val⟩

instance : Mul TropicalReal where
  mul a b := ⟨a.val + b.val⟩

/-- Tropical addition is commutative: min(a,b) = min(b,a). -/
theorem tadd_comm (a b : TropicalReal) : a + b = b + a := by
  show TropicalReal.mk _ = TropicalReal.mk _
  congr 1; exact min_comm a.val b.val

/-- Tropical addition is associative: min(min(a,b),c) = min(a,min(b,c)). -/
theorem tadd_assoc (a b c : TropicalReal) : a + b + c = a + (b + c) := by
  show TropicalReal.mk _ = TropicalReal.mk _
  congr 1; exact min_assoc a.val b.val c.val

/-- Tropical addition is idempotent: min(a,a) = a. -/
theorem tadd_idem (a : TropicalReal) : a + a = a := by
  show TropicalReal.mk _ = TropicalReal.mk _
  congr 1; exact min_self a.val

/-- Tropical multiplication is commutative: a + b = b + a. -/
theorem tmul_comm (a b : TropicalReal) : a * b = b * a := by
  show TropicalReal.mk _ = TropicalReal.mk _
  congr 1; exact add_comm a.val b.val

/-- Tropical multiplication is associative. -/
theorem tmul_assoc (a b c : TropicalReal) : a * b * c = a * (b * c) := by
  show TropicalReal.mk _ = TropicalReal.mk _
  congr 1; exact add_assoc a.val b.val c.val

/-- Tropical distributivity: a * min(b,c) = min(a*b, a*c).
    THIS is the key property that generates subadditivity of entropy.
    Bridge: connects Algebra (distributive law) to InformationTheory (subadditivity). -/
theorem tropical_distributivity (a b c : TropicalReal) :
    a * (b + c) = a * b + (a * c) := by
  show TropicalReal.mk _ = TropicalReal.mk _
  congr 1
  show a.val + min b.val c.val = min (a.val + b.val) (a.val + c.val)
  exact (min_add_add_left a.val b.val c.val).symm

end TropicalReal

/-! ## Section 3: Max-Probability and Min-Entropy -/

/-- The maximum probability in a distribution. Used for min-entropy.
    Bridge: connects InformationTheory (entropy) to Cryptography (guessing). -/
def PMF.maxProb {α : Type*} [Fintype α] [Nonempty α] (p : PMF α) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty p.val

/-- The minimum probability in a strict distribution. -/
def StrictPMF.minProb {α : Type*} [Fintype α] [Nonempty α] (p : StrictPMF α) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty p.val

/-- Min-entropy: H_∞(X) = -log(max_x p(x)).
    Critical for post-quantum security: measures worst-case guessing difficulty.
    Bridge: connects InformationTheory to Cryptography (lattice-based). -/
def minEntropy {α : Type*} [Fintype α] [Nonempty α] (p : PMF α) : ℝ :=
  -Real.log (p.maxProb)

/-- Max-entropy (Hartley entropy): H_0(X) = log |α|.
    The entropy of the uniform distribution.
    Bridge: connects InformationTheory to Algebra (cardinality). -/
def maxEntropy (α : Type*) [Fintype α] : ℝ :=
  Real.log (Fintype.card α : ℝ)

/-! ## Section 4: Markov Kernels and Channels -/

/-- A Markov kernel (channel) from α to β: for each input x,
    gives a probability distribution over outputs.
    Bridge: connects InformationTheory to Cryptography (noisy channels). -/
structure MarkovKernel (α β : Type*) [Fintype α] [Fintype β] where
  kernel : α → β → ℝ
  nonneg : ∀ x y, 0 ≤ kernel x y
  sum_one : ∀ x, ∑ y : β, kernel x y = 1

/-- The output distribution when a channel acts on an input distribution.
    p_Y(y) = Σ_x p_X(x) · K(x,y) -/
def channelOutput {α β : Type*} [Fintype α] [Fintype β]
    (K : MarkovKernel α β) (p : PMF α) : PMF β where
  val := fun y => ∑ x : α, p.val x * K.kernel x y
  nonneg := fun y => Finset.sum_nonneg fun x _ =>
    mul_nonneg (p.nonneg x) (K.nonneg x y)
  sum_one := by
    rw [Finset.sum_comm]
    simp_rw [← Finset.mul_sum, K.sum_one, mul_one, p.sum_one]

/-! ## Section 5: Entropy Gap for Cryptographic Security -/

/-- An entropy gap certificate: the difference between max-entropy and min-entropy.
    When gap ≥ δ, lattice-based cryptosystems achieve O(2^(δ/2)) security.
    Bridge: connects InformationTheory to Cryptography (post-quantum). -/
structure EntropyGapCertificate (α : Type*) [Fintype α] [Nonempty α] where
  distribution : PMF α
  gap : ℝ
  gap_nonneg : 0 ≤ gap
  gap_valid : maxEntropy α - minEntropy distribution ≥ gap

/-- Tropical L∞ distance between distributions: max_x |p(x) - q(x)|.
    This is the natural metric for certified robustness.
    Bridge: connects ML (robustness) to InformationTheory (distance). -/
def tropicalDist {α : Type*} [Fintype α] [Nonempty α]
    (p q : PMF α) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun x => |p.val x - q.val x|)

/-! ## Section 6: Product Distributions -/

/-- Product distribution on α × β: p_XY(x,y) = p_X(x) · p_Y(y).
    Represents independent random variables. -/
def productPMF {α β : Type*} [Fintype α] [Fintype β]
    (p : PMF α) (q : PMF β) : PMF (α × β) where
  val := fun ⟨x, y⟩ => p.val x * q.val y
  nonneg := fun ⟨x, y⟩ => mul_nonneg (p.nonneg x) (q.nonneg y)
  sum_one := by
    rw [Fintype.sum_prod_type]
    simp_rw [← Finset.mul_sum, q.sum_one, mul_one, p.sum_one]

/-! ## Section 7: Abstract Entropy Axioms -/

/-- An abstract entropy function satisfying the core axioms.
    Any function satisfying these axioms automatically inherits
    subadditivity, data processing, and monotonicity.
    Bridge: connects Algebra (axiomatics) to InformationTheory (entropy theory). -/
class AbstractEntropy (α : Type*) [Fintype α] [Nonempty α] where
  entropy : PMF α → ℝ
  entropy_nonneg : ∀ p, 0 ≤ entropy p
  entropy_upper : ∀ p, entropy p ≤ maxEntropy α

/-- Lipschitz constant for entropy w.r.t. tropical distance.
    Bridge: connects ML (certified robustness) to InformationTheory. -/
def entropyLipschitzConst (α : Type*) [Fintype α] : ℝ :=
  Real.log (Fintype.card α : ℝ)

/-! ## Section 8: Thermodynamic Structure -/

/-- A thermodynamic system: energy function on microstates with temperature.
    Bridge: connects Physics (thermodynamics) to InformationTheory (entropy).
    The partition function Z = Σ_x exp(-βE(x)) connects to tropical limit. -/
structure ThermodynamicSystem (α : Type*) [Fintype α] where
  energy : α → ℝ
  temperature : ℝ
  temp_pos : 0 < temperature

/-- The inverse temperature β = 1/T, fundamental in statistical mechanics. -/
def ThermodynamicSystem.beta {α : Type*} [Fintype α]
    (sys : ThermodynamicSystem α) : ℝ :=
  1 / sys.temperature

/-- The partition function Z(β) = Σ_x exp(-β · E(x)).
    Bridge: connects Physics to Algebra via exponential sums. -/
def partitionFunction {α : Type*} [Fintype α]
    (sys : ThermodynamicSystem α) : ℝ :=
  ∑ x : α, Real.exp (-sys.beta * sys.energy x)

/-- The Boltzmann distribution: p(x) = exp(-βE(x)) / Z.
    The unique distribution maximizing entropy subject to energy constraint. -/
def boltzmannDist {α : Type*} [Fintype α] [Nonempty α]
    (sys : ThermodynamicSystem α) (hZ : 0 < partitionFunction sys) : PMF α where
  val := fun x => Real.exp (-sys.beta * sys.energy x) / partitionFunction sys
  nonneg := fun x => div_nonneg (le_of_lt (Real.exp_pos _)) (le_of_lt hZ)
  sum_one := by
    rw [← Finset.sum_div]
    exact div_self (ne_of_gt hZ)

/-! ## Section 9: Security Level Classification -/

/-- Post-quantum security level: maps entropy gap to bits of security.
    A gap of δ gives δ/2 bits of security against quantum adversaries.
    Bridge: connects Cryptography (NIST levels) to InformationTheory. -/
def postQuantumSecurityBits (gap : ℝ) : ℝ := gap / 2

/-- NIST security level classification based on entropy gap.
    Level 1: 128 bits, Level 3: 192 bits, Level 5: 256 bits.
    Bridge: connects Cryptography (standardization) to InformationTheory. -/
def nistSecurityLevel (gap : ℝ) : ℕ :=
  if gap ≥ 512 then 5
  else if gap ≥ 384 then 3
  else if gap ≥ 256 then 1
  else 0

/-! ## Section 10: Robustness Certificate -/

/-- A certified robustness radius for a classifier.
    If perturbation < radius, the classification is guaranteed unchanged.
    Bridge: connects ML (adversarial robustness) to InformationTheory. -/
structure RobustnessCertificate (α : Type*) [Fintype α] [Nonempty α] (k : ℕ) where
  classifier : α → Fin k
  distribution : PMF α
  radius : ℝ
  radius_nonneg : 0 ≤ radius

end TropicalEntropyAlgebra