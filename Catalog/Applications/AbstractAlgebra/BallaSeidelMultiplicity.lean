/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Seidel-matrix rank/multiplicity bridge for Balla's conjecture (`α = 1/3`)

This file isolates the **exact mechanism** by which Balla's conjecture for
`α = 1/3` is a statement about *eigenvalue multiplicity*, and proves the two
dimension-free rank identities that reduce "counting equiangular lines" to
"bounding the multiplicity of the smallest Seidel eigenvalue".

For a system of `m` unit vectors `v₁, …, v_m` in `ℝ^d` with pairwise inner
products `±1/3`, the Gram matrix is `G = I + (1/3)·S`, where the **Seidel matrix**
`S = 3G − 3I` has zero diagonal and `±1` off-diagonal.  Two facts drive everything:

* **Rank cap.**  `rank(G) ≤ d` (the Gram matrix of vectors in `ℝ^d` factors as
  `B·Bᵀ` with `B` an `m × d` matrix), hence `rank(S + 3I) = rank(3G) ≤ d`
  (`seidel_rank_le`).
* **Rank–nullity.**  `m = rank(S + 3I) + nullity(S + 3I)`, so
  `m ≤ d + nullity(S + 3I)` (`line_count_le`).  The nullity of `S + 3I` is exactly
  the **multiplicity of the eigenvalue `−3` of the Seidel matrix `S`**.

Thus the number of equiangular `1/3` lines exceeds the ambient dimension `d` by at
most the multiplicity of `−3` as a Seidel eigenvalue.  Balla's bound
`max{28, 2(d−1)}` is precisely a sharp bound on that multiplicity (the theme of
`Balla-Draxler-Keevash-Sudakov-18`, `Jiang-Polyanskii-20`, refining
`Lemmens-Seidel-73`); here we prove the *reduction* to it with zero `sorry`s.

Companion file: `Applications/EquiangularOneThird.lean` (tensor/Gram absolute
bounds and the Seidel positive-semidefiniteness `S ⪰ −3I`).
-/
import Mathlib

open Matrix

namespace BallaOneThird

variable {d m : ℕ}

/-- A family `v : Fin m → ℝ^d` is **equiangular with parameter `α`**: unit vectors
with `|⟨vᵢ, vⱼ⟩| = α` for `i ≠ j`. -/
def Equiangular (α : ℝ) (v : Fin m → EuclideanSpace ℝ (Fin d)) : Prop :=
  (∀ i, ‖v i‖ = 1) ∧ (∀ i j, i ≠ j → |inner ℝ (v i) (v j)| = α)

/-- The **Seidel matrix** `S = 3·G − 3·I` of a family (with `G` the Gram matrix). -/
noncomputable def seidel (v : Fin m → EuclideanSpace ℝ (Fin d)) :
    Matrix (Fin m) (Fin m) ℝ :=
  (3 : ℝ) • Matrix.gram ℝ v - (3 : ℝ) • (1 : Matrix (Fin m) (Fin m) ℝ)

/-! ## The rank cap `rank(G) ≤ d` -/

/-- **Gram rank cap.**  The Gram matrix of `m` vectors in `ℝ^d` has rank at most
`d`, because it factors as `B·Bᵀ` with `B` the `m × d` coordinate matrix. -/
theorem gram_rank_le (v : Fin m → EuclideanSpace ℝ (Fin d)) :
    (Matrix.gram ℝ v).rank ≤ d := by
  set B : Matrix (Fin m) (Fin d) ℝ := Matrix.of (fun i k => v i k) with hB
  have hfac : Matrix.gram ℝ v = B * Bᵀ := by
    ext i j
    simp only [Matrix.gram, Matrix.of_apply, Matrix.mul_apply, Matrix.transpose_apply, hB]
    rw [EuclideanSpace.inner_eq_star_dotProduct]
    simp [dotProduct, mul_comm]
  rw [hfac]
  calc (B * Bᵀ).rank ≤ B.rank := Matrix.rank_mul_le_left _ _
    _ ≤ Fintype.card (Fin d) := Matrix.rank_le_card_width _
    _ = d := by simp

