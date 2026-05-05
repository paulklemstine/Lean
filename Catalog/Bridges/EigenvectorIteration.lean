import Mathlib
import Bridges.MaxPlusDefs
import Bridges.MaxPlusLemmas

/-!
# Eigenvector Iteration and Spectral Growth

Given a tropical eigenvector `v` with eigenvalue `μ`, we prove:
1. Adding a constant commutes with max-plus multiplication
2. Iterating `maxPlusMul M` k times on an eigenvector yields `k·μ + v`
3. The bounded defect growth theorem follows

## Key insight

Instead of using `tropicalMatPow` (which requires a tropical identity that doesn't
exist over `ℝ`), we work with iterated application of `maxPlusMul M`. This avoids
the `-∞` issue entirely and gives cleaner statements.
-/

noncomputable section

open Finset BigOperators

variable {n : ℕ}

/-! ### Iterated max-plus multiplication -/

/-- Iterated application of max-plus matrix-vector multiplication. -/
def iterMaxPlusMul (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) :
    ℕ → (Fin n → ℝ) → (Fin n → ℝ)
  | 0, v => v
  | k + 1, v => maxPlusMul M (iterMaxPlusMul hn M k v) hn

/-- Zeroth iterate is the identity. -/
theorem iterMaxPlusMul_zero (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin n → ℝ) : iterMaxPlusMul hn M 0 v = v := rfl

/-- Successor iterate unfolds. -/
theorem iterMaxPlusMul_succ (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ)
    (k : ℕ) (v : Fin n → ℝ) :
    iterMaxPlusMul hn M (k + 1) v = maxPlusMul M (iterMaxPlusMul hn M k v) hn := rfl

/-! ### Shift lemma -/

/-
Max-plus multiplication commutes with adding a constant to the vector:
    `M ⊗ (c + v) = c + (M ⊗ v)`.
-/
theorem maxPlusMul_shift (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (c : ℝ) :
    maxPlusMul M (fun i => c + v i) hn = fun i => c + maxPlusMul M v hn i := by
  ext i;
  unfold maxPlusMul;
  refine' le_antisymm _ _ <;> norm_num [ Finset.sup'_le_iff ];
  · exact fun j => by linarith [ Finset.le_sup' ( fun j => M i j + v j ) ( Finset.mem_univ j ) ] ;
  · obtain ⟨ j, hj ⟩ := Finset.exists_max_image Finset.univ ( fun j => M i j + v j ) ⟨ i, Finset.mem_univ i ⟩ ; use j ; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ;

/-! ### The iteration theorem -/

/-
**Eigenvector iteration theorem**: If `v` is an eigenvector with eigenvalue `μ`,
    then the k-th iterate of `maxPlusMul M` applied to `v` yields `k·μ + v`.

    This is the fundamental bridge from eigenvectors to asymptotic growth.
-/
theorem eigenvector_iterate (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (mu : ℝ)
    (hv : ∀ i, maxPlusMul M v hn i = mu + v i)
    (k : ℕ) (i : Fin n) :
    iterMaxPlusMul hn M k v i = k * mu + v i := by
  -- By induction on k. Base case k=0: iterMaxPlusMul M 0 v i = v i = 0 * mu + v i. ✓
  induction' k with k ih generalizing i;
  · aesop;
  · have h_ind : iterMaxPlusMul hn M (k + 1) v i = maxPlusMul M (fun j => k * mu + v j) hn i := by
      rw [ iterMaxPlusMul_succ, ← funext ih ];
    rw [ h_ind, maxPlusMul_shift ] ; norm_num [ hv ] ; ring

/-! ### Bounds from iterates -/

/-- Upper bound: each entry of the k-th iterate is bounded by the corresponding
    eigenvector entry shifted by k·μ. Since iterMaxPlusMul computes entry-wise
    max over paths, any entry is ≤ the global max. -/
theorem iterMaxPlusMul_entry_eq (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (mu : ℝ)
    (hv : ∀ i, maxPlusMul M v hn i = mu + v i)
    (k : ℕ) :
    ∀ i, iterMaxPlusMul hn M k v i = k * mu + v i :=
  fun i => eigenvector_iterate hn M v mu hv k i

/-! ### Bounded defect growth from eigenvector -/

/-
If `M` admits an eigenvector with eigenvalue `μ`, then the max entry of
    the k-th iterate applied to the eigenvector grows as `k·μ + maxᵢ vᵢ`.
-/
theorem iterate_max_eq (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (mu : ℝ)
    (hv : ∀ i, maxPlusMul M v hn i = mu + v i) (k : ℕ) :
    Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (iterMaxPlusMul hn M k v) =
      k * mu + Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) v := by
  refine' le_antisymm _ _;
  · simp +zetaDelta at *;
    exact fun i => by linarith [ eigenvector_iterate hn M v mu hv k i, Finset.le_sup' ( fun i => v i ) ( Finset.mem_univ i ) ] ;
  · obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty_iff.mpr ⟨ ⟨ 0, hn ⟩ ⟩ ) v;
    exact le_trans ( by rw [ hi.2 ] ; exact eigenvector_iterate hn M v mu hv k i ▸ le_rfl ) ( Finset.le_sup' ( fun a => iterMaxPlusMul hn M k v a ) hi.1 )

end