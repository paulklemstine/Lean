/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Cubical Semantics: Interval, Path, and Function Extensionality

This file develops a semantic cubical interface inside Lean 4, defining interval-like
structure, path types, and fundamental operations on paths. The main result is
**dependent function extensionality at the path level**: pointwise paths between dependent
functions induce a path between the functions themselves.

## Main definitions

- `CubicalInterval` — Type class for interval objects with two endpoints and reversal
- `PathOver` — Path type as interval-indexed functions with boundary conditions
- `reflPath` — Constant path (reflexivity)
- `pathSymm` — Path reversal (symmetry)
- `ap` — Functorial action on paths
- `pathReparam` — Reparametrization of paths

## Main results

- `path_ext` — Extensionality principle for paths
- `path_eta` — Eta expansion for paths
- `ap_compose` — Functoriality of `ap` under composition
- `ap_id` — Identity preservation for `ap`
- `ap_reflPath` — `ap` on constant paths
- `funext_of_path` — Dependent function extensionality from pointwise paths
- `funext_of_path_nondep` — Non-dependent function extensionality from pointwise paths
- `pathSymm_pathSymm` — Path reversal is involutive (with involution hypothesis)

## Design choices

We model the cubical interval abstractly via a type class `CubicalInterval I` requiring
only two endpoints `i0, i1 : I` and a reversal `rev : I → I`. The path type
`PathOver A a₀ a₁` is the subtype of functions `I → A` satisfying boundary conditions.
This formulation is general enough to support any interval model (including `Bool`, `Fin 2`,
or richer structures) while remaining concrete enough for Lean's type theory.
-/

namespace CubicalSemantics

/-- A cubical interval is a type with two distinguished endpoints and a reversal operation
    satisfying boundary conditions. This is the minimal structure needed for path algebra. -/
class CubicalInterval (I : Type u) where
  /-- The left endpoint of the interval. -/
  i0 : I
  /-- The right endpoint of the interval. -/
  i1 : I
  /-- Reversal (orientation-reversing involution). -/
  rev : I → I
  /-- Reversal sends the left endpoint to the right. -/
  rev_i0 : rev i0 = i1
  /-- Reversal sends the right endpoint to the left. -/
  rev_i1 : rev i1 = i0

/-- A path in type `A` from `a₀` to `a₁` over an interval `I` is a function `I → A`
    whose value at `i0` is `a₀` and at `i1` is `a₁`. This is the semantic analogue of
    the identity/path type in cubical type theory. -/
