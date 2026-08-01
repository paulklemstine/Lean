import Mathlib

/-!
# LWE Key Exchange: Reconciliation, Forward-Secrecy Hybrids, and Parameters

This file isolates three rigorous components of an LWE key-exchange analysis.
It proves a reconciliation margin for bounded accumulated error, gives a finite
probability model in which post-compromise views inherit the usual LWE hybrid
bound, and checks concrete arithmetic for a modulus and dimension commonly
used at the 128-bit design scale.  The final arithmetic theorem is deliberately
stated as a parameter check, not as an unconditional cryptanalytic security
claim.
-/

open Finset BigOperators

noncomputable section

namespace LWEKeyExchange

/-- A probability mass function on a finite set of protocol views. -/
structure FinitePMF (Ω : Type*) [Fintype Ω] where
  /-- Probability assigned to a view. -/
  mass : Ω → ℝ
  /-- Every probability is nonnegative. -/
  nonneg : ∀ x, 0 ≤ mass x
  /-- Probabilities sum to one. -/
  sum_mass : ∑ x, mass x = 1

/-- The `ℓ¹` distance between finite view distributions. -/
def l1Gap {Ω : Type*} [Fintype Ω] (P Q : FinitePMF Ω) : ℝ :=
  ∑ x, |P.mass x - Q.mass x|

/-- The family of post-compromise views, indexed by the exposed static key and
by the challenge session bit. -/
structure PostCompromiseExperiment (Static View : Type*) [Fintype View] where
  /-- Distribution of the complete view after exposure of a static key. -/
  view : Static → Bool → FinitePMF View

/-- Quantitative forward secrecy: exposing any static key leaves the two session
bit experiments within `ε` in `ℓ¹` distance. -/
def ForwardSecure {Static View : Type*} [Fintype View]
    (E : PostCompromiseExperiment Static View) (ε : ℝ) : Prop :=
  ∀ sk, l1Gap (E.view sk false) (E.view sk true) ≤ ε

/-- Triangle inequality for finite protocol views. -/
theorem l1Gap_triangle {Ω : Type*} [Fintype Ω] (P Q R : FinitePMF Ω) :
    l1Gap P R ≤ l1Gap P Q + l1Gap Q R := by
  simp only [l1Gap]
  rw [← sum_add_distrib]
  exact Finset.sum_le_sum fun x _ => abs_sub_le _ _ _

/-- **Forward secrecy from post-exposure LWE hybrids.**

If, for every exposed static key, both challenge-session views are close to one
common ideal view that does not depend on the session bit, then the protocol is
forward secure.  In an LWE instantiation the two assumptions are precisely the
post-exposure decisional-LWE game hops. -/
theorem forwardSecure_of_common_ideal
    {Static View : Type*} [Fintype View]
    (E : PostCompromiseExperiment Static View)
    (ideal : Static → FinitePMF View) (ε₀ ε₁ : ℝ)
    (hzero : ∀ sk, l1Gap (E.view sk false) (ideal sk) ≤ ε₀)
    (hone : ∀ sk, l1Gap (E.view sk true) (ideal sk) ≤ ε₁) :
    ForwardSecure E (ε₀ + ε₁) := by
  intro sk
  have h := l1Gap_triangle (E.view sk false) (ideal sk) (E.view sk true)
  have hsymm : l1Gap (ideal sk) (E.view sk true) =
      l1Gap (E.view sk true) (ideal sk) := by
    simp [l1Gap, abs_sub_comm]
  rw [hsymm] at h
  exact h.trans (add_le_add (hzero sk) (hone sk))

/-- A uniform per-branch post-exposure LWE loss `ε` gives total forward-secrecy
loss at most `2ε`. -/
theorem forwardSecure_of_symmetric_lwe
    {Static View : Type*} [Fintype View]
    (E : PostCompromiseExperiment Static View)
    (ideal : Static → FinitePMF View) (ε : ℝ)
    (hclose : ∀ sk b, l1Gap (E.view sk b) (ideal sk) ≤ ε) :
    ForwardSecure E (2 * ε) := by
  simpa [two_mul] using
    (forwardSecure_of_common_ideal E ideal ε ε
      (fun sk => hclose sk false) (fun sk => hclose sk true))

/-- **Accumulated reconciliation error.** If each of `m` LWE error terms has
magnitude at most `B`, their sum has magnitude at most `mB`. -/
theorem accumulated_error_bound (m : ℕ) (error : Fin m → ℤ) (B : ℤ)
    (herror : ∀ i, |error i| ≤ B) :
    |∑ i, error i| ≤ (m : ℤ) * B := by
  calc
    |∑ i, error i| ≤ ∑ i, |error i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : Fin m, B := Finset.sum_le_sum fun i _ => herror i
    _ = (m : ℤ) * B := by simp

/-- **Reconciliation correctness margin.** If the accumulated error is bounded
by `mB` and `4mB < q`, then it lies strictly inside the quarter-modulus decoding
radius. -/
theorem reconciliation_margin (q m : ℕ) (B : ℤ) (error : Fin m → ℤ)
    (herror : ∀ i, |error i| ≤ B)
    (hmargin : 4 * ((m : ℤ) * B) < q) :
    4 * |∑ i, error i| < q := by
  have hsum := accumulated_error_bound m error B herror
  omega

/-- Concrete dimension used in the checked parameter profile. -/
def concreteDimension : ℕ := 512

/-- Concrete prime modulus used in the checked parameter profile. -/
def concreteModulus : ℕ := 12289

/-- Number of bounded errors accumulated by the concrete reconciliation check. -/
def concreteErrorCount : ℕ := 1024

/-- Per-error integer magnitude used in the concrete reconciliation check. -/
def concreteErrorBound : ℤ := 3

/-- The concrete modulus is prime, so nonzero multipliers form a field and the
standard prime-modulus LWE rerandomisation argument applies. -/
theorem concreteModulus_prime : Nat.Prime concreteModulus := by
  norm_num [concreteModulus]

/-- The raw secret-vector search space has at least `2^128` elements.  This is a
combinatorial parameter check and is not identified with a complete security
estimate. -/
theorem concrete_keyspace_ge_128 :
    2 ^ 128 ≤ concreteModulus ^ concreteDimension := by
  rw [concreteModulus, concreteDimension]
  calc
    2 ^ 128 ≤ 12289 ^ 128 := Nat.pow_le_pow_left (by norm_num) 128
    _ ≤ 12289 ^ 512 := pow_le_pow_right₀ (by norm_num) (by norm_num)

/-- The concrete profile has a strict quarter-modulus reconciliation margin for
1024 errors of magnitude at most 3: `4·1024·3 < 12289`. -/
theorem concrete_reconciliation_inequality :
    4 * ((concreteErrorCount : ℤ) * concreteErrorBound) < concreteModulus := by
  norm_num [concreteErrorCount, concreteErrorBound, concreteModulus]

/-- Every error vector satisfying the concrete bound lies inside the strict
quarter-modulus reconciliation radius. -/
theorem concrete_reconciliation_correct
    (error : Fin concreteErrorCount → ℤ)
    (herror : ∀ i, |error i| ≤ concreteErrorBound) :
    4 * |∑ i, error i| < concreteModulus := by
  exact reconciliation_margin concreteModulus concreteErrorCount
    concreteErrorBound error herror concrete_reconciliation_inequality

end LWEKeyExchange

end