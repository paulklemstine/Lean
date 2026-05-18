/-
# Graph Cochain Complex and Hodge Decomposition

This file instantiates the abstract Hodge decomposition from `Basic.lean`
to the combinatorial setting of graph cochains on finite vertex sets.

We define the concrete coboundary operators d₀ and d₁ on the cochain spaces
C⁰ = V → ℝ, C¹ = (V × V) → ℝ, C² = (V × V × V) → ℝ equipped with
L² inner products, prove the cochain complex condition d₁ ∘ d₀ = 0,
and derive the Hodge decomposition as a consequence.

## Interpretation for adversarial robustness

- **C¹**: The space of "inconsistency fields" on pairs of activation regions
- **range(d₀)**: Globally correctable inconsistency (removable by recalibrating
  region potentials)
- **range(d₁†)**: Local rotational defects (circulations around triples)
- **ker(Δ₁)**: Irreducible topological obstruction — the harmonic component
  that survives all local and global correction
-/
import Mathlib
import Algebra.HodgeDecomposition.Basic

set_option linter.unusedSectionVars false

open scoped InnerProductSpace
open LinearMap Submodule

noncomputable section

namespace GraphCochain

variable (V : Type*) [Fintype V] [DecidableEq V]

/-! ## Cochain spaces

We model the cochain spaces as `EuclideanSpace ℝ ι` where `ι` is the
appropriate indexing type. This gives us finite-dimensional real inner
product spaces automatically. -/

/-- 0-cochains: scalar functions on vertices. -/
abbrev C0 := EuclideanSpace ℝ V

/-- 1-cochains: functions on directed edges (pairs of vertices). -/
abbrev C1 := EuclideanSpace ℝ (V × V)

/-- 2-cochains: functions on directed triangles (triples of vertices). -/
abbrev C2 := EuclideanSpace ℝ (V × V × V)

/-! ## Coboundary operators

We define d₀ and d₁ by composing raw function-space linear maps with
the WithLp equivalences. This gives us clean linear maps between
EuclideanSpace types. -/

/-- Raw 0-coboundary on plain function types: (d₀ f)(i,j) = f(j) - f(i). -/
def d0_raw : (V → ℝ) →ₗ[ℝ] (V × V → ℝ) where
  toFun f p := f p.2 - f p.1
  map_add' f g := by ext p; simp; ring
  map_smul' r f := by ext p; simp; ring

/-- Raw 1-coboundary on plain function types:
    (d₁ ω)(i,j,k) = ω(i,j) - ω(i,k) + ω(j,k). -/
def d1_raw : (V × V → ℝ) →ₗ[ℝ] (V × V × V → ℝ) where
  toFun ω t := ω (t.1, t.2.1) - ω (t.1, t.2.2) + ω (t.2.1, t.2.2)
  map_add' ω η := by ext t; simp; ring
  map_smul' r ω := by ext t; simp; ring

/-- The 0-coboundary as a linear map between EuclideanSpace types. -/
def d0 : C0 V →ₗ[ℝ] C1 V :=
  (WithLp.linearEquiv 2 ℝ (V × V → ℝ)).symm.toLinearMap.comp
    ((d0_raw V).comp (WithLp.linearEquiv 2 ℝ (V → ℝ)).toLinearMap)

/-- The 1-coboundary as a linear map between EuclideanSpace types. -/
def d1 : C1 V →ₗ[ℝ] C2 V :=
  (WithLp.linearEquiv 2 ℝ (V × V × V → ℝ)).symm.toLinearMap.comp
    ((d1_raw V).comp (WithLp.linearEquiv 2 ℝ (V × V → ℝ)).toLinearMap)

/-! ## Cochain complex condition -/

/-- **d₁ ∘ d₀ = 0**: the fundamental cochain complex property.
    Algebraically: (f(j)-f(i)) - (f(k)-f(i)) + (f(k)-f(j)) = 0. -/
theorem d1_comp_d0 : HodgeDecomposition.IsCochainComplex (d0 V) (d1 V) := by
  ext f p1;
  simp +decide [ d0, d1, d0_raw, d1_raw ]

/-! ## Instantiated Hodge decomposition -/

/-- The 1-Hodge Laplacian for graph cochains:
    Δ₁ = d₀ ∘ d₀† + d₁† ∘ d₁ -/
def graphHodgeLaplacian₁ : C1 V →ₗ[ℝ] C1 V :=
  HodgeDecomposition.hodgeLaplacian₁ (d0 V) (d1 V)

/-- **Hodge Decomposition for graph 1-cochains**: Every inconsistency field
    on a finite vertex set decomposes into exact (gradient), coexact (curl†),
    and harmonic components. -/
theorem graph_hodge_decomposition (ω : C1 V) :
    ∃ (f : C0 V) (η : C2 V) (h : C1 V),
      ω = d0 V f + (LinearMap.adjoint (d1 V)) η + h ∧
      h ∈ LinearMap.ker (graphHodgeLaplacian₁ V) :=
  HodgeDecomposition.hodge_decomposition_exists (d1_comp_d0 V) ω

/-- The three subspaces span the full 1-cochain space. -/
theorem graph_hodge_decomposition_top :
    LinearMap.range (d0 V) ⊔ LinearMap.range (LinearMap.adjoint (d1 V)) ⊔
      LinearMap.ker (graphHodgeLaplacian₁ V) = ⊤ :=
  HodgeDecomposition.hodge_decomposition_sup (d1_comp_d0 V)

/-- **Harmonic characterization**: ker(Δ₁) = ker(d₁) ∩ ker(d₀†).
    A 1-cochain is an irreducible topological obstruction iff it is
    simultaneously closed and co-closed. -/
theorem graph_harmonic_characterization :
    LinearMap.ker (graphHodgeLaplacian₁ V) =
      LinearMap.ker (d1 V) ⊓ LinearMap.ker (LinearMap.adjoint (d0 V)) :=
  HodgeDecomposition.ker_hodgeLaplacian₁_eq (d1_comp_d0 V)

/-- Exact and coexact 1-cochains are orthogonal:
    gradient inconsistency ⟂ rotational defects. -/
theorem graph_exact_coexact_orthogonal {u v : C1 V}
    (hu : u ∈ LinearMap.range (d0 V))
    (hv : v ∈ LinearMap.range (LinearMap.adjoint (d1 V))) :
    @inner ℝ _ _ u v = 0 :=
  HodgeDecomposition.inner_range_d₀_range_adjoint_d₁ (d1_comp_d0 V) hu hv

end GraphCochain

end