def PathOver {I : Type u} [CubicalInterval I] (A : Type v) (a₀ a₁ : A) : Type (max u v) :=
  { p : I → A // p (CubicalInterval.i0) = a₀ ∧ p (CubicalInterval.i1) = a₁ }

/-- `Bool` as a cubical interval: `false` is the left endpoint, `true` is the right. -/
instance : CubicalInterval Bool where
  i0 := false
  i1 := true
  rev := (! ·)
  rev_i0 := rfl
  rev_i1 := rfl

/-- `Fin 2` as a cubical interval. -/
instance : CubicalInterval (Fin 2) where
  i0 := 0
  i1 := 1
  rev := fun i => 1 - i
  rev_i0 := by decide
  rev_i1 := by decide

variable {I : Type u} [CubicalInterval I]

/-- The constant (reflexivity) path at a point. -/
def reflPath {A : Type v} (a : A) : PathOver (I := I) A a a :=
  ⟨fun _ => a, rfl, rfl⟩

/-- Path reversal (symmetry): reverses the direction of a path using the interval's
    reversal operation. -/
def pathSymm {A : Type v} {a₀ a₁ : A}
    (p : PathOver (I := I) A a₀ a₁) : PathOver (I := I) A a₁ a₀ :=
  ⟨p.1 ∘ CubicalInterval.rev,
   by simp [Function.comp, CubicalInterval.rev_i0, p.2.2],
   by simp [Function.comp, CubicalInterval.rev_i1, p.2.1]⟩

/-- Functorial action of a function on paths: if `p` is a path from `a₀` to `a₁`,
    then `ap f p` is a path from `f a₀` to `f a₁`. -/
def ap {A : Type v} {B : Type w}
    (f : A → B) {a₀ a₁ : A} (p : PathOver (I := I) A a₀ a₁) :
    PathOver (I := I) B (f a₀) (f a₁) :=
  ⟨f ∘ p.1,
   by simp [Function.comp, p.2.1],
   by simp [Function.comp, p.2.2]⟩

/-- Reparametrization of a path by an endpoint-preserving map on the interval. -/
def pathReparam {A : Type v} {a₀ a₁ : A}
    (p : PathOver (I := I) A a₀ a₁) (φ : I → I)
    (hφ0 : φ CubicalInterval.i0 = CubicalInterval.i0)
    (hφ1 : φ CubicalInterval.i1 = CubicalInterval.i1) :
    PathOver (I := I) A a₀ a₁ :=
  ⟨p.1 ∘ φ,
   by simp [Function.comp, hφ0, p.2.1],
   by simp [Function.comp, hφ1, p.2.2]⟩

/-! ### Path extensionality and eta -/

/-
Two paths are equal if their underlying functions agree pointwise.
-/
theorem path_ext {A : Type v} {a₀ a₁ : A}
    {p q : PathOver (I := I) A a₀ a₁} (h : ∀ i, p.1 i = q.1 i) : p = q := by
  exact Subtype.ext <| funext h

/-
Eta expansion for paths is an identity.
-/
theorem path_eta {A : Type v} {a₀ a₁ : A}
    (p : PathOver (I := I) A a₀ a₁) :
    (⟨p.1, ⟨p.2.1, p.2.2⟩⟩ : PathOver (I := I) A a₀ a₁) = p := by
  -- The equality follows from the fact that the first component of `p` is equal to itself, and the second and third components are equal by definition.
  congr

/-! ### Functoriality of `ap` -/

/-
`ap` preserves composition: applying a composite function is the same as
    applying each function in sequence. This is the path-level analogue of functoriality.
-/
theorem ap_compose {A : Type v} {B : Type w} {C : Type x}
    (g : B → C) (f : A → B) {a₀ a₁ : A}
    (p : PathOver (I := I) A a₀ a₁) :
    ap (I := I) (g ∘ f) p = ap g (ap f p) := by
  exact Subtype.ext rfl

/-
`ap` preserves the identity function.
-/
theorem ap_id {A : Type v} {a₀ a₁ : A}
    (p : PathOver (I := I) A a₀ a₁) :
    ap (I := I) id p = p := by
  exact Subtype.ext rfl

/-
`ap` on a constant path yields a constant path.
-/
theorem ap_reflPath {A : Type v} {B : Type w} (f : A → B) (a : A) :
    ap (I := I) f (reflPath a) = reflPath (f a) := by
  -- To prove the equality of the two paths, we can use extensionality.
  apply Subtype.ext;
  -- By definition of `ap`, we have `ap f (reflPath a) = fun i => f (reflPath a i)`.
  funext i; simp [ap, reflPath]

/-! ### Path symmetry properties -/

/-
Path reversal is involutive when the interval's reversal is an involution.
-/
theorem pathSymm_pathSymm
    (hrev : ∀ i : I, CubicalInterval.rev (CubicalInterval.rev i) = i)
    {A : Type v} {a₀ a₁ : A}
    (p : PathOver (I := I) A a₀ a₁) :
    pathSymm (pathSymm p) = p := by
  unfold pathSymm;
  exact Subtype.ext <| funext fun i => by simp +decide [ hrev ] ;

/-
Reversing a constant path yields the same constant path.
-/
theorem pathSymm_reflPath {A : Type v} (a : A) :
    pathSymm (reflPath (I := I) a) = reflPath a := by
  exact Subtype.ext ( funext fun _ => rfl )

/-! ### Function extensionality from paths -/

/-
**Dependent function extensionality from paths.** Given a pointwise family of paths
    `h x : PathOver (β x) (f x) (g x)` for each `x : α`, there is a path from `f` to `g`
    in the type of dependent functions `(x : α) → β x`.

    This is the central theorem connecting the cubical path formalism to extensional
    principles: it shows that the path object `PathOver` has enough coherence to recover
    function extensionality.
-/
def funext_of_path
    {α : Type v} {β : α → Type w}
    {f g : (x : α) → β x}
    (h : ∀ x, PathOver (I := I) (β x) (f x) (g x)) :
    PathOver (I := I) ((x : α) → β x) f g :=
  ⟨fun i x => (h x).1 i,
   funext fun x => (h x).2.1,
   funext fun x => (h x).2.2⟩

/-
**Non-dependent function extensionality from paths.** A specialization of
    `funext_of_path` to non-dependent function types.
-/
def funext_of_path_nondep
    {α : Type v} {β : Type w}
    {f g : α → β}
    (h : ∀ x, PathOver (I := I) β (f x) (g x)) :
    PathOver (I := I) (α → β) f g :=
  ⟨fun i x => (h x).1 i,
   funext fun x => (h x).2.1,
   funext fun x => (h x).2.2⟩

/-! ### Reparametrization invariance -/

/-
The identity reparametrization does not change a path.
-/
theorem pathReparam_id {A : Type v} {a₀ a₁ : A}
    (p : PathOver (I := I) A a₀ a₁) :
    pathReparam p id rfl rfl = p := by
  exact Subtype.ext rfl

/-
Composition of reparametrizations.
-/
theorem pathReparam_comp {A : Type v} {a₀ a₁ : A}
    (p : PathOver (I := I) A a₀ a₁)
    (φ ψ : I → I)
    (hφ0 : φ CubicalInterval.i0 = CubicalInterval.i0)
    (hφ1 : φ CubicalInterval.i1 = CubicalInterval.i1)
    (hψ0 : ψ CubicalInterval.i0 = CubicalInterval.i0)
    (hψ1 : ψ CubicalInterval.i1 = CubicalInterval.i1) :
    pathReparam (pathReparam p φ hφ0 hφ1) ψ hψ0 hψ1 =
    pathReparam p (φ ∘ ψ) (by simp [Function.comp, hψ0, hφ0])
                          (by simp [Function.comp, hψ1, hφ1]) := by
  exact Subtype.ext ( funext fun i => rfl )

end CubicalSemantics