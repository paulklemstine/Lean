/-
# Invariance properties of the max-plus spectral radius

The maximum cycle mean `λ(A)` is the unique tropical eigenvalue of `A`
(`tropEigen_iff_eq_maxCycleMean`).  Here we exploit that characterisation to derive the
three basic invariance/covariance laws of the tropical spectral radius:

* **diagonal similarity**: `λ(D ⊗ A ⊗ D^{-1}) = λ(A)`, where `D` is the tropical diagonal
  matrix with entries `d i` (in max-plus, conjugation by a diagonal matrix just shifts the
  entries by `d i - d j`);
* **powers**: `λ(A^{⊗ k}) = k · λ(A)` — the spectral mapping theorem for monomials;
* **transposition**: `λ(Aᵀ) = λ(A)`, proved combinatorially by reversing cycles.

None of these is definitional: each one is a statement about optima over all cycles of all
lengths, and the first two go through the existence and uniqueness parts of the tropical
Perron–Frobenius theorem.
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.TropicalGelfand

namespace TropicalLA

open Matrix

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## Diagonal similarity -/

/-- Tropical conjugation of `A` by the diagonal matrix with entries `d`:
`(D ⊗ A ⊗ D^{-1}) i j = d i + A i j - d j`. -/
def diagConj (A : Matrix ι ι ℝ) (d : ι → ℝ) : Matrix ι ι ℝ :=
  Matrix.of fun i j => d i + A i j - d j

/-- Diagonal conjugation transports eigenvectors: if `v` is an eigenvector of `A` for
`lam`, then `v + d` is an eigenvector of `diagConj A d` for the same `lam`. -/
theorem isTropEigen_diagConj {A : Matrix ι ι ℝ} {lam : ℝ} {v : ι → ℝ} (d : ι → ℝ)
    (h : IsTropEigen A lam v) : IsTropEigen (diagConj A d) lam (fun i => v i + d i) := by
  intro i
  have hA := h i
  apply le_antisymm
  · refine Finset.sup'_le _ _ fun j _ => ?_
    have := le_tmulVec A v i j
    rw [hA] at this
    simp only [diagConj, Matrix.of_apply]
    linarith
  · obtain ⟨j, hj⟩ := exists_tmulVec_eq A v i
    have hle : diagConj A d i j + (v j + d j) ≤ tmulVec (diagConj A d) (fun i => v i + d i) i :=
      le_tmulVec (diagConj A d) (fun i => v i + d i) i j
    have : tmulVec A v i = A i j + v j := hj
    rw [hA] at this
    have hentry : diagConj A d i j = d i + A i j - d j := rfl
    rw [hentry] at hle
    show lam + (v i + d i) ≤ tmulVec (diagConj A d) (fun i => v i + d i) i
    linarith

/-- **The tropical spectral radius is invariant under diagonal similarity.** -/
theorem maxCycleMean_diagConj (A : Matrix ι ι ℝ) (d : ι → ℝ) :
    maxCycleMean (diagConj A d) = maxCycleMean A := by
  obtain ⟨v, hv⟩ := exists_tropEigen A
  exact ((tropEigen_iff_eq_maxCycleMean (diagConj A d) (maxCycleMean A)).1
    ⟨_, isTropEigen_diagConj d hv⟩).symm

/-! ## Spectral mapping for tropical powers -/

/-- **Spectral mapping theorem.**  The maximum cycle mean of the `(m+1)`-st tropical power
of `A` is `(m+1)` times that of `A`. -/
theorem maxCycleMean_tpow (A : Matrix ι ι ℝ) (m : ℕ) :
    maxCycleMean (tpow A m) = (m + 1) * maxCycleMean A := by
  obtain ⟨v, hv⟩ := exists_tropEigen A
  have hpow : IsTropEigen (tpow A m) ((m + 1) * maxCycleMean A) v := by
    intro i
    have := congrFun (hv.tmulVec_tpow m) i
    simpa using this
  exact ((tropEigen_iff_eq_maxCycleMean (tpow A m) ((m + 1) * maxCycleMean A)).1 ⟨v, hpow⟩).symm

/-! ## Transposition -/

omit [Fintype ι] [Nonempty ι] in
/-- Reversing a closed walk of `Aᵀ` yields a closed walk of `A` of the same length and
weight. -/
theorem pathWeight_transpose_reverse (A : Matrix ι ι ℝ) (c : ℕ → ι) (m : ℕ) :
    pathWeight A (fun t => c (m - t)) m = pathWeight Aᵀ c m := by
  simp only [pathWeight, Matrix.transpose_apply]
  rw [← Finset.sum_range_reflect (fun s => A (c (s + 1)) (c s)) m]
  refine Finset.sum_congr rfl fun t ht => ?_
  have ht' : t < m := Finset.mem_range.mp ht
  have h1 : m - 1 - t + 1 = m - t := by omega
  have h2 : m - 1 - t = m - (t + 1) := by omega
  rw [h1, h2]

/-- One direction of transposition invariance. -/
theorem maxCycleMean_transpose_le (A : Matrix ι ι ℝ) :
    maxCycleMean Aᵀ ≤ maxCycleMean A := by
  obtain ⟨m, c, hm, _, hcyc, hval⟩ := exists_critical_cycle_maxCycleMean (A := Aᵀ)
  set c' : ℕ → ι := fun t => c (m - t) with hc'
  have hcycle' : c' m = c' 0 := by
    simp only [hc', Nat.sub_self, Nat.sub_zero, hcyc]
  have hw : pathWeight A c' m = m * maxCycleMean Aᵀ := by
    rw [hc', pathWeight_transpose_reverse, hval]
  have hle : pathWeight A c' m ≤ m * maxCycleMean A := cycle_le_maxCycleMean m c' hcycle'
  rw [hw] at hle
  have hmpos : (0 : ℝ) < m := by exact_mod_cast hm
  exact le_of_mul_le_mul_left (by linarith) hmpos

/-- **The tropical spectral radius is invariant under transposition**: the best mean cycle
of `A` and of `Aᵀ` agree, since cycles reverse. -/
theorem maxCycleMean_transpose (A : Matrix ι ι ℝ) : maxCycleMean Aᵀ = maxCycleMean A := by
  refine le_antisymm (maxCycleMean_transpose_le A) ?_
  have := maxCycleMean_transpose_le Aᵀ
  rwa [Matrix.transpose_transpose] at this

end TropicalLA