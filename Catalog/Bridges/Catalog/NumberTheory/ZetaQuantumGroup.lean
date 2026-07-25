import Mathlib

/-!
# Structural tests for a proposed zeta–Casimir correspondence

This file isolates rigorous consequences of using the classical quadratic labels
`n(n+1)` as a putative Casimir spectrum.  The results are independent of any
unproved assertion about Riemann zeros or quantum groups.
-/

namespace ZetaQuantumGroup

/-- The proposed quadratic Casimir eigenvalue attached to label `n`. -/
def casimirEigenvalue (n : ℕ) : ℝ := (n : ℝ) * (n + 1)

/-- The quadratic Casimir labels are strictly increasing. -/
theorem casimirEigenvalue_strictMono : StrictMono casimirEigenvalue := by
  exact fun m n h => by unfold casimirEigenvalue; nlinarith [ ( by norm_cast : ( m : ℝ ) + 1 ≤ n ) ] ;

/-- Consecutive quadratic Casimir labels have the exact gap `2(n+1)`. -/
theorem casimirEigenvalue_gap (n : ℕ) :
    casimirEigenvalue (n + 1) - casimirEigenvalue n = 2 * (n + 1 : ℝ) := by
  unfold casimirEigenvalue; push_cast; ring;

/-- The second finite difference of the Casimir spectrum is constantly two. -/
theorem casimirEigenvalue_secondDifference (n : ℕ) :
    casimirEigenvalue (n + 2) - 2 * casimirEigenvalue (n + 1) +
      casimirEigenvalue n = 2 := by
  unfold casimirEigenvalue; push_cast; ring;

/-- A nonconstant affine transform of the quadratic spectrum cannot have equal
successive gaps. Thus an affine spectral map cannot produce an arithmetic
progression, even locally at two adjacent gaps. -/
theorem affine_transform_adjacent_gaps_ne
    (a b : ℝ) (ha : a ≠ 0) (n : ℕ) :
    (a * casimirEigenvalue (n + 1) + b) -
        (a * casimirEigenvalue n + b) ≠
      (a * casimirEigenvalue (n + 2) + b) -
        (a * casimirEigenvalue (n + 1) + b) := by
  norm_num [ casimirEigenvalue ] ; ring_nf; aesop;

/-- Without regularity conditions on the spectral map, *every* real sequence
can be represented as a function of the quadratic Casimir labels. Consequently,
a bare assertion `γₙ = f(n(n+1))` has no arithmetic content by itself. -/
theorem arbitrary_sequence_has_spectral_map (γ : ℕ → ℝ) :
    ∃ f : ℝ → ℝ, ∀ n : ℕ, f (casimirEigenvalue n) = γ n := by
  obtain ⟨casimirEigenvalue_inv, h_inv⟩ : ∃ (casimirEigenvalue_inv : ℝ → ℕ), ∀ n, casimirEigenvalue_inv (casimirEigenvalue n) = n := by
    exact ⟨ Function.invFun casimirEigenvalue, fun n => Function.leftInverse_invFun ( show Function.Injective casimirEigenvalue from by exact fun m n hmn => by simpa using StrictMono.injective ( casimirEigenvalue_strictMono ) hmn ) n ⟩;
  exact ⟨ fun x => γ ( casimirEigenvalue_inv x ), fun n => by simp +decide [ h_inv ] ⟩

/-- For positive labels, applying the ordinary logarithm to the quadratic
spectrum is trapped between `2 log n` and `2 log(n+1)`. In particular, the
literal logarithm of `n(n+1)` has logarithmic rather than `n/log n` scale. -/
theorem log_casimirEigenvalue_bounds (n : ℕ) (hn : 1 ≤ n) :
    2 * Real.log (n : ℝ) ≤ Real.log (casimirEigenvalue n) ∧
      Real.log (casimirEigenvalue n) ≤ 2 * Real.log (n + 1 : ℝ) := by
  unfold casimirEigenvalue;
  exact ⟨ by rw [ ← Real.log_rpow, Real.log_le_log_iff ] <;> norm_cast <;> nlinarith, by rw [ ← Real.log_rpow, Real.log_le_log_iff ] <;> norm_cast <;> nlinarith ⟩

/-- The phase selected from a real spectral parameter lies on the complex unit
circle, as required for a unit-modulus deformation parameter. -/
noncomputable def qPhase (γ : ℝ) : ℂ := Complex.exp ((2 * Real.pi * γ : ℝ) * Complex.I)

/-- The proposed deformation phase always has norm one. -/
theorem norm_qPhase (γ : ℝ) : ‖qPhase γ‖ = 1 := by
  unfold qPhase; norm_num [ Complex.norm_exp ] ;

/-- The proposed deformation phase is therefore never zero. -/
theorem qPhase_ne_zero (γ : ℝ) : qPhase γ ≠ 0 := by
  exact Complex.exp_ne_zero _

end ZetaQuantumGroup