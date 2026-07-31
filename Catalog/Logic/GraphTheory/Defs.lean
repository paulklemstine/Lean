import Mathlib

/-!
# List choosability

A graph is `k`-choosable when every assignment of at least `k` permitted natural-number
colours to each vertex admits a proper colouring selected from those lists.
-/

open SimpleGraph Finset

namespace ListChoosability

/-- List choosability for finite graphs, using natural numbers as a common colour universe. -/
def Choosable {V : Type*} (G : SimpleGraph V) (k : ℕ) : Prop :=
  ∀ L : V → Finset ℕ, (∀ v, k ≤ (L v).card) →
    ∃ c : V → ℕ, (∀ v, c v ∈ L v) ∧ ∀ u v, G.Adj u v → c u ≠ c v

end ListChoosability
namespace TropicalChoquetVoronoi

/-- A finite closure operator, presented by its action on finite subsets. -/
structure TropicalClosureOp (M : Type*) [DecidableEq M] where
  hull : Finset M → Finset M
  extensive : ∀ S, S ⊆ hull S
  mono : ∀ {S T}, S ⊆ T → hull S ⊆ hull T
  idempotent : ∀ S, hull (hull S) = hull S

/-- An extremal generator does not lie in the hull of the other generators. -/
def IsTropExtremal {M : Type*} [DecidableEq M]
    (op : TropicalClosureOp M) (Ext : Finset M) (e : M) : Prop :=
  e ∈ Ext ∧ e ∉ op.hull (Ext.erase e)

/-- A support contains the represented point and no proper sub-support does. -/
def SupportCertifiedBy {M : Type*} [DecidableEq M]
    (op : TropicalClosureOp M) (σ : Finset M) (x : M) : Prop :=
  x ∈ op.hull σ ∧ ∀ τ : Finset M, τ ⊂ σ → x ∉ op.hull τ

/-- A minimal tropical support drawn from a specified generator set. -/
def IsMinimalTropSupport {M : Type*} [DecidableEq M]
    (op : TropicalClosureOp M) (Ext σ : Finset M) (x : M) : Prop :=
  σ ⊆ Ext ∧ SupportCertifiedBy op σ x

/-- A finite abstract simplicial complex represented by its downward-closed faces. -/
structure AbstractSimplicialComplex (M : Type*) [DecidableEq M] where
  faces : Set (Finset M)
  downward_closed : ∀ {σ τ}, σ ∈ faces → τ ⊆ σ → τ ∈ faces

/-- The simplicial complex consisting of all subsets of the selected supports. -/
def TropSupportComplex {M : Type*} [DecidableEq M] (Supp : M → Finset M) :
    AbstractSimplicialComplex M where
  faces := {σ | ∃ x, σ ⊆ Supp x}
  downward_closed := by
    rintro σ τ ⟨x, hx⟩ hτσ
    exact ⟨x, hτσ.trans hx⟩

/-- Correctness conditions for reconstruction from a family of supports. -/
def SupportReconstructionCorrect {M : Type*} [DecidableEq M]
    (op : TropicalClosureOp M) (Ext : Finset M) (Supp : M → Finset M)
    (V : AbstractSimplicialComplex M) : Prop :=
  (∀ x, Supp x ∈ V.faces) ∧
  (∀ σ, σ ∈ V.faces → ∃ x, σ ⊆ Supp x) ∧
  (∀ e ∈ Ext, ∃ x, e ∈ Supp x) ∧
  (∀ x, Supp x ⊆ Ext)

/-- A map compatible with finite tropical hulls. -/
structure TropSemimodMorphism
    (M N : Type*) [DecidableEq M] [DecidableEq N]
    (opM : TropicalClosureOp M) (opN : TropicalClosureOp N) where
  toFun : M → N
  hull_compat : ∀ S, (opM.hull S).image toFun ⊆ opN.hull (S.image toFun)

end TropicalChoquetVoronoi