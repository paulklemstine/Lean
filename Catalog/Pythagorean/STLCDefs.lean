/-
# Simply Typed Lambda Calculus: Definitions

Extends the untyped lambda calculus from BoundedBetaDefs with:
- Simple types (base type + arrow types)
- Typing contexts and typing judgments
- Type complexity measures
- Strong normalization definitions
- Reduction graph and DAG structures

These definitions support the finite model property theorems.
-/

import Pythagorean.BoundedBetaDefs

/-! ## Simple Types -/

/-- Simple types for STLC: a base type and arrow (function) types. -/
inductive Ty : Type where
  | base : Ty
  | arrow : Ty → Ty → Ty
  deriving DecidableEq, Repr

namespace Ty

/-- The depth (nesting level) of arrow types. -/
def depth : Ty → Nat
  | base => 0
  | arrow s t => 1 + max s.depth t.depth

/-- The size of a type (number of constructors). -/
def size : Ty → Nat
  | base => 1
  | arrow s t => 1 + s.size + t.size

/-- Type complexity: a combined measure used for normalization bounds.
    For base types, complexity is 1.
    For arrow types, complexity grows multiplicatively. -/
def complexity : Ty → Nat
  | base => 1
  | arrow s t => (s.complexity + 1) * (t.complexity + 1)

theorem complexity_pos (τ : Ty) : 0 < τ.complexity := by
  induction τ with
  | base => simp [complexity]
  | arrow s t ih_s ih_t =>
    simp only [complexity]
    exact Nat.mul_pos (by omega) (by omega)

end Ty

/-! ## Typing Context -/

/-- A typing context maps variable indices to types. -/
def Ctx := List (Nat × Ty)

namespace Ctx

/-- Look up a variable in a context. -/
def lookup : Ctx → Nat → Option Ty
  | [], _ => none
  | (y, τ) :: Γ, x => if x = y then some τ else lookup Γ x

/-- Extend a context with a new binding. -/
def extend (Γ : Ctx) (x : Nat) (τ : Ty) : Ctx := (x, τ) :: Γ

end Ctx

/-! ## Typing Judgment -/

/-- Typing judgment: `HasType Γ t τ` means term `t` has type `τ` in context `Γ`. -/
inductive HasType : Ctx → Lam → Ty → Prop where
  | var (Γ : Ctx) (x : Nat) (τ : Ty) (h : Γ.lookup x = some τ) :
      HasType Γ (.var x) τ
  | app (Γ : Ctx) (t u : Lam) (σ τ : Ty)
      (ht : HasType Γ t (.arrow σ τ)) (hu : HasType Γ u σ) :
      HasType Γ (.app t u) τ
  | lam (Γ : Ctx) (x : Nat) (σ τ : Ty) (body : Lam)
      (hb : HasType (Γ.extend x σ) body τ) :
      HasType Γ (.lam x body) (.arrow σ τ)

/-! ## Strong Normalization -/

/-- A term is strongly normalizing if every reduction sequence from it terminates.
    Defined via well-founded accessibility of the inverse beta-step relation. -/
def SN (t : Lam) : Prop := Acc (fun u v => BetaStep v u) t

/-- A term is in normal form if no beta reduction applies. -/
def IsNormalForm (t : Lam) : Prop := ∀ u, ¬ BetaStep t u

/-- Normal forms are strongly normalizing. -/
theorem SN_of_normalForm {t : Lam} (h : IsNormalForm t) : SN t :=
  Acc.intro t (fun u hu => absurd hu (h u))

/-- SN is closed under backward steps: if all one-step reducts of t are SN,
    and t itself has no infinite reduction, then t is SN. -/
theorem SN_intro {t : Lam} (h : ∀ u, BetaStep t u → SN u) : SN t :=
  Acc.intro t (fun u hu => h u hu)

/-! ## Typed Term Bundle -/

