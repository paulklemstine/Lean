import Mathlib

/-!
# The Hermitian inner product reconstructs the complex Hopf fibre

This file addresses the **complex base case of Conjecture 1** of the
"Composition-Algebra Playground" research direction: a *single* algebraic device
— the Hermitian inner product `λ = z̄z' + w̄w'` of two unit vectors — recovers the
full fibre structure of the Hopf map `S³ → S²`.

Two unit vectors `a = (z, w)` and `b = (z', w')` in `ℂ²` lie on the same Hopf
fibre iff they are complex-proportional, `b = μ a` with `‖μ‖ = 1`.  We show the
inner-product witness `λ = ⟨a, b⟩` detects and reconstructs this:

* `abs_witness_le_one` : `‖λ‖ ≤ 1` always (Cauchy–Schwarz);
* `witness_of_proportional` : if `b = μ a` then `λ = μ`;
* `dist_sq_eq` : the key identity `‖z' - λz‖² + ‖w' - λw‖² = 1 - ‖λ‖²`;
* `reconstruct_fibre` : if `‖λ‖ = 1` then `b = λ a`, i.e. the two points are on
  the same fibre and the second is recovered from the first by the phase `λ`.
-/

open ComplexConjugate

namespace HopfWitness

/-- The Hermitian inner-product witness `λ = z̄z' + w̄w'`. -/
noncomputable def witness (z w z' w' : ℂ) : ℂ := conj z * z' + conj w * w'

/-- **Key squared-distance identity.**  For unit vectors `(z,w)`, `(z',w')`,
the squared distance from `(z',w')` to its projection `λ·(z,w)` equals
`1 - ‖λ‖²`, where `λ` is the inner-product witness. -/
theorem dist_sq_eq (z w z' w' : ℂ)
    (ha : ‖z‖ ^ 2 + ‖w‖ ^ 2 = 1) (hb : ‖z'‖ ^ 2 + ‖w'‖ ^ 2 = 1) :
    ‖z' - witness z w z' w' * z‖ ^ 2 + ‖w' - witness z w z' w' * w‖ ^ 2
      = 1 - ‖witness z w z' w'‖ ^ 2 := by
  unfold witness
  norm_num [Complex.normSq, Complex.sq_norm] at *
  grind

/-- **Cauchy–Schwarz.**  The witness of two unit vectors has modulus at most `1`. -/
theorem abs_witness_le_one (z w z' w' : ℂ)
    (ha : ‖z‖ ^ 2 + ‖w‖ ^ 2 = 1) (hb : ‖z'‖ ^ 2 + ‖w'‖ ^ 2 = 1) :
    ‖witness z w z' w'‖ ≤ 1 := by
  have h_nonneg : 1 - ‖witness z w z' w'‖ ^ 2 ≥ 0 :=
    dist_sq_eq z w z' w' ha hb ▸ add_nonneg (sq_nonneg _) (sq_nonneg _)
  nlinarith only [h_nonneg]

/-- **Forward direction.**  If the second vector is `μ` times the first,
`(z',w') = μ·(z,w)`, and the first is a unit vector, then the witness recovers
the multiplier exactly: `λ = μ`.  (No unit assumption on `μ` is required; when
`(z',w')` is itself a unit vector this forces `‖μ‖ = 1`.) -/
theorem witness_of_proportional (z w μ : ℂ)
    (ha : ‖z‖ ^ 2 + ‖w‖ ^ 2 = 1) :
    witness z w (μ * z) (μ * w) = μ := by
  unfold witness
  have hz : conj z * z = ((‖z‖ ^ 2 : ℝ) : ℂ) := by
    rw [mul_comm, Complex.mul_conj, Complex.normSq_eq_norm_sq]
  have hw : conj w * w = ((‖w‖ ^ 2 : ℝ) : ℂ) := by
    rw [mul_comm, Complex.mul_conj, Complex.normSq_eq_norm_sq]
  have hexp : conj z * (μ * z) + conj w * (μ * w) = μ * (conj z * z + conj w * w) := by ring
  rw [hexp, hz, hw, ← Complex.ofReal_add, ha]; norm_num

/-- **Fibre reconstruction.**  If the witness of two unit vectors has modulus
`1`, the second vector is exactly `λ` times the first: they lie on a common Hopf
fibre and `λ` is the connecting phase. -/
theorem reconstruct_fibre (z w z' w' : ℂ)
    (ha : ‖z‖ ^ 2 + ‖w‖ ^ 2 = 1) (hb : ‖z'‖ ^ 2 + ‖w'‖ ^ 2 = 1)
    (hlam : ‖witness z w z' w'‖ = 1) :
    z' = witness z w z' w' * z ∧ w' = witness z w z' w' * w := by
  have h_dist_sq : ‖z' - witness z w z' w' * z‖ ^ 2 + ‖w' - witness z w z' w' * w‖ ^ 2 = 0 := by
    rw [dist_sq_eq z w z' w' ha hb, hlam]; norm_num
  exact ⟨sub_eq_zero.mp (norm_eq_zero.mp (by contrapose! h_dist_sq; positivity)),
    sub_eq_zero.mp (norm_eq_zero.mp (by contrapose! h_dist_sq; positivity))⟩

end HopfWitness