import Mathlib

/-!
# Low-Rank Obstruction for Naive Arithmetic Kernels

We prove that the symmetric outer-product matrix `M_{ij} = u_i v_j + v_i u_j`
has rank at most 2 for any vectors `u, v`. This implies that the naive
prime-log kernel `K(p,q) = log(pq)/√(pq)` is rank ≤ 2 and therefore cannot
encode the spectral complexity of zeta truncations.

## Main Results

- `rank_vecMulVec_le_one`: `rank(u · vᵀ) ≤ 1`
- `rank_add_outer_le_two`: `rank(u·vᵀ + v·uᵀ) ≤ 2`
-/

open Matrix

noncomputable section

/-- The symmetric rank-1+1 matrix `M_{ij} = u_i · v_j + v_i · u_j`. -/
def symOuterProduct {ι : Type*} [Fintype ι] [DecidableEq ι]
    (u v : ι → ℝ) : Matrix ι ι ℝ :=
  Matrix.of fun i j => u i * v j + v i * u j

/-
A rank-one outer product `u · vᵀ` has rank at most 1.
-/
theorem rank_vecMulVec_le_one
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (u v : ι → ℝ) :
    Matrix.rank (vecMulVec u v) ≤ 1 :=
  Matrix.rank_vecMulVec_le u v

/-
**The symmetric outer-product matrix has rank ≤ 2.**
    `rank(u·vᵀ + v·uᵀ) ≤ 2` for any vectors `u, v`.
-/
theorem rank_add_outer_le_two
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (u v : ι → ℝ) :
    Matrix.rank (Matrix.of fun i j => u i * v j + v i * u j) ≤ 2 := by
  -- We can rewrite the matrix $M$ as $M = u \cdot v^T + v \cdot u^T$.
  have hM : (Matrix.of (fun i j => (u i) * (v j) + (v i) * (u j))) = (vecMulVec u v) + (vecMulVec v u) := by
    ext; simp +decide [ mul_comm ];
    unfold vecMulVec; simp +decide [ Matrix.vecMulVec, mul_comm ] ;
  have h_rank_add : Matrix.rank (vecMulVec u v + vecMulVec v u) ≤ Matrix.rank (vecMulVec u v) + Matrix.rank (vecMulVec v u) := by
    rw [ Matrix.rank, Matrix.rank, Matrix.rank ];
    rw [ ← Submodule.finrank_sup_add_finrank_inf_eq ];
    exact le_add_right ( Submodule.finrank_mono <| by aesop_cat );
  exact hM ▸ h_rank_add.trans ( by linarith [ rank_vecMulVec_le_one u v, rank_vecMulVec_le_one v u ] )

/-
The symmetric outer-product is indeed a sum of two outer products.
-/
theorem symOuterProduct_eq_sum {ι : Type*} [Fintype ι] [DecidableEq ι]
    (u v : ι → ℝ) :
    symOuterProduct u v = vecMulVec u v + vecMulVec v u := by
  -- By definition of matrix equality, we need to show that each entry is equal.
  ext i j; simp [symOuterProduct, vecMulVec]

end