/-- A typed lambda term: a term together with its typing derivation. -/
structure TypedLam where
  ctx : Ctx
  term : Lam
  ty : Ty
  hasType : HasType ctx term ty

namespace TypedLam

/-- Extract the underlying untyped term. -/
def toLam (t : TypedLam) : Lam := t.term

/-- Size of the underlying term. -/
def termSize (t : TypedLam) : Nat := t.term.size

end TypedLam

/-! ## Reduction Sequences -/

/-- A list of terms forms a valid reduction sequence. -/
def IsReductionSequence : List Lam → Prop
  | [] => True
  | [_] => True
  | t :: u :: rest => BetaStep t u ∧ IsReductionSequence (u :: rest)

/-- The multi-step beta reduction relation (transitive-reflexive closure). -/
inductive BetaStarStep : Lam → Lam → Prop where
  | refl (t : Lam) : BetaStarStep t t
  | step {t u v : Lam} (h₁ : BetaStarStep t u) (h₂ : BetaStep u v) :
      BetaStarStep t v

/-- BetaStarStep is transitive. -/
theorem BetaStarStep.trans {t u v : Lam}
    (h₁ : BetaStarStep t u) (h₂ : BetaStarStep u v) :
    BetaStarStep t v := by
  induction h₂ with
  | refl => exact h₁
  | step _ h₂b ih => exact .step ih h₂b

/-- A single step embeds into multi-step. -/
theorem BetaStarStep.single {t u : Lam} (h : BetaStep t u) :
    BetaStarStep t u :=
  .step (.refl t) h

/-! ## Reduction Graph -/

/-- The reduction graph of a term: vertices are reachable terms,
    edges are beta-step relations between them. -/
structure ReductionGraph where
  root : Lam
  vertices : Set Lam
  edges : Set (Lam × Lam)
  root_mem : root ∈ vertices
  edges_sub : ∀ p ∈ edges, p.1 ∈ vertices ∧ p.2 ∈ vertices

/-- Construct the reduction graph of a term. -/
noncomputable def reductionGraphOf (t : Lam) : ReductionGraph where
  root := t
  vertices := {u | BetaStarStep t u}
  edges := {p | BetaStarStep t p.1 ∧ BetaStep p.1 p.2}
  root_mem := BetaStarStep.refl t
  edges_sub := fun p ⟨h1, h2⟩ => ⟨h1, BetaStarStep.step h1 h2⟩

/-- A reduction graph is a DAG if the edge relation is well-founded on vertices. -/
def IsDAG' (G : ReductionGraph) : Prop :=
  WellFounded (fun u v => (v, u) ∈ G.edges)

/-! ## Bounded FTS for Typed Terms -/

/-- Extract a bounded FTS from a typed term using type complexity as depth bound. -/
noncomputable def toBoundedFTSTyped (t : TypedLam) : FTS :=
  toFTS (Ty.complexity t.ty ^ t.termSize) t.toLam

/-- Type complexity function used in bound statements. -/
def typeComplexity (τ : Ty) : Nat := τ.complexity

/-- Type depth function. -/
def typeDepth (τ : Ty) : Nat := τ.depth

/-! ## Connecting ReachableWithin and BetaStarStep -/

/-- ReachableWithin embeds into BetaStarStep. -/
theorem reachableWithin_to_betaStarStep {d : Nat} {t u : Lam}
    (h : ReachableWithin d t u) : BetaStarStep t u := by
  induction h with
  | refl => exact .refl _
  | step _ h₂ ih => exact .step ih h₂

/-- BetaStarStep embeds into ReachableWithin for some depth. -/
theorem betaStarStep_to_reachableWithin {t u : Lam}
    (h : BetaStarStep t u) : ∃ d, ReachableWithin d t u := by
  induction h with
  | refl => exact ⟨0, .refl 0 _⟩
  | step _ h₂ ih =>
    obtain ⟨d, hd⟩ := ih
    exact ⟨d + 1, .step hd h₂⟩