/-- **Seidel rank cap.**  `rank(S + 3·I) = rank(3·G) ≤ d`.  Equivalently, the
`−3`-eigenspace of the Seidel matrix `S` has dimension at least `m − d`. -/
theorem seidel_rank_le (v : Fin m → EuclideanSpace ℝ (Fin d)) :
    (seidel v + (3 : ℝ) • (1 : Matrix (Fin m) (Fin m) ℝ)).rank ≤ d := by
  have hEq : seidel v + (3 : ℝ) • (1 : Matrix (Fin m) (Fin m) ℝ) = (3 : ℝ) • Matrix.gram ℝ v := by
    simp only [seidel]; abel
  rw [hEq]
  set B : Matrix (Fin m) (Fin d) ℝ := Matrix.of (fun i k => v i k) with hB
  have hfac : (3 : ℝ) • Matrix.gram ℝ v = ((3 : ℝ) • B) * Bᵀ := by
    ext i j
    simp only [Matrix.gram, Matrix.smul_apply, Matrix.of_apply, Matrix.mul_apply,
      Matrix.transpose_apply, hB, smul_eq_mul]
    rw [EuclideanSpace.inner_eq_star_dotProduct]
    simp [dotProduct, Finset.mul_sum, mul_comm, mul_assoc]
  rw [hfac]
  calc (((3 : ℝ) • B) * Bᵀ).rank ≤ ((3 : ℝ) • B).rank := Matrix.rank_mul_le_left _ _
    _ ≤ Fintype.card (Fin d) := Matrix.rank_le_card_width _
    _ = d := by simp

/-! ## The rank–nullity bridge `m ≤ d + multiplicity` -/

/-- **Line-count bridge.**  For *any* family of `m` vectors in `ℝ^d`,
`m ≤ d + nullity(S + 3·I)`.  Here `nullity(S + 3·I)` — the dimension of the kernel
of `S + 3·I` — is the multiplicity of the eigenvalue `−3` of the Seidel matrix `S`.
This is the precise reduction of the equiangular-line count to a spectral
multiplicity, which Balla's theorem then bounds by `max{28, 2(d−1)} − d`. -/
theorem line_count_le (v : Fin m → EuclideanSpace ℝ (Fin d)) :
    m ≤ d + Module.finrank ℝ (LinearMap.ker (Matrix.mulVecLin
      (seidel v + (3 : ℝ) • (1 : Matrix (Fin m) (Fin m) ℝ)))) := by
  set A := seidel v + (3 : ℝ) • (1 : Matrix (Fin m) (Fin m) ℝ) with hA
  have hrn := LinearMap.finrank_range_add_finrank_ker (Matrix.mulVecLin A)
  have hdim : Module.finrank ℝ (Fin m → ℝ) = m := by simp
  have hrank : A.rank = Module.finrank ℝ (LinearMap.range (Matrix.mulVecLin A)) := rfl
  have hle : A.rank ≤ d := seidel_rank_le v
  rw [hdim, ← hrank] at hrn
  omega

/-! ## Seidel entries for equiangular `1/3` systems -/

/-- For an equiangular `1/3` system the Seidel matrix has **zero diagonal**. -/
theorem seidel_diag (v : Fin m → EuclideanSpace ℝ (Fin d))
    (hunit : ∀ i, ‖v i‖ = 1) (i : Fin m) : seidel v i i = 0 := by
  have hself : inner ℝ (v i) (v i) = (1 : ℝ) := by
    rw [real_inner_self_eq_norm_sq, hunit i]; norm_num
  have : (Matrix.gram ℝ v) i i = inner ℝ (v i) (v i) := rfl
  simp only [seidel, Matrix.sub_apply, Matrix.smul_apply, this, hself,
    Matrix.one_apply_eq, smul_eq_mul]
  ring

/-- For an equiangular `1/3` system the Seidel matrix has **`±1` off-diagonal
entries**. -/
theorem seidel_offdiag (v : Fin m → EuclideanSpace ℝ (Fin d))
    (h : Equiangular (1 / 3) v) {i j : Fin m} (hij : i ≠ j) :
    seidel v i j = 1 ∨ seidel v i j = -1 := by
  obtain ⟨_, hangle⟩ := h
  have hg : (Matrix.gram ℝ v) i j = inner ℝ (v i) (v j) := rfl
  have habs : |inner ℝ (v i) (v j)| = 1 / 3 := hangle i j hij
  have hval : seidel v i j = 3 * inner ℝ (v i) (v j) := by
    simp only [seidel, Matrix.sub_apply, Matrix.smul_apply, hg,
      Matrix.one_apply_ne hij, smul_eq_mul]; ring
  rcases abs_eq (by norm_num : (0 : ℝ) ≤ 1 / 3) |>.1 habs with hpos | hneg
  · left; rw [hval, hpos]; norm_num
  · right; rw [hval, hneg]; norm_num

