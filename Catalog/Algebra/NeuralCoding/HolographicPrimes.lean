import Mathlib

/-!
# Finite prime partition functions

This file isolates a rigorous algebraic core of the proposed “prime hologram.”  A
finite collection of boundary factors is expanded as a sum over occupation-number
configurations, and its finite-cutoff defect from the Euler factors is computed
exactly.  No claim about AdS/CFT, zero statistics, or the Riemann hypothesis is
made.
-/

namespace HolographicPrimes

open scoped BigOperators

/-- The primes in a finite set of natural numbers. -/
def primesIn (S : Finset ℕ) : Finset ℕ := S.filter Nat.Prime

/-- A finite occupation-number partition function with local weights `w p`. -/
def cutoffPartition (S : Finset ℕ) (w : ℕ → ℚ) (m : ℕ) : ℚ :=
  ∏ p ∈ primesIn S, ∑ k ∈ Finset.range m, (w p) ^ k

/-- The corresponding finite product of Euler denominators. -/
def eulerDenominator (S : Finset ℕ) (w : ℕ → ℚ) : ℚ :=
  ∏ p ∈ primesIn S, (1 - w p)

/-- The cutoff partition function is exactly a sum over all boundary
occupation-number configurations. -/
theorem cutoffPartition_eq_sum_configurations
    (S : Finset ℕ) (w : ℕ → ℚ) (m : ℕ) :
    cutoffPartition S w m =
      ∑ a ∈ Fintype.piFinset (fun _ : {p // p ∈ primesIn S} => Finset.range m),
        ∏ p : {p // p ∈ primesIn S}, (w p.1) ^ (a p) := by
  simp +decide [cutoffPartition, primesIn]
  rw [Finset.prod_sum]
  refine' Finset.sum_bij (fun f hf => fun x => f x x.2) _ _ _ _ <;> simp +decide
  · simp +contextual [funext_iff]
  · exact fun b hb => ⟨ fun x hx => b ⟨ x, by aesop ⟩, hb, rfl ⟩

/-- Exact finite-cutoff Euler identity. Multiplication by all local Euler
denominators leaves precisely the product of cutoff defects. -/
theorem cutoffPartition_mul_eulerDenominator
    (S : Finset ℕ) (w : ℕ → ℚ) (m : ℕ) :
    cutoffPartition S w m * eulerDenominator S w =
      ∏ p ∈ primesIn S, (1 - (w p) ^ m) := by
  convert Finset.prod_mul_distrib.symm using 1
  exact Finset.prod_congr rfl fun x _ => by rw [geom_sum_mul_neg]

/-- The residue object `ZMod p` has natural cardinality `p`; in particular,
a prime boundary ring has exactly `p` elements. -/
theorem boundary_cardinality (p : ℕ) : Nat.card (ZMod p) = p := by
  exact Nat.card_zmod p

/-- An inverse-cardinality local weight is the usual reciprocal Euler weight. -/
theorem boundary_inverse_weight (p : ℕ) :
    ((Nat.card (ZMod p) : ℚ)⁻¹) = (p : ℚ)⁻¹ := by
  rw [boundary_cardinality]

/-- Specializing the exact cutoff identity to reciprocal boundary cardinalities
produces a finite, fully algebraic prime partition-function formula. -/
theorem boundary_partition_identity (S : Finset ℕ) (m : ℕ) :
    cutoffPartition S (fun p => ((Nat.card (ZMod p) : ℚ)⁻¹)) m *
        eulerDenominator S (fun p => ((Nat.card (ZMod p) : ℚ)⁻¹)) =
      ∏ p ∈ primesIn S, (1 - ((p : ℚ)⁻¹) ^ m) := by
  convert cutoffPartition_mul_eulerDenominator S _ m using 1
  exact Finset.prod_congr rfl fun p _ => by rw [boundary_inverse_weight]

/-- At primes two and three with three occupation levels, the partition sum,
Euler denominator, and cutoff-corrected product have the stated exact values. -/
theorem two_prime_three_level_example :
    cutoffPartition {2, 3} (fun p => (p : ℚ)⁻¹) 3 = 91 / 36 ∧
      eulerDenominator {2, 3} (fun p => (p : ℚ)⁻¹) = 1 / 3 ∧
      cutoffPartition {2, 3} (fun p => (p : ℚ)⁻¹) 3 *
          eulerDenominator {2, 3} (fun p => (p : ℚ)⁻¹) = 91 / 108 := by
  have hprimes : primesIn {2, 3} = {2, 3} := by
    ext p
    simp only [primesIn, Finset.mem_filter, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · exact fun h => h.1
    · intro h
      refine ⟨h, ?_⟩
      rcases h with rfl | rfl
      · exact Nat.prime_two
      · exact Nat.prime_three
  rw [show cutoffPartition {2, 3} (fun p => (p : ℚ)⁻¹) 3 =
      ∏ p ∈ primesIn {2, 3}, ∑ k ∈ Finset.range 3, ((p : ℚ)⁻¹) ^ k by rfl]
  simp [eulerDenominator, hprimes, Finset.sum_range_succ]
  norm_num

end HolographicPrimes