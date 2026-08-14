import Mathlib

/-!
# Core objects for tropical Choquet–Voronoi duality

This module supplies the definitions used by `Bridges/TropicalChoquetVoronoiDuality.lean`,
which referred to a `TropicalChoquetVoronoi` vocabulary that no module in the catalog
provided.

* `TropicalClosureOp M` — a finitary closure operator on a finite carrier, the
  combinatorial skeleton of a tropical (idempotent) convex hull;
* `IsTropExtremal`, `SupportCertifiedBy`, `IsMinimalTropSupport` — extremality and
  minimal support data;
* `AbstractSimplicialComplex M` and the support complex `TropSupportComplex`;
* `SupportReconstructionCorrect` — the correctness certificate for reconstructing the
  incidence geometry from support data;
* `TropSemimodMorphism` — hull-compatible maps.
-/

namespace TropicalChoquetVoronoi

variable {M : Type*} [DecidableEq M] [Fintype M]

/-- A **tropical closure operator**: an extensive, monotone, idempotent hull operation
on finite subsets.  This is the combinatorial skeleton of tropical convexity. -/
structure TropicalClosureOp (M : Type*) [DecidableEq M] [Fintype M] where
  /-- The hull of a finite set. -/
  hull : Finset M → Finset M
  /-- The hull contains its argument. -/
  extensive : ∀ S, S ⊆ hull S
  /-- The hull is monotone. -/
  mono : ∀ {S T}, S ⊆ T → hull S ⊆ hull T
  /-- The hull is idempotent. -/
  idempotent : ∀ S, hull (hull S) = hull S

/-- `e` is **tropically extremal** in `Ext` when it belongs to `Ext` but not to the hull
of the other generators. -/
def IsTropExtremal (op : TropicalClosureOp M) (Ext : Finset M) (e : M) : Prop :=
  e ∈ Ext ∧ e ∉ op.hull (Ext.erase e)

/-- `σ` **certifies the support** of `x` when `x` lies in the hull of `σ` and in the hull
of no proper subset of `σ`. -/
def SupportCertifiedBy (op : TropicalClosureOp M) (σ : Finset M) (x : M) : Prop :=
  x ∈ op.hull σ ∧ ∀ τ : Finset M, τ ⊂ σ → x ∉ op.hull τ

/-- `σ` is a **minimal support** of `x` inside the generating set `Ext`. -/
def IsMinimalTropSupport (op : TropicalClosureOp M) (Ext : Finset M) (σ : Finset M)
    (x : M) : Prop :=
  σ ⊆ Ext ∧ SupportCertifiedBy op σ x

/-- A finite **abstract simplicial complex** on `M`, given by its downward-closed family
of faces. -/
structure AbstractSimplicialComplex (M : Type*) where
  /-- The faces of the complex. -/
  faces : Set (Finset M)
  /-- Faces are closed under passing to subsets. -/
  down_closed : ∀ σ ∈ faces, ∀ τ : Finset M, τ ⊆ σ → τ ∈ faces

/-- The **support complex** of a support assignment: the subsets of individual
supports. -/
def TropSupportComplex {M : Type*} (Supp : M → Finset M) : AbstractSimplicialComplex M where
  faces := {σ : Finset M | ∃ x : M, σ ⊆ Supp x}
  down_closed := by
    rintro σ ⟨x, hx⟩ τ hτ
    exact ⟨x, hτ.trans hx⟩

/-- The **reconstruction certificate**: the complex `V` contains every support, every
face is contained in a support, every generator is used, and supports lie in `Ext`. -/
def SupportReconstructionCorrect (_op : TropicalClosureOp M) (Ext : Finset M)
    (Supp : M → Finset M) (V : AbstractSimplicialComplex M) : Prop :=
  (∀ x : M, Supp x ∈ V.faces) ∧
    (∀ σ ∈ V.faces, ∃ x : M, σ ⊆ Supp x) ∧
      (∀ e ∈ Ext, ∃ x : M, e ∈ Supp x) ∧
        (∀ x : M, Supp x ⊆ Ext)

/-- A **morphism of tropical semimodules**: a map whose image of a hull lands in the hull
of the image. -/
structure TropSemimodMorphism (M N : Type*) [DecidableEq M] [Fintype M]
    [DecidableEq N] [Fintype N]
    (opM : TropicalClosureOp M) (opN : TropicalClosureOp N) where
  /-- The underlying map. -/
  toFun : M → N
  /-- Hull compatibility. -/
  hull_compat : ∀ S : Finset M, (opM.hull S).image toFun ⊆ opN.hull (S.image toFun)

end TropicalChoquetVoronoi