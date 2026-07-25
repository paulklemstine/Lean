import Mathlib

/-! # `spectral_bound`: a sound tactic for eigenvalue magnitude estimates

This file develops a custom Lean 4 tactic, `spectral_bound`, that discharges
goals of the form "the magnitude of an eigenvalue is at most `B`" from a bound
on the absolute row sums of the matrix.  Its soundness is the
**Gershgorin-type row-sum bound**, proved here from first principles.

* `eigenvalue_rowsum_bound` : if `M *ᵥ v = l • v` with `v ≠ 0`, and every
  absolute row sum `∑ⱼ |Mᵢⱼ|` is `≤ B`, then `|l| ≤ B`.  This is the
  soundness certificate.
* `spectral_bound` : the tactic that applies the certificate.
* A concrete `2 × 2` example whose eigenvalue magnitudes are bounded by the
  tactic, plus a derived **spectral-radius / trace** style corollary.

-- !-- Lab Notes -- !--
Hypothesis: "Every eigenvalue `l` of a real matrix `M` satisfies
`|l| ≤ maxᵢ ∑ⱼ |Mᵢⱼ|` (the ∞-operator-norm / weak Gershgorin bound), and this
single inequality can be packaged as a reusable, sound tactic."
Experiment: Proved the bound by the classical 'largest coordinate' argument:
pick the index `i` maximising `|vᵢ|` (exists since `Fin n` is finite & nonempty);
positivity of `|vᵢ|` follows from `v ≠ 0`; then expand the `i`-th eigen-equation
and chain triangle inequality + monotonicity of the sum.
Analysis: The crux is `Finite.exists_max` for the argmax and
`le_of_mul_le_mul_right` to cancel the strictly positive `|vᵢ|`.  A first attempt
phrased the bound as `maxᵢ ∑ⱼ |Mᵢⱼ|` directly, which entangled the proof with
`Finset.sup'` bookkeeping; abstracting the bound to a hypothesis `B` with
`∀ i, ∑ⱼ |Mᵢⱼ| ≤ B` removed that friction without weakening the result (the
max instantiates `B`).
Critique: The hypothesis `v ≠ 0` is load-bearing (a zero "eigenvector" makes any
`l` admissible) and is genuinely used via `abs_pos`.  The bound is the *weak*
Gershgorin bound (a single global disc), not the per-disc union — we flag this
as the honest scope and list the sharpening as a future direction.
Synthesis: A soundness-certified eigenvalue tactic resting on one inductive-free
but inequality-rich lemma, demonstrated on an explicit matrix.
-- !-- end Lab Notes -- !--
-/

namespace Bridges.SpectralBoundTactic

open Matrix

/-! ## Soundness certificate: the weak Gershgorin row-sum bound -/

/-- **Soundness of `spectral_bound`.** If `l` is an eigenvalue of the real matrix
`M` with eigenvector `v ≠ 0`, and `B` bounds every absolute row sum of `M`, then
`|l| ≤ B`.  Proof: at the index `i` where `|vᵢ|` is maximal, expand the
eigen-equation and apply the triangle inequality. -/
theorem eigenvalue_rowsum_bound {n : ℕ} (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (l : ℝ)
    (hv : v ≠ 0) (heig : M.mulVec v = l • v)
    (B : ℝ) (hB : ∀ i, ∑ j, |M i j| ≤ B) : |l| ≤ B := by
  have : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  obtain ⟨i, hi⟩ := Finite.exists_max (fun j => |v j|)
  -- `|v i|` is the maximal coordinate, hence positive since `v ≠ 0`.
  have hvi_pos : 0 < |v i| := by
    rcases Function.ne_iff.mp hv with ⟨k, hk⟩
    exact lt_of_lt_of_le (abs_pos.mpr hk) (hi k)
  -- the `i`-th component of the eigen-equation.
  have hrow : ∑ j, M i j * v j = l * v i := by
    have := congrFun heig i
    simpa [Matrix.mulVec, dotProduct, Pi.smul_apply, smul_eq_mul] using this
  -- multiply the target by the positive quantity `|v i|` and chain estimates.
  have key : |l| * |v i| ≤ B * |v i| := by
    calc |l| * |v i| = |l * v i| := by rw [abs_mul]
      _ = |∑ j, M i j * v j| := by rw [hrow]
      _ ≤ ∑ j, |M i j * v j| := Finset.abs_sum_le_sum_abs _ _
      _ = ∑ j, |M i j| * |v j| := by simp [abs_mul]
      _ ≤ ∑ j, |M i j| * |v i| := by
            apply Finset.sum_le_sum
            intro j _
            exact mul_le_mul_of_nonneg_left (hi j) (abs_nonneg _)
      _ = (∑ j, |M i j|) * |v i| := by rw [Finset.sum_mul]
      _ ≤ B * |v i| := mul_le_mul_of_nonneg_right (hB i) (abs_nonneg _)
  exact le_of_mul_le_mul_right key hvi_pos

/-! ## The `spectral_bound` tactic

`spectral_bound` reduces an eigenvalue-magnitude goal `|l| ≤ B` to the row-sum
hypotheses required by `eigenvalue_rowsum_bound`.  Because it only `apply`s a
proved theorem, every goal it closes is true. -/
macro "spectral_bound" : tactic =>
  `(tactic| apply Bridges.SpectralBoundTactic.eigenvalue_rowsum_bound <;> assumption)

/-! ## Worked example: an explicit `2 × 2` matrix

Let `M = ![![1, 2], ![0, 3]]`.  Each absolute row sum is `≤ 3`, so every
eigenvalue satisfies `|l| ≤ 3`.  We feed the row-sum bound to the soundness
certificate. -/
example (v : Fin 2 → ℝ) (l : ℝ)
    (hv : v ≠ 0)
    (heig : (Matrix.of ![![1, 2], ![0, 3]] : Matrix (Fin 2) (Fin 2) ℝ).mulVec v = l • v) :
    |l| ≤ 3 := by
  apply eigenvalue_rowsum_bound (n := 2) (by norm_num) _ v l hv heig
  intro i
  fin_cases i <;>
    simp only [Fin.sum_univ_two, Matrix.of_apply] <;> norm_num [Matrix.cons_val]

/-- Demonstration of the `spectral_bound` macro itself: when the row-sum bound
and the eigen-data are in context, the tactic closes the magnitude goal. -/
example {n : ℕ} (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (l : ℝ)
    (hv : v ≠ 0) (heig : M.mulVec v = l • v)
    (B : ℝ) (hB : ∀ i, ∑ j, |M i j| ≤ B) : |l| ≤ B := by
  spectral_bound

/-! ## Corollary: real eigenvalues lie in a symmetric interval

The magnitude bound immediately yields two-sided bounds on a *real* eigenvalue,
the form most useful for downstream stability/convergence arguments. -/
theorem eigenvalue_interval {n : ℕ} (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (l : ℝ)
    (hv : v ≠ 0) (heig : M.mulVec v = l • v)
    (B : ℝ) (hB : ∀ i, ∑ j, |M i j| ≤ B) : -B ≤ l ∧ l ≤ B := by
  have h := eigenvalue_rowsum_bound hn M v l hv heig B hB
  exact abs_le.mp h

end Bridges.SpectralBoundTactic