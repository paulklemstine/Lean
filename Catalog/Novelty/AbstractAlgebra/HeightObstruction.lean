/-
# The Global Obstruction as a Néron–Tate Height Pairing

For quotients of higher genus, the generalized Giampietro–Darmon factorization
of the infinite product of `p`-adic cross-ratios into local intersection
multiplicities holds only **up to a global obstruction given by the Néron–Tate
height pairing on the Jacobian**.

The Néron–Tate height is a *positive semidefinite symmetric bilinear form* on
`MW(J) ⊗ ℝ`, positive definite modulo torsion. We model it by a real inner
product on a space `V` (playing the role of `MW(J) ⊗ ℝ`), and we define the
**global obstruction** attached to two Heegner divisors `D, E` by the Gram
determinant of their height pairing:
`Obs(D, E) = ⟨D,D⟩ ⟨E,E⟩ - ⟨D,E⟩²`.

## Main results
* `neronTateObstruction_nonneg` — the global obstruction is always `≥ 0`
  (Cauchy–Schwarz / positivity of the height pairing).
* `sq_real_inner_le` — the underlying Cauchy–Schwarz bound.
* `neronTateObstruction_of_height_zero` — **genus-0 exactness**: if a Heegner
  divisor is a torsion class (height `0`), the obstruction vanishes and the
  factorization is exact.
* `neronTateObstruction_of_parallel` — the obstruction vanishes for proportional
  (linearly dependent) Heegner divisors.
* `neronTateObstruction_symm` — the obstruction is symmetric in `D, E`.
-/
import Mathlib

namespace GiampietroDarmon

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]

/-- The **global obstruction** to exact factorization attached to two Heegner
divisors `D, E`, modelled by the Gram determinant of the Néron–Tate height
pairing:
`Obs(D, E) = ⟨D,D⟩ ⟨E,E⟩ - ⟨D,E⟩²`. -/
noncomputable def neronTateObstruction (D E : V) : ℝ :=
  inner ℝ D D * inner ℝ E E - (inner ℝ D E) ^ 2

/-
Cauchy–Schwarz for the (real) height pairing, in squared form.
-/
theorem sq_real_inner_le (D E : V) :
    (inner ℝ D E : ℝ) ^ 2 ≤ inner ℝ D D * inner ℝ E E := by
  nlinarith [ sq_nonneg ( inner ℝ D D - inner ℝ E E ), abs_le.mp ( abs_real_inner_le_norm D E ), real_inner_self_eq_norm_sq D, real_inner_self_eq_norm_sq E ]

/-
**Positivity of the global obstruction.** The Néron–Tate height pairing is
positive semidefinite, so the obstruction is always nonnegative.
-/
theorem neronTateObstruction_nonneg (D E : V) : 0 ≤ neronTateObstruction D E := by
  exact sub_nonneg_of_le ( sq_real_inner_le D E )

/-
The global obstruction is symmetric in its two arguments.
-/
theorem neronTateObstruction_symm (D E : V) :
    neronTateObstruction D E = neronTateObstruction E D := by
  unfold neronTateObstruction;
  rw [ mul_comm, real_inner_comm E D ]

/-
**Genus-0 exactness.** If a Heegner divisor `D` is a torsion class — i.e. has
vanishing Néron–Tate height (`‖D‖ = 0`), as happens when the Jacobian of the
quotient is trivial (genus `0`) — then the obstruction vanishes and the
factorization is exact.
-/
theorem neronTateObstruction_of_height_zero {D : V} (hD : ‖D‖ = 0) (E : V) :
    neronTateObstruction D E = 0 := by
  have hD0 : D = 0 := by simpa using hD
  subst hD0
  simp [neronTateObstruction]

/-
The global obstruction vanishes for proportional (linearly dependent) Heegner
divisors `D = t • E`.
-/
theorem neronTateObstruction_of_parallel (t : ℝ) (E : V) :
    neronTateObstruction (t • E) E = 0 := by
  unfold neronTateObstruction
  simp only [real_inner_smul_left, real_inner_smul_right]
  ring

end GiampietroDarmon