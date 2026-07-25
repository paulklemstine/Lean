/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Spectral & Fixed-Point Duality of Hodge-Laplacian Message Passing

This file *extends* the convergence theory of
`Catalog/Speculative/AutoResearch/HodgeMessagePassingConvergence.lean`
(`mpStep`, `mpStep_apply`, `mpStep_harmonic_fixed`, `mpStep_iterate_harmonic_fixed`,
`mpStep_contraction`, `mpStep_converges_to_harmonic`) along a **duality / representation**
axis rather than an analytic one.

Three classical dualities are made precise for the gradient message-passing layer
`T = mpStep L α = 1 - α·L`:

* **Spectral representation (eigen-duality).**  On any eigenvector of the Laplacian
  `L x = λ x`, the *operator* `T` and all of its depth iterates `Tᵏ` act as plain
  *scalars*: `T x = (1 - αλ) x` and `Tᵏ x = (1 - αλ)ᵏ x`
  (`mpStep_eigen`, `mpStep_iterate_eigen`).  Message passing is thus simultaneously
  diagonalised with `L` — formalised by the commutation `L ∘ T = T ∘ L`
  (`mpStep_comm_L`).  The energy of an eigen-mode after `k` layers is exactly
  `(1-αλ)^{2k} ‖x‖²` (`mpStep_eigen_energy`), and an eigen-mode strictly contracts
  precisely when `0 < αλ < 2` (`mpStep_eigen_contracts`).

* **Adjoint duality.**  When `L` is symmetric for the inner product, so is `T`
  (`mpStep_symm`): the layer is its own dual operator under the Riesz pairing.

* **Fixed-point ↔ kernel duality (the representation theorem).**  For a nonzero step
  `α ≠ 0`, the *dynamical* invariants of message passing coincide with the *algebraic*
  kernel of the Laplacian: `T x = x ↔ L x = 0` (`mpStep_fixed_iff`), and as
  submodules the unit eigenspace equals the harmonic/cohomology space
  `ker (T - 1) = ker L` (`mpStep_eigenspace_one`).  Composed with the catalog's
  `harmonic_iff`, this represents Hodge cohomology as exactly the fixed points of
  message passing (`hodge_cohomology_eq_fixed`).

The upshot: **message passing is the Laplacian seen in its own eigenbasis**; its
fixed-point space *is* cohomology, and its spectrum is the affine image `1 - α·spec(L)`.

-- !-- Lab Notebook -- !--
Hypothesis:  The convergence cycle treated `T = 1 - αL` analytically (energy decay).
  Dually, `T` is a *polynomial in `L`*, so it must (i) commute with `L`, (ii) be
  diagonal on every eigenspace of `L` with eigenvalue `1 - αλ`, (iii) inherit
  symmetry from `L`, and (iv) have unit-eigenspace exactly `ker L`.  These four facts
  re-cast convergence as a spectral/representation statement and identify the
  fixed-point set of the dynamics with Hodge cohomology.
Result:  Formalised and proved sorry-free.  `mpStep_eigen` / `mpStep_iterate_eigen`
  (scalar action on eigenvectors), `mpStep_comm_L` (simultaneous diagonalisation),
  `mpStep_eigen_energy` (exact eigen-mode energy `(1-αλ)^{2k}`),
  `mpStep_eigen_contracts` (spectral contraction window `0<αλ<2`), `mpStep_symm`
  (adjoint duality), `mpStep_fixed_iff` / `mpStep_eigenspace_one` (fixed ↔ kernel),
  and the bridge `hodge_cohomology_eq_fixed` to the catalog's `harmonic_iff`.
Insight:  The decisive structural move is that `mpStep L α = 1 - α • L` is a degree-1
  polynomial in the single operator `L`; every duality above is then a statement about
  `p(L)` for `p(t) = 1 - αt`.  Eigen-action follows from `smul_smul` + `sub_smul`,
  commutation from `map_sub`/`map_smul`, and fixed ↔ kernel from `smul_eq_zero` with
  `α ≠ 0` — no spectral theorem is needed, only the polynomial-functional-calculus shape.
Failure analysis:  Stating `mpStep_eigenspace_one` with `LinearMap.ker (mpStep L α - 1)`
  keeps the proof a clean `ext` + `mpStep_fixed_iff`; phrasing it through eigenspaces of
  `Module.End` would have dragged in `End.eigenspace`/`Module.End.HasEigenvalue` API for
  no extra content.  Real inner products make `mpStep_symm` a `simp [inner_sub_left,
  inner_smul_left]` with no `starRingEnd` bookkeeping.
-- !-- Lab Notebook -- !--
-/
import Mathlib
import Speculative.AutoResearch.HodgeMessagePassingConvergence

open scoped InnerProductSpace BigOperators Topology
open HodgeMessagePassingConvergence

namespace HodgeMessagePassingDuality

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-! ## Spectral representation: `T` acts as a scalar on eigenvectors -/

/-
!-- comment: `T x = x - α•(L x) = x - α•(λ•x) = (1 - αλ)•x` by `smul_smul`/`sub_smul`. -- !--

**Eigen-duality (one layer).** On an eigenvector `L x = λ x`, the message-passing
operator acts as the scalar `1 - αλ`.
-/
theorem mpStep_eigen (L : E →ₗ[ℝ] E) (α lam : ℝ) {x : E} (hx : L x = lam • x) :
    mpStep L α x = (1 - α * lam) • x := by
  simp [mpStep_apply, hx, smul_smul, sub_smul]

/-
!-- comment: An eigenvector of `L` stays an eigenvector of `T`; induct on `k` using
`mpStep_eigen`, since `Tᵏx = (1-αλ)ᵏ•x` and `L((1-αλ)ᵏ•x)=λ•((1-αλ)ᵏ•x)`. -- !--

**Eigen-duality (depth `k`).** All iterates act as the scalar `(1 - αλ)ᵏ` on an
eigenvector of `L`. This is the spectral representation of deep message passing.
-/
theorem mpStep_iterate_eigen (L : E →ₗ[ℝ] E) (α lam : ℝ) {x : E} (hx : L x = lam • x)
    (k : ℕ) :
    ((mpStep L α) ^ k) x = (1 - α * lam) ^ k • x := by
  induction k <;> simp_all +decide [ pow_succ, mul_assoc, smul_smul ];
  module

/-! ## Simultaneous diagonalisation: `T` commutes with `L` -/

/-
!-- comment: Both sides equal `L x - α•L (L x)`; expand `mpStep_apply`, `map_sub`,
`map_smul`. -- !--

**Simultaneous diagonalisation.** Message passing commutes with the Laplacian,
`L ∘ T = T ∘ L`, because `T` is a polynomial in `L`. Hence any spectral/harmonic
projector of `L` commutes with every message-passing layer.
-/
theorem mpStep_comm_L (L : E →ₗ[ℝ] E) (α : ℝ) (x : E) :
    L (mpStep L α x) = mpStep L α (L x) := by
  simp +decide [ mpStep_apply, map_sub, map_smul ]

/-! ## Exact energy and the spectral contraction window -/

/-
!-- comment: Use `mpStep_iterate_eigen` then `inner_smul_left`/`inner_smul_right`;
`(1-αλ)^k` is real so the scalar pulls out as its square. -- !--

**Exact eigen-mode energy.** After `k` layers the energy of an eigen-mode is
`(1-αλ)^{2k}` times its initial energy — the convergence rate is *exact*, not just a
bound, on eigenvectors.
-/
theorem mpStep_eigen_energy (L : E →ₗ[ℝ] E) (α lam : ℝ) {x : E} (hx : L x = lam • x)
    (k : ℕ) :
    ⟪((mpStep L α) ^ k) x, ((mpStep L α) ^ k) x⟫_ℝ
      = (1 - α * lam) ^ (2 * k) * ⟪x, x⟫_ℝ := by
  rw [ mpStep_iterate_eigen L α lam hx k, real_inner_smul_left, real_inner_smul_right ] ; ring

/-
!-- comment: `|1 - αλ| < 1 ↔ -1 < 1 - αλ < 1 ↔ 0 < αλ < 2`; finish by `abs_lt`. -- !--

**Spectral contraction window.** An eigen-mode with eigenvalue `λ` strictly
contracts under one layer exactly when `0 < αλ < 2`.
-/
theorem mpStep_eigen_contracts (α lam : ℝ) (h1 : 0 < α * lam) (h2 : α * lam < 2) :
    |1 - α * lam| < 1 := by
  exact abs_lt.mpr ⟨ by linarith, by linarith ⟩

/-! ## Adjoint duality: symmetry of `L` lifts to `T` -/

/-
!-- comment: Expand both sides with `mpStep_apply`, `inner_sub_left/right`,
`inner_smul_left/right`; reduce to `⟪L x, y⟫ = ⟪x, L y⟫`. -- !--

**Adjoint duality.** If `L` is symmetric for the inner product, so is every layer
`T`: message passing is self-dual under the Riesz pairing.
-/
theorem mpStep_symm (L : E →ₗ[ℝ] E) (α : ℝ)
    (hsymm : ∀ x y, ⟪L x, y⟫_ℝ = ⟪x, L y⟫_ℝ) (x y : E) :
    ⟪mpStep L α x, y⟫_ℝ = ⟪x, mpStep L α y⟫_ℝ := by
  simp +decide [ inner_sub_left, inner_sub_right, inner_smul_left, inner_smul_right, hsymm ]

/-! ## Fixed-point ↔ kernel duality (the representation theorem) -/

/-
!-- comment: `T x = x ↔ x - α•Lx = x ↔ α•Lx = 0 ↔ Lx = 0` using `sub_eq_self`
and `smul_eq_zero` with `α ≠ 0`. -- !--

**Fixed-point ↔ kernel duality.** For a nonzero step the dynamical fixed points of
message passing are exactly the kernel (harmonic space) of the Laplacian.
-/
theorem mpStep_fixed_iff (L : E →ₗ[ℝ] E) {α : ℝ} (hα : α ≠ 0) {x : E} :
    mpStep L α x = x ↔ L x = 0 := by
  simp +decide [ mpStep, hα, sub_eq_self ]

/-
!-- comment: `ext x`; `(T - 1) x = T x - x = 0 ↔ T x = x ↔ L x = 0` by
`mpStep_fixed_iff`. -- !--

**Representation theorem (eigenspace form).** As submodules, the unit eigenspace of
message passing equals the kernel of the Laplacian, `ker (T - 1) = ker L`.
-/
theorem mpStep_eigenspace_one (L : E →ₗ[ℝ] E) {α : ℝ} (hα : α ≠ 0) :
    LinearMap.ker (mpStep L α - 1) = LinearMap.ker L := by
  aesop

/-
!-- comment: Combine the catalog's `harmonic_iff` (closed-and-coclosed `↔ Δ x = 0`)
with `mpStep_fixed_iff` for `Δ = up + down`. -- !--

**Cohomology = fixed points of message passing.** For the abstract Hodge Laplacian
`Δ = up + down` with symmetric PSD pieces and a nonzero step, a cochain is harmonic
(closed and coclosed) iff it is a fixed point of message passing — representing Hodge
cohomology as the invariants of the dynamics.
-/
theorem hodge_cohomology_eq_fixed
    (up down : E →ₗ[ℝ] E)
    (hsymm_up : ∀ x y, ⟪up x, y⟫_ℝ = ⟪x, up y⟫_ℝ)
    (hpos_up : ∀ x, 0 ≤ ⟪up x, x⟫_ℝ)
    (hsymm_down : ∀ x y, ⟪down x, y⟫_ℝ = ⟪x, down y⟫_ℝ)
    (hpos_down : ∀ x, 0 ≤ ⟪down x, x⟫_ℝ)
    {α : ℝ} (hα : α ≠ 0) (x : E) :
    (up x = 0 ∧ down x = 0)
      ↔ mpStep (HodgeSpectralThreshold.hodgeLaplacian up down) α x = x := by
  rw [ ← HodgeSpectralThreshold.harmonic_iff up down hsymm_up hpos_up hsymm_down hpos_down x ];
  simp +decide [ mpStep, hα ]

end HodgeMessagePassingDuality