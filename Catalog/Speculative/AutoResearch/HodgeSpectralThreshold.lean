/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Spectral Depth Thresholds for Hodge–Laplacian Message Passing

This file extracts a rigorous, sorry-free linear-algebraic skeleton for the theory of
*spectral depth thresholds* governing message passing with the combinatorial Hodge
Laplacian on a simplicial complex / cell complex.

The Hodge Laplacian on `k`-cochains is built from a coboundary/incidence matrix `B`
as the "up" Laplacian `L = Bᵀ B`.  A single layer of (gradient-descent style) message
passing acts by `x ↦ x - α (L *ᵥ x)`.  Two phenomena are made precise:

* **Homotopy invariance of harmonic signals.**  The kernel of `L` is the space of
  *harmonic* cochains, which (by the discrete Hodge theorem) is isomorphic to a
  cohomology group and is therefore a homotopy/topological invariant.  We prove that
  harmonic signals are *exact fixed points* of message passing at every depth: they
  pass through arbitrarily deep networks undistorted.

* **Spectral contraction off the harmonic core.**  On the complement (signals carrying
  Dirichlet energy), message passing contracts the energy by a factor governed by the
  spectral gap.  Iterating contracts geometrically, yielding a *finite spectral depth
  threshold*: for any tolerance `ε`, finitely many layers suffice to drive the residual
  below `ε`.

## Main results

* `hodge_isSymm`               — the Hodge Laplacian `Bᵀ B` is symmetric.
* `hodge_quadform`             — `⟨x, Lx⟩ = ‖B x‖²` (Dirichlet energy identity).
* `hodge_psd`                  — `L` is positive semidefinite.
* `harmonic_iff_boundary`      — discrete Hodge theorem: `Lx = 0 ↔ Bx = 0`.
* `mpStep_fixes_harmonic`      — harmonic signals are fixed by one layer.
* `mpStep_iterate_fixes_harmonic` — harmonic signals are fixed at every depth.
* `quadform_mpStep`            — exact energy expansion of one layer.
* `mpStep_contraction`         — one-layer spectral contraction under a gap hypothesis.
* `quadform_iterate_bound`     — geometric energy decay over depth.
* `spectral_depth_threshold`   — finitely many layers suffice to reach any tolerance.

## Catalog synthesis

This bridges the *MachineLearning* domain (graph/simplicial neural networks, the
oversmoothing phenomenon) with the *homotopy & path-space* program: the harmonic kernel
is exactly the homotopy-invariant part of a signal, and message passing is a discrete
deformation that fixes invariants while contracting everything else.  It extends the
spirit of the catalog's spectral results (e.g. expander / spectral-gap machinery in
`Algebra/ClassicalGroupExpanders` and `Algebra/ExpanderWalk/Amplification`) from scalar
graph Laplacians to the higher Hodge Laplacian on cochains.
-/
import Mathlib

namespace HodgeSpectralThreshold

open Matrix

variable {m n : ℕ}

-- !-- Lab Notebook -- !--
-- Hypothesis: The combinatorial Hodge Laplacian `L = Bᵀ B` should behave as a symmetric
--   PSD operator whose kernel (harmonic cochains) is fixed by message passing while the
--   energy-carrying complement contracts geometrically with depth.
-- Result: All ten statements below are proven sorry-free; the contraction is fully
--   quantitative (factor `1 - αμ(2 - αλ)`) and yields a finite depth threshold.
-- Insight: The Dirichlet-energy identity `⟨x,Lx⟩ = ⟨Bx,Bx⟩` is the linchpin — it turns
--   both PSD-ness and the discrete Hodge theorem into one-line consequences of
--   `dotProduct`-self positivity, and turns the contraction into pure `nlinarith`.
-- Failure analysis: `positivity` cannot see through the `dotProduct` sum (entries are
--   `v i * v i`, not `(v i)^2`); we unfold to `Finset.sum_nonneg` + `mul_self_nonneg`.
--   The spectral-gap nonnegativity `0 ≤ μ` turned out logically unnecessary for the
--   one-step contraction, so the stated theorem is strictly more general.
-- !-- end Lab Notebook -- !--

/-- The "up" combinatorial Hodge Laplacian associated with a coboundary/incidence
matrix `B`. -/
def hodge (B : Matrix (Fin m) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ := Bᵀ * B

/-- One layer of (gradient-descent style) Hodge message passing with step size `α`:
`x ↦ x - α (L x)`. -/
def mpStep (L : Matrix (Fin n) (Fin n) ℝ) (α : ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  x - α • (L *ᵥ x)

-- !-- The transpose of `Bᵀ B` is `Bᵀ B` since `(Bᵀ B)ᵀ = Bᵀ (Bᵀ)ᵀ = Bᵀ B`. -- !--
theorem hodge_isSymm (B : Matrix (Fin m) (Fin n) ℝ) : (hodge B).IsSymm := by
  simp [hodge, Matrix.IsSymm, Matrix.transpose_mul]

-- !-- `⟨x, (BᵀB)x⟩ = ⟨x, Bᵀ(Bx)⟩ = ⟨Bx, Bx⟩` via `mulVec_mulVec`, `dotProduct_mulVec`,
--    and `vecMul_transpose`; this is the discrete Dirichlet energy. -- !--
theorem hodge_quadform (B : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) :
    x ⬝ᵥ (hodge B) *ᵥ x = (B *ᵥ x) ⬝ᵥ (B *ᵥ x) := by
  unfold hodge
  rw [← Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec, Matrix.vecMul_transpose]

-- !-- The Dirichlet energy is a sum of squares, hence nonnegative. -- !--
theorem hodge_psd (B : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) :
    0 ≤ x ⬝ᵥ (hodge B) *ᵥ x := by
  rw [hodge_quadform]
  exact Finset.sum_nonneg fun i _ => mul_self_nonneg _

-- !-- Discrete Hodge theorem: `Lx = 0 ↔ Bx = 0`.  The `←` is `mulVec_mulVec`; the `→`
--    pushes `Lx = 0` into `⟨Bx,Bx⟩ = 0`, then `dotProduct_self_eq_zero`. -- !--
theorem harmonic_iff_boundary (B : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) :
    (hodge B) *ᵥ x = 0 ↔ B *ᵥ x = 0 := by
  constructor
  · intro h
    have hq : (B *ᵥ x) ⬝ᵥ (B *ᵥ x) = 0 := by
      rw [← hodge_quadform, h, dotProduct_zero]
    exact dotProduct_self_eq_zero.mp hq
  · intro h
    unfold hodge
    rw [← Matrix.mulVec_mulVec, h, Matrix.mulVec_zero]

-- !-- If `Lx = 0` then `x - α(Lx) = x - 0 = x`. -- !--
theorem mpStep_fixes_harmonic (L : Matrix (Fin n) (Fin n) ℝ) (α : ℝ) (x : Fin n → ℝ)
    (hx : L *ᵥ x = 0) : mpStep L α x = x := by
  unfold mpStep
  rw [hx, smul_zero, sub_zero]

-- !-- Harmonic signals are fixed at every depth: induction on `k`, applying
--    `mpStep_fixes_harmonic` at the outermost layer. -- !--
theorem mpStep_iterate_fixes_harmonic (L : Matrix (Fin n) (Fin n) ℝ) (α : ℝ)
    (x : Fin n → ℝ) (hx : L *ᵥ x = 0) (k : ℕ) : (mpStep L α)^[k] x = x := by
  induction k with
  | zero => simp
  | succ k ih => rw [Function.iterate_succ_apply', ih]; exact mpStep_fixes_harmonic L α x hx

-- !-- Exact energy expansion `‖x - αLx‖² = ‖x‖² - 2α⟨x,Lx⟩ + α²‖Lx‖²` via bilinearity
--    of `dotProduct`. -- !--
theorem quadform_mpStep (L : Matrix (Fin n) (Fin n) ℝ) (α : ℝ) (x : Fin n → ℝ) :
    (mpStep L α x) ⬝ᵥ (mpStep L α x)
      = (x ⬝ᵥ x) - 2 * α * (x ⬝ᵥ (L *ᵥ x)) + α ^ 2 * ((L *ᵥ x) ⬝ᵥ (L *ᵥ x)) := by
  unfold mpStep
  simp [dotProduct, mul_sub, mul_assoc, mul_comm, mul_left_comm]
  simpa only [← Finset.mul_sum _ _ _, ← Finset.sum_mul] using by ring

-- !-- One-layer spectral contraction.  With spectral-gap lower bound `μ‖x‖² ≤ ⟨x,Lx⟩`,
--    operator bound `‖Lx‖² ≤ λ⟨x,Lx⟩`, and admissible step `0 ≤ α`, `αλ ≤ 2`, the energy
--    expansion plus `nlinarith` give the contraction factor `1 - αμ(2 - αλ)`. -- !--
theorem mpStep_contraction (L : Matrix (Fin n) (Fin n) ℝ) (α μ lam : ℝ) (x : Fin n → ℝ)
    (hα0 : 0 ≤ α) (hαlam : α * lam ≤ 2)
    (hgap : μ * (x ⬝ᵥ x) ≤ x ⬝ᵥ (L *ᵥ x))
    (hbound : (L *ᵥ x) ⬝ᵥ (L *ᵥ x) ≤ lam * (x ⬝ᵥ (L *ᵥ x))) :
    (mpStep L α x) ⬝ᵥ (mpStep L α x) ≤ (1 - α * μ * (2 - α * lam)) * (x ⬝ᵥ x) := by
  rw [quadform_mpStep]
  nlinarith [mul_nonneg hα0 (sub_nonneg_of_le hαlam),
    mul_le_mul_of_nonneg_left hgap hα0, mul_le_mul_of_nonneg_left hbound hα0]

-- !-- Geometric energy decay over depth: if each layer `T` contracts the quadratic
--    form by `ρ ≥ 0`, then `k` layers contract by `ρ^k`.  Induction on `k`, multiplying
--    the inductive bound by `ρ ≥ 0`. -- !--
theorem quadform_iterate_bound (T : (Fin n → ℝ) → (Fin n → ℝ)) (ρ : ℝ) (hρ : 0 ≤ ρ)
    (hstep : ∀ y, (T y) ⬝ᵥ (T y) ≤ ρ * (y ⬝ᵥ y)) (x : Fin n → ℝ) (k : ℕ) :
    (T^[k] x) ⬝ᵥ (T^[k] x) ≤ ρ ^ k * (x ⬝ᵥ x) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply', pow_succ', mul_assoc]
    exact le_trans (hstep _) (mul_le_mul_of_nonneg_left ih hρ)

-- !-- Finite spectral depth threshold: with contraction factor `ρ < 1`, the residual
--    energy `ρ^k‖x‖²` eventually drops below any `ε > 0` (geometric series tends to `0`,
--    via `quadform_iterate_bound`), so finitely many layers suffice. -- !--
theorem spectral_depth_threshold (T : (Fin n → ℝ) → (Fin n → ℝ)) (ρ : ℝ)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hstep : ∀ y, (T y) ⬝ᵥ (T y) ≤ ρ * (y ⬝ᵥ y))
    (x : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε) :
    ∃ N, ∀ k, N ≤ k → (T^[k] x) ⬝ᵥ (T^[k] x) ≤ ε := by
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ k ≥ N, ρ ^ k * (x ⬝ᵥ x) ≤ ε := by
    have htend : Filter.Tendsto (fun k : ℕ => ρ ^ k * (x ⬝ᵥ x)) Filter.atTop (nhds 0) := by
      simpa using (tendsto_pow_atTop_nhds_zero_of_lt_one hρ0 hρ1).mul_const (x ⬝ᵥ x)
    exact (htend.eventually (ge_mem_nhds hε)).exists_forall_of_atTop
  exact ⟨N, fun k hk => le_trans (quadform_iterate_bound T ρ hρ0 hstep x k) (hN k hk)⟩

end HodgeSpectralThreshold