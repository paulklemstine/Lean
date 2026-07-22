import Mathlib
import Physics.LandauerSecondLaw
import Physics.LandauerFluctuationBound

/-!
# Size-indexed Landauer bounds for Boolean-register reset

This file connects finite combinatorics and finite-temperature fluctuation relations.
The combinatorial side counts an `n`-bit register and proves that resetting it to one
state erases exactly `n` bits.  The analytic side applies the Jarzynski second law to
turn that exact cardinality loss into an expected-work lower bound.  An arbitrary
runtime function is carried through the theorem but does not enter the bound, making
precise that runtime and information loss are distinct size-indexed resources.

The final tail theorem strengthens the expectation statement: the probability of
beating the size-indexed Landauer threshold by a margin is exponentially bounded.
-/

noncomputable section

open BigOperators Real Finset
open JarzynskiLandauer LandauerSecondLaw LandauerFluctuationBound

namespace SizeIndexedLandauerBridge

/-- Reset every state of an `n`-bit Boolean register to the unique output state. -/
def bitReset (n : ℕ) : (Fin n → Bool) → Unit := fun _ => ()

/-- The Boolean register has exactly `2^n` logical states. -/
lemma card_bitRegister (n : ℕ) : Fintype.card (Fin n → Bool) = 2 ^ n := by
  simp

/-- Logical bits discarded by a reset: base-two logarithm of input states minus
base-two logarithm of reachable output states. -/
def discardedBits (n : ℕ) : ℝ :=
  Real.logb 2 (Fintype.card (Fin n → Bool)) - Real.logb 2 1

/-- Resetting an `n`-bit Boolean register erases exactly `n` bits. -/
theorem discardedBits_bitReset (n : ℕ) : discardedBits n = n := by
  unfold discardedBits
  rw [card_bitRegister]
  simp [Real.logb_pow, Real.logb_self_eq_one]

/--
**Size-indexed Landauer bridge.** If the physical reset of an `n`-bit register obeys
an input-size-indexed Jarzynski relation whose free-energy change is the combinatorial
information loss, then its expected work is at least `k T n log 2`.

`runtime` is deliberately arbitrary: no polynomial, exponential, or other runtime
hypothesis is used.  It records the separation between computational time and entropy
loss without identifying the two resources.
-/
theorem expected_work_ge_size_indexed_landauer
    {Ω : Type*} [Fintype Ω]
    (p : ℕ → Ω → ℝ) (W : ℕ → Ω → ℝ)
    (k T : ℝ) (hk : 0 < k) (hT : 0 < T)
    (hpmf : ∀ n, IsPMF (p n))
    (hfluctuation : ∀ n,
      JarzynskiCondition (p n) (W n) (k * T)⁻¹
        (k * T * (discardedBits n * Real.log 2))) :
    ∀ _runtime : ℕ → ℕ, ∀ n,
      k * T * (n * Real.log 2) ≤ expect (p n) (W n) := by
  intro _runtime n
  rw [← discardedBits_bitReset n]
  exact jarzynski_second_law (p n) (hpmf n) (W n) (k * T)⁻¹
    (k * T * (discardedBits n * Real.log 2))
    (inv_pos.2 (mul_pos hk hT)) (hfluctuation n)

/-- The same bridge stated for any lower bound `b(n)` on the bits discarded. -/
theorem expected_work_ge_discarded_bits
    {Ω : Type*} [Fintype Ω]
    (b : ℕ → ℝ) (p : ℕ → Ω → ℝ) (W : ℕ → Ω → ℝ)
    (k T : ℝ) (hk : 0 < k) (hT : 0 < T)
    (hpmf : ∀ n, IsPMF (p n))
    (hfluctuation : ∀ n,
      JarzynskiCondition (p n) (W n) (k * T)⁻¹
        (k * T * (discardedBits n * Real.log 2)))
    (hb : ∀ n, b n ≤ discardedBits n) :
    ∀ n, k * T * (b n * Real.log 2) ≤ expect (p n) (W n) := by
  intro n
  have hlog : 0 ≤ Real.log 2 := Real.log_nonneg (by norm_num)
  have hbits : b n * Real.log 2 ≤ discardedBits n * Real.log 2 :=
    mul_le_mul_of_nonneg_right (hb n) hlog
  have hcost : k * T * (b n * Real.log 2) ≤
      k * T * (discardedBits n * Real.log 2) :=
    mul_le_mul_of_nonneg_left hbits (mul_nonneg hk.le hT.le)
  exact hcost.trans (jarzynski_second_law (p n) (hpmf n) (W n) (k * T)⁻¹
    (k * T * (discardedBits n * Real.log 2))
    (inv_pos.2 (mul_pos hk hT)) (hfluctuation n))

/--
**Finite-size fluctuation refinement.** Under the same relation, the probability that
an `n`-bit reset beats its Landauer threshold by margin `ξ` is at most
`exp (-(kT)⁻¹ ξ)`.  Thus the bridge controls not only mean work but rare low-work runs.
-/
theorem size_indexed_violation_probability
    {Ω : Type*} [Fintype Ω]
    (p : ℕ → Ω → ℝ) (W : ℕ → Ω → ℝ)
    (k T : ℝ) (hk : 0 < k) (hT : 0 < T)
    (hpmf : ∀ n, IsPMF (p n))
    (hfluctuation : ∀ n,
      JarzynskiCondition (p n) (W n) (k * T)⁻¹
        (k * T * (discardedBits n * Real.log 2))) :
    ∀ n ξ,
      ∑ ω ∈ univ.filter (fun ω => W n ω < k * T * (n * Real.log 2) - ξ), p n ω
        ≤ Real.exp (-(k * T)⁻¹ * ξ) := by
  intro n ξ
  rw [← discardedBits_bitReset n]
  exact second_law_violation_bound (p n) (hpmf n) (W n) (k * T)⁻¹
    (k * T * (discardedBits n * Real.log 2))
    (inv_pos.2 (mul_pos hk hT)) (hfluctuation n) ξ

end SizeIndexedLandauerBridge