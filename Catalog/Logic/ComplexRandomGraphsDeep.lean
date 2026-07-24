/-
# Complex-weighted undirected random graphs, II: spectral line-locking and global invariants

This file deepens the theory of fixed-amplitude complex-weighted undirected graphs
developed in `ComplexRandomGraphs`.  There the adjacency matrix of an edge relation
weighted by a single complex amplitude `z` was shown to factor as `z • B`, with `B`
a real symmetric zero-one matrix, and to be normal with eigenpairs transported along
the complex line spanned by `z`.

Here we complete the spectral picture.  The main theorem, `spectrum_line_locked`,
shows that *every* eigenvalue of the weighted matrix (for a symmetric edge relation
and nonzero amplitude) lies exactly on the real line through the origin in the
direction of `z`: there is a genuine real number `μ` with eigenvalue `z · μ`.  This
is the sharpest possible obstruction to a circular-law interpretation — the spectrum
does not fill a disk, it collapses onto a single line.  We also record the global
multiplicative invariants (determinant, trace) and the complete-graph outlier for
arbitrary order.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): If the fixed-amplitude undirected model rotates a Hermitian
real spectrum, then the entire spectrum of `z • B` should be pinned to the line
`ℝ · z`, not merely individual transported eigenpairs.  Bolder: this should hold for
*abstract* eigenpairs (any nonzero vector with `A v = λ v`), not only for the
spectral-theorem eigenvalues, because reality of a Hermitian Rayleigh quotient is
elementary.
Experiment (Stage 2): The core lemma `isHermitian_eigenvalue_real` computes the
Rayleigh quotient `star v ⬝ᵥ A.mulVec v` two ways using `A.conjTranspose = A`,
forcing `star λ = λ`.  Line-locking then divides by the amplitude and re-uses the
indicator Hermitian structure from the companion file.  The complete-graph outlier
generalizes the four-vertex example to every order `n ≥ 3` via `(n-1)² > n`.
Analysis (Stage 3): Every claim survives.  Reality of the pulled-back eigenvalue is
the crux; determinant/trace scaling are immediate consequences of the scalar
factorization but are genuine global (basis-independent) invariants, not entrywise
restatements.
Critique (Stage 4): `spectrum_line_locked` requires `z ≠ 0` (otherwise the matrix is
zero and the statement is vacuous but the *direction* is undefined) and symmetry of
the edge relation (otherwise `B` is not Hermitian and eigenvalues leave the line).
Both hypotheses are load-bearing and retained.  The outlier bound genuinely needs
`n ≥ 3`: at `n = 2` the complete-graph eigenvalue `z` sits strictly inside the
`√2 ‖z‖` disk, so the four-vertex phenomenon is not an artifact of small order but
begins exactly at `n = 3`.
Synthesis (Stage 5): Fixed-amplitude complex weighting is spectrally one-dimensional.
Genuine two-dimensional (disk-filling) spectra require breaking the scalar-Hermitian
factorization, i.e. independently phased or directed edges — the content of the
companion future-directions note.
-/
import Mathlib
import Logic.ComplexRandomGraphs

open Finset BigOperators Matrix

namespace ComplexRandomGraph

/-! ### Reality of Hermitian eigenvalues (abstract eigenpairs) -/

/-- A Rayleigh-quotient argument: any eigenvalue of a Hermitian matrix belonging to a
nonzero eigenvector is real, i.e. fixed by complex conjugation. -/
theorem isHermitian_eigenvalue_real {V : Type*} [Fintype V] [DecidableEq V]
    {A : Matrix V V ℂ} (hA : A.IsHermitian) {mu : ℂ} {v : V → ℂ}
    (hv : v ≠ 0) (hAv : A.mulVec v = mu • v) :
    (starRingEnd ℂ) mu = mu := by
  have starDot : ∀ a b : V → ℂ, star (a ⬝ᵥ b) = star a ⬝ᵥ star b := by
    intro a b
    simp only [dotProduct, star_sum, Pi.star_apply, star_mul']
  have key : star v ⬝ᵥ v = ((∑ i, Complex.normSq (v i) : ℝ) : ℂ) := by
    simp only [dotProduct, Pi.star_apply, RCLike.star_def, Complex.ofReal_sum]
    exact Finset.sum_congr rfl (fun i _ => (Complex.normSq_eq_conj_mul_self).symm)
  have hc0 : star v ⬝ᵥ v ≠ 0 := by
    rw [key]; intro h
    rw [Complex.ofReal_eq_zero] at h
    apply hv; funext i
    have hnn : ∀ j ∈ (Finset.univ : Finset V), 0 ≤ Complex.normSq (v j) :=
      fun j _ => Complex.normSq_nonneg _
    simpa using (Finset.sum_eq_zero_iff_of_nonneg hnn).mp h i (Finset.mem_univ i)
  have hcreal : star (star v ⬝ᵥ v) = star v ⬝ᵥ v := by rw [key]; simp
  have hLreal : star (star v ⬝ᵥ A.mulVec v) = star v ⬝ᵥ A.mulVec v := by
    rw [starDot, star_star, star_mulVec, hA, dotProduct_comm, dotProduct_mulVec]
  have hLmu : star v ⬝ᵥ A.mulVec v = mu * (star v ⬝ᵥ v) := by
    rw [hAv, dotProduct_smul, smul_eq_mul]
  rw [hLmu, star_mul', hcreal] at hLreal
  have hcancel := mul_right_cancel₀ hc0 hLreal
  simpa [RCLike.star_def] using hcancel

/-! ### The full spectrum lies on the complex line through the amplitude -/

/-- **Spectral line-locking.**  For a symmetric edge relation and nonzero amplitude
`z`, every eigenvalue of the weighted adjacency matrix is `z` times a real number:
the spectrum collapses onto the single complex line `ℝ · z`.  This is the exact
obstruction to a circular (disk-filling) limiting law. -/
theorem spectrum_line_locked {V : Type*} [Fintype V] [DecidableEq V]
    {z : ℂ} (hz : z ≠ 0) (g : V → V → Bool) (hsymm : ∀ i j, g i j = g j i)
    {lam : ℂ} {v : V → ℂ} (hv : v ≠ 0)
    (hAv : (adjacency z g).mulVec v = lam • v) :
    ∃ mu : ℝ, lam = z * (mu : ℂ) := by
  have hHerm := indicator_isHermitian g hsymm
  have hpull := eigenpair_pullback hz g v hAv
  have hreal := isHermitian_eigenvalue_real hHerm hv hpull
  refine ⟨(lam / z).re, ?_⟩
  have hquot : lam / z = ((lam / z).re : ℂ) := by
    have him : (lam / z).im = 0 := Complex.conj_eq_iff_im.mp hreal
    apply Complex.ext <;> simp [him]
  rw [← hquot]
  field_simp

/-! ### Global multiplicative invariants -/

/-- The determinant of a fixed-amplitude adjacency matrix is `z^n` times the
determinant of its zero-one indicator matrix. -/
theorem adjacency_det {V : Type*} [Fintype V] [DecidableEq V]
    (z : ℂ) (g : V → V → Bool) :
    (adjacency z g).det = z ^ (Fintype.card V) * (indicator g).det := by
  rw [adjacency_factor, Matrix.det_smul]

/-- The trace of a fixed-amplitude adjacency matrix is `z` times the trace of its
indicator matrix; for an irreflexive (loopless) relation both traces vanish. -/
theorem adjacency_trace_loopless {V : Type*} [Fintype V] [DecidableEq V]
    (z : ℂ) (g : V → V → Bool) (hloop : ∀ i, g i i = false) :
    (adjacency z g).trace = 0 := by
  rw [show (adjacency z g).trace = ∑ i, adjacency z g i i from rfl]
  apply Finset.sum_eq_zero
  intro i _
  simp [adjacency, hloop i]

/-! ### The complete-graph outlier at every order -/

/-- On `n` vertices the complete loopless realization has the all-ones vector as an
eigenvector with eigenvalue `(n-1) z`, generalizing the four-vertex computation. -/
theorem complete_eigenpair (z : ℂ) (n : ℕ) :
    (adjacency z (fun i j : Fin n => decide (i ≠ j))).mulVec (fun _ : Fin n => (1 : ℂ)) =
      (((n : ℂ) - 1) * z) • (fun _ : Fin n => (1 : ℂ)) := by
  ext i
  simp only [adjacency, Matrix.mulVec, dotProduct, mul_one, Pi.smul_apply, smul_eq_mul]
  rw [Finset.sum_ite, Finset.sum_const_zero, add_zero, Finset.sum_const, nsmul_eq_mul]
  have hcard : (Finset.univ.filter (fun j => (decide (i ≠ j) : Bool) = true)).card = n - 1 := by
    have : (Finset.univ.filter (fun j => (decide (i ≠ j) : Bool) = true))
        = Finset.univ.erase i := by
      ext j
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, decide_eq_true_eq,
        Finset.mem_erase, and_true]
      exact ne_comm
    rw [this, Finset.card_erase_of_mem (Finset.mem_univ i), Finset.card_univ, Fintype.card_fin]
  rw [hcard]
  rcases Nat.eq_zero_or_pos n with h0 | hpos
  · subst h0; exact i.elim0
  · rw [Nat.cast_sub hpos]; push_cast; ring

/-- For every order `n ≥ 3` the complete-graph mean-direction eigenvalue `(n-1) z`
lies strictly outside the heuristic radius `√n ‖z‖`.  The phenomenon first appears at
`n = 3` (it fails at `n = 2`), so the four-vertex example is representative, not
special. -/
theorem complete_outside_sqrt_disk (z : ℂ) (hz : z ≠ 0) (n : ℕ) (hn : 3 ≤ n) :
    ‖((n : ℂ) - 1) * z‖ > Real.sqrt n * ‖z‖ := by
  have hzn : 0 < ‖z‖ := norm_pos_iff.mpr hz
  have hn3 : (3 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hnorm : ‖((n : ℂ) - 1) * z‖ = ((n : ℝ) - 1) * ‖z‖ := by
    have hcast : ((n : ℂ) - 1) = (((n : ℝ) - 1 : ℝ) : ℂ) := by push_cast; ring
    rw [hcast, norm_mul, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg (by linarith)]
  rw [gt_iff_lt, hnorm]
  apply mul_lt_mul_of_pos_right _ hzn
  apply (Real.sqrt_lt' (by linarith)).mpr
  nlinarith [hn3]

end ComplexRandomGraph