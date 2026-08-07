import Mathlib

/-! # The Hermitian witness of a Hopf fibre

For two points `(z, w)` and `(z', w')` of `ℂ²` the *Hermitian witness* is their inner
product

`witness z w z' w' = conj z * z' + conj w * w'`.

Cauchy–Schwarz bounds its modulus by the product of the two norms, and — this is the
content of the file — **equality reconstructs the phase**: if both points are on the unit
three-sphere and the witness has modulus one, then `(z', w') = u · (z, w)` for the unit
complex number `u = witness z w z' w'`.  This is the algebraic heart of the statement that
the fibres of the Hopf map are circles.

Main results.

* `witness_normSq_add` — the exact defect identity
  `‖v − s·u‖² = ‖v‖² − 2|s|² + |s|²‖u‖²` for `s` the witness; it is an unconditional
  polynomial identity, so the Cauchy–Schwarz inequality and its equality case both follow.
* `witness_normSq_le` — Cauchy–Schwarz in `ℂ²`.
* `reconstruct_fibre` — the equality case: the witness *is* the phase.
-/

namespace HopfWitness

open ComplexConjugate

/-- The Hermitian inner product of `(z, w)` and `(z', w')` in `ℂ²`. -/
noncomputable def witness (z w z' w' : ℂ) : ℂ := conj z * z' + conj w * w'

/-- **The exact Cauchy–Schwarz defect identity in `ℂ²`.** -/
theorem witness_normSq_add (z w z' w' : ℂ) :
    Complex.normSq (z' - witness z w z' w' * z) + Complex.normSq (w' - witness z w z' w' * w)
      = (Complex.normSq z' + Complex.normSq w')
        - 2 * Complex.normSq (witness z w z' w')
        + Complex.normSq (witness z w z' w') * (Complex.normSq z + Complex.normSq w) := by
  simp only [witness, Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
    Complex.mul_im, Complex.add_re, Complex.add_im, Complex.conj_re, Complex.conj_im]
  ring

/-- **Cauchy–Schwarz in `ℂ²`.** -/
theorem witness_normSq_le (z w z' w' : ℂ) (ha : Complex.normSq z + Complex.normSq w = 1) :
    Complex.normSq (witness z w z' w') ≤ Complex.normSq z' + Complex.normSq w' := by
  have h := witness_normSq_add z w z' w'
  rw [ha, mul_one] at h
  nlinarith [Complex.normSq_nonneg (z' - witness z w z' w' * z),
    Complex.normSq_nonneg (w' - witness z w z' w' * w)]

/-- **Equality reconstructs the phase.**  If two unit vectors of `ℂ²` have a Hermitian
witness of modulus one, then the second is the first multiplied by that witness; in
particular they lie on a common Hopf fibre. -/
theorem reconstruct_fibre (z w z' w' : ℂ)
    (ha : ‖z‖ ^ 2 + ‖w‖ ^ 2 = 1) (hb : ‖z'‖ ^ 2 + ‖w'‖ ^ 2 = 1)
    (heq : ‖witness z w z' w'‖ = 1) :
    z' = witness z w z' w' * z ∧ w' = witness z w z' w' * w := by
  have ha' : Complex.normSq z + Complex.normSq w = 1 := by
    rw [Complex.normSq_eq_norm_sq, Complex.normSq_eq_norm_sq]; exact ha
  have hb' : Complex.normSq z' + Complex.normSq w' = 1 := by
    rw [Complex.normSq_eq_norm_sq, Complex.normSq_eq_norm_sq]; exact hb
  have hs : Complex.normSq (witness z w z' w') = 1 := by
    rw [Complex.normSq_eq_norm_sq, heq]; norm_num
  have h := witness_normSq_add z w z' w'
  rw [ha', hb', hs] at h
  norm_num at h
  have h1 : Complex.normSq (z' - witness z w z' w' * z) = 0 := by
    nlinarith [Complex.normSq_nonneg (z' - witness z w z' w' * z),
      Complex.normSq_nonneg (w' - witness z w z' w' * w)]
  have h2 : Complex.normSq (w' - witness z w z' w' * w) = 0 := by
    nlinarith [Complex.normSq_nonneg (z' - witness z w z' w' * z),
      Complex.normSq_nonneg (w' - witness z w z' w' * w)]
  constructor
  · have := Complex.normSq_eq_zero.mp h1
    linear_combination this
  · have := Complex.normSq_eq_zero.mp h2
    linear_combination this

end HopfWitness