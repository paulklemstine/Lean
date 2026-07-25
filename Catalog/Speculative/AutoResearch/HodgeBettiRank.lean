/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Hodge–Betti Rank Count

This is the foundational file of the discrete Hodge theory program.  For a two-step cochain
complex of finite-dimensional real inner product spaces

  `U --e--> V --d--> W`        with the chain condition `d ∘ e = 0`,

we define the **Hodge Laplacian** on the middle space

  `Δ = d* ∘ d + e ∘ e*  : V →ₗ V`     (`hodgeLap`),

and prove the local pieces that drive the entire program:

* `ker_adjoint_eq_orthogonal_range` — `ker f* = (range f)ᗮ` (the image/cokernel duality).
* `hodgeLap_ker` — `ker Δ = ker d ⊓ ker e*` (a cochain is harmonic iff closed and coclosed).
* `range_e_le_ker_d` — `range e ≤ ker d` (the chain condition makes exact cochains closed).
* `hodge_betti` — `dim (ker Δ) + dim (range e) = dim (ker d)` (Hodge–Betti dimension count:
  the harmonic dimension equals the `k`-th Betti number `dim ker d − rank e`).

## Catalog synthesis

This file is the root of the spectral-depth / full-Hodge-decomposition program; the
three-way splitting (`HodgeThreeWayDecomposition`) and the Hodge isomorphism
(`HodgeIsomorphism`) extend it.
-/
import Mathlib

namespace HodgeBettiRank

open LinearMap RealInnerProductSpace
open scoped InnerProductSpace

variable {U V W : Type*}
  [NormedAddCommGroup U] [InnerProductSpace ℝ U] [FiniteDimensional ℝ U]
  [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
  [NormedAddCommGroup W] [InnerProductSpace ℝ W] [FiniteDimensional ℝ W]

-- !-- Lab Notebook -- !--
-- Hypothesis: A two-step cochain complex `U --e--> V --d--> W` with `d ∘ e = 0` carries a
--   Hodge Laplacian `Δ = d* d + e e*` whose kernel (the harmonic cochains) has dimension
--   equal to the `k`-th Betti number `dim ker d − rank e`.
-- Result: The four foundational statements are proven sorry-free.
-- Insight: `ker Δ = ker d ⊓ ker e*` because `⟨Δ x, x⟩ = ‖d x‖² + ‖e* x‖²`, a sum of squares
--   that vanishes iff both terms do.  Combined with `ker e* = (range e)ᗮ` and `range e ≤ ker d`,
--   the Betti count is the relative orthogonal-complement dimension law inside `ker d`.
-- !-- end Lab Notebook -- !--

/-- The **Hodge Laplacian** of a two-step cochain complex `U --e--> V --d--> W`, acting on the
middle cochain space `V`:  `Δ = d* ∘ d + e ∘ e*`. -/
noncomputable def hodgeLap (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) : V →ₗ[ℝ] V :=
  LinearMap.adjoint d ∘ₗ d + e ∘ₗ LinearMap.adjoint e

/-
!-- `ker f* = (range f)ᗮ`: `f* x = 0` iff `⟨f y, x⟩ = ⟨y, f* x⟩ = 0` for all `y`. -- !--
-/
theorem ker_adjoint_eq_orthogonal_range {E F : Type*}
    [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
    [NormedAddCommGroup F] [InnerProductSpace ℝ F] [FiniteDimensional ℝ F]
    (f : E →ₗ[ℝ] F) :
    LinearMap.ker (LinearMap.adjoint f) = (LinearMap.range f)ᗮ := by
  ext x
  simp only [LinearMap.mem_ker, Submodule.mem_orthogonal, LinearMap.mem_range,
    forall_exists_index, forall_apply_eq_imp_iff]
  constructor
  · intro hx y
    rw [← adjoint_inner_right, hx, inner_zero_right]
  · intro hx
    apply ext_inner_right ℝ
    intro y
    rw [adjoint_inner_left, inner_zero_left]
    exact inner_eq_zero_symm.mp (hx y)

/-
!-- Harmonic = closed ∩ coclosed.  `⟨Δ x, x⟩ = ‖d x‖² + ‖e* x‖²`, so `Δ x = 0` (equivalently
`⟨Δ x, x⟩ = 0` by self-adjoint nonnegativity) iff `d x = 0` and `e* x = 0`. -- !--
-/
theorem hodgeLap_ker (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) :
    LinearMap.ker (hodgeLap d e) = LinearMap.ker d ⊓ LinearMap.ker (LinearMap.adjoint e) := by
  apply le_antisymm;
  · intro x hx;
    have h_inner : inner ℝ (d x) (d x) + inner ℝ (e.adjoint x) (e.adjoint x) = 0 := by
      simp_all +decide [ hodgeLap ];
      replace hx := congr_arg ( fun y => inner ℝ y x ) hx ; simp_all +decide [ inner_add_left, adjoint_inner_left ];
      convert hx using 2 ; rw [ ← adjoint_inner_right ] ; simp +decide;
    simp_all +decide [ inner_self_eq_norm_sq_to_K ];
    exact ⟨ norm_eq_zero.mp ( by contrapose! h_inner; positivity ), norm_eq_zero.mp ( by contrapose! h_inner; positivity ) ⟩;
  · intro x hx; simp_all +decide [ hodgeLap ] ;

-- !-- Exact ⊆ closed.  For `x = e u`, `d x = d (e u) = (d ∘ e) u = 0`. -- !--
omit [FiniteDimensional ℝ U] [FiniteDimensional ℝ V] [FiniteDimensional ℝ W] in
theorem range_e_le_ker_d (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0) :
    LinearMap.range e ≤ LinearMap.ker d := by
  rintro x ⟨u, rfl⟩
  simp only [LinearMap.mem_ker]
  have : (d ∘ₗ e) u = 0 := by rw [hde]; rfl
  simpa using this

/-
!-- Hodge–Betti count.  `ker Δ = ker d ⊓ (range e)ᗮ` (from `hodgeLap_ker`,
`ker_adjoint_eq_orthogonal_range`) and `range e ≤ ker d`; inside `ker d` the exact part
`range e` and its relative orthogonal complement are disjoint and span, so their
dimensions add to `dim ker d`. -- !--
-/
theorem hodge_betti (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0) :
    Module.finrank ℝ (LinearMap.ker (hodgeLap d e)) + Module.finrank ℝ (LinearMap.range e)
      = Module.finrank ℝ (LinearMap.ker d) := by
  convert Submodule.finrank_sup_add_finrank_inf_eq ( LinearMap.range e ) ( d.ker ⊓ ( LinearMap.range e ) ᗮ ) using 1;
  · rw [ Submodule.finrank_sup_add_finrank_inf_eq ];
    rw [ hodgeLap_ker, add_comm, ker_adjoint_eq_orthogonal_range ];
  · have h_sup : LinearMap.range e ⊔ (LinearMap.range e)ᗮ ⊓ LinearMap.ker d = LinearMap.ker d := by
      grind +suggestions;
    rw [ ← Submodule.finrank_sup_add_finrank_inf_eq, inf_comm, h_sup ];
    simp +decide [ ← inf_assoc, Submodule.inf_orthogonal_eq_bot ]

end HodgeBettiRank