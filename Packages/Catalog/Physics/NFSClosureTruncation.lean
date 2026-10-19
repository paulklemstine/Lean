import Mathlib

/-!
# NFS closure, channel 2: the truncated `left_dependencies` instrument saturates

Round 44's sparse-linear-algebra experiment was killed on **instrument validity**
(`refuteA`): its routine `left_dependencies` breaks out of the row loop after `60`
dependencies, so every downstream quantity is read off a truncated run.

This file proves *why* such an instrument cannot carry a per-instance signal.

* `excess_le_leftNullity` : for a relation matrix `M` over any field, with `r` relations
  (rows) and `c` factor-base primes (columns), the space of left dependencies has dimension
  at least `r - c` (rank–nullity).  Over `𝔽₂` this is the congruence-of-squares guarantee of
  every sieve (QS **and** NFS).
* `card_leftKernel_GF2` : over `𝔽₂` the left kernel has exactly `2 ^ nullity` elements.
* `truncated_reading_saturates` : a reading truncated at a cap `k` equals `k` on **every**
  matrix whose excess `r - c` is at least `k`; with `k = 60` and any NFS run collecting
  `60` more relations than primes, the reading is the constant `60`.
* `truncated_reading_blind` : two such instances are indistinguishable by the instrument,
  however different their actual dependency spaces — so the reading cannot be a lever.
* `truncated_vector_count_saturates` : if instead every nonzero dependency vector is
  counted, the cap `60` is already reached at excess `6`, since `2^6 - 1 = 63 ≥ 60`.
-/

namespace Physics.NFSClosure

open Module

variable {K : Type*} [Field K] {r c : ℕ}

/-- The space of left dependencies of a relation matrix `M` (rows = relations): vectors
`v` with `v ᵥ* M = 0`, realised as the kernel of `Mᵀ` acting on column vectors. -/
noncomputable def leftKernel (M : Matrix (Fin r) (Fin c) K) : Submodule K (Fin r → K) :=
  LinearMap.ker M.transpose.mulVecLin

/-- The left nullity: the number of independent dependencies Gaussian elimination finds. -/
noncomputable def leftNullity (M : Matrix (Fin r) (Fin c) K) : ℕ :=
  finrank K (leftKernel M)

theorem mem_leftKernel_iff (M : Matrix (Fin r) (Fin c) K) (v : Fin r → K) :
    v ∈ leftKernel M ↔ Matrix.vecMul v M = 0 := by
  simp [leftKernel]

/-- **Rank–nullity for relations.**  `rank M + leftNullity M = r`. -/
theorem rank_add_leftNullity (M : Matrix (Fin r) (Fin c) K) :
    M.rank + leftNullity M = r := by
  have h := LinearMap.finrank_range_add_finrank_ker M.transpose.mulVecLin
  rw [Module.finrank_fin_fun] at h
  rw [← Matrix.rank_transpose]
  exact h

/-- **Excess guarantee.**  A relation matrix with `r` rows and `c` columns has at least
`r - c` independent left dependencies. -/
theorem excess_le_leftNullity (M : Matrix (Fin r) (Fin c) K) : r - c ≤ leftNullity M := by
  have h := rank_add_leftNullity M
  have hr : M.rank ≤ c := by
    simpa using M.rank_le_card_width
  omega

/-- Over `𝔽₂` the left kernel has exactly `2 ^ leftNullity` elements. -/
theorem card_leftKernel_GF2 (M : Matrix (Fin r) (Fin c) (ZMod 2)) :
    Nat.card (leftKernel M) = 2 ^ leftNullity M := by
  rw [leftNullity, Module.natCard_eq_pow_finrank (K := ZMod 2), Nat.card_zmod]

/-- Over `𝔽₂`, at least `2 ^ (r - c) - 1` nonzero dependency vectors exist. -/
theorem nonzero_dependencies_GF2 (M : Matrix (Fin r) (Fin c) (ZMod 2)) :
    2 ^ (r - c) - 1 ≤ Nat.card (leftKernel M) - 1 := by
  rw [card_leftKernel_GF2]
  have := Nat.pow_le_pow_right (by norm_num : 0 < 2) (excess_le_leftNullity M)
  omega

/-- A truncated instrument: it reports `min k n` where `n` is the true count. -/
def truncate (k n : ℕ) : ℕ := min k n

/-- **Saturation.**  The truncated dependency reading equals the cap `k` on every matrix
whose excess `r - c` reaches `k`. -/
theorem truncated_reading_saturates (M : Matrix (Fin r) (Fin c) K) {k : ℕ}
    (hk : k ≤ r - c) : truncate k (leftNullity M) = k := by
  have := excess_le_leftNullity M
  unfold truncate
  omega

/-- **Blindness.**  Two relation matrices (of possibly different shapes and over the same
field), both with excess at least `k`, produce identical truncated readings, regardless of
their actual nullities. -/
theorem truncated_reading_blind {r' c' : ℕ} (M : Matrix (Fin r) (Fin c) K)
    (M' : Matrix (Fin r') (Fin c') K) {k : ℕ} (hk : k ≤ r - c) (hk' : k ≤ r' - c') :
    truncate k (leftNullity M) = truncate k (leftNullity M') := by
  rw [truncated_reading_saturates M hk, truncated_reading_saturates M' hk']

/-- The truncated instrument is not injective on true nullities above the cap: it collapses
nullities `k` and `k + 1` (and every larger one) to the same value. -/
theorem truncate_not_injective (k : ℕ) : truncate k k = truncate k (k + 1) := by
  unfold truncate; omega

/-- **Round-44 instance.**  With cap `60`, any `𝔽₂` relation matrix carrying an excess of at
least `60` relations reads exactly `60`. -/
theorem left_dependencies_cap60 (M : Matrix (Fin r) (Fin c) (ZMod 2)) (h : 60 ≤ r - c) :
    truncate 60 (leftNullity M) = 60 :=
  truncated_reading_saturates M h

/-- **Vector-count variant.**  If the instrument counts *nonzero dependency vectors* (all
subset-products that are squares) rather than independent ones, the cap `60` is reached as
soon as the excess is `6`, because `2 ^ 6 - 1 = 63`. -/
theorem truncated_vector_count_saturates (M : Matrix (Fin r) (Fin c) (ZMod 2))
    (h : 6 ≤ r - c) : truncate 60 (Nat.card (leftKernel M) - 1) = 60 := by
  have h1 := nonzero_dependencies_GF2 M
  have h2 : 2 ^ 6 ≤ 2 ^ (r - c) := Nat.pow_le_pow_right (by norm_num) h
  unfold truncate
  omega

end Physics.NFSClosure