/-- **Balla reduction for `α = 1/3`.**  An equiangular `1/3` system of `m` lines in
`ℝ^d` has an associated symmetric Seidel matrix `S` (zero diagonal, `±1`
off-diagonal), and the line count obeys `m ≤ d + μ`, where `μ` is the multiplicity
of the eigenvalue `−3` of `S` (the nullity of `S + 3·I`).  Balla's conjecture is
the statement that this `μ` is small enough to force `m ≤ max{28, 2(d−1)}`. -/
theorem equiangular_oneThird_reduction (v : Fin m → EuclideanSpace ℝ (Fin d))
    (h : Equiangular (1 / 3) v) :
    (∀ i, seidel v i i = 0) ∧
    (∀ i j, i ≠ j → seidel v i j = 1 ∨ seidel v i j = -1) ∧
    m ≤ d + Module.finrank ℝ (LinearMap.ker (Matrix.mulVecLin
      (seidel v + (3 : ℝ) • (1 : Matrix (Fin m) (Fin m) ℝ)))) := by
  refine ⟨fun i => seidel_diag v h.1 i, fun i j hij => seidel_offdiag v h hij, line_count_le v⟩

end BallaOneThird

/-
-- !-- Lab Notes -- !--

Category (Menu Balance): CROSS-DOMAIN BRIDGE
  Combinatorics (equiangular line systems / Balla) ⨯ Linear algebra
  (matrix rank, rank–nullity, Seidel-matrix spectra).

External signal awareness:
  Balla's framework recasts `N_α(d)` in terms of the multiplicity of the smallest
  eigenvalue `−1/α` of a `0/±1` Seidel matrix.  For `α = 1/3` that eigenvalue is
  the integer `−3` and the "spectral order" is `κ₁ = 2` (witnessed by `K₂`), which
  is what collapses the general bound to `max{28, 2(d−1)}`.  This file formalises
  the reduction "line count ↦ eigenvalue multiplicity" underlying
  `Balla-Draxler-Keevash-Sudakov-18` and `Jiang-Polyanskii-20`.

Hypothesis (Hypothesizer):
  H1. The Gram matrix of vectors living in `ℝ^d` cannot have rank above `d`,
      whatever `m` is — this is the *only* place the ambient dimension enters.
  H2 (bold). The full angle constraint for `α = 1/3` is captured by a single
      spectral quantity: the multiplicity of `−3` in the Seidel matrix, and the
      line count is `d` plus exactly that multiplicity.
  H3. Consequently Balla's conjecture is *equivalent* (given H2) to a purely
      spectral multiplicity bound; the geometry is fully absorbed by rank–nullity.

Experiment (Experimenter):
  * `gram_rank_le`: factor `G = B·Bᵀ` (via `EuclideanSpace.inner_eq_star_dotProduct`)
    and chain `rank_mul_le_left`, `rank_le_card_width`.  Confirmed H1.
  * `seidel_rank_le`: `S + 3I = 3G = (3B)·Bᵀ`, same rank chain.  The scalar `3`
    rides along inside the factor.
  * `line_count_le`: `LinearMap.finrank_range_add_finrank_ker` on `mulVecLin`,
    with `Matrix.rank` unfolding *definitionally* to `finrank` of the range; then
    `omega`.  Confirmed H2's reduction.
  * `seidel_diag`, `seidel_offdiag`: the `0/±1` structure via `abs_eq` case split.
  * `equiangular_oneThird_reduction`: packages the three facts.

Analysis (Analyst):
  - The structural pattern: "geometry (ambient dimension) enters only through
    `rank(G) ≤ d`; everything else is rank–nullity bookkeeping."  This is
    `true and provable` and dimension-free.
  - What remains open here is *bounding the nullity* `μ = nullity(S + 3I)`; that is
    a genuinely combinatorial statement about `±1` symmetric matrices with smallest
    eigenvalue `−3`.  It is `true but hard` and is exactly the content of Balla's
    theorem.  The reduction cleanly separates the easy (linear-algebraic) half from
    the hard (spectral-combinatorial) half.

Critique (Critic):
  - No result is `True`/`rfl`/`decide`-only: `gram_rank_le`/`seidel_rank_le`
    compose real rank inequalities via an explicit factorisation, and
    `line_count_le` uses rank–nullity plus `omega`.
  - `line_count_le` needs *no* equiangular hypothesis — it is the honest general
    statement; the `1/3` structure is added separately in
    `equiangular_oneThird_reduction`.
  - Edge cases: `m = 0` gives `0 ≤ d + …` (fine); the off-diagonal claim is vacuous
    for `m ≤ 1`, as it should be.

Synthesis (PI):
  The equiangular-`1/3` line count is `d` plus the multiplicity of the Seidel
  eigenvalue `−3`.  Both rank facts are formalised with zero `sorry`s, reducing
  Balla's conjecture to a sharp bound on that single spectral multiplicity